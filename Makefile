EXTRA_CFLAGS +=-Wno-error=date-time
EXTRA_CFLAGS +=-Wno-date-time
DEPMOD  = /sbin/depmod
ARCH := arm
CROSS_COMPILE ?=
KVER  := $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
MODDESTDIR := $(INSTALL_MOD_PATH)/lib/modules/$(KVER)/kernel/drivers/input/touchscreen/

MODULE_NAME := gt911

gt9xx_core := gt9xx_update.o goodix_tool.o gt9xx.o

$(MODULE_NAME)-y += $(gt9xx_core)

obj-m := $(MODULE_NAME).o

all:
	make -C $(KSRC) M=`pwd` modules

install:
	install -p -m 644 -D $(MODULE_NAME).ko $(MODDESTDIR)$(MODULE_NAME).ko
	$(DEPMOD) -a ${KVER}

clean:
	make -C $(KSRC) M=`pwd` clean

rm:
	rm $(MODDESTDIR)$(MODULE_NAME).ko
