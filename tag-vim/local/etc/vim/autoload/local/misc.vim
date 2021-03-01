function! local#misc#ls()
    let bufnrs = range(1, bufnr("$"))
    call filter(bufnrs, {_, v -> buflisted(v)})

    " Work out how long the longest bufhead is to assist with alignment of
    " buftail
    for i in bufnrs
        " + 1 is to account for slash added to the end of bufhead path later
        let bufheadlen = bufname(i)->fnamemodify(":p:~")->pathshorten()->fnamemodify(":h")->len() + 1
        if ! exists("maxheadlen")
            let maxheadlen = bufheadlen
        else
            let maxheadlen = bufheadlen > maxheadlen ? bufheadlen : maxheadlen
        endif
    endfor

    for i in bufnrs
        let bufnum = printf("%*d", bufnr("$")->len(), i)
        let curtag = i == bufnr("%") ? "%" : i == bufnr("#") ? "#" : " "
        let activetag = win_findbuf(i)->empty() ? "h" : "a"
        let modifiabletag = getbufvar(i, "&buftype") == "terminal" ?
                    \ "R" : getbufvar(i, "&modifiable", 1) == 0 ? 
                    \ "-" : " "
        let modifiedtag = getbufvar(i, "&modified", 0) ? "+" : " "
        let bufhead = bufname(i)->empty() ?
                    \ printf("%-*s", maxheadlen, " ") :
                    \ printf("%-*s", maxheadlen, bufname(i)->fnamemodify(":p:~")->pathshorten()->fnamemodify(":h") . "/")
        let buftail = bufname(i)->empty() ?
                    \ "[No Name]" :
                    \ bufname(i)->fnamemodify(":t")
        echo bufnum . " " . curtag . activetag . modifiabletag . modifiedtag . " " . bufhead . "    ". buftail
    endfor
endfunction

function! local#misc#oldfiles()
    " Get the absolute path to all files in v:oldfiles plus all buffers
    let files = mapnew(v:oldfiles, {_, f -> f->fnamemodify(":p")->resolve()})
    let bufnrs = range(1, bufnr("$"))
    call filter(bufnrs, {_, x -> bufexists(x)})
    for i in bufnrs
        if bufname(i)->len() > 0
            files->add(bufname(i)->fnamemodify(":p")->resolve())
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
                \ "lnum": 1,
                \ "col": 1,
                \ "text": "Last modified: " . strftime("%a %d %B %Y %H:%M", getftime(f))
                \ }})
    call setqflist([], ' ', {"items": items})

    " Make all paths relative to $HOME
    let oldpwd = chdir($HOME)
    copen
    call chdir(oldpwd)
endfunction
