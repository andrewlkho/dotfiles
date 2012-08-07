" folding
setlocal foldmethod=indent
setlocal foldnestmax=1
setlocal foldlevel=1
nmap <buffer> <leader>f za
nmap <buffer> <silent> ,f0 :nmap <buffer> <leader>F ,f1<CR>:setlocal foldlevel=0<CR>
nmap <buffer> <silent> ,f1 :nmap <buffer> <leader>F ,f0<CR>:setlocal foldlevel=1<CR>
nmap <buffer> <leader>F ,f0

" compilation shortcuts
nmap <buffer> <leader>py :!/usr/bin/env python<CR>
nmap <buffer> <leader>pr :!/usr/bin/env python % <CR>
