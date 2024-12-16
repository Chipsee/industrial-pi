#include <errno.h>
#include <paths.h>
#include <sys/wait.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <string.h>
#include "av4helper_core.h"


//////////////////////////////////////////////////////
//int cs_shell_exec(const char* cmd, char* result, size_t size);
//int cs_shell_system(const char *cmd);
//////////////////////////////////////////////////////

#define SLAVE_ADDR 0x51
#define I2CBUS "/dev/i2c-0"

#define I2C_DEBUG(fmt,arg...)   do{ \
                                    if(I2CDEBUG_ON) \
                                    printf("<<I2C_DEBUG->> [%d]"fmt"\n",__LINE__, ##arg); \
                                }while(0)

#define STM_DEBUG(fmt,arg...)   do{ \
                                    if(DEBUG_ON) \
                                    printf("<<STM_DEBUG->> [%d]"fmt"\n",__LINE__, ##arg); \
                                }while(0)

////////////////////////I2C REG///////////////////////
#define BOOTMODE	0x00
#define DEVSIZE		0x0A
#define BUZZERSTATU	0x13
#define MAJORVER	0x19
#define MINORVER	0x1A
////////////////////////I2C REG///////////////////////

////////////////////////I2C REG VALUE///////////////////////
#define ENABLE		0x0E
#define DISABLE		0x0D
#define AUTOB		0x0A
#define MANUALB		0x0E
////////////////////////I2C REG VALUE///////////////////////

static char* exec(const char* cmd)
{
	if (NULL == cmd || 0 == strlen(cmd))
		return NULL;

	FILE *fp = NULL;
	char buf[128];
	char *ret;
	static int SIZE_UNITE = 512;
	size_t size = SIZE_UNITE;

	fp = popen((const char *) cmd, "r");
	if (NULL == fp)
		return NULL;

	memset(buf, 0, sizeof(buf));
	ret = (char*) calloc(sizeof(char), sizeof(char) * size);
	if(ret == NULL) {
		printf("exec, calloc %d failed\n", size);
		return NULL;
	}

	while (NULL != fgets(buf, sizeof(buf)-1, fp)) {
		if (size <= (strlen(ret) + strlen(buf))) {
			size += SIZE_UNITE;
			ret = (char*) realloc(ret, sizeof(char) * size);
			if(ret == NULL) {
				printf("exec, realloc %d failed\n", size);
				return NULL;
			}
		}
		strcat(ret, buf);
	}

	pclose(fp);
	ret = (char*) realloc(ret, sizeof(char) * (strlen(ret) + 1));

	return ret;
}

int cs_shell_exec(const char* cmd, char* result, size_t size)
{
	if (NULL == cmd || 0 == strlen(cmd))
		return -1;

	char *str = exec(cmd);
	int len = size - 1;

	if (NULL == str)
		return -1;

	if (strlen(str) < len) {
		len = strlen(str);
	}

	memset(result, 0, size);
	if (len > 0) {
		strncpy(result, str, len);
	}
	free(str);

	return 0;
}

static int system_fd_closexec(const char* command) {
	int wait_val = 0;
	pid_t pid = -1;

	if (!command)
		return 1;

	if ((pid = vfork()) < 0)
		return -1;

	if (pid == 0) {
		int i = 0;
		int stdin_fd = fileno(stdin);
		int stdout_fd = fileno(stdout);
		int stderr_fd = fileno(stderr);
		long sc_open_max = sysconf(_SC_OPEN_MAX);
		if (sc_open_max < 0) {
			sc_open_max = 20000; /* enough? */
		}
		/* close all descriptors in child sysconf(_SC_OPEN_MAX) */
		for (i = 0; i < sc_open_max; i++) {
			if (i == stdin_fd || i == stdout_fd || i == stderr_fd)
				continue;
			close(i);
		}

		execl(_PATH_BSHELL, "sh", "-c", command, (char*)0);
		_exit(127);
	}

	while (waitpid(pid, &wait_val, 0) < 0) {
		if (errno != EINTR) {
			wait_val = -1;
			break;
		}
	}

	return wait_val;
}

int cs_shell_system(const char *cmd)
{
	pid_t status;

	status = system_fd_closexec(cmd);

	if (-1 == status) {
		return -1;
	} else {
		if (WIFEXITED(status)) {
			if (0 == WEXITSTATUS(status)) {
				return 0;
			} else {
				return -2;
			}
		} else {
			return -3;
		}
	}

	return 0;
}

void Delay_ms(u32 time)
{
	usleep(time * 1000);
}

