# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/ggrisb/.oh-my-zsh

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
plugins=(git)

source $ZSH/oh-my-zsh.sh


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

export GOPATH=/Users/ggrisb/go
export PATH=$PATH:$HOME/scripts:$GOPATH/bin:/usr/local/bin
export HOMEBREW_GITHUB_API_TOKEN=2ffbd838625f647652f801bc1aac3e4335f376f2
export GO15VENDOREXPERIMENT=1
set -o vi

alias jdk6='export JAVA_HOME=`/usr/libexec/java_home -v 1.6`'
alias jdk7='export JAVA_HOME=`/usr/libexec/java_home -v 1.7`'
alias jdk8='export JAVA_HOME=`/usr/libexec/java_home -v 1.8`'

#start the docker daemon
#eval "$(docker-machine env default)"

alias ls='ls -G'
alias ll='ls -lG'

alias k='kubectl'

alias coral='cd ~/go/src/github.comcast.com/viper-cog/coral'
alias ops='cd ~/go/src/github.comcast.com/viper-cog/coral-ops'
alias libcoral='cd ~/go/src/github.comcast.com/viper-cog/libcoral'
alias pillar='cd ~/go/src/github.comcast.com/viper-cog/pillar'
alias dock='eval "$(docker-machine env dev)"'
alias libmpegts='cd ~/go/src/github.comcast.com/viper-cog/libmpegts'
alias codec='cd ~/go/src/github.comcast.com/viper-cog/codec'
alias vip='cd ~/go/src/github.comcast.com/viper-cog'
alias gots='cd ~/go/src/github.com/comcast/gots'
alias tmp='cd ~/go/src/tmp'

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#PS1="\u@\h:\j:\w:\$(__git_ps1 "%s")"

