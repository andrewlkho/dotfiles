let R_source = "~/.vim/bundle/Nvim-R/R/tmux_split.vim"
let R_assign = 0
let R_args = ['--no-save', '--quiet']
let R_nvimpager = 0
let R_tmux_title = "automatic"

let R_user_maps_only = 1
nmap <LocalLeader>rf <Plug>RStart
nmap <LocalLeader>rq <Plug>RClose
nmap <LocalLeader>rl <Plug>RSendFile
vmap <LocalLeader>rl <Plug>RSendSelection<Esc>
nmap <LocalLeader>kh <Plug>RMakeHTML
nmap <LocalLeader>kp <Plug>RMakePDFK

setlocal expandtab
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal tabstop=2
