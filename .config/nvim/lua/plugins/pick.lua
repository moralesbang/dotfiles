local pick = require("mini.pick")

pick.setup()

local people_experience_path = "src/pages/dashboard/PeopleExperience"

local always_excluded_args = {
  "--glob",
  "!**/.git",
  "--glob",
  "!**/.git/**",
  "--glob",
  "!**/.claude/worktrees/**",
}

local default_search_args = {
  "--hidden",
  "--no-ignore-dot",
  "--no-ignore-exclude",
  "--no-ignore-global",
  "--no-require-git",
}
vim.list_extend(default_search_args, always_excluded_args)

local project_search_args = {
  "--hidden",
  "--no-ignore",
}
vim.list_extend(project_search_args, always_excluded_args)
vim.list_extend(project_search_args, {
  "--glob",
  "!**/node_modules/**",
  "--glob",
  "!**/build/**",
})

local grep_methods = {
  regex = { flag = "--no-fixed-strings", next = "plain" },
  plain = { flag = "--fixed-strings", next = "regex" },
}

local function git(command, cwd)
  local result = vim
    .system(vim.list_extend({ "git" }, command), {
      cwd = cwd,
      text = true,
    })
    :wait()

  if result.code ~= 0 then
    return nil
  end

  return vim.trim(result.stdout)
end

local function repository_context()
  local cwd = vim.fn.getcwd()
  local root = git({ "rev-parse", "--show-toplevel" }, cwd)

  if root == nil then
    return { cwd = cwd }
  end

  return {
    cwd = cwd,
    root = root,
    origin = git({ "remote", "get-url", "origin" }, root),
  }
end

local function is_people_experience_repository(origin)
  if origin == nil then
    return false
  end

  local normalized = origin:gsub("%.git$", "")
  return normalized:match("[/:]HumandDev/humand%-backoffice$") ~= nil
    or normalized:match("[/:]HumandDev/humand%-web$") ~= nil
end

local function default_scope()
  local context = repository_context()

  if not is_people_experience_repository(context.origin) then
    return {
      cwd = context.cwd,
      name = "working directory",
      search_args = default_search_args,
    }
  end

  return {
    cwd = vim.fs.joinpath(context.root, people_experience_path),
    name = "People Experience",
    search_args = default_search_args,
  }
end

local function project_scope()
  local context = repository_context()
  return {
    cwd = context.root or context.cwd,
    name = "project, including ignored",
    search_args = project_search_args,
  }
end

local function show_with_icons(buf_id, items, query)
  pick.default_show(buf_id, items, query, { show_icons = true })
end

local function find_files(scope)
  local command = { "rg", "--files", "--color=never" }
  vim.list_extend(command, scope.search_args)

  pick.builtin.cli({ command = command }, {
    source = {
      cwd = scope.cwd,
      name = "Files (" .. scope.name .. ")",
      show = show_with_icons,
    },
  })
end

local function grep_command(pattern, method, search_args)
  local command = {
    "rg",
    "--column",
    "--line-number",
    "--no-heading",
    "--field-match-separator",
    "\\x00",
    "--color=never",
    grep_methods[method].flag,
  }

  vim.list_extend(command, search_args)

  local case = vim.o.ignorecase and (vim.o.smartcase and "smart-case" or "ignore-case") or "case-sensitive"
  vim.list_extend(command, { "--" .. case, "--", pattern })

  return command
end

local function live_grep(scope)
  local method = "regex"
  local process

  local function picker_name()
    return string.format("Grep (%s, %s)", scope.name, method)
  end

  local function match(_, _, query)
    if process ~= nil then
      process:kill()
      process = nil
    end

    local querytick = pick.get_querytick()
    if #query == 0 then
      pick.set_picker_items({}, { do_match = false, querytick = querytick })
      return
    end

    process = pick.set_picker_items_from_cli(grep_command(table.concat(query), method, scope.search_args), {
      set_items_opts = { do_match = false, querytick = querytick },
      spawn_opts = { cwd = scope.cwd },
    })
  end

  local function refresh()
    pick.set_picker_opts({ source = { name = picker_name() } })
    pick.set_picker_query(pick.get_picker_query())
  end

  local function switch_method()
    method = grep_methods[method].next
    refresh()
  end

  pick.start({
    source = {
      cwd = scope.cwd,
      items = {},
      match = match,
      name = picker_name(),
      show = show_with_icons,
    },
    mappings = {
      switch_method = { char = "<C-e>", func = switch_method },
    },
  })
end

vim.keymap.set("n", "<leader>ff", function()
  find_files(default_scope())
end, { desc = "Find files in default scope" })

vim.keymap.set("n", "<leader>fg", function()
  live_grep(default_scope())
end, { desc = "Live grep in default scope" })

vim.keymap.set("n", "<leader>fF", function()
  find_files(project_scope())
end, { desc = "Find files across project, including ignored" })

vim.keymap.set("n", "<leader>fG", function()
  live_grep(project_scope())
end, { desc = "Live grep across project, including ignored" })

vim.keymap.set("n", "<leader>fb", pick.builtin.buffers, { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fr", pick.builtin.resume, { desc = "Resume previous picker" })
