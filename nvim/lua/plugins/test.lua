return {
  "vim-test/vim-test",
  config = function()
    vim.g["test#strategy"] = "wezterm"

    vim.keymap.set("n", "<leader>tn", ":w | TestNearest --coverage=false<CR>", { desc = "[T]est [N]earest" })
    vim.keymap.set("n", "<leader>tf", ":w | TestFile<CR>", { desc = "[T]est [F]ile" })
    vim.keymap.set("n", "<leader>ts", ":w | TestSuite<CR>", { desc = "[T]est [S]uite" })
    vim.keymap.set("n", "<leader>tl", ":w | TestLast<CR>", { desc = "[T]est [L]ast" })
    vim.keymap.set("n", "<leader>tv", ":w | TestVisit<CR>", { desc = "[T]est [V]isit" })
  end,
}
