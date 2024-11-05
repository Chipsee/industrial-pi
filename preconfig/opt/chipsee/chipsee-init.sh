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

# settings the user variable
USER=$(head -1 /boot/userconf | cut -d':' -f1)

FWLOC=$(/usr/lib/raspberrypi-sys-mods/get_fw_loc)

OVERLAYS=/boot/overlays
[ -d /boot/firmware/overlays ] && OVERLAYS=/boot/firmware/overlays
CONFIG=/boot/config.txt
[ -f /boot/firmware/usercfg.txt ] && CONFIG=/boot/firmware/usercfg.txt
[ -f /boot/firmware/config.txt ] && CONFIG=/boot/firmware/config.txt

# Backup log file
[ -f /boot/chipseeinit_firstrun.log ] && cp /boot/chipseeinit_firstrun.log /var/log/ && sync
[ -f /boot/firmware/chipseeinit_firstrun.log ] && cp /boot/firmware/chipseeinit_firstrun.log /var/log/ && sync

# fix First run
#grep -q firstrun /opt/chipsee/.cmdline.txt && sed -i 's| systemd.run.*||g' /opt/chipsee/.cmdline.txt

CMVER=`cat /proc/device-tree/model | cut -d " " -f 5`
SCREEN_SIZE=`fbset | grep -v endmode | grep mode | awk -F '"' '{print $2}'`
BOARD=`cat /opt/chipsee/.board`
BOARDL=`echo $BOARD | tr '[:upper:]' '[:lower:]'`

#enable i2c0 interface for CM4
if [ "x$CMVER" = "x4" ]; then
	raspi-gpio set 44 a1
	raspi-gpio set 45 a1
fi

##enable i2c1 interface
dtparam -d $OVERLAYS i2c_arm=on
modprobe i2c-dev
modprobe i2c_bcm2835

