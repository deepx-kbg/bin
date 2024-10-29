#!/bin/bash

pushd ~/m1a

BOARD="$1"
if [ -z "$BOARD" ]; then
    BOARD=mdot2
fi

./m1a_setup.py -t asic -o $BOARD

popd
