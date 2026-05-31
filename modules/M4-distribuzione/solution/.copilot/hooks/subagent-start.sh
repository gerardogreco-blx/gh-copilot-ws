#!/usr/bin/env bash
# SubagentStart hook: inietta lo schema del DB nella conversation del subagente.
#
# Input contract: legge da stdin un JSON con campi agent_id, agent_type, ...
# Output contract: stdout JSON con hookSpecificOutput.additionalContext.
# Exit 0 = allow; il testo in additionalContext viene aggiunto al contesto del subagente.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_FILE="$SCRIPT_DIR/../context/db-schema.sql"

if [ ! -f "$SCHEMA_FILE" ]; then
  exit 0
fi

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""')

# Inietta lo schema solo per subagenti che hanno bisogno di contesto DB.
# Se cambi il nome del subagente in .github/agents/, aggiorna qui.
case "$AGENT_TYPE" in
  dba|database|sql-expert)
    SCHEMA_BODY=$(cat "$SCHEMA_FILE")
    CONTEXT_MSG=$(printf 'Schema corrente del database applicativo (fonte di verità, iniettato dal SubagentStart hook):\n\n```sql\n%s\n```\n\nUsa esclusivamente nomi di tabella e colonne presenti qui sopra. Se la richiesta non è soddisfacibile con questo schema, dillo esplicitamente.' "$SCHEMA_BODY")
    jq -n --arg ctx "$CONTEXT_MSG" '{hookSpecificOutput: {additionalContext: $ctx}}'
    ;;
  *)
    # Per altri subagenti non iniettiamo nulla: il hook è no-op.
    ;;
esac

exit 0
