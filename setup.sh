#!/bin/bash

#Dotfiles this is where we are
# Maybe I should move these to Google Drive
ln -s $HOME/dotfiles/vim/vimrc.vim $HOME/.vimrc
ln -s $HOME/dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/dotfiles/.gitignore $HOME/.gitignore
ln -s $HOME/dotfiles/.gitconfig $HOME/.gitconfig

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

# Brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#All the rest of the things
brew bundle
