return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      -- VM draws extra cursors with VM_Insert in insert mode; use the same colour as normal/visual mode cursors
      local function set_vm_insert()
        vim.api.nvim_set_hl(0, "VM_Insert", { link = "VM_Cursor" })
      end
      vim.api.nvim_create_autocmd({ "ColorScheme", "User" }, {
        pattern = { "*", "visual_multi_start" },
        callback = set_vm_insert,
      })
      set_vm_insert()

      -- The real cursor (latest selection) is reverse-video by default, so it inverts the VM colours.
      -- VM already draws a coloured cursor on every selection, so hide the real one while VM is active.
      local saved_guicursor
      vim.api.nvim_create_autocmd("User", {
        pattern = "visual_multi_start",
        callback = function()
          vim.api.nvim_set_hl(0, "VM_HiddenCursor", { fg = "#ffffff", bg = "#000000", blend = 100 }) -- blend=100 hides the cursor; it needs a colour to take effect
          saved_guicursor = saved_guicursor or vim.o.guicursor
          vim.o.guicursor = saved_guicursor:gsub("n%-v%-c%-sm:block", "n-v-c-sm:block-VM_HiddenCursor")
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "visual_multi_exit",
        callback = function()
          if saved_guicursor then
            vim.o.guicursor = saved_guicursor
            saved_guicursor = nil
          end
        end,
      })
    end,
  },
}
