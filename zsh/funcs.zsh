#!/bin/bash
function bs () {
	cat <<EOF > ./$1.sh
#!/usr/local/bin/bash

set -euo pipefail
EOF
vim ./$1.sh
}

function flop () {
	if [[ "$HOME" = "/Users/guy" ]]; then
	# Work is 17
		loc=17
	else
	#Home is 15
		loc=15
	fi
	ddcctl -d 1 -i $loc
}

function yolo () {
	if [ -n "$1" ]; then
		git commit -am "$1"
	else
		git commit -av
	fi
	git push

}

function decode_secrets () {

	for e in $(kubectl -n appcatalog-realdev get secret $1 -o json | jq -r '.data | to_entries[] | "\(.key)=\(.value|@base64d)"'); do
		echo $e
	done
}



# k get po -o json | jq -r '.items[].name | select(startswith("hook") )'
function kl () {
	pod_name=$(kubectl get po -o json | jq -r '.items[0].metadata.name | select(startswith('\"$1\"'))')
	if [ -n "$pod_name" ]; then

		kubectl logs -f $pod_name
	fi
}

function docker-cleanup () {

	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q) --force
}
function got () {

	pushd .
	cd $GOPATH/src/tmp/gen
	d=`date +%s`
	mkdir $d
	cd $d
	echo 'package main\n\nfunc main() {\n\tprintln("test")\n}' >> main.go
	echo 'package main\nimport "testing"\n\nfunc TestMain(t *testing.T) {\n}' >> main_test.go
	go mod init
	vim main_test.go main.go -O
}
function dock () {

	cp $HOME/necessities/goapp/Dockerfile .
	img=`pwd | rev | cut -f1 -d'/' - | rev`
	cat $HOME/necessities/goapp/Makefile | sed "s/imagename/$img/g" >> Makefile
}

function kswitch () {

	mkdir -p /usr/local/bin/kubectls/$1
	cd /usr/local/bin/kubectls/$1
	curl -LO "https://storage.googleapis.com/kubernetes-release/release/v$1/bin/darwin/amd64/kubectl"
	chmod +x kubectl
	cp kubectl /usr/local/bin/
	cd -
}
function smoosh () {
	local IFS=""
	echo "$*"
}
