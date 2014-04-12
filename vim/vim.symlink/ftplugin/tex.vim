setlocal spell
setlocal textwidth=80
setlocal formatoptions=tq

let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
let g:LatexBox_viewer = "open -a Skim"
let g:LatexBox_quickfix = 2
let g:LatexBox_latexmk_options = "-pdflatex='pdflatex -synctex=1 \%O \%S'"
