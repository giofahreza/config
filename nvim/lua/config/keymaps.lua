local keymap = vim.keymap
local options = { noremap = true, silent = true }

keymap.set("n", "ss", ":split<CR>")
keymap.set("n", "sv", ":vsplit<CR>")

keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

keymap.set("n", "dw", 'vb"_d')

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w>5<")
keymap.set("n", "<C-w><right>", "<C-w>5>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Java specific keymaps
-- Using leader key for Java operations
keymap.set("n", "<leader>jo", "<Cmd>lua require('jdtls').organize_imports()<CR>", { desc = "Organize Imports" })
keymap.set("n", "<leader>jv", "<Cmd>lua require('jdtls').extract_variable()<CR>", { desc = "Extract Variable" })
keymap.set("n", "<leader>jc", "<Cmd>lua require('jdtls').extract_constant()<CR>", { desc = "Extract Constant" })
keymap.set("n", "<leader>jm", "<Cmd>lua require('jdtls').extract_method()<CR>", { desc = "Extract Method" })
keymap.set("n", "<leader>jt", "<Cmd>lua require('jdtls').test_class()<CR>", { desc = "Run All Tests" })
keymap.set("n", "<leader>jT", "<Cmd>lua require('jdtls').test_nearest_method()<CR>", { desc = "Run Nearest Test" })

-- Navigation
keymap.set("n", "gs", "<Cmd>lua require('jdtls').super_implementation()<CR>", { desc = "Go to Super Implementation" })
keymap.set("n", "gS", "<Cmd>lua require('jdtls').goto_references()<CR>", { desc = "Show All References" })

-- Refactoring
keymap.set("n", "<leader>jr", "<Cmd>lua require('jdtls').rename_file()<CR>", { desc = "Rename File" })
keymap.set("n", "<leader>jn", "<Cmd>lua require('jdtls').navigate_to_method()<CR>", { desc = "Navigate to Method" })

-- Code generation
keymap.set(
  "n",
  "<leader>jgc",
  "<Cmd>lua require('jdtls').generate_constructor()<CR>",
  { desc = "Generate Constructor" }
)
keymap.set("n", "<leader>jgs", "<Cmd>lua require('jdtls').generate_to_string()<CR>", { desc = "Generate toString()" })
keymap.set(
  "n",
  "<leader>jgg",
  "<Cmd>lua require('jdtls').generate_getters_and_setters()<CR>",
  { desc = "Generate Getters and Setters" }
)

-- Project view
keymap.set("n", "<leader>jp", "<Cmd>lua require('jdtls').projects()<CR>", { desc = "List Projects" })
keymap.set("n", "<leader>je", "<Cmd>lua require('jdtls').explorer()<CR>", { desc = "Open Java Explorer" })
