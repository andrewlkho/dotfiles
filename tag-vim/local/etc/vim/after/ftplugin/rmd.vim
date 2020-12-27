setlocal expandtab
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal tabstop=2

" (Ab)use code blocks for folding
setlocal foldmethod=marker
setlocal foldmarker=```{,```
setlocal foldlevel=99

setlocal makeprg=Rscript\ -e\ \"rmarkdown::render('%')\"
