" =============================================================================
" Filename: gruvboxcustom.vim
" Author: Andrew Ho
" Description: Based on gruvbox but with correct lightline colours
" Last modified: 2020-05-17
" =============================================================================


if lightline#colorscheme#background() ==# 'dark'
  let s:fg4 = '#a89984' | let s:fg4_256 = 246
  let s:bg0 = '#282828' | let s:bg0_256 = 235
  let s:bg1 = '#3c3836' | let s:bg1_256 = 237
  let s:bg2 = '#504945' | let s:bg2_256 = 239
  let s:bg4 = '#7c6f64' | let s:bg4_256 = 243

  let s:blue = '#83a598' | let s:blue_256 = 109
  let s:aqua = '#8ec07c' | let s:aqua_256 = 108
  let s:red = '#fb4934' | let s:red_256 = 167
  let s:yellow = '#fabd2f' | let s:yellow_256 = 214
  let s:orange = '#fe8019' | let s:orange_256 = 208
else
  let s:fg4 = '#7c6f64' | let s:fg4_256 = 243
  let s:bg0 = '#fbf1c7' | let s:bg0_256 = 229
  let s:bg1 = '#ebdbb2' | let s:bg1_256 = 223
  let s:bg2 = '#d5c4a1' | let s:bg2_256 = 250
  let s:bg4 = '#a89984' | let s:bg4_256 = 246

  let s:blue = '#076678' | let s:blue_256 = 24
  let s:aqua = '#427b58' | let s:aqua_256 = 66
  let s:red = '#9d0006' | let s:red_256 = 88
  let s:yellow = '#b57614' | let s:yellow_256 = 136
  let s:orange = '#af3a03' | let s:orange_256 = 130
endif

let s:group1 = [ s:fg4, s:bg1, s:fg4_256, s:bg1_256 ]
let s:group2 = [ s:fg4, s:bg2, s:fg4_256, s:bg2_256 ]
let s:group3 = [ s:bg0, s:fg4, s:bg0_256, s:fg4_256 ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.left = [ [ s:bg0, s:blue, s:bg0_256, s:blue_256 ], s:group2 ]
let s:p.normal.middle = [ s:group1 ]
let s:p.normal.right = [ s:group3, s:group2 ]

let s:p.insert.left = [ [ s:bg0, s:aqua, s:bg0_256, s:aqua_256 ], s:group2 ]
let s:p.replace.left = [ [ s:bg0, s:red, s:bg0_256, s:red_256 ], s:group2 ]
let s:p.visual.left = [ [ s:bg0, s:yellow, s:bg0_256, s:yellow_256 ], s:group2 ]

let s:p.inactive.left = [ [ s:bg4, s:bg1, s:bg4_256, s:bg1_256 ] ]
let s:p.inactive.middle = [ [ s:bg4, s:bg1, s:bg4_256, s:bg1_256 ] ]
let s:p.inactive.right = [ [ s:bg4, s:bg1, s:bg4_256, s:bg1_256 ] ]

let s:p.tabline.middle = [ [ s:bg0, s:bg0, s:bg0_256, s:bg0_256 ] ]
let s:p.tabline.left = [ s:group1 ]
let s:p.tabline.tabsel = [ s:group2 ]

let s:p.normal.warning = [ [ s:bg2, s:yellow, s:bg2_256, s:yellow_256 ] ]
let s:p.normal.error = [ [ s:bg0, s:orange, s:bg0_256, s:orange_256 ] ]


let g:lightline#colorscheme#gruvboxcustom#palette = s:p
