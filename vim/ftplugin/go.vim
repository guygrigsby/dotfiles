function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  elseif l:file =~# '^\f\+_test\.go$'
    call go#cmd#Test(0, 1)
  endif
endfunction

nmap <Leader>dv <Plug>(go-def-vertical)
nmap <Leader>ds <Plug>(go-def-split)
nmap <Leader>db <Plug>(go-doc-browser-browser)
nmap <Leader>gd <Plug>(go-doc)
nmap <leader>t <Plug>(go-test)
nmap <Leader>gd <Plug>(go-doc)
nmap <Leader>s <Plug>(go-implements)
nmap <Leader>gg <Plug>(go-import)
nmap <leader>r <Plug>(go-run)
nmap <leader>gl <Plug>(go-metalinter)
nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

" ALE syntax checker
let g:ale_fix_on_save = 0

" For running goimports on save
let g:go_fmt_command ="goimports"
let g:go_fmt_options = {
      \ 'gofmt': '-s',
      \ 'goimports': '-local github.com/nytimes',
      \ }
let g:go_term_enabled = 0
let g:go_term_mode = "split"
let g:go_build_tags = "integration,example"
" GoMetaLinter settings
let g:go_metalinter_autosave = 0
let g:go_metalinter_command = "golangci-lint"
let g:go_list_type = 'quickfix'
let g:go_metalinter_enabled = ["govet", "golint", "wsl", "errcheck"]
let g:go_metalinter_autosave_enabled = ["govet", "golint"]
" }}}
