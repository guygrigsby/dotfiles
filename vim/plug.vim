if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'avakhov/vim-yaml'
Plug 'bling/vim-airline'
Plug 'cespare/vim-toml', 
      \ { 'for': 'toml' }
Plug 'ctrlpvim/ctrlp.vim'
Plug 'ekalinin/Dockerfile.vim', 
      \ { 'for': 'Dockerfile' }
Plug 'elzr/vim-json', 
      \ { 'for': 'json' }
Plug 'fatih/vim-go', 
      \ { 'do': ':GoInstallBinaries' }
Plug 'fatih/molokai'
Plug 'guygrigsby/auto-pairs'
Plug 'iamcco/markdown-preview.nvim', 
      \ { 'do': { -> mkdp#util#install() } }
Plug 'leafgarland/typescript-vim', 
      \ { 'for': 'typescript' }
Plug 'majutsushi/tagbar'
Plug 'mattn/webapi-vim'
Plug 'maxmellon/vim-jsx-pretty', 
      \ { 'for': 'jsx' }
Plug 'othree/yajs.vim', 
      \ { 'for': 'javascript' }
Plug 'prettier/vim-prettier', {
      \ 'do': 'yarn install',
      \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }
Plug 'ludovicchabant/vim-gutentags'
Plug 'rking/ag.vim'
Plug 'rust-lang/rust.vim', 
      \ { 'for': 'rust' }
Plug 'skywind3000/asyncrun.vim'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'Valloric/YouCompleteMe', { 
      \ 'do' : '~/.vim/plugged/YouCompleteMe/install.py --clangd-completer --rust-completer  --go-completer' }
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/indentpython.vim', 
      \ { 'for': 'python' } 
Plug 'xolox/vim-misc'
Plug 'xolox/vim-notes'
call plug#end()

" Install missing plugins on vim open
autocmd VimEnter *
      \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
      \|   PlugInstall --sync | q
      \| endif


