vim.pack.add {
  -- colorscheme
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  -- the goat file manager
  { src = "https://github.com/stevearc/oil.nvim", name = "oil" },
  -- add gitstatus to the goat file manager
  "https://github.com/refractalize/oil-git-status.nvim",
  -- auto load into jsonls and yamlls completions from SchemaStore
  "https://github.com/b0o/SchemaStore.nvim",
}

require("plugins.colorscheme")
require("plugins.oil")
