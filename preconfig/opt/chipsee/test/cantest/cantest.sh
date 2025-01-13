#!/bin/sh


sudo ip link set can0 down
sudo ip link set can0 type can bitrate 1000000
sudo ip link set can0 up
candump can0 &

sleep 20

i=1000
while [ $i -gt 0 ]; do
echo $i
sudo cansend can0 5A1#11.2233.44556677.88
i=`expr $i - 1`
done
