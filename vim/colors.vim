" Vim File
" Author: Guy J Grigsby <https://grigsby.dev>
" Version: 0.1.0
" Created: Thu Dec 17 21:51:22 2020
" Title:   colors.vim
" Summary:
"

let s:none = [ 'NONE', 'NONE' ]
let s:ultrablack = [ '#000000', 0 ]
let s:black = [ '#121212', 233 ]
let s:grey = [ '#626262', 241 ]
let s:lightgrey = [ '#d0d0d0', 252 ]
let s:white = [ '#ffffff', 231 ]
let s:teal = [ '#00afd7', 38 ]
let s:hotpink = [ '#ff5fd7', 206 ]
let s:mediumpurple = ['#af5fff', 135]
let s:purple = [ '#8787d7', 104 ]
let s:verypurple = ['#af00ff',169]
let s:darkpurple = [ '#380549', 128 ]
let s:lightpink = [ '#ffd7ff', 225 ]
let s:pink = [ '#d7005f', 161 ]
let s:steelblue = [ '#5fd7ff', 81 ]
let s:blue = [ '#8470FF', 99 ]
let s:violet = [ '#eeccff', 177 ]
let s:plum = [ '#d7afff', 183 ]
let s:red = [ '#ff0000', 196 ]
let s:green = ['#5faf00', 70 ]
let s:warmpurple = [ '#DA10AC', 165 ]

function! Color(group, ...)
  let gui = 'hi ' . a:group
  let tui = gui

  if len(a:1)>0
    let gui .= ' guifg=' . a:1[0]
    let tui .= ' ctermfg=' . a:1[1]
  endif

  if a:0>1 && len(a:2)>0
    let gui .= ' guibg=' . a:2[0]
    let tui .= ' ctermbg=' .  a:2[1]
  endif

  if a:0 >= 3 && strlen(a:3)
    let gui .= ' gui=' . a:3
    let tui .= ' cterm=' . a:3
  endif

  execute gui
  execute tui
endfunction

call Color('Type', s:pink)
call Color('Statement', s:hotpink)
call Color('Special', s:steelblue)
