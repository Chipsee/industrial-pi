#!/bin/bash

set +e

FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'pi' '$5$cOHLmNrEWu$7Mm1Ien61LmISTYOr0c0bZ28iNgsbuvtu.1tX9V4878'
else
   echo "$FIRSTUSER:"'$5$cOHLmNrEWu$7Mm1Ien61LmISTYOr0c0bZ28iNgsbuvtu.1tX9V4878' | chpasswd -e
   if [ "$FIRSTUSER" != "pi" ]; then
      usermod -l "pi" "$FIRSTUSER"
      usermod -m -d "/home/pi" "pi"
      groupmod -n "pi" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=pi/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/pi/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /pi /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi

# Auto login
if [ ! -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
    mkdir /etc/systemd/system/getty@tty1.service.d/ -p
cat >/etc/systemd/system/getty@tty1.service.d/autologin.conf <<'AEOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I xterm
AEOF
    systemctl daemon-reload
fi
if grep -q "^#autologin-user=" /etc/lightdm/lightdm.conf ; then
    sed /etc/lightdm/lightdm.conf -i -e "s/^#autologin-user=/autologin-user=pi/"
fi

if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_wlan 'Chipsee' '1c7ea2c5cc3fbf9802dddacb94968df9da7423db4fbc9a634110398d5a6c9b50' 'CN'
else
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	ssid="Chipsee"
	psk=1c7ea2c5cc3fbf9802dddacb94968df9da7423db4fbc9a634110398d5a6c9b50
}

WPAEOF
   chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
   rfkill unblock wifi
   for filename in /var/lib/systemd/rfkill/*:wlan ; do
       echo 0 > $filename
   done
fi
rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0
