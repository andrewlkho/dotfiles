function! local#zettel#new()
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

function! local#zettel#qffunc(info)
    let qfl = getqflist({"id": a:info.id, "items": 1}).items
    let l = []
    for i in range(a:info.start_idx - 1, a:info.end_idx - 1)
        call add(l, bufname(qfl[i].bufnr)->fnamemodify(":t:r") . "|" . qfl[i].lnum . "|" . qfl[i].text)
    endfor
    return l
endfunction

function! local#zettel#grep(pattern)
    let lines = systemlist("find ~/Dropbox/Notes/zettel -type f -exec grep -qsi '" . a:pattern . "' '{}' \\; -exec awk 'BEGIN{ORS=\"\"; printf \"\\%s:0:\", ARGV[1]} /^title:/{sub(\"^title: *\", \"\"); print} /^tags:/{sub(\"^tags: *\", \" \"); print} END{print \"\\n\"}' '{}' \\;")
    call reverse(sort(lines))
    call setqflist([], ' ', {"efm": "%f:%l:%m", "lines": lines, "quickfixtextfunc": "local#zettel#qffunc"})
    copen
endfunction

function! local#zettel#index()
    enew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
    setlocal path=$HOME/Dropbox/Notes/zettel suffixesadd=.md
    file [ZettelIndex]
    let l:output = systemlist('find /Users/andrewlkho/Dropbox/Notes/zettel -type f -exec awk ''BEGIN{sprintf("basename -s .md %s", ARGV[1]) | getline fn} /^title:/{sub("^title: *", ""); title=$0} /^tags:/{sub("^tags: *", ""); tags=$0} END{printf "%s|%s|%s\n", fn, title, tags}'' "{}" \; | sort -r | column -s "|" -t')
    call setline(1, l:output)
endfunction
