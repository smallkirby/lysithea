# Tutorial

This TUTORIAL describes how you can use `lysithea` in CTF kernel challenge. 
Here, we use `lkgit` from [`TSGCTF2021`](TBD) as en example.

## Init

First, you download attachment files of the challenge and extract it in a working directory.  
In this case, the challenge has typical structure and distribution files:

```dist.sh
.
├── bzImage
├── lkgit.tar.gz
├── rootfs.cpio
├── run.sh
└── src
    ├── client
    │   └── client.c
    ├── include
    │   └── lkgit.h
    └── kernel
        └── lkgit.c
```

Then, what you have to do first is `lysithea init`. It copies some raw assets from `lysithea` directory. Also, it checks working directory and configures itself if possible for later operations.

```init.sh
$ lysithea init
[-] config file not found.
[+] initiating pwn workspace...
[.] copying exploit.c
[.] copying exploit.h
[.] copying extract-vmlinux.sh
[.] copying sender.py
[.] copying drothea
[.] compiling and copying ingrid
make: Entering directory '/home/skb/lysithea/drothea/ingrid'
make: 'ingrid' is up to date.
make: Leaving directory '/home/skb/lysithea/drothea/ingrid'
[+] found 1 QEMU run-script candidates: ./run.sh
[+] copying ./run.sh -> ./run.sh.dev
[+] creating lysithea config file: .lysithea.conf
Initialized empty Git repository in /home/skb/test/lkgittest/.git/
[master (root-commit) 9737592] [lysithea] initial commit
 2 files changed, 20 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 exploit.c
[+] initiated git environment
```

Newly created files are below:

```
├── drothea
├── exploit.c
├── exploit.h
├── extract-vmlinux.sh
├── ingrid
├── run.sh.dev
├── sender.py
```

- `drothea`: kernel configuration checker
- `ingrid`: kernel configuration checker in binary format to check some points, which cannot be tested by `drothea`.
- `exploit.c` / `exploit.h`: exploit source code. you edit it.
- `run.sh.dev`: QEMU script copied from original script. `lysithea` uses this script not to destroy original one.
- `sender.py`: script to send exploit binary to remote server.


## kernel configuration check

Then you would want to extract distributed filesystem `rootfs.cpio`, to check its init scripts. You can extract it by `lysithea extract`:

```extract.sh
$ lysithea extract
[+] Extracting filesystem into 'extracted'
[+] extraction success

$ ls ./extracted
total 1208
drwxrwxr-x 17 skb skb   4096 Dec  3 21:04 .
drwxrwxr-x  5 skb skb   4096 Dec  3 21:04 ..
drwxr-xr-x  2 skb skb   4096 Dec  3 21:04 bin
(snipped...)
```

`lysithea` finds filesystem in current directory by itself and extracts it. You can check its content as you like, but first step would be to edit `init` scripts to get a root for debug purpose.

```edit-init
$ vim ./extracted/init
```

After you get root, just type `lysithea drothea --verbose` (ofcourse you can remove `verbose` flag for simpler output):

```drothea.sh
$ lysithea drothea --verbose
[+] re-compressing filesystem...
20535 blocks
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
[.] kernel version:
Linux version 5.10.25 (hack@ash) (x86_64-buildroot-linux-gnu-gcc.br_real (Buildroot 2021.02.1) 9.3.0, GNU ld (GNU Binutils) 2.34) #1 Fri Oct 1 20:11:36 JST 2021
[!] unprivileged ebpf installation is enabled.
[!] unprivileged userfaultfd is enabled.
[?] KASLR seems enabled. Should turn off for debug purpose.
[?] kptr seems restricted. Should try 'echo 0 > /proc/sys/kernel/kptr_restrict' in init script.
Ingrid v1.0.0
[.] userfaultfd is not disabled.
[-] CONFIG_STRICT_DEVMEM is enabled.
===============================
[.] END of drothea
[.] cleaning Drothea...
```

