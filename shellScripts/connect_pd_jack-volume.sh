#!/bin/bash



jack_disconnect pure_data_0:output0 system:playback_1
jack_disconnect pure_data_0:output1 system:playback_2

for CHANNEL in {1..6}
do
	jack_connect pure_data_0:output$(($CHANNEL - 1)) Volume_Master:input_$CHANNEL
done

echo "Connected purr-data and jack-volume (Volume_Master) Clients"

