#!/usr/bin/env bash
# PR-title standard for the Humand repos — the single source of its regex.
#   check.sh <title>   exit 0 when <title> matches, 1 otherwise.
re='^\[([A-Z]+-[0-9]+|NO-CARD)\] OWL \| .+$'
linear='OWL-[0-9]+'

if grep -qE "$linear" <<<"$1"; then
  echo "Invalid PR title '$1': $(grep -oE "$linear" <<<"$1" | head -1) is a Linear key; cite the Jira key or NO-CARD." >&2
  exit 1
fi
grep -qE "$re" <<<"$1" && exit 0
echo "Invalid PR title '$1': expected [<TICKET>] OWL | <description>." >&2
exit 1
