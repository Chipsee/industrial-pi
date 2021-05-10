#!/bin/sh -e

# we will stop dpms-lcd in lite version
if ! command -v xset > /dev/null; then
      echo "xset not found"
      sleep 5
      systemctl --user stop dpms-lcd
      return 1
fi

# sleep to wait xorg start
sleep 60

while [ 1 ]; do
	DPMSSTATUS=`xset -display :0 q | grep 'DPMS is' | awk -F ' ' '{print $3}'`
	MONITORSTATUS=`xset -display :0 q | grep Monitor | awk -F ' ' '{print $3}'`

	CURBRIGHTNESSPATH="/sys/class/backlight/pwm-backlight/brightness"
	CURBRIGHTNESS=`cat $CURBRIGHTNESSPATH`

	#echo dpms status is $DPMSSTATUS
	#echo monitor status is $MONITORSTATUS
	#echo cur bri is $CURBRIGHTNESS

	if [ $DPMSSTATUS = "Enabled" -a $MONITORSTATUS = "Off" -a $CURBRIGHTNESS -gt 0 ]; then
		SAVEBRIGHTNESS=$CURBRIGHTNESS
		echo 0 > $CURBRIGHTNESSPATH
		echo "Close LCD Backlight"
	elif [ $DPMSSTATUS = "Enabled" -a $MONITORSTATUS = "On" -a $CURBRIGHTNESS -eq 0 ]; then 
		echo $SAVEBRIGHTNESS > $CURBRIGHTNESSPATH
		echo "Open LCD Backlight"
	fi	
		
	sleep 1;
done
