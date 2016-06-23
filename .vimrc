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
Plugin 'blueyed/vim-diminactive'
Plugin 'tpope/vim-fugitive'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'rking/ag.vim'
Plugin 'benekastah/neomake'
Plugin 'nsf/gocode', {'rtp': 'vim/'}
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-obsession'

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

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible


" Enable syntax highlighting
syntax on

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

set mouse=v

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=0
 
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

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
        nnoremap <C-L> :nohl<CR><C-L>

" neovim
if has('nvim')
        " neovim map <ESC> to exit insert mode in terminal
        tnoremap <Esc> <C-\><C-n>
endif

set diffopt+=vertical

" VimGo
" For running goimports on save
let g:go_fmt_command ="goimports"
let g:go_term_enabled = 1
let g:go_term_mode = "split"
au FileType go nmap <Leader>dv <Plug>(go-def-vertical)
au FileType go nmap <Leader>ds <Plug>(go-def-split)
au FileType go nmap <Leader>db <Plug>(go-doc-browser-browser)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <leader>r <Plug>(go-run-split)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage).
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>s <Plug>(go-implements)
au FileType go nmap <Leader>gg <Plug>(go-import)
au FileType go nmap <leader>rt <Plug>(go-run-tab)
" Airline tab line
let g:airline#extensions#tabline#enabled = 1
:hi ColorColumn ctermbg=0 guibg=#eee8d5
let g:diminactive_use_colorcolumn = 1
"let g:diminactive_use_syntax = 1
" NO ARROWS
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
noremap Q <NOP>
"------------------------------------------------------------
