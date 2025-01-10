#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "av4helper_core.h"

int main(int argc, char *argv[])
{
	int fd, ret;

	if (argc != 2) {
		printf("Usage: %s <on|off>\n", argv[0]);
		return 1;
	}

	fd = cs_init();
	if (fd < 0 ) {
              printf("buzzer init error");
              return fd;
        }

	if(strcmp(argv[1], "on") == 0) {
		cs_open_buzzer(fd);
	} else if (strcmp(argv[1], "off") == 0) {
		cs_close_buzzer(fd);
	} else {
		printf("Invalid argument. Use 'on' or 'off'.\n");
		return 1;
	}

	cs_deinit(fd);

	return 0;
}
