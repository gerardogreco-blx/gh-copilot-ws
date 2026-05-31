#!/usr/bin/env pwsh
# PreToolUse hook (PowerShell): blocks tool calls that violate .copilot/policy.yml.
#
# Input contract: reads JSON from stdin with keys: tool, parameters
# Output: exit 0 = allow; exit 1 = block (stdout shown to agent as block reason)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$policyPath = Join-Path $scriptDir "../policy.yml"

if (-not (Test-Path $policyPath)) {
    exit 0
}

$rawInput = [Console]::In.ReadToEnd()
$payload = $rawInput | ConvertFrom-Json
$tool = if ($payload.PSObject.Properties.Name -contains "tool") { $payload.tool } else { "" }

function Block-Tool([string]$reason) {
    Write-Host "🛑 BLOCKED by .copilot/policy.yml"
    Write-Host "Reason: $reason"
    Write-Host ""
    Write-Host "Suggerimento: riformula in modo non distruttivo, oppure modifica policy.yml se sei sicuro."
    exit 1
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
        if ($payload.parameters -and ($payload.parameters.PSObject.Properties.Name -contains "command")) {
            $cmd = [string]$payload.parameters.command
        }
        foreach ($rule in Read-Section "shell_blocked" $policyPath) {
            if ($cmd -match $rule.Pattern) {
                Block-Tool $rule.Reason
            }
        }
    }
    { $_ -in @("Edit", "Write", "MultiEdit") } {
        $pathVal = ""
        if ($payload.parameters) {
            if ($payload.parameters.PSObject.Properties.Name -contains "file_path") {
                $pathVal = [string]$payload.parameters.file_path
            } elseif ($payload.parameters.PSObject.Properties.Name -contains "path") {
                $pathVal = [string]$payload.parameters.path
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
