" A simple wiki plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! wiki#get_root() abort " {{{1
  " If the root has been specified already, then simply return it
  if exists('b:wiki.root') | return b:wiki.root | endif

  " Search directory tree for an 'index.EXT' file
  for l:ext in g:wiki_filetypes
    let l:index = printf('%s.%s', g:wiki_index_name, l:ext)
    let l:root = get(
          \ map(
          \   findfile(l:index, '.;', -1),
          \   'fnamemodify(v:val, '':p:h'')'),
          \ -1, '')
    if !empty(l:root) | return l:root | endif
  endfor

  " Try globally specified wiki
  if !empty(g:wiki_root)
    let l:root = fnamemodify(g:wiki_root, ':p')
    if l:root[-1:-1] ==# '/'
      let l:root = l:root[:-2]
    endif
    if !isdirectory(l:root)
      echoerr 'g:wiki_root is specified but it does not exist!'
    else
      return resolve(l:root)
    endif
  endif

  return ''
endfunction

" }}}1
function! wiki#goto_index() abort " {{{1
  call wiki#url#parse('wiki:/index').open()
endfunction

" }}}1
" {{{1 function! wiki#reload()
let s:file = expand('<sfile>')
if get(s:, 'reload_guard', 1)
  function! wiki#reload() abort
    let s:reload_guard = 0
    let l:foldmethod = &l:foldmethod

    " Reload autoload scripts
    for l:file in [s:file]
          \ + split(globpath(fnamemodify(s:file, ':h'), '**/*.vim'), '\n')
      execute 'source' l:file
    endfor

    " Reload plugin
    if exists('g:wiki_loaded')
      unlet g:wiki_loaded
      runtime plugin/wiki.vim
    endif

    " Reload ftplugin and syntax
    if &filetype ==# 'wiki'
      unlet! b:did_ftplugin
      runtime ftplugin/wiki.vim

      if get(b:, 'current_syntax', '') ==# 'wiki'
        unlet b:current_syntax
        runtime syntax/wiki.vim
      endif
    endif

    if exists('#User#WikiReloadPost')
      doautocmd <nomodeline> User WikiReloadPost
    endif

    let &l:foldmethod = l:foldmethod
    unlet s:reload_guard
  endfunction
endif

" }}}1
