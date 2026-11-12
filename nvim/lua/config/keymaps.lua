local keymap = vim.keymap
local options = { noremap = true, silent = true }

keymap.set("n", "ss", ":split<CR>")
keymap.set("n", "sv", ":vsplit<CR>")

keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

keymap.set("n", "dw", 'vb"_d')

keymap.set("n", "<S-Up>", "<C-u>", { desc = "Scroll half-page up" })
keymap.set("n", "<S-Down>", "<C-d>", { desc = "Scroll half-page down" })
