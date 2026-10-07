vim.pack.add({
  -- Basics
  -- Configure common editor options and mappings.
  "https://github.com/nvim-mini/mini.basics",

  -- Appearance
  -- Apply the editor colorscheme.
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  -- Color line numbers according to the current mode.
  "https://github.com/mawkler/modicator.nvim",
  -- Provide filetype and UI icons.
  "https://github.com/nvim-mini/mini.icons",
  -- Render Markdown inside the editor.
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  -- Preview Markdown in the browser with custom colors and fonts.
  "https://github.com/iamcco/markdown-preview.nvim",
  -- Display the editor statusline.
  "https://github.com/nvim-mini/mini.statusline",
  -- Show the start screen.
  "https://github.com/nvim-mini/mini.starter",

  -- Input And Notifications
  -- Show user input with scope-aware floating prompts.
  "https://github.com/nvim-mini/mini.input",
  -- Display notifications and their history.
  "https://github.com/nvim-mini/mini.notify",

  -- Navigation
  -- Provide fuzzy pickers and selection menus.
  "https://github.com/nvim-mini/mini.pick",
  -- Provide additional pickers and textobject generators.
  "https://github.com/nvim-mini/mini.extra",
  -- Browse and edit directories as buffers.
  { src = "https://github.com/stevearc/oil.nvim", name = "oil" },
  -- Show Git status in the directory browser.
  "https://github.com/refractalize/oil-git-status.nvim",

  -- Editing
  -- Show clues for available key combinations.
  "https://github.com/nvim-mini/mini.clue",
  -- Extend around and inside textobjects.
  "https://github.com/nvim-mini/mini.ai",
  -- Add, delete, and replace surroundings.
  "https://github.com/nvim-mini/mini.surround",
  -- Highlight the current indentation scope.
  "https://github.com/nvim-mini/mini.indentscope",

  -- Buffers And Sessions
  -- Delete buffers while preserving the window layout.
  "https://github.com/nvim-mini/mini.bufremove",
  -- Save and restore editor sessions.
  "https://github.com/nvim-mini/mini.sessions",

  -- Language Tools
  -- Install Svelte and embedded-language parsers for Tree-sitter highlighting.
  "https://github.com/nvim-treesitter/nvim-treesitter",
  -- Install language servers and development tools.
  "https://github.com/mason-org/mason.nvim",
  -- Bridge Mason installations and native LSP configuration.
  "https://github.com/mason-org/mason-lspconfig.nvim",
  -- Provide language server configurations.
  "https://github.com/neovim/nvim-lspconfig",
  -- Format buffers with external tools and LSP fallback.
  "https://github.com/stevearc/conform.nvim",
  -- Provide JSON schemas for language servers.
  "https://github.com/b0o/SchemaStore.nvim",
})

-- Basics
require("plugins.basics")

-- Appearance
require("plugins.colorscheme")
require("plugins.modicator")
require("plugins.icons")
require("plugins.render_markdown")
require("plugins.markdown_preview")
require("plugins.statusline")
require("plugins.starter")

-- Input And Notifications
require("plugins.input")
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
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.formatting")
