#!/bin/sh


set -xeuo pipefail
plugdir=$(cd -P "$(dirname "$0")/.." > /dev/null && pwd)
echo $plugdir
#cd "$plugdir"
#
#vim=$1
#vimdir="/tmp/vim-go-test/$vim-install"
#export GOPATH=$vimdir
#export PATH=${GOPATH}/bin:$PATH
#
#if [ ! -f "$vimdir/bin/vim" ]; then
#	echo "$vimdir/bin/vim doesn't exist; did you install it with the install-vim script?"
#	exit 1
#fi
#
#
#
