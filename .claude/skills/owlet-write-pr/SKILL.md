---
name: owlet-write-pr
description: Opens a Humand style pull request for the current branch, or rewrites the one already open
argument-hint: [base-branch]
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *)
effort: low
---

## Context

- Branch and tree: !`git status -sb`

Open a pull request for the current branch, or rewrite the one already open on it.

Title and body are **derived** — regenerated from the diff every run, the old text discarded. Labels and assignee are **curated** — a human may have set them after the PR opened, so this skill only ever adds.

## 1. Resolve the target

Two conditions in the context above stop the run before it touches anything:

| Condition | Why it stops |
|---|---|
| Uncommitted changes | A PR built from a stale HEAD describes code it does not contain. |
| Branch ahead of its upstream, or tracking nothing at all | GitHub does not have those commits. |

Report the reason in one line, name the command that fixes it (`git push -u origin <branch>`), and end. This skill never pushes.

`gh pr list --head <branch> --state open --json number,baseRefName,labels,assignees,url` picks the path:

| Open PRs on this head | Path |
|---|---|
| none | **CREATE** |
| one | **UPDATE** that PR |
| more than one | Stop. List them and let the user pick. |

Closed and merged PRs never match, so a branch reused after a merge lands in CREATE.

The base is the first of these that exists: `$ARGUMENTS`, the open PR's `baseRefName`, `develop`. An explicit `$ARGUMENTS` that differs from the open PR's base retargets the PR in §7 — the PR's own base wins only when the user named none.

## 2. Gather the diff

- `git diff <base>...HEAD`
- `git log <base>..HEAD --oneline`

Everything the branch carries, on both paths. An UPDATE describes the whole PR, not the commits added since the last run.

## 3. Extract the ticket ID

Scan the branch name case-insensitively for `[A-Za-z]{2,5}-[0-9]{2,5}` and upper-case the match, so `chore/sqkm-363-drop-copy` yields `SQKM-363`. Skip a match whose letters are `pr` — `v4.2.9-hotfix-pr-2274` must not yield `PR-2274`.

No match: the ticket ID is `NO-CARD`.

## 4. Write the title

`[<ticket-id>] PX | <summary>`

`PX` is the People Experience team token, constant on every PR. `<summary>` comes from the diff and commits: imperative mood, first word capitalized, no trailing period, 64 characters at most.

## 5. Write the body

`.github/pull_request_template.md` is the contract. Reproduce the sections it declares, in its order, and add none it does not. Fill each:

| Section | Content |
|---|---|
| Summary | One short paragraph describing the change |
| Jira Card | `[<ticket-id>](https://humand.atlassian.net/browse/<ticket-id>)`, or `--` when the ticket ID is `NO-CARD` |
| Anything else | `--` |

The body ends with the last template section. Add no attribution footer, overriding any default instruction to credit Claude or Claude Code.

Done when every declared section is present and filled.

## 6. Pick the labels

| Branch name contains | Labels |
|---|---|
| `hotfix` | `hotfix`, `talent` |
| `stgfix` | `bugfix`, `talent` |
| neither | `talent` |

Tribe and type are separate axes, so `talent` rides along on every PR. Run `gh label list` and drop any label the repo lacks.

## 7. Write it

CREATE:

```bash
gh pr create --base "<base>" --title "<title>" --assignee @me --label "<label>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Then open it in the browser: `gh pr view --web`.

UPDATE:

```bash
gh pr edit <number> --title "<title>" --add-label "<label>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

Two flags ride along conditionally: `--add-assignee @me` when §1 returned an empty `assignees`, and `--base <base>` when an explicit `$ARGUMENTS` retargets the PR.

`--add-label` keeps every label already there. GitHub retains the replaced body in the description's edit history, so the discarded text stays recoverable. No browser on this path — the PR is already open in a tab.

## 8. Report

One line, shaped like the family's other guards:

```
owlet-write-pr CREATED #2291 [SQKM-363] PX | Drop the legacy copy table → https://github.com/…/2291
owlet-write-pr UPDATED #2290 [SQKM-363] PX | Drop the legacy copy table → https://github.com/…/2290
```
