#1/bin/bash

JV_WORKSPACE=5

echo "jack-volume (VBAP) Starting Up..."

gnome-terminal --working-directory=NIME2019-AVMSV/shellScripts -- "./jack-volume_w_flags_VBAP.sh"

jvctl -p 7700 -c 7 -j 'VBAP' &

sleep 0.3

JV_WIN_ARG=$(wmctrl -l | grep 'Terminal' | sort -r | head -1 | awk '{print $1;}')
JVCTL_WIN_ARG=$(wmctrl -l | grep 'jvctl' | sort -r | head -1 | awk '{print $1;}')

# echo "$JV_WIN_ARG"
# echo "$JVCTL_WIN_ARG"

wmctrl -ir $JV_WIN_ARG -t $JV_WORKSPACE
wmctrl -ir $JVCTL_WIN_ARG -t $JV_WORKSPACE


echo "Moved jack-volume (VBAP) to workspace $(($JV_WORKSPACE + 1))."

echo "Done."
