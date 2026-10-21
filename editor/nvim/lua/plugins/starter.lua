local starter = require("mini.starter")
local picker = require("plugins.pick")

local header =
  [[███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓
 ██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒
▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░
▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██
▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒
░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░
░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░
   ░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░
         ░    ░  ░    ░ ░        ░   ░         ░
                                ░]]

local function session_items()
  local detected = {}

  for _, session in pairs(MiniSessions.detected) do
    table.insert(detected, session)
  end

  table.sort(detected, function(a, b)
    return a.modify_time > b.modify_time
  end)

  local items = {}
  for _, session in ipairs(vim.list_slice(detected, 1, 3)) do
    local session_name = session.name
    table.insert(items, {
      name = session_name:gsub("%.vim$", ""),
      action = function()
        MiniSessions.read(session_name)
      end,
      section = "Sessions",
    })
  end

  return items
end

local recent_files = starter.sections.recent_files(3, true, true)
local function recent_file_items()
  local items = recent_files()

  if #items == 1 and items[1].action == "" then
    return {}
  end

  for _, item in ipairs(items) do
    item.section = "Recent files"
  end

  return items
end

starter.setup({
  autoopen = true,
  evaluate_single = false,
  items = {
    session_items,
    recent_file_items,
    {
      name = "Find files",
      action = picker.find_files,
      section = "Actions",
    },
    {
      name = "Live grep",
      action = picker.live_grep,
      section = "Actions",
    },
    {
      name = "Browse files",
      action = function()
        require("oil").open(vim.fn.getcwd())
      end,
      section = "Actions",
    },
  },
  header = header,
  footer = "Type to filter  •  ↑/↓ navigate  •  <CR> open  •  <C-c> close",
  content_hooks = {
    starter.gen_hook.adding_bullet("› ", true),
    starter.gen_hook.aligning("center", "center"),
  },
  query_updaters = "abcdefghijklmnopqrstuvwxyz0123456789_-.",
  silent = false,
})

vim.api.nvim_create_user_command("Starter", function()
  starter.open()
end, {
  desc = "Open MiniStarter",
})
