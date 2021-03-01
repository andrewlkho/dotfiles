function! local#linter#run()
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

function! local#linter#status()
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
