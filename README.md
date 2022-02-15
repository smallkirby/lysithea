# lysithea

**which is smaller witch?**

- [lysithea](#lysithea)
- [It is...](#it-is)
- [Installation](#installation)
- [Features](#features)
  - [Auto logging of exploit history](#auto-logging-of-exploit-history)
  - [Drothea: small kernel exploitable configuration checker](#drothea-small-kernel-exploitable-configuration-checker)
  - [Easy misc operations on kernel challenge](#easy-misc-operations-on-kernel-challenge)
- [Usage](#usage)
- [Tutorial](#tutorial)
- [Assumed environment](#assumed-environment)


# It is...

Small cute utils for CTF kernel pwn challenges.  

# Installation

Just exec `install.sh`, which installs required dependencies. All the deps are listed in `build/pkglist.required`.

```install.sh
git clone https://github.com/smallkirby/lysithea.git
cd ./lysithea
./install.sh
bash # to enable bash completion
```

# Features

## Auto logging of exploit history

pwning is a repeat of rewriting exploit & testing it on local. lysithea logs all pwn tries and helps you search QEMU output and associated exploit.

```logging.sh
$ lysithea local
[+] starting exploit localy...
SeaBIOS (version 1.13.0-1ubuntu1.1)
Booting from ROM..
.
/ $ exit
reboot: System halted
qemu-system-x86_64: terminating on signal 2
[+] saving exploit log...
[master cc01254] [lysithea]
 1 file changed, 2 insertions(+), 7 deletions(-)

$ lysithea logs
0       :    Sat Nov 13 23:24:47 2021 +0900
1       :    Sat Nov 13 22:43:53 2021 +0900
2       :    Sat Nov 13 22:41:57 2021 +0900

$ lysithea log 0
[+] starting exploit localy...
SeaBIOS (version 1.13.0-1ubuntu1.1)
Booting from ROM..
.
/ $ exit
reboot: System halted

$ lysithea fetch 2 --no-pager  | head
/****************
 *
 * Full exploit of hogehoge.
 *
****************/

#define _GNU_SOURCE
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
```


## Drothea: small kernel exploitable configuration checker

`lysithea` runs `drothea` on target host to check kernel exploitable configuration.  

`drothea` can be executed by POSIX shell such as `ash` (default shell in `busybox`). `drothea` uses its survent `ingrid`, to check some configurations from point of C-view.  

`lysithea` automates execution of `drothea` using QEMU server and named pipes, so you can check configurations just by `lysithea drothea` command in **host** machine.  

Tests are now under construction 🚧.

```drothea.sh
$ lysithea drothea --verbose
[.] creating temporary QEMU script...
[.] editing QEMU script...
[.] creating pipes for Drothea
[+] starting QEMU...
[.] waiting boot finishes...
[+] Boot confirmed.
[.] clearing pipe...
[.] success clearing pipe
===============================
Drothea v1.0.0
[!] mmap_min_addr is not 0x10000: 4096
[!] SMEP is disabled.
[!] SMAP is disabled.
[!] unprivileged ebpf installation is enabled.
Ingrid v1.0.0
[.] userfaultfd is not disabled.
===============================
[.] END of drothea
[.] cleaning Drothea...
```


## Easy misc operations on kernel challenge

`lysithea` helps you extract filesystem, re-compress it, prepare template files on a directory, build exploit for remote execution, and test exploit on local by simple commands.


# Usage

For all up-to-date commands, do `lysithea help` on your host.


```help.txt
$ lysithea help
[-] config file not found.
Lysithea v1.0.0

Usage:
  local                         : run QEMU script locally
  remote                        : run exploit on remote host
  help                          : show this help
  version                       : show version info
  init                          : init the pwn workspace
  extract                       : extract filesystem
  build                         : compile exploit for local usage
  compress                      : compress filesystem
  error                         : show error description
  exploit                       : synonym of local
  logs                          : show list of logs
  log                           : show QEMU log of given time
  fetch                         : fetch given time of exploit
  drothea                       : run kernel configuration checker in QEMU
  config                        : configure default options interactively
  memo                          : leave memo for latest exploit log
  clean                         : clean current directory
```

# Tutorial

Check [`TUTORIAL.md`](./docs/TUTORIAL.md) for actual usage example.

# Assumed environment

tested only on Ubuntu.
