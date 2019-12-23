DEPMOD  = /sbin/depmod
ARCH := arm
CROSS_COMPILE ?=
KVER  := $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
MODDESTDIR := $(INSTALL_MOD_PATH)/lib/modules/$(KVER)/kernel/drivers/input/misc/

MODULE_NAME := lsm6ds3
lsm6ds3-core += lsm6ds3_core.o lsm6ds3_i2c.o
$(MODULE_NAME)-y += $(lsm6ds3-core)

obj-m := $(MODULE_NAME).o

all: install

compile:
	make -C $(KSRC) M=`pwd` modules

install: compile
	install -p -m 644 -D $(MODULE_NAME).ko $(MODDESTDIR)$(MODULE_NAME).ko
	$(DEPMOD) -a ${KVER}

clean:
	make -C $(KSRC) M=`pwd` clean
	rm $(MODDESTDIR)$(MODULE_NAME).ko
	$(DEPMOD) -a ${KVER}
