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

## Input prompts

[mini.input](https://github.com/nvim-mini/mini.input) provides `vim.ui.input` and compatible Mini plugin prompts. General prompts open centered in the editor; explicit consumer scopes are preserved, so LSP rename and the inputs from `mini.ai` and `mini.surround` stay near the cursor. MiniPick keeps its own internal input view, and MiniNotify continues to handle notifications.

Appearance, editing keys, and completion use MiniInput's defaults. Press `<CR>` to accept, `<Esc>` to cancel, and `<Tab>` / `<S-Tab>` to navigate completion. `<C-o>` cycles the scope and `<C-s>` cycles the position while a prompt is open. Native `:`, `/`, `?`, and confirmation dialogs are unchanged; native UI setup lives in `lua/config/ui.lua`.

To check the setup after restarting Neovim, run `:lua vim.ui.input({ prompt = "Centered input: " }, vim.print)` and `:lua vim.ui.input({ prompt = "Cursor input: ", scope = "cursor" }, vim.print)`. Test LSP rename in a buffer with an attached language server, custom textobject edges (`va?`), function surroundings (`saf` after selecting text), and MiniPick (`<leader>ff`). Check that prompts accept/cancel correctly and keep their expected positions.

## Oil and MiniPick

- Press `-` to open Oil when navigating or modifying files and directories.
- Press `gyr` to copy the cursor entry's path relative to Neovim's working directory to the system clipboard.
- Press `gya` to copy the cursor entry's absolute path to the system clipboard, abbreviating your home directory as `~`.
- Use MiniPick when searching by file name, searching file contents, switching buffers, or choosing from a plugin-provided menu.

## Markdown rendering

[render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) is disabled by default. In Markdown buffers, press `<leader>mr` (Space, m, r) or run `:RenderMarkdown buf_toggle` to toggle rendering for the current buffer only. Other buffers remain unchanged.

Rendering keeps the plugin's default backgrounds and tables but removes decorative icons from headings, code blocks, links, callouts, and the sign column. Lists and checkboxes keep their original Markdown markers. Raw Markdown is shown in Insert mode and on the cursor line. Tree-sitter highlighting is enabled for Markdown using Neovim's bundled `markdown` and `markdown_inline` parsers. This configuration requires a Neovim installation that includes both parsers (as Neovim 0.12 does).

Run `:checkhealth render-markdown` to check the setup. HTML comment concealment, LaTeX rendering, and YAML frontmatter rendering need optional parsers/tools that are not installed by this configuration.

## Markdown browser preview

[markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) opens manually in the default browser. In Markdown buffers, press `<leader>mp` (Space, m, p) to toggle the current file's preview without closing previews for other files. Each Markdown buffer has its own browser tab, so multiple files can be previewed simultaneously. Previews remain open when switching buffers, and browser scrolling is independent of the editor. `<leader>mr` still controls rendering inside Neovim.

The preview uses dark Catppuccin Macchiato for the content panel, syntax highlighting, and Mermaid diagrams without changing Neovim's colorscheme. The outer page background is `#0f0e16` and the main foreground is `#f7f8fd`. Text, headings, and Mermaid labels use the locally installed Xenon family (`MonaspiceXe Nerd Font`); code blocks, inline code, and keyboard shortcuts use Argon (`MonaspiceAr Nerd Font Mono`). KaTeX keeps its mathematical fonts. The base text size is 14px, with proportionally sized headings and code. The original spacing is preserved, with a wider 1200px content limit. Heading levels H1–H6 use Macchiato red, peach, yellow, green, sapphire, and lavender respectively.

The official prebuilt binary is installed asynchronously on first launch of Neovim and checked after plugin updates. Downloading requires `bash`, `curl` or `wget`, and `tar`. The current upstream installer supports native Apple Silicon; the binary assets are published under release `v0.0.10`. No Node/Yarn dependencies are installed. Run `:MarkdownPreviewInstall` to verify or retry installation.

`:MarkdownPreview` opens the current file's preview; `<leader>mp` can close it even when opened with that command. `:MarkdownPreviewStop` stops the server and all previews, while `<leader>mp` only closes the current buffer's preview. The upstream `:MarkdownPreviewToggle` also stops all previews when toggled off; use the keymap for independent control. The browser may prevent automatic tab closure; close the tab manually if necessary. The server is restricted to localhost.

Styles live in `markdown-preview/macchiato.css` and `markdown-preview/highlight.css`. The Markdown stylesheet is combined with the plugin's original CSS in Neovim's cache directory. After editing styles, restart Neovim and reload the browser page.

## Svelte support

- Tree-sitter highlights `.svelte` templates and embedded JavaScript, TypeScript, and CSS. `nvim-treesitter` installs the required parsers automatically and updates them when the plugin is updated with `vim.pack`.
- Mason installs `svelte-language-server`; `nvim-lspconfig` enables diagnostics, completion, hover, navigation, and rename in Svelte buffers.
- `vtsls` loads Mason's bundled `typescript-svelte-plugin` for navigation and diagnostics involving Svelte components from JavaScript/TypeScript files, including when using workspace TypeScript versions.
- Conform uses the Svelte LSP's Prettier-based formatter on save and with `<leader>cf`. Existing Biome formatting for other filetypes is unchanged. The LSP honors project Prettier configuration; no separate global Prettier installation is needed.

Parser installation requires `tree-sitter-cli` >= 0.26.1, a C compiler, `curl`, and `tar`. On macOS, install the CLI with `brew install tree-sitter-cli`. After the initial asynchronous installation finishes, reopen any Svelte buffer that was opened before its parser was available.

Check `:checkhealth nvim-treesitter`, `:checkhealth vim.lsp`, and `:ConformInfo` in a saved `.svelte` file. Run `:TSInstall svelte html css javascript typescript` to retry parser installation, or `:MasonInstall svelte-language-server` to retry LSP installation.

This follows the common [LazyVim Svelte integration](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/svelte.lua), using the modern [nvim-treesitter API](https://github.com/nvim-treesitter/nvim-treesitter/tree/main) and the [official Svelte language tools](https://github.com/sveltejs/language-tools). There is no formal Neovim-wide Svelte standard; this is a mainstream reference setup adapted to `vim.pack` and native Neovim completion.
