#!/bin/bash

ALSAO_WORKSPACE=3

echo "alsa_out Starting Up..."

gnome-terminal --working-directory=NIME2019-AVMSV/shellScripts -- "./alsa_out_w_flags_Pro.sh"

gnome-terminal --working-directory=NIME2019-AVMSV/shellScripts -- "./alsa_out_w_flags_H5.sh"

sleep 0.1

ALSAO_PRO_WIN_ARG=$(wmctrl -l | grep 'Terminal' | sort -r | awk 'NR==2' | awk '{print $1;}')

ALSAO_H5_WIN_ARG=$(wmctrl -l | grep 'Terminal' | sort -r | awk 'NR==1' | awk '{print $1;}')


wmctrl -ir $ALSAO_PRO_WIN_ARG -t $ALSAO_WORKSPACE
wmctrl -ir $ALSAO_H5_WIN_ARG -t $ALSAO_WORKSPACE

echo "Moved alsa_out to workspace $(($ALSAO_WORKSPACE + 1))"

echo "Done."
