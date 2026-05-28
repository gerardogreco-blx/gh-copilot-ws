#!/usr/bin/env pwsh
# SubagentStart hook (PowerShell): inietta lo schema del DB nella conversation del subagente.
#
# Input contract: legge da stdin un JSON con campi agent_id, agent_type, ...
# Output contract: stdout JSON con hookSpecificOutput.additionalContext.
# Exit 0 = allow; il testo in additionalContext viene aggiunto al contesto del subagente.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$schemaFile = Join-Path $scriptDir "../context/db-schema.sql"

if (-not (Test-Path $schemaFile)) {
    exit 0
}

$rawInput = [Console]::In.ReadToEnd()
$payload = $rawInput | ConvertFrom-Json
$agentType = if ($payload.PSObject.Properties.Name -contains "agent_type") { [string]$payload.agent_type } else { "" }

# Inietta lo schema solo per subagenti che hanno bisogno di contesto DB.
if ($agentType -in @("dba", "database", "sql-expert")) {
    $schemaBody = Get-Content -LiteralPath $schemaFile -Raw
    $contextMsg = @"
Schema corrente del database applicativo (fonte di verità, iniettato dal SubagentStart hook):

``````sql
$schemaBody
``````

Usa esclusivamente nomi di tabella e colonne presenti qui sopra. Se la richiesta non è soddisfacibile con questo schema, dillo esplicitamente.
"@
    $output = @{
        hookSpecificOutput = @{
            additionalContext = $contextMsg
        }
    }
    $output | ConvertTo-Json -Depth 4 -Compress
}

exit 0
