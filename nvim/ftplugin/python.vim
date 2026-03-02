set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79
set autoindent

nmap <leader>r :! clear && python % <CR>
autocmd BufRead,BufWritePre *.py :ImportName<CR>
