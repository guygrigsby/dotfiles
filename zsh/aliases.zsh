alias white='cd /Users/guygrigsby/go/src/github.com/guygrigsby/whitelist'

alias gclum='git checkout main && git pull upstream main'
alias gclom='git checkout main && git pull origin main'
alias glom='git pull origin main'
alias rup='git remote rename origin upstream'

alias gss='git status -s'

alias ls='ls -G --color=auto'
alias l='ls -lG --color=auto'
alias ll='ls -lah --color=auto'

alias k='kubectl'
alias kp='kubectl get po -o wide'
alias kl='kubectl logs -f'
alias kn='kubectl get no'
alias kg='kubectl get -o yaml'
alias kd='kubectl describe'
alias kdel='kubectl delete po'

alias tmp='cd ~/go/src/tmp'

alias gg='cd ~/go/src/github.com/guygrigsby'
alias gome=' cd ~/go/src'

alias vim=nvim
alias vi=nvim
alias vrc="nvim $DOTFILES/vim"
alias zrc="nvim $DOTFILES/zsh; echo 'sourcing ~/.zshrc' && exec zsh"
alias lrc="nvim ~/.localrc"
alias .z='. ~/.zshrc'
alias .l='. ~/.localrc'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias op='cd $GG/vim-opine && vim -O indent/toml.vim sample.toml'

alias nuget="mono /usr/local/bin/nuget.exe"
alias pip=pip3
