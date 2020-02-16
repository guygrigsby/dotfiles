" Rust {{{
" 
nnoremap <leader>r :RustRun <CR>
let g:rustfmt_autosave = 1
let g:ycm_rust_src_path = $RUST_SRC_PATH
BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi
BufWritePost *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&" | redraw!
" }}}
