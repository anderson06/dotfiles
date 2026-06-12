-- Soft-wrap prose buffers (markdown, text, gitcommit) at word boundaries.
-- Global wrap is off (see core/options.lua) for code; this re-enables it for
-- long-form text, e.g. the `claude-prompt-*.md` buffer Claude Code opens via $EDITOR.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text', 'gitcommit' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true   -- break at word boundaries, not mid-word
    vim.opt_local.breakindent = true -- keep wrapped lines visually indented
  end,
})
