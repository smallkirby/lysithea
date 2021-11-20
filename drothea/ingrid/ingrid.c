//encoding: utf-8;
//spaces: 2;

/**********
 *
 * Ingrid v1.0.0
 *
 * Survent of Drothea.
 * Check kernel configurations which cannot be tested by Drothea.
 *
**********/

#define _GNU_SOURCE
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <fcntl.h>
#include <stdint.h>
#include <unistd.h>
#include <assert.h>
#include <stdlib.h>
#include <signal.h>
#include <poll.h>
#include <pthread.h>
#include <err.h>
#include <errno.h>
#include <sched.h>
#include <linux/bpf.h>
#include <linux/filter.h>
#include <linux/userfaultfd.h>
#include <linux/prctl.h>
#include <sys/syscall.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/prctl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/xattr.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <sys/shm.h>

#define VERSION "1.0.0"

int VERBOSE = 0;

/**** Utils ***************/

void v_printf(char *fmt, ...) {
  if (VERBOSE == 1) {
    va_list va;
    va_start(va, fmt);
    vprintf(fmt, va);
    va_end(va);
  }
}

void check_verbose(int argc, char *argv[]) {
  for (int ix = 0; ix != argc; ++ix) {
    if (strcmp(argv[ix], "--verbose") == 0) {
      VERBOSE = 1;
    }
  }
}

/**** END Utils ************/


/**** tests ****************/

void test_uffd_enabled() {
  if (syscall(__NR_userfaultfd, O_CLOEXEC | O_NONBLOCK) == -1) {
    puts("[-] userfualtfd is disabled.");
  } else {
    v_printf("[.] userfaultfd is not disabled.\n");
  }
}

void test_config_strict_devmem(void) {
  int fd = open("/dev/mem", O_RDWR);
  if (fd == -1) {
    puts("[-] CONFIG_DEVMEM is disabled.");
    return;
  }

  // search system RAM addr, which is restricted to read if CONFIG_STRICT_DEVMEM is enabled.
  FILE *iomem = fopen("/proc/iomem", "r");
  if (iomem == NULL) goto FAIL_IOMEM;
  char *line, buf[0x100];
  size_t len = 0;
  unsigned count = 0;
  unsigned long systemram = 0xdeadbeef;
  while (getline(&line, &len, iomem) != -1) {
    if (strstr(line, "System RAM") != 0 && count++) {
      systemram = strtoul(strtok(line, "-"), NULL, 16);
      break;
    }
  }

  if (systemram == 0xdeadbeef) {
FAIL_IOMEM:
    v_printf("[-] failed to search system RAM addr.\n");
    return;
  }
  fclose(iomem);


  // try to read from System RAM
  assert(lseek(fd, (off_t)systemram, SEEK_SET) != -1);
  //assert(lseek(fd, (off_t)0x100000, SEEK_SET) != -1);
  if (read(fd, buf, 0x10) == -1) {
    v_printf("[-] CONFIG_STRICT_DEVMEM is enabled.\n");
  } else {
    puts("[+] CONFIG_STRICT_DEVMEM is disabled.");
  }

  close(fd);
}

/**** END tests ************/


/**** main *****************/

void do_tests(void) {
  test_uffd_enabled();
  test_config_strict_devmem();
}

int main(int argc, char *argv[]) {
  check_verbose(argc, argv);
  v_printf("Ingrid v%s\n", VERSION);

  do_tests();

  return 0;
}
