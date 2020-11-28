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

function! local#OldfilesQfFunc(info)
    let qfl = getqflist({"id": a:info.id, "items": 1}).items
    let l = []
    for i in range(a:info.start_idx - 1, a:info.end_idx - 1)
        call add(l, bufname(qfl[i].bufnr)->fnamemodify(":p") . "|" . qfl[i].lnum . "|" . qfl[i].text)
    endfor
    return l
endfunction

function! local#Oldfiles()
    " Get the absolute path to all files in v:oldfiles plus any unlisted buffers.
    " This is easier than fiddling with rviminfo / wviminfo.  I tend to :bdelete
    " buffers I'm done with, anything else should be in :buffers so doesn't need
    " to be in the oldfiles listing.
    let files = mapnew(v:oldfiles, {_, f -> f->fnamemodify(":p")})
    let bufnrs = range(1, bufnr("$"))
    call filter(bufnrs, {_, x -> bufexists(x) && ! buflisted(x)})
    for i in bufnrs
        if bufname(i)->len() > 0
            files->add(bufname(i)->fnamemodify(":p"))
        endif
    endfor
    call uniq(sort(files))

    " Remove directories and files that can't be found plus vim help files
    call filter(files, {_, f -> getftype(f) != "dir" && getftime(f) != -1})
    call filter(files, {_, f -> f !~ "/usr.*/share/vim.*/doc/.*\.txt$"})

    " Populate quickfix
    call sort(files, {x, y ->  getftime(y) - getftime(x)})
    let items = mapnew(files, {_, f -> {
                \ "filename": f->fnamemodify(":p"),
                \ "lnum": 0,
                \ "col": 0,
                \ "text": "Last modified: " . strftime("%a %d %B %Y %H:%M", getftime(f))
                \ }})
    call setqflist([], ' ', {"items": items, "quickfixtextfunc": "local#OldfilesQfFunc"})
    copen
endfunction
