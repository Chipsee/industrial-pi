DEPMOD  = /sbin/depmod
ARCH := arm
CROSS_COMPILE ?=
KVER  ?= $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
MODDESTDIR := $(INSTALL_MOD_PATH)/usr/lib/modules/$(KVER)/kernel/sound/soc/codecs/
MODULE_NAME := snd-soc-es8388

ifdef DEBUG
ifneq ($(DEBUG),0)
        ccflags-y += -DDEBUG -DAC101_DEBG
endif
endif

$(MODULE_NAME)-y += es8388.o

obj-m := $(MODULE_NAME).o

all: install

compile:
	make -C $(KSRC) M=`pwd` modules
	dtc -@ -I dts -O dtb -o es8388.dtbo es8388-overlay.dts

install: compile
	mkdir -p $(TP)/boot/overlays
	mkdir -p $(TP)/opt/chipsee/voicecard/
	mkdir -p /opt/chipsee/voicecard/
	install -p -m 644 -D $(MODULE_NAME).ko $(MODDESTDIR)$(MODULE_NAME).ko
	install -p -m 644 -D $(MODULE_NAME).ko $(TP)$(MODDESTDIR)$(MODULE_NAME).ko
	install -p -m 644 -D es8388.dtbo /boot/overlays/es8388.dtbo
	install -p -m 644 -D es8388.dtbo $(TP)/boot/overlays/es8388.dtbo
	install -p -m 644 -D es8388.conf /opt/chipsee/voicecard/
	install -p -m 644 -D es8388.conf $(TP)/opt/chipsee/voicecard/
	install -p -m 644 -D es8388_asound.state /opt/chipsee/voicecard/
	install -p -m 644 -D es8388_asound.state $(TP)/opt/chipsee/voicecard/
	$(DEPMOD) -a ${KVER}

clean:
	make -C $(KSRC) M=`pwd` clean
	rm $(MODDESTDIR)$(MODULE_NAME).ko
	rm /boot/overlays/es8388.dtbo
	rm /opt/chipsee/voicecard/es8388.conf
	rm /opt/chipsee/voicecard/es8388_asound.state
	$(DEPMOD) -a ${KVER}

cleancur:
	make -C $(KSRC) M=`pwd` clean
