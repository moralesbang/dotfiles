vim.pack.add {
  -- colorscheme
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  -- color the current line number by mode
  "https://github.com/mawkler/modicator.nvim",
  -- file and folder icons for plugins
  "https://github.com/nvim-mini/mini.icons",
  -- fuzzy file, text, and selection picker
  "https://github.com/nvim-mini/mini.pick",
  -- minimal statusline
  "https://github.com/nvim-mini/mini.statusline",
  -- the goat file manager
  { src = "https://github.com/stevearc/oil.nvim", name = "oil" },
  -- add gitstatus to the goat file manager
  "https://github.com/refractalize/oil-git-status.nvim",
  -- install and manage external developer tools
  "https://github.com/mason-org/mason.nvim",
  -- connect Mason packages to Neovim's LSP client
  "https://github.com/mason-org/mason-lspconfig.nvim",
  -- provide default configurations for language servers
  "https://github.com/neovim/nvim-lspconfig",
  -- format buffers with project-aware formatters
  "https://github.com/stevearc/conform.nvim",
  -- add JSON schemas to jsonls completions and validation
  "https://github.com/b0o/SchemaStore.nvim",
}

require("plugins.colorscheme")
require("plugins.modicator")
require("plugins.icons")
require("plugins.pick")
require("plugins.statusline")
require("plugins.oil")
require("plugins.lsp")
require("plugins.formatting")
