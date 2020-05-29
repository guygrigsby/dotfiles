"-----------taken from https://github.com/igemnace/vim-config/blob/master/cfg/after/ftplugin/javascript.vim ---------{{{
" make Vim recognize ES6 import statements
let &l:include = 'from\|require'

" make Vim use ES6 export statements as define statements
let &l:define = '\v(export\s+(default\s+)?)?(var|let|const|(async\s+)?function|class)|export\s+'
"-----------------------}}}

set shiftwidth=2
set tabstop=2
set expandtab

"autocmd BufWritePre *.js :normal gg=G``
" FORMATTERS
setlocal formatprg=prettier
