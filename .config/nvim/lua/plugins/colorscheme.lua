require("catppuccin").setup {
  flavour = "mocha",
  transparent_background = true,
  custom_highlights = function(colors)
    return {
      MiniStatuslineFilename = { fg = colors.text, bg = colors.none },
      MiniStatuslineInactive = { fg = colors.blue, bg = colors.none },
      -- modicator mode colors, matching the mini.statusline mode section
      NormalMode = { fg = colors.blue },
      InsertMode = { fg = colors.green },
      VisualMode = { fg = colors.mauve },
      SelectMode = { fg = colors.mauve },
      ReplaceMode = { fg = colors.red },
      CommandMode = { fg = colors.peach },
      TerminalMode = { fg = colors.teal },
      TerminalNormalMode = { fg = colors.blue },
    }
  end,
}

vim.cmd.colorscheme "catppuccin"
