return {
  {
    "LazyVim/LazyVim",
    init = function()
      local function patch_root()
        local ok, root = pcall(require, "lazyvim.util.root")
        if not ok or type(root) ~= "table" or root._enoent_guard_installed then
          return
        end

        local function fallback_dir()
          local cwd = vim.uv.cwd()
          if type(cwd) == "string" and cwd ~= "" and vim.uv.fs_stat(cwd) then
            return cwd
          end

          local home = vim.env.HOME
          if type(home) == "string" and home ~= "" and vim.uv.fs_stat(home) then
            pcall(vim.api.nvim_set_current_dir, home)
            return home
          end

          return "."
        end

        local old_pattern = root.detectors.pattern
        root.detectors.pattern = function(buf, patterns)
          local path = root.bufpath(buf) or vim.uv.cwd()
          if type(path) ~= "string" or path == "" or not vim.uv.fs_stat(path) then
            return {}
          end
          local ok_pattern, result = pcall(old_pattern, buf, patterns)
          if ok_pattern and type(result) == "table" then
            return result
          end
          return {}
        end

        local old_get = root.get
        root.get = function(opts)
          local ok_get, result = pcall(old_get, opts)
          if ok_get and type(result) == "string" and result ~= "" then
            return result
          end
          return fallback_dir()
        end

        local old_cwd = root.cwd
        root.cwd = function()
          local ok_cwd, result = pcall(old_cwd)
          if ok_cwd and type(result) == "string" and result ~= "" then
            return result
          end
          return fallback_dir()
        end

        local old_git = root.git
        root.git = function()
          local ok_git, result = pcall(old_git)
          if ok_git and type(result) == "string" and result ~= "" then
            return result
          end
          return root.get({ normalize = true })
        end

        root._enoent_guard_installed = true
      end

      patch_root()

      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = patch_root,
      })
    end,
  },
}
