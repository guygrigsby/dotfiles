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
Plug 'itchyny/lightline.vim'
Plug 'dense-analysis/ale' "syntax error highlighting
Plug 'fatih/vim-go', {
      \ 'do': ':GoInstallBinaries',
      \ 'for': ['go', 'markdown' ]}
Plug '$GG/vim-opine', { 'for': 'toml' }
Plug 'guygrigsby/vim-scratch'
Plug 'iamcco/markdown-preview.nvim',
      \ { 'do': { -> mkdp#util#install() } }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mattn/webapi-vim'
Plug 'pangloss/vim-javascript'
Plug 'maxmellon/vim-jsx-pretty',
      \ { 'for': 'jsx' }
Plug 'preservim/nerdtree'
Plug 'ludovicchabant/vim-gutentags'
Plug 'rking/ag.vim'
Plug 'rust-lang/rust.vim',
      \ { 'for': 'rust' }
Plug 'skywind3000/asyncrun.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'ycm-core/YouCompleteMe', { 'do': function('BuildYCM') } "autocomplete
Plug 'xolox/vim-misc'
Plug 'xolox/vim-notes'


"--------------}}}}}}}}}}}} Plug
call plug#end()
filetype plugin indent on
syntax on

nmap <leader>t :UnitTest <CR>
nmap <C-p> :Files <CR>

" Install missing plugins on vim open
"autocmd VimEnter *
"      \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
"      \|   PlugInstall --sync | q
"      \| endif
"
" terminal
let termwinsize = 10*0

" Open Nerdtree on start if a directory is chosen
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | wincmd w | endif
" NERDtree behaviour :h NERDTreeCustomOpenArgs
let g:NERDTreeCustomOpenArgs = {'file': {'reuse': 'all', 'where': 'p'}, 'dir': {}}
" if NERDtree is the only split open, close vim
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
" prevent crashing with NERDtree and Plug
let g:plug_window = 'noautocmd vertical topleft new'


" lightline
let g:lightline = {
      \ 'colorscheme': 'molokai',
      \ }

" remove default '-- INSERT --' because it's in the line
set noshowmode

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
      \   'javascript': ['prettier']
      \}
let g:ale_linters = {
      \ 'javascript': ['eslint'],
      \ 'go'        : ['golangci-lint']
      \}
let g:ale_go_golangci_lint_options = '--fast'
let g:ale_fix_on_save = 1
let g:ale_sign_style_error = '>>'
let g:ale_sign_style_warning = '--'
let g:ale_set_highlights = 1
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1



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
" colorscheme slate
colorscheme custom-molokai

" Turn of swap files
set noswapfile

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" spellcheck
set spell spelllang=en_us
let s:spfile = $HOME . fnameescape('/Google Drive/vim/spell/en.utf-8.add')
if !empty(glob(s:spfile))
  set spellfile = s:spfile
endif


" Autoload files when changed
" set autoread
" save on buffer change
" set autowriteall

set wildmenu
set showcmd
set hlsearch
set backspace=indent,eol,start
set autoindent
set nostartofline
set ruler
"set laststatus=2
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
source $HOME/dotfiles/vim/gutentags.vim

" misc {{{ -------------------------------
"
" Prevent Fugitive conflicts with editor config
let g:EditorConfig_exclude_patterns = ['fugitive://.\*']

" Notes dir
let g:notes_directories = ['~/Google Drive/notes']

"{{{ ---------------------------_YCM-----------------------------------------
nnoremap <leader>gd :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>dv :leftabove vertical YcmCompleter GoTo<CR>
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
