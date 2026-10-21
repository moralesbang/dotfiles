# playwright-cli for work-ui-qa

The commands a run uses, and the gotchas `--help` doesn't confess. For any other command or flag, `playwright-cli <command> --help`. For patterns beyond it (dialogs, iframes, uploads, waiting), the bundled skill: `$(brew --prefix playwright-cli)/libexec/lib/node_modules/@playwright/cli/node_modules/playwright-core/lib/tools/skills/playwright-cli/SKILL.md`.

## Gotchas

- **Config is fixed at `open`.** The session runs in a daemon that reads the `PLAYWRIGHT_MCP_*` environment once, when `open` spawns it. Later calls ignore their environment; changing config means `close` and `open` again.
- **Defaults are what the run wants**: headless, Chrome, in-memory profile. Leave `--headed`, `--persistent` and `--profile` off.
- **Secrets go through `fill`.** `fill <target> PASSWORD` types the value of `PASSWORD` from the secrets file. Every output shows the value as `<secret>PASSWORD</secret>`, page text included. A key missing from the file is typed literally, so a plain `PASSWORD` in the result means the key is unset.
- **`--filename` resolves against the shell's cwd**, not the output dir. Always pass absolute paths into the run dir. Output without `--filename` (auto-saved snapshots, logs) lands in `PLAYWRIGHT_MCP_OUTPUT_DIR`.
- **Refs (`e12`) belong to the latest snapshot.** After the page changes, take a new snapshot before using a ref.
- **`requests` resets on page load.** Collect it before a full navigation; in-app route changes keep it.
- **A blocked origin fails with `net::ERR_BLOCKED_BY_CLIENT`**, on navigation and on `fetch` alike. WebSockets bypass the block.
- **`run-code` is sandboxed**: one function expression, `async page => { … }`, with no `require` or `process`.
- **Headless sessions shut down after 1h idle.** A session gone mid-run means reopening it with the full §4 environment.

## Commands

Every call is `playwright-cli -s=<session> <command>`.

| command | use |
|---|---|
| `open <url>` | Start the session (with the §4 environment). |
| `goto <url>` · `reload` · `go-back` | Navigate. |
| `snapshot [target]` | Accessibility tree with refs; a target scopes it to one element. |
| `find <text>` · `find --regex <re>` | Matching snapshot nodes with context: the usual evidence excerpt. |
| `click <target>` · `fill <target> <text>` · `select <target> <val>` · `check <target>` · `hover <target>` · `press <key>` | Act. A target is a ref or a unique selector. |
| `screenshot [target] --filename <abs>.png` | Evidence image; `--full-page` for content below the fold. |
| `console error [--clear]` | Console errors since the last clear. |
| `requests [--filter <re>] [--clear]` | Requests with status; static assets hidden unless `--static`. |
| `eval '<func>' [target]` | Read a value from the page. |
| `run-code '<func>'` | Multi-step Playwright code when single commands fall short. |
| `resize <w> <h>` | Viewport. |
| `state-load <file>` · `state-save <file>` | Auth state in and out. |
| `close` | End the session. |

`request`, `request-headers` and `response-body` expose headers and bodies, which can carry tokens: read them only to diagnose a failure, never copy them into the report.
