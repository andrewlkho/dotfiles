setlocal textwidth=100

" Mute the user interface
setlocal cursorlineopt=number
setlocal showtabline=0
setlocal laststatus=0
setlocal nonumber
setlocal norelativenumber

nnoremap <buffer> j gj
nnoremap <buffer> k gk

" shortcut to making environments: type itemize then press <C-B>
inoremap <buffer> <C-B> <Esc>yypk$<C-V>jA}<Esc>^i\begin{<Esc>j^i\end{<Esc>O

setlocal spell
" add biblatex citekeys to internal (spell) wordlist
function! SpellAddCitekeys()
    let l:bibfiles = getline(1, "$")
    call filter(l:bibfiles, {_, v -> match(v, "addbibresource") > -1})
    call map(l:bibfiles, {_, v -> matchstr(v, "addbibresource{.*}")[15:-2]})
    for l:b in l:bibfiles
        try
            if exists("l:allbibs")
                call extend(l:allbibs, readfile(l:b))
            else
                let l:allbibs = readfile(l:b)
            endif
        catch
        endtry
    endfor
    if exists("l:allbibs")
        call filter(l:allbibs, {_, v -> match(v, "^@") > -1})
        call map(l:allbibs, {_, v -> matchstr(v, "{.*,")[1:-2]})
        for l:citekey in l:allbibs
            silent execute ":spellgood! " . l:citekey
        endfor
    endif
endfunction
augroup SpellAddCitekeys
    autocmd! * <buffer>
    autocmd BufEnter,BufWritePost <buffer> call SpellAddCitekeys()
augroup END

" Abuse the location list to show an outline of the current document
function! LatexOutline()
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
    call setloclist(0, [], "r", {"items": l:items, "quickfixtextfunc": "LatexOutlineLLFunc"})
endfunction
function! LatexOutlineLLFunc(info)
    let l:items = getloclist(a:info.winid, {"items": 1}).items
    let l:l = []
    for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
        call add(l:l, l:items[idx].text)
    endfor
    return l:l
endfunction
command! LatexShowOutline call LatexOutline() |
            \ vertical leftabove lopen |
            \ execute "vertical resize " . mapnew(getline(1, "$"), {_, v -> len(v)})->max() |
            \ wincmd p |
            \ lbefore |
            \ execute "normal \<C-O>"

" run latexmk without clobbering the screen
function! Latexmk()
    echo "Compiling with latexmk... "
    let l:lines = systemlist("latexmk " . expand("%:S"))
    if v:shell_error
        echon "failed!"
    else
        echon "success!"
    endif
    call setqflist([], " ", {"efm": &errorformat, "lines": l:lines})
endfunction
nnoremap <buffer> <leader>ll :call Latexmk()<CR>
nnoremap <buffer> <leader>lc :!latexmk -c %<CR>
nnoremap <buffer> <leader>lw :!texcount %<CR>
nnoremap <buffer> <leader>lo :execute "cgetfile" . expand("%:p:r") . ".log"<CR>:copen<CR>

setlocal makeprg=latexmk\ %:S
" https://github.com/lervag/vimtex/blob/98327bfe0e599bf580e61cfaa6216c8d4177b23d/compiler/latexmk.vim
setlocal errorformat=%-P**%f
setlocal errorformat+=%-P**\"%f\"
setlocal errorformat+=%E!\ LaTeX\ %trror:\ %m
setlocal errorformat+=%E%f:%l:\ %m
setlocal errorformat+=%E!\ %m
setlocal errorformat+=%Z<argument>\ %m
setlocal errorformat+=%Cl.%l\ %m
setlocal errorformat+=%+WLaTeX\ Font\ Warning:\ %.%#line\ %l%.%#
setlocal errorformat+=%-CLaTeX\ Font\ Warning:\ %m
setlocal errorformat+=%-C(Font)%m
setlocal errorformat+=%+WLaTeX\ %.%#Warning:\ %.%#line\ %l%.%#
setlocal errorformat+=%+WLaTeX\ %.%#Warning:\ %m
setlocal errorformat+=%+WOverfull\ %\\%\\hbox%.%#\ at\ lines\ %l--%*\\d
setlocal errorformat+=%+WUnderfull\ %\\%\\hbox%.%#\ at\ lines\ %l--%*\\d
setlocal errorformat+=%+WPackage\ natbib\ Warning:\ %m\ on\ input\ line\ %l%.
setlocal errorformat+=%+WPackage\ biblatex\ Warning:\ %m
setlocal errorformat+=%-C(biblatex)%.%#in\ t%.%#
setlocal errorformat+=%-C(biblatex)%.%#Please\ v%.%#
setlocal errorformat+=%-C(biblatex)%.%#LaTeX\ a%.%#
setlocal errorformat+=%-C(biblatex)%m
setlocal errorformat+=%-Z(babel)%.%#input\ line\ %l.
setlocal errorformat+=%-C(babel)%m
setlocal errorformat+=%+WPackage\ hyperref\ Warning:\ %m
setlocal errorformat+=%-C(hyperref)%.%#on\ input\ line\ %l.
setlocal errorformat+=%-C(hyperref)%m
setlocal errorformat+=%+WPackage\ scrreprt\ Warning:\ %m
setlocal errorformat+=%-C(scrreprt)%m
setlocal errorformat+=%+WPackage\ fixltx2e\ Warning:\ %m
setlocal errorformat+=%-C(fixltx2e)%m
setlocal errorformat+=%+WPackage\ titlesec\ Warning:\ %m
setlocal errorformat+=%-C(titlesec)%m
setlocal errorformat+=%-G%.%#

nnoremap <buffer> ,doc :-1read $XDG_CONFIG_HOME/vim/snippets/doc.tex<CR>Gdd2k
nnoremap <buffer> ,letter :-1read $XDG_CONFIG_HOME/vim/snippets/letter.tex<CR>Gdd14k:put =strftime('%A %e %B %Y')<CR>V=gg/REPLACEME<CR>
