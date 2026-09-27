local statusline = require("mini.statusline")

-- show mode names in uppercase (NORMAL, INSERT, ...) while keeping the default layout
local section_mode = statusline.section_mode
statusline.section_mode = function(args)
  local mode, mode_hl = section_mode(args)
  return mode:upper(), mode_hl
end

statusline.setup()
