return {
  "vim-test/vim-test",
  dependencies = {
    'preservim/vimux',
  },
  config = function()
    vim.g["test#strategy"] = "vimux"

    vim.keymap.set("n", "<leader>tn", ":TestNearest --coverage=false<CR>", {})
    vim.keymap.set("n", "<leader>tf", ":TestFile<CR>", {})
    vim.keymap.set("n", "<leader>ts", ":TestSuite<CR>", {})
    vim.keymap.set("n", "<leader>tl", ":TestLast<CR>", {})
    vim.keymap.set("n", "<leader>tv", ":TestVisit<CR>", {})
  end,
}
