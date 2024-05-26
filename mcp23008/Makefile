EXTRA_CFLAGS +=-Wno-error=date-time
EXTRA_CFLAGS +=-Wno-date-time
DEPMOD  = /sbin/depmod
FWLOC:= $(shell /usr/lib/raspberrypi-sys-mods/get_fw_loc)
CROSS_COMPILE ?=
KVER := $(shell uname -r)

all: install

compile:
	dtc -@ -I dts -O dtb -o mcp23017.dtbo mcp23017-overlay.dts

install: compile
	mkdir -p $(TP)$(FWLOC)/overlays
	install -p -m 644 -D mcp23017.dtbo $(FWLOC)/overlays/
	install -p -m 644 -D mcp23017.dtbo $(TP)$(FWLOC)/overlays/

clean:
	rm $(FWLOC)/overlays/mcp23017.dtbo
	rm mcp23017.dtbo
