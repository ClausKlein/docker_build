#!/bin/sh

set -u
set -e
set -x

docker build -f ./Dockerfile --tag=devcontainer:latest .
docker run -it --rm devcontainer:latest
docker create --name Hello devcontainer:latest
docker cp Hello:/home/app/stagedir.tar.gz Hello-ubuntu-v20.04.tgz
docker rm -f Hello

