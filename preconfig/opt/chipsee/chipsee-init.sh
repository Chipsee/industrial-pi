#!/bin/bash
#
# Copyright (c) 2021 Xiaoqiang Liu <lxq@chipsee.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


set -x
LOGF=/var/log/$(basename $0).log
exec 1> >(tee $LOGF)
exec 2>&1

export PATH=$PATH:/opt/vc/bin
OVERLAYS=/boot/overlays
[ -d /boot/firmware/overlays ] && OVERLAYS=/boot/firmware/overlays
CONFIG=/boot/config.txt
[ -f /boot/firmware/usercfg.txt ] && CONFIG=/boot/firmware/usercfg.txt

#enable i2c interface
raspi-gpio set 44 a1
raspi-gpio set 45 a1

CMVER=`cat /proc/device-tree/model | cut -d " " -f 5`
SCREEN_SIZE=`fbset | grep -v endmode | grep mode | awk -F '"' '{print $2}'`

if [ "$SCREEN_SIZE" = "1280x800" ]; then
	if [ "x$CMVER" = "x3" ]; then
        	echo "Init GPIO for CS12800RA101"
        	OUT="503 502 501 500" 
        	IN="496 497 498 499"
        	BUZZER=40
	elif [ "x$CMVER" = "x4" ]; then
        	echo "Init GPIO for LRRA4-101"
        	BUZZER=12
	fi
       	# LVDS
        lt8619cinit 
	#insmod /home/pi/cslcd/cs_lcd.ko
	#echo cs_lcd 0x32 | tee /sys/bus/i2c/devices/i2c-0/new_device
	#fbi -T 1 -noverbose -a /etc/logo.png
	if [ ! -f /home/pi/.config/systemd/user/default.target.wants/audioswitch.service ]; then
		mkdir -p /home/pi/.config/systemd/user/default.target.wants
		ln -s /usr/lib/systemd/user/audioswitch.service /home/pi/.config/systemd/user/default.target.wants/audioswitch.service
		chown pi:pi /home/pi/.config/systemd/user/default.target.wants/audioswitch.service
		reboot
	fi
else
	if [ "x$CMVER" = "x3" ]; then
        	echo "Init GPIO for CS10600RA070"
        	OUT="4 5 6 7"
        	IN="8 9 10 11" 
        	BUZZER=21
	elif [ "x$CMVER" = "x4" ]; then
        	echo "Init GPIO for CS10600RA4070"
        	OUT="503 502 501 500" 
        	IN="496 497 498 499"
        	BUZZER=19
		
	fi
fi

# Funcs
get_overlay() {
    ov=$1
    if grep -q -E "^dtoverlay=$ov" $CONFIG; then
      echo 0
    else
      echo 1
    fi
}

do_overlay() {
    ov=$1
    RET=$2
    DEFAULT=--defaultno
    CURRENT=0
    if [ $(get_overlay $ov) -eq 0 ]; then
        DEFAULT=
        CURRENT=1
    fi
    if [ $RET -eq $CURRENT ]; then
        ASK_TO_REBOOT=1
    fi
    if [ $RET -eq 0 ]; then
        sed $CONFIG -i -e "s/^#dtoverlay=$ov/dtoverlay=$ov/"
        if ! grep -q -E "^dtoverlay=$ov" $CONFIG; then
            printf "dtoverlay=$ov\n" >> $CONFIG
        fi
        STATUS=enabled
    elif [ $RET -eq 1 ]; then
        sed $CONFIG -i -e "s/^dtoverlay=$ov/#dtoverlay=$ov/"
        STATUS=disabled
    else
        return $RET
    fi
}

_VER_RUN=
function get_kernel_version() {
    local ZIMAGE IMG_OFFSET

    _VER_RUN=""
    [ -z "$_VER_RUN" ] && {
        ZIMAGE=/boot/kernel.img
        IMG_OFFSET=$(LC_ALL=C grep -abo $'\x1f\x8b\x08\x00' $ZIMAGE | head -n 1 | cut -d ':' -f 1)
        _VER_RUN=$(dd if=$ZIMAGE obs=64K ibs=4 skip=$(( IMG_OFFSET / 4)) | zcat | grep -a -m1 "Linux version" | strings | awk '{ print $3; }')
    }
    echo "$_VER_RUN"
    return 0
}

