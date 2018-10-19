#!/bin/sh

./halite --replay-directory replays/ -vvv --width 32 --height 32 "julia MyBot.jl" "julia MyBot.jl"
