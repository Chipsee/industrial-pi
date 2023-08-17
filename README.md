# Introduction
We will use this repo to contain the source code and config for Chipsee Raspberry Computer Module Hardware.

# Supported Raspberry Official System
This repository only support follow [Raspberry Pi official system](https://www.raspberrypi.org/software/operating-systems/) now:
 - 2019-04-08-raspbian-stretch (Not support CM4 products)
 - 2020-02-13-raspbian-buster
 - 2020-12-02-raspios-buster
 - 2021-10-30-raspios-bullseye
 - 2022-9-22-raspios-bullseye

# How to use
## 1. Prepare system
Install Raspberry Pi official system and boot, run follow commands in ssh or serial debug console. The Chipsee Industrial-Pi network and serial debug port is supported by Raspberry Pi official system default. 

## 2. Download industrial-pi repository
This repository only supports tested kernel version listed in branches. If the kernel version of your system is not in the branches lists, you should select one closer kernel version that you had.
If your kernel version is listed in the branches,use follow commands,
```
git clone --depth=1 --branch `uname -r` https://github.com/Chipsee/industrial-pi.git
```
If there is some error about branch, check if the kernel you are using is listed in the branchs, if not, check the following section, or ignore it.

## ISSUE: The kernel version you are using is not listed in the branches?
If your kernel version is not listed in the branches, checkout the branches closer to your kernel,
check your kernel,
```
uname -r
```
select one closer branches, for example your kernel version is 5.10.17-v71+, you can select 5.10.63-v71+ branches
```
git clone --depth=1 --branch 5.10.63-v71+ https://github.com/Chipsee/industrial-pi.git
```
and do the following modification
```
1. modify Makefile
diff --git a/Makefile b/Makefile
index b98ad3c..98de440 100644
--- a/Makefile
+++ b/Makefile
@@ -28,7 +28,6 @@ help:
 ##############################################################
 install:
        @apt-get update
-       @dpkg -i $(TOPDIR)/tools/*.deb
        @make -C $(GT9XX_DIR)
        @echo "Install GT9XX success!!"
        @make -C $(LSM6DS3_DIR)

2. install raspberrypi-kernel-headers packages
sudo apt update
sudo apt install raspberrypi-kernel-headers
```

## 3. Compile and install
```
cd industrial-pi
sudo make install
```
If there is no error, reboot your board.

## 4. Uninstall
```
cd industrial-pi
sudo make uninstall
```
## 5. More commands
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
 - AIO-CM4-101(CS12800RA4101A)
 - CS12720RA4050 (from 2021-10-30 V2 image)
 - CS12800RA4101P (from 2021-10-30 V2 image)
 - CS10768RA4121P (from 2021-10-30 V2 image)
 - CS19108RA4133P (from 2021-10-30 V2 image)
 - CS10768RA4150P (from 2021-10-30 V2 image)
 - CS19108RA4156P (from 2021-10-30 V2 image)
 - CS19108RA4215P (from 2021-10-30 V2 image)
 - CS19108RA4236P (from 2021-10-30 V2 image)
 - CS10600RA4070D (from 2022-09-22 V3 image)


# Latest system images
 **2022-09-22 V3 64bit**
 - Desktop with small software [2022-09-22-raspios-bullseye-arm64-chipsee-v3.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20220922/bullseye-arm64/2022-09-22-raspios-bullseye-arm64-chipsee-v3.img.xz)
 - Lite [2022-09-22-raspios-bullseye-arm64-lite-chipsee-v3.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20220922/bullseye-arm64/2022-09-22-raspios-bullseye-arm64-lite-chipsee-v3.img.xz)

**2021-10-30 V2 32bit**
 - Desktop with Full software [2021-10-30-raspios-bullseye-armhf-full-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-full-chipsee-v2.img.xz)
 - Desktop with small software [2021-10-30-raspios-bullseye-armhf-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-chipsee-v2.img.xz)
 - Lite [2021-10-30-raspios-bullseye-armhf-lite-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-lite-chipsee-v2.img.xz)

# Release notes

**2022-9-22 V2:**

- First released 64bit system
- 32bit system will be released later.
- Hold the kernel package, you can upgrade other software by using "apt-get upgrade" commands.

**2021-10-30 V2:**

- Add CS12720RA4050 CS12800RA4101P CS19108RA4133P CS10768RA4150P CS19108RA4156P support.
- Bug Fix: LCDTest of Hardwaretest application don't work.
- Known bugs: CAN bus will fail to bring up if you don't add 120R resistor between CAN_H and CAN_L.

**2021-10-30 V1:**

- First release for Debian 11(bullseye)
- Known bugs: CAN bus will fail to bring up if you don't add 120R resistor between CAN_H and CAN_L.

**2020-12-02 V4:**

- Disable Screen Blank Feature.
- Add Chipsee Hardwaretest Applications.
- Bug Fix: some 7" and 10.1" LCD display issue.

**2020-12-02 V3:**

- Add PWM backlight support.
- Add warning about updating system and disable updating system automatically on system fisrtboot.
- Automatically load WiFi/Bt and disable SD slot as WiFi/Bt and SD slot can't be use at same time.

# Older system images
 **2022-09-22 V2 64bit:**
 - Desktop with small software [2022-09-22-raspios-bullseye-arm64-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20220922/bullseye-arm64/2022-09-22-raspios-bullseye-arm64-chipsee-v2.img.xz)
 - Lite [2022-09-22-raspios-bullseye-arm64-lite-chipsee-v2.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20220922/bullseye-arm64/2022-09-22-raspios-bullseye-arm64-lite-chipsee-v2.img.xz)
 
 **2021-10-30 V1:**
 - Desktop with Full software [2021-10-30-raspios-bullseye-armhf-full-chipsee-v1.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-full-chipsee-v1.img.xz)
 - Desktop with small software [2021-10-30-raspios-bullseye-armhf-chipsee-v1.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-chipsee-v1.img.xz)
 - Lite [2021-10-30-raspios-bullseye-armhf-lite-chipsee-v1.img.xz](https://chipsee-tmp.s3.amazonaws.com/mksdcardfiles/RaspberryPi/20211030/2021-10-30-raspios-bullseye-armhf-lite-chipsee-v1.img.xz)
 
 > The follow older buster release use old firmware, it doesn't support latest CM4 Rev1.1, for detailt product change note, refer to [CM4 PCN](https://pip.raspberrypi.com/categories/645)
 
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

