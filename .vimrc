filetype off                  " required
" Vundle --------------------------- {{{
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'fatih/molokai'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-fugitive'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'guygrigsby/auto-pairs'
Plugin 'rking/ag.vim'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-obsession'
Plugin 'avakhov/vim-yaml'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-notes'
Plugin 'Valloric/YouCompleteMe'
Plugin 'elzr/vim-json'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'ekalinin/Dockerfile.vim'
Plugin 'cespare/vim-toml'
Plugin 'mattn/webapi-vim'
Plugin 'prettier/vim-prettier'
Plugin 'rust-lang/rust.vim'
Plugin 'ludovicchabant/vim-gutentags'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Put your non-Plugin stuff after this line }}}

" AutoPairs
let g:AutoPairsFlyMode = 0
" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Map \- and \+ to resize window
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>



"Folding
set foldmethod=indent
set foldlevel=99
set encoding=utf-8
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
" autoformat js
" autocmd BufWritePost *.js AsyncRun -post=checktime ./node_modules/.bin/eslint --fix %


" }}}

" Arrows off {{{ ---------------------------------------------
" NO ARROWS
nnoremap <Up> <NOP>
nnoremap <Down> <NOP>
nnoremap <Left> <NOP>
nnoremap <Right> <NOP>
nnoremap Q <NOP>
" }}}
" The Silver Searcher {{{ --------------------------------
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
" }}}

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
" AutoPairs
let g:AutoPairsFlyMode = 0

" Prevent Fugitive conflicts with editor config
let g:EditorConfig_exclude_patterns = ['fugitive://.\*']

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Map \- and \+ to resize window
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>
" Python
autocmd FileType json nmap <leader>f %!python -m json.tool


" Notes dir
let g:notes_directories = ['~/Google Drive/notes']

" }}}
" js

" Python
au FileType json nmap <leader>f %!python -m json.tool
" YCM {{{
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
" }}}
" Airline {{{ ---------------------------------------------------
let g:airline#extensions#tabline#enabled = 1
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

:hi ColorColumn ctermbg=0 guibg=#eee8d5

