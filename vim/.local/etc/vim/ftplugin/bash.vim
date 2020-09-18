setlocal makeprg=shellcheck\ -f\ gcc\ -s\ bash\ -S\ warning
setlocal errorformat=
    \%f:%l:%c:\ %trror:\ %m,
    \%f:%l:%c:\ %tarning:\ %m,
    \%I%f:%l:%c:\ note:\ %m

augroup lint
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> silent lmake! <afile> | silent redraw!
augroup END
