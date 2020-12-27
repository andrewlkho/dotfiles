setlocal textwidth=80
setlocal formatoptions+=tcqwl1

if expand("%:p:h") == $HOME . "/Dropbox/Notes/zettel"
    setlocal tags=$XDG_CACHE_HOME/vim/tags
    setlocal iskeyword+=#
    augroup ZettelGenerateTags
        autocmd! * <buffer>
        autocmd BufWritePost <buffer> call system('find ${HOME}/Dropbox/Notes/zettel -type f -exec awk ''BEGIN{OFS="\n"} {$1=$1} /^tags:/{for (i=2;i<=NF;i++) print $i "\t" FILENAME "\t" 1}'' ''{}'' + | sort > ${XDG_CACHE_HOME}/vim/tags')
    augroup END
endif
