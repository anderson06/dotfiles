return {
  {
    "folke/zen-mode.nvim",
    config = function()
      vim.api.nvim_set_keymap("n", "<leader>zm", ":ZenMode<CR>", { noremap = false })
    end,
  },
}
