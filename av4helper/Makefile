ifneq ($(CROSS_COMPILE),)
CROSS-COMPILE:=$(CROSS_COMPILE)
endif
CC:=$(CROSS-COMPILE)gcc
LD:=$(CROSS-COMPILE)ld

all: release

release: clean
	$(CC) av4helper_core.c av4_buzzer.c -o av4_buzzer
	$(CC) av4helper_core.c buzzer.c -o buzzer
	$(CC) av4helper_core.c av4helper.c -o av4helper
	install -p -m 777 -D av4_buzzer /usr/bin/av4_buzzer
	install -p -m 777 -D av4_buzzer $(TP)/usr/bin/av4_buzzer
	install -p -m 777 -D av4helper /usr/bin/av4helper
	install -p -m 777 -D av4helper $(TP)/usr/bin/av4helper

clean:
	rm -rf *.o av4_buzzer av4helper buzzer
	rm -rf /usr/bin/av4helper
	rm -rf /usr/bin/av4_buzzer

cleancur:
	rm -rf *.o av4_buzzer av4helper buzzer
