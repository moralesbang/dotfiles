-- Skipped modules and why:
--   basics     -> config/options.lua          comment  -> built-in gc
--   completion -> built-in LSP completion     snippets -> built-in vim.snippet
--   deps       -> vim.pack                    notify   -> vim._core.ui2
--   base16, colors, hues -> catppuccin        doc, fuzzy, test -> plugin dev tools

-- Appearance
require("mini.icons").setup()
MiniIcons.tweak_lsp_kind() -- icons in the completion menu

require("mini.statusline").setup()
vim.o.showmode = false -- statusline already shows the mode

require("mini.tabline").setup()
require("mini.statuscolumn").setup()
require("mini.starter").setup()
require("mini.cursorword").setup()
require("mini.indentscope").setup()
require("mini.trailspace").setup()
require("mini.animate").setup {
  cursor = { enable = false }, -- Ghostty cursor shader already animates it
}

local hipatterns = require("mini.hipatterns")
hipatterns.setup {
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
}

local map = require("mini.map")
map.setup {
  integrations = {
    map.gen_integration.builtin_search(),
    map.gen_integration.diagnostic(),
    map.gen_integration.diff(),
  },
}

-- Editing
local gen_ai_spec = require("mini.extra").gen_ai_spec
require("mini.ai").setup {
  custom_textobjects = {
    B = gen_ai_spec.buffer(),
    D = gen_ai_spec.diagnostic(),
    I = gen_ai_spec.indent(),
    L = gen_ai_spec.line(),
    N = gen_ai_spec.number(),
  },
}
require("mini.align").setup()
require("mini.move").setup()
require("mini.pairs").setup()
require("mini.splitjoin").setup()
require("mini.surround").setup()
require("mini.operators").setup {
  -- Defaults gr/gx would clobber the built-in LSP gr* maps and gx (open URL)
  replace = { prefix = "cr" },
  exchange = { prefix = "cx" },
}

local map_multistep = require("mini.keymap").map_multistep
map_multistep("i", "<Tab>", { "pmenu_next" })
map_multistep("i", "<S-Tab>", { "pmenu_prev" })
map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
map_multistep("i", "<BS>", { "minipairs_bs" })

-- Navigation
-- `nvim <dir>` shows the starter (cwd = <dir>) instead of an explorer; `-` still opens mini.files
vim.g.loaded_netrwPlugin = 1
require("mini.files").setup { options = { use_as_default_explorer = false } }
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if vim.fn.argc() ~= 1 or vim.fn.isdirectory(vim.fn.argv(0)) == 0 then return end
    local dir_buf = vim.api.nvim_get_current_buf()
    vim.fn.chdir(vim.fn.argv(0))
    MiniStarter.open()
    vim.api.nvim_buf_delete(dir_buf, { force = true })
  end,
})
require("mini.pick").setup()
require("mini.extra").setup()
require("mini.visits").setup()
require("mini.jump").setup()
require("mini.jump2d").setup()
require("mini.bracketed").setup {
  -- Built-in [b ]b [d ]d [l ]l [q ]q already cover these
  buffer = { suffix = "" },
  diagnostic = { suffix = "" },
  location = { suffix = "" },
  quickfix = { suffix = "" },
}

-- Workflow
require("mini.bufremove").setup()
require("mini.sessions").setup()
require("mini.cmdline").setup()
require("mini.input").setup()
require("mini.misc").setup()
MiniMisc.setup_restore_cursor()

local miniclue = require("mini.clue")
miniclue.setup {
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "i", keys = "<C-x>" },
    { mode = { "n", "x" }, keys = "g" },
    { mode = { "n", "x" }, keys = "'" },
    { mode = { "n", "x" }, keys = "`" },
    { mode = { "n", "x" }, keys = '"' },
    { mode = { "i", "c" }, keys = "<C-r>" },
    { mode = "n", keys = "<C-w>" },
    { mode = { "n", "x" }, keys = "z" },
  },
  clues = {
    { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
    { mode = "n", keys = "<Leader>c", desc = "+Code" },
    { mode = "n", keys = "<Leader>f", desc = "+Find" },
    { mode = "n", keys = "<Leader>g", desc = "+Git" },
    { mode = "n", keys = "<Leader>m", desc = "+Map" },
    { mode = "n", keys = "<Leader>z", desc = "+Zdiff" },
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
}

-- Keymaps
vim.keymap.set("n", "-", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "Open file explorer" })

vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function() MiniPick.builtin.grep_live() end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", function() MiniPick.builtin.buffers() end, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", function() MiniPick.builtin.help() end, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fr", function() MiniExtra.pickers.oldfiles() end, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fv", function() MiniExtra.pickers.visit_paths() end, { desc = "Visited paths" })
vim.keymap.set("n", "<leader>fd", function() MiniExtra.pickers.diagnostic() end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fk", function() MiniExtra.pickers.keymaps() end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>f.", function() MiniPick.builtin.resume() end, { desc = "Resume last picker" })

vim.keymap.set("n", "<leader>bd", function() MiniBufremove.delete() end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bz", function() MiniMisc.zoom() end, { desc = "Zoom window" })
vim.keymap.set("n", "<leader>cw", function() MiniTrailspace.trim() end, { desc = "Trim trailing whitespace" })

vim.keymap.set("n", "<leader>mm", function() MiniMap.toggle() end, { desc = "Toggle minimap" })
vim.keymap.set("n", "<leader>mf", function() MiniMap.toggle_focus() end, { desc = "Focus minimap" })
