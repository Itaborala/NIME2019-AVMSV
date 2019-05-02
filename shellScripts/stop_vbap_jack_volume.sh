#!/bin/bash

JVCTL_PID=$(ps -Fa | grep 'jvctl' | grep 'VBAP' | awk '{print $2;}')
JV_PID=$(ps -Fa | grep 'jack-volume' | grep 'VBAP' | awk '{print $2;}')


kill $JVCTL_PID
kill $JV_PID

echo "jack-volume (VBAP) processes terminated."
