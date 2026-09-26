vim.pack.add {
  "https://github.com/stevearc/oil.nvim",

  -- Appearance
  "https://github.com/catppuccin/nvim",

  -- LSP, completion and formatting
  "https://github.com/b0o/SchemaStore.nvim",

  -- Git
  "https://github.com/refractalize/oil-git-status.nvim",
  "https://github.com/martindur/zdiff.nvim",
}

require("plugins.colorscheme")
require("plugins.oil")
require("plugins.git")
