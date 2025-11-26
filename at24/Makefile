EXTRA_CFLAGS +=-Wno-error=date-time
EXTRA_CFLAGS +=-Wno-date-time
DEPMOD  = /sbin/depmod
FWLOC:= $(shell /usr/lib/raspberrypi-sys-mods/get_fw_loc)
CROSS_COMPILE ?=
KVER ?= $(shell uname -r)

all: install

compile:
	dtc -@ -I dts -O dtb -o i2c-at24.dtbo i2c-at24-overlay.dts

install: compile
	mkdir -p $(TP)$(FWLOC)/overlays
	install -p -m 644 -D i2c-at24.dtbo $(FWLOC)/overlays/
	install -p -m 644 -D i2c-at24.dtbo $(TP)$(FWLOC)/overlays/

clean:
	rm $(FWLOC)/overlays/i2c-at24.dtbo
	rm i2c-at24.dtbo
