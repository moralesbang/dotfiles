require("catppuccin").setup {
  flavour = "mocha",
  transparent_background = true,
  -- Explicit so the compiled cache picks it up (auto-detection doesn't bust it)
  integrations = {
    mini = { enabled = true },
  },
}

vim.cmd.colorscheme "catppuccin"
