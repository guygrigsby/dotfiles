"
set shiftwidth=2
set tabstop=2
set expandtab

" Fix files with prettier, and then ESLint.
"
autocmd FileType qf setlocal wrap
let g:ale_fixers = {
      \   'javascript': ['prettier', 'remove_trailing_lines', 'trim_whitespace'],
      \   'css': ['prettier'],
      \   'html': ['prettier'],
      \}
let g:ale_linters = {
      \ 'javascript': ['eslint'],
      \}
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_options = '--single-quote --trailing-comma all --no-semi'
let g:ale_sign_style_error = '>>'
let g:ale_sign_style_warning = '--'
let g:ale_set_highlights = 1
let g:ale_set_loclist = 1
let g:ale_set_quickfix = 1

nnoremap <leader>r :term node % <CR>

let g:ycm_autoclose_preview_window_after_completion = 1

"autocmd BufWritePre *.js :normal gg=G``
" FORMATTERS
