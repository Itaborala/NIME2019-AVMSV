#!/bin/bash

CADENCE_PID=$(ps -Fa | grep 'cadence' | grep 'dence.py' | awk '{print $2;}')
CATIA_PID=$(ps -Fa | grep 'cadence' | grep 'catia.py' | awk '{print $2;}')


kill $CATIA_PID
sleep 0.1
kill $CADENCE_PID

echo "Cadence processes terminated."
