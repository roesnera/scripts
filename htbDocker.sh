#!/bin/bash

function buildAcReg() {
  docker build \
    -t "htb-academy-regular-parrot" \
    .
  exit 0
}

function runAcReg() {
  run htb-academy-regular-parrot
  exit 0
}

function run() {
  docker run \
    --rm \
    -d \
    --network host \
    --privileged \
    "$1"
  exit 0
}

function attach() {
  docker exec \
    -it \
    $1 \
    bash
}
