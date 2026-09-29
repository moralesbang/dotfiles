local servers = {
  "vtsls",
  "biome",
  "html",
  "cssls",
  "jsonls",
  "lua_ls",
}

vim.lsp.config("vtsls", {
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
    },
  },
})

-- Add project-specific JSON schemas for package.json, tsconfig.json, and other
-- common configuration files.
vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

-- Let lua_ls understand this Neovim configuration without prompting to
-- configure the workspace.
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

require("mason-lspconfig").setup {
  ensure_installed = servers,
  automatic_enable = servers,
}

vim.diagnostic.config {
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded" },
}

-- Neovim supplies most LSP mappings by default. Add definition/declaration
-- jumps and opt in to its built-in completion UI for every attached server.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to definition" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = event.buf, desc = "Go to declaration" })
  end,
})
