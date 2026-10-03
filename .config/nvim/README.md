# Neovim configuration

This configuration uses [Oil](https://github.com/stevearc/oil.nvim) for filesystem navigation and manipulation, and [MiniPick](https://github.com/nvim-mini/mini.pick) for fuzzy file, text, buffer, and selection searches.

## Search mappings

| Mapping | Action |
| --- | --- |
| `<leader>ff` | Find files in the default scope |
| `<leader>fg` | Live grep in the default scope |
| `<leader>fF` | Find files across the project, including ignored files |
| `<leader>fG` | Live grep across the project, including ignored files |
| `<leader>fb` | Find open buffers |
| `<leader>fr` | Resume the previous picker |

`<leader>` is Space.

## Buffer mappings

These mappings follow LazyVim, using `mini.bufremove` instead of Snacks for buffer deletion.

| Mapping | Action |
| --- | --- |
| `H` / `[b` | Previous buffer |
| `L` / `]b` | Next buffer |
| `<leader>bb` / ``<leader>` `` | Switch to the alternate buffer |
| `<leader>bd` | Delete the current buffer, preserving splits |
| `<leader>bo` | Delete other listed buffers, preserving splits |
| `<leader>bi` | Delete listed buffers not visible in any tab |
| `<leader>bD` | Delete the current buffer and close its windows |

Deletion with `mini.bufremove` asks for confirmation before discarding unsaved changes. `<leader>bD` uses Neovim's `:bdelete`, which refuses to discard unsaved changes.

## Search scopes

| Context | Default scope (`ff`/`fg`) | Across-project scope (`fF`/`fG`) |
| --- | --- | --- |
| `HumandDev/humand-backoffice` | `src/pages/dashboard/PeopleExperience` | Git repository root |
| `HumandDev/humand-web` | `src/pages/dashboard/PeopleExperience` | Git repository root |
| Any other Git repository | Neovim's working directory | Git repository root |
| Outside Git | Neovim's working directory | Neovim's working directory |

The two Humand repositories are identified by their `origin` URL, so the special scope continues to work for relocated clones and Git worktrees.

Oil's directory-changing actions affect the working-directory scope used by MiniPick.

## Ignore behavior

### Default search

`<leader>ff` and `<leader>fg`:

- Include hidden files.
- Honor root and nested `.gitignore` files.
- Do not honor `.git/info/exclude`, global Git excludes, `.ignore`, or `.rgignore`.
- Always omit `.git/` and `.claude/worktrees/`.

This keeps locally excluded documentation such as `CLAUDE.md`, `CONTEXT.md`, and `docs/` searchable while retaining the project's shared `.gitignore` policy.

### Across-project search

`<leader>fF` and `<leader>fG` include both normal and ignored files. They always omit these potentially large directories:

- `.git/`
- `.claude/worktrees/`
- `node_modules/`
- `build/`

Other ignored output, including `coverage/`, `playwright-report/`, `test-results/`, and `test-triage/`, is available through these mappings on demand.

## MiniPick controls

| Key | Action |
| --- | --- |
| `<CR>` | Open or accept the selected item |
| `<C-n>` / `<C-p>` | Move to the next or previous item |
| `<Tab>` | Toggle preview |
| `<S-Tab>` | Toggle picker information |
| `<Esc>` | Close the picker |
| `<C-e>` | Switch live grep between regular-expression and plain-text matching |

MiniPick also provides the interface for `vim.ui.select`, Neovim's shared API for selection menus opened by plugins.

## Oil and MiniPick

- Press `-` to open Oil when navigating or modifying files and directories.
- Press `gyr` to copy the cursor entry's path relative to Neovim's working directory to the system clipboard.
- Press `gya` to copy the cursor entry's absolute path to the system clipboard, abbreviating your home directory as `~`.
- Use MiniPick when searching by file name, searching file contents, switching buffers, or choosing from a plugin-provided menu.

## Markdown rendering

[render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) is disabled by default. In Markdown buffers, press `<leader>mr` (Space, m, r) or run `:RenderMarkdown buf_toggle` to toggle rendering for the current buffer only. Other buffers remain unchanged.

Rendering keeps the plugin's default backgrounds and tables but removes decorative icons from headings, code blocks, links, callouts, and the sign column. Lists and checkboxes keep their original Markdown markers. Raw Markdown is shown in Insert mode and on the cursor line. Tree-sitter highlighting is enabled for Markdown using Neovim's bundled `markdown` and `markdown_inline` parsers. This configuration requires a Neovim installation that includes both parsers (as Neovim 0.12 does).

Run `:checkhealth render-markdown` to check the setup. HTML comment concealment, LaTeX rendering, and YAML frontmatter rendering need optional parsers/tools that are not installed by this configuration.
