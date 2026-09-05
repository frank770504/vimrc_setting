scriptencoding utf-8

function! airline#extensions#tabline#formatters#fugitive#format(bufnr, buffers) abort
  let l:name = bufname(a:bufnr)
  if l:name =~# '^fugitive://'
    let l:label = exists('*FugitiveTabLabel') ? FugitiveTabLabel(l:name) : ''
    if !empty(l:label)
      let l:hint = get(g:, 'fugitive_tab_hint', '')
      return airline#extensions#tabline#formatters#default#wrap_name(a:bufnr, l:hint . l:label)
    endif
  endif
  return airline#extensions#tabline#formatters#unique_tail_improved#format(a:bufnr, a:buffers)
endfunction
