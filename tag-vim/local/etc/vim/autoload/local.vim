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
    let qfl = getqflist({"id": a:info.id, "items": 1}).items
    let l = []
    for i in range(a:info.start_idx - 1, a:info.end_idx - 1)
        call add(l, bufname(qfl[i].bufnr)->fnamemodify(":t:r") . "|" . qfl[i].lnum . "|" . qfl[i].text)
    endfor
    return l
endfunction

function! local#ZettelGrep(pattern)
    let lines = systemlist("find ~/Dropbox/Notes/zettel -type f -exec grep -qsi '" . a:pattern . "' '{}' \\; -exec awk 'BEGIN{ORS=\"\"; printf \"\\%s:0:\", ARGV[1]} /^title:/{sub(\"^title: *\", \"\"); print} /^tags:/{sub(\"^tags: *\", \" \"); print} END{print \"\\n\"}' '{}' \\;")
    call reverse(sort(lines))
    call setqflist([], ' ', {"efm": "%f:%l:%m", "lines": lines, "quickfixtextfunc": "local#ZettelQfFunc"})
    copen
endfunction

function! local#ZettelIndex()
    enew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
    setlocal path=$HOME/Dropbox/Notes/zettel suffixesadd=.md
    file [ZettelIndex]
    let l:output = systemlist('find /Users/andrewlkho/Dropbox/Notes/zettel -type f -exec awk ''BEGIN{sprintf("basename -s .md %s", ARGV[1]) | getline fn} /^title:/{sub("^title: *", ""); title=$0} /^tags:/{sub("^tags: *", ""); tags=$0} END{printf "%s|%s|%s\n", fn, title, tags}'' "{}" \; | sort -r | column -s "|" -t')
    call setline(1, l:output)
endfunction

function! local#OldfilesQfFunc(info)
    let qfl = getqflist({"id": a:info.id, "items": 1}).items
    let l = []
    for i in range(a:info.start_idx - 1, a:info.end_idx - 1)
        call add(l, bufname(qfl[i].bufnr)->fnamemodify(":p:~") . "|" . qfl[i].lnum . "|" . qfl[i].text)
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

function! local#LinterRun()
    if &filetype == "python"
        if executable("flake8")
            let l:lines = systemlist("flake8 --max-line-length 88 --extend-ignore=E203 " . expand("%:S"))
            let l:efm = "%f:%l:%c: %t%n %m"
            let l:title = "flake8"
        endif
    elseif &filetype == "sh"
        if executable("shellcheck")
            let l:shelltype = exists("b:is_bash") ? "bash" : "sh"
            let l:lines = systemlist("shellcheck -f gcc -s " . l:shelltype . " -S warning " . expand("%:S"))
            let l:efm = "
                        \%f:%l:%c:\ %trror:\ %m,
                        \%f:%l:%c:\ %tarning:\ %m,
                        \%I%f:%l:%c:\ note:\ %m
                        \"
            let l:title = "shellcheck (" . l:shelltype . ")"
        endif
    elseif &filetype == "r"
        if executable("Rscript")
            let l:lines = systemlist("Rscript --vanilla -e 'lintr::lint(\"" . expand("%") . "\")'")
            " lintr has multi-line output by default, which is not needed for the
            " location list
            call filter(l:lines, {_, x -> x[0:strlen(expand("%:p"))-1] == expand("%:p")})
            let l:efm = "
                        \%W%f:%l:%c: style: %m,
                        \%W%f:%l:%c: warning: %m,
                        \%E%f:%l:%c: error: %m
                        \"
            let l:title = "lintr"
        endif
    endif

    if exists("l:lines")
        call setloclist(0, [], "r", {"efm": l:efm, "lines": l:lines, "title": "linter output: " . l:title})
    endif
endfunction

function! local#LinterStatus()
    let l:output = ''

    if getloclist(0, {"title": 0})["title"][0:12] == "linter output"
        let l:errors = len(filter(getloclist(0), {k, v -> v.valid == 1 && (v.type ==? "E" || v.type ==? "F")}))
        let l:warnings = len(filter(getloclist(0), {k, v -> v.valid == 1 && v.type ==? "W"}))

        if l:errors > 0
            let l:output = l:output . '✗' . l:errors . ' '
        endif
        if l:warnings > 0
            let l:output = l:output . '▲' . l:warnings . ' '
        endif
        if len(l:output) > 0
            let l:output = ' ' . l:output
        endif
    endif

    return l:output
endfunction

function! local#ListBuffers()
    let bufnrs = range(1, bufnr("$"))
    call filter(bufnrs, {_, v -> buflisted(v)})
    for i in bufnrs
        let bufnum = printf("%*d", bufnr("$")->len(), i)
        let curtag = i == bufnr("%") ? "%" : i == bufnr("#") ? "#" : " "
        let activetag = win_findbuf(i)->empty() ? "h" : "a"
        let modifiabletag = getbufvar(i, "&buftype") == "terminal" ?
                    \ "R" : getbufvar(i, "&modifiable", 1) == 0 ? 
                    \ "-" : " "
        let modifiedtag = getbufvar(i, "&modified", 0) ? "+" : " "
        let bufname = bufname(i)->empty() ?
                    \ "[No Name]" :
                    \ bufname(i)->fnamemodify(":p:~")->pathshorten()
        echo bufnum . " " . curtag . activetag . modifiabletag . modifiedtag . " " . bufname
    endfor
endfunction
