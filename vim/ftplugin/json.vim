set shiftwidth=2
set expandtab
let g:vim_json_conceal = 0
let g:vim_json_warnings = 1

let g:ale_set_highlights = 1
let g:ale_linters = {'json': ['prettier']}
let g:ale_fixers = {'json': ['prettier']}
let g:ale_fix_on_save = 1
"autocmd BufWritePre *.json :normal gg=G``
