EXTRA_CFLAGS +=-Wno-error=date-time
EXTRA_CFLAGS +=-Wno-date-time
DEPMOD  = /sbin/depmod
FWLOC:= $(shell /usr/lib/raspberrypi-sys-mods/get_fw_loc)
CROSS_COMPILE ?=
KVER ?= $(shell uname -r)

all: install

compile:
	dtc -@ -I dts -O dtb -o pwm-backlight.dtbo pwm-backlight-overlay.dts

install: compile
	mkdir -p $(TP)$(FWLOC)/overlays
	install -p -m 644 -D pwm-backlight.dtbo $(FWLOC)/overlays/
	install -p -m 644 -D pwm-backlight.dtbo $(TP)$(FWLOC)/overlays/

clean:
	rm $(FWLOC)/overlays/pwm-backlight.dtbo
	rm pwm-backlight.dtbo
