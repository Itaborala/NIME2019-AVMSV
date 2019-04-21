#!/bin/bash


PRO_PID=$(ps -Fa | grep alsa_out | grep 'hw:Pro,1' | awk '{print $2;}'i)

H5_PID=$(ps -Fa | grep alsa_out | grep 'hw:H5' | awk '{print $2;}'i)

kill $PRO_PID $H5_PID

echo "alsa_out processes terminated."
