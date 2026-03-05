return {
  "mfussenegger/nvim-jdtls",
  opts = {
    jdtls = function(opts)
      local java_home = "/home/akido/.sdkman/candidates/java/21.0.8-amzn"
      local lombok_path = "/home/akido/.local/share/jdtls/lombok.jar"
      opts.cmd = {
        java_home .. "/bin/java",
        "-javaagent:" .. lombok_path, -- :white_check_mark: Lombok agent
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        "/home/akido/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250519-0528.jar",
        "-configuration",
        "/home/akido/.local/share/jdtls/config_linux",
        "-data",
        vim.fn.stdpath("cache") .. "/jdtls-workspace",
      }
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-21",
                path = java_home,
              },
            },
          },
        },
      })
      -- Keep your other config (inlay hints, extendedClientCapabilities, etc.)
      local ecc = require("jdtls").extendedClientCapabilities
      ecc.resolveAdditionalTextEditsSupport = true
      opts.init_options = opts.init_options or {}
      opts.init_options.extendedClientCapabilities = ecc
      return opts
    end,
  },
}
