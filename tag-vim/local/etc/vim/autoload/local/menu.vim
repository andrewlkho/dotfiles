function! local#menu#new()
    if ! isdirectory($HOME . "/Dropbox/Tarandy/Menus")
        return
    endif

    " Move old menu(s) to the archive
    let curmenus = globpath($HOME . "/Dropbox/Tarandy/Menus", "*", 0, 1)
    call filter(curmenus, {_, v -> fnamemodify(v, ":t") =~ '\m^\d\{4}-\d\{2}-\d\{2}\.txt$'})
    for curmenu in curmenus
        let curmenu_archive = $HOME . "/Dropbox/Tarandy/Menus/Archive/" . fnamemodify(curmenu, ":t")
        if empty(glob(curmenu_archive))
            call rename(curmenu, curmenu_archive)
        endif
    endfor

    " Open new menu
    execute "edit " $HOME . "/Dropbox/Tarandy/Menus/" . strftime("%Y-%m-%d") . ".txt"
    silent only

    " Open most recent menu
    let oldmenus = globpath($HOME . "/Dropbox/Tarandy/Menus/Archive", "*", 0, 1)
    call filter(oldmenus, {_, v -> fnamemodify(v, ":t") =~ '\m^\d\{4}-\d\{2}-\d\{2}\.txt$'})
    let mostrecent = oldmenus->sort()->reverse()->get(0)
    execute "rightbelow vsplit " . mostrecent
    wincmd h
endfunction
