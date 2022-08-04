#!/bin/zsh
#
export DOTFILES=$HOME/dotfiles

#Dotfiles this is where we are
# Maybe I should move these to Google Drive
curl -sfL git.io/antibody | sudo sh -s - -b /usr/local/bin
ln -s $DOTFILES/vim/vimrc.vim $HOME/.vimrc
ln -s $DOTFILES/git/gitignore.link $HOME/.gitignore
ln -s $DOTFILES/git/config $HOME/.gitconfig
ln -s $DOTFILES/zsh/zshrc.link $HOME/.zshrc
ln -s $DOTFILES/git $HOME/.config/git
ln -s $DOTFILES/zsh $HOME/.zsh
ln -s $DOTFILES/vim/ftplugin $HOME/.vim/ftplugin
ln -s $DOTFILES/ag/ignore $HOME/.ignore
ln -s $DOTFILES/vim/plugin $HOME/.vim
ln -s $DOTFILES/vim/after $HOME/.vim
