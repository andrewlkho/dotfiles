setlocal foldmethod=indent

" compilation shortcuts
nmap <buffer> <leader>py :!/usr/bin/env python<CR>
nmap <buffer> <leader>pr :!/usr/bin/env python % <CR>

" syntastic
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_args = '--ignore=E501'
