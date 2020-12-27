function! LintBash()
    if executable("shellcheck")
        let l:lines = systemlist("shellcheck -f gcc -s bash -S warning " . expand("%:S"))
    else
        let l:lines = [expand("%") . ":0:0: Warning: shellcheck is not available"]
    endif
    let l:efm = "
                \%f:%l:%c:\ %trror:\ %m,
                \%f:%l:%c:\ %tarning:\ %m,
                \%I%f:%l:%c:\ note:\ %m
                \"
    call setloclist(0, [], "r", {"efm": l:efm, "lines": l:lines, "title": "linter (shellcheck)"})
endfunction
augroup LintBash
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> call LintBash()
augroup END
