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

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."


