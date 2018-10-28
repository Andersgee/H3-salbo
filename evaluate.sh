#!/bin/bash

set -e

MAP_SIZE=64

if [ "$(uname)" == "Darwin" ]; then
  HALITE=./halite-osx
else
  HALITE=./halite-linux
fi

mkdir -p replays

TMP=`mktemp -d`
BOTS=""

echo "Tempdir: $TMP"

if [ "$#" == "0" ]; then
  echo "Missing arguments, expected git commit refs"
  false
fi

for i in `seq 1 $#`; do
  git clone . $TMP/$i
  pushd $TMP/$i
  git checkout ${!i}
  popd
  BOTS="$BOTS $TMP/$i/MyBot.jl"
done

$HALITE --replay-directory replays/ -vvv --width $MAP_SIZE --height $MAP_SIZE $BOTS

rm -rf $TMP
