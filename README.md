# Introduction
We will use this repo to contain the source code and config for Chipsee Raspberry Computer Module Hardware.

# Supported Raspberry Official System
This repository only support follow [Raspberry Pi official system](https://www.raspberrypi.org/software/operating-systems/) now:
 - 2019-04-08-raspbian-stretch (Not support CM4 products)
 - 2020-02-13-raspbian-buster
 - 2020-12-02-raspios-buster
 - 2021-10-30-raspios-bullseye

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
This repository only support follow Chipsee Industrial Board, you can order them from the official Chipsee Web [chipsee web site](https://chipsee.com/product-category/ipc/arm-raspberry-pi/) or from your nearest distributor.
 - CS10600RA070
 - CS12800RA101
 - CS10600RA4070
 - CS12800RA4101
 - AIO-CM4-101
 - CS12720RA4050 (New, Latest system image support it)
 - CS12800RA4101P (New, Latest system image support it)
 - CS19108RA4133P (New, Latest system image support it)
 - CS10768RA4150P (New, Latest system image support it)
 - CS19108RA4156P (New, Latest system image support it)

# Latest system images
 - Desktop with Full software [2021-10-30-raspios-bullseye-armhf-full-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-full-chipsee-v2.img.xz)
 - Desktop with small software [2021-10-30-raspios-bullseye-armhf-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-chipsee-v2.img.xz)
 - Lite [2021-10-30-raspios-bullseye-armhf-lite-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-lite-chipsee-v2.img.xz)

# Release notes

**2021-10-30 V1:**

- Add CS12720RA4050 CS12800RA4101P CS19108RA4133P CS10768RA4150P CS19108RA4156P support.
- Bug Fix: LCDTest of Hardwaretest application don't work.
- Known bugs: CAN bus will fail to bring up.

**2021-10-30 V1:**

- First release for Debian 11(bullseye)
- Known bugs: CAN bus will fail to bring up.

**2020-12-02 V4:**

- Disable Screen Blank Feature.
- Add Chipsee Hardwaretest Applications.
- Bug Fix: some 7" and 10.1" LCD display issue.

**2020-12-02 V3:**

- Add PWM backlight support.
- Add warning about updating system and disable updating system automatically on system fisrtboot.
- Automatically load WiFi/Bt and disable SD slot as WiFi/Bt and SD slot can't be use at same time.

# Older system images
 
 **2021-10-30 V1:**
 - Desktop with Full software [2021-10-30-raspios-bullseye-armhf-full-chipsee-v1.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-full-chipsee-v1.img.xz)
 - Desktop with small software [2021-10-30-raspios-bullseye-armhf-chipsee-v1.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-chipsee-v1.img.xz)
 - Lite [2021-10-30-raspios-bullseye-armhf-lite-chipsee-v1.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-lite-chipsee-v1.img.xz)
 
 **2020-12-02 V4:**
 - [2020-12-02-raspios-buster-armhf-full-chipsee-v4.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-full-chipsee-v4.img.xz)
 - [2020-12-02-raspios-buster-armhf-chipsee-v4.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-chipsee-v4.img.xz)
 - [2020-12-02-raspios-buster-armhf-lite-chipsee-v4.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-lite-chipsee-v4.img.xz)
 
 **2020-12-02 V3:**
 - [2020-12-02-raspios-buster-armhf-full-chipsee-v3.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-full-chipsee-v3.img.xz)
 - [2020-12-02-raspios-buster-armhf-chipsee-v3.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-chipsee-v3.img.xz)
 - [2020-12-02-raspios-buster-armhf-lite-chipsee-v3.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-lite-chipsee-v3.img.xz)
 
 **2020-12-02 V2:**
 - [2020-12-02-raspios-buster-armhf-full-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-full-chipsee-v2.img.xz)
 - [2020-12-02-raspios-buster-armhf-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-chipsee-v2.img.xz)
 - [2020-12-02-raspios-buster-armhf-lite-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20201202/2020-12-02-raspios-buster-armhf-lite-chipsee-v2.img.xz)

