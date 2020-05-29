alias gclum='git checkout master && git pull upstream master'
alias gclom='git checkout master && git pull origin master'
alias glom='git pull origin master'
alias rup='git remote rename origin upstream'

alias ls='ls -G'
alias l='ls -lG'
alias ll='ls -lah'

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

alias vrc="vim $DOTFILES/vim"
alias vcfg="vim $DOTFILES/vim'r"
alias zrc="vim $DOTFILES/zsh; echo 'sourcing ~/.zshrc' && . ~/.zshrc"
alias lrc="vim ~/.localrc"
alias .z='. ~/.zshrc'
alias .l='. ~/.localrc'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias op='cd $GG/vim-opine && vim -O indent/toml.vim sample.toml'
alias asl='cd ~/generalassembly'
alias gasly='cd ~/generalassembly'
