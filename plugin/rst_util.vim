if exists('g:loaded_rst_util')
  finish
endif
let g:loaded_rst_util = 1

" Add section line like riv.vim
nnoremap <Plug>(rst-section1) 0yyp0<C-v>$r=<ESC>
nnoremap <Plug>(rst-section2) 0yyp0<C-v>$r-<ESC>
nnoremap <Plug>(rst-section3) 0yyp0<C-v>$r~<ESC>
nnoremap <Plug>(rst-section4) 0yyp0<C-v>$r"<ESC>
nnoremap <Plug>(rst-section5) 0yyp0<C-v>$r'<ESC>
nnoremap <Plug>(rst-section6) 0yyp0<C-v>$r`<ESC>

" Insert bullet
inoremap <Plug>(rst-insert-samebullet) <C-o>:call rst_util#insertSameBullet()<CR>
inoremap <Plug>(rst-insert-childbullet) <C-o>:call rst_util#insertRotateBullet(1)<CR>
inoremap <Plug>(rst-insert-parentbullet) <C-o>:call rst_util#insertRotateBullet(-1)<CR>

" Insert line block
inoremap <Plug>(rst-insert-lineblock) <C-o>:call rst_util#insertLineBlock()<CR>

