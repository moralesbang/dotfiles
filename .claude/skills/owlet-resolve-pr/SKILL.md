---
name: owlet-resolve-pr
description: Answers a pull request's unresolved review threads — fixes each one, replies in it, and resolves it
argument-hint: [pr]
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *), Read, Edit, Grep
model: sonnet
effort: medium
---

## Context

- Current branch: !`git branch --show-current`
- Uncommitted changes: !`git status --short`

Answer every unresolved review **thread** on the pull request named by `$ARGUMENTS`, or on the current branch's PR when that is empty.

A reply carries a **receipt** — the sha that proves the fix is pushed. No claim without a receipt, so the commit and push in §6 come before any reply in §7.

## 1. Resolve the target

`gh pr view <pr> --json number,headRefName,url` resolves the PR. `gh repo view --json nameWithOwner` gives the `<owner>/<repo>` the API calls need.

Two conditions stop the run before it touches anything:

| Condition | Why it stops |
|---|---|
| Uncommitted changes in the context above | This run lands one commit covering every fix; a dirty tree buries unrelated work in it. |
| Head branch is not the current branch | Fixes have to land on the branch under review. |

Report the reason in one line and end.

## 2. Fetch the threads

One query carries everything the run needs — each thread's node `id` for the resolve mutation, and its first comment's `databaseId` for the reply endpoint:

```graphql
query($owner:String!, $name:String!, $pr:Int!, $cursor:String) {
  repository(owner:$owner, name:$name) {
    pullRequest(number:$pr) {
      reviewThreads(first:100, after:$cursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id isResolved isOutdated path line originalLine
          comments(first:50) { nodes { databaseId author { login __typename } body } }
        }
      }
    }
  }
}
```

`gh api graphql -F owner=':owner' -F name=':repo' -F pr=<pr> -f query='…'` runs it from inside the repo.

`reviewThreads` takes no resolved filter, so keep `isResolved: false` and drop the rest. `line` is null on an outdated thread — `originalLine` locates it. `__typename` splits the authors: `User` is a human, anything else is a bot.

Sort the survivors human-first, then number them from 1. That numbering is the run's spine: §4 offers it, you answer with it, §8 reports against it.

Done when every unresolved thread holds a number, an author, a human/bot label, a path and line, and its full comment text, and `hasNextPage` is false.

## 3. Classify every thread

Read the code each thread points at before deciding — the file as it stands now, plus `grep` for the symbol the comment names. A verdict from the comment text alone is a guess.

Every thread lands in exactly one verdict:

| Verdict | When | What §5–§7 do with it |
|---|---|---|
| `FIX` | The concern is real and you know the change. | Edit, reply with the receipt, resolve. |
| `ADDRESSED` | `isOutdated`, and the code at that path no longer carries the concern. | Reply naming the sha that already fixed it, resolve. No edit. |
| `PUSHBACK` | The comment is wrong for this codebase, and you can show it. | Reply with the reasoning. **Leave open** — the reviewer owns the close. |
| `HAND OFF` | Needs product input, or stays ambiguous after reading the code. | Nothing posted, nothing resolved. It comes back to you in §8. |

The split between `PUSHBACK` and `HAND OFF` is the difference between knowing and not: **argue in public, ask in private.** Confident the comment is wrong → say so in the thread. Unsure what it wants → hand it off and let the user answer.

A severity marker in the comment (`hu-reviewer` writes `**[Important]**`) is a label to carry into the plan. It never decides a verdict.

Done when every numbered thread has a verdict and, for `FIX`, the specific edit named.

## 4. Offer the plan

One numbered line per thread, in the §2 order:

```
PLAN — #2290, 4 threads

1 locale/en/general.json:26  hu-reviewer (bot) [Important]
  FIX      add `trigger.tooltip` and `oli.role` to the copy table
2 locale/es/goals.json:8  polbac (human)
  PUSHBACK key has 3 refs (goals.json:8, admin/audience.tsx:14) — removing it breaks the picker
3 locale/en/foo.json:12  hu-reviewer (bot)  outdated
  ADDRESSED already fixed in 9f34357
4 locale/es/bar.json:4  polbac (human)
  HAND OFF all 20 locales, or es only? PR only touches es
```

Then wait. `go` runs the whole plan; `go except 2` or `just 1 and 4` runs a subset. Anything else is a replan, not an execution.

An unapproved item stays untouched, unresolved and unanswered, and §8 reports it as skipped.

## 5. Fix and verify

Apply the approved `FIX` edits.

Then find this repo's own check and run it, scoped to the changed files: `CLAUDE.md` names it in some repos, `package.json` scripts in others (`lint`, `typecheck`, `test`), and a `.scripts/` or `Makefile` target in the rest.

| Result | Next |
|---|---|
| Green | §6. |
| Red, and the cause is one of your edits | Fix it and re-run. Twice red on the same edit is a hand off for that thread — drop it from the run. |
| No check discoverable | Say so in one line and continue to §6. |

Done when every approved `FIX` is edited and the check is green, skipped as unavailable, or reported red.

## 6. Mint the receipt

One commit for the whole run:

```
fix(review): address review comments on #<pr> [owlet]
```

Push it. `git rev-parse --short HEAD` is the **receipt** every reply in §7 cites.

`ADDRESSED` threads carry their own older receipt — the sha found in §3 — so a run of nothing but `ADDRESSED` and `PUSHBACK` skips this step entirely.

## 7. Reply, then resolve

Reply in the thread — never as a top-level PR comment:

```
gh api repos/<owner>/<repo>/pulls/<pr>/comments/<databaseId>/replies -f body='…'
```

`<databaseId>` is the thread's **first** comment.

A reply states the change and its receipt, in the language of the comment it answers:

| Verdict | Shape |
|---|---|
| `FIX` | `Fixed in a1b2c3 — added \`trigger.tooltip\` and \`oli.role\` to the copy table.` |
| `ADDRESSED` | `Addressed in 9f34357 — the key moved to \`general.json\`.` |
| `PUSHBACK` | The technical reasoning, with the evidence that supports it: paths, line numbers, grep counts. Close by inviting the correction — the reviewer may hold context you lack. |

Two lines at most. The diff carries the detail; the reply carries the pointer to it. Gratitude and praise (`thanks`, `good catch`, `you're right`) belong to neither — state the fix instead.

Resolve `FIX` and `ADDRESSED` only:

```
gh api graphql -f query='mutation($t:ID!){ resolveReviewThread(input:{threadId:$t}){ thread { isResolved } } }' -F t=<thread id>
```

`PUSHBACK` stays open by design.

Done when every approved thread has its reply posted, and every `FIX` and `ADDRESSED` among them returns `isResolved: true`.

## 8. Report

One line per numbered thread, shaped like the family's other guards:

```
owlet #2290 FIX       1 general.json:26      fixed a1b2c3, resolved
owlet #2290 PUSHBACK  2 es/goals.json:8      replied, left open
owlet #2290 ADDRESSED 3 en/foo.json:12       resolved
owlet #2290 HAND OFF  4 es/bar.json:4        nothing posted
  needs you: all 20 locales, or es only?
owlet #2290 SKIPPED   5 es/baz.json:2        not approved
```

Every `HAND OFF` adds its `needs you:` line — that line is the whole point of the verdict.

Close with the count still open on the PR and, when that count is zero, say the PR is ready to merge.
