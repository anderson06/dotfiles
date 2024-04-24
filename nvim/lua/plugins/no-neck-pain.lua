return {
  "shortcuts/no-neck-pain.nvim",
  config = function()
    vim.keymap.set("n", "<leader>zn", "<cmd>NoNeckPain<cr>", { desc = "No Neck Pain" })
  end,
}
