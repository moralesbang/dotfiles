local icons = require("mini.icons")

-- Directory glyphs come from work-harness when it is installed.
local ok, harness = pcall(dofile, vim.fn.expand("~/Projects/work-harness/editor/mini-icons.lua"))

icons.setup {
  directory = ok and harness or {},
}
icons.mock_nvim_web_devicons()
