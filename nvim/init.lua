vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- File tree mappings
vim.keymap.set('n', '<leader>n', ':Neotree filesystem reveal toggle left<CR>', {})
vim.keymap.set('n', '<leader>bf', ':Neotree buffers reveal toggle float<CR>', {})

require("core.options")
require("core.keymaps")
require("core.highlight-on-yank")
