#!/usr/bin/env bash
# PreToolUse hook (Claude Code): blocca le tool call che violano policy.yml.
#
# Input contract: legge da stdin un JSON con i campi tool_name, tool_input.
# Output: exit 0 = allow; exit 2 = block (stderr mostrato all'agente come motivo del blocco).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLICY="$SCRIPT_DIR/../policy.yml"
if [ ! -f "$POLICY" ]; then
  exit 0
fi

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')

block() {
  local reason="$1"
  echo "🛑 BLOCKED by policy.yml" >&2
  echo "Reason: $reason" >&2
  echo "" >&2
  echo "Suggerimento: riformula in modo non distruttivo, oppure modifica policy.yml se sei sicuro." >&2
  exit 2
}

read_section() {
  awk -v section="$1" '
    $0 ~ "^"section":$" { inside=1; next }
    /^[a-zA-Z_]+:$/ { inside=0 }
    inside && /pattern:/ {
      sub(/^[[:space:]]*-?[[:space:]]*pattern:[[:space:]]*/, "")
      gsub(/^['"'"'"]|['"'"'"]$/, "")
      print
    }
  ' "$POLICY"
}

read_reason() {
  local pattern="$1" section="$2"
  PATTERN_VAR="$pattern" awk -v section="$section" '
    BEGIN { p = ENVIRON["PATTERN_VAR"] }
    $0 ~ "^"section":$" { inside=1; next }
    /^[a-zA-Z_]+:$/ { inside=0 }
    inside && /pattern:/ {
      cur=$0
      sub(/^[[:space:]]*-?[[:space:]]*pattern:[[:space:]]*/, "", cur)
      gsub(/^['"'"'"]|['"'"'"]$/, "", cur)
      matched = (cur == p)
    }
    inside && matched && /reason:/ {
      sub(/^[[:space:]]*reason:[[:space:]]*/, "")
      gsub(/^['"'"'"]|['"'"'"]$/, "")
      print
      exit
    }
  ' "$POLICY"
}

case "$TOOL" in
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
    while IFS= read -r pattern; do
      [ -z "$pattern" ] && continue
      if echo "$CMD" | grep -qE "$pattern"; then
        reason=$(read_reason "$pattern" "shell_blocked")
        block "${reason:-pattern $pattern}"
      fi
    done < <(read_section shell_blocked)
    ;;
  Edit|Write|MultiEdit)
    PATH_VAL=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
    while IFS= read -r pattern; do
      [ -z "$pattern" ] && continue
      if echo "$PATH_VAL" | grep -qE "$pattern"; then
        reason=$(read_reason "$pattern" "file_writes_blocked")
        block "${reason:-path matches $pattern}"
      fi
    done < <(read_section file_writes_blocked)
    ;;
esac

exit 0
