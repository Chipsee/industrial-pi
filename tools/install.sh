#!/bin/bash

KVR=`uname -r`
PKG=$KVR.tar.gz

if [ $UID -eq "0" ]; then
   echo "You are in root, continue!!"
else
   echo "Must use root to exec!! sudo ./install.sh" 
   exit 0
fi

echo "Welcom To install Chipsee package for Pi $KVR"

if [ -f $PKG ]; then
    tar zxvfm $PKG -C /
    # Used by systemd services
    systemctl daemon-reload
    systemctl enable chipsee-init.service
    systemctl disable hciuart
    # Used by modules
    depmod -a $KVR
    # Used by quectel-CM
    apt-get -y install udhcpc
    echo "Install Done!!"
else
    echo "There is no $PKG"
fi
