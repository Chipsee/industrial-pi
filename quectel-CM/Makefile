ifneq ($(CROSS_COMPILE),)
CROSS-COMPILE:=$(CROSS_COMPILE)
endif
CC:=$(CROSS-COMPILE)gcc
LD:=$(CROSS-COMPILE)ld

all: release

release: clean
	$(CC) -Wall -s QmiWwanCM.c GobiNetCM.c main.c MPQMUX.c QMIThread.c util.c udhcpc.c -o quectel-CM -lpthread
	install -p -m 777 -D quectel-CM /usr/bin/quectel-CM
	apt-get install -y udhcpc > /dev/nul

debug: clean
	$(CC) -Wall -g QmiWwanCM.c GobiNetCM.c main.c MPQMUX.c QMIThread.c util.c udhcpc.c -o quectel-CM -lpthread

clean:
	rm -rf quectel-CM *~
	rm -rf /usr/bin/quectel-CM
