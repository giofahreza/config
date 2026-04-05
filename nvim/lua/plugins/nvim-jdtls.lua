return {
  "mfussenegger/nvim-jdtls",
  opts = {
    jdtls = function(opts)
      local java_home = vim.env.JAVA_HOME
      local java_bin = java_home and (java_home .. "/bin/java") or vim.fn.exepath("java")
      if java_bin ~= nil and java_bin ~= "" then
        local runtime_path = java_home
        if runtime_path == nil or runtime_path == "" then
          runtime_path = vim.fn.fnamemodify(vim.fn.resolve(java_bin), ":h:h")
        end
        opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
          java = {
            configuration = {
              runtimes = {
                {
                  name = "JavaSE-21",
                  path = runtime_path,
                },
              },
            },
          },
        })
      end
      local ecc = require("jdtls").extendedClientCapabilities
      ecc.resolveAdditionalTextEditsSupport = true
      opts.init_options = opts.init_options or {}
      opts.init_options.extendedClientCapabilities = ecc
      return opts
    end,
  },
}
