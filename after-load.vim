" --------------------------------------
" devfonts
" --------------------------------------

" remap stage/unstage hunks so it does not conflict with buffer navigation
unmap <Leader>hs
unmap <Leader>hr
unmap <Leader>hu
unmap <Leader>hp

nmap <Leader>gs <Plug>GitGutterStageHunk
nmap <Leader>gu <Plug>GitGutterUndoHunk
nmap <Leader>gp <Plug>GitGutterPreviewHunk
