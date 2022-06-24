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

[ ! -f /opt/chipsee/.cmdline.txt ] && cp /boot/cmdline.txt /opt/chipsee/.cmdline.txt && sed -i 's|quiet|quiet init=/usr/lib/raspi-config/init_resize\.sh|' /opt/chipsee/.cmdline.txt

! grep -q quiet /boot/cmdline.txt && ! grep -q init_resize /opt/chipsee/.cmdline.txt && sed -i 's|rootwait|rootwait init=/usr/lib/raspi-config/init_resize\.sh|' /opt/chipsee/.cmdline.txt

grep -q firstrun /opt/chipsee/.cmdline.txt && sed -i 's| systemd.run.*||g' /opt/chipsee/.cmdline.txt

CMVER=`cat /proc/device-tree/model | cut -d " " -f 5`
SCREEN_SIZE=`fbset | grep -v endmode | grep mode | awk -F '"' '{print $2}'`
BOARD=`cat /opt/chipsee/.board`

#enable i2c0 interface for CM4
if [ "x$CMVER" = "x4" ]; then
	raspi-gpio set 44 a1
	raspi-gpio set 45 a1
fi

##enable i2c1 interface
dtparam -d $OVERLAYS i2c_arm=on
modprobe i2c-dev
modprobe i2c_bcm2835

if [ "X$CMVER" = "X3" ]; then
        IS2514=`lsusb | grep -c 0424:2514`
        IS4232=`lsusb | grep -c 0403:6011`
        if [ "$IS2514" = "1" ] || [ "$IS4232" = "1" ]; then
                echo "Board should be CS12800RA101"
		if [ "x$BOARD" != "xCS12800RA101" ]; then
			echo "SOM changed, reboot."
			cp /opt/chipsee/.cmdline.txt /boot/cmdline.txt
			reboot
		fi
        	echo "Init GPIO for CS12800RA101"
        	OUT="503 502 501 500" 
        	IN="496 497 498 499"
        	BUZZER=40
       		# LVDS
        	lt8619cinit 
		#insmod /home/pi/cslcd/cs_lcd.ko
		#echo cs_lcd 0x32 | tee /sys/bus/i2c/devices/i2c-0/new_device
		#fbi -T 1 -noverbose -a /etc/logo.png
        else
                echo "Board should be CS10600RA070"
		if [ "x$BOARD" != "xCS10600RA070" ]; then
			echo "SOM changed, reboot."
			cp /opt/chipsee/.cmdline.txt /boot/cmdline.txt
			reboot
		fi
        	echo "Init GPIO for CS10600RA070"
        	OUT="4 5 6 7"
        	IN="8 9 10 11" 
        	BUZZER=21
        fi
elif [ "X$CMVER" = "X4" ]; then
        ## for Chipsee CM4 products enable I2C0(need to debug -_-)
        dtparam -d $OVERLAYS audio=off
        dtoverlay -d $OVERLAYS i2c0 pins_44_45=1
        raspi-gpio set 44 a1
        raspi-gpio set 45 a1
        echo "I2C0:" >> $LOGF
        i2cdetect -y 0 >> $LOGF
        is_1a="NULL"
        is_32="NULL"
        is_20="NULL"
        is_1a=$(i2cdetect -y  1 0x1a 0x1a | egrep "(1a|UU)" | awk '{print $2}')
        is_32=$(i2cdetect -y  0 0x32 0x32 | egrep "(32|UU)" | awk '{print $2}')
        is_20=$(i2cdetect -y  1 0x20 0x20 | egrep "(20|UU)" | awk '{print $2}')
        echo "is_1a is $is_1a"
        echo "is_32 is $is_32"
        echo "is_20 is $is_20"
        dtparam -d $OVERLAYS audio=on
        if [ "X${is_1a}" = "X1a" -o "X${is_1a}" = "XUU" ]; then
                echo "Board should be CS12800RA4101"
		if [ "x$BOARD" != "xCS12800RA4101" ]; then
			echo "SOM changed, reboot."
			cp /opt/chipsee/.cmdline.txt /boot/cmdline.txt
			reboot
		fi
        	echo "Init GPIO for CS12800RA4101"
        	BUZZER=12
       		# LVDS
        	lt8619cinit 
		#insmod /home/pi/cslcd/cs_lcd.ko
		#echo cs_lcd 0x32 | tee /sys/bus/i2c/devices/i2c-0/new_device
		#fbi -T 1 -noverbose -a /etc/logo.png
	elif [ "X${is_32}" = "X32" -o "X${is_32}" = "XUU" ]; then
                echo "Board should be CS12800RA4101BOX"
		if [ "x$BOARD" != "xCS12800RA4101BOX" ]; then
			echo "SOM changed, reboot."
			cp /opt/chipsee/.cmdline.txt /boot/cmdline.txt
			reboot
		fi
        	echo "Init GPIO for CS12800RA4101BOX"
        	OUT="503 502 501 500" 
        	IN="496 497 498 499"
        	BUZZER=19
       		# LVDS
        	lt8619cinit 
	elif [ "X${is_20}" = "X20" -o "X${is_20}" = "XUU" ]; then
                echo "Board is CS10600RA4070"
		if [ "x$BOARD" != "xCS10600RA4070" ]; then
			echo "SOM changed, reboot."
			cp /opt/chipsee/.cmdline.txt /boot/cmdline.txt
			reboot
		fi
        	echo "Init GPIO for CS10600RA4070"
        	OUT="503 502 501 500" 
        	IN="496 497 498 499"
        	BUZZER=19
	else
                echo "Board is CS12720RA4050"
		if [ "x$BOARD" != "xCS12720RA4050" ]; then
			echo "SOM changed, reboot."
			cp /opt/chipsee/.cmdline.txt /boot/cmdline.txt
			reboot
		fi
        	echo "Init GPIO for CS12720RA4050"
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
[ ! -d /sys/class/gpio/gpio$i ] && echo $i > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$i/direction
chmod a+w /sys/class/gpio/gpio$i/value
ln -sf /sys/class/gpio/gpio$i/value /dev/chipsee-gpio$num
num=`expr $num + 1`
done            
sleep 1         
for i in $IN; do
[ ! -d /sys/class/gpio/gpio$i ] && echo $i > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio$i/direction
chmod a+r /sys/class/gpio/gpio$i/value
ln -sf /sys/class/gpio/gpio$i/value /dev/chipsee-gpio$num
num=`expr $num + 1`
done
# Buzzer
[ ! -d /sys/class/gpio/gpio$BUZZER ] && echo $BUZZER > /sys/class/gpio/export
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

