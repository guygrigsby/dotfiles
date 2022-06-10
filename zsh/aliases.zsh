alias gclum='git checkout main && git pull upstream main'
alias gclom='git checkout main && git pull origin main'
alias glom='git pull origin main'
alias rup='git remote rename origin upstream'
alias gss='git status -s'
alias gdo='git diff origin/main'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'

alias ls='ls -G --color=auto'
alias l='ls -lG --color=auto'
alias ll='ls -lah --color=auto'

alias p='pwd'

alias k='kubectl'
alias kp='kubectl get po -o wide'
alias kl='kubectl logs -f'
alias kn='kubectl get no'
alias kg='kubectl get -o yaml'
alias kd='kubectl describe'
alias kdel='kubectl delete po'

alias tmp='cd ~/go/src/tmp'

alias hc='cd ~/go/src/github.com/hashicorp'
alias gg='cd ~/go/src/github.com/guygrigsby'
alias gome=' cd ~/go/src'

alias vim=nvim
alias vi=nvim
alias vrc="nvim $DOTFILES/vim"
alias zrc="nvim $DOTFILES/zsh; echo 'sourcing ~/.zshrc' && exec zsh"
alias lrc="nvim ~/.localrc/env.zsh; echo 'sourcing ~/.localrc/env.zsh' && exec zsh"
alias .z='. ~/.zshrc'
alias .l='. ~/.localrc/env.zsh'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias nuget="mono /usr/local/bin/nuget.exe"
alias pip=pip3

alias door='doormat login && eval $(doormat aws export --account pedp_remote_dev)'
alias up='hcloud hcp dev run'
alias bprox='hcloud hcp dev connect 9200:boundary-d16a8388-a44f-4343-a9e0-7ed4ada4d603.boundary-controller:api'
