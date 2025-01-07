#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/inotify.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "av4helper_core.h"

// 守护进程初始化函数
void init_daemon() {
    pid_t pid;

    // 创建子进程，终止父进程
    if ((pid = fork()) < 0) {
        perror("fork");
        exit(1);
    } else if (pid != 0) {
        exit(0);
    }

    // 创建新的会话
    setsid();

    // 改变工作目录
    chdir("/");

    // 重设文件权限掩码
    umask(0);

    // 关闭文件描述符
    close(STDIN_FILENO);
    close(STDOUT_FILENO);
    close(STDERR_FILENO);
}

int main() {
    int fd, wd, i2cfd;
    char buffer[1024];
    const char *filename = "/dev/buzzer";

    // 初始化守护进程
    init_daemon();

    // 初始化 inotify
    fd = inotify_init();
    if (fd < 0) {
        perror("inotify_init");
        exit(EXIT_FAILURE);
    }

    // 添加监控项
    wd = inotify_add_watch(fd, filename, IN_MODIFY);
    if (wd < 0) {
        perror("inotify_add_watch");
        close(fd);
        exit(EXIT_FAILURE);
    }
    
    i2cfd = cs_init();
    if (i2cfd < 0 ) {
        printf("buzzer i2c init error");
        return fd;
    }

    while (1) {
        int length = read(fd, buffer, sizeof(buffer));
        if (length < 0) {
            perror("read");
            break;
        }

        // 处理 inotify 事件
        struct inotify_event *event = (struct inotify_event *) buffer;
        if (event->mask & IN_MODIFY) {
            FILE *file = fopen(filename, "r");
            if (file) {
                char value;
                fread(&value, 1, 1, file);
                fclose(file);

                if (value == '1') {
                    cs_open_buzzer(i2cfd);
                } else if (value == '0') {
                    cs_close_buzzer(i2cfd);
                }
            }
        }
    }

    // 清理
    inotify_rm_watch(fd, wd);
    close(fd);
    cs_deinit(i2cfd);

    return 0;
}
