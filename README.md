# Bang's dotfiles

Personal config, grouped by **module**: one tool's config, its requirements and the links that
mount it into the paths the tool reads. Folders are named by what they hold, not by where they
land; each module's **Links** say where that is. The clone can live anywhere (`<dotfiles>` below);
the convention is `~/Projects/dotfiles/`.

Platforms: macOS with Homebrew at `/opt/homebrew`, and Arch-based Linux (CachyOS) with `pacman`.
Install cells read `macOS` · `Linux`; a single command applies to both. What differs per OS lives
in the module itself, picked at link time (see `ghostty`).

| module | folder | what |
|---|---|---|
| `zsh` | `shell/zsh/` | Shell: prompt, history, plugins, aliases, work-account `gh` |
| `nvim` | `editor/nvim/` | Neovim on `vim.pack`, LSP, pickers |
| `ghostty` | `terminal/ghostty/` | Terminal, font, cursor shaders |
| `claude-code` | `agents/claude-code/`, `agents/ccstatusline/` | Claude Code settings, hooks, themes, status line |
| `opencode` | `agents/opencode/` | OpenCode themes and base config |

`assets/` is reference material outside any module: the Catppuccin palette and saved prompts.

Coming from the old layout (`.config/`, `zsh/`, `.claude/` at the root)? Migrate with
[`CHANGELOG.md`](CHANGELOG.md) first.

## Setup

Run the steps in order. Each ends on its **done** condition; the next step starts only once it holds.

### 1. Choose

Show the user the module table and ask which to set up: all, or a subset (only `nvim`, say).

**Done**: the user named the set of modules.

### 2. Requirements

For each chosen module, run every check in its **Requirements** table. List the failing ones to
the user with their install commands and install the ones they confirm. **Optional** rows only
enable a feature; report them, never block on them.

**Done**: every non-optional check of every chosen module passes.

### 3. Link

Create each chosen module's **Links**, with the absolute `<dotfiles>` path as source. Make the
parent directory when missing.

A real file or directory already at a link path is the machine's own config: stop and hand it to
the user to back up or merge; the link goes in only once the path is free. A symlink pointing
elsewhere is replaced only with the user's confirmation.

**Done**: `readlink` on each link prints its `<dotfiles>` source.

### 4. Verify

Run each chosen module's **Verify** command.

**Done**: every verify command succeeds; report each result to the user.

## Modules

### zsh

