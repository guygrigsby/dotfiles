set shiftwidth=2 
set tabstop=2
set expandtab
set autoindent

autocmd BufNewFile *.vim :CreateVimHeader <CR>

nnoremap <leader>r :source % <CR>
