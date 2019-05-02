#!/bin/bash

for CHANNEL in {1..6}
do
	HW="UCA222"
	
	if [ $CHANNEL -le 4 ]; then
		#HW="M-AudioPro1"
		if [ $CHANNEL -le 2 ]; then
		
		
			HW="M-AudioPro0"
		else
			HW="M-AudioPro1"
		fi
	fi

	PB_CH=1

	if [ $(($CHANNEL % 2)) -eq 0 ]; then
		PB_CH=2
	fi

	#echo "$HW"
	#echo "$PB_CH"

	jack_connect Volume_Master:output_$CHANNEL $HW:playback_$PB_CH
done

echo "Connected jack-volume (Volume_Master) and alsa_out Clients"

