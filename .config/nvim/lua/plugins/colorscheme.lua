require("catppuccin").setup {
  flavour = "mocha",
  transparent_background = true,
  custom_highlights = function(colors)
    return {
      MiniStatuslineFilename = { fg = colors.text, bg = colors.none },
      MiniStatuslineInactive = { fg = colors.blue, bg = colors.none },
    }
  end,
}

vim.cmd.colorscheme "catppuccin"
