#!/bin/sh
while [ 1 ] 
do
echo "-------H-------"
for i in 1 2 3 4; do
echo 1 > /dev/chipsee-gpio$i
done
sleep 1
for i in 5 6 7 8; do
cat /dev/chipsee-gpio$i
done
echo 1 > /dev/buzzer
sleep 1
echo 0 > /dev/buzzer
echo "-------L-------"
for i in 1 2 3 4; do
echo 0 > /dev/chipsee-gpio$i
done
sleep 1
for i in 5 6 7 8; do
cat /dev/chipsee-gpio$i
done
sleep 2
done
