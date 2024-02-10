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
  end,
}
