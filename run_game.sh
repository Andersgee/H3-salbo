#!/bin/bash

MAP_SIZE=32

if [ "$(uname)" == "Darwin" ]; then
  HALITE=./halite-osx
else
  HALITE=./halite-linux
fi

mkdir -p replays

BOTS=()
BOTS+=("./MyBot.jl")
BOTS+=("./MyBot.jl")
#BOTS+=("./MyBot.jl")
#BOTS+=("./MyBot.jl")

$HALITE --no-timeout --replay-directory replays/ -vvv --width $MAP_SIZE --height $MAP_SIZE "${BOTS[@]}"
