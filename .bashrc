source ~/.bash_mods/git-completion.bash
source ~/.bash_mods/git-prompt.sh

export GOPATH=/Users/ggrisb/go
export PATH=$PATH:$HOME/scripts:$GOPATH/bin
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

unset HISTFILESIZE
export HISTCONTROL=ignoredups  # no duplicate entries
export HISTSIZE=10000000                   # big big history
export HISTFILESIZE=10000000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# best prompt ... ever
BLACK="\[\033[0;30m\]"
DARK_GRAY="\[\033[1;30m\]"
LIGHT_GRAY="\[\033[0;37m\]"
BLUE="\[\033[0;34m\]"
LIGHT_BLUE="\[\033[1;34m\]"
GREEN="\[\033[0;32m\]"
LIGHT_GREEN="\[\033[1;32m\]"
CYAN="\[\033[0;36m\]"
LIGHT_CYAN="\[\033[1;36m\]"
RED="\[\033[0;31m\]"
LIGHT_RED="\[\033[1;31m\]"
PURPLE="\[\033[0;35m\]"
LIGHT_PURPLE="\[\033[1;35m\]"
BROWN="\[\033[0;33m\]"
YELLOW="\[\033[1;33m\]"
WHITE="\[\033[1;37m\]"
DEFAULT_COLOR="\[\033[00m\]"

#PS1="$PURPLE($DEFAULT_COLOR\u@\h$PURPLE)-($DEFAULT_COLOR\j$PURPLE)-($DEFAULT_COLOR\w$PURPLE)-($DEFAULT_COLOR\$(__git_ps1 "%s")$PURPLE)-> $DEFAULT_COLOR"
PS1="\u@\h:\j:\w:\$(__git_ps1 "%s")"

#PS1="\u$YELLOW@$DEFAULT_COLOR\h:$PURPLE\w $GREEN\$(__git_ps1)$DEFAULT_COLOR\$ "

# This is Reedells PS1
#PS1="\`if [ \$? = 0 ];
#  then
#                echo -en '$GREEN--($LIGHT_CYAN\u$YELLOW@$LIGHT_CYAN\h$GREEN)--($YELLOW\w$GREEN)--($PURPLE'; __git_ps1 "%s"; echo -n '$GREEN)-- :)\n--\$$DEFAULT_COLOR ';
#    else
#                echo -en '$LIGHT_RED--($LIGHT_CYAN\u$YELLOW@$LIGHT_CYAN\h$LIGHT_RED)--($YELLOW\w$LIGHT_RED)--($PURPLE'; __git_ps1 "%s"; echo -n '$LIGHT_RED)-- :         (\n--\$$DEFAULT_COLOR ';
#                fi; \`"

# added by travis gem
[ -f /Users/ggrisb/.travis/travis.sh ] && source /Users/ggrisb/.travis/travis.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
