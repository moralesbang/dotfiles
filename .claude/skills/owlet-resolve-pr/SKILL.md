---
name: owlet-resolve-pr
description: Answers the current branch's pull request unresolved review threads — fixes each one, replies in it, and resolves it
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *), Read, Edit, Grep, AskUserQuestion
model: opus
effort: high
---

## Context

- Current branch: !`git branch --show-current`
- Uncommitted changes: !`git status --short`

Answer every unresolved review **thread** on the current branch's pull request. The skill takes no arguments — the branch picks the PR.

A reply carries a **receipt** — the sha that proves the fix is pushed. No claim without a receipt, so the commit and push in §6 come before any reply in §7.

## 1. Resolve the target

`gh pr view --json number,url` resolves the current branch's PR. `gh repo view --json nameWithOwner` gives the `<owner>/<repo>` the API calls need.

Two conditions stop the run before it touches anything:

| Condition | Why it stops |
|---|---|
| Uncommitted changes in the context above | This run lands one commit covering every fix; a dirty tree buries unrelated work in it. |
| No open PR on the current branch | There is nothing to answer, and suggesting one is not this skill's job. |

Report it in one line and end — `😑 owlet — <reason>`, as in `😑 owlet — no open PR on branch feat/foo` or `😑 owlet — uncommitted changes, commit or stash first`.

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
| `HAND OFF` | Needs product input, or stays ambiguous after reading the code. | Nothing posted, nothing resolved. §8 hands it back to you. |

The split between `PUSHBACK` and `HAND OFF` is the difference between knowing and not: **argue in public, ask in private.** Confident the comment is wrong → say so in the thread. Unsure what it wants → hand it off and let the user answer.

A severity marker in the comment (`hu-reviewer` writes `**[Important]**`) is a label to carry into the plan. It never decides a verdict.

Done when every numbered thread has a verdict and, for `FIX`, the specific edit named.

## 4. Offer the plan

A heading, a summary line, and one table row per thread, in the §2 order. Each verdict wears its emoji: 🔧 `FIX` · ✅ `ADDRESSED` · ⛔ `PUSHBACK` · 🙋 `HAND OFF`. The `Author` cell carries the human/bot label and any severity marker; `Plan` names the edit, the argument, the older sha, or the open question.

```markdown
### owlet · PR #2290 · plan

**1 fix** · 1 pushback · 1 addressed · 1 needs input

| # | Verdict | Location | Author | Plan |
|---|---|---|---|---|
| 1 | 🔧 `FIX` | `locale/en/general.json:26` | hu-reviewer (bot) · [Important] | Add `trigger.tooltip` and `oli.role` to the copy table |
| 2 | ⛔ `PUSHBACK` | `locale/es/goals.json:8` | polbac (human) | Key has 3 refs (`goals.json:8`, `admin/audience.tsx:14`) — removing it breaks the picker |
| 3 | ✅ `ADDRESSED` | `locale/en/foo.json:12` | hu-reviewer (bot) · outdated | Already fixed in `9f34357` |
| 4 | 🙋 `HAND OFF` | `locale/es/bar.json:4` | polbac (human) | All 20 locales, or `es` only? PR only touches `es` |

👉 `go` runs everything · `go except 2` / `just 1 and 4` runs a subset · anything else replans
```

Then wait. `go` runs the whole plan; `go except 2` or `just 1 and 4` runs a subset. Anything else is a replan, not an execution.

An unapproved item stays untouched, unresolved and unanswered, and §8 reports it as skipped.

## 5. Fix and verify

Apply the approved `FIX` edits.

Then find this repo's own check and run it, scoped to the changed files: `CLAUDE.md` names it in some repos, `package.json` scripts in others (`lint`, `typecheck`, `test`), and a `.scripts/` or `Makefile` target in the rest.

| Result | Next |
|---|---|
| Green | §6. |
| Red, and the cause is one of your edits | Fix it and re-run. Twice red on the same edit turns that thread into a `HAND OFF` — drop it from the run; §8 reports it. |
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

The same heading and table as §4, now carrying outcomes instead of plans. The summary line counts what happened: resolved, left open, needs input, skipped — drop any count that is zero. `SKIPPED` wears ⏭️.

```markdown
### owlet · PR #2290

**2 resolved** · 1 left open · 1 needs input · 1 skipped

| # | Status | Location | Outcome |
|---|---|---|---|
| 1 | 🔧 `FIX` | `general.json:26` | Committed `a1b2c3` · resolved |
| 2 | ⛔ `PUSHBACK` | `es/goals.json:8` | Replied · left open |
| 3 | ✅ `ADDRESSED` | `en/foo.json:12` | Resolved |
| 4 | 🙋 `HAND OFF` | `es/bar.json:4` | Nothing posted |
| 5 | ⏭️ `SKIPPED` | `es/baz.json:2` | Not approved |

**Needs you · #4:** Update all 20 locales, or `es` only?
```

Every `HAND OFF` adds its **Needs you** line under the table — that line is the whole point of the verdict.

Close with the count still open on the PR and, when that count is zero, say the PR is ready to merge.
