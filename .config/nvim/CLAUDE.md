# Neovim config

Plugins use the built-in `vim.pack` (no lazy.nvim, no packer).

## Plugin layout

- `lua/plugins/init.lua` is the **registry**: one `vim.pack.add({...})` call listing every plugin. Entries are grouped under a `-- Section` comment (`-- Appearance`, `-- LSP, completion and formatting`, `-- Git`, ...) with a blank line between groups; a plugin that fits no group sits at the top before the first section. Below the call, one `require("plugins.<name>")` per config file.
- `lua/plugins/<name>.lua` is the **config** for one plugin or one concern (e.g. `mini`, `git`, `colorscheme`): `setup`, keymaps, autocmds. Config files never call `vim.pack.add`.
- `init.lua` at the root only requires `config.options`, `config.keymaps`, `plugins`.

Adding a plugin means two edits: an entry under the right section in the registry and, if it needs setup, a new config file plus its `require` line. Removing one means reversing both.

Entries are bare URL strings. Use `{ src = ..., name = ... }` only when two repos share the same last path segment (e.g. two `.../nvim` repos).
