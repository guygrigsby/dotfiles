#!/bin/zsh
#
export PATH=/usr/local/bin:$HOME/scripts:$GOPATH/bin:/usr/local/go/bin:$HOME/lib:$HOME/scripts:$PATH
export PATH=${0:A:h}/bin:$PATH
#export GROOVY_HOME=/usr/local/opt/groovy/libexec
export PATH=$PATH:$HOME/.cargo/bin
#export PATH="/usr/local/opt/icu4c/bin:$PATH"
#export PATH="/usr/local/opt/gradle@6/bin:$PATH"
export PATH="/usr/local/opt/go@1.17/bin:$PATH"
export PATH="$HOME/go/src/github.com/hashicorp/cloud-makefiles/bin:/usr/local/opt/go@1.17/bin:/Users/guygrigsby/go/src/github.com/hashicorp/cloud-sre/bin:/usr/local/opt/manual-install:$PATH"
export PATH="$HOME/Library/Python/3.8/bin:$PATH:$GOPATH/src/github.com/hashicorp/cloud-boundary-service/scripts:/opt/homebrew/bin"