/*
 * 参数：fd 为文件描述符，由i2c_open返回;
 * 参数：slave_addr 为从设备地址;
 * 参数：writebuf 向从设备写的数据和数据目的地地址(单位字节); 通常格式为{data_addr,data,...}即{数据地址,数据,...}
 * 参数：n为写数据字节个数，这里通常是2，一个数据地址，一个数据。
 * 返回值：成功返回0,失败返回-1.
 */

static int i2c_write(int fd, unsigned int slave_addr, unsigned char * writebuf, int n)
{
	int ret;
	
	struct i2c_msg msg[1] = {
		{
		.addr = slave_addr,
		.len = n,
		.buf = writebuf,
		}
	};
		
	struct i2c_rdwr_ioctl_data data = {
		.msgs = msg,
		.nmsgs = 1,
	};
	
	ret = ioctl(fd,I2C_RDWR,&data);
	if(ret < 0){
		I2C_DEBUG("[I2C-WRITE]: Write data error!!");
		close(fd);
		return -1;
	}
	return ret;
}

/*
 * 参数：fd 为文件描述符，由i2c_open返回;
 * 参数：slave_addr 为从设备地址;
 * 参数：data_addr 从设备数据地址;
 * 参数：readbuf 向从设备读的数据(单位字节);
 * 参数：n为需要读取的数据字节个数;
 * 返回值：成功返回0,失败返回负;
 */

static int i2c_read(int fd, unsigned int slave_addr, unsigned char *data_addr, unsigned char *readbuf, int n)
{

	int ret;	
	// 封装读操作的i2c_msg消息，共2个，一个是数据地址（写），一个加了读取数据的标志。
	struct i2c_msg msg[2] = {
		{
			.addr = slave_addr,
			.len = 1,
			.buf = data_addr,
		},
		{
			.addr = slave_addr,
			.flags = I2C_M_RD,
			.len = n,
			.buf = readbuf,
		}
	};
	
	// 封装data供ioctl使用
	struct i2c_rdwr_ioctl_data data = {
		.msgs = msg,
		.nmsgs = 1,
	};
	
	// 读操作1，先写读取从机数据的数据地址，封装在第一个msg消息的writebuf中
	ret = ioctl(fd, I2C_RDWR, &data);
	if(ret<0){
		I2C_DEBUG("[I2C-READ]: Write data addr error.");
		close(fd);
		return ret;
	}
		
	// 读操作2，再通过第二个msg(带I2C_M_RD标志，代表要从从机接收数据到主机)来操作。
	data.msgs = &msg[1];
	ret = ioctl(fd, I2C_RDWR, &data);
	if(ret<0){
		I2C_DEBUG("[I2C-READ]: Read data error.");
		close(fd);
		return ret;
	}
	
	return ret;
}

static int i2c_open(char * i2c_dev)
{
	int fd;

	if((fd = open(i2c_dev,O_RDWR)) < 0){
		I2C_DEBUG("[I2C-READ]: Open i2c dev %s fail!!", i2c_dev);
		return -1;
	}
	
	return fd;
}

static int i2c_set_slave_addr_bits(int fd, int n)
{
	if((ioctl(fd,I2C_TENBIT,n)) < 0){
		I2C_DEBUG("[I2C-SET]: Set 7bit mode Error!!");
		close(fd);
		return -1;
	}
	
	return 0;
}

static int i2c_set_slave_addr(int fd, unsigned int slave_addr)
{
	if((ioctl(fd,I2C_SLAVE,slave_addr)) < 0){
		I2C_DEBUG("[I2C-SET]: Set %d slave_addr error!!",slave_addr);
		close(fd);
		return -1;
	}
	
	return 0;
}

// i2cinit
// 成功：返回fd，失败：返回负值
int cs_init()
{
	int fd, ret;
	// 打开i2c总线
	fd = i2c_open(I2CBUS);
	if(fd<0) {
		I2C_DEBUG("Open %s error!!",I2CBUS);
		return fd;
	}
	
	// 设置从机地址
	ret = i2c_set_slave_addr(fd,SLAVE_ADDR);
	if(ret <0) {
		I2C_DEBUG("Ret is %d, set slave_addr %#x error!!",ret,SLAVE_ADDR);
		return ret;
	}
	
	// 设置i2c为7位地址模式
	ret = i2c_set_slave_addr_bits(fd,0);
	if(ret <0) {
		I2C_DEBUG("Ret is %d, write data error!!",ret);
		return ret;
	}
	
	return fd;
}

