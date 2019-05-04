#!/bin/bash

PD_WIN_ARG=$(wmctrl -l | grep 'purr-data' | sort -r | awk '{print $1;}')

wmctrl -ic $PD_WIN_ARG

echo "purr-data processes terminated."
