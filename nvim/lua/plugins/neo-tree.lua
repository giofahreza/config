return {
  -- Show dotfiles and hidden files in the explorer (LazyVim's neo-tree extra hides them)
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_hidden = false,
        },
      },
    },
  },
}
