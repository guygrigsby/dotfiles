#!/bin/zsh

# dev
#export BOUNDARY_ADDR="https://5b489ba2-97ce-42d6-80dd-af3d17e401a5.boundary.hcp.dev"
export BOUNDARY_ADDR="http://localhost:9200"
export GOLANG_PROTOBUF_REGISTRATION_CONFLICT=warn
export ICLOUD_DIR=$HOME/Library/Mobile\ Documents/com~apple~CloudDocs
export NVM_DIR="$HOME/.nvm"
export GOPRIVATE=github.com/hashicorp
export GOFLAGS="-tags=e2e,smoke_test"
export HC=$HOME/go/src/github.com/hashicorp
# use 1password ssh agent. This allows direct access to ssh keys stored in 1password private vault.
export SSH_AUTH_SOCK=~/.1password/agent.sock
export HOMEBREW_NO_AUTO_UPDATE=1
