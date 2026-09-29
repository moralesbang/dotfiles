require("vim._core.ui2").enable({})

vim.g.maplocalleader = " "

vim.o.tabstop = 2 -- how many spaces tab inserts
vim.o.softtabstop = 2 -- how many spaces tab inserts
vim.o.shiftwidth = 2 -- controls number of spaces when using >> or << commands
vim.o.expandtab = true -- use appropriate number of spaces with tab
vim.o.relativenumber = true -- show relative line numbers around the cursor
vim.o.cursorlineopt = "number" -- only highlight the line number, not the line background
vim.o.autoindent = true -- copy indent from current line when starting new line
vim.o.scrolloff = 8 -- always keep 8 lines above/below cursor unless at start/end of file
vim.o.laststatus = 3 -- single global statusline instead of one per window
vim.o.clipboard = "unnamedplus" -- use the system clipboard by default
vim.o.completeopt = "menuone,noselect,popup,fuzzy" -- keep built-in completion behavior
