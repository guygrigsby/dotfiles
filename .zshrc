#!/bin/zsh
zmodload zsh/zprof

export GG=$GOPATH/src/github.com/guygrigsby
export EDITOR=vim

autoload -U colors; colors
#
export DOTFILES="$HOME/dotfiles"

# all of our zsh files
typeset -U config_files
config_files=($DOTFILES/*/*.zsh)

# load the path files
for file in ${(M)config_files:#*/path.zsh}; do
  source "$file"
done

autoload -U compinit -X && compinit -X

source <(antibody init)
antibody bundle < ~/.zsh/zsh_plugins.txt

# Rust
if [ -f "$HOME/.cargo/env" ]; then source $HOME/.cargo/env; fi

# load everything but the path and completion files
for file in ${${config_files:#*/path.zsh}:#*/completion.zsh}; do
  source "$file"
done
#
# load every completion after autocomplete loads
for file in ${(M)config_files:#*/completion.zsh}; do
  source "$file"
done

# vi mode
bindkey -v
bindkey '^[[Z' reverse-menu-complete

[ -f ~/.localrc ] && . ~/.localrc

zprof
