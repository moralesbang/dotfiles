vim.pack.add({
  -- Basics
  "https://github.com/nvim-mini/mini.basics",

  -- Appearance
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/mawkler/modicator.nvim",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/nvim-mini/mini.statusline",
  "https://github.com/nvim-mini/mini.starter",
  "https://github.com/nvim-mini/mini.notify",

  -- Navigation
  "https://github.com/nvim-mini/mini.pick",
  "https://github.com/nvim-mini/mini.extra",
  { src = "https://github.com/stevearc/oil.nvim", name = "oil" },
  "https://github.com/refractalize/oil-git-status.nvim",

  -- Editing
  "https://github.com/nvim-mini/mini.clue",
  "https://github.com/nvim-mini/mini.ai",
  "https://github.com/nvim-mini/mini.surround",
  "https://github.com/nvim-mini/mini.indentscope",

  -- Buffers And Sessions
  "https://github.com/nvim-mini/mini.bufremove",
  "https://github.com/nvim-mini/mini.sessions",

  -- Language Tools
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/b0o/SchemaStore.nvim",
})

-- Basics
require("plugins.basics")

-- Appearance
require("plugins.colorscheme")
require("plugins.modicator")
require("plugins.icons")
require("plugins.render_markdown")
require("plugins.statusline")
require("plugins.starter")
require("plugins.notify")

-- Navigation
require("plugins.pick")
require("plugins.mini_extra")
require("plugins.oil")

-- Editing
require("plugins.clue")
require("plugins.ai")
require("plugins.surround")
require("plugins.indentscope")

-- Buffers And Sessions
require("plugins.buffers")
require("plugins.sessions")

-- Language Tools
require("plugins.lsp")
require("plugins.formatting")
