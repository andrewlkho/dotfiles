let b:ale_linters = ['flake8']
let b:ale_fixers = ['trim_whitespace', 'autopep8']
let b:ale_python_flake8_options = '--max-line-length=119'

let g:SimpylFold_docstring_preview = 1
nnoremap <space> za
set foldlevel=99

set expandtab
set softtabstop=4
set shiftwidth=4
set tabstop=4

nnoremap ,main :-1read $XDG_CONFIG_HOME/vim/snippets/main.py<CR>Gdd4k
