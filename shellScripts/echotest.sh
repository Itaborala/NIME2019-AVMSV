#!/bin/bash

echo "Press [ESC] to quit"
# read a single character
while read -s -r -n1 key
do

# if input == ESC key
if [[ $key == $'\e' ]];
then
break;
fi


done
echo "Goodbye! :)"
sleep 0.8
