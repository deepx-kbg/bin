#!/bin/bash

pushd ~/dxnn_sdk/deepx_firmware

BOARD="$1"
if [ -z "$BOARD" ]; then
    BOARD=mdot2
fi

./m1a_setup.py -t asic -o $BOARD

popd
