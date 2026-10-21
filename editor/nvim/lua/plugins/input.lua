local input = require("mini.input")

input.setup({
  handlers = {
    -- Center general prompts while preserving each consumer's explicit scope.
    view = input.gen_view.floatwin({ style = "MM" }),
  },
})
