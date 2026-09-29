local function relative_to_cwd(path)
  local cwd = vim.fn.getcwd()
  local relative = vim.fs.relpath(cwd, path)
  if relative then
    return relative
  end

  local depth = 0
  for parent in vim.fs.parents(cwd) do
    depth = depth + 1
    relative = vim.fs.relpath(parent, path)
    if relative then
      return ("../"):rep(depth) .. (relative == "." and "" or relative)
    end
  end
end

local function copy_path(format)
  local oil = require("oil")
  local entry = oil.get_cursor_entry()
  local directory = oil.get_current_dir()
  if not directory then
    vim.notify("Path copying is only available for local directories", vim.log.levels.ERROR)
    return
  end

  local path = vim.fs.normalize(entry and vim.fs.joinpath(directory, entry.name) or directory)
  if format == "relative" then
    path = relative_to_cwd(path)
  else
    path = vim.fn.fnamemodify(path, ":~")
  end
  if not path then
    vim.notify("Could not make path relative to the working directory", vim.log.levels.ERROR)
    return
  end
  if (not entry or entry.type == "directory") and path:sub(-1) ~= "/" then
    path = path .. "/"
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
    ["<leader>yp"] = {
      callback = function()
        copy_path("relative")
      end,
      mode = "n",
      desc = "Copy cwd-relative path to system clipboard",
    },
    ["<leader>yh"] = {
      callback = function()
        copy_path("absolute")
      end,
      mode = "n",
      desc = "Copy path with ~ for home to system clipboard",
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
