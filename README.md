# Introduction
We will use this repo to contain the source code and config for Chipsee Raspberry Computer Module Hardware.

# How to use
## Prepare system
You can install raspberry pi official system, please reference [raspbian.](https://www.raspberrypi.org/downloads/raspbian/)
## Download industrial-pi repository
```
git clone --depth=1 --branch `uname -r` https://github.com/Chipsee/industrial-pi.git
```
## Compile and install
```
cd industrial-pi
sudo make install
```
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
