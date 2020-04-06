" Go {{{ --------------------------------------------
echom "Running ftplugin Go"
"
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
nmap <leader>r <Plug>(go-run)
nmap <leader>t <Plug>(go-test)
nmap <Leader>gd <Plug>(go-doc)
nmap <Leader>s <Plug>(go-implements)
nmap <Leader>gg <Plug>(go-import)
nmap <leader>rt <Plug>(go-run-split)
nmap <leader>gl <Plug>(go-metalinter)
nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

" For running goimports on save
let g:go_fmt_command ="goimports"
let g:go_term_enabled = 1
let g:go_term_mode = "split"
let g:go_test_timeout = '600s'
let g:go_build_tags = "integration,gostar,example,example"
" }}}

