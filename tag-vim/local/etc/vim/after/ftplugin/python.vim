setlocal expandtab
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal tabstop=4

setlocal foldmethod=indent
setlocal foldnestmax=1
setlocal foldlevel=99

function! LintPython()
    if executable("xflake8")
        let l:lines = systemlist("flake8 --max-line-length 88 --extend-ignore=E203 " . expand("%:S"))
    else
        let l:lines = [expand("%"). ":0:0: W0 flake8 is not available"]
    endif
    call setloclist(0, [], "r", {"efm": "%f:%l:%c: %t%n %m", "lines": l:lines, "title": "linter (flake8)"})
endfunction
augroup LintPython
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> call LintPython()
augroup END

nnoremap <buffer> <leader>gq :Black<CR>

nnoremap <buffer> <leader>r :let cwd=expand("%:p:h")<CR>:vertical terminal ++norestore ++close<CR><C-W>:call term_sendkeys("", "cd '" . cwd . "'")<CR><CR>python && exit<CR>import os<CR>
vnoremap <buffer> <leader>l :'<.'> w! $XDG_CACHE_HOME/vim/repl-tmp<CR><C-W><C-W>print(open(os.environ["XDG_CACHE_HOME"] + "/vim/repl-tmp").read())<CR>exec(open(os.environ["XDG_CACHE_HOME"] + "/vim/repl-tmp").read())<CR>

nnoremap ,main :-1read $XDG_CONFIG_HOME/vim/snippets/main.py<CR>Gdd4k
