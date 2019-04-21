#!/bin/bash

SCSYNTH_WORKSPACE=9

echo "scsynth Starting Up..."

gnome-terminal --working-directory=NIME2019-AVMSV/shellScripts -- "./scsynth_w_flags.sh"


sleep 0.1


SCSYNTH_WIN_ARG=$(wmctrl -l | grep 'Terminal' | sort -r | head -1 | awk '{print $1;}')

wmctrl -ir $SCSYNTH_WIN_ARG -t $SCSYNTH_WORKSPACE

echo "Moved scsynth to workspace $(($SCSYNTH_WORKSPACE + 1))"

echo "Done."

