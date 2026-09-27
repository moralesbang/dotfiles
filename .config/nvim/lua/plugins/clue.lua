local clue = require("mini.clue")

clue.setup {
  triggers = {
    -- leader
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    -- built-in prefixes
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "[" },
    { mode = "x", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "x", keys = "]" },
  },

  clues = {
    -- leader groups
    { mode = "n", keys = "<Leader>f", desc = "+find" },
    { mode = "x", keys = "<Leader>f", desc = "+find" },
    { mode = "n", keys = "<Leader>c", desc = "+code" },
    { mode = "x", keys = "<Leader>c", desc = "+code" },
    -- built-in descriptions
    clue.gen_clues.g(),
    clue.gen_clues.z(),
    clue.gen_clues.windows { submode_resize = true },
  },

  window = {
    delay = 300,
    config = { width = "auto" },
  },
}
