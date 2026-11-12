-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Markdown buffers: disable diagnostics (warnings/errors) and show raw markup (no conceal)
local function setup_markdown_buffer(buf)
  vim.diagnostic.enable(false, { bufnr = buf })
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win][0].conceallevel = 0
  end
end
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    setup_markdown_buffer(args.buf)
  end,
})
-- This file loads on VeryLazy, after the FileType event of a file opened from the command line
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.bo[buf].filetype == "markdown" then
    setup_markdown_buffer(buf)
  end
end
