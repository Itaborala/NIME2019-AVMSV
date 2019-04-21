#!/bin/bash

cd ../

export "SC_JACK_DEFAULT_INPUTS"="system:capture_1,system:capture_2"

export "SC_JACK_DEFAULT_OUTPUTS"="jack-volume:input_1,jack-volume:input_2,jack-volume:input_3,jack-volume:input_4,jack-volume:input_5,jack-volume:input_6"

scsynth -u 20001 -i 2 -o 6
