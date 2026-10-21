# Changelog

Breaking changes, newest first. Each entry is a migration guide for the agent updating a machine
that already runs these dotfiles: apply every entry newer than the machine's checkout, in order.

## 2026-10-21: semantic layout

Folders are now named by module, not by the path they land on. Every link into the repo moves.

| old | new |
|---|---|
| `zsh/` | `shell/zsh/` |
| `.config/nvim/` | `editor/nvim/` |
| `.config/ghostty/` | `terminal/ghostty/` |
| `.claude/` | `agents/claude-code/` |
| `.config/ccstatusline/` | `agents/ccstatusline/` |
| `.config/opencode/` | `agents/opencode/` |
| `resources/catppuccin-macchiato.json` | `assets/palettes/catppuccin-macchiato.json` |
| `resources/prompts/` | `assets/prompts/` |
| `.opencode/skills/setup/` (empty) | removed; setup lives in `README.md` |

Also changed:

- `.zshenv` derives `ZDOTDIR` from its own real path instead of hardcoding
  `~/Projects/dotfiles/zsh`. `~/.zshenv` is the only zsh link; `~/.zshrc` and `~/.zprofile` links
  are obsolete.
- `.zshrc` and the `settings.json` hook commands use `$HOME` instead of `/Users/moralesbang`;
  `.zshrc` sources `wt` only when present.

### Migrate

1. **Quiesce.** Ask the user to close every Claude Code session and every terminal but the one you
   run in: `~/.claude` and `ZDOTDIR` both move under them.

   **Done**: the user confirms.

2. **Pull.** Commit local edits to tracked files first, then `git pull --rebase`: rename detection
   carries those edits to the new paths. A conflict lands at the new path; resolve it there,
   keeping the `$HOME` form in hook commands and the derived `ZDOTDIR` line.

   **Done**: `git status` is clean and `shell/zsh/.zshenv` exists.

3. **Move Claude Code's runtime.** The pull moved only tracked files; sessions, history, skills,
   plugins and `hooks/local/` stay in `<dotfiles>/.claude/` (gitignored). Copy them over without
   touching the tracked files:

   ```sh
   rsync -a --ignore-existing <dotfiles>/.claude/ <dotfiles>/agents/claude-code/
   ```

   Show the user `diff -rq <dotfiles>/.claude <dotfiles>/agents/claude-code`; delete
   `<dotfiles>/.claude/` only once they confirm nothing in it is missing from the new folder.

   **Done**: `<dotfiles>/.claude/` is gone and `agents/claude-code/projects/` exists.

4. **Relink.** Replace each old link (`ln -sfn`), then remove the obsolete ones:

   | link | new target |
   |---|---|
   | `~/.zshenv` | `<dotfiles>/shell/zsh/.zshenv` |
   | `~/.config/nvim` | `<dotfiles>/editor/nvim` |
   | `~/.config/ghostty` | `<dotfiles>/terminal/ghostty` |
   | `~/.claude` | `<dotfiles>/agents/claude-code` |
   | `~/.config/ccstatusline` | `<dotfiles>/agents/ccstatusline` |
   | `~/.config/opencode/themes` | `<dotfiles>/agents/opencode/themes` |
   | `~/.zshrc`, `~/.zprofile` | none: remove the symlink |

   Relink only modules the machine already had; a link path holding a real file is the README's
   step-3 stop case. Search for leftovers with
   `find ~ ~/.config -maxdepth 2 -type l -lname '*dotfiles*' ! -exec test -e {} \; -print`.

   **Done**: that `find` prints nothing.

5. **Verify.** Run each linked module's **Verify** from `README.md`. Open terminals still export the
   old `ZDOTDIR`: zsh started from them finds no config until the user opens a new terminal.

   **Done**: every verify succeeds; tell the user to restart their terminals.
