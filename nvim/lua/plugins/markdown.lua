return {
  -- Off by default; toggle with <leader>um. Restore raw markup (conceallevel 0) when toggled off.
  -- When on, keep the cursor line rendered in normal mode (insert mode stays raw).
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      enabled = false,
      anti_conceal = { enabled = false },
      win_options = {
        conceallevel = { default = 0 },
        concealcursor = { rendered = "n" },
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install --omit=dev --no-package-lock && npm install msgpack-lite@0.1.26 --omit=dev --no-package-lock",
    init = function()
      vim.g.mkdp_echo_preview_url = 1

      -- The bundled linux binary crashes on this machine, so use the Node fallback.
      local bin = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim/app/bin/markdown-preview-linux"
      if vim.fn.has("Linux") == 1 and vim.fn.executable(bin) == 1 then
        vim.fn.setfperm(bin, "rw-r--r--")
      end
    end,
  },
}
