if isdirectory($HOME . "/Dropbox/Notes")
    nnoremap <expr> bw ":Dirvish " . $HOME . "/Dropbox/Notes<CR>"
    nnoremap <expr> s ":edit " . $HOME . "/Dropbox/Notes/Scratchpad/" . expand(strftime("%Y-%m-%d %H.%M.%S.md")) . "<CR>"
endif

nnoremap <expr> bv ":Dirvish " . $HOME . "/.local/etc/vim<CR>"
