# lysithea

**which is smaller witch?**


# It is...

Small cute snippet manager for CTF kernel pwn challenges.  

This is an expansion of [`mr.sh`](https://github.com/smallkirby/snippet/blob/master/exploit/kernel/mr.sh).  


# Installation

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

## Easy misc operations on kernel challenge

`lysithea` helps you extract filesystem, re-compress it, prepare template files on a directory, build exploit for remote execution, and test exploit on local by simple commands.


# Usage

```help.txt
$ lysithea help
Lysithea v1.0.0

Usage:
  init      : init the pwn workspace
  extract   : extract filesystem
  compress  : compress filesystem
  run       : run QEMU
  build     : compile exploit for local usage
  error     : show error description
  local     : run QEMU script
  exploit   : synonym of 'local'
  remote    : run exploit on remote host
  logs      : show list of logs
  log       : show QEMU log of given time
  fetch     : fetch given time of exploit
  version   : show version info
  help      : show this help
```

# Tutorial

Check [`TUTORIAL.md`](./docs/TUTORIAL.md) for actual usage example.

# Assumed environment

tested only on Ubuntu.
