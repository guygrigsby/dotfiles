set et sw=4 ts=4
"au BufWritePre *.toml :normal gg=G
"
"set shiftwidth=2
"set tabstop=2
""if exists("*TOMLindent")
""  finish
""endif
""set indentexpr=GetTomlIndent()
"
"function! GetTomlIindent()
"  " Only load this indent file when no other was loaded yet.
"  "if exists("b:did_indent")
"  "  finish
"  "endif
"  "let b:did_indent = 1
"
"  if lnum == 0
"    return 0
"  endif
"
"  let prev_lineno = prevnonblank(lnum)
"  let ind = indent( prev_lineno ) 
"
"  let prev_text = prevnonblank( prev_lineno )
"  let first_char = strpart( prev_text, 0, 1 )
"  echo first_char
"  if first_char == "["
"    let ind = ind + shiftwidth()
"    return ind
"  endfunction