# Audio
is_1a=$(i2cdetect -y  1 0x1a 0x1a | egrep "(1a|UU)" | awk '{print $2}')
overlay=""
if [ "x${is_1a}" != "x" ]; then
    echo "install 2mic"
    overlay=seeed-2mic-voicecard
    asound_conf=/opt/chipsee/voicecard/asound_2mic.conf
    asound_state=/opt/chipsee/voicecard/wm8960_asound.state
fi
if [ "x${overlay}" != "x" -a "x${CMVER}" = "x4" ]; then
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

    # restore the sound state
    alsactl restore

    # SPEAKER
    # pactl list need be run as nomal user not root
    #CURRENT_PROFILE=$(pactl list sinks | grep "Active Port"| cut -d ' ' -f 3-)
    DETIO=6
    SPKENIO=11
    [ ! -d /sys/class/gpio/gpio$DETIO ] && echo $DETIO > /sys/class/gpio/export
    [ ! -d /sys/class/gpio/gpio$SPKENIO ] && echo $SPKENIO > /sys/class/gpio/export
    echo in > /sys/class/gpio/gpio$DETIO/direction
    echo out > /sys/class/gpio/gpio$SPKENIO/direction
    echo 0 > /sys/class/gpio/gpio$SPKENIO/value
    chmod 777 /sys/class/gpio/gpio$SPKENIO/value
    chmod 777 /sys/class/gpio/gpio$DETIO/value
    # execute other contents in audioswitch.service
    # systemctl --user start audioswitch.service
    # systemctl --user enable audioswitch.service
    # or use this shell to enable audioswitch.service
    if [ ! -f /home/pi/.config/systemd/user/default.target.wants/audioswitch.service ]; then
    	mkdir -p /home/pi/.config/systemd/user/default.target.wants
    	ln -s /usr/lib/systemd/user/audioswitch.service /home/pi/.config/systemd/user/default.target.wants/audioswitch.service
	ln -s /usr/lib/systemd/user/dpms-lcd.service /home/pi/.config/systemd/user/default.target.wants/dpms-lcd.service
        chown pi:pi /home/pi/.config -R
    	reboot
    fi

fi

# Backlight Control
chmod a+w /sys/class/backlight/pwm-backlight/brightness
if [ ! -f /home/pi/.config/systemd/user/default.target.wants/dpms-lcd.service ]; then
	mkdir -p /home/pi/.config/systemd/user/default.target.wants
	ln -s /usr/lib/systemd/user/dpms-lcd.service /home/pi/.config/systemd/user/default.target.wants/dpms-lcd.service
	chown pi:pi /home/pi/.config -R
	reboot
fi

# Udhcpc for 4G
if [ -f /etc/udhcpc/default.script ]; then
        mkdir /usr/share/udhcpc -p
        ln -sf /etc/udhcpc/default.script /usr/share/udhcpc/default.script
fi

exit 0
