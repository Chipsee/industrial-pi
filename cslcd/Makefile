DEPMOD  = /sbin/depmod
ARCH := arm
CROSS_COMPILE ?=
KVER  := $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
MODDESTDIR := $(INSTALL_MOD_PATH)/lib/modules/$(KVER)/kernel/drivers/

MODULE_NAME := cs_lcd

obj-m := $(MODULE_NAME).o

all: compile

compile:
	make -C $(KSRC) M=`pwd` modules
	$(DEPMOD) -a ${KVER}
clean:
	make -C $(KSRC) M=`pwd` clean
	$(DEPMOD) -a ${KVER}
