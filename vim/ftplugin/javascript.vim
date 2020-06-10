"-----------taken from https://github.com/igemnace/vim-config/blob/master/cfg/after/ftplugin/javascript.vim ---------{{{
" make Vim recognize ES6 import statements
let &l:include = 'from\|require'

" make Vim use ES6 export statements as define statements
let &l:define = '\v(export\s+(default\s+)?)?(var|let|const|(async\s+)?function|class)|export\s+'
"-----------------------}}}
"
set shiftwidth=2
set tabstop=2
set expandtab

" Fix files with prettier, and then ESLint.
let g:ale_set_highlights = 1
let g:ale_linters = {'javascript': ['prettier', 'eslint']}
let g:ale_fixers = {'javascript': ['prettier', 'eslint']}
let g:ale_javascript_prettier_options = '--single-quote --trailing-comma all'
let g:ale_fix_on_save = 1

nnoremap <leader>r :term node % <CR>

"autocmd BufWritePre *.js :normal gg=G``
" FORMATTERS
