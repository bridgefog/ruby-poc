#!/bin/bash

set -e -x

apt-get update
apt-get autoremove -y
apt-get install -y build-essential subversion mercurial bzr git

docker pull ruby:2.2.0
docker pull jbenet/go-ipfs
cid=$(docker create jbenet/go-ipfs:latest)
docker cp "${cid}:/go/bin/ipfs" /tmp/
mv /tmp/ipfs /usr/bin/ipfs_from_docker
docker rm "${cid}" # TODO: double check this bit worked

git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile

# set up go dev env
curl -sS 'https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz' | tar -zxC /usr/local
echo 'export GOPATH=/root/code/go' >> /root/.profile
echo 'export PATH=$GOPATH/bin:$PATH:/usr/local/go/bin' >> /root/.profile
source /root/.profile

mkdir -p /root/code

go get -v -t github.com/jbenet/go-ipfs
go install -v github.com/jbenet/go-ipfs/cmd/ipfs
go get -v -t github.com/rtlong/ipfs-badge-object-hash
go install -v github.com/rtlong/ipfs-badge-object-hash

rbenv install 2.2.0
rbenv shell 2.2.0
gem install bundler
