# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

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
# ENABLE_CORRECTION="true"

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
  osx
  zsh-completions
  #zsh-kubectl-prompt
)
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh
source $ZSH/templates/zshrc.zsh-template

#source /Users/ggrigs200/scripts/env.sh
#source /Users/ggrigs200/scripts/secrets.bash

RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
#source ~/.bash_mods/git-completion.bash
#source ~/.bash_mods/git-prompt.sh
#
#
#
#
#Load NVM - node version manager
export NVM_DIR="${XDG_CONFIG_HOME/:-$HOME/.}nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

export EDITOR=/usr/local/bin/vim
export GOPATH=$HOME/go
export PATH=/usr/local/bin:$PATH:$HOME/scripts:$GOPATH/bin:
export PATH=$PATH:/usr/local/go/bin
export GO15VENDOREXPERIMENT=1
export GO111MODULE=on
# vi mode
bindkey -v


bindkey '^[[Z' reverse-menu-complete

alias jdk6='export JAVA_HOME=`/usr/libexec/java_home -v 1.6`'
alias jdk7='export JAVA_HOME=`/usr/libexec/java_home -v 1.7`'
alias jdk8='export JAVA_HOME=`/usr/libexec/java_home -v 1.8`'


alias ls='ls -G'
alias ll='ls -lG'

alias k='kubectl'
alias kp='kubectl get po -o wide'
alias kn='kubectl get no'
alias kl='kubectl logs -f'

alias coral='cd ~/go/src/github.comcast.com/viper-cog/coral'
alias ops='cd ~/go/src/github.comcast.com/viper-cog/coral-ops'
alias image='cd ~/go/src/github.comcast.com/viper-cog/image'
alias pillar='cd ~/go/src/github.comcast.com/viper-cog/pillar'
alias codec='cd ~/go/src/github.comcast.com/viper-cog/codec'
alias vip='cd ~/go/src/github.comcast.com/viper-cog'
alias nitro='cd ~/go/src/github.comcast.com/nitro/go-nitro'
alias nhelm='helm --tiller-namespace nitro'
alias gots='cd ~/go/src/github.com/Comcast/gots'
alias tmp='cd ~/go/src/tmp'
alias s8='cd ~/go/src/github.comcast.com/viper-cog/mod_super8'
alias veg='cd ~/go/src/github.comcast.com/viper-veg'
alias lane='cd ~/go/src/github.comcast.com/viper-veg/kube-configs'
alias core='cd ~/go/src/github.comcast.com/mpcore/mpcore'
alias norlin='cd ~/go/src/github.comcast.com/viper-veg/norlin'
alias onecloud='cd ~/go/src/code.comcast.com/onecloud'


alias gg='cd ~/go/src/github.comcast.com/ggrigs200'

alias live=live.sh

alias stage='kubectl --context=stage'
alias scpoto='kubectl --context=potomac'
alias scnl='kubectl --context=northlake'
alias po='kubectl --context=rdei-potomac'
alias nl='kubectl --context=rdei-northlake'
alias qa='kubectl --context=rdei-canary'

alias dev='ssh guy@10.168.141.69'

alias eclim='/Users/ggrigs200/eclipse/java-2018-09/Eclipse.app/Contents/Eclipse/eclimd'
# Create a UUID
alias uuid="python -c 'import sys,uuid; sys.stdout.write(uuid.uuid4().hex)' | pbcopy && pbpaste && echo"
alias awslogin="/Users/ggrigs200/go/src/github.comcast.com/dh-pass-infra/aws-adfs-auth/bin/aws_adfs_auth"
alias totp='node /Users/ggrigs200/go/src/code.comcast.com/onecloud/puppeteer-ocp-login/node totp.js'
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#PS1="\u@\h:\j:\w:\$(__git_ps1 "%s")"
#



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ggrigs200/tmp/gcloud/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/ggrigs200/tmp/gcloud/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ggrigs200/tmp/gcloud/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/ggrigs200/tmp/gcloud/google-cloud-sdk/completion.zsh.inc'; fi

# added by travis gem
[ -f /Users/ggrigs200/.travis/travis.sh ] && source /Users/ggrigs200/.travis/travis.sh
