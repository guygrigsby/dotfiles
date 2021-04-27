#!/bin/zsh

# vi mode
bindkey -v
export KEYTIMEOUT=1
bindkey '^P' up-history
bindkey '^N' down-history

ulimit -n 4096

##############################################################################
# History Configuration
##############################################################################
HISTFILE=~/.zsh_history     #Where to save history to disk
HISTSIZE=999999999
SAVEHIST=$HISTSIZE           #Number of history entries to save to disk
setopt    APPEND_HISTORY     #Append history to the history file (no overwriting)
setopt    SHARE_HISTORY      #Share history across terminals
setopt    INC_APPEND_HISTORY  #Immediately append to the history file, not just when a term is killed

setopt 	  HIST_IGNORE_ALL_DUPS
