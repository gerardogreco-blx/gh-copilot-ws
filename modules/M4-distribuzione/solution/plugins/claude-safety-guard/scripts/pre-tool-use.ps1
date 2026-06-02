#!/usr/bin/env pwsh
# PreToolUse hook (Claude Code, PowerShell): blocca le tool call che violano policy.yml.
#
# Input contract: legge da stdin un JSON con i campi tool_name, tool_input.
# Output: exit 0 = allow; exit 2 = block (stderr mostrato all'agente come motivo del blocco).

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$policyPath = Join-Path $scriptDir "../policy.yml"

if (-not (Test-Path $policyPath)) {
    exit 0
}

$rawInput = [Console]::In.ReadToEnd()
$payload = $rawInput | ConvertFrom-Json
$tool = if ($payload.PSObject.Properties.Name -contains "tool_name") { $payload.tool_name } else { "" }

function Block-Tool([string]$reason) {
    [Console]::Error.WriteLine("🛑 BLOCKED by policy.yml")
    [Console]::Error.WriteLine("Reason: $reason")
    [Console]::Error.WriteLine("")
    [Console]::Error.WriteLine("Suggerimento: riformula in modo non distruttivo, oppure modifica policy.yml se sei sicuro.")
    exit 2
}

function Read-Section([string]$sectionName, [string]$path) {
    $rules = @()
    $inside = $false
    $currentPattern = $null
    foreach ($line in Get-Content -LiteralPath $path) {
        if ($line -match "^${sectionName}:\s*$") { $inside = $true; continue }
        if ($line -match "^[A-Za-z_]+:\s*$") {
            if ($inside -and $currentPattern) { $rules += $currentPattern }
            $inside = $false; $currentPattern = $null; continue
        }
        if (-not $inside) { continue }
        if ($line -match "^\s*-\s*pattern:\s*['""]?(.*?)['""]?\s*$") {
            if ($currentPattern) { $rules += $currentPattern }
            $currentPattern = [pscustomobject]@{ Pattern = $Matches[1]; Reason = "" }
        }
        elseif ($line -match "^\s*reason:\s*['""]?(.*?)['""]?\s*$" -and $currentPattern) {
            $currentPattern.Reason = $Matches[1]
        }
    }
    if ($currentPattern) { $rules += $currentPattern }
    return $rules
}

switch ($tool) {
    "Bash" {
        $cmd = ""
        if ($payload.tool_input -and ($payload.tool_input.PSObject.Properties.Name -contains "command")) {
            $cmd = [string]$payload.tool_input.command
        }
        foreach ($rule in Read-Section "shell_blocked" $policyPath) {
            if ($cmd -match $rule.Pattern) {
                Block-Tool $rule.Reason
            }
        }
    }
    { $_ -in @("Edit", "Write", "MultiEdit") } {
        $pathVal = ""
        if ($payload.tool_input) {
            if ($payload.tool_input.PSObject.Properties.Name -contains "file_path") {
                $pathVal = [string]$payload.tool_input.file_path
            } elseif ($payload.tool_input.PSObject.Properties.Name -contains "path") {
                $pathVal = [string]$payload.tool_input.path
            }
        }
        foreach ($rule in Read-Section "file_writes_blocked" $policyPath) {
            if ($pathVal -match $rule.Pattern) {
                Block-Tool $rule.Reason
            }
        }
    }
}

exit 0
