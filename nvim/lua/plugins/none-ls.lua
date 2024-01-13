return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.formatting.prettier,
      },
    })

    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format {
        -- Never use tsserver for formatting
        -- This avoids conflicts with prettier
        filter = function(client) return client.name ~= "tsserver" end
      }
    end, {})
  end,
}