It stars QEMU automatically and runs `drothea` and `ingrid` inside it. They check kernel configurations and report you if the kernel has weak configurations. In this example, `drothea` reports that kernel version is 5.10.25, unprivileged uffd is allowed, unprivileged ebpf is allowed, and etc. It also says that KASLR and kptr restriction is enabled, which make debugging harder.


## write exploit and try on local

Now you know kernel configurations, you would see its source code and (I wish) notices some bugs. Then you have to write exploit and test it locally.
`exploit.h` has many useful functions and macros for exploit, you can make use of it. Ofcourse you can use your exploit template cuz it is optimized for me.
After you write your exploit, you can execute it just by `lysithea local`:

```local.sh
$ lysithea local
[+] compiling exploit...
In file included from exploit.c:1:
[+] re-compressing filesystem...
23457 blocks
[+] starting exploit localy...
SeaBIOS (version 1.13.0-1ubuntu1.1)


iPXE (http://ipxe.org) 00:03.0 CA00 PCI2.10 PnP PMM+0FF8C8B0+0FECC8B0 CA00



Booting from ROM..
Boot took 1.90 seconds

/ # echo hogehoge
hogehoge
```

`lysithea` compiles your exploit, copies it in an extracted filesystem, re-compresses the filesystem, and starts QEMU to run exploit.

After this try, you enter `Ctrl+C` and notice that below message is shown:

```terminal.sh
/ # qemu-system-x86_64: terminating on signal 2
[+] saving exploit log...
[master ee4b5d7] [lysithea] (auto-generated)
 1 file changed, 14 insertions(+)
 create mode 100644 .lysithea.log
```

`lysithea` hooks termination signal and logs snapshot of QEMU output and your exploit of this try. It is useful if you want to rollback to previous version of exploit which seems better than exploit you are writing now.


## check exploit log

You can list all logs of your exploit tries by `lysithea logs`:

```logs.sh
$ lysithea logs
0       :    Fri Dec 3 21:20:46 2021 +0900
1       :    Fri Dec 3 21:20:42 2021 +0900
2       :    Fri Dec 3 21:17:14 2021 +0900
3       :    Fri Dec 3 20:58:28 2021 +0900
```

Then you can select index to check QEMU output of that try by `lysithea log`:

```log.sh
$ lysithea log 0
[+] starting exploit localy...
SeaBIOS (version 1.13.0-1ubuntu1.1)
Booting from ROM...
<FF>
Boot took 1.90 seconds

/ # ls
bin       exploit   lib       media     root      tmp
dev       home      lib64     mnt       run       usr
drothea   ingrid    linuxrc   opt       sbin      var
etc       init      lkgit.ko  proc      sys
/ # cat /home/use^M/ # cat /home/user/flag
TSGCTF{this_is_fake_flag}
/ #
```

If it is the very snapshot you want to rollback to, you can fetch the exploit of that time by `lysithea fetch`. By default, `lysithea fetch` uses pager to view your exploit, which is useful when you just check some parts of it. If you don't want to use pager to pipe the output, you can specify `--no-pager` option:

```fetch-no-pager.sh
$ lysithea fetch 1 --no-pager | head
#include "./exploit.h"

/*********** commands ******************/
#define DEV_PATH ""   // the path the device is placed

/*********** constants ******************/
```

### You want to leave a memo for specific log?

If you find your current exploit is really close to the answer, you would want to mark it to remember. Okay, just type `lysithea memo "<YOUR MESSAGE>"`:

```memo.sh
$ lysithea memo "success kbase leak. AAR should be achieved."
[master 835d3f1] [lysithea] (auto-generated)
 Date: Fri Dec 3 21:22:25 2021 +0900
 1 file changed, 10 insertions(+), 6 deletions(-)
```

Then you can easily rollback to it at anytime by checking `lysithea logs`:

