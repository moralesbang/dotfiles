local markdown = require("render-markdown")

-- Keep callout labels and destination-specific link rendering without their icons.
local callouts = vim.deepcopy(markdown.default.callout)
for _, callout in pairs(callouts) do
  callout.rendered = callout.rendered:gsub("^%S+%s+", "")
end

local link_icons = {}
for name in pairs(markdown.default.link.custom) do
  link_icons[name] = { icon = "" }
end

markdown.setup {
  enabled = false,
  heading = { icons = {} },
  code = { language_icon = false },
  sign = { enabled = false },
  bullet = { enabled = false },
  checkbox = { enabled = false },
  callout = callouts,
  link = {
    image = "",
    email = "",
    hyperlink = "",
    footnote = { icon = "" },
    wiki = { icon = "" },
    custom = link_icons,
  },
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(event)
    -- Neovim ships the Markdown parsers; enable their highlighting explicitly.
    vim.treesitter.start(event.buf)

    vim.keymap.set("n", "<leader>mr", markdown.buf_toggle, {
      buffer = event.buf,
      desc = "Toggle Markdown rendering",
    })
  end,
  desc = "Enable Markdown highlighting and rendering toggle",
})
