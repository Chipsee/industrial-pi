EXTRA_CFLAGS +=-Wno-error=date-time
EXTRA_CFLAGS +=-Wno-date-time
DEPMOD  = /sbin/depmod
ARCH := arm
CROSS_COMPILE ?=
KVER  := $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
MODDESTDIR := $(INSTALL_MOD_PATH)/usr/lib/modules/$(KVER)/kernel/drivers/video/backlight/

MODULE_NAME := pwm_bl

obj-m := $(MODULE_NAME).o

all: install

compile:
	make -C $(KSRC) M=`pwd` modules
	dtc -@ -I dts -O dtb -o pwm-backlight.dtbo pwm-backlight-overlay.dts

install: compile
	mkdir -p $(TP)/boot/overlays
	install -p -m 644 -D $(MODULE_NAME).ko $(MODDESTDIR)$(MODULE_NAME).ko
	install -p -m 644 -D $(MODULE_NAME).ko $(TP)$(MODDESTDIR)$(MODULE_NAME).ko
	install -p -m 644 -D pwm-backlight.dtbo /boot/overlays/
	install -p -m 644 -D pwm-backlight.dtbo $(TP)/boot/overlays/
	$(DEPMOD) -a ${KVER}

clean:
	make -C $(KSRC) M=`pwd` clean
	rm $(MODDESTDIR)$(MODULE_NAME).ko
	rm /boot/overlays/pwm-backlight.dtbo
	rm pwm-backlight.dtbo
	$(DEPMOD) -a ${KVER}
