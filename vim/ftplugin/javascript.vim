"-----------taken from https://github.com/igemnace/vim-config/blob/master/cfg/after/ftplugin/javascript.vim ---------{{{
" make Vim recognize ES6 import statements
let &l:include = 'from\|require'

" make Vim use ES6 export statements as define statements
let &l:define = '\v(export\s+(default\s+)?)?(var|let|const|(async\s+)?function|class)|export\s+'
"-----------------------}}}

set shiftwidth=2
set tabstop=2
set expandtab

au BufRead,BufWritePre *.js,css,jsx,html,scss :normal gg=G``
" FORMATTERS
au FileType javascript setlocal formatprg=prettier
au FileType javascript.jsx setlocal formatprg=prettier
au FileType typescript setlocal formatprg=prettier\ --parser\ typescript
au FileType html setlocal formatprg=js-beautify\ --type\ html
au FileType scss setlocal formatprg=prettier\ --parser\ css
au FileType css setlocal formatprg=prettier\ --parser\ css
