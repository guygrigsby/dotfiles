# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
#ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git 
  zsh-completions
#  kube-ps1
  gcloud
  helm
)
autoload -U compinit -X && compinit -X

source $ZSH/oh-my-zsh.sh
source $ZSH/templates/zshrc.zsh-template
#source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
#
export SCRIPTS="$HOME/scripts"
export DOTFILES="$HOME/dotfiles"

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
# vi mode
bindkey -v
bindkey '^[[Z' reverse-menu-complete

alias gclum='git checkout master && git pull upstream master'
alias gclom='git checkout master && git pull origin master'
alias rup='git remote rename origin upstream'

alias ls='ls -G'
alias ll='ls -lG'

alias k='kubectl'
alias kp='kubectl get po -o wide'
alias kn='kubectl get no'
alias kl='kubectl logs -f'

alias tmp='cd ~/go/src/tmp'

alias gg='cd ~/go/src/github.com/guygrigsby'
alias gome=' cd ~/go/src'

alias vrc='vim ~/.vimrc'
alias zrc='vim ~/.zshrc'
alias .z='. ~/.zshrc'
alias .s=". $SCRIPTS/secrets.sh"
alias .e=". $SCRIPTS/env.sh"
alias .f=". $SCRIPTS/funcs.sh"

#PROMPT='$(kube_ps1)'$PROMPT

# Create a UUID
alias uuid="python -c 'import sys,uuid; sys.stdout.write(uuid.uuid4().hex)' | pbcopy && pbpaste && echo"
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# added by travis gem
[ -f /Users/ggrigs200/.travis/travis.sh ] && source /Users/ggrigs200/.travis/travis.sh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/guy/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/guy/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/guy/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/guy/google-cloud-sdk/completion.zsh.inc'; fi