ISSOMCHANGED=0
IS133PISO=0
if [ "X$CMVER" = "X3" ]; then
        IS2514=`lsusb | grep -c 0424:2514`
        IS4232=`lsusb | grep -c 0403:6011`
        if [ "$IS2514" = "1" ] || [ "$IS4232" = "1" ]; then
                echo "Board should be CS12800RA101"
		if [ "x$BOARD" != "xCS12800RA101" ]; then
			echo "SOM changed, reboot."
			ISSOMCHANGED=1
			cp ${FWLOC}/config-cs12800ra101.txt ${FWLOC}/config.txt
		fi
        	echo "Init GPIO for CS12800RA101"
        	OUT="503 502 501 500" 
        	IN="496 497 498 499"
        	BUZZER=40
       		# LVDS
        	lcdinit 
		#insmod /home/pi/cslcd/cs_lcd.ko
		#echo cs_lcd 0x32 | tee /sys/bus/i2c/devices/i2c-0/new_device
		#fbi -T 1 -noverbose -a /etc/logo.png
        else
                echo "Board should be CS10600RA070"
		if [ "x$BOARD" != "xCS10600RA070" ]; then
			echo "SOM changed, reboot."
			ISSOMCHANGED=1
			cp ${FWLOC}/config-cs10600ra070.txt ${FWLOC}/config.txt
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
        ISVL805=`lspci | grep -c VL805`
        echo "is_1a is $is_1a"
        echo "is_32 is $is_32"
        echo "is_20 is $is_20"
        dtparam -d $OVERLAYS audio=on

        if [ "X${is_1a}" = "X1a" -o "X${is_1a}" = "XUU" ]; then
                echo "Board should be CS12800RA4101A"
		if [ "x$BOARD" != "xCS12800RA4101A" ]; then
			echo "SOM changed, reboot."
			ISSOMCHANGED=1
			cp ${FWLOC}/config-cs12800ra4101a.txt ${FWLOC}/config.txt
		fi
        	echo "Init GPIO for CS12800RA4101A"
        	BUZZER=12
       		# LVDS
        	lcdinit 
	elif [ "X${is_32}" = "X32" -o "X${is_32}" = "XUU" ]; then
		## for big size display
		RAWSIZE=`i2cget -y -a 0 0x51 0x0A`
		BASE16SIZE=${RAWSIZE#0x}
		BASE16SIZEUPPER=`echo ${BASE16SIZE} | tr '[:lower:]' '[:upper:]'`
		PANELSIZE=`echo "ibase=16;${BASE16SIZEUPPER}" | bc`
		echo Panel size is $PANELSIZE
		case ${PANELSIZE} in
			101)
                		echo "Board should be CS12800RA4101P"
				[ "x$BOARD" != "xCS12800RA4101P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs12800ra4101p.txt ${FWLOC}/config.txt
				;;
			121)
                		echo "Board should be CS10768RA4121P"
				[ "x$BOARD" != "xCS10768RA4121P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs10768ra4121p.txt ${FWLOC}/config.txt
				;;
			133)
                		echo "Board should be CS19108RA4133P"
				[ "x$BOARD" != "xCS19108RA4133P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs19108ra4133p.txt ${FWLOC}/config.txt
				;;
			134)
                		echo "Board should be CS19108RA4133PISO"
				[ "x$BOARD" != "xCS19108RA4133PISO" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs19108ra4133piso.txt ${FWLOC}/config.txt
				IS133PISO=1;
				;;
			150)
                		echo "Board should be CS10768RA4150P"
				[ "x$BOARD" != "xCS10768RA4150P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs10768ra4150p.txt ${FWLOC}/config.txt
				;;
			156)
                		echo "Board should be CS19108RA4156P"
				[ "x$BOARD" != "xCS19108RA4156P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs19108ra4156p.txt ${FWLOC}/config.txt
				;;
			170)
                		echo "Board should be CS12102RA4170P"
				[ "x$BOARD" != "xCS12102RA4170P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs12102ra4170p.txt ${FWLOC}/config.txt
				;;
			185)
                		echo "Board should be CS19108RA4185P"
				[ "x$BOARD" != "xCS19108RA4185P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs19108ra4185p.txt ${FWLOC}/config.txt
				;;
			190)
                		echo "Board should be CS12102RA4190P"
				[ "x$BOARD" != "xCS12102RA4190P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs12102ra4190p.txt ${FWLOC}/config.txt
				;;
			215)
                		echo "Board should be CS19108RA4215P"
				[ "x$BOARD" != "xCS19108RA4215P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs19108ra4215p.txt ${FWLOC}/config.txt
				;;
			236)
                		echo "Board should be CS19108RA4236P"
				[ "x$BOARD" != "xCS19108RA4236P" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs19108ra4236p.txt ${FWLOC}/config.txt
				;;
			*)
                		echo "Board should be CS12800RA4101BOX"
				[ "x$BOARD" != "xCS12800RA4101BOX" ] && ISSOMCHANGED=1 && cp ${FWLOC}/config-cs12800ra4101box.txt ${FWLOC}/config.txt
				;;
		esac

        	echo "Init GPIO for Big Size products"
		if [ ${IS133PISO} -eq 1 ]; then
        		OUT="12 13" 
        		IN="496 497 498 499 500 501 502 503"
		else
        		OUT="503 502 501 500" 
        		IN="496 497 498 499"
		fi
        	BUZZER=19
       		# LVDS
        	[ "x$BOARD" == "xCS12800RA4101BOX" ] && lcdinit 
        	[ "x$BOARD" == "xCS12800RA4101P" ] && lcdinit 
	elif [ "X${ISVL805}" = "X1" ]; then
                echo "Board is CS10600RA4070D"
                if [ "x$BOARD" != "xCS10600RA4070D" ]; then
                        echo "SOM changed, reboot."
                        ISSOMCHANGED=1
			cp ${FWLOC}/config-cs10600ra4070d.txt ${FWLOC}/config.txt
                fi
                echo "Init GPIO for CS10600RA4070D"
                OUT="503 502 501 500"
                IN="496 497 498 499"
                BUZZER=19
	elif [ "X${is_20}" = "X20" -o "X${is_20}" = "XUU" ]; then
               	echo "Board is CS10600RA4070"
		if [ "x$BOARD" != "xCS10600RA4070" ]; then
			echo "SOM changed, reboot."
			ISSOMCHANGED=1
			cp ${FWLOC}/config-cs10600ra4070.txt ${FWLOC}/config.txt
		fi
        	echo "Init GPIO for CS10600RA4070"
        	OUT="503 502 501 500" 
        	IN="496 497 498 499"
        	BUZZER=19
	else
        	echo "Board is CS12720RA4050"
		if [ "x$BOARD" != "xCS12720RA4050" ]; then
			echo "SOM changed, reboot."
			ISSOMCHANGED=1
			cp ${FWLOC}/config-cs12720ra4050.txt ${FWLOC}/config.txt
		fi
       		echo "Init GPIO for CS12720RA4050"
       		BUZZER=19
	fi
fi

