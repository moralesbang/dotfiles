---
name: work-git-pr
description: Pull request fields to Humand's standard: title, body, assignee, labels. Use before creating or updating a PR in a Humand repo (`~/Projects/Work/`).
model: sonnet
effort: medium
---

Produces the **fields** of the current branch's pull request: base, assignee, labels, title, and body. Pushing, then running `gh pr create` or `gh pr edit` with them, is the caller's job.

`~/Projects/Work/_workspace/standards/pull-requests.md` owns the standard, and `~/Projects/Work/_workspace/standards/git.md` the rules it shares with branches and commits. Read both before writing.

Title and body describe the **change**: `git diff origin/<base>...HEAD`, `git log origin/<base>..HEAD`, and what this conversation built.

## Inputs

| input | |
|---|---|
| **base** | Optional, create only. `git.md` → Base by default. |
| **ticket** | Optional. A Jira key or `NO-CARD`; see **2. Ticket**. |
| **fix target** | Optional. `staging` or `prod`, set only from the user's words that the PR fixes a bug there; see **5. Assignee and labels**. |

## 1. Mode

`gh pr view --json state,title,body,baseRefName,labels` sets the mode:

| result | mode | base |
|---|---|---|
| `state` is `OPEN` | **update** | its `baseRefName` |
| no pull request found, or none open | **create** | the `base` input, else the default |

Any other `gh` error ends the run, reported verbatim.

`git fetch origin <base>`. Then:

- HEAD is `<base>`, or `git log origin/<base>..HEAD` is empty: there is nothing to describe. Report `work-git-pr STOPPED <reason>` and end.
- `git status --short` lists changes: they sit outside the PR. Ask whether to commit them first (message from the `work-git-commit` skill) or leave them out.

Done when the mode and base are set, the branch is ahead of `origin/<base>`, and the uncommitted changes are committed or left out by the user's choice.

## 2. Ticket

The title takes the branch's ticket verbatim (`pull-requests.md` → Ticket):

| branch token | next |
|---|---|
| A Jira key or `NO-CARD`, matching the `ticket` input when one is given | Use it. |
| `TBD`, a name off the standard, or a `ticket` input that differs | Take the `ticket` input, else ask the user for the Jira key or `NO-CARD`. The branch takes a **rename** to carry it: the new name comes from the `work-git-branch` skill, with the ticket as its token. |

Done when the ticket is a Jira key or `NO-CARD`, and any rename it needs has its new name.

## 3. Title

Write it per `pull-requests.md` → Title.

Done when `scripts/check.sh '<title>'` exits 0.

## 4. Body

**Create** fills the body per `pull-requests.md` → Body.

**Update** regenerates `## Summary` alone, from the whole change. Every other section and the footer stay byte-for-byte as the open PR has them.

Done when every template heading is present, in order, with a value, and the footer closes the body.

## 5. Assignee and labels

Set them per `pull-requests.md` → Assignee and labels; **fix target** `staging` picks the staging fix label, `prod` the prod one. In update, the PR's current labels stay, and the output lists the ones it lacks.

Done when `talent` is present, and a fix label is present exactly when **fix target** is set.

## 6. Output

```
work-git-pr <create|update> · base <base>
rename: <old> → <new>
assignee: @me
labels: <labels>
title: <title>
```

`rename` appears only when **2. Ticket** noted one; it lands before the push, so the PR opens on the new name. The body follows in a fenced `markdown` block, with four backticks when the body holds a fence of its own.
