---
name: work-ui-qa
description: UI QA of an implemented feature against its spec's acceptance criteria, in a headless browser on Humand's dev environment. Use when verifying a hu-web or hu-backoffice feature in the browser, standalone or as the SDD verification loop.
allowed-tools: Bash(playwright-cli *), Bash(lsof *), Bash(grep -q *), Read, Write
---

Drives the local frontend with `playwright-cli` and judges every acceptance criterion (**AC**) of a spec as `pass`, `fail` or `not-verifiable`. The output is a report the implementer reads to fix what failed.

The spec's ACs are the whole scope. Each AC is copied verbatim and judged as written: the run never invents, infers, rewrites or completes an AC, and a spec without identifiable ACs aborts the run.

An AC passes only on **evidence**: what the run observed in the page, held as a snapshot excerpt plus a screenshot. No evidence, no `pass`.

## Inputs

| input | |
|---|---|
| **Spec** | Required. Path to the spec file. |
| **Project** | Required. `hu-web` or `hu-backoffice`. |
| **Checkout** | Optional. The working tree on the feature branch; defaults to `~/Projects/Work/<project>`. A worktree path when the feature lives in one. |
| **Routes** | Optional. URLs or paths where the feature lives. Hints only: they never add or narrow ACs. |

An abort reports one line and ends: `😑 work — <reason>`, as in `😑 work — spec has no identifiable ACs`. Every abort after §3 still runs §7.

## 1. Preconditions

1. Read the spec. Collect every AC: the items labelled `AC-<n>`, each with its exact text. None found → abort.
2. `~/Projects/Work/.secrets/<project>/develop.env` must exist and be non-empty (`test -s`). Missing → abort, telling the user to create it from `develop.env.example` next to it, with `chmod 600`.
3. `command -v playwright-cli` must succeed.
4. **Second user**: available when both `grep -q '^EMAIL_2=.' <env>` and `grep -q '^PASSWORD_2=.' <env>` succeed.

**`.secrets/` stays opaque.** Its files are only ever passed by path to `playwright-cli`, or tested with `test` and `grep -q`, whose exit code is their only output. Their contents never enter context: the credentials and the session tokens in the state files stay outside the transcript.

Done when the AC list holds every `AC-<n>` in the spec, verbatim, in spec order.

## 2. Run dir and marker

- **Feature slug**: the spec's parent dir name when the spec lives under `~/Projects/Work/.sdd/`, else the spec's file name without extension.
- **Run dir**: `~/Projects/Work/.sdd/<feature-slug>/verify/<YYYYMMDD-HHMMSS>/`, created now. Every artifact of the run lands inside it; nothing is written to the checkout.
- **Marker**: `(vMMDD:HHMM)` from the run's start time, as in `(v1018:2041)`. Every text field the run fills on an entity it creates ends with the marker.
- **Sessions**: one per user (§4), `ui-qa-<HHMMSS>-<n>`. Every `playwright-cli` call carries the acting user's `-s=<session>`.

## 3. Dev server

| project | port | start command (from the checkout) |
|---|---|---|
| `hu-web` | 3001 | `VITE_PORT=3001 bun start` |
| `hu-backoffice` | 3000 | `bun start --port 3000` |

`lsof -nP -iTCP:<port> -sTCP:LISTEN -t` gives the listener's PID; `lsof -a -p <pid> -d cwd -Fn` its cwd.

