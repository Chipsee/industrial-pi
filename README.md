# Introduction
We will use this repo to contain the source code and config for Chipsee Raspberry Computer Module Hardware.

## Supported Raspberry Official System
This repository only support follow [Raspberry Pi official system](https://www.raspberrypi.org/downloads/raspbian/) now:
 - 2019-04-08-raspbian-stretch
 - 2020-02-13-raspbian-buster

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
