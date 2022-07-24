scriptencoding utf-8

" Insert bullet {{{
"TODO: 行の途中なら、それ以降の文字列を次の行に移動

let s:bullets = '*+-'
let s:regexBullets = '[' .. s:bullets .. ']'
let s:regexNumberBullets = '\%([0-9]\+\|[a-zA-Z#]\)\.'
" List: *, +, -, |, [0-9]., [a-z]., [A-Z]., #.
let s:isList = {t -> t =~# '^\s*\%(' .. s:regexNumberBullets .. '\|' .. s:regexBullets .. '\||\)\s'}
let s:hasBullet = {t -> t =~# '^\s*' .. s:regexBullets .. '\s'}

function! s:getNumberedBullet(t) abort
  let idxFirstNum = match(a:t, '[1-9]')
  let listpostfixlen = 2
  return strpart(a:t, idxFirstNum, matchend(a:t, '\.\s') - idxFirstNum - listpostfixlen)
endfunction

function! s:getListHead(t) abort
  " s:bullets, #. , | なら同じもの
  if s:hasBullet(a:t)
    return strpart(a:t, 0, matchend(a:t, '^\s*' .. s:regexBullets .. '\s'))
  endif
  if a:t =~# '^\s*\%(#\.\||\)\s'
    return strpart(a:t, 0, matchend(a:t, '^\s*\%(#\.\||\)\s'))
  endif

  " 数字なら次の数
  if a:t =~# '^\s*[0-9]\+\.\s'
    let head = strpart(a:t, 0, matchend(a:t, '^\s*[0-9]\+\.\s'))
    let bullet = s:getNumberedBullet(a:t)
    let newBullet = bullet + 1
    return substitute(head, bullet, newBullet, '')
  endif

  " a-zA-Z なら次のアルファベット
  let head = strpart(a:t, 0, matchend(a:t, '^\s*[a-zA-Z]\.\s'))
  let bullet = strpart(head, match(head, '[a-zA-Z]'), 1)
  let newBullet = nr2char(char2nr(bullet) + 1)
  return substitute(head, bullet, newBullet, '')
endfunction

function! s:getRotateNewBullet(n, bullet, bullets) abort
  let l:i = stridx(a:bullets, a:bullet)
  if l:i + a:n > len(a:bullets) - 1
    let l:j = (l:i + a:n) % len(a:bullets)
  elseif l:i + a:n < 0
    let l:j = l:i + a:n + len(a:bullets)
  else
    let l:j = l:i + a:n
  endif
  return strpart(a:bullets, l:j, 1)
endfunction

function! s:rotateBullet(t, n) abort
  if a:t =~# '^\s*[0-9]\+\.\s'
    let newBullet = s:getRotateNewBullet(a:n, '#', '#aA')
    return substitute(a:t, s:getNumberedBullet(a:t), newBullet, '')
  endif

  if s:hasBullet(a:t)
    let bullet = strpart(a:t, match(a:t, s:regexBullets), 1)
    let newBullet = s:getRotateNewBullet(a:n, bullet, s:bullets)
    return substitute(a:t, bullet, newBullet, '')
  endif

  let bullet = strpart(a:t, match(a:t, '[#a-zA-Z]'), 1)
  if bullet =~# '[a-z]'
    let baseBullet = 'a'
  elseif bullet =~# '[A-Z]'
    let baseBullet = 'A'
  else
    let baseBullet = bullet
  endif
  let newBullet = s:getRotateNewBullet(a:n, baseBullet, '#aA')
  return substitute(a:t, bullet, newBullet, '')
endfunction

function! s:insertstr(str, addstr, pos) abort
  call setline('.', strpart(a:str, 0, a:pos) .. a:addstr .. strpart(a:str, a:pos))
  call cursor(0, col('$'))
endfunction

" _ is cursor position
"
" hoge_ -> * hoge_
"
" * hoge_ -> * hoge
"            * _
"
" 1. hoge_ -> 1. hoge
"             2. _
"
" * | hoge  -> * | hoge
"   | fuga_      | fuga
"              * _
"
" #. | hoge   -> #. | hoge
"    | fuga_        | fuga
"                #. _
function! rst_util#insertSameBullet() abort
  let l:line = getline('.')

  " 先頭が | の行か
  if l:line =~# '^\s*|\s'
    " 直上の行が空白だったらなにもしない
    let l:bulletlnum = s:getNonBlankLineFirst()
    if l:bulletlnum == 0
      return
    endif

    let l:bulletline = getline(l:bulletlnum)
  else
    let l:bulletline = l:line
  endif

  if s:isList(l:bulletline)
    call append('.', s:getListHead(l:bulletline))
    call cursor(line('.') + 1, col('$'))
    return
  endif

  let l:bullet = '* '
  let l:indent = indent('.')
  call setline('.', strpart(l:line, 0, l:indent) .. l:bullet .. strpart(l:line, l:indent))
  call cursor(0, col('$'))
endfunction
function! s:getNonBlankLineFirst() abort
  let l:lnum = line('.')

  " 直前の行が空白なら 0
  if l:lnum - 1 > prevnonblank(l:lnum - 1)
    return 0
  endif

  while l:lnum >= 1
    if l:lnum - 1 > prevnonblank(l:lnum - 1)
      return l:lnum
    endif
    let l:lnum -= 1
  endwhile

  " 先頭になったら 0
  return 0
endfunction

" * hoge_ -> * hoge
"
"             + _
"
"   + hoge_ ->   + hoge
"
"              * _
"
" * | hoge  -> * | hoge
"   | fuga_      | fuga
"
"                + _
"
" #. | hoge  -> #. | hoge
"    | fuga_       | fuga
"
"                 a. _
function! rst_util#insertRotateBullet(n) abort
  " 先頭が | の行か
  if getline('.') =~# '^\s*|\s'
    let l:lnum = s:getNonBlankLineFirst()
    if l:lnum == 0
      return
    endif
  else
    let l:lnum = line('.')
  endif

  call s:insertRotateBullet(l:lnum, a:n)
endfunction
function! s:insertRotateBullet(lnum, n) abort
  let l:line = getline(a:lnum)
  if !s:isList(l:line)
    return
  endif
  if a:n > 0
    let newLine = '  ' .. s:rotateBullet(s:getListHead(l:line), 1)
  else
    let newLine = strpart(s:rotateBullet(s:getListHead(l:line), -1), 2)
  endif

  call append('.', ['', newLine])
  call cursor(line('.') + 2, col('$') + 2)
endfunction
" }}}

" Insert line block {{{
function! rst_util#insertLineBlock() abort
  let l:line = getline('.')
  let l:lb = '| '

  " * | hoge_ -> * | hoge
  "                | _
  if l:line =~# '^\s*\%(' .. s:regexNumberBullets .. '\|' .. s:regexBullets .. '\)\s|'
    let l:lbpos = stridx(l:line, '|')
    " FIXME: Support the use of tabs for indentation
    call append('.', repeat(' ', l:lbpos) .. l:lb)
    call cursor(line('.') + 1, col('$'))
    return
  endif

  " | hoge_ -> | hoge
  "            | _
  if l:line =~# '^\s*|\s'
    let l:lbpos = stridx(l:line, '|')
    call append('.', repeat(' ', l:lbpos) .. l:lb)
    call cursor(line('.') + 1, col('$'))
    return
  endif

  " #. hoge_ -> #. | hoge
  "                | _
  if l:line =~# '^\s*' .. s:regexNumberBullets .. '\s[^|]'
    call s:insertstr(l:line, l:lb, strlen(s:getListHead(l:line)))
    call append('.', repeat(' ', indent('.') + 3) .. l:lb)
    call cursor(line('.') + 1, col('$'))
    return
  endif

  " * hoge_ -> * | hoge
  "              | _
  if l:line =~# '^\s*' .. s:regexBullets .. '\s[^|]'
    call s:insertstr(l:line, l:lb, strlen(s:getListHead(l:line)))
    call append('.', repeat(' ', indent('.') + 2) .. l:lb)
    call cursor(line('.') + 1, col('$'))
    return
  endif

  " hoge- -> | hoge
  "          | _
  call s:insertstr(l:line, l:lb, indent('.'))
  call append('.', repeat(' ', indent('.')) .. l:lb)
  call cursor(line('.') + 1, col('$'))
endfunction
" }}}