| requirement | check | install |
|---|---|---|
| macOS only: Homebrew | `test -x /opt/homebrew/bin/brew` | [brew.sh](https://brew.sh) |
| starship, fzf, atuin, zoxide, eza, lazygit, gh | `command -v <tool>` | `brew install <tool>` · `pacman -S <tool>` (`github-cli` for gh) |
| zinit | `brew --prefix zinit` · `test -r ~/.local/share/zinit/zinit.git/zinit.zsh` | `brew install zinit` · `git clone https://github.com/zdharma-continuum/zinit ~/.local/share/zinit/zinit.git` |
| Nerd Font in the terminal (eza icons, prompt) | ask the user | see `ghostty` |
| **Optional**: Bun (completions) | `command -v bun` | `curl -fsSL https://bun.sh/install \| bash` |
| **Optional**: nvm (node pinned by `.nvmrc`) | `test -d ~/.nvm/versions/node` | [nvm](https://github.com/nvm-sh/nvm#installing-and-updating) |
| **Optional**: `wt` (worktrees) | `test -s ~/Projects/wt/shell/wt.zsh` | work-harness `global-scripts/wt/README.md` |

**Links**: `~/.zshenv` → `<dotfiles>/shell/zsh/.zshenv`. Only that one: `.zshenv` points
`ZDOTDIR` at its own real directory, and zsh reads `.zprofile` and `.zshrc` from there.

**Verify**: `env -u ZDOTDIR zsh -i -c 'echo $ZDOTDIR'` prints `<dotfiles>/shell/zsh`.

`.zshenv` carries work wiring for `~/Projects/Work/`: the `gh` account `jmorales-hu`, the
harness's `_workspace/scripts` on `PATH`, and nvim's `NVIM_PICK_SCOPE`.

### nvim

| requirement | check | install |
|---|---|---|
| Neovim 0.12+ (`vim.pack`) | `nvim --version` | `brew install neovim` · `pacman -S neovim` |
| ripgrep (pickers) | `command -v rg` | `brew install ripgrep` · `pacman -S ripgrep` |
| tree-sitter CLI and a C compiler (parsers) | `command -v tree-sitter cc` | `brew install tree-sitter-cli`; `xcode-select --install` · `pacman -S tree-sitter-cli base-devel` |
| Node (Mason installs the LSP servers) | `command -v npm` | `brew install node` · nvm (zsh puts its newest node on `PATH`) |
| Nerd Font in the terminal | ask the user | see `ghostty` |
| **Optional**: TypeScript 7 (`tsc --lsp`) | `command -v tsc` | `bun add -g typescript` |

**Links**: `~/.config/nvim` → `<dotfiles>/editor/nvim`.

**Verify**: `nvim --headless +'lua print(vim.fn.resolve(vim.fn.stdpath("config")))' +qa` prints
`<dotfiles>/editor/nvim`. The first interactive `nvim` installs the plugins pinned in
`nvim-pack-lock.json`: hand that launch to the user.

`editor/nvim/AGENTS.md` holds the plugin layout rules; `README.md` the mappings.

### ghostty

| requirement | check | install |
|---|---|---|
| Ghostty | `command -v ghostty` | `brew install --cask ghostty` · `pacman -S ghostty` |
| MonaspiceNe Nerd Font | `fc-list \| grep -i monaspicene` (macOS: `ls ~/Library/Fonts \| grep -i monaspice`) | `brew install --cask font-monaspice-nerd-font` · `pacman -S otf-monaspace-nerd` |

**Links**:

- `~/.config/ghostty` → `<dotfiles>/terminal/ghostty`
- `<dotfiles>/terminal/ghostty/local` → `os/macos` or `os/linux` (relative, gitignored)

`config` holds what both OSes share and includes `local` last. `os/<os>` holds font size,
opacity and OS-only keys (`macos-*`; Linux: GTK blur CSS, Hyprland accent keybinds, `command`).

**Verify**: `ghostty +validate-config` exits `0`.

### claude-code

| requirement | check | install |
|---|---|---|
| Claude Code | `command -v claude` | `curl -fsSL https://claude.ai/install.sh \| bash` |
| jq (hooks) | `command -v jq` | `brew install jq` · `pacman -S jq` |
| Bun (status line runs `bunx ccstatusline`) | `command -v bun` | `curl -fsSL https://bun.sh/install \| bash` |
| **Optional**: work-harness (skills, `work-dependency-bump` hook) | `test -d ~/Projects/work-harness` | its `README.md` |

**Links**:

- `~/.claude` → `<dotfiles>/agents/claude-code`
- `~/.config/ccstatusline` → `<dotfiles>/agents/ccstatusline`

`~/.claude` is linked whole, so Claude Code's runtime data (sessions, history, caches, plugins,
skills) lands in `agents/claude-code/` too; `.gitignore` tracks only `CLAUDE.md`, `settings.json`,
`hooks/` and `themes/`. A `~/.claude` that already exists is the step-3 stop case: the user
closes every Claude Code session before merging it. `~/.claude.json` stays outside the repo.

**Verify**: `jq -e .hooks ~/.claude/settings.json` and `test -f ~/.config/ccstatusline/settings.json`
both succeed.

Reference:

- **Skills**: `skills/` is local. `work-*` and hero skills install from work-harness
  `skills/README.md`. The `block-skills-all-agents.sh` hook blocks installing a skill for every agent.
- **Local hooks**: `hooks/local/session-start.sh`, when present, runs on `SessionStart`: the place
  for machine-only integrations. Herdr, for one: its installer drops `hooks/herdr-agent-state.sh`
  (gitignored) and adds a `SessionStart` entry to `settings.json`. Move that entry's command into
  `hooks/local/session-start.sh` and drop it from `settings.json`, which is shared.
- **Themes**: `themes/README.md`.

### opencode

| requirement | check | install |
|---|---|---|
| OpenCode | `command -v opencode` | [opencode.ai/docs](https://opencode.ai/docs) |

**Links**: `~/.config/opencode/themes` → `<dotfiles>/agents/opencode/themes`.

`cli.json` and `tui.jsonc` are a base, not links: copy each into `~/.config/opencode/` when absent.
Each machine adds its own plugins and picks its theme there: `catppuccin-macchiato-transparent`
or `catppuccin-mocha-transparent`. Drop the base `tui.jsonc` plugin path on machines without it.

**Verify**: `test -f ~/.config/opencode/themes/catppuccin-macchiato-transparent.json`.
