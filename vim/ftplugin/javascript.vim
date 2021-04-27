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
let g:prettier#config#single_quote = 'true'
let g:prettier#config#trailing_comma = 'all'

" filenames like *.xml, *.html, *.xhtml, ...
" These are the file extensions where this plugin is enabled.
"
let g:closetag_filenames = '*.*'
let g:closetag_xhtml_filetypes = 'html,javascript.js,jsx'

" filenames like *.xml, *.xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'

" filetypes like xml, xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filetypes = 'xhtml,jsx'

" integer value [0|1]
" This will make the list of non-closing tags case-sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
"
let g:closetag_emptyTags_caseSensitive = 1

" dict
" Disables auto-close if not in a "valid" region (based on filetype)
"
"let g:closetag_regions = {
"    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
"    \ 'javascript.jsx': 'jsxRegion',
"    \ 'javascript.js': 'jsxRegion',
"    \ }
"
" Shortcut for closing tags, default is '>'
"
let g:closetag_shortcut = '>'

" Add > at current position without closing the current tag, default is ''
"
"let g:closetag_close_shortcut = '<leader>>'


nnoremap <leader>r :term node % <CR>
nnoremap <leader>t :term yarn test --watchAll=false<CR>
nnoremap <leader>wd :term yarn wd<CR>

let g:ycm_autoclose_preview_window_after_completion = 1

"autocmd BufWritePre *.js :normal gg=G``
" FORMATTERS
