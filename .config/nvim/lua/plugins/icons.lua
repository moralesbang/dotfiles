local icons = require("mini.icons")

icons.setup {
  directory = {
    [".sdd"] = { glyph = "󱪚", hl = "MiniIconsCyan" },
    [".secrets"] = { glyph = "󱕴", hl = "MiniIconsYellow" },
    [".worktrees"] = { glyph = "󰘬", hl = "MiniIconsOrange" },
    ["_workspace"] = { glyph = "󱌼", hl = "MiniIconsPurple" },
    ["scripts"] = { glyph = "󰞷", hl = "MiniIconsGreen" },
    ["standards"] = { glyph = "󱓳", hl = "MiniIconsBlue" },
  },
}
icons.mock_nvim_web_devicons()