```memo-log.sh
$ lysithea logs
0       :    Fri Dec 3 21:28:35 2021 +0900
1       :    Fri Dec 3 21:22:25 2021 +0900

        success kbase leak. AAR should be achieved.

2       :    Fri Dec 3 21:22:11 2021 +0900
3       :    Fri Dec 3 21:20:46 2021 +0900
4       :    Fri Dec 3 21:20:42 2021 +0900
```

### You don't wannna leave logs?

Suppose you know some tries you are to do from now on are just test, and you don't want to leave a log to keep logs clean. You can configure `lysithea` interactively by `lysithea config`:

```config.sh
$ lysithea config
[+] Currenct configurations:
### lysithea configuration file ###
QEMUSCRIPT=./run.sh.dev


[+] choose below command to flip current setting, or set options by 'OPTION_NAME=OPTION_VALUE'.
  nobuild             : skip build of exploit and compression of filesystem defaultly.
  nolog               : don't take log of local exploit history defaultly.
  exploit=<string>    : specify exploit filename.
  rootfs=<string>     : specify rootfs filename.
  qemu=<string>       : specify qemuscript filename.
 ('q' to quit) >
```

In this case, you can change configuration by `nolog`. After it, no logs are taken. If you want to re-enable logging, you can configurate `lysithea` in the same way.

```config-log.sh
 ('q' to quit) > nolog
[+] set EXPLOIT_DONT_LOG to 1.

$ lysithea local
[+] compiling exploit...
[+] re-compressing filesystem...
23457 blocks
[+] starting exploit localy...
Boot took 1.78 seconds

/ # echo "this is not logged"
this is not logged
/ # qemu-system-x86_64: terminating on signal 2
```

You can edit other configurations also by `lysithea config`, such as build option, name of QEMU script, and etc. For complete list of available configs, try `lysithea config` on your host.


## run exploit in remote host

Congrats, you write exploit which works well locally. Then you have to try it in remote host. Just type: `lysithea remote`:

```remote.sh
$ lysithea remote --host skbctf.skb.pw --port 25252
[+] starting exploit remotely...
[+] compiling compressed exploit...
fetch https://dl-cdn.alpinelinux.org/alpine/v3.13/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.13/community/x86_64/APKINDEX.tar.gz
(1/14) Upgrading musl (1.2.2-r0 -> 1.2.2-r1)
(snipped...)
(14/14) Installing musl-dev (1.2.2-r1)
Executing busybox-1.32.1-r6.trigger
[+] Using target as skbctf.skb.pw:25252
[+] Opening connection to skbctf.skb.pw on port 25252: Done
[+] sending base64ed exploit (total: 0x52fc)...
[.] sent 0x5400 bytes [101.223874976 %]
[*] Switching to interactive mode
 ./exploit
[ ] END of life...
```

It automatically compiles your exploit by using light-weight musl libc, strips and gzip and base64 encodes it, sends it to remote host, and runs it. The only thing you have to do is to specify host and port.

### it's boring to specify port and host?

If you are too lazy to specify port and host in every tries, you can configure `lysithea` only once by `lysithea config`. You can configure it while you are waiting the distributed files are being downloaded...


## Other usage?

Just type `lysithea help`:

```usage.sh
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
```

This help message is generated from annotations in the source code of `lysithea`, hence it is always up-to-new.

## want completion?

Ofcourse you can use tab-completion of `lysithea commands`. To install completion file, exec `./install.sh` in root directory of `lysithea`.
This completion file is also generated automatically from annotations in the source code. It is always up-to-new.

## `lysithea` is only for Bash?

...? Ofcourse yes. Is there any shells in the world other than Bash???? Please tell me if you know.



## Contributions and Suggestions

`lysithea` is now under construction. We appreciate it if you have some suggestions for `lysithea`. Please create issues or PR on this Github as you like. Question is also welcome in Issue or somewhere. You can directly contact me on [Twiter](https://twitter.com/smallkirby).
