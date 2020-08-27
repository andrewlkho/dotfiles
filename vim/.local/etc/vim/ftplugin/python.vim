let b:ale_linters = ['flake8']
let b:ale_python_flake8_options = '--max-line-length 88 --extend-ignore=E203,W503'

let g:SimpylFold_docstring_preview = 1
nnoremap <space> za
setlocal foldlevel=99

setlocal expandtab
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal tabstop=4

setlocal colorcolumn=88
nnoremap <buffer> <leader>gq :Black<CR>

nnoremap <buffer> <leader>r :let cwd=expand("%:p:h")<CR>:vertical terminal ++norestore ++close<CR><C-W>:call term_sendkeys("", "cd '" . cwd . "'")<CR><CR>python && exit<CR>import os<CR>
vnoremap <buffer> <leader>l :'<.'> w! $XDG_CACHE_HOME/vim/repl-tmp<CR><C-W><C-W>print(open(os.environ["XDG_CACHE_HOME"] + "/vim/repl-tmp").read())<CR>exec(open(os.environ["XDG_CACHE_HOME"] + "/vim/repl-tmp").read())<CR>

nnoremap ,main :-1read $XDG_CONFIG_HOME/vim/snippets/main.py<CR>Gdd4k
