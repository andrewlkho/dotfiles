highlight link texSpecialChar Normal

" I find syntax highlighting of citation commands distracting
call matchadd('texComment', '\\autocite{[^}]*}')
