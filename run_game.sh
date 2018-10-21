#!/bin/sh

./halite --replay-directory replays/ -vvv --width 32 --height 32 "~/dev/julia-1.0.1/bin/julia MyBot.jl" "~/dev/julia-1.0.1/bin/julia MyBot.jl"
