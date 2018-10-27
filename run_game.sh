#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
  HALITE=./halite-osx
else
  HALITE=./halite-linux
fi

mkdir -p replays

$HALITE --no-timeout --replay-directory replays/ -vvv --width 32 --height 32 "./MyBot.jl" "./MyBot.jl"
