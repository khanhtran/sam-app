#!/bin/bash

IMAGE=docker-codebuild:latest

function tmppasswd {
  TMPPASSWD=$(mktemp)
  cat /etc/passwd > "${TMPPASSWD}"
  echo $TMPPASSWD
}

function tmpgroup {
  TMPGROUP=$(mktemp)
  cat /etc/group > "${TMPGROUP}"
  echo $TMPGROUP
}

export PASSWD=$(tmppasswd)
export GROUP=$(tmpgroup)
trap "rm -f $PASSWD $GROUP" EXIT

exec docker run -it \
    --rm=true \
    --net=host \
    --volume=${PASSWD}:/etc/passwd:ro \
    --volume=${GROUP}:/etc/group:ro \
    --volume=/var/run/docker.sock:/var/run/docker.sock \
    --volume=${HOME}:${HOME} \
    --volume=/tmp/.X11-unix:/tmp/.X11-unix \
    $(for group in $(id -g); do echo "--group-add=${group}"; done) \
    --user=$(id -u):$(id -g) -i \
    $(test -t 2 && echo "-t") \
    --workdir=$(pwd) \
    -e DOCKER_URL=unix:///var/run/docker.sock \
    -e USER \
    -e DISPLAY \
    -e TZ=${TZ:-America/New_York} \
    ${IMAGE} "$@"
