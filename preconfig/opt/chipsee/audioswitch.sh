#!/bin/sh -e
# SPEAKER
#CURRENT_PROFILE=$(pactl list sinks | grep "Active Port"| cut -d ' ' -f 3-)
# wait to avoid noise
sleep 30

if command -v pactl > /dev/null; then
	card=`pactl list cards |  grep -i 'alsa.card.name' | sed 's/ //g'| sed 's/alsa.card.name=\"//g'| sed 's/\"//g'`
fi

DETIO=518
SPKENIO=523
while [ 1 ]; do
    isdet=`cat /sys/class/gpio/gpio$DETIO/value`
    if [ $isdet -eq 0 ] ; then
        echo 0 > /sys/class/gpio/gpio$SPKENIO/value
	if command -v pactl > /dev/null; then
		pactl set-sink-port @DEFAULT_SINK@ "analog-output-headphones"
	fi
	#echo "Headphone"
    else
        echo 1 > /sys/class/gpio/gpio$SPKENIO/value
	if command -v pactl > /dev/null; then
		pactl set-sink-port @DEFAULT_SINK@ "analog-output-speaker"
	fi
	#echo "Speaker and Microphone"
    fi
    sleep 1
done
