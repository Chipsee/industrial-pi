EXTRA_CFLAGS +=-Wno-tautological-compare
EXTRA_CFLAGS +=-Wno-format-overflow
EXTRA_CFLAGS +=-Wno-unused-const-variable
CFLAGS += $(EXTRA_CFLAGS)

ifneq ($(CROSS_COMPILE),)
CROSS-COMPILE:=$(CROSS_COMPILE)
endif
CC:=$(CROSS-COMPILE)gcc
LD:=$(CROSS-COMPILE)ld

all: release

release: clean
	$(CC) $(CFLAGS) -Wall -s QmiWwanCM.c GobiNetCM.c main.c MPQMUX.c QMIThread.c util.c udhcpc.c -o quectel-CM -lpthread
	install -p -m 777 -D quectel-CM /usr/bin/quectel-CM
	install -p -m 777 -D quectel-CM $(TP)/usr/bin/quectel-CM
	apt-get update > /dev/null
	apt-get install -y udhcpc > /dev/null

debug: clean
	$(CC) $(CFLAGS) -Wall -g QmiWwanCM.c GobiNetCM.c main.c MPQMUX.c QMIThread.c util.c udhcpc.c -o quectel-CM -lpthread

clean:
	rm -rf quectel-CM *~
	rm -rf /usr/bin/quectel-CM
