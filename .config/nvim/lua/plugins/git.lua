require("mini.git").setup() -- :Git command, branch info for the statusline
require("mini.diff").setup() -- hunk signs, gh/gH apply/reset, [h ]h navigation

require("zdiff").setup()

vim.keymap.set("n", "<leader>go", function() MiniDiff.toggle_overlay() end, { desc = "Toggle diff overlay" })
vim.keymap.set({ "n", "x" }, "<leader>gs", function() MiniGit.show_at_cursor() end, { desc = "Show git info at cursor" })

vim.keymap.set("n", "<leader>zd", function() require("zdiff").open() end, { desc = "Zdiff (uncommitted)" })
vim.keymap.set("n", "<leader>zD", function() require("zdiff").open("main") end, { desc = "Zdiff (vs main)" })
