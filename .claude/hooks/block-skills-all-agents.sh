#!/usr/bin/env bash
# PreToolUse(Bash): block `skills add` targeting every agent (`-a '*'`, `--agent '*'`, `--all`).
# Convention: canonical in ~/.agents/skills, Claude Code via symlink.
cmd=$(jq -r '.tool_input.command // empty')

if grep -qE '(^|[[:space:];&|])skills(@[^[:space:]]+)?[[:space:]]+(add|a)([[:space:]]|$)' <<<"$cmd" &&
  grep -qE "(-a|--agent)[[:space:]=]+['\"]?\*|--all([[:space:]]|$)" <<<"$cmd"; then
  echo "Blocked: never install skills to every agent. Use: bunx skills add <pkg> -g -s <skill> -a claude-code codex -y (canonical in ~/.agents/skills, symlink in ~/.claude/skills)." >&2
  exit 2
fi
exit 0
