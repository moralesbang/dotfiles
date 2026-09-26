require("vim._core.ui2").enable({})

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.tabstop = 2 -- how many spaces tab inserts
vim.o.softtabstop = 2 -- how many spaces tab inserts
vim.o.shiftwidth = 2 -- controls number of spaces when using >> or << commands
vim.o.expandtab = true -- use appropriate number of spaces with tab
vim.o.smartindent = true -- indenting correctly after {
vim.o.autoindent = true -- copy indent from current line when starting new line
vim.o.scrolloff = 8 -- always keep 8 lines above/below cursor unless at start/end of file
vim.o.clipboard = "unnamedplus" -- yank/paste through the system clipboard

vim.o.termguicolors = true -- enable 24-bit colors
vim.o.updatetime = 200 -- save swap file with 200ms debouncing
vim.o.swapfile = false -- disable swapfile
vim.o.backup = false -- disable backup on q
vim.o.autoread = true -- auto update file if changed outside of nvim
vim.o.undofile = true -- persistant undo history
vim.o.number = true -- enable line numbers
vim.o.relativenumber = true -- enable relative line numbers

