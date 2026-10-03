local bufremove = require("mini.bufremove")

bufremove.setup()

local function delete_buffers(predicate)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and predicate(buf) then
      bufremove.delete(buf)
    end
  end
end

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>bd", function()
  bufremove.delete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  delete_buffers(function(buf)
    return buf ~= current
  end)
end, { desc = "Delete Other Buffers" })
vim.keymap.set("n", "<leader>bi", function()
  delete_buffers(function(buf)
    return #vim.fn.win_findbuf(buf) == 0
  end)
end, { desc = "Delete Invisible Buffers" })
vim.keymap.set("n", "<leader>bD", "<cmd>bdelete<cr>", { desc = "Delete Buffer and Window" })
