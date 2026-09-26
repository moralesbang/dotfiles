-- Server overrides; everything else comes from nvim-lspconfig's lsp/*.lua defaults
vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
})

require("mason").setup()

-- Calls vim.lsp.enable() for every server mason has installed
require("mason-lspconfig").setup {
  automatic_enable = true,
}

-- Installs missing tools on startup; accepts lspconfig or mason names
require("mason-tool-installer").setup {
  ensure_installed = {
    "ts_ls",
    "biome",
    "jsonls",
    "lua_ls",
    "stylua",
  },
}

vim.diagnostic.config {
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded" },
}

vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.signcolumn = "yes" -- keep text from shifting when diagnostics appear

-- Built-in defaults already cover K, grn, gra, grr, gri, grt, gO, [d, ]d, <C-w>d
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
  end,
})
