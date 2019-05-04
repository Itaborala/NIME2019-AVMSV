#!/bin/bash

SC_WIN_ARG=$(wmctrl -l | grep 'SuperCollider' | grep 'IDE' | sort -r | awk '{print $1;}')

wmctrl -ic $SC_WIN_ARG

echo "scide processes terminated."
