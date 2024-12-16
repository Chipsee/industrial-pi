#ifndef __CS_AV4HELPER_CORE_H__
#define __CS_AV4HELPER_CORE_H__

#ifdef __cplusplus
extern "C" {
#endif

#define DEBUG_ON 1
#define I2CDEBUG_ON 1

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef enum
{
        LOW    = 0,
        HIGH   = !LOW
} Pin_Status;

int cs_shell_exec(const char* cmd, char* result, size_t size);
int cs_shell_system(const char *cmd);

void Delay_ms(u32 time);

// init
int cs_init();

// Get buzzer open/close status
// data = 1==> open data = 0==> close
int cs_get_buzzer_oc_status(int fd, u8 *data);
// Open Buzzer
int cs_open_buzzer(int fd);
// Close Buzzer
int cs_close_buzzer(int fd);

// Get boot mode
// data = 0 ==> auto boot, data = 1 ==> manual boot
int cs_get_bootmode(int fd, u8 *data);
// Set auto boot
int cs_set_auto_boot(int fd);
// Set manual boot
int cs_set_manual_boot(int fd);

// Get firmware version
int cs_get_firmware_version(int fd,u8 *major, u8 *minor);

// de init
int cs_deinit(int fd);

#ifdef __cplusplus
}
#endif

#endif
