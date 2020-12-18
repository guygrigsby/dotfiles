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
let s:pink = [ '#d7005f', 161 ]
let s:steelblue = [ '#5fd7ff', 81 ]
let s:blue = [ '#8470FF', 99 ]
let s:violet = [ '#eeccff', 177 ]
let s:plum = [ '#d7afff', 183 ]
let s:red = [ '#ff0000', 196 ]
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
call Color('Normal', s:lightgrey, s:black)
call Color('CursorLine', s:none, s:black)
call Color('Keyword', s:hotpink)
"hi CursorLine               ctermbg=234   cterm=none
hi CursorLineNr ctermfg=208               cterm=none
call Color('Boolean', s:mediumpurple)
hi Character       ctermfg=144
call Color('Number', s:mediumpurple)
call Color('String', s:plum)
call Color('Float', s:warmpurple)
call Color('Conditional', s:steelblue, s:black, 'bold')
call Color('Constant', s:mediumpurple, s:black, 'bold')
hi Cursor          ctermfg=16  ctermbg=253
hi Debug           ctermfg=225               cterm=bold
call Color('Define', s:steelblue, s:none)
hi Delimiter       ctermfg=241

call Color('DiffAdd', s:black, s:plum)
call Color('DiffDelete', s:darkpurple, s:lightgrey)
call Color('DiffChange', s:ultrablack, s:lightgrey)
call Color('DiffText', s:grey, s:lightgrey)

call Color('Directory', s:purple, s:black, 'bold')
call Color('Error', s:lightpink, s:ultrablack)
hi ErrorMsg        ctermfg=199 ctermbg=16    cterm=bold
hi Exception       ctermfg=123               cterm=bold
hi FoldColumn      ctermfg=67  ctermbg=16
hi Folded          ctermfg=67  ctermbg=16
call Color('Function', s:purple)
call Color('Identifier', s:hotpink)
hi Ignore          ctermfg=244 ctermbg=232
hi IncSearch       ctermfg=193 ctermbg=16

call Color('keywork', s:verypurple, s:none, 'bold')
call Color('Label', s:verypurple)
call Color('Macro', s:white)
call Color('SpecialKey', s:teal)

hi MatchParen      ctermfg=233  ctermbg=208 cterm=bold
call Color('ModeMsg', s:hotpink)
call Color('MoreMsg', s:hotpink)
hi Operator        ctermfg=69

" complete menu
call Color('Pmenu', s:plum, s:black)
call Color('PmenuSel', s:darkpurple, s:lightgrey)
hi PmenuSbar                   ctermbg=232
hi PmenuThumb      ctermfg=81

hi PreCondit       ctermfg=123               cterm=bold
hi PreProc         ctermfg=123
hi Question        ctermfg=81
call Color('Repeat', s:hotpink)
call Color('Search', s:black, s:lightpink, 'bold')
" marks column
hi SignColumn      ctermfg=123 ctermbg=235
hi SpecialChar     ctermfg=161               cterm=bold
hi SpecialComment  ctermfg=245               cterm=bold
call Color('Special', s:steelblue)
if has("spell")
  call Color('SpellBad', s:none, s:none, 'undercurl')
  hi SpellCap                ctermbg=17
  hi SpellLocal              ctermbg=17
  hi SpellRare  ctermfg=none ctermbg=none  cterm=reverse
endif
  call Color('StatusLine', s:teal, s:none, 'undercurl')
  call Color('SpellBad', s:none, s:none, 'undercurl')
hi StatusLine      ctermfg=238 ctermbg=253
hi StatusLineNC    ctermfg=244 ctermbg=232
"hi StorageClass    ctermfg=104
"hi Structure       ctermfg=81
"hi Tag             ctermfg=161
"hi Title           ctermfg=166
"hi Todo            ctermfg=231 ctermbg=232   cterm=bold
"
call Color('TypeDef', s:steelblue, s:black, 'bold')
call Color('Type', s:steelblue)
call Color('Underline', s:plum, s:none, 'underline')
"
"hi VertSplit       ctermfg=244 ctermbg=232   cterm=bold
"hi VisualNOS                   ctermbg=238
"hi Visual                      ctermbg=235
"hi WarningMsg      ctermfg=231 ctermbg=238   cterm=bold
"hi WildMenu        ctermfg=81  ctermbg=16
call Color('Comment', s:grey)
hi CursorColumn                ctermbg=236
hi ColorColumn                 ctermbg=236

call Color('LineNr', s:grey, s:black)
hi NonText         ctermfg=59

hi Include         ctermfg=153

" Must be at the end, because of ctermbg=234 bug.
" https://groups.google.com/forum/#!msg/vim_dev/afPqwAFNdrU/nqh6tOM87QUJ
set background=dark
