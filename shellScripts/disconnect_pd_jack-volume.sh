#!/bin/bash

for CHANNEL in {1..6}
do
	jack_disconnect pure_data_0:output$(($CHANNEL - 1)) Volume_Master:input_$CHANNEL
done

echo "Disconnected purr-data and jack-volume (Volume_Master) Clients"

