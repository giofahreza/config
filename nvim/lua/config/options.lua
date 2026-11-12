vim.g.mapleader = " "

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true

vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.report = 0
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.inccommand = "split"
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false -- No Wrap lines
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" }) -- Finding files - Search down into subfolders
vim.opt.wildignore:append({ "*/node_modules/*" })
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.splitkeep = "cursor"
vim.opt.mouse = "a"
vim.opt.swapfile = false
vim.opt.clipboard = "unnamedplus"

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })

vim.cmd([[au BufNewFile,BufRead *.astro setf astro]])
vim.cmd([[au BufNewFile,BufRead Podfile setf ruby]])

-- local in_wsl = os.getenv("WSL_DISTRO_NAME") ~= nil
--
-- if in_wsl then
--   vim.g.clipboard = {
--     name = "wsl clipboard",
--     copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
--     paste = { ["+"] = { "powershell.exe", "-c", "Get-Clipboard" }, ["*"] = { "powershell.exe", "-c", "Get-Clipboard" } },
--     cache_enabled = true,
--   }
-- end

local in_wsl = os.getenv("WSL_DISTRO_NAME") ~= nil
local in_ssh = os.getenv("SSH_CONNECTION") ~= nil or os.getenv("SSH_CLIENT") ~= nil or os.getenv("SSH_TTY") ~= nil
local in_wayland = os.getenv("WAYLAND_DISPLAY") ~= nil
local has_wl_copy = vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1

if in_wayland and has_wl_copy and not in_ssh then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = { "wl-copy", "--foreground", "--type", "text/plain" },
      ["*"] = { "wl-copy", "--foreground", "--primary", "--type", "text/plain" },
    },
    paste = {
      ["+"] = { "wl-paste", "--no-newline" },
      ["*"] = { "wl-paste", "--no-newline", "--primary" },
    },
    cache_enabled = true,
  }
elseif in_wsl and not in_ssh and has_wl_copy then
  -- Only use wl-copy/wl-paste when in local WSL (not SSH)
  vim.g.clipboard = {
    name = "wsl clipboard",
    copy = {
      ["+"] = { "wl-copy" },
      ["*"] = { "wl-copy" },
    },
    paste = {
      ["+"] = { "wl-paste", "--no-newline" },
      ["*"] = { "wl-paste", "--no-newline" },
    },
    cache_enabled = true,
  }
elseif in_ssh then
  -- Use OSC 52 over SSH when the local terminal supports it.
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.opt.clipboard = "unnamedplus"
  end,
})
