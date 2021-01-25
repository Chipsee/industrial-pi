#!/bin/sh -e
# SPEAKER
#CURRENT_PROFILE=$(pactl list sinks | grep "Active Port"| cut -d ' ' -f 3-)
DETIO=6
SPKENIO=11
while [ 1 ]; do
    isdet=`cat /sys/class/gpio/gpio$DETIO/value`
    if [ $isdet -eq 0 ] ; then
        echo 0 > /sys/class/gpio/gpio$SPKENIO/value
        pactl set-sink-port 0 "analog-output-headphones"
	#echo "Headphone"
    else
        echo 1 > /sys/class/gpio/gpio$SPKENIO/value
        pactl set-sink-port 0 "analog-output-speaker"
	#echo "Speaker"
    fi
    sleep 1
done
