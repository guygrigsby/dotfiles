#!/bin/zsh
#
export DOTFILES=$HOME/dotfiles

#Dotfiles this is where we are
# Maybe I should move these to Google Drive
ln -s $DOTFILES/vim/vimrc.vim $HOME/.vimrc
ln -s $DOTFILES/git/gitignore.link $HOME/.gitignore
ln -s $DOTFILES/git/gitconfig.link $HOME/.gitconfig
ln -s $DOTFILES/zsh/zshrc.link $HOME/.zshrc
ln -s $DOTFILES/.zshrc $HOME/.zshrc
ln -s $DOTFILES/git $HOME/.config/git
ln -s $DOTFILES/zsh $HOME/.zsh
ln -s $DOTFILES/vim/ftplugin $HOME/.vim
ln -s $DOTFILES/ag/ignore $HOME/.ignore
ln -s $DOTFILES/vim/plugin $HOME/.vim
ln -s $DOTFILES/vim/after $HOME/.vim

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
