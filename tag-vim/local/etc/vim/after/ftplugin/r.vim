setlocal expandtab
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal tabstop=2

setlocal formatprg=Rscript\ --no-save\ --no-restore\ -e\ 'x\ <-\ file(\"stdin\");\ o\ <-\ styler::style_text(readLines(x),scope=\"line_breaks\");\ close(x);\ o'\ 2>/dev/null
nnoremap <buffer> <leader>gq gggqG<C-O><C-O>

nnoremap <buffer> <leader>r :let cwd=expand("%:p:h")<CR>:vertical terminal ++norestore ++close R --no-save --quiet<CR><C-W>:call term_sendkeys("", "setwd('" . cwd . "')")<CR><CR>
vnoremap <buffer> <leader>l :'<.'> w! $XDG_CACHE_HOME/vim/repl-tmp<CR><C-W><C-W>source(paste0(Sys.getenv("XDG_CACHE_HOME"), "/vim/repl-tmp"), echo=TRUE, max.deparse.length=4095)<CR><C-W><C-W>
nnoremap <buffer> <leader>! :!Rscript --no-save --no-restore %:S<CR>
