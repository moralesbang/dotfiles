require("vim._core.ui2").enable({})

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.tabstop = 2 -- how many spaces tab inserts
vim.o.softtabstop = 2 -- how many spaces tab inserts
vim.o.shiftwidth = 2 -- controls number of spaces when using >> or << commands
vim.o.expandtab = true -- use appropriate number of spaces with tab
vim.o.smartindent = true -- indenting correctly after {
vim.o.number = true -- show absolute file line numbers
vim.o.relativenumber = true -- show relative line numbers around the cursor
vim.o.autoindent = true -- copy indent from current line when starting new line
vim.o.scrolloff = 8 -- always keep 8 lines above/below cursor unless at start/end of file
vim.o.laststatus = 3 -- single global statusline instead of one per window
vim.o.showmode = false -- mode is already shown in the statusline
