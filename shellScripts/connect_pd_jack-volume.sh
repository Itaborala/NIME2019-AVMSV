#!/bin/bash

for CHANNEL in {1..6}
do
	jack_connect pure_data_0:output$(($CHANNEL - 1)) Volume_Master:input_$CHANNEL
done

