#!/bin/bash

MAP_SIZE=64
#SEED="--seed 1540994495"

if [ "$(uname)" == "Darwin" ]; then
  HALITE=./halite-osx
else
  HALITE=./halite-linux
fi

mkdir -p replays

BOTS=()
BOTS+=("./MyBot.jl")
BOTS+=("./MyBot.jl")
BOTS+=("./MyBot.jl")
BOTS+=("./MyBot.jl")

$HALITE $SEED --replay-directory replays/ -vvv --width $MAP_SIZE --height $MAP_SIZE "${BOTS[@]}"
