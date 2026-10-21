# Neovim config

Plugins use the built-in `vim.pack` (no lazy.nvim, no packer).

## Plugin layout

- `lua/plugins/init.lua` is the **registry**: one `vim.pack.add({...})` call listing every plugin, each entry preceded by a one-line `--` comment saying what it is for. Below the call, one `require("plugins.<name>")` per config file.
- `lua/plugins/<name>.lua` is the **config** for one plugin (or one concern, e.g. `lsp`, `formatting`, `git`): `setup`, keymaps, autocmds. Config files never call `vim.pack.add`.
- `init.lua` at the root only requires `config.options`, `config.keymaps`, `plugins`.

Adding a plugin means two edits: an entry in the registry and, if it needs setup, a new config file plus its `require` line. Removing one means reversing both.

Entries are a bare URL string when the repo name is the plugin name; use `{ src = ..., name = ... }` when the repo name would collide or mislead (e.g. `rose-pine/neovim` → `name = "rose-pine"`).
