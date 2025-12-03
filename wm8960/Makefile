DEPMOD  = /sbin/depmod
CROSS_COMPILE ?=
FWLOC:= $(shell /usr/lib/raspberrypi-sys-mods/get_fw_loc)
KVER  ?= $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
MODDESTDIR := $(INSTALL_MOD_PATH)/usr/lib/modules/$(KVER)/kernel/sound/soc/codecs/
MODULE_NAME := snd-soc-wm8960

# If KERNELRELEASE is defined, we've been invoked from the
# kernel build system and can use its language
#ifneq ($(KERNELRELEASE),)
#$(warning KERNELVERSION=$(KERNELVERSION))

#$(MODULE_NAME)-objs := wm8960.o 

#obj-m += $(MODULE_NAME).o

ifdef DEBUG
ifneq ($(DEBUG),0)
        ccflags-y += -DDEBUG -DAC101_DEBG
endif
endif

#else

$(MODULE_NAME)-y += wm8960.o

obj-m := $(MODULE_NAME).o

all: install

compile:
	make -C $(KSRC) M=`pwd` modules
	dtc -@ -I dts -O dtb -o seeed-2mic-voicecard.dtbo seeed-2mic-voicecard-overlay.dts

install: compile
	mkdir -p $(TP)$(FWLOC)/overlays
	install -p -m 644 -D $(MODULE_NAME).ko $(MODDESTDIR)$(MODULE_NAME).ko
	install -p -m 644 -D $(MODULE_NAME).ko $(TP)$(MODDESTDIR)$(MODULE_NAME).ko
	install -p -m 644 -D seeed-2mic-voicecard.dtbo $(FWLOC)/overlays/seeed-2mic-voicecard.dtbo
	install -p -m 644 -D seeed-2mic-voicecard.dtbo $(TP)$(FWLOC)/overlays/seeed-2mic-voicecard.dtbo
	install -p -m 644 -D asound_2mic.conf /opt/chipsee/voicecard/asound_2mic.conf
	install -p -m 644 -D asound_2mic.conf $(TP)/opt/chipsee/voicecard/asound_2mic.conf
	install -p -m 644 -D wm8960_asound.state /opt/chipsee/voicecard/wm8960_asound.state
	install -p -m 644 -D wm8960_asound.state $(TP)/opt/chipsee/voicecard/wm8960_asound.state
	$(DEPMOD) -a ${KVER}

clean:
	make -C $(KSRC) M=`pwd` clean
	rm $(MODDESTDIR)$(MODULE_NAME).ko
	rm $(FWLOC)/overlays/seeed-2mic-voicecard.dtbo
	rm /opt/chipsee/voicecard/asound_2mic.conf
	rm /opt/chipsee/voicecard/wm8960_asound.state
	$(DEPMOD) -a ${KVER}

cleancur:
	make -C $(KSRC) M=`pwd` clean

#endif
