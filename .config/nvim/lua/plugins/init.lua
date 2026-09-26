-- Build steps for plugins that need compilation. Must be registered before
-- vim.pack.add so it fires on first install.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
      vim.system({ "make" }, { cwd = ev.data.path }):wait()
    end
  end,
})

vim.pack.add {
  "https://github.com/stevearc/oil.nvim",

  -- Appearance
  "https://github.com/catppuccin/nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",

  -- Fuzzy finding
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",

  -- LSP, completion and formatting
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/b0o/SchemaStore.nvim",

  -- Git
  "https://github.com/refractalize/oil-git-status.nvim",
  "https://github.com/martindur/zdiff.nvim",
}

require("plugins.colorscheme")
require("plugins.lualine")
require("plugins.oil")
require("plugins.telescope")
require("plugins.lsp")
require("plugins.formatting")
require("plugins.git")
