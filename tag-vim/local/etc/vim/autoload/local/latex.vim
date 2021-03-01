" add biblatex citekeys to internal (spell) wordlist
function! local#latex#spelladdcitekeys()
    let l:bibfiles = getline(1, "$")
    call filter(l:bibfiles, {_, v -> match(v, "addbibresource") > -1})
    call map(l:bibfiles, {_, v -> matchstr(v, "addbibresource{.*}")[15:-2]})
    for l:b in l:bibfiles
        if filereadable(l:b)
            if exists("l:allbibs")
                call extend(l:allbibs, readfile(l:b))
            else
                let l:allbibs = readfile(l:b)
            endif
        endif
    endfor
    if exists("l:allbibs")
        call filter(l:allbibs, {_, v -> match(v, "^@") > -1})
        call map(l:allbibs, {_, v -> matchstr(v, "{.*,")[1:-2]})
        for l:citekey in l:allbibs
            silent execute ":spellgood! " . l:citekey
        endfor
    endif
endfunction

" abuse the location list to show an outline of the current document
function! local#latex#outline()
    let l:levels = {"part": 0, "chapter": 1, "section": 2, "subsection": 3,
                \"subsubsection": 4, "paragraph": 5, "subparagraph": 6}

    let l:lines = getline(1, "$")
    call map(l:lines, {l, v -> [l+1, v]})
    let l:pattern = '^\\\(' . join(keys(l:levels), '\|') . '\)'
    call filter(l:lines, {_, v -> match(v[1], l:pattern) > -1 })

    let l:minlevel = mapnew(l:lines, {_, v -> l:levels[matchstr(v[1], '^\\[^{]\+{')[1:-2]]})->min()
    let l:items = []
    for l:row in l:lines
        let l:bufnr = bufnr()
        let l:lnum = l:row[0]
        let l:col = 1
        let l:level = l:levels[matchstr(l:row[1], '^\\[^{]\+{')[1:-2]] - l:minlevel
        let l:prefix = repeat("· ", l:level)
        let l:name = l:row[1]->substitute('\\[^{]\+{', '', 'g')->substitute('}', '', 'g')->substitute('[^\\]%.*$', '', '')
        call add(l:items, {"bufnr": l:bufnr, "lnum": l:lnum, "col": l:col, "text": l:prefix . l:name})
    endfor
    call setloclist(0, [], "r", {"items": l:items, "quickfixtextfunc": "local#latex#outlinellfunc"})
endfunction

function! local#latex#outlinellfunc(info)
    let l:items = getloclist(a:info.winid, {"items": 1}).items
    let l:l = []
    for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
        call add(l:l, l:items[idx].text)
    endfor
    return l:l
endfunction

let s:latexmk_job = -1
function! local#latex#latexmk()
    echo "Compiling with latexmk... "
    if has("job")
        let s:latexmk_job = job_start(["latexmk", "-cd", expand("%")], {"close_cb": "local#latex#latexmkfinish"})
    else
        let l:lines = systemlist("latexmk -cd " . expand("%"))
        if v:shell_error
            echon "failed!"
        else
            echon "success!"
        endif
        call setqflist([], " ", {"efm": &errorformat, "lines": l:lines})
    endif
endfunction

function! local#latex#latexmkfinish(channel)
    let l:lines = []
    while ch_status(a:channel, {"part": "out"}) == "buffered"
        call add(l:lines, ch_read(a:channel))
    endwhile
    let l:exit = ch_getjob(a:channel)->job_info()->get("exitval")

    call setqflist([], " ", {"efm": &errorformat, "lines": l:lines})
    if l:exit == 0
        echo "Compiling with latexmk... success!"
    else
        echo "Compiling with latexmk... failed!"
    endif
endfunction
