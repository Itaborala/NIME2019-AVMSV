#!/bin/bash

PD_WORKSPACE=3

echo "purr-data Starting Up..."

purr-data &

sleep 3

PD_WIN_ARG=$(wmctrl -l | grep 'purr-data' | sort -r | awk '{print $1;}')
PEO_WIN_ARG=$(wmctrl -l | grep 'Profile' | sort -r | awk '{print $1;}')

wmctrl -ic $PEO_WIN_ARG
wmctrl -ir $PD_WIN_ARG -t $PD_WORKSPACE

echo "Moved purr-data to workspace $(($PD_WORKSPACE + 1))"

echo "Done."
