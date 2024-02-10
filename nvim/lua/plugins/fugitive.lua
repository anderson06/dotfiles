return {
  "tpope/vim-fugitive",
  config = function()
    local function toggleGitStatus()
      if vim.fn.buflisted(vim.fn.bufname("fugitive:///*/.git//$")) ~= 0 then
        vim.cmd([[ execute ":bdelete" bufname('fugitive:///*/.git//$') ]])
      else
        vim.cmd.Git()
      end
    end

    vim.keymap.set("n", "<leader>gs", toggleGitStatus, {})

    -- Git
    vim.api.nvim_set_keymap("n", "<leader>gc", ":Git commit -n -m \"", { noremap = false })
    vim.api.nvim_set_keymap("n", "<leader>gp", ":Git push -u origin HEAD<CR>", { noremap = false })
  end,
}
