#!/bin/bash

CADENCE_WORKSPACE=9


cadence &

echo "Cadence Starting Up..."

catia &

echo "Catia Starting Up..."

sleep 1 

CADENCE_WINDOW_ARGUMENT=$(wmctrl -l | grep 'Cadence'| head -1 | awk '{print $1;}')

CATIA_WINDOW_ARGUMENT=$(wmctrl -l | grep 'Catia'| head -1 | awk '{print $1;}')

#echo "Cadence Win/Arg: $CADENCE_WINDOW_ARGUMENT"

wmctrl -ir $CADENCE_WINDOW_ARGUMENT -t $CADENCE_WORKSPACE
wmctrl -ir $CATIA_WINDOW_ARGUMENT -t $CADENCE_WORKSPACE

echo "Moved Cadence and Catia to workspace $(($CADENCE_WORKSPACE + 1))."

echo "Done."
