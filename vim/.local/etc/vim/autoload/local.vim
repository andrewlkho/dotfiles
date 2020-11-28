function! local#ZettelNew()
    " let l:id = strftime("%Y%m%dT%H%M%S")
    " let l:fname = $HOME . "/Dropbox/Notes/zettel/" . l:id . ".md"
    " execute "edit " . l:fname
    " call append(0, "# ")
    " call append(0, "# " . l:id)
    " 2
    let l:now = strftime("%Y-%m-%d %H:%M:%S")
    let l:id = substitute(substitute(substitute(l:now, "-", "", "g"), ":", "", "g"), " ", "T", "")
    let l:fname = $HOME . "/Dropbox/Notes/zettel/" . l:id . ".md"
    execute "edit " . l:fname
    call append(0, "title:  ")
    call append(1, "tags:   ")
    call append(2, "")
    call append(3, "date: " . l:now)
    5d_
    1
    startinsert!
endfunction

function! local#ZettelQfFunc(info)
    let qfl = getqflist({"id" : a:info.id, "items" : 1}).items
    let l = []
    for i in range(a:info.start_idx - 1, a:info.end_idx - 1)
        call add(l, bufname(qfl[i].bufnr)->fnamemodify(":t:r") . '|' . qfl[i].lnum . '|' . qfl[i].text)
    endfor
    return l
endfunction

function! local#ZettelGrep(pattern)
    let l:oldgrepprg = &grepprg
    let l:oldgrepformat = &grepformat
    let &grepprg="find ~/Dropbox/Notes/zettel -type f -exec grep -qsi '" . a:pattern . "' '{}' \\; -exec awk 'BEGIN{ORS=\"\"; printf \"\\%s:0:\", ARGV[1]} /^title:/{sub(\"^title: *\", \"\"); print} /^tags:/{sub(\"^tags: *\", \"    \"); print} END{print \"\\n\"}' '{}' \\;"
    let &grepformat="%f:%l:%m"
    set quickfixtextfunc=local#ZettelQfFunc
    silent grep! | silent redraw!
    copen
    let &grepprg=l:oldgrepprg
    let &grepformat=l:oldgrepformat
    set quickfixtextfunc=
endfunction
