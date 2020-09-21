#!/bin/sh
canport=$1

echo ""
echo "Can0 init ..."
echo ""
./canconfig $canport stop
./canconfig $canport bitrate 10000 ctrlmode triple-sampling on loopback off
./canconfig $canport start
echo ""
echo "$canport inited!!"
echo ""

echo "$canport send date five times ..."
i=0
while [ $i -lt 5 ]
do
i=`expr $i + 1`
./cansend $canport 0x11 0x22 0x33 0x44 0x55 0x66 0x77 0x88
sleep 1
done
echo ""
echo "$canport dump date in background"
./candump $canport &

echo "Can Tested done!!"
