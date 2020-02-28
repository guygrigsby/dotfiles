#!/bin/bash

#Dotfiles
ln -s ./.vimrc $HOME
ln -s ./.zshrc $HOME
ln -s ./ftplugin $HOME/.vim
ln -s ./.gitignore $HOME
git config --global core.excludesfile '~/.gitignore'

# Env stuff
# sourced at this location
git clone git@github.com:guygrigsby/scripts.git $HOME/scripts
# Basics
git clone git@github.com:guygrigsby/necessities.git $HOME/necessities



# Go
mkdir -p $HOME/go
curl https://dl.google.com/go/go1.13.7.darwin-amd64.pkg -O
# user interventions required
open go1.13.7.darwin-amd64.pkg
# other versions https://golang.org/doc/install?download=go1.13.7.darwin-amd64.pkg#extra_versions

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Vundle
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim

# YCM
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer --go-completer --rust-completer
ln -s ./global_extra_conf.py $HOME

# Brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#All the rest of the things
brew bundle