if [ ${ISSOMCHANGED} -eq 1 ]; then
	echo "SOM changed, reboot."
	## Old image
	[ ! -f /usr/lib/raspberrypi-sys-mods/firstboot ] && ! grep -q quiet ${FWLOC}/cmdline.txt && sed -i 's|rootwait|rootwait init=/usr/lib/raspi-config/init_resize\.sh|' ${FWLOC}/cmdline.txt
	[ ! -f /usr/lib/raspberrypi-sys-mods/firstboot ] && grep -q quiet ${FWLOC}/cmdline.txt && sed -i 's|quiet|quiet init=/usr/lib/raspi-config/init_resize\.sh|' ${FWLOC}/cmdline.txt

	## New image
	[ -f /usr/lib/raspberrypi-sys-mods/firstboot ] && ! grep -q quiet ${FWLOC}/cmdline.txt && sed -i 's|rootwait|rootwait init=/usr/lib/raspberrypi-sys-mods/firstboot|' ${FWLOC}/cmdline.txt
	[ -f /usr/lib/raspberrypi-sys-mods/firstboot ] && grep -q quiet ${FWLOC}/cmdline.txt && sed -i 's|quiet|quiet init=/usr/lib/raspberrypi-sys-mods/firstboot|' ${FWLOC}/cmdline.txt
	reboot
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
	ZIMAGE=${FWLOC}/kernel.img
        IMG_OFFSET=$(LC_ALL=C grep -abo $'\x1f\x8b\x08\x00' $ZIMAGE | head -n 1 | cut -d ':' -f 1)
        _VER_RUN=$(dd if=$ZIMAGE obs=64K ibs=4 skip=$(( IMG_OFFSET / 4)) | zcat | grep -a -m1 "Linux version" | strings | awk '{ print $3; }')
    }
    echo "$_VER_RUN"
    return 0
}

# GPIO
num=1
nnum=1
for i in $OUT; do
[ ! -d /sys/class/gpio/gpio$i ] && echo $i > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$i/direction
chmod a+w /sys/class/gpio/gpio$i/value
ln -sf /sys/class/gpio/gpio$i/value /dev/chipsee-gpio$num
ln -sf /sys/class/gpio/gpio$i/value /dev/gpio-out$nnum
num=`expr $num + 1`
nnum=`expr $nnum + 1`
done            
sleep 1         
nnum=1
for i in $IN; do
[ ! -d /sys/class/gpio/gpio$i ] && echo $i > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio$i/direction
chmod a+r /sys/class/gpio/gpio$i/value
ln -sf /sys/class/gpio/gpio$i/value /dev/chipsee-gpio$num
ln -sf /sys/class/gpio/gpio$i/value /dev/gpio-in$nnum
num=`expr $num + 1`
nnum=`expr $nnum + 1`
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
#modprobe lsm6ds3
#echo lsm6ds3 0x6a | tee /sys/bus/i2c/devices/i2c-1/new_device
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
    if [ ! -f /home/$USER/.config/systemd/user/default.target.wants/audioswitch.service ]; then
    	mkdir -p /home/$USER/.config/systemd/user/default.target.wants
    	ln -s /usr/lib/systemd/user/audioswitch.service /home/$USER/.config/systemd/user/default.target.wants/audioswitch.service
	ln -s /usr/lib/systemd/user/dpms-lcd.service /home/$USER/.config/systemd/user/default.target.wants/dpms-lcd.service
        chown $USER:$USER /home/$USER/.config -R
    	reboot
    fi

fi

# Backlight Control
chmod a+w /sys/class/backlight/pwm-backlight/brightness
if [ ! -f /home/$USER/.config/systemd/user/default.target.wants/dpms-lcd.service ]; then
	mkdir -p /home/$USER/.config/systemd/user/default.target.wants
	ln -s /usr/lib/systemd/user/dpms-lcd.service /home/$USER/.config/systemd/user/default.target.wants/dpms-lcd.service
	chown $USER:$USER /home/$USER/.config -R
	reboot
fi

# Udhcpc for 4G
if [ -f /etc/udhcpc/default.script ]; then
        mkdir /usr/share/udhcpc -p
        ln -sf /etc/udhcpc/default.script /usr/share/udhcpc/default.script
fi

#
# Hold raspberrypi firmware which will break system driver
# if you know follow, and want to upgrade kernel,
# run "apt-mark unhold raspberrypi-kernel raspberrypi-kernel-headers raspberrypi-sys-mods raspberrypi-ui-mods"
# if you upgrade kernel, some driver may not work, for example touchscreen, lcd and so on
# find driver from https://github.com/Chipsee/industrial-pi
# 
#apt-mark hold raspberrypi-kernel raspberrypi-kernel-headers raspberrypi-sys-mods raspberrypi-ui-mods linux-headers


exit 0
