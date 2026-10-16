---
name: work-code-review
description: Reviews a branch, PR, or WIP changes against Humand's coding standards and the originating spec.
---

Read `~/.agents/skills/code-review/SKILL.md` and follow it with the user's arguments, unchanged except for step 3.

**Standards sources** (step 3) are the repo-local docs that process finds, **plus** every file in `~/Projects/Work/_workspace/standards/`, which lives outside every repo and worktree.

Done when the Standards sub-agent prompt lists every file in `~/Projects/Work/_workspace/standards/`.
