local sessions = require("mini.sessions")

vim.opt.sessionoptions = {
  "buffers",
  "curdir",
  "folds",
  "tabpages",
  "winsize",
}

sessions.setup({
  autoread = false,
  autowrite = true,
  file = "",
  force = {
    read = false,
    write = true,
    delete = false,
  },
  hooks = {
    pre = { read = nil, write = nil, delete = nil },
    post = { read = nil, write = nil, delete = nil },
  },
  verbose = {
    read = false,
    write = true,
    delete = true,
  },
})

local function with_extension(name)
  return name:match("%.vim$") and name or name .. ".vim"
end

local function complete_sessions()
  local names = vim.tbl_keys(sessions.detected)
  table.sort(names)
  return names
end

vim.api.nvim_create_user_command("SessionWrite", function(args)
  sessions.write(with_extension(args.args))
end, {
  nargs = 1,
  complete = complete_sessions,
  desc = "Write a named global session",
})

vim.api.nvim_create_user_command("SessionRead", function(args)
  if args.args == "" then
    sessions.select("read")
    return
  end

  sessions.read(with_extension(args.args))
end, {
  nargs = "?",
  complete = complete_sessions,
  desc = "Read a global session",
})

vim.api.nvim_create_user_command("SessionDelete", function(args)
  if args.args == "" then
    sessions.select("delete")
    return
  end

  sessions.delete(with_extension(args.args))
end, {
  nargs = "?",
  complete = complete_sessions,
  desc = "Delete a global session",
})
