local conform = require("conform")

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
  },
  formatters = {
    -- Avoid changing projects that do not opt in to Biome.
    ["biome-check"] = { require_cwd = true },
  },
  format_on_save = { timeout_ms = 1000 },
  notify_no_formatters = false,
}

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  conform.format { async = true }
end, { desc = "Format buffer" })
