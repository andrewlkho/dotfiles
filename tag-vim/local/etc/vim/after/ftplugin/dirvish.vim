if isdirectory($HOME . "/Dropbox/Notes")
    nnoremap <buffer><expr> bw ":Dirvish " . $HOME . "/Dropbox/Notes<CR>"
    nnoremap <buffer><expr> s ":edit " . $HOME . "/Dropbox/Notes/Scratchpad/" . expand(strftime("%Y-%m-%d %H.%M.%S.md")) . "<CR>"
endif

if isdirectory($HOME . "/git/brainmask_hpc.git/pbs")
    nnoremap <buffer><expr> bp ":Dirvish " . $HOME . "/git/brainmask_hpc.git/pbs<CR>"
endif

nnoremap <buffer><expr> bv ":Dirvish " . $HOME . "/.local/etc/vim<CR>"
