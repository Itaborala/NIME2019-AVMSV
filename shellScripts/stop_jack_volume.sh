#!/bin/bash

JVCTL_PID=$(ps -Fa | grep 'jvctl' | grep 'Volume_Master' | awk '{print $2;}')
JV_PID=$(ps -Fa | grep 'jack-volume' | grep 'Volume_Master' | awk '{print $2;}')


kill $JVCTL_PID
kill $JV_PID

echo "jack-volume (Volume_Master) processes terminated."
