local ai = require("mini.ai")
local extra = require("mini.extra")

ai.setup({
  custom_textobjects = {
    B = extra.gen_ai_spec.buffer(),
    D = extra.gen_ai_spec.diagnostic(),
  },
})