int cs_deinit(int fd)
{
	close(fd);
	return 0;
}

// 以下两个函数要根据具体从机做相应延时调整
static int WriteI2C_Byte(int fd, u8 addr, u8 date)
{
	int ret;
	u8 buf[2] = {0};
	buf[0] = addr;
	buf[1] = date;
	ret = i2c_write(fd,SLAVE_ADDR, buf, sizeof(buf));
	if(ret < 0)
		I2C_DEBUG("Ret is %d, WriteI2C_Byte error!!\n", ret);
	Delay_ms(50); // STM8的从机是从EEPROM中写，写完后要延时一下，不能立即读，否则会有问题
	return ret;
}

static int ReadI2C_Byte(int fd, u8 reg, u8 *data)
{
	int ret;
	u8 writebuf[1] = {0};
	writebuf[0] = reg;
	u8 readbuf[1]={0};
	ret = i2c_read(fd,SLAVE_ADDR,writebuf,readbuf,1);
	if(ret < 0){
		I2C_DEBUG("Ret is %d, ReadI2C_Byte error!!\n", ret);
		return ret;
	}

	*data = readbuf[0];
	
	return ret;
}

// Get Device Size
int cs_get_device_size(int fd, u8 *data)
{
	int ret;
	ret = ReadI2C_Byte(fd,DEVSIZE,data);
	if(ret < 0){
                STM_DEBUG("Ret is %d, %s error!!", ret, __func__);
                return ret;
        }
	return ret;
}

// Get buzzer open/close status
// 1==>open 0==>close
int cs_get_buzzer_oc_status(int fd, u8 *data)
{
	int ret;
        ret = ReadI2C_Byte(fd,BUZZERSTATU, data);
        if(ret < 0){
                STM_DEBUG("Ret is %d, %s error!!", ret, __func__);
                return ret;
        }

	*data = *data & 0x0F;

        switch (*data)
        {
                case ENABLE: 
                        *data = 1;
                        break;
                case DISABLE:
                        *data = 0;
                        break;
                default:
                        *data = 0;
                        break;
        }
        return ret;
}
// Open Buzzer
int cs_open_buzzer(int fd)
{
	int ret;
	ret = WriteI2C_Byte(fd,BUZZERSTATU,ENABLE);
	if(ret < 0){
                STM_DEBUG("Ret is %d, %s error!!", ret, __func__);
                return ret;
        }
	return ret;
}
// Close Buzzer
int cs_close_buzzer(int fd)
{
	int ret;
	ret = WriteI2C_Byte(fd,BUZZERSTATU,DISABLE);
	if(ret < 0){
                STM_DEBUG("Ret is %d, %s error!!", ret, __func__);
                return ret;
        }
	return ret;
}

// Get boot mode
// 0==> auto boot 1==> manual boot
int cs_get_bootmode(int fd, u8 *data)
{
	int ret;
	ret = ReadI2C_Byte(fd,BOOTMODE, data);
	if(ret < 0){
                STM_DEBUG("Ret is %d, %s error!!", ret, __func__);
                return ret;
        }
	
	*data = *data & 0x0F;

	switch (*data)
        {
                case AUTOB:
                        *data = 0;
                        break;
                case MANUALB:
                        *data = 1;
                        break;
                default:
			*data = 0;
                        break;
        }
	return ret;
}
// Set auto boot
int cs_set_auto_boot(int fd)
{
	int ret;
	ret = WriteI2C_Byte(fd,BOOTMODE,AUTOB);
	if(ret < 0){
                STM_DEBUG("Ret is %d, %s error!!", ret, __func__);
                return ret;
        }
	return ret;
}
// Set manual boot
int cs_set_manual_boot(int fd)
{
	int ret;
	ret = WriteI2C_Byte(fd,BOOTMODE,MANUALB);
	if(ret < 0){
                STM_DEBUG("Ret is %d, %s error!!", ret, __func__);
                return ret;
        }
	return ret;
}
// Get Version
// Get Firmware Version
int cs_get_firmware_version(int fd,u8 *major, u8 *minor)
{
        int ret;
        ret = ReadI2C_Byte(fd,MAJORVER,major);
        if(ret < 0){
                STM_DEBUG("Ret is %d, %s error!!", ret, __func__);
                return ret;
        }

        ret = ReadI2C_Byte(fd,MINORVER,minor);
        if(ret < 0){
                STM_DEBUG("Ret is %d, %s error!!", ret, __func__);
                return ret;
        }

        return ret;	
}
