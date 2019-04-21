#!/bin/bash


SCSYNTH_PID=$(ps -Fa | grep scsynth | grep 20001 | awk '{print $2;}')

kill $SCSYNTH_PID

echo "scsynth process terminated."