- **Listener whose cwd is the checkout**: reuse it.
- **Listener elsewhere**: abort. The port belongs to someone else's server.
- **No listener**: start it in the background, output to `<run>/server.log`, and poll `lsof` until the port listens (2 min cap; on timeout, abort and quote the log's tail). Record the PID. This run owns that server.

## 4. Browser and auth

Read [`references/playwright-cli.md`](references/playwright-cli.md) before the first `playwright-cli` call.

Both users log into the same `COMMUNITY`, each in its own session:

| user | session | email · password keys | state file (in `~/Projects/Work/.secrets/<project>/`) |
|---|---|---|---|
| **u1** | `ui-qa-<HHMMSS>-1` | `EMAIL` · `PASSWORD` | `develop.state.json` |
| **u2** | `ui-qa-<HHMMSS>-2` | `EMAIL_2` · `PASSWORD_2` | `develop.2.state.json` |

u1 goes through this section now. u2 goes through it at the first AC that needs it (§5), with its own session, keys, state file and guard check.

Open the user's session with its config. The environment applies once, at `open`:

```sh
PLAYWRIGHT_MCP_SECRETS_FILE=~/Projects/Work/.secrets/<project>/develop.env \
PLAYWRIGHT_MCP_OUTPUT_DIR=<run>/cli \
PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900 \
PLAYWRIGHT_MCP_BLOCKED_ORIGINS='api-prod.humand.co;app.humand.co;admin.humand.co;assets.humand.co;sockets-service-prod.humand.co' \
playwright-cli -s=<session> open http://localhost:<port>
```

The blocked origins are the network half of the **prod guard**: the browser cannot reach production. Staging is allowed.

**State.** When the user's state file exists, `state-load` it and reload. Landing inside the app means the session is live: skip to the guard check. Landing on the login page means it expired: log in.

**Spanish UI.** The run expects every page in Spanish, starting with the login's "Usuario" field. A login, community picker or app page in another language → abort (`UI not in Spanish; switch the user's language`).

**Login.** Email and password, no SSO:

1. `fill` the "Usuario" field with the user's email key, then Continue.
2. In the community picker, `fill` the search box with `COMMUNITY`, then snapshot. Exactly one option whose whole text is `<secret>COMMUNITY</secret>` → click it. None → abort (`community not found`); several → abort (`community ambiguous`). `COMMUNITY` holds the community's name as the picker shows it.
3. Run the guard check, then `fill` the password field with the user's password key and submit.
4. `state-save` to the user's state file, then `chmod 600` it.

An SSO, OTP or any other step outside this flow → abort; every AC is `not-verifiable` and §6 still writes the report.

**Guard check.** The second half of the prod guard, run before the password is typed:

```sh
playwright-cli -s=<session> eval '() => [...new Set(performance.getEntriesByType("resource").map(e => new URL(e.name).host))]'
```

The API host must be `*.dev.humand.co` or `*.stg.humand.co`. A production host, or any `ERR_BLOCKED_BY_CLIENT` in `requests` → abort before anything else is typed.

Done when the user's session is authenticated inside the app and its guard check saw a dev or staging API host.

## 5. Verify each AC

**Users.** u1 performs every step. u2 acts only in an AC that names a second user or another admin.

For each AC, in order:

1. **Reach** the feature: the Routes input, the app's own navigation, or the checkout's routing code (read-only) to find the URL.
2. **Act** as the AC describes, at 1440x900. `resize` to `390 844` only for an AC that names mobile, and back after it.
3. **Observe**: `find` or a scoped `snapshot` for the excerpt that shows each clause of the AC; `screenshot --filename <run>/shots/ac-<n>-<user>.png`.
4. **Collect** `console error` and the 4xx/5xx entries of `requests` from each session the AC used, then clear both (`--clear`), so each AC carries only its own errors.
5. **Judge**:

| result | when |
|---|---|
| `pass` | The evidence shows every clause of the AC holding. |
| `fail` | The evidence shows a clause not holding. |
| `not-verifiable` | Anything else: the feature can't be reached, the AC needs SSO/OTP, email, a second user `develop.env` lacks (§1), or pre-existing data, its wording admits more than one reading, or the evidence is inconclusive. |

**Data.** The run creates only the entities an AC needs, each named with the marker. Every edit or delete targets an entity carrying this run's marker; an AC that needs to change data the run did not create is `not-verifiable`. Created entities stay in dev; the report lists them.

Done when every AC holds a result, its steps, and its evidence (or, for `not-verifiable`, the one-line reason).

## 6. Report

Write `<run>/report.md`:

````md
# UI QA — <feature-slug>

- **Spec:** <path>
- **Target:** <project> · <checkout> · <branch> @ <short sha> · http://localhost:<port>
- **Run:** <timestamp> · marker `<marker>`
- **Result:** <pass | fail | not-verifiable> — <n> pass · <n> fail · <n> not-verifiable

## AC-<n> — <result>

> <AC text, verbatim>

**Steps**
1. [u1] …

**Evidence** (u1)
```
<snapshot excerpt>
```
![AC-<n> · u1](shots/ac-<n>-u1.png)

**Reason** (fail / not-verifiable only): <one line>

**Errors**
- console: <message>
- `<METHOD> <url>` → <status>

## Created data

| type | name | URL |
|---|---|---|
````

The top-level result is `pass` only when every AC passes; otherwise `fail` when any AC fails; otherwise `not-verifiable`.

Each step and each evidence block names its user; u2's appear only in ACs where u2 acted.

Errors list method, URL and status only. Request and response headers and bodies stay out of the report: they can carry session tokens.

## 7. Teardown

1. `playwright-cli -s=<session> close`, for every session the run opened.
2. Stop the dev server only when §3 started it: `kill <pid>`.
3. Return to the caller the report path and a summary: the counts, plus one line per non-`pass` AC (`AC-<n> — <result>: <reason>`).

The run dir stays: the implementer reads it, and the SDD orchestrator deletes `verify/` when the feature closes.
