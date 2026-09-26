local conform = require("conform")

-- biome-check = `biome check --write`: format, safe lint fixes, organize imports
local biome = { "biome-check" }

conform.setup {
  formatters_by_ft = {
    javascript = biome,
    javascriptreact = biome,
    typescript = biome,
    typescriptreact = biome,
    json = biome,
    jsonc = biome,
    css = biome,
    lua = { "stylua" },
  },
  formatters = {
    -- Only run in projects with a biome config, so non-biome repos stay untouched
    ["biome-check"] = { require_cwd = true },
  },
  format_on_save = { timeout_ms = 1000 },
  notify_no_formatters = false, -- non-biome repos would warn on every save
}

vim.keymap.set({ "n", "v" }, "<leader>cf", function() conform.format { async = true } end, { desc = "Format buffer" })
