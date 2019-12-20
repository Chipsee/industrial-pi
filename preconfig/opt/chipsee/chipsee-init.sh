#!/bin/sh
# GPIO
OUT="4 5 6 7"
IN="8 9 10 11"
BUZZER=21
BACKLIGHT=41
AUDIO=42
num=1
for i in $OUT; do
echo $i > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$i/direction
chmod a+w /sys/class/gpio/gpio$i/value
ln -sf /sys/class/gpio/gpio$i/value /dev/chipsee-gpio$num
num=`expr $num + 1`
done
sleep 1
for i in $IN; do
echo $i > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio$i/direction
chmod a+r /sys/class/gpio/gpio$i/value
ln -sf /sys/class/gpio/gpio$i/value /dev/chipsee-gpio$num
num=`expr $num + 1`
done
# Audio
echo $AUDIO > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$AUDIO/direction
echo 1 > /sys/class/gpio/gpio$AUDIO/value
# BACKLIGHT
echo $BACKLIGHT > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$BACKLIGHT/direction
echo 1 > /sys/class/gpio/gpio$BACKLIGHT/value
# Buzzer
echo $BUZZER > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$BUZZER/direction
chmod a+w /sys/class/gpio/gpio$BUZZER/value
ln -sf /sys/class/gpio/gpio$BUZZER/value /dev/buzzer
echo "GPIO Init done!!"
# Kernel Modules
modprobe gt911
echo Goodix-TS 0x5d | tee /sys/bus/i2c/devices/i2c-1/new_device
modprobe lsm6ds3
echo lsm6ds3 0x6a | tee /sys/bus/i2c/devices/i2c-1/new_device
echo "Kernel modules load success!!"
