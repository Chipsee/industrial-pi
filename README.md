# Introduction
We will use this repo to contain the source code and config for Chipsee Raspberry Computer Module Hardware.

# Supported Raspberry Official System
This repository only support follow [Raspberry Pi official system](https://www.raspberrypi.org/software/operating-systems/) now:
 - 2019-04-08-raspbian-stretch (Not support CM4 products)
 - 2020-02-13-raspbian-buster
 - 2020-12-02-raspios-buster

# How to use
## Prepare system
Install Raspberry Pi official system and boot, run follow commands in ssh or serial debug console. The Chipsee Industrial-Pi network and serial debug port is supported by Raspberry Pi official system default. 
## Download industrial-pi repository
```
git clone --depth=1 --branch `uname -r` https://github.com/Chipsee/industrial-pi.git
```
## Compile and install
```
cd industrial-pi
sudo make install
```
If there is no error, reboot your board.

## Uninstall
```
cd industrial-pi
sudo make uninstall
```
## More commands
```
cd industrial-pi
make help
```

# Supported Chipsee Board
This repository only support follow Chipsee Industrial Board:
 - CS10600RA070-V1.0
 - CS12800RA101-V1.0
 - CS10600RA4070-V1.0
 - LRRA4-101-V1.0

# Latest system image
 - Desktop with Full software [2020-12-02-raspios-buster-armhf-full-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-full-chipsee-v2.img.xz)
 - Desktop with small software [2020-12-02-raspios-buster-armhf-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-chipsee-v2.img.xz)
 - Lite [2020-12-02-raspios-buster-armhf-lite-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-lite-chipsee-v2.img.xz)

