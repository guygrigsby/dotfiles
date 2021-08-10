function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py --clangd-completer --rust-completer --go-completer --js-completer
  endif
endfunction

"------------{{{ Plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

autocmd BufNewFile,BufRead zsh_plugins.txt set filetype=zsh

call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go', {
      \ 'do': ':GoInstallBinaries',
      \ 'for': ['go', 'markdown' ]}
Plug '$GG/vim-opine', { 'for': 'toml' }
Plug 'guygrigsby/piccolo', { 'branch': 'main' }
Plug 'guygrigsby/vim-scratch', { 'branch': 'main' }
Plug 'iamcco/markdown-preview.nvim',
      \ { 'do': { -> mkdp#util#install() } }
Plug 'ludovicchabant/vim-gutentags'
Plug 'mattn/webapi-vim'
Plug 'mattn/emmet-vim'
Plug 'mattn/pastebin-vim'
Plug 'moll/vim-node'
"--------------}}}}}}}}}}}} Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
"--------------}}}}}}}}}}}} Telescope
Plug 'OmniSharp/omnisharp-vim'
Plug 'pangloss/vim-javascript'
Plug 'prettier/vim-prettier'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'preservim/nerdtree'
Plug 'mileszs/ack.vim'
Plug 'rust-lang/rust.vim',
      \ { 'for': 'rust' }
Plug 'skywind3000/asyncrun.vim'
Plug 'stevearc/vim-arduino'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'w0rp/ale'
Plug 'ycm-core/YouCompleteMe'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-notes'


"--------------}}}}}}}}}}}} Plug
call plug#end()
filetype plugin indent on
set background=dark
syntax on
set spell spelllang=en_us

let gt='$HOME/dotfiles/vim/gutentags.vim'



nmap <leader>t :UnitTest <CR>
nnoremap <C-p> <cmd>lua require('telescope.builtin').find_files()<cr>
"nmap <C-p> :Files <CR>
"let g:user_emmet_leader_key='<C-Z>,'

" Install missing plugins on vim open
"autocmd VimEnter *
"      \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
"      \|   PlugInstall --sync | q
"      \| endif
"
" terminal
let termwinsize = 10*0
" ag.vim is deprecated
let g:ackprg = 'ag --vimgrep --smart-case'
cnoreabbrev ag Ack
cnoreabbrev aG Ack
cnoreabbrev Ag Ack
cnoreabbrev AG Ack
" Open Nerdtree on start if a directory is chosen
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | wincmd w | endif
" NERDtree behaviour :h NERDTreeCustomOpenArgs
let g:NERDTreeCustomOpenArgs = {'file': {'reuse': 'all', 'where': 'p'}, 'dir': {}}
" if NERDtree is the only split open, close vim
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeShowBookmarks=1
" prevent crashing with NERDtree and Plug
let g:plug_window = 'noautocmd vertical topleft new'

"{{{ magic setting for sane regex -----------------------
"nnoremap / /\v
"cnoremap %s %sm
"cnoremap \>s \>sm
"nnoremap :g/ :g/\v
"nnoremap :g// :g//
"}}} --------------------------------------------------------
"
"
" ale
let g:ale_fixers = {
      \   '*'         : ['remove_trailing_lines', 'trim_whitespace'],
      \   'javascript': ['prettier'],
      \   'css': ['prettier'],
      \   'c': ['prettier'],
      \   'ino': ['prettier']
      \}
let g:ale_linters = {
      \ 'javascript': ['eslint'],
      \ 'go'        : ['golangci-lint'],
      \ 'cs'        : ['OmniSharp']
      \}
let g:ale_go_golangci_lint_options = '--fast'
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_options = '--single-quote --trailing-comma all --no-semi'
let g:ale_sign_style_error = '>>'
let g:ale_sign_style_warning = '--'
let g:ale_set_highlights = 1
let g:ale_set_loclist = 0
"let g:ale_set_quickfix = 1



nnoremap <leader>f gg=G``
nnoremap <C-L> :nohl<CR><C-L>

" Map \- and \+ to resize window
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>

nnoremap <silent> Q <nop>
"Folding
set foldmethod=indent
set foldlevel=99
set encoding=utf-8
"
" Correct RGB escape codes for vim inside tmux
if !has('nvim') && $TERM ==# 'screen-256color'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors
colorscheme piccolo

" Turn off swap files
set noswapfile

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Autoload files when changed
set autoread
" save on buffer change
"set autowriteall

set wildmenu
set showcmd
set hlsearch
set backspace=indent,eol,start
set autoindent
set nostartofline
set ruler
set laststatus=2
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
"set statusline+=%N%t%=(%y%V)
set confirm
set novisualbell
set mouse=
"set cmdheight=2
set number
set notimeout ttimeout ttimeoutlen=0
"yank to system clipboard
set clipboard+=unnamed
" turn off preview pane for autocomplete
"set completeopt-=preview
" }}}

"gotags and tagbar {{{ ----------------------------------
"""
let gt='$HOME/dotfiles/vim/gutentags.vim'
if filereadable(gt)
  source gt
endif

source ~/.localrc/vim/local.vim

" misc {{{ -------------------------------
"
" Prevent Fugitive conflicts with editor config
let g:EditorConfig_exclude_patterns = ['fugitive://.\*']

" Notes dir
let g:notes_directories = ['~/Google Drive/notes']

"{{{ ---------------------------_YCM-----------------------------------------
"nnoremap <leader>gd :YcmCompleter GoToDeclaration<CR>
"nnoremap <leader>dv :leftabove vertical YcmCompleter GoTo<CR>
let g:ycm_goto_buffer_command="split"
let g:ycm_auto_trigger = 1
let g:ycm_python_interpreter_path = ''
let g:ycm_python_sys_path = []
let g:ycm_extra_conf_vim_data = [
      \  'g:ycm_python_interpreter_path',
      \  'g:ycm_python_sys_path'
      \]
let g:ycm_semantic_triggers = {
      \   'javascript': [ 're!\w{2}' ],
      \   'go': [ 're!\w{2}' ]
      \ }
"let g:ycm_global_ycm_extra_conf = '~/.global_extra_conf.py'
" }}} -----------------------------------------------------------
":hi ColorColumn ctermbg=0 guibg=#eee8d5
"
function! StartProf()
  :profile start profile.log
  :profile func *
  :profile file *
endfunction

function! StopProf()
  :profile pause
  :noautocmd qall!
endfunction

let g:scratch_author = "Guy J Grigsby <https://grigsby.dev>"

function! RunCommandInBuffer(cmd)
  redir => message
  silent execute a:cmd
  redir END
  if empty(message)
    echoerr "no output"
  else
    new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=message
  endif
endfunction

command! -nargs=+ -complete=command BuffList call RunCommandInBuffer(<q-args>)
function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction

function! EnderDrop()
  execute "normal! G\o\"vim: sw=2 ts=2 et\<Esc>"
endfunction<CR>

nnoremap <silent> <Leader>ed :call EnderDrop()<CR>
nnoremap <Leader>pp :make up <CR>
"vim: sw=2 ts=2 et
