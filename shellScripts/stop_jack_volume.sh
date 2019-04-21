#!/bin/bash

JVCTL_PID=$(ps -Fa | grep 'jvctl' | grep 'python' | awk '{print $2;}')
JV_PID=$(ps -Fa | grep 'jack-volume' | head -1 | awk '{print $2;}')


kill $JVCTL_PID
kill $JV_PID

echo "jack-volume processes terminated."
