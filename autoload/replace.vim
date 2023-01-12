fu! s:pasteCmdlineWindowCur(mode)
  if a:mode == 0
    let tmp = [
          \ printf('%%s/\<%s\>/%s/g', s:cword, s:cword),
          \ printf('    %%s/%s/%s/g', s:cword, s:cword),
          \ ]
  else
    let tmp = [
          \ printf("'<,'>s\/\\<%s\\>/%s/g", s:cword, s:cword),
          \ printf("    '<,'>s/%s/%s/g", s:cword, s:cword),
          \ ]
  endif
  let length = 2
  if s:cword != s:cWORD
    if a:mode == 0
      let tmp += [
            \ printf('    %%s/%s/%s/g', s:cWORD, s:cWORD),
            \ ]
    else
      let tmp += [
            \ printf("'<,'>s/%s/%s/g", s:cWORD, s:cWORD),
            \ ]
    endif
    let length += 1
  endif
  call setline('.', tmp)
  1000wincmd -
  exec string(length * 2 - 2) ."wincmd +"
  norm zz$2h
  exec "norm \<c-e>"
endfu

fu! replace#do(cmd)
  exec a:cmd
endfu

fu! s:pasteCmdlineWindowAll()
  let pwd = substitute(getcwd(), '\', '/', 'g')
  let pwd = substitute(pwd, ' ', '\\ ', 'g')
  if exists("g:terminal_ok") && g:terminal_ok == 1
    let tmp = "call bash#runHide('fd * "
    let tmp .= '"%s"'
  else
    let tmp = "call replace#do('AsyncRun bash -c \"fd * "
    let tmp .= '\"%s\"'
  endif
  let tmp .= " -X sed -i '"
  let tmp .= ' ."'
  let tmp .= "'"
  let tmp .= '"'
  let tmp .= "%s .'"
  let tmp .= '1,$s/'
  let tmp .= '%s'
  let tmp .= '%s'
  let tmp .= '%s'
  let tmp .= '/'
  let tmp .= '%s'
  let tmp .= "/g'"
  let tmp .= ' ."'
  let tmp .= "'"
  let tmp .= '")'
  call setline('.', [
        \ printf(tmp, pwd, '',   '\<', s:cword, '\>', s:cword),
        \ printf(tmp, pwd, '    ', '', s:cword,   '', s:cword),
        \ printf(tmp, pwd, '',     '', s:cWORD,   '', s:cWORD),
        \ ])
  1000wincmd -
  4wincmd +
  norm zz$F/h
  exec "norm \<c-e>"
endfu

fu! s:escape(abspath)
  return substitute(a:abspath, '/', '\', 'g')
endfu

fu! replace#tryGoTo(abspath)
  let go = 0
  for tabIndex in range(1, tabpagenr('$'))
    let bufs = tabpagebuflist(tabIndex)
    for winIndex in range(len(bufs))
      let bufNr = bufs[winIndex]
      if nvim_buf_is_valid(bufNr)
        if s:escape(nvim_buf_get_name(bufNr)) == s:escape(a:abspath)
          call win_gotoid(win_getid(winIndex+1, tabIndex))
          let go = 1
          break
        endif
      endif
    endfor
  endfor
  return go
endfu

fu! replace#cur(mode)
  let cword = expand('<cword>')
  let cWORD = expand('<cWORD>')
  if len(cword) != 0
    let s:cword = cword
    let s:cWORD = cWORD
  endif
  if len(s:cword) == 0
    return
  endif
  call feedkeys(":\<c-f>")
  call timer_start(20, { -> <sid>pasteCmdlineWindowCur(a:mode) })
endfu

fu! replace#all()
  let cword = expand('<cword>')
  let cWORD = expand('<cWORD>')
  if len(cword) != 0
    let s:cword = cword
    let s:cWORD = cWORD
  endif
  if len(s:cword) == 0
    return
  endif
  let curP = expand('%:p')
  call bash#hide()
  call replace#tryGoTo(curP)
  call feedkeys(":\<c-f>")
  call timer_start(20, { -> <sid>pasteCmdlineWindowAll() })
endfu

let s:cword = ''
let s:cWORD = ''
