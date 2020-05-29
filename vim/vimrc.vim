function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py --clangd-completer --rust-completer --go-completer
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
Plug 'avakhov/vim-yaml', { 'for': 'yaml' }
Plug 'bling/vim-airline'
Plug 'cespare/vim-toml', { 'for': 'toml' }
Plug 'ekalinin/Dockerfile.vim', 
      \ { 'for': 'Dockerfile' }
Plug 'elzr/vim-json', 
      \ { 'for': 'json' }
Plug 'fatih/vim-go', 
      \ { 'do': ':GoInstallBinaries' }
Plug '$GG/vim-opine', { 'for': 'toml' }
Plug 'guygrigsby/vim-scratch'
Plug 'h1mesuke/vim-unittest'
Plug 'iamcco/markdown-preview.nvim', 
      \ { 'do': { -> mkdp#util#install() } }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'leafgarland/typescript-vim', 
      \ { 'for': 'typescript' }
Plug 'mattn/webapi-vim'
Plug 'maxmellon/vim-jsx-pretty', 
      \ { 'for': 'jsx' }
Plug 'mgedmin/python-imports.vim', { 'for': 'python' }
Plug 'neo4j-contrib/cypher-vim-syntax', { 'for': 'cypher' } 
Plug 'othree/yajs.vim', 
      \ { 'for': 'javascript' }
Plug 'prettier/vim-prettier', {
      \ 'do': 'yarn install',
      \ 'for': ['javascript', 'jsx', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }
Plug 'ludovicchabant/vim-gutentags'
Plug 'rking/ag.vim'
Plug 'rust-lang/rust.vim', 
      \ { 'for': 'rust' }
Plug 'skywind3000/asyncrun.vim'
Plug 'hashivim/vim-terraform', { 'for': 'terraform' }
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-scriptease'
Plug 'tpope/vim-dispatch'
Plug 'ycm-core/YouCompleteMe', { 'do': function('BuildYCM') }
Plug 'vim-scripts/applescript.vim', { 'for': 'applescript' }
Plug 'vim-scripts/indentpython.vim', 
      \ { 'for': 'python' } 
Plug 'xolox/vim-misc'
Plug 'xolox/vim-notes'


"--------------}}}}}}}}}}}} Plug
call plug#end()

nmap <leader>t :UnitTest <CR>
nmap <C-p> :Files <CR>
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
let g:prettier#exec_cmd_async = 1


" Install missing plugins on vim open
"autocmd VimEnter *
"      \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
"      \|   PlugInstall --sync | q
"      \| endif


filetype plugin indent on
syntax on

"{{{ magic setting for sane regex -----------------------
"nnoremap / /\v
"cnoremap %s %sm
"cnoremap \>s \>sm
"nnoremap :g/ :g/\v
"nnoremap :g// :g//
"}}} --------------------------------------------------------


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

" Shows the autocomplete menu above tab-bar
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch
" Use case insensitive search, except when using capital letters
"set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
" set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

"set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=0

"yank to system clipboard
set clipboard+=unnamed
" turn off preview pane for autocomplete
set completeopt-=preview
" }}}
let g:AutoPairs = {'(':')', '[':']', '{':'}',"`":"`", '```':'```', '"""':'"""', "'''":"'''"}

"gotags and tagbar {{{ ----------------------------------
"""
set tags=./tags,tags;$HOME
"
"
let g:tagbar_type_go = {
      \ 'ctagstype' : 'go',
      \ 'kinds'     : [
      \ 'p:package',
      \ 'i:imports:1',
      \ 'c:constants',
      \ 'v:variables',
      \ 't:types',
      \ 'n:interfaces',
      \ 'w:fields',
      \ 'e:embedded',
      \ 'm:methods',
      \ 'r:constructor',
      \ 'f:functions'
      \ ],
      \ 'sro' : '.',
      \ 'kind2scope' : {
      \ 't' : 'ctype',
      \ 'n' : 'ntype'
      \ },
      \ 'scope2kind' : {
      \ 'ctype' : 't',
      \ 'ntype' : 'n'
      \ },
      \ 'ctagsbin'  : 'gotags',
      \ 'ctagsargs' : '-sort -silent'
      \ }
" }}}
"
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
"let g:ycm_global_ycm_extra_conf = '~/.global_extra_conf.py'
" }}} -----------------------------------------------------------
" Airline {{{ ---------------------------------------------------
"let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='dark'
let g:airline_solarized_bg='dark'
" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

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
