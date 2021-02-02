setlocal expandtab
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal tabstop=4

setlocal foldmethod=indent
setlocal foldnestmax=1
setlocal foldlevel=99

nnoremap <buffer> <leader>gq :Black<CR>

nnoremap <buffer> <leader>r :let cwd=expand("%:p:h")<CR>:vertical terminal ++norestore ++close<CR><C-W>:call term_sendkeys("", "cd '" . cwd . "'")<CR><CR>python && exit<CR>import os<CR>
vnoremap <buffer> <leader>l :'<.'> w! $XDG_CACHE_HOME/vim/repl-tmp<CR><C-W><C-W>print(open(os.environ["XDG_CACHE_HOME"] + "/vim/repl-tmp").read())<CR>exec(open(os.environ["XDG_CACHE_HOME"] + "/vim/repl-tmp").read())<CR>
