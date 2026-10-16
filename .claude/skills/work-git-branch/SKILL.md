---
name: work-git-branch
description: Branch name to Humand's standard. Use before creating or renaming a branch in a Humand repo (`~/Projects/Work/`).
model: sonnet
effort: medium
---

Produces the branch **name**, plus the **base** a new branch starts from. Creating or renaming the branch, locally and on origin, is the caller's job.

`~/Projects/Work/_workspace/standards/branches.md` owns the standard, and `~/Projects/Work/_workspace/standards/git.md` the rules it shares with commits and PRs. Read both before writing.

## Inputs

| input | |
|---|---|
| **Token** | Required. Take it from the conversation when it's explicit there; otherwise ask the user. |
| **Description** | Required for a new branch. The work's intent: what changes and why, in one line, enough to pick the type and write the slug — `fix pie chart percentages that add up past 100`, rather than `pie chart`. Build the name from whatever arrives. |
| **Current branch** | Rename only. The new name keeps its type and slug when it has them, unless the inputs change them. |
| **Base** | Optional, new branch only. `git.md` → Base by default. |

## Name

Build it per `branches.md` → Name: the type the description calls for, the token verbatim, the description as the slug.

Done when the type is the one the whole description fits, and the token is the input verbatim.

## Output

One line:

- new branch: `work-git-branch <name> ← origin/<base>`, the base freshly fetched so the branch starts from its latest commit;
- rename: `work-git-branch <old> → <new>`.
