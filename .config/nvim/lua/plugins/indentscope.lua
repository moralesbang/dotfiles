require("mini.indentscope").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "minipick", "oil", "qf" },
  callback = function(event)
    vim.b[event.buf].miniindentscope_disable = true
  end,
  desc = "Disable indentation scopes in special buffers",
})

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(event)
    vim.b[event.buf].miniindentscope_disable = true
  end,
  desc = "Disable indentation scopes in terminal buffers",
})
