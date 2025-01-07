#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "av4helper_core.h"

#define DEBUG_ON 1
#define CS_DEBUG(fmt,arg...)   do{ \
                                    if(DEBUG_ON) \
                                    printf("<<CS_DEBUG->> [%d]"fmt"\n",__LINE__, ##arg); \
                                }while(0)

typedef struct {
        const char *cmd;
        int (*action)(int);
} command_t;

static command_t cs_av4helper_command_table[] = {
	{"",NULL},
	{"open_buzzer",cs_open_buzzer},
	{"close_buzzer",cs_close_buzzer},
	{"set_auto_boot",cs_set_auto_boot},
	{"set_manual_boot",cs_set_manual_boot},
};

void show_cs_av4helper_cmd() {
        unsigned int i;
        printf("#### Please Input Your Test Command Index ####\n");
        for (i = 1; i < sizeof(cs_av4helper_command_table) / sizeof(command_t); i++) {
                printf("%d.  %s \n", i, cs_av4helper_command_table[i].cmd);
        }
        printf("Which would you like(only support 1 - %d)[Ctrl+C quit]: ",i);
}

int cs_av4helper_test_config(int fd)
{
        int i, item_cnt, ret;
	u8 data;

        item_cnt = sizeof(cs_av4helper_command_table) / sizeof(command_t);

        while(1) {
   		ret = cs_get_buzzer_oc_status(fd, &data);  
   		if (ret < 0 ) {
         			CS_DEBUG("%s error.", __func__);
         			return ret;
   		}
   		printf("BUZZER(open/close): %s\n", data?"OPEN":"CLOSE");

   		ret = cs_get_bootmode(fd, &data);  
   		if (ret < 0 ) {
         			CS_DEBUG("%s error.", __func__);
         			return ret;
   		}
   		printf("BOOTMODE(AUTO/MANUAL): %s\n", data?"MANUAL":"AUTO");

                show_cs_av4helper_cmd();
		scanf("%d",&i);

                if ((i >= 1) && (i < item_cnt)) {
                	ret = cs_av4helper_command_table[i].action(fd);
			if(ret < 0 )
			{
				CS_DEBUG("%s error.",cs_av4helper_command_table[i].cmd);
				return ret;
			}
		}

		printf("\n\n");

		Delay_ms(10);
        }

        return 0;
}

int main()
{
	int fd, ret;
        u8 data,major,minor;
	fd = cs_init();
	if (fd < 0 ) {
              CS_DEBUG("cs_av4helper init error");
              return fd;
        }

	printf("\nWelcome to Chipsee CMHelper Test Units.\n");
        ret = cs_get_firmware_version(fd, &major, &minor);
	if (ret < 0 ) {
              CS_DEBUG("%s error.", __func__);
              return ret;
        }
	printf("MCU Firmware Version is: %d.%d\n", major,minor);

	ret = cs_av4helper_test_config(fd);
	if (ret < 0 ) {
              CS_DEBUG("%s error.", __func__);
              return ret;
        }

	return 0;
}
