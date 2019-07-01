filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'fatih/molokai'
Plugin 'scrooloose/nerdtree'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'guygrigsby/auto-pairs'
Plugin 'rking/ag.vim'
Plugin 'benekastah/neomake'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-obsession'
Plugin 'rizzatti/dash.vim'
Plugin 'avakhov/vim-yaml'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-notes'
Plugin 'Valloric/YouCompleteMe'
Plugin 'xavierchow/vim-swagger-preview'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'elzr/vim-json'
Plugin 'leafgarland/typescript-vim'
Plugin 'peitalin/vim-jsx-typescript'
Plugin 'prettier/vim-prettier'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'seeamkhan/robotframework-vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"
" colorscheme slate
colorscheme molokai

" Turn of swap files
set noswapfile

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible


" Enable syntax highlighting
syntax on

" spellcheck
set spell spelllang=en_us

" Autoload files when changed
set autoread
" save on buffer change
set autowriteall

" Shows the autocomplete menu above tab-bar
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch
" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

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
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=0

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>

"yank to system clipboard
set clipboard+=unnamed
" turn off preview pane for autocomplete
set completeopt-=preview


"------------------------------------------------------------
" Indentation options {{{1
"
" Indentation settings according to personal preference.

" Indentation settings for using 2 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
 
set shiftwidth=8
set softtabstop=8
set expandtab

" Indentation settings for using hard tabs for indent. Display tabs as
" two characters wide.
"set shiftwidth=2
"set tabstop=2
"
"
"Folding
set foldmethod=indent
set foldlevel=99

" The Silver Searcher
if executable('ag')
        " Use ag over grep
        set grepprg=ag\ --nogroup\ --nocolor

        " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
        let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

        " ag is fast enough that CtrlP doesn't need to cache
        let g:ctrlp_use_caching = 0
endif
" CTRLP fuzzy search within files
let g:ctrlp_cmd = 'CtrlPLastMode'
let g:ctrlp_extensions = ['line']
" CtrlP
let g:ctrlp_working_path_mode = 'rw'

"gotags and tagbar
"
set tags=./tags,tags;$HOME


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



"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings
"
" AutoPairs
let g:AutoPairsFlyMode = 0

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Map \- and \+ to resize window
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>


" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  elseif l:file =~# '^\f\+_test\.go$'
    call go#cmd#Test(0, 1)
  endif
endfunction

" Fugitive 
" open grep in quickfix window
" autocmd QuickFixCmdPost *grep* cwindow
" open log in quickfix window
" autocmd QuickFixCmdPost *log* cwindow

" VimGo
" For running goimports on save
let g:go_fmt_command ="goimports"
let g:go_term_enabled = 1
let g:go_term_mode = "split"

" Notes dir
:let g:notes_directories = ['~/Google Drive/notes']
" js

" autocmd BufWritePre *.go call go#lint#Errcheck()
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>ds <Plug>(go-def-split)
au FileType go nmap <Leader>db <Plug>(go-doc-browser-browser)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage).
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>s <Plug>(go-implements)
au FileType go nmap <Leader>gg <Plug>(go-import)
"au FileType go nmap <leader>rt <Plug>(go-run-tab)
au FileType go nmap <leader>gl <Plug>(go-metalinter)

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
" Python
au FileType json nmap <leader>f %!python -m json.tool
au FileType python nmap <leader>r :! clear && python % <CR>
let g:ycm_python_interpreter_path = ''
let g:ycm_python_sys_path = []
let g:ycm_extra_conf_vim_data = [
  \  'g:ycm_python_interpreter_path',
  \  'g:ycm_python_sys_path'
  \]
let g:ycm_global_ycm_extra_conf = '~/global_extra_conf.py'


au FileType robot nmap <leader>r :! clear && robot % <CR>

" Airline tab line
let g:airline#extensions#tabline#enabled = 1
:hi ColorColumn ctermbg=0 guibg=#eee8d5
"
" NO ARROWS
nnoremap <Up> <NOP>
nnoremap <Down> <NOP>
nnoremap <Left> <NOP>
nnoremap <Right> <NOP>
nnoremap Q <NOP>
" typescript
let g:typescript_compiler_binary = 'tsc'
let g:typescript_compiler_options = ''
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow
"------------------------------------------------------------
