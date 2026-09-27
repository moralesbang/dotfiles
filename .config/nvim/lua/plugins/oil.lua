local function copy_entry_path(format)
  local oil = require("oil")
  local entry = oil.get_cursor_entry()
  local directory = oil.get_current_dir()
  if not entry or not directory then
    vim.notify("Path copying is only available for local files", vim.log.levels.ERROR)
    return
  end

  local path = vim.fs.normalize(directory .. entry.name)
  if format == "relative" then
    path = vim.fn.fnamemodify(path, ":.")
  else
    path = vim.fn.fnamemodify(path, ":~")
  end

  local copied, error_message = pcall(vim.fn.setreg, "+", path)
  if not copied then
    vim.notify("Could not copy path to the system clipboard: " .. error_message, vim.log.levels.ERROR)
    return
  end

  vim.notify((format == "relative" and "Relative" or "Absolute") .. " path copied: " .. path)
end

require("oil").setup {
  default_file_explorer = true,
  keymaps = {
    ["gyr"] = {
      callback = function()
        copy_entry_path("relative")
      end,
      desc = "Copy relative path to system clipboard",
    },
    ["gya"] = {
      callback = function()
        copy_entry_path("absolute")
      end,
      desc = "Copy absolute path to system clipboard",
    },
  },
  view_options = {
    show_hidden = true,
  },
  win_options = {
    signcolumn = "yes:2",
  },
}

require("oil-git-status").setup()

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
