local treesitter = require("nvim-treesitter")
local parsers = { "svelte", "html", "css", "javascript", "typescript" }
local group = vim.api.nvim_create_augroup("SvelteTreesitter", { clear = true })

-- Embedded scripts and styles need their own parsers and queries.
treesitter.install(parsers)

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "svelte",
  callback = function(event)
    local ok, err = pcall(vim.treesitter.start, event.buf)
    if not ok then
      vim.notify("Svelte highlighting unavailable: " .. tostring(err), vim.log.levels.WARN)
    end
  end,
  desc = "Enable Svelte and embedded-language highlighting",
})

-- Parser revisions must stay in sync with the installed plugin version.
vim.api.nvim_create_autocmd("PackChanged", {
  group = group,
  callback = function(event)
    if event.data.spec.name == "nvim-treesitter" and event.data.kind == "update" then
      treesitter.update(parsers)
    end
  end,
  desc = "Update Svelte parsers after updating nvim-treesitter",
})
