" Vim color File
" Author: Guy J Grigsby <https://grigsby.dev>
" License: MIT License
" Created: 21:06:35 05/10/2004
" Title:   piccolo.vim
" Summary: The Piccolo Theme
"
hi clear

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
let s:lightcyan = [ '#cff1ef', 230 ]
let s:lightgreen = [ '#cfdac8', 230 ]
let s:pink = [ '#d7005f', 161 ]
let s:steelblue = [ '#5fd7ff', 81 ]
let s:blue = [ '#8470FF', 99 ]
let s:violet = [ '#eeccff', 177 ]
let s:plum = [ '#d7afff', 183 ]
let s:red = [ '#ff0000', 196 ]
let s:warmpurple = [ '#DA10AC', 165 ]
let s:fuchsia = [ '#FF00FF', 13 ]

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

call Color('vimCommand', s:hotpink)
call Color('Normal', s:blue, s:black)
call Color('CursorLine', s:white, s:warmpurple)
call Color('CursorLineNr', s:white, s:warmpurple)
call Color('Keyword', s:hotpink)
call Color('Boolean', s:mediumpurple)
call Color('Character', s:mediumpurple)
call Color('Number', s:mediumpurple)
call Color('String', s:plum)
call Color('Float', s:warmpurple)
call Color('Conditional', s:steelblue, s:black, 'bold')
call Color('Constant', s:mediumpurple, s:black, 'bold')
call Color('Cursor', s:white, s:black)
call Color('Debug', s:black, s:steelblue, 'bold')
call Color('Define', s:steelblue, s:none)
call Color('Delimiter', s:violet)
call Color('DiffAdd', s:black, s:teal)
call Color('DiffDelete', s:white, s:red)
call Color('DiffChange', s:hotpink, s:ultrablack)
call Color('DiffText', s:white, s:black)

call Color('Directory', s:purple, s:black, 'bold')
call Color('Error', s:lightpink, s:black)
call Color('ErrorMsg', s:white, s:red, 'bold')
call Color('Exception', s:white, s:red, 'bold')
call Color('FoldColumn', s:white, s:darkpurple)
call Color('Folded', s:white, s:darkpurple)
call Color('Function', s:teal)
call Color('Identifier', s:warmpurple)
call Color('Ignore', s:black, s:teal)
call Color('Ignore', s:grey, s:purple)
call Color('Keyword', s:verypurple, s:none, 'bold')
call Color('Label', s:verypurple)
call Color('Macro', s:white)

call Color('MatchParen', s:red, s:none, 'bold')
call Color('MoreMsg', s:hotpink)
call Color('Operator', s:fuchsia)

" complete menu
call Color('Pmenu', s:plum, s:black)
call Color('PmenuSel', s:darkpurple, s:lightgrey)
call Color('PmenuSbar', s:pink, s:darkpurple)
call Color('PmenuThumb', s:hotpink)
call Color('PreCondit', s:hotpink, s:black, 'bold')
call Color('PreProc', s:hotpink)
call Color('Question', s:hotpink)
call Color('Repeat', s:hotpink)
call Color('Search', s:black, s:warmpurple, 'bold')
" marks column
call Color('SignColumn', s:hotpink, s:black)
call Color('Special', s:fuchsia)
call Color('SpecialChar', s:fuchsia, s:black, 'bold')
call Color('SpecialComment', s:fuchsia, s:black, 'bold')
call Color('SpecialKey', s:fuchsia)
if has("spell")
  call Color('SpellBad', s:none, s:none, 'undercurl')
  call Color('SpellCap', s:none, s:darkpurple)
  call Color('SpellLocal', s:none, s:darkpurple)
  call Color('SpellRare', s:none, s:none, 'reverse')
endif
call Color('Statement', s:warmpurple)
call Color('StatusLine', s:teal, s:none, 'undercurl')
call Color('StatusLineNC', s:white, s:teal)
call Color('StorageClass', s:steelblue)
call Color('Structure', s:warmpurple)
call Color('Tag', s:steelblue)
call Color('Title', s:hotpink)
call Color('Todo', s:white, s:black, 'bold')
call Color('Type', s:warmpurple, s:black)
call Color('TypeDef', s:steelblue, s:black, 'bold')
call Color('Underline', s:fuchsia, s:none, 'underline')
call Color('VertSplit', s:warmpurple, s:none, 'bold')
call Color('VisualNOS', s:black, s:grey)
call Color('Visual', s:black, s:grey)
call Color('WarningMsg', s:white, s:teal, 'bold')
call Color('WildMenu', s:white, s:darkpurple, 'bold')
call Color('Comment', s:grey)
call Color('CursorColumn', s:black, s:hotpink)
call Color('ColorColumn', s:black, s:warmpurple)
call Color('LineNr', s:grey, s:black)
call Color('NonText', s:verypurple)
call Color('Include', s:fuchsia, s:black, 'italic')

" Must be at the end, because of ctermbg=234 bug.
" https://groups.google.com/forum/#!msg/vim_dev/afPqwAFNdrU/nqh6tOM87QUJ
set background=dark
