---
name: work-git-commit
description: Commit message to Humand's standard. Use before every commit in a Humand repo (`~/Projects/Work/`).
model: sonnet
effort: medium
---

Writes the **message** for the commit about to land. Committing with it is the caller's job.

`~/Projects/Work/_workspace/standards/commits.md` owns the standard, and `~/Projects/Work/_workspace/standards/git.md` the rules it shares with branches and PRs. Read both before writing.

## Inputs

| input | |
|---|---|
| **Change** | What the commit records: the staged diff (`git diff --staged`), or the changes the caller is about to stage. |
| **Intent** | Why the change exists, from the conversation. It decides whether a body is needed and what it says. |

## Message

Type and scope come from the diff itself, read against `git.md` → Type and `commits.md` → Commit scope; the conversation's framing of the work ("a quick fix") yields to what the diff shows.

Done when:

- the type is the `git.md` → Type row the whole diff fits;
- a body is present exactly when the subject leaves *why* open;
- a `!` subject carries the `commits.md` CM-014 footer;
- an agent-generated commit ends with the `commits.md` CM-015 footer, naming the caller's model.

## Output

The message alone, in a fenced block.
