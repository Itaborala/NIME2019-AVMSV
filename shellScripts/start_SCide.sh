#!/bin/bash

SC_WORKSPACE=2

echo "scide Starting Up..."

scide ../Patches/SC/AV-MSV.scd &

sleep 1

SC_WIN_ARG=$(wmctrl -l | grep 'SuperCollider' | grep 'IDE' | sort -r | awk '{print $1;}')

wmctrl -ir $SC_WIN_ARG -t $SC_WORKSPACE

echo "Moved scide to workspace $(($SC_WORKSPACE + 1))"

echo "Done."
