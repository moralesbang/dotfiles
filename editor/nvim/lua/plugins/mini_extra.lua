require("mini.extra").setup()

vim.keymap.set("n", "<leader>fk", function()
  MiniExtra.pickers.keymaps()
end, { desc = "Find keymaps" })
