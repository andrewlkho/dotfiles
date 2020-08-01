colorscheme onehalflight
setlocal background=light
setlocal nocursorline
setlocal colorcolumn=
setlocal norelativenumber

" Soft wrap at window width or 100 (includes gutter etc), whichever is greater
setlocal wrap
setlocal linebreak
setlocal display+=lastline
function! SoftWrap()
    if (&columns > 100)
        setlocal columns=100
    endif
endfunction
augroup tex
    autocmd! VimResized,BufEnter <buffer>
    autocmd VimResized,BufEnter <buffer> call SoftWrap()
augroup END

" Mute the user interface
highlight! link ALEErrorSign LineNr
highlight! link ALEInfoSign LineNr
highlight! link ALEWarningSign LineNr
setlocal showtabline=0
setlocal laststatus=0

nnoremap j gj
nnoremap k gk

nmap <buffer> <leader>ll <plug>(vimtex-compile)
nmap <buffer> <leader>lv <plug>(vimtex-view)
nmap <buffer> <leader>lc <plug>(vimtex-clean)
nmap <buffer> <leader>lw :VimtexCountWords<CR>

nnoremap ,doc :-1read $XDG_CONFIG_HOME/vim/snippets/doc.tex<CR>Gdd2k
nnoremap ,letter :-1read $XDG_CONFIG_HOME/vim/snippets/letter.tex<CR>Gdd14k:put =strftime('%A %e %B %Y')<CR>V=gg/REPLACEME<CR>
