#!/bin/sh

TOPDIR=`pwd`
ORICONF=/boot/firmware/config.txt
ORIAARCH64CONF=${TOPDIR}/base/aarch64-config.txt
ORIARMV7LCONF=${TOPDIR}/base/armv7l-config.txt

if [ ! -f  $ORIAARCH64CONF ]; then
	echo "there is no aarch64 config file"
	exit 1
fi

if [ ! -f  $ORIARMV7LCONF ]; then
	echo "there is no armv7l config file"
	exit 1
fi

for i in `ls ${TOPDIR}/base/config*`; do 
        CONFBASE=`echo $i | awk -F '/' '{print $NF}' | awk '{print substr($0, 1, length($0)-4)}'`
	AARCH64CONF=${CONFBASE}-aarch64.txt
	ARMV7LCONF=${CONFBASE}-armv7l.txt

        #echo $i $CONFBASE
	#echo $AARCH64CONF
	#echo $ARMV7LCONF

	cp $ORIAARCH64CONF $AARCH64CONF
	cat $i >> $AARCH64CONF

	cp $ORIARMV7LCONF $ARMV7LCONF
	cat $i >> $ARMV7LCONF
done;
