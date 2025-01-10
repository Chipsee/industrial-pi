DEPMOD  = /sbin/depmod
CROSS_COMPILE ?=
FWLOC:= $(shell /usr/lib/raspberrypi-sys-mods/get_fw_loc)
KVER  := $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
MODDESTDIR := $(INSTALL_MOD_PATH)/usr/lib/modules/$(KVER)/kernel/drivers/net/can/spi/mcp251xfd/
MODULE_NAME := mcp251xfd

ifdef DEBUG
ifneq ($(DEBUG),0)
        ccflags-y += -DDEBUG -DAC101_DEBG
endif
endif

mcp251xfd-objs :=
mcp251xfd-objs += mcp251xfd-chip-fifo.o
mcp251xfd-objs += mcp251xfd-core.o
mcp251xfd-objs += mcp251xfd-crc16.o
mcp251xfd-objs += mcp251xfd-ethtool.o
mcp251xfd-objs += mcp251xfd-ram.o
mcp251xfd-objs += mcp251xfd-regmap.o
mcp251xfd-objs += mcp251xfd-ring.o
mcp251xfd-objs += mcp251xfd-rx.o
mcp251xfd-objs += mcp251xfd-tef.o
mcp251xfd-objs += mcp251xfd-timestamp.o
mcp251xfd-objs += mcp251xfd-tx.o
mcp251xfd-objs += mcp251xfd-dump.o

$(MODULE_NAME)-y += $(mcp251xfd-objs)

obj-m := $(MODULE_NAME).o

all: install

compile:
	make -C $(KSRC) M=`pwd` modules

install: compile
	@if [ -f $(MODDESTDIR)$(MODULE_NAME).ko.xz ]; then \
		rm $(MODDESTDIR)$(MODULE_NAME).ko.xz; \
	fi
	install -p -m 644 -D $(MODULE_NAME).ko $(MODDESTDIR)$(MODULE_NAME).ko
	install -p -m 644 -D $(MODULE_NAME).ko $(TP)$(MODDESTDIR)$(MODULE_NAME).ko
	$(DEPMOD) -a ${KVER}

clean:
	make -C $(KSRC) M=`pwd` clean
	#rm $(MODDESTDIR)$(MODULE_NAME).ko
	#$(DEPMOD) -a ${KVER}

#endif
