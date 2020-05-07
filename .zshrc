#zmodload zsh/zprof
autoload -U compinit -X && compinit -X

source <(antibody init)
antibody bundle < ~/.zsh/zsh_plugins.txt
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"
# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(
#  aws
#  git 
#  zsh-completions
#  zsh-kubectl-prompt
#  helm
#  alias-tips
#  gcloud
#)
autoload -U colors; colors

PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+=' %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}) "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

ZSH_THEME_GIT_PROMPT_CACHE="true"

#source $ZSH/oh-my-zsh.sh
#source $ZSH/custom/plugins/zsh-kubectl-prompt/kubectl.zsh
RPROMPT='%{$fg[cyan]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

#
export SCRIPTS="$HOME/scripts"
export DOTFILES="$HOME/dotfiles"

if [ -f "$DOTFILES/zsh/git.zsh" ]; then source $DOTFILES/zsh/git.zsh; fi
if [ -f "$SCRIPTS/env.sh" ]; then source $SCRIPTS/env.sh; fi
if [ -f "$SCRIPTS/secrets.sh" ]; then source $SCRIPTS/secrets.sh; fi
if [ -f "$SCRIPTS/funcs.sh" ]; then source $SCRIPTS/funcs.sh; fi
# Rust
if [ -f "$HOME/.cargo/env" ]; then source $HOME/.cargo/env; fi
# Python pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

export EDITOR=vim
export GOPATH=$HOME/go
export PATH=/usr/local/bin:$PATH:$SCRIPTS:$GOPATH/bin:/usr/local/go/bin:$HOME/lib
export GO111MODULE=on
export GG=$GOPATH/src/github.com/guygrigsby
# vi mode
bindkey -v
bindkey '^[[Z' reverse-menu-complete

alias gclum='git checkout master && git pull upstream master'
alias gclom='git checkout master && git pull origin master'
alias glom='git pull origin master'
alias rup='git remote rename origin upstream'

alias ls='ls -G'
alias l='ls -lG'
alias ll='ls -lah'

alias k='kubectl'
alias kp='kubectl get po -o wide'
alias kn='kubectl get no'
alias kg='kubectl get -o yaml'
alias kd='kubectl describe'
alias kdel='kubectl delete po'

alias tmp='cd ~/go/src/tmp'

alias gg='cd ~/go/src/github.com/guygrigsby'
alias gome=' cd ~/go/src'

alias vrc="vim $DOTFILES/vim/vimrc.vim"
alias vcfg='vim ~/dotfiles/vim'
alias zrc='vim ~/.zshrc; echo "sourcing ~/.zshrc" && . ~/.zshrc'
alias .z='. ~/.zshrc'
alias .s=". $SCRIPTS/secrets.sh"
alias .e=". $SCRIPTS/env.sh"
alias .f=". $SCRIPTS/funcs.sh"

export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# added by travis gem
[ -f /Users/ggrigs200/.travis/travis.sh ] && source /Users/ggrigs200/.travis/travis.sh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/guy/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/guy/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/guy/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/guy/google-cloud-sdk/completion.zsh.inc'; fi

#zprof
