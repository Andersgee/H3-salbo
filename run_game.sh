#!/bin/sh

if [ "$(uname)" == "Darwin" ]; then
  JULIA=julia
  HALITE=./halite-osx
else
  JULIA=~/dev/julia-1.0.1/bin/julia
  HALITE=./halite-linux
fi

mkdir -p replays

$HALITE --replay-directory replays/ -vvv --width 32 --height 32 "$JULIA MyBot.jl" "$JULIA MyBot.jl"
