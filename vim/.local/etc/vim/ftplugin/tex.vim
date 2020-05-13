setlocal background=light
colorscheme PaperColor
set nocursorline

function! s:goyo_enter()
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!

  " fix border around goyo window
  highlight VertSplit cterm=NONE
  highlight StatusLine cterm=NONE
  highlight StatusLineNC cterm=NONE
  
  " subdued linting
  highlight AleErrorSign ctermfg=252
  highlight AleWarningSign ctermfg=252
  highlight AleInfoSign ctermfg=252
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

" fixes https://github.com/reedes/vim-pencil/issues/76
let g:pencil#cursorwrap = 0
call pencil#init({'wrap': 'soft', 'textwidth': 100, 'conceallevel': 0})
call goyo#execute(0, '100x100%')

nmap <buffer> <leader>ll <plug>(vimtex-compile)
nmap <buffer> <leader>lv <plug>(vimtex-view)
nmap <buffer> <leader>lc <plug>(vimtex-clean)
nmap <buffer> <leader>lw :VimtexCountWords<CR>
