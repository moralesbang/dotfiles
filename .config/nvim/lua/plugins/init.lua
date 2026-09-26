vim.pack.add {
  "https://github.com/nvim-mini/mini.nvim",

  -- Appearance
  "https://github.com/catppuccin/nvim",

  -- LSP, completion and formatting
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/b0o/SchemaStore.nvim",

  -- Git
  "https://github.com/martindur/zdiff.nvim",
}

require("plugins.colorscheme")
require("plugins.mini")
require("plugins.lsp")
require("plugins.formatting")
require("plugins.git")
