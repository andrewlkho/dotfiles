setlocal expandtab
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal tabstop=2

function! LintR()
    let l:lines = systemlist("Rscript --vanilla -e 'lintr::lint(\"" . expand("%") . "\")'")
    " lintr has multi-line output by default, which is not needed for the
    " location list
    call filter(l:lines, {_, x -> x[0:strlen(expand("%:p"))-1] == expand("%:p")})
    let l:efm = "
                \%W%f:%l:%c: style: %m,
                \%W%f:%l:%c: warning: %m,
                \%E%f:%l:%c: error: %m
                \"
    call setloclist(0, [], "r", {"efm": l:efm, "lines": l:lines, "title": "linter (lintr)"})
endfunction
augroup LintR
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> call LintR()
augroup END

setlocal formatprg=Rscript\ --vanilla\ -e\ 'x\ <-\ file(\"stdin\");\ o\ <-\ styler::style_text(readLines(x),scope=\"line_breaks\");\ close(x);\ o'\ 2>/dev/null
nnoremap <buffer> <leader>gq gggqG<C-O><C-O>

nnoremap <buffer> <leader>r :let cwd=expand("%:p:h")<CR>:vertical terminal ++norestore ++close R --no-save --quiet<CR><C-W>:call term_sendkeys("", "setwd('" . cwd . "')")<CR><CR>
vnoremap <buffer> <leader>l :'<.'> w! $XDG_CACHE_HOME/vim/repl-tmp<CR><C-W><C-W>source(paste0(Sys.getenv("XDG_CACHE_HOME"), "/vim/repl-tmp"), echo=TRUE, max.deparse.length=4095)<CR><C-W><C-W>
nnoremap <buffer> <leader>! :!Rscript --vanilla %<CR>
