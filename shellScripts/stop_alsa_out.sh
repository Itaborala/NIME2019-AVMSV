#!/bin/bash

#tinha um 'i' estranho no final dos PID's

PRO0_PID=$(ps -Fa | grep alsa_out | grep 'hw:Pro,0' | awk '{print $2;}')

PRO1_PID=$(ps -Fa | grep alsa_out | grep 'hw:Pro,1' | awk '{print $2;}')

#H5_PID=$(ps -Fa | grep alsa_out | grep 'hw:H5' | awk '{print $2;}')

CODEC_PID=$(ps -Fa | grep alsa_out | grep 'hw:CODEC' | awk '{print $2;}')

kill $PRO0_PID $PRO1_PID $CODEC_PID

echo "alsa_out processes terminated."
