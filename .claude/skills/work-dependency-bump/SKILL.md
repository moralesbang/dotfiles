---
name: work-dependency-bump
description: Dependency bump for `humand-backoffice` and `humand-web`. Use when a branch there needs a `hu-translations` or `material-hu` change its `bun.lock` doesn't lock yet.
---

A consumer's `bun.lock` locks each dependency to a commit, and only the automated **bump PR** moves that lock. A branch absorbs a dependency change by rebasing onto its base once a bump carrying the change merges; until then it runs on a local **pin**.

[`scripts/check.sh`](scripts/check.sh) owns the rule: a branch keeps the `@humanddev/hu-translations` and `@humanddev/material-hu` entries of `bun.lock` and `package.json` at its **fork point** (its merge-base with its base). It also runs as a PreToolUse **guard**: a `git commit` that moves those entries anywhere else is blocked with a pointer back here. Other lockfile changes, from `bun add` or `bun remove`, pass.

## Inputs

| input | |
|---|---|
| **Change** | Required. The `hu-translations` or `material-hu` PR the branch needs. Take it from the conversation; otherwise ask the user. |
| **Base** | The branch's PR base (`gh pr view --json baseRefName`); `develop` when the branch has no PR. |

## 1. Locate

`git fetch origin <base>`, then read `<locked>`: the `#<sha>` of the dependency's `"@humanddev/<dep>":` entry in `origin/<base>:bun.lock`. The base carries the change when the change's PR has merged and `gh api repos/HumandDev/<dep>/compare/<merge commit>...<locked> --jq .status` prints `identical` or `ahead`.

Done when the state is known:

| state | when | next |
|---|---|---|
| **absorbed** | `origin/<base>` carries the change | 2. Rebase |
| **pending** | it does not yet | 3. Pin |

## 2. Rebase

1. Drop a pin left by step 3: `git restore package.json bun.lock`.
2. `git rebase origin/<base>`. On a `bun.lock` conflict, keep the base's side (`--ours` during a rebase) and let `bun install` regenerate the branch's own packages: `git checkout --ours bun.lock && bun install && git add bun.lock && git rebase --continue`.
3. `bun install`.

Done when `origin/<base>` is an ancestor of `HEAD`, `bun install` leaves `bun.lock` unchanged, and `scripts/check.sh` exits 0. A failing check means a commit in the branch carries its own bump: put the entries it names back to the fork point's (for `bun.lock`: `git checkout <fork point> -- bun.lock && bun install`), commit, and run the check again.

## 3. Pin

Runs the branch on the change before its bump merges. The pin lives only in the working tree: commit the feature's files by explicit path while it stands, and the guard keeps it out of every commit.

1. Point the dependency at the change in `package.json`: `"@humanddev/<dep>": "git@github.com:HumandDev/<dep>.git#<ref>"`, `<ref>` being the change's PR branch while the PR is open, `main` once it merged.
2. `bun install`.
3. Find the newest bump PR for the dependency against the base:

   ```sh
   gh pr list --repo HumandDev/<consumer> --author app/humand-react-bot --base <base> --state all --search "bump <dep> in:title" --limit 1
   ```

   The newest bump supersedes earlier ones: it locks the dependency's latest `main`, which contains every earlier commit. On a `release-*` base with no bump in sight, read [`AUTOMATION.md`](AUTOMATION.md).

Done when `bun.lock` locks the dependency at a commit that carries the change, and neither `package.json` nor `bun.lock` is staged. CI runs on the committed lock, so it lacks the change until the bump merges and step 2 runs.

## Output

One line:

- absorbed: `work-dependency-bump <dep> <sha7> ← origin/<base>`, plus `· push --force-with-lease pending` when the branch is already on origin; the push is the caller's job.
- pending: `work-dependency-bump <dep> pinned #<ref> · bump <url | none yet>`.
