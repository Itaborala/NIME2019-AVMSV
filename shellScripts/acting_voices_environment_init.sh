#!/bin/bash

CADENCE_WORKSPACE=6



cadence &

echo "Cadence Starting Up..."

sleep 2 

CADENCE_WINDOW_ARGUMENT=$(wmctrl -l | grep 'Cadence'| head -1 | awk '{print $1;}')

echo "Cadence Win/Arg: $CADENCE_WINDOW_ARGUMENT"

wmctrl -ir $CADENCE_WINDOW_ARGUMENT -t $CADENCE_WORKSPACE

echo "Moved Cadence to workspace $(($CADENCE_WORKSPACE + 1))."

echo "Done."
