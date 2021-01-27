EXTRA_CFLAGS +=-Wno-error=date-time
EXTRA_CFLAGS +=-Wno-date-time
DEPMOD  = /sbin/depmod
ARCH := arm
CROSS_COMPILE ?=
KVER  := $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
MODDESTDIR := $(INSTALL_MOD_PATH)/usr/lib/modules/$(KVER)/kernel/drivers/input/touchscreen/

MODULE_NAME := gt9xx

gt9xx_core := gt9xx_update.o goodix_tool.o gt9xx_i2c.o

$(MODULE_NAME)-y += $(gt9xx_core)

obj-m := $(MODULE_NAME).o

all: install

compile:
	make -C $(KSRC) M=`pwd` modules
	dtc -@ -I dts -O dtb -o gt9xx.dtbo gt9xx-overlay.dts

install: compile
	mkdir -p $(TP)/boot/overlays
	install -p -m 644 -D $(MODULE_NAME).ko $(MODDESTDIR)$(MODULE_NAME).ko
	install -p -m 644 -D $(MODULE_NAME).ko $(TP)$(MODDESTDIR)$(MODULE_NAME).ko
	install -p -m 644 -D gt9xx.dtbo /boot/overlays/
	install -p -m 644 -D gt9xx.dtbo $(TP)/boot/overlays/
	
	$(DEPMOD) -a ${KVER}

clean:
	make -C $(KSRC) M=`pwd` clean
	rm $(MODDESTDIR)$(MODULE_NAME).ko
	rm /boot/overlays/gt9xx.dtbo
	rm gt9xx.dtbo
	$(DEPMOD) -a ${KVER}
