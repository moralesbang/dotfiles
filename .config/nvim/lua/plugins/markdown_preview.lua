local plugin_file = vim.api.nvim_get_runtime_file("plugin/mkdp.vim", false)[1]
local plugin_dir = vim.fn.fnamemodify(plugin_file, ":h:h")
local styles_dir = vim.fn.stdpath("config") .. "/markdown-preview"
local cache_dir = vim.fn.stdpath("cache") .. "/markdown-preview"
local colors = require("catppuccin.palettes").get_palette("macchiato")
local foreground = "#f7f8fd"
local group = vim.api.nvim_create_augroup("MarkdownPreview", { clear = true })

local function prepare_styles()
  -- Custom Markdown CSS replaces the original; append overrides to keep its layout.
  local lines = vim.fn.readfile(plugin_dir .. "/app/_static/markdown.css")
  vim.list_extend(lines, vim.fn.readfile(styles_dir .. "/macchiato.css"))
  vim.fn.mkdir(cache_dir, "p")
  vim.fn.writefile(lines, cache_dir .. "/markdown.css")
end

vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 0
vim.g.mkdp_browser = ""
vim.g.mkdp_open_to_the_world = 0
vim.g.mkdp_combine_preview = 0
vim.g.mkdp_combine_preview_auto_refresh = 0
vim.g.mkdp_theme = "dark"
vim.g.mkdp_markdown_css = cache_dir .. "/markdown.css"
vim.g.mkdp_highlight_css = styles_dir .. "/highlight.css"
vim.g.mkdp_preview_options = {
  disable_sync_scroll = 1,
  disable_filename = 0,
  hide_yaml_meta = 1,
  content_editable = false,
  maid = {
    theme = "base",
    themeVariables = {
      darkMode = true,
      background = colors.base,
      fontFamily = '"MonaspiceXe Nerd Font", monospace',
      primaryColor = colors.surface0,
      primaryTextColor = foreground,
      primaryBorderColor = colors.mauve,
      secondaryColor = colors.surface1,
      secondaryTextColor = foreground,
      secondaryBorderColor = colors.teal,
      tertiaryColor = colors.mantle,
      tertiaryTextColor = foreground,
      tertiaryBorderColor = colors.blue,
      lineColor = colors.subtext0,
      textColor = foreground,
      mainBkg = colors.surface0,
      nodeBorder = colors.mauve,
      clusterBkg = colors.mantle,
      clusterBorder = colors.surface2,
      edgeLabelBackground = colors.base,
      titleColor = foreground,
    },
  },
}

local binary = plugin_dir .. "/app/bin/markdown-preview-" .. vim.fn["mkdp#util#get_platform"]()
local installing = false

local function ensure_binary(recheck)
  if installing then
    return
  end

  local executable = vim.fn.executable(binary) == 1
  if executable and not recheck then
    return
  end

  local package = vim.json.decode(table.concat(vim.fn.readfile(plugin_dir .. "/package.json"), "\n"))
  if executable then
    local result = vim.system({ binary, "--version" }, { text = true }):wait(3000)
    if result.code == 0 and vim.trim(result.stdout or "") == package.version then
      return
    end
  end

  installing = true
  vim.notify("Installing the official Markdown preview binary…")
  -- Run the upstream installer asynchronously without changing Neovim's cwd.
  local command = { "bash", "./install.sh", "v" .. package.version }
  vim.system(command, { cwd = plugin_dir .. "/app", text = true }, function(result)
    vim.schedule(function()
      installing = false
      -- The installer can report success without downloading a usable executable.
      if result.code ~= 0 or vim.fn.executable(binary) ~= 1 then
        vim.notify(
          "Markdown preview installation failed: " .. (result.stderr or "") .. "\nRetry with :MarkdownPreviewInstall",
          vim.log.levels.ERROR
        )
        return
      end
      local version = vim.system({ binary, "--version" }, { text = true }):wait(3000)
      if version.code ~= 0 or vim.trim(version.stdout or "") ~= package.version then
        vim.notify(
          "Markdown preview binary verification failed. Retry with :MarkdownPreviewInstall",
          vim.log.levels.ERROR
        )
        return
      end
      vim.notify("Markdown preview binary installed and verified.")
    end)
  end)
end

vim.api.nvim_create_user_command("MarkdownPreviewInstall", function()
  ensure_binary(true)
end, { desc = "Install or verify the official Markdown preview binary" })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "markdown",
  callback = function(event)
    vim.keymap.set("n", "<leader>mp", function()
      if installing then
        vim.notify("Markdown preview is still installing. Try again shortly.", vim.log.levels.WARN)
        return
      end
      -- The plugin installs buffer-local refresh hooks even when opened via :MarkdownPreview.
      local ok, refresh = pcall(vim.api.nvim_get_autocmds, {
        group = "MKDP_REFRESH_INIT" .. event.buf,
        buffer = event.buf,
      })
      local server_running = vim.fn["mkdp#rpc#get_server_status"]() == 1
      if server_running and ok and #refresh > 0 then
        -- Unlike :MarkdownPreviewStop, this only closes the current buffer's pages.
        vim.fn["mkdp#rpc#preview_close"]()
      else
        if vim.fn.executable(binary) ~= 1 then
          vim.notify("Markdown preview binary is missing. Run :MarkdownPreviewInstall", vim.log.levels.ERROR)
          return
        end
        vim.cmd.MarkdownPreview()
      end
    end, { buffer = event.buf, desc = "Toggle current Markdown preview" })
  end,
  desc = "Add the browser preview toggle to Markdown buffers",
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = group,
  callback = function(event)
    if event.data.spec.name == "markdown-preview.nvim" and event.data.kind == "update" then
      prepare_styles()
      ensure_binary(true)
    end
  end,
  desc = "Refresh Markdown preview styles and binary after plugin updates",
})

prepare_styles()
-- The config loads after vim.pack.add, so this also handles the initial installation.
ensure_binary(false)
