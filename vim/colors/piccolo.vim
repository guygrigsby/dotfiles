" Vim color File
" Author: Guy J Grigsby <https://grigsby.dev>
" License: MIT License
" Created: 21:06:35 05/10/2004
" Title:   piccolo.vim
" Summary: The Piccolo Theme

let s:none = [ 'NONE', 'NONE' ]
let s:black = [ '#121212', 233 ]
let s:lightgray = [ '#d0d0d0', 252 ]
let s:gray = [ '#808080', 244 ]
let s:white = [ '#ffffff', 231 ]
let s:teal = [ '#00afd7', 38 ]
let s:hotpink = [ '#ff5fd7', 206 ]
let s:purple = [ '#8787d7', 104 ]
let s:darkpurple = [ '#9933ff', 128 ]
let s:lightpink = [ '#ffd7ff', 225 ]
let s:pink = [ '#d7005f', 161 ]
let s:steelblue = [ '#5fd7ff', 81 ]
let s:blue = [ '#8470FF', 99 ]
let s:violet = [ '#eeccff', 177 ]
let s:plum = [ '#d7afff', 183 ]
let s:red = [ '#ff0000', 196 ]

let s:warning = ['#5faf00', 70 ]

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


hi clear

call Color('Normal', s:lightgray, s:black)
call Color('CursorLine', s:none, s:black)
call Color('Keyword', s:hotpink)
hi CursorLine               ctermbg=234   cterm=none
hi CursorLineNr ctermfg=208               cterm=none
hi Boolean         ctermfg=135
hi Character       ctermfg=144
hi Number          ctermfg=135
hi String          ctermfg=244
hi Conditional     ctermfg=81               cterm=bold
hi Constant        ctermfg=135               cterm=bold
hi Cursor          ctermfg=16  ctermbg=253
hi Debug           ctermfg=225               cterm=bold
call Color('Define', s:steelblue, s:none)
hi Delimiter       ctermfg=241

hi DiffAdd                     ctermbg=24
hi DiffChange      ctermfg=181 ctermbg=239
hi DiffDelete      ctermfg=162 ctermbg=53
hi DiffText                    ctermbg=102 cterm=bold

hi Directory       ctermfg=123               cterm=bold
hi Error           ctermfg=219 ctermbg=89
hi ErrorMsg        ctermfg=199 ctermbg=16    cterm=bold
hi Exception       ctermfg=123               cterm=bold
hi Float           ctermfg=135
hi FoldColumn      ctermfg=67  ctermbg=16
hi Folded          ctermfg=67  ctermbg=16
hi Function        ctermfg=104
call Color('Identifier', s:hotpink)
hi Ignore          ctermfg=244 ctermbg=232
hi IncSearch       ctermfg=193 ctermbg=16

hi keyword         ctermfg=129               cterm=bold
hi Label           ctermfg=129               cterm=none
hi Macro           ctermfg=193
call Color('SpecialKey', s:teal)

hi MatchParen      ctermfg=233  ctermbg=208 cterm=bold
call Color('ModeMsg', s:hotpink)
call Color('MoreMsg', s:hotpink)
hi Operator        ctermfg=69

" complete menu
call Color('Pmenu', s:plum, s:black)
hi PmenuSel        ctermfg=255 ctermbg=242
hi PmenuSbar                   ctermbg=232
hi PmenuThumb      ctermfg=81

hi PreCondit       ctermfg=123               cterm=bold
hi PreProc         ctermfg=123
hi Question        ctermfg=81
hi Repeat          ctermfg=161               cterm=bold
call Color('Search', s:black, s:lightpink, 'bold')
" marks column
hi SignColumn      ctermfg=123 ctermbg=235
hi SpecialChar     ctermfg=161               cterm=bold
hi SpecialComment  ctermfg=245               cterm=bold
hi Special         ctermfg=81
if has("spell")
  call Color('SpellBad', s:warning, s:none, 'underline')
  hi SpellCap                ctermbg=17
  hi SpellLocal              ctermbg=17
  hi SpellRare  ctermfg=none ctermbg=none  cterm=reverse
endif
hi Statement       ctermfg=99               cterm=bold
hi StatusLine      ctermfg=238 ctermbg=253
hi StatusLineNC    ctermfg=244 ctermbg=232
hi StorageClass    ctermfg=104
hi Structure       ctermfg=81
hi Tag             ctermfg=161
hi Title           ctermfg=166
hi Todo            ctermfg=231 ctermbg=232   cterm=bold

hi Typedef         ctermfg=81                cterm=bold
hi Type            ctermfg=81                cterm=none
hi Underlined      ctermfg=244               cterm=underline

hi VertSplit       ctermfg=244 ctermbg=232   cterm=bold
hi VisualNOS                   ctermbg=238
hi Visual                      ctermbg=235
hi WarningMsg      ctermfg=231 ctermbg=238   cterm=bold
hi WildMenu        ctermfg=81  ctermbg=16

hi Comment         ctermfg=59
hi CursorColumn                ctermbg=236
hi ColorColumn                 ctermbg=236
hi LineNr          ctermfg=250 ctermbg=236
hi NonText         ctermfg=59

hi Include         ctermfg=153

" Must be at the end, because of ctermbg=234 bug.
" https://groups.google.com/forum/#!msg/vim_dev/afPqwAFNdrU/nqh6tOM87QUJ
set background=dark
