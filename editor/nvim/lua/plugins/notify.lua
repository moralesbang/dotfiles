local notify = require("mini.notify")

notify.setup()

vim.notify = notify.make_notify({
  ERROR = { duration = 10000 },
})

vim.keymap.set("n", "<leader>n", notify.show_history, { desc = "Notification History" })