# GPIO
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
# Buzzer
echo $BUZZER > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$BUZZER/direction
chmod a+w /sys/class/gpio/gpio$BUZZER/value 
ln -sf /sys/class/gpio/gpio$BUZZER/value /dev/buzzer
echo "GPIO Init done!!"

# Kernel Modules
modprobe gt9xx
#echo Goodix-TS 0x5d | tee /sys/bus/i2c/devices/i2c-1/new_device
modprobe lsm6ds3
echo lsm6ds3 0x6a | tee /sys/bus/i2c/devices/i2c-1/new_device
echo "Kernel modules load success!!"

# Udhcpc for 4G
if [ -f /etc/udhcpc/default.script ]; then
        mkdir /usr/share/udhcpc -p
        ln -sf /etc/udhcpc/default.script /usr/share/udhcpc/default.script
fi

# Audio
is_1a=$(i2cdetect -y  1 0x1a 0x1a | egrep "(1a|UU)" | awk '{print $2}')
overlay=""
if [ "x${is_1a}" != "x" ]; then
    echo "install 2mic"
    overlay=seeed-2mic-voicecard
    asound_conf=/opt/chipsee/voicecard/asound_2mic.conf
    asound_state=/opt/chipsee/voicecard/wm8960_asound.state
fi
if [ "$overlay" ]; then
    echo Install $overlay ...

    # Remove old configuration
    rm /etc/asound.conf
    rm /var/lib/alsa/asound.state

: <<\EOF
    kernel_ver=$(get_kernel_version)
    # echo kernel_ver=$kernel_ver

    # TODO: dynamic dtoverlay Bug of v4.19.x
    #       no DT node phandle inserted.
    if [[ "$kernel_ver" =~ ^4\.19.*$ || "$kernel_ver" =~ ^5\.*$ ]]; then
        for i in $RPI_HATS; do
            if [ "$i" == "$overlay" ]; then
                do_overlay $overlay 0
            else
                echo Uninstall $i ...
                do_overlay $i 1
            fi
        done
    fi
EOF
    #make sure the driver loads correctly
    dtoverlay -d $OVERLAYS $overlay || true


    echo "create $overlay asound configure file"
    ln -s $asound_conf /etc/asound.conf
    echo "create $overlay asound status file"
    ln -s $asound_state /var/lib/alsa/asound.state
fi

# restore the sound state
alsactl restore

#Force 3.5mm ('headphone') jack
#   The Raspberry Pi 4, released on 24th Jun 2019, has two HDMI ports,
#   and can drive two displays with audios for two users simultaneously,
#   in a "multiseat" configuration. The earlier single virtual ALSA
#   option for re-directing audio playback between headphone jack and HDMI
#   via a 'Routing' mixer setting was turned off eventually to allow
#   simultaneous usage of all 3 playback devices.
if aplay -l | grep -q "bcm2835 ALSA"; then
    amixer cset numid=3 1 || true
fi

# SPEAKER
CURRENT_PROFILE=$(pactl list sinks | grep "Active Port"| cut -d ' ' -f 3-)
DETIO=6
SPKENIO=11
echo $DETIO > /sys/class/gpio/export
echo $SPKENIO > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio$DETIO/direction
echo out > /sys/class/gpio/gpio$SPKENIO/direction
echo 1 > /sys/class/gpio/gpio$SPKENIO/value
chmod 777 /sys/class/gpio/gpio$SPKENIO/value
chmod 777 /sys/class/gpio/gpio$DETIO/value
# follow contents will execute in audioswitch.service
# systemctl --user start audioswitch.service
# systemctl --user enable audioswitch.service
#COUNT=1
#while [ 1 ]; do
#    isdet=`cat /sys/class/gpio/gpio$DETIO/value`
#    if [ $isdet -eq 0 ] ; then
#        echo 0 > /sys/class/gpio/gpio$SPKENIO/value
#        pactl set-sink-port 0 "analog-output-headphones"
#	echo "$COUNT: Headphone"
#    else
#        echo 1 > /sys/class/gpio/gpio$SPKENIO/value
#        pactl set-sink-port 0 "analog-output-speaker"
#	echo "$COUNT: Speaker"
#    fi
#    COUNT=`expr $COUNT + 1`
#    sleep 1
#done
if [ ! -f /home/pi/.config/systemd/user/default.target.wants/audioswitch.service ]; then
	ln -s /usr/lib/systemd/user/audioswitch.service /home/pi/.config/systemd/user/default.target.wants/audioswitch.service
fi

exit 0
