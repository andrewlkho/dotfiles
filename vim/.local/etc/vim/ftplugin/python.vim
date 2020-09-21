setlocal expandtab
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal tabstop=4

setlocal foldmethod=indent
setlocal foldnestmax=1
setlocal foldlevel=99

setlocal makeprg=flake8\ --max-line-length\ 88\ --extend-ignore=E203\ %:S
setlocal errorformat=%f:%l:%c:\ %t%n\ %m
augroup lint
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> silent lmake! | silent redraw!
augroup END

nnoremap <buffer> <leader>gq :Black<CR>

nnoremap <buffer> <leader>r :let cwd=expand("%:p:h")<CR>:vertical terminal ++norestore ++close<CR><C-W>:call term_sendkeys("", "cd '" . cwd . "'")<CR><CR>python && exit<CR>import os<CR>
vnoremap <buffer> <leader>l :'<.'> w! $XDG_CACHE_HOME/vim/repl-tmp<CR><C-W><C-W>print(open(os.environ["XDG_CACHE_HOME"] + "/vim/repl-tmp").read())<CR>exec(open(os.environ["XDG_CACHE_HOME"] + "/vim/repl-tmp").read())<CR>

nnoremap ,main :-1read $XDG_CONFIG_HOME/vim/snippets/main.py<CR>Gdd4k
