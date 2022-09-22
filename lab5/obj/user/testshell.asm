
obj/user/testshell.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 03 05 00 00       	call   800534 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
  800046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004d:	89 3c 24             	mov    %edi,(%esp)
  800050:	e8 21 1c 00 00       	call   801c76 <seek>
	seek(kfd, off);
  800055:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800059:	89 34 24             	mov    %esi,(%esp)
  80005c:	e8 15 1c 00 00       	call   801c76 <seek>

	cprintf("shell produced incorrect output.\n");
  800061:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  800068:	e8 33 06 00 00       	call   8006a0 <cprintf>
	cprintf("expected:\n===\n");
  80006d:	c7 04 24 eb 2f 80 00 	movl   $0x802feb,(%esp)
  800074:	e8 27 06 00 00       	call   8006a0 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800079:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007c:	eb 0c                	jmp    80008a <wrong+0x56>
		sys_cputs(buf, n);
  80007e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800082:	89 1c 24             	mov    %ebx,(%esp)
  800085:	e8 e6 0e 00 00       	call   800f70 <sys_cputs>
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  80008a:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 6e 1a 00 00       	call   801b0c <read>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	7f dc                	jg     80007e <wrong+0x4a>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  8000a2:	c7 04 24 fa 2f 80 00 	movl   $0x802ffa,(%esp)
  8000a9:	e8 f2 05 00 00       	call   8006a0 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ae:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b1:	eb 0c                	jmp    8000bf <wrong+0x8b>
		sys_cputs(buf, n);
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	89 1c 24             	mov    %ebx,(%esp)
  8000ba:	e8 b1 0e 00 00       	call   800f70 <sys_cputs>
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bf:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000c6:	00 
  8000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cb:	89 3c 24             	mov    %edi,(%esp)
  8000ce:	e8 39 1a 00 00       	call   801b0c <read>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7f dc                	jg     8000b3 <wrong+0x7f>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000d7:	c7 04 24 f5 2f 80 00 	movl   $0x802ff5,(%esp)
  8000de:	e8 bd 05 00 00       	call   8006a0 <cprintf>
	exit();
  8000e3:	e8 a4 04 00 00       	call   80058c <exit>
}
  8000e8:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 3c             	sub    $0x3c,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800103:	e8 a0 18 00 00       	call   8019a8 <close>
	close(1);
  800108:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010f:	e8 94 18 00 00       	call   8019a8 <close>
	opencons();
  800114:	e8 c7 03 00 00       	call   8004e0 <opencons>
	opencons();
  800119:	e8 c2 03 00 00       	call   8004e0 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  80012d:	e8 11 1f 00 00       	call   802043 <open>
  800132:	89 c3                	mov    %eax,%ebx
  800134:	85 c0                	test   %eax,%eax
  800136:	79 20                	jns    800158 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013c:	c7 44 24 08 15 30 80 	movl   $0x803015,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 2b 30 80 00 	movl   $0x80302b,(%esp)
  800153:	e8 50 04 00 00       	call   8005a8 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800158:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 96 27 00 00       	call   8028f9 <pipe>
  800163:	85 c0                	test   %eax,%eax
  800165:	79 20                	jns    800187 <umain+0x94>
		panic("pipe: %e", wfd);
  800167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016b:	c7 44 24 08 3c 30 80 	movl   $0x80303c,0x8(%esp)
  800172:	00 
  800173:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80017a:	00 
  80017b:	c7 04 24 2b 30 80 00 	movl   $0x80302b,(%esp)
  800182:	e8 21 04 00 00       	call   8005a8 <_panic>
	wfd = pfds[1];
  800187:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  80018a:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  800191:	e8 0a 05 00 00       	call   8006a0 <cprintf>
	if ((r = fork()) < 0)
  800196:	e8 45 13 00 00       	call   8014e0 <fork>
  80019b:	85 c0                	test   %eax,%eax
  80019d:	79 20                	jns    8001bf <umain+0xcc>
		panic("fork: %e", r);
  80019f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a3:	c7 44 24 08 45 30 80 	movl   $0x803045,0x8(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b2:	00 
  8001b3:	c7 04 24 2b 30 80 00 	movl   $0x80302b,(%esp)
  8001ba:	e8 e9 03 00 00       	call   8005a8 <_panic>
	if (r == 0) {
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	0f 85 9f 00 00 00    	jne    800266 <umain+0x173>
		dup(rfd, 0);
  8001c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ce:	00 
  8001cf:	89 1c 24             	mov    %ebx,(%esp)
  8001d2:	e8 22 18 00 00       	call   8019f9 <dup>
		dup(wfd, 1);
  8001d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001de:	00 
  8001df:	89 34 24             	mov    %esi,(%esp)
  8001e2:	e8 12 18 00 00       	call   8019f9 <dup>
		close(rfd);
  8001e7:	89 1c 24             	mov    %ebx,(%esp)
  8001ea:	e8 b9 17 00 00       	call   8019a8 <close>
		close(wfd);
  8001ef:	89 34 24             	mov    %esi,(%esp)
  8001f2:	e8 b1 17 00 00       	call   8019a8 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fe:	00 
  8001ff:	c7 44 24 08 4e 30 80 	movl   $0x80304e,0x8(%esp)
  800206:	00 
  800207:	c7 44 24 04 12 30 80 	movl   $0x803012,0x4(%esp)
  80020e:	00 
  80020f:	c7 04 24 51 30 80 00 	movl   $0x803051,(%esp)
  800216:	e8 97 24 00 00       	call   8026b2 <spawnl>
  80021b:	89 c7                	mov    %eax,%edi
  80021d:	85 c0                	test   %eax,%eax
  80021f:	79 20                	jns    800241 <umain+0x14e>
			panic("spawn: %e", r);
  800221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800225:	c7 44 24 08 55 30 80 	movl   $0x803055,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 2b 30 80 00 	movl   $0x80302b,(%esp)
  80023c:	e8 67 03 00 00       	call   8005a8 <_panic>
		close(0);
  800241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800248:	e8 5b 17 00 00       	call   8019a8 <close>
		close(1);
  80024d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800254:	e8 4f 17 00 00       	call   8019a8 <close>
		wait(r);
  800259:	89 3c 24             	mov    %edi,(%esp)
  80025c:	e8 3b 28 00 00       	call   802a9c <wait>
		exit();
  800261:	e8 26 03 00 00       	call   80058c <exit>
	}
	close(rfd);
  800266:	89 1c 24             	mov    %ebx,(%esp)
  800269:	e8 3a 17 00 00       	call   8019a8 <close>
	close(wfd);
  80026e:	89 34 24             	mov    %esi,(%esp)
  800271:	e8 32 17 00 00       	call   8019a8 <close>

	rfd = pfds[0];
  800276:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800279:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 5f 30 80 00 	movl   $0x80305f,(%esp)
  800288:	e8 b6 1d 00 00       	call   802043 <open>
  80028d:	89 c6                	mov    %eax,%esi
  80028f:	85 c0                	test   %eax,%eax
  800291:	79 20                	jns    8002b3 <umain+0x1c0>
		panic("open testshell.key for reading: %e", kfd);
  800293:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800297:	c7 44 24 08 c8 2f 80 	movl   $0x802fc8,0x8(%esp)
  80029e:	00 
  80029f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002a6:	00 
  8002a7:	c7 04 24 2b 30 80 00 	movl   $0x80302b,(%esp)
  8002ae:	e8 f5 02 00 00       	call   8005a8 <_panic>
	}
	close(rfd);
	close(wfd);

	rfd = pfds[0];
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8002b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  8002ba:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		panic("open testshell.key for reading: %e", kfd);

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  8002c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c8:	00 
  8002c9:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	89 3c 24             	mov    %edi,(%esp)
  8002d3:	e8 34 18 00 00       	call   801b0c <read>
  8002d8:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e1:	00 
  8002e2:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	e8 1b 18 00 00       	call   801b0c <read>
		if (n1 < 0)
  8002f1:	85 db                	test   %ebx,%ebx
  8002f3:	79 20                	jns    800315 <umain+0x222>
			panic("reading testshell.out: %e", n1);
  8002f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f9:	c7 44 24 08 6d 30 80 	movl   $0x80306d,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 2b 30 80 00 	movl   $0x80302b,(%esp)
  800310:	e8 93 02 00 00       	call   8005a8 <_panic>
		if (n2 < 0)
  800315:	85 c0                	test   %eax,%eax
  800317:	79 20                	jns    800339 <umain+0x246>
			panic("reading testshell.key: %e", n2);
  800319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031d:	c7 44 24 08 87 30 80 	movl   $0x803087,0x8(%esp)
  800324:	00 
  800325:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  80032c:	00 
  80032d:	c7 04 24 2b 30 80 00 	movl   $0x80302b,(%esp)
  800334:	e8 6f 02 00 00       	call   8005a8 <_panic>
		if (n1 == 0 && n2 == 0)
  800339:	85 db                	test   %ebx,%ebx
  80033b:	75 06                	jne    800343 <umain+0x250>
  80033d:	85 c0                	test   %eax,%eax
  80033f:	75 14                	jne    800355 <umain+0x262>
  800341:	eb 39                	jmp    80037c <umain+0x289>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  800343:	83 fb 01             	cmp    $0x1,%ebx
  800346:	75 0d                	jne    800355 <umain+0x262>
  800348:	83 f8 01             	cmp    $0x1,%eax
  80034b:	75 08                	jne    800355 <umain+0x262>
  80034d:	8a 45 e6             	mov    -0x1a(%ebp),%al
  800350:	38 45 e7             	cmp    %al,-0x19(%ebp)
  800353:	74 13                	je     800368 <umain+0x275>
			wrong(rfd, kfd, nloff);
  800355:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800358:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	89 3c 24             	mov    %edi,(%esp)
  800363:	e8 cc fc ff ff       	call   800034 <wrong>
		if (c1 == '\n')
  800368:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  80036c:	75 06                	jne    800374 <umain+0x281>
			nloff = off+1;
  80036e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800371:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800374:	ff 45 d4             	incl   -0x2c(%ebp)
	}
  800377:	e9 45 ff ff ff       	jmp    8002c1 <umain+0x1ce>
	cprintf("shell ran correctly\n");
  80037c:	c7 04 24 a1 30 80 00 	movl   $0x8030a1,(%esp)
  800383:	e8 18 03 00 00       	call   8006a0 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800388:	cc                   	int3   

	breakpoint();
}
  800389:	83 c4 3c             	add    $0x3c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    
  800391:	00 00                	add    %al,(%eax)
	...

00800394 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800397:	b8 00 00 00 00       	mov    $0x0,%eax
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8003a4:	c7 44 24 04 b6 30 80 	movl   $0x8030b6,0x4(%esp)
  8003ab:	00 
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	e8 94 08 00 00       	call   800c4b <strcpy>
	return 0;
}
  8003b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003d5:	eb 30                	jmp    800407 <devcons_write+0x49>
		m = n - tot;
  8003d7:	8b 75 10             	mov    0x10(%ebp),%esi
  8003da:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8003dc:	83 fe 7f             	cmp    $0x7f,%esi
  8003df:	76 05                	jbe    8003e6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8003e1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8003e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003ea:	03 45 0c             	add    0xc(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	89 3c 24             	mov    %edi,(%esp)
  8003f4:	e8 cb 09 00 00       	call   800dc4 <memmove>
		sys_cputs(buf, m);
  8003f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fd:	89 3c 24             	mov    %edi,(%esp)
  800400:	e8 6b 0b 00 00       	call   800f70 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800405:	01 f3                	add    %esi,%ebx
  800407:	89 d8                	mov    %ebx,%eax
  800409:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80040c:	72 c9                	jb     8003d7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80040e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800414:	5b                   	pop    %ebx
  800415:	5e                   	pop    %esi
  800416:	5f                   	pop    %edi
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80041f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800423:	75 07                	jne    80042c <devcons_read+0x13>
  800425:	eb 25                	jmp    80044c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800427:	e8 f2 0b 00 00       	call   80101e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80042c:	e8 5d 0b 00 00       	call   800f8e <sys_cgetc>
  800431:	85 c0                	test   %eax,%eax
  800433:	74 f2                	je     800427 <devcons_read+0xe>
  800435:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800437:	85 c0                	test   %eax,%eax
  800439:	78 1d                	js     800458 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80043b:	83 f8 04             	cmp    $0x4,%eax
  80043e:	74 13                	je     800453 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	88 10                	mov    %dl,(%eax)
	return 1;
  800445:	b8 01 00 00 00       	mov    $0x1,%eax
  80044a:	eb 0c                	jmp    800458 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80044c:	b8 00 00 00 00       	mov    $0x0,%eax
  800451:	eb 05                	jmp    800458 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800458:	c9                   	leave  
  800459:	c3                   	ret    

0080045a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800466:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80046d:	00 
  80046e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 f7 0a 00 00       	call   800f70 <sys_cputs>
}
  800479:	c9                   	leave  
  80047a:	c3                   	ret    

0080047b <getchar>:

int
getchar(void)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800481:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800488:	00 
  800489:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800497:	e8 70 16 00 00       	call   801b0c <read>
	if (r < 0)
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 0f                	js     8004af <getchar+0x34>
		return r;
	if (r < 1)
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	7e 06                	jle    8004aa <getchar+0x2f>
		return -E_EOF;
	return c;
  8004a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8004a8:	eb 05                	jmp    8004af <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8004aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8004af:	c9                   	leave  
  8004b0:	c3                   	ret    

008004b1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	e8 a5 13 00 00       	call   80186e <fd_lookup>
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	78 11                	js     8004de <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8004cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8004d6:	39 10                	cmp    %edx,(%eax)
  8004d8:	0f 94 c0             	sete   %al
  8004db:	0f b6 c0             	movzbl %al,%eax
}
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <opencons>:

int
opencons(void)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8004e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 2a 13 00 00       	call   80181b <fd_alloc>
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	78 3c                	js     800531 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8004f5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8004fc:	00 
  8004fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800500:	89 44 24 04          	mov    %eax,0x4(%esp)
  800504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80050b:	e8 2d 0b 00 00       	call   80103d <sys_page_alloc>
  800510:	85 c0                	test   %eax,%eax
  800512:	78 1d                	js     800531 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800514:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80051a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80051d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80051f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800522:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 bf 12 00 00       	call   8017f0 <fd2num>
}
  800531:	c9                   	leave  
  800532:	c3                   	ret    
	...

00800534 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	56                   	push   %esi
  800538:	53                   	push   %ebx
  800539:	83 ec 20             	sub    $0x20,%esp
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800542:	e8 b8 0a 00 00       	call   800fff <sys_getenvid>
  800547:	25 ff 03 00 00       	and    $0x3ff,%eax
  80054c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800553:	c1 e0 07             	shl    $0x7,%eax
  800556:	29 d0                	sub    %edx,%eax
  800558:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80055d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800563:	a3 04 50 80 00       	mov    %eax,0x805004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800568:	85 f6                	test   %esi,%esi
  80056a:	7e 07                	jle    800573 <libmain+0x3f>
		binaryname = argv[0];
  80056c:	8b 03                	mov    (%ebx),%eax
  80056e:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800573:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800577:	89 34 24             	mov    %esi,(%esp)
  80057a:	e8 74 fb ff ff       	call   8000f3 <umain>

	// exit gracefully
	exit();
  80057f:	e8 08 00 00 00       	call   80058c <exit>
}
  800584:	83 c4 20             	add    $0x20,%esp
  800587:	5b                   	pop    %ebx
  800588:	5e                   	pop    %esi
  800589:	5d                   	pop    %ebp
  80058a:	c3                   	ret    
	...

0080058c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800592:	e8 42 14 00 00       	call   8019d9 <close_all>
	sys_env_destroy(0);
  800597:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80059e:	e8 0a 0a 00 00       	call   800fad <sys_env_destroy>
}
  8005a3:	c9                   	leave  
  8005a4:	c3                   	ret    
  8005a5:	00 00                	add    %al,(%eax)
	...

008005a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	56                   	push   %esi
  8005ac:	53                   	push   %ebx
  8005ad:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005b0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005b3:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  8005b9:	e8 41 0a 00 00       	call   800fff <sys_getenvid>
  8005be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d4:	c7 04 24 cc 30 80 00 	movl   $0x8030cc,(%esp)
  8005db:	e8 c0 00 00 00       	call   8006a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e7:	89 04 24             	mov    %eax,(%esp)
  8005ea:	e8 50 00 00 00       	call   80063f <vcprintf>
	cprintf("\n");
  8005ef:	c7 04 24 70 34 80 00 	movl   $0x803470,(%esp)
  8005f6:	e8 a5 00 00 00       	call   8006a0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005fb:	cc                   	int3   
  8005fc:	eb fd                	jmp    8005fb <_panic+0x53>
	...

00800600 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	53                   	push   %ebx
  800604:	83 ec 14             	sub    $0x14,%esp
  800607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80060a:	8b 03                	mov    (%ebx),%eax
  80060c:	8b 55 08             	mov    0x8(%ebp),%edx
  80060f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800613:	40                   	inc    %eax
  800614:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800616:	3d ff 00 00 00       	cmp    $0xff,%eax
  80061b:	75 19                	jne    800636 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80061d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800624:	00 
  800625:	8d 43 08             	lea    0x8(%ebx),%eax
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	e8 40 09 00 00       	call   800f70 <sys_cputs>
		b->idx = 0;
  800630:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800636:	ff 43 04             	incl   0x4(%ebx)
}
  800639:	83 c4 14             	add    $0x14,%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5d                   	pop    %ebp
  80063e:	c3                   	ret    

0080063f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800648:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80064f:	00 00 00 
	b.cnt = 0;
  800652:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800659:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80065c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800663:	8b 45 08             	mov    0x8(%ebp),%eax
  800666:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800670:	89 44 24 04          	mov    %eax,0x4(%esp)
  800674:	c7 04 24 00 06 80 00 	movl   $0x800600,(%esp)
  80067b:	e8 82 01 00 00       	call   800802 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800680:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	e8 d8 08 00 00       	call   800f70 <sys_cputs>

	return b.cnt;
}
  800698:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80069e:	c9                   	leave  
  80069f:	c3                   	ret    

008006a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	e8 87 ff ff ff       	call   80063f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    
	...

008006bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	57                   	push   %edi
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	83 ec 3c             	sub    $0x3c,%esp
  8006c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c8:	89 d7                	mov    %edx,%edi
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006d9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	75 08                	jne    8006e8 <printnum+0x2c>
  8006e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006e3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006e6:	77 57                	ja     80073f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006e8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006ec:	4b                   	dec    %ebx
  8006ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8006fc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800700:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800707:	00 
  800708:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80070b:	89 04 24             	mov    %eax,(%esp)
  80070e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800711:	89 44 24 04          	mov    %eax,0x4(%esp)
  800715:	e8 02 26 00 00       	call   802d1c <__udivdi3>
  80071a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80071e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800722:	89 04 24             	mov    %eax,(%esp)
  800725:	89 54 24 04          	mov    %edx,0x4(%esp)
  800729:	89 fa                	mov    %edi,%edx
  80072b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80072e:	e8 89 ff ff ff       	call   8006bc <printnum>
  800733:	eb 0f                	jmp    800744 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800735:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800739:	89 34 24             	mov    %esi,(%esp)
  80073c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80073f:	4b                   	dec    %ebx
  800740:	85 db                	test   %ebx,%ebx
  800742:	7f f1                	jg     800735 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800744:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800748:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80074c:	8b 45 10             	mov    0x10(%ebp),%eax
  80074f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800753:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80075a:	00 
  80075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80075e:	89 04 24             	mov    %eax,(%esp)
  800761:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800764:	89 44 24 04          	mov    %eax,0x4(%esp)
  800768:	e8 cf 26 00 00       	call   802e3c <__umoddi3>
  80076d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800771:	0f be 80 ef 30 80 00 	movsbl 0x8030ef(%eax),%eax
  800778:	89 04 24             	mov    %eax,(%esp)
  80077b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80077e:	83 c4 3c             	add    $0x3c,%esp
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5f                   	pop    %edi
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800789:	83 fa 01             	cmp    $0x1,%edx
  80078c:	7e 0e                	jle    80079c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80078e:	8b 10                	mov    (%eax),%edx
  800790:	8d 4a 08             	lea    0x8(%edx),%ecx
  800793:	89 08                	mov    %ecx,(%eax)
  800795:	8b 02                	mov    (%edx),%eax
  800797:	8b 52 04             	mov    0x4(%edx),%edx
  80079a:	eb 22                	jmp    8007be <getuint+0x38>
	else if (lflag)
  80079c:	85 d2                	test   %edx,%edx
  80079e:	74 10                	je     8007b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a0:	8b 10                	mov    (%eax),%edx
  8007a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a5:	89 08                	mov    %ecx,(%eax)
  8007a7:	8b 02                	mov    (%edx),%eax
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ae:	eb 0e                	jmp    8007be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b5:	89 08                	mov    %ecx,(%eax)
  8007b7:	8b 02                	mov    (%edx),%eax
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ce:	73 08                	jae    8007d8 <sprintputch+0x18>
		*b->buf++ = ch;
  8007d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d3:	88 0a                	mov    %cl,(%edx)
  8007d5:	42                   	inc    %edx
  8007d6:	89 10                	mov    %edx,(%eax)
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	89 04 24             	mov    %eax,(%esp)
  8007fb:	e8 02 00 00 00       	call   800802 <vprintfmt>
	va_end(ap);
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	57                   	push   %edi
  800806:	56                   	push   %esi
  800807:	53                   	push   %ebx
  800808:	83 ec 4c             	sub    $0x4c,%esp
  80080b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080e:	8b 75 10             	mov    0x10(%ebp),%esi
  800811:	eb 12                	jmp    800825 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800813:	85 c0                	test   %eax,%eax
  800815:	0f 84 6b 03 00 00    	je     800b86 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80081b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081f:	89 04 24             	mov    %eax,(%esp)
  800822:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800825:	0f b6 06             	movzbl (%esi),%eax
  800828:	46                   	inc    %esi
  800829:	83 f8 25             	cmp    $0x25,%eax
  80082c:	75 e5                	jne    800813 <vprintfmt+0x11>
  80082e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800832:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800839:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80083e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800845:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084a:	eb 26                	jmp    800872 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80084f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800853:	eb 1d                	jmp    800872 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800858:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80085c:	eb 14                	jmp    800872 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800861:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800868:	eb 08                	jmp    800872 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80086a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80086d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800872:	0f b6 06             	movzbl (%esi),%eax
  800875:	8d 56 01             	lea    0x1(%esi),%edx
  800878:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80087b:	8a 16                	mov    (%esi),%dl
  80087d:	83 ea 23             	sub    $0x23,%edx
  800880:	80 fa 55             	cmp    $0x55,%dl
  800883:	0f 87 e1 02 00 00    	ja     800b6a <vprintfmt+0x368>
  800889:	0f b6 d2             	movzbl %dl,%edx
  80088c:	ff 24 95 40 32 80 00 	jmp    *0x803240(,%edx,4)
  800893:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800896:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80089b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80089e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008a2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008a5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008a8:	83 fa 09             	cmp    $0x9,%edx
  8008ab:	77 2a                	ja     8008d7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008ad:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008ae:	eb eb                	jmp    80089b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b3:	8d 50 04             	lea    0x4(%eax),%edx
  8008b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008be:	eb 17                	jmp    8008d7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c4:	78 98                	js     80085e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c9:	eb a7                	jmp    800872 <vprintfmt+0x70>
  8008cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008ce:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008d5:	eb 9b                	jmp    800872 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8008d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008db:	79 95                	jns    800872 <vprintfmt+0x70>
  8008dd:	eb 8b                	jmp    80086a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008df:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008e3:	eb 8d                	jmp    800872 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8d 50 04             	lea    0x4(%eax),%edx
  8008eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f2:	8b 00                	mov    (%eax),%eax
  8008f4:	89 04 24             	mov    %eax,(%esp)
  8008f7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008fd:	e9 23 ff ff ff       	jmp    800825 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	8d 50 04             	lea    0x4(%eax),%edx
  800908:	89 55 14             	mov    %edx,0x14(%ebp)
  80090b:	8b 00                	mov    (%eax),%eax
  80090d:	85 c0                	test   %eax,%eax
  80090f:	79 02                	jns    800913 <vprintfmt+0x111>
  800911:	f7 d8                	neg    %eax
  800913:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800915:	83 f8 0f             	cmp    $0xf,%eax
  800918:	7f 0b                	jg     800925 <vprintfmt+0x123>
  80091a:	8b 04 85 a0 33 80 00 	mov    0x8033a0(,%eax,4),%eax
  800921:	85 c0                	test   %eax,%eax
  800923:	75 23                	jne    800948 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800925:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800929:	c7 44 24 08 07 31 80 	movl   $0x803107,0x8(%esp)
  800930:	00 
  800931:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	89 04 24             	mov    %eax,(%esp)
  80093b:	e8 9a fe ff ff       	call   8007da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800940:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800943:	e9 dd fe ff ff       	jmp    800825 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800948:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80094c:	c7 44 24 08 19 35 80 	movl   $0x803519,0x8(%esp)
  800953:	00 
  800954:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800958:	8b 55 08             	mov    0x8(%ebp),%edx
  80095b:	89 14 24             	mov    %edx,(%esp)
  80095e:	e8 77 fe ff ff       	call   8007da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800963:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800966:	e9 ba fe ff ff       	jmp    800825 <vprintfmt+0x23>
  80096b:	89 f9                	mov    %edi,%ecx
  80096d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800970:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800973:	8b 45 14             	mov    0x14(%ebp),%eax
  800976:	8d 50 04             	lea    0x4(%eax),%edx
  800979:	89 55 14             	mov    %edx,0x14(%ebp)
  80097c:	8b 30                	mov    (%eax),%esi
  80097e:	85 f6                	test   %esi,%esi
  800980:	75 05                	jne    800987 <vprintfmt+0x185>
				p = "(null)";
  800982:	be 00 31 80 00       	mov    $0x803100,%esi
			if (width > 0 && padc != '-')
  800987:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80098b:	0f 8e 84 00 00 00    	jle    800a15 <vprintfmt+0x213>
  800991:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800995:	74 7e                	je     800a15 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800997:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80099b:	89 34 24             	mov    %esi,(%esp)
  80099e:	e8 8b 02 00 00       	call   800c2e <strnlen>
  8009a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009a6:	29 c2                	sub    %eax,%edx
  8009a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009ab:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009af:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009b2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009b5:	89 de                	mov    %ebx,%esi
  8009b7:	89 d3                	mov    %edx,%ebx
  8009b9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bb:	eb 0b                	jmp    8009c8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009c1:	89 3c 24             	mov    %edi,(%esp)
  8009c4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c7:	4b                   	dec    %ebx
  8009c8:	85 db                	test   %ebx,%ebx
  8009ca:	7f f1                	jg     8009bd <vprintfmt+0x1bb>
  8009cc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8009d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009d7:	85 c0                	test   %eax,%eax
  8009d9:	79 05                	jns    8009e0 <vprintfmt+0x1de>
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009e3:	29 c2                	sub    %eax,%edx
  8009e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009e8:	eb 2b                	jmp    800a15 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009ea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009ee:	74 18                	je     800a08 <vprintfmt+0x206>
  8009f0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009f3:	83 fa 5e             	cmp    $0x5e,%edx
  8009f6:	76 10                	jbe    800a08 <vprintfmt+0x206>
					putch('?', putdat);
  8009f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009fc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a03:	ff 55 08             	call   *0x8(%ebp)
  800a06:	eb 0a                	jmp    800a12 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0c:	89 04 24             	mov    %eax,(%esp)
  800a0f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a12:	ff 4d e4             	decl   -0x1c(%ebp)
  800a15:	0f be 06             	movsbl (%esi),%eax
  800a18:	46                   	inc    %esi
  800a19:	85 c0                	test   %eax,%eax
  800a1b:	74 21                	je     800a3e <vprintfmt+0x23c>
  800a1d:	85 ff                	test   %edi,%edi
  800a1f:	78 c9                	js     8009ea <vprintfmt+0x1e8>
  800a21:	4f                   	dec    %edi
  800a22:	79 c6                	jns    8009ea <vprintfmt+0x1e8>
  800a24:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a27:	89 de                	mov    %ebx,%esi
  800a29:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a2c:	eb 18                	jmp    800a46 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a32:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a39:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a3b:	4b                   	dec    %ebx
  800a3c:	eb 08                	jmp    800a46 <vprintfmt+0x244>
  800a3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a41:	89 de                	mov    %ebx,%esi
  800a43:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a46:	85 db                	test   %ebx,%ebx
  800a48:	7f e4                	jg     800a2e <vprintfmt+0x22c>
  800a4a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a4d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a52:	e9 ce fd ff ff       	jmp    800825 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a57:	83 f9 01             	cmp    $0x1,%ecx
  800a5a:	7e 10                	jle    800a6c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a5c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5f:	8d 50 08             	lea    0x8(%eax),%edx
  800a62:	89 55 14             	mov    %edx,0x14(%ebp)
  800a65:	8b 30                	mov    (%eax),%esi
  800a67:	8b 78 04             	mov    0x4(%eax),%edi
  800a6a:	eb 26                	jmp    800a92 <vprintfmt+0x290>
	else if (lflag)
  800a6c:	85 c9                	test   %ecx,%ecx
  800a6e:	74 12                	je     800a82 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a70:	8b 45 14             	mov    0x14(%ebp),%eax
  800a73:	8d 50 04             	lea    0x4(%eax),%edx
  800a76:	89 55 14             	mov    %edx,0x14(%ebp)
  800a79:	8b 30                	mov    (%eax),%esi
  800a7b:	89 f7                	mov    %esi,%edi
  800a7d:	c1 ff 1f             	sar    $0x1f,%edi
  800a80:	eb 10                	jmp    800a92 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a82:	8b 45 14             	mov    0x14(%ebp),%eax
  800a85:	8d 50 04             	lea    0x4(%eax),%edx
  800a88:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8b:	8b 30                	mov    (%eax),%esi
  800a8d:	89 f7                	mov    %esi,%edi
  800a8f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a92:	85 ff                	test   %edi,%edi
  800a94:	78 0a                	js     800aa0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a96:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a9b:	e9 8c 00 00 00       	jmp    800b2c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800aa0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800aab:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800aae:	f7 de                	neg    %esi
  800ab0:	83 d7 00             	adc    $0x0,%edi
  800ab3:	f7 df                	neg    %edi
			}
			base = 10;
  800ab5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aba:	eb 70                	jmp    800b2c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800abc:	89 ca                	mov    %ecx,%edx
  800abe:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac1:	e8 c0 fc ff ff       	call   800786 <getuint>
  800ac6:	89 c6                	mov    %eax,%esi
  800ac8:	89 d7                	mov    %edx,%edi
			base = 10;
  800aca:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800acf:	eb 5b                	jmp    800b2c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800ad1:	89 ca                	mov    %ecx,%edx
  800ad3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad6:	e8 ab fc ff ff       	call   800786 <getuint>
  800adb:	89 c6                	mov    %eax,%esi
  800add:	89 d7                	mov    %edx,%edi
			base = 8;
  800adf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800ae4:	eb 46                	jmp    800b2c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800ae6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aea:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800af1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800af4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800aff:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b02:	8b 45 14             	mov    0x14(%ebp),%eax
  800b05:	8d 50 04             	lea    0x4(%eax),%edx
  800b08:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b0b:	8b 30                	mov    (%eax),%esi
  800b0d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b12:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b17:	eb 13                	jmp    800b2c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b19:	89 ca                	mov    %ecx,%edx
  800b1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1e:	e8 63 fc ff ff       	call   800786 <getuint>
  800b23:	89 c6                	mov    %eax,%esi
  800b25:	89 d7                	mov    %edx,%edi
			base = 16;
  800b27:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b2c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b30:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b37:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3f:	89 34 24             	mov    %esi,(%esp)
  800b42:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b46:	89 da                	mov    %ebx,%edx
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	e8 6c fb ff ff       	call   8006bc <printnum>
			break;
  800b50:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b53:	e9 cd fc ff ff       	jmp    800825 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b5c:	89 04 24             	mov    %eax,(%esp)
  800b5f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b62:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b65:	e9 bb fc ff ff       	jmp    800825 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b6e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b75:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b78:	eb 01                	jmp    800b7b <vprintfmt+0x379>
  800b7a:	4e                   	dec    %esi
  800b7b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b7f:	75 f9                	jne    800b7a <vprintfmt+0x378>
  800b81:	e9 9f fc ff ff       	jmp    800825 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b86:	83 c4 4c             	add    $0x4c,%esp
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 28             	sub    $0x28,%esp
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b9d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ba1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ba4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	74 30                	je     800bdf <vsnprintf+0x51>
  800baf:	85 d2                	test   %edx,%edx
  800bb1:	7e 33                	jle    800be6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bba:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc8:	c7 04 24 c0 07 80 00 	movl   $0x8007c0,(%esp)
  800bcf:	e8 2e fc ff ff       	call   800802 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bd7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bdd:	eb 0c                	jmp    800beb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bdf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800be4:	eb 05                	jmp    800beb <vsnprintf+0x5d>
  800be6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bf3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	89 04 24             	mov    %eax,(%esp)
  800c0e:	e8 7b ff ff ff       	call   800b8e <vsnprintf>
	va_end(ap);

	return rc;
}
  800c13:	c9                   	leave  
  800c14:	c3                   	ret    
  800c15:	00 00                	add    %al,(%eax)
	...

00800c18 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	eb 01                	jmp    800c26 <strlen+0xe>
		n++;
  800c25:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c26:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c2a:	75 f9                	jne    800c25 <strlen+0xd>
		n++;
	return n;
}
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c34:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3c:	eb 01                	jmp    800c3f <strnlen+0x11>
		n++;
  800c3e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3f:	39 d0                	cmp    %edx,%eax
  800c41:	74 06                	je     800c49 <strnlen+0x1b>
  800c43:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c47:	75 f5                	jne    800c3e <strnlen+0x10>
		n++;
	return n;
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	53                   	push   %ebx
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c55:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c5d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c60:	42                   	inc    %edx
  800c61:	84 c9                	test   %cl,%cl
  800c63:	75 f5                	jne    800c5a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c65:	5b                   	pop    %ebx
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 08             	sub    $0x8,%esp
  800c6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c72:	89 1c 24             	mov    %ebx,(%esp)
  800c75:	e8 9e ff ff ff       	call   800c18 <strlen>
	strcpy(dst + len, src);
  800c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c81:	01 d8                	add    %ebx,%eax
  800c83:	89 04 24             	mov    %eax,(%esp)
  800c86:	e8 c0 ff ff ff       	call   800c4b <strcpy>
	return dst;
}
  800c8b:	89 d8                	mov    %ebx,%eax
  800c8d:	83 c4 08             	add    $0x8,%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca6:	eb 0c                	jmp    800cb4 <strncpy+0x21>
		*dst++ = *src;
  800ca8:	8a 1a                	mov    (%edx),%bl
  800caa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cad:	80 3a 01             	cmpb   $0x1,(%edx)
  800cb0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb3:	41                   	inc    %ecx
  800cb4:	39 f1                	cmp    %esi,%ecx
  800cb6:	75 f0                	jne    800ca8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cca:	85 d2                	test   %edx,%edx
  800ccc:	75 0a                	jne    800cd8 <strlcpy+0x1c>
  800cce:	89 f0                	mov    %esi,%eax
  800cd0:	eb 1a                	jmp    800cec <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cd2:	88 18                	mov    %bl,(%eax)
  800cd4:	40                   	inc    %eax
  800cd5:	41                   	inc    %ecx
  800cd6:	eb 02                	jmp    800cda <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cd8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800cda:	4a                   	dec    %edx
  800cdb:	74 0a                	je     800ce7 <strlcpy+0x2b>
  800cdd:	8a 19                	mov    (%ecx),%bl
  800cdf:	84 db                	test   %bl,%bl
  800ce1:	75 ef                	jne    800cd2 <strlcpy+0x16>
  800ce3:	89 c2                	mov    %eax,%edx
  800ce5:	eb 02                	jmp    800ce9 <strlcpy+0x2d>
  800ce7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ce9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800cec:	29 f0                	sub    %esi,%eax
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cfb:	eb 02                	jmp    800cff <strcmp+0xd>
		p++, q++;
  800cfd:	41                   	inc    %ecx
  800cfe:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cff:	8a 01                	mov    (%ecx),%al
  800d01:	84 c0                	test   %al,%al
  800d03:	74 04                	je     800d09 <strcmp+0x17>
  800d05:	3a 02                	cmp    (%edx),%al
  800d07:	74 f4                	je     800cfd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d09:	0f b6 c0             	movzbl %al,%eax
  800d0c:	0f b6 12             	movzbl (%edx),%edx
  800d0f:	29 d0                	sub    %edx,%eax
}
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	53                   	push   %ebx
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d20:	eb 03                	jmp    800d25 <strncmp+0x12>
		n--, p++, q++;
  800d22:	4a                   	dec    %edx
  800d23:	40                   	inc    %eax
  800d24:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d25:	85 d2                	test   %edx,%edx
  800d27:	74 14                	je     800d3d <strncmp+0x2a>
  800d29:	8a 18                	mov    (%eax),%bl
  800d2b:	84 db                	test   %bl,%bl
  800d2d:	74 04                	je     800d33 <strncmp+0x20>
  800d2f:	3a 19                	cmp    (%ecx),%bl
  800d31:	74 ef                	je     800d22 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d33:	0f b6 00             	movzbl (%eax),%eax
  800d36:	0f b6 11             	movzbl (%ecx),%edx
  800d39:	29 d0                	sub    %edx,%eax
  800d3b:	eb 05                	jmp    800d42 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d42:	5b                   	pop    %ebx
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d4e:	eb 05                	jmp    800d55 <strchr+0x10>
		if (*s == c)
  800d50:	38 ca                	cmp    %cl,%dl
  800d52:	74 0c                	je     800d60 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d54:	40                   	inc    %eax
  800d55:	8a 10                	mov    (%eax),%dl
  800d57:	84 d2                	test   %dl,%dl
  800d59:	75 f5                	jne    800d50 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d6b:	eb 05                	jmp    800d72 <strfind+0x10>
		if (*s == c)
  800d6d:	38 ca                	cmp    %cl,%dl
  800d6f:	74 07                	je     800d78 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d71:	40                   	inc    %eax
  800d72:	8a 10                	mov    (%eax),%dl
  800d74:	84 d2                	test   %dl,%dl
  800d76:	75 f5                	jne    800d6d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d89:	85 c9                	test   %ecx,%ecx
  800d8b:	74 30                	je     800dbd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d93:	75 25                	jne    800dba <memset+0x40>
  800d95:	f6 c1 03             	test   $0x3,%cl
  800d98:	75 20                	jne    800dba <memset+0x40>
		c &= 0xFF;
  800d9a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d9d:	89 d3                	mov    %edx,%ebx
  800d9f:	c1 e3 08             	shl    $0x8,%ebx
  800da2:	89 d6                	mov    %edx,%esi
  800da4:	c1 e6 18             	shl    $0x18,%esi
  800da7:	89 d0                	mov    %edx,%eax
  800da9:	c1 e0 10             	shl    $0x10,%eax
  800dac:	09 f0                	or     %esi,%eax
  800dae:	09 d0                	or     %edx,%eax
  800db0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800db2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800db5:	fc                   	cld    
  800db6:	f3 ab                	rep stos %eax,%es:(%edi)
  800db8:	eb 03                	jmp    800dbd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dba:	fc                   	cld    
  800dbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dbd:	89 f8                	mov    %edi,%eax
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dd2:	39 c6                	cmp    %eax,%esi
  800dd4:	73 34                	jae    800e0a <memmove+0x46>
  800dd6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dd9:	39 d0                	cmp    %edx,%eax
  800ddb:	73 2d                	jae    800e0a <memmove+0x46>
		s += n;
		d += n;
  800ddd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800de0:	f6 c2 03             	test   $0x3,%dl
  800de3:	75 1b                	jne    800e00 <memmove+0x3c>
  800de5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800deb:	75 13                	jne    800e00 <memmove+0x3c>
  800ded:	f6 c1 03             	test   $0x3,%cl
  800df0:	75 0e                	jne    800e00 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800df2:	83 ef 04             	sub    $0x4,%edi
  800df5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800df8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800dfb:	fd                   	std    
  800dfc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dfe:	eb 07                	jmp    800e07 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e00:	4f                   	dec    %edi
  800e01:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e04:	fd                   	std    
  800e05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e07:	fc                   	cld    
  800e08:	eb 20                	jmp    800e2a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e0a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e10:	75 13                	jne    800e25 <memmove+0x61>
  800e12:	a8 03                	test   $0x3,%al
  800e14:	75 0f                	jne    800e25 <memmove+0x61>
  800e16:	f6 c1 03             	test   $0x3,%cl
  800e19:	75 0a                	jne    800e25 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e1b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e1e:	89 c7                	mov    %eax,%edi
  800e20:	fc                   	cld    
  800e21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e23:	eb 05                	jmp    800e2a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e25:	89 c7                	mov    %eax,%edi
  800e27:	fc                   	cld    
  800e28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e34:	8b 45 10             	mov    0x10(%ebp),%eax
  800e37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e42:	8b 45 08             	mov    0x8(%ebp),%eax
  800e45:	89 04 24             	mov    %eax,(%esp)
  800e48:	e8 77 ff ff ff       	call   800dc4 <memmove>
}
  800e4d:	c9                   	leave  
  800e4e:	c3                   	ret    

00800e4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e63:	eb 16                	jmp    800e7b <memcmp+0x2c>
		if (*s1 != *s2)
  800e65:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e68:	42                   	inc    %edx
  800e69:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e6d:	38 c8                	cmp    %cl,%al
  800e6f:	74 0a                	je     800e7b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e71:	0f b6 c0             	movzbl %al,%eax
  800e74:	0f b6 c9             	movzbl %cl,%ecx
  800e77:	29 c8                	sub    %ecx,%eax
  800e79:	eb 09                	jmp    800e84 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7b:	39 da                	cmp    %ebx,%edx
  800e7d:	75 e6                	jne    800e65 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e92:	89 c2                	mov    %eax,%edx
  800e94:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e97:	eb 05                	jmp    800e9e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e99:	38 08                	cmp    %cl,(%eax)
  800e9b:	74 05                	je     800ea2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e9d:	40                   	inc    %eax
  800e9e:	39 d0                	cmp    %edx,%eax
  800ea0:	72 f7                	jb     800e99 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ead:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eb0:	eb 01                	jmp    800eb3 <strtol+0xf>
		s++;
  800eb2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eb3:	8a 02                	mov    (%edx),%al
  800eb5:	3c 20                	cmp    $0x20,%al
  800eb7:	74 f9                	je     800eb2 <strtol+0xe>
  800eb9:	3c 09                	cmp    $0x9,%al
  800ebb:	74 f5                	je     800eb2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ebd:	3c 2b                	cmp    $0x2b,%al
  800ebf:	75 08                	jne    800ec9 <strtol+0x25>
		s++;
  800ec1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ec2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ec7:	eb 13                	jmp    800edc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ec9:	3c 2d                	cmp    $0x2d,%al
  800ecb:	75 0a                	jne    800ed7 <strtol+0x33>
		s++, neg = 1;
  800ecd:	8d 52 01             	lea    0x1(%edx),%edx
  800ed0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ed5:	eb 05                	jmp    800edc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800edc:	85 db                	test   %ebx,%ebx
  800ede:	74 05                	je     800ee5 <strtol+0x41>
  800ee0:	83 fb 10             	cmp    $0x10,%ebx
  800ee3:	75 28                	jne    800f0d <strtol+0x69>
  800ee5:	8a 02                	mov    (%edx),%al
  800ee7:	3c 30                	cmp    $0x30,%al
  800ee9:	75 10                	jne    800efb <strtol+0x57>
  800eeb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eef:	75 0a                	jne    800efb <strtol+0x57>
		s += 2, base = 16;
  800ef1:	83 c2 02             	add    $0x2,%edx
  800ef4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ef9:	eb 12                	jmp    800f0d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800efb:	85 db                	test   %ebx,%ebx
  800efd:	75 0e                	jne    800f0d <strtol+0x69>
  800eff:	3c 30                	cmp    $0x30,%al
  800f01:	75 05                	jne    800f08 <strtol+0x64>
		s++, base = 8;
  800f03:	42                   	inc    %edx
  800f04:	b3 08                	mov    $0x8,%bl
  800f06:	eb 05                	jmp    800f0d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f08:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f12:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f14:	8a 0a                	mov    (%edx),%cl
  800f16:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f19:	80 fb 09             	cmp    $0x9,%bl
  800f1c:	77 08                	ja     800f26 <strtol+0x82>
			dig = *s - '0';
  800f1e:	0f be c9             	movsbl %cl,%ecx
  800f21:	83 e9 30             	sub    $0x30,%ecx
  800f24:	eb 1e                	jmp    800f44 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f26:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f29:	80 fb 19             	cmp    $0x19,%bl
  800f2c:	77 08                	ja     800f36 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f2e:	0f be c9             	movsbl %cl,%ecx
  800f31:	83 e9 57             	sub    $0x57,%ecx
  800f34:	eb 0e                	jmp    800f44 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f36:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f39:	80 fb 19             	cmp    $0x19,%bl
  800f3c:	77 12                	ja     800f50 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f3e:	0f be c9             	movsbl %cl,%ecx
  800f41:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f44:	39 f1                	cmp    %esi,%ecx
  800f46:	7d 0c                	jge    800f54 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f48:	42                   	inc    %edx
  800f49:	0f af c6             	imul   %esi,%eax
  800f4c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f4e:	eb c4                	jmp    800f14 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f50:	89 c1                	mov    %eax,%ecx
  800f52:	eb 02                	jmp    800f56 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f54:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f5a:	74 05                	je     800f61 <strtol+0xbd>
		*endptr = (char *) s;
  800f5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f5f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f61:	85 ff                	test   %edi,%edi
  800f63:	74 04                	je     800f69 <strtol+0xc5>
  800f65:	89 c8                	mov    %ecx,%eax
  800f67:	f7 d8                	neg    %eax
}
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    
	...

00800f70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f81:	89 c3                	mov    %eax,%ebx
  800f83:	89 c7                	mov    %eax,%edi
  800f85:	89 c6                	mov    %eax,%esi
  800f87:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <sys_cgetc>:

int
sys_cgetc(void)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f94:	ba 00 00 00 00       	mov    $0x0,%edx
  800f99:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9e:	89 d1                	mov    %edx,%ecx
  800fa0:	89 d3                	mov    %edx,%ebx
  800fa2:	89 d7                	mov    %edx,%edi
  800fa4:	89 d6                	mov    %edx,%esi
  800fa6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbb:	b8 03 00 00 00       	mov    $0x3,%eax
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	89 cb                	mov    %ecx,%ebx
  800fc5:	89 cf                	mov    %ecx,%edi
  800fc7:	89 ce                	mov    %ecx,%esi
  800fc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	7e 28                	jle    800ff7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fda:	00 
  800fdb:	c7 44 24 08 ff 33 80 	movl   $0x8033ff,0x8(%esp)
  800fe2:	00 
  800fe3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fea:	00 
  800feb:	c7 04 24 1c 34 80 00 	movl   $0x80341c,(%esp)
  800ff2:	e8 b1 f5 ff ff       	call   8005a8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ff7:	83 c4 2c             	add    $0x2c,%esp
  800ffa:	5b                   	pop    %ebx
  800ffb:	5e                   	pop    %esi
  800ffc:	5f                   	pop    %edi
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	57                   	push   %edi
  801003:	56                   	push   %esi
  801004:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801005:	ba 00 00 00 00       	mov    $0x0,%edx
  80100a:	b8 02 00 00 00       	mov    $0x2,%eax
  80100f:	89 d1                	mov    %edx,%ecx
  801011:	89 d3                	mov    %edx,%ebx
  801013:	89 d7                	mov    %edx,%edi
  801015:	89 d6                	mov    %edx,%esi
  801017:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801019:	5b                   	pop    %ebx
  80101a:	5e                   	pop    %esi
  80101b:	5f                   	pop    %edi
  80101c:	5d                   	pop    %ebp
  80101d:	c3                   	ret    

0080101e <sys_yield>:

void
sys_yield(void)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801024:	ba 00 00 00 00       	mov    $0x0,%edx
  801029:	b8 0b 00 00 00       	mov    $0xb,%eax
  80102e:	89 d1                	mov    %edx,%ecx
  801030:	89 d3                	mov    %edx,%ebx
  801032:	89 d7                	mov    %edx,%edi
  801034:	89 d6                	mov    %edx,%esi
  801036:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	57                   	push   %edi
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
  801043:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801046:	be 00 00 00 00       	mov    $0x0,%esi
  80104b:	b8 04 00 00 00       	mov    $0x4,%eax
  801050:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801053:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801056:	8b 55 08             	mov    0x8(%ebp),%edx
  801059:	89 f7                	mov    %esi,%edi
  80105b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80105d:	85 c0                	test   %eax,%eax
  80105f:	7e 28                	jle    801089 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801061:	89 44 24 10          	mov    %eax,0x10(%esp)
  801065:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80106c:	00 
  80106d:	c7 44 24 08 ff 33 80 	movl   $0x8033ff,0x8(%esp)
  801074:	00 
  801075:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107c:	00 
  80107d:	c7 04 24 1c 34 80 00 	movl   $0x80341c,(%esp)
  801084:	e8 1f f5 ff ff       	call   8005a8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801089:	83 c4 2c             	add    $0x2c,%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	57                   	push   %edi
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109a:	b8 05 00 00 00       	mov    $0x5,%eax
  80109f:	8b 75 18             	mov    0x18(%ebp),%esi
  8010a2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	7e 28                	jle    8010dc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 08 ff 33 80 	movl   $0x8033ff,0x8(%esp)
  8010c7:	00 
  8010c8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010cf:	00 
  8010d0:	c7 04 24 1c 34 80 00 	movl   $0x80341c,(%esp)
  8010d7:	e8 cc f4 ff ff       	call   8005a8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010dc:	83 c4 2c             	add    $0x2c,%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fd:	89 df                	mov    %ebx,%edi
  8010ff:	89 de                	mov    %ebx,%esi
  801101:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801103:	85 c0                	test   %eax,%eax
  801105:	7e 28                	jle    80112f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801112:	00 
  801113:	c7 44 24 08 ff 33 80 	movl   $0x8033ff,0x8(%esp)
  80111a:	00 
  80111b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801122:	00 
  801123:	c7 04 24 1c 34 80 00 	movl   $0x80341c,(%esp)
  80112a:	e8 79 f4 ff ff       	call   8005a8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80112f:	83 c4 2c             	add    $0x2c,%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801140:	bb 00 00 00 00       	mov    $0x0,%ebx
  801145:	b8 08 00 00 00       	mov    $0x8,%eax
  80114a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114d:	8b 55 08             	mov    0x8(%ebp),%edx
  801150:	89 df                	mov    %ebx,%edi
  801152:	89 de                	mov    %ebx,%esi
  801154:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801156:	85 c0                	test   %eax,%eax
  801158:	7e 28                	jle    801182 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80115a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801165:	00 
  801166:	c7 44 24 08 ff 33 80 	movl   $0x8033ff,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 1c 34 80 00 	movl   $0x80341c,(%esp)
  80117d:	e8 26 f4 ff ff       	call   8005a8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801182:	83 c4 2c             	add    $0x2c,%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    

0080118a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	57                   	push   %edi
  80118e:	56                   	push   %esi
  80118f:	53                   	push   %ebx
  801190:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801193:	bb 00 00 00 00       	mov    $0x0,%ebx
  801198:	b8 09 00 00 00       	mov    $0x9,%eax
  80119d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a3:	89 df                	mov    %ebx,%edi
  8011a5:	89 de                	mov    %ebx,%esi
  8011a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	7e 28                	jle    8011d5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 08 ff 33 80 	movl   $0x8033ff,0x8(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c8:	00 
  8011c9:	c7 04 24 1c 34 80 00 	movl   $0x80341c,(%esp)
  8011d0:	e8 d3 f3 ff ff       	call   8005a8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011d5:	83 c4 2c             	add    $0x2c,%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f6:	89 df                	mov    %ebx,%edi
  8011f8:	89 de                	mov    %ebx,%esi
  8011fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	7e 28                	jle    801228 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801200:	89 44 24 10          	mov    %eax,0x10(%esp)
  801204:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80120b:	00 
  80120c:	c7 44 24 08 ff 33 80 	movl   $0x8033ff,0x8(%esp)
  801213:	00 
  801214:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80121b:	00 
  80121c:	c7 04 24 1c 34 80 00 	movl   $0x80341c,(%esp)
  801223:	e8 80 f3 ff ff       	call   8005a8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801228:	83 c4 2c             	add    $0x2c,%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801236:	be 00 00 00 00       	mov    $0x0,%esi
  80123b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801240:	8b 7d 14             	mov    0x14(%ebp),%edi
  801243:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801246:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801249:	8b 55 08             	mov    0x8(%ebp),%edx
  80124c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80124e:	5b                   	pop    %ebx
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	57                   	push   %edi
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801261:	b8 0d 00 00 00       	mov    $0xd,%eax
  801266:	8b 55 08             	mov    0x8(%ebp),%edx
  801269:	89 cb                	mov    %ecx,%ebx
  80126b:	89 cf                	mov    %ecx,%edi
  80126d:	89 ce                	mov    %ecx,%esi
  80126f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801271:	85 c0                	test   %eax,%eax
  801273:	7e 28                	jle    80129d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801275:	89 44 24 10          	mov    %eax,0x10(%esp)
  801279:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801280:	00 
  801281:	c7 44 24 08 ff 33 80 	movl   $0x8033ff,0x8(%esp)
  801288:	00 
  801289:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801290:	00 
  801291:	c7 04 24 1c 34 80 00 	movl   $0x80341c,(%esp)
  801298:	e8 0b f3 ff ff       	call   8005a8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80129d:	83 c4 2c             	add    $0x2c,%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    
  8012a5:	00 00                	add    %al,(%eax)
	...

008012a8 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	57                   	push   %edi
  8012ac:	56                   	push   %esi
  8012ad:	53                   	push   %ebx
  8012ae:	83 ec 3c             	sub    $0x3c,%esp
  8012b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  8012b4:	89 d6                	mov    %edx,%esi
  8012b6:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  8012b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  8012c3:	e8 37 fd ff ff       	call   800fff <sys_getenvid>
  8012c8:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  8012ca:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  8012d1:	74 31                	je     801304 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  8012d3:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  8012da:	00 
  8012db:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ea:	89 3c 24             	mov    %edi,(%esp)
  8012ed:	e8 9f fd ff ff       	call   801091 <sys_page_map>
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	0f 8e ae 00 00 00    	jle    8013a8 <duppage+0x100>
  8012fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ff:	e9 a4 00 00 00       	jmp    8013a8 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  801304:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801307:	25 02 08 00 00       	and    $0x802,%eax
  80130c:	83 f8 01             	cmp    $0x1,%eax
  80130f:	19 db                	sbb    %ebx,%ebx
  801311:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801317:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  80131d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801321:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801328:	89 44 24 08          	mov    %eax,0x8(%esp)
  80132c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801330:	89 3c 24             	mov    %edi,(%esp)
  801333:	e8 59 fd ff ff       	call   801091 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  801338:	85 c0                	test   %eax,%eax
  80133a:	79 1c                	jns    801358 <duppage+0xb0>
  80133c:	c7 44 24 08 2a 34 80 	movl   $0x80342a,0x8(%esp)
  801343:	00 
  801344:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80134b:	00 
  80134c:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  801353:	e8 50 f2 ff ff       	call   8005a8 <_panic>
	if ((perm|~pte)&PTE_COW){
  801358:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80135b:	f7 d0                	not    %eax
  80135d:	09 d8                	or     %ebx,%eax
  80135f:	f6 c4 08             	test   $0x8,%ah
  801362:	74 38                	je     80139c <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  801364:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801368:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80136c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801370:	89 74 24 04          	mov    %esi,0x4(%esp)
  801374:	89 3c 24             	mov    %edi,(%esp)
  801377:	e8 15 fd ff ff       	call   801091 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  80137c:	85 c0                	test   %eax,%eax
  80137e:	79 23                	jns    8013a3 <duppage+0xfb>
  801380:	c7 44 24 08 2a 34 80 	movl   $0x80342a,0x8(%esp)
  801387:	00 
  801388:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80138f:	00 
  801390:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  801397:	e8 0c f2 ff ff       	call   8005a8 <_panic>
	}
	return 0;
  80139c:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a1:	eb 05                	jmp    8013a8 <duppage+0x100>
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  8013a8:	83 c4 3c             	add    $0x3c,%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5e                   	pop    %esi
  8013ad:	5f                   	pop    %edi
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	56                   	push   %esi
  8013b4:	53                   	push   %ebx
  8013b5:	83 ec 20             	sub    $0x20,%esp
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8013bb:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  8013bd:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8013c1:	75 1c                	jne    8013df <pgfault+0x2f>
		panic("pgfault: error!\n");
  8013c3:	c7 44 24 08 46 34 80 	movl   $0x803446,0x8(%esp)
  8013ca:	00 
  8013cb:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8013d2:	00 
  8013d3:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  8013da:	e8 c9 f1 ff ff       	call   8005a8 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  8013df:	89 f0                	mov    %esi,%eax
  8013e1:	c1 e8 0c             	shr    $0xc,%eax
  8013e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013eb:	f6 c4 08             	test   $0x8,%ah
  8013ee:	75 1c                	jne    80140c <pgfault+0x5c>
		panic("pgfault: error!\n");
  8013f0:	c7 44 24 08 46 34 80 	movl   $0x803446,0x8(%esp)
  8013f7:	00 
  8013f8:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8013ff:	00 
  801400:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  801407:	e8 9c f1 ff ff       	call   8005a8 <_panic>
	envid_t envid = sys_getenvid();
  80140c:	e8 ee fb ff ff       	call   800fff <sys_getenvid>
  801411:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  801413:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80141a:	00 
  80141b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801422:	00 
  801423:	89 04 24             	mov    %eax,(%esp)
  801426:	e8 12 fc ff ff       	call   80103d <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  80142b:	85 c0                	test   %eax,%eax
  80142d:	79 1c                	jns    80144b <pgfault+0x9b>
  80142f:	c7 44 24 08 46 34 80 	movl   $0x803446,0x8(%esp)
  801436:	00 
  801437:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80143e:	00 
  80143f:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  801446:	e8 5d f1 ff ff       	call   8005a8 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  80144b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  801451:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801458:	00 
  801459:	89 74 24 04          	mov    %esi,0x4(%esp)
  80145d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801464:	e8 c5 f9 ff ff       	call   800e2e <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  801469:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801470:	00 
  801471:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801475:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801479:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801480:	00 
  801481:	89 1c 24             	mov    %ebx,(%esp)
  801484:	e8 08 fc ff ff       	call   801091 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801489:	85 c0                	test   %eax,%eax
  80148b:	79 1c                	jns    8014a9 <pgfault+0xf9>
  80148d:	c7 44 24 08 46 34 80 	movl   $0x803446,0x8(%esp)
  801494:	00 
  801495:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80149c:	00 
  80149d:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  8014a4:	e8 ff f0 ff ff       	call   8005a8 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  8014a9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014b0:	00 
  8014b1:	89 1c 24             	mov    %ebx,(%esp)
  8014b4:	e8 2b fc ff ff       	call   8010e4 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	79 1c                	jns    8014d9 <pgfault+0x129>
  8014bd:	c7 44 24 08 46 34 80 	movl   $0x803446,0x8(%esp)
  8014c4:	00 
  8014c5:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8014cc:	00 
  8014cd:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  8014d4:	e8 cf f0 ff ff       	call   8005a8 <_panic>
	return;
	panic("pgfault not implemented");
}
  8014d9:	83 c4 20             	add    $0x20,%esp
  8014dc:	5b                   	pop    %ebx
  8014dd:	5e                   	pop    %esi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	57                   	push   %edi
  8014e4:	56                   	push   %esi
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8014e9:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  8014f0:	e8 13 16 00 00       	call   802b08 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8014f5:	bf 07 00 00 00       	mov    $0x7,%edi
  8014fa:	89 f8                	mov    %edi,%eax
  8014fc:	cd 30                	int    $0x30
  8014fe:	89 c7                	mov    %eax,%edi
  801500:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  801502:	85 c0                	test   %eax,%eax
  801504:	79 1c                	jns    801522 <fork+0x42>
		panic("fork : error!\n");
  801506:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  80150d:	00 
  80150e:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  801515:	00 
  801516:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  80151d:	e8 86 f0 ff ff       	call   8005a8 <_panic>
	if (envid==0){
  801522:	85 c0                	test   %eax,%eax
  801524:	75 28                	jne    80154e <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  801526:	8b 1d 04 50 80 00    	mov    0x805004,%ebx
  80152c:	e8 ce fa ff ff       	call   800fff <sys_getenvid>
  801531:	25 ff 03 00 00       	and    $0x3ff,%eax
  801536:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80153d:	c1 e0 07             	shl    $0x7,%eax
  801540:	29 d0                	sub    %edx,%eax
  801542:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801547:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  801549:	e9 f2 00 00 00       	jmp    801640 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  80154e:	e8 ac fa ff ff       	call   800fff <sys_getenvid>
  801553:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801556:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  80155b:	89 d8                	mov    %ebx,%eax
  80155d:	c1 e8 16             	shr    $0x16,%eax
  801560:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801567:	a8 01                	test   $0x1,%al
  801569:	74 17                	je     801582 <fork+0xa2>
  80156b:	89 da                	mov    %ebx,%edx
  80156d:	c1 ea 0c             	shr    $0xc,%edx
  801570:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801577:	a8 01                	test   $0x1,%al
  801579:	74 07                	je     801582 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  80157b:	89 f0                	mov    %esi,%eax
  80157d:	e8 26 fd ff ff       	call   8012a8 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801582:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801588:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80158e:	75 cb                	jne    80155b <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801590:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801597:	00 
  801598:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80159f:	ee 
  8015a0:	89 3c 24             	mov    %edi,(%esp)
  8015a3:	e8 95 fa ff ff       	call   80103d <sys_page_alloc>
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	79 1c                	jns    8015c8 <fork+0xe8>
  8015ac:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  8015b3:	00 
  8015b4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8015bb:	00 
  8015bc:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  8015c3:	e8 e0 ef ff ff       	call   8005a8 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  8015c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015cb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8015d7:	c1 e0 07             	shl    $0x7,%eax
  8015da:	29 d0                	sub    %edx,%eax
  8015dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015e1:	8b 40 64             	mov    0x64(%eax),%eax
  8015e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e8:	89 3c 24             	mov    %edi,(%esp)
  8015eb:	e8 ed fb ff ff       	call   8011dd <sys_env_set_pgfault_upcall>
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	79 1c                	jns    801610 <fork+0x130>
  8015f4:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  8015fb:	00 
  8015fc:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801603:	00 
  801604:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  80160b:	e8 98 ef ff ff       	call   8005a8 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  801610:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801617:	00 
  801618:	89 3c 24             	mov    %edi,(%esp)
  80161b:	e8 17 fb ff ff       	call   801137 <sys_env_set_status>
  801620:	85 c0                	test   %eax,%eax
  801622:	79 1c                	jns    801640 <fork+0x160>
  801624:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  80162b:	00 
  80162c:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801633:	00 
  801634:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  80163b:	e8 68 ef ff ff       	call   8005a8 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801640:	89 f8                	mov    %edi,%eax
  801642:	83 c4 2c             	add    $0x2c,%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	5f                   	pop    %edi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <sfork>:

// Challenge!
int
sfork(void)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	57                   	push   %edi
  80164e:	56                   	push   %esi
  80164f:	53                   	push   %ebx
  801650:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  801653:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  80165a:	e8 a9 14 00 00       	call   802b08 <set_pgfault_handler>
  80165f:	ba 07 00 00 00       	mov    $0x7,%edx
  801664:	89 d0                	mov    %edx,%eax
  801666:	cd 30                	int    $0x30
  801668:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80166b:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  80166d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801671:	c7 04 24 57 34 80 00 	movl   $0x803457,(%esp)
  801678:	e8 23 f0 ff ff       	call   8006a0 <cprintf>
	if (envid<0)
  80167d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801681:	79 1c                	jns    80169f <sfork+0x55>
		panic("sfork : error!\n");
  801683:	c7 44 24 08 62 34 80 	movl   $0x803462,0x8(%esp)
  80168a:	00 
  80168b:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  801692:	00 
  801693:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  80169a:	e8 09 ef ff ff       	call   8005a8 <_panic>
	if (envid==0){
  80169f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8016a3:	75 28                	jne    8016cd <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  8016a5:	8b 1d 04 50 80 00    	mov    0x805004,%ebx
  8016ab:	e8 4f f9 ff ff       	call   800fff <sys_getenvid>
  8016b0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016b5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8016bc:	c1 e0 07             	shl    $0x7,%eax
  8016bf:	29 d0                	sub    %edx,%eax
  8016c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016c6:	89 03                	mov    %eax,(%ebx)
		return envid;
  8016c8:	e9 18 01 00 00       	jmp    8017e5 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  8016cd:	e8 2d f9 ff ff       	call   800fff <sys_getenvid>
  8016d2:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8016d4:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8016d9:	89 d8                	mov    %ebx,%eax
  8016db:	c1 e8 16             	shr    $0x16,%eax
  8016de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016e5:	a8 01                	test   $0x1,%al
  8016e7:	74 2c                	je     801715 <sfork+0xcb>
  8016e9:	89 d8                	mov    %ebx,%eax
  8016eb:	c1 e8 0c             	shr    $0xc,%eax
  8016ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016f5:	a8 01                	test   $0x1,%al
  8016f7:	74 1c                	je     801715 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8016f9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801700:	00 
  801701:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801705:	89 74 24 08          	mov    %esi,0x8(%esp)
  801709:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80170d:	89 3c 24             	mov    %edi,(%esp)
  801710:	e8 7c f9 ff ff       	call   801091 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801715:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80171b:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801721:	75 b6                	jne    8016d9 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  801723:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172b:	e8 78 fb ff ff       	call   8012a8 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801730:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801737:	00 
  801738:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80173f:	ee 
  801740:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801743:	89 04 24             	mov    %eax,(%esp)
  801746:	e8 f2 f8 ff ff       	call   80103d <sys_page_alloc>
  80174b:	85 c0                	test   %eax,%eax
  80174d:	79 1c                	jns    80176b <sfork+0x121>
  80174f:	c7 44 24 08 62 34 80 	movl   $0x803462,0x8(%esp)
  801756:	00 
  801757:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  80175e:	00 
  80175f:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  801766:	e8 3d ee ff ff       	call   8005a8 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  80176b:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801771:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801778:	c1 e7 07             	shl    $0x7,%edi
  80177b:	29 d7                	sub    %edx,%edi
  80177d:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  801783:	89 44 24 04          	mov    %eax,0x4(%esp)
  801787:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80178a:	89 04 24             	mov    %eax,(%esp)
  80178d:	e8 4b fa ff ff       	call   8011dd <sys_env_set_pgfault_upcall>
  801792:	85 c0                	test   %eax,%eax
  801794:	79 1c                	jns    8017b2 <sfork+0x168>
  801796:	c7 44 24 08 62 34 80 	movl   $0x803462,0x8(%esp)
  80179d:	00 
  80179e:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  8017a5:	00 
  8017a6:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  8017ad:	e8 f6 ed ff ff       	call   8005a8 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  8017b2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8017b9:	00 
  8017ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017bd:	89 04 24             	mov    %eax,(%esp)
  8017c0:	e8 72 f9 ff ff       	call   801137 <sys_env_set_status>
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	79 1c                	jns    8017e5 <sfork+0x19b>
  8017c9:	c7 44 24 08 62 34 80 	movl   $0x803462,0x8(%esp)
  8017d0:	00 
  8017d1:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8017d8:	00 
  8017d9:	c7 04 24 3b 34 80 00 	movl   $0x80343b,(%esp)
  8017e0:	e8 c3 ed ff ff       	call   8005a8 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8017e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017e8:	83 c4 3c             	add    $0x3c,%esp
  8017eb:	5b                   	pop    %ebx
  8017ec:	5e                   	pop    %esi
  8017ed:	5f                   	pop    %edi
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    

008017f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8017fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	89 04 24             	mov    %eax,(%esp)
  80180c:	e8 df ff ff ff       	call   8017f0 <fd2num>
  801811:	05 20 00 0d 00       	add    $0xd0020,%eax
  801816:	c1 e0 0c             	shl    $0xc,%eax
}
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	53                   	push   %ebx
  80181f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801822:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801827:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801829:	89 c2                	mov    %eax,%edx
  80182b:	c1 ea 16             	shr    $0x16,%edx
  80182e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801835:	f6 c2 01             	test   $0x1,%dl
  801838:	74 11                	je     80184b <fd_alloc+0x30>
  80183a:	89 c2                	mov    %eax,%edx
  80183c:	c1 ea 0c             	shr    $0xc,%edx
  80183f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801846:	f6 c2 01             	test   $0x1,%dl
  801849:	75 09                	jne    801854 <fd_alloc+0x39>
			*fd_store = fd;
  80184b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80184d:	b8 00 00 00 00       	mov    $0x0,%eax
  801852:	eb 17                	jmp    80186b <fd_alloc+0x50>
  801854:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801859:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80185e:	75 c7                	jne    801827 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801860:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801866:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80186b:	5b                   	pop    %ebx
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801874:	83 f8 1f             	cmp    $0x1f,%eax
  801877:	77 36                	ja     8018af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801879:	05 00 00 0d 00       	add    $0xd0000,%eax
  80187e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801881:	89 c2                	mov    %eax,%edx
  801883:	c1 ea 16             	shr    $0x16,%edx
  801886:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80188d:	f6 c2 01             	test   $0x1,%dl
  801890:	74 24                	je     8018b6 <fd_lookup+0x48>
  801892:	89 c2                	mov    %eax,%edx
  801894:	c1 ea 0c             	shr    $0xc,%edx
  801897:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80189e:	f6 c2 01             	test   $0x1,%dl
  8018a1:	74 1a                	je     8018bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8018a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ad:	eb 13                	jmp    8018c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018b4:	eb 0c                	jmp    8018c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8018b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018bb:	eb 05                	jmp    8018c2 <fd_lookup+0x54>
  8018bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8018c2:	5d                   	pop    %ebp
  8018c3:	c3                   	ret    

008018c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	53                   	push   %ebx
  8018c8:	83 ec 14             	sub    $0x14,%esp
  8018cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d6:	eb 0e                	jmp    8018e6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8018d8:	39 08                	cmp    %ecx,(%eax)
  8018da:	75 09                	jne    8018e5 <dev_lookup+0x21>
			*dev = devtab[i];
  8018dc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8018de:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e3:	eb 35                	jmp    80191a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8018e5:	42                   	inc    %edx
  8018e6:	8b 04 95 f0 34 80 00 	mov    0x8034f0(,%edx,4),%eax
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	75 e7                	jne    8018d8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8018f1:	a1 04 50 80 00       	mov    0x805004,%eax
  8018f6:	8b 00                	mov    (%eax),%eax
  8018f8:	8b 40 48             	mov    0x48(%eax),%eax
  8018fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801903:	c7 04 24 74 34 80 00 	movl   $0x803474,(%esp)
  80190a:	e8 91 ed ff ff       	call   8006a0 <cprintf>
	*dev = 0;
  80190f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801915:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80191a:	83 c4 14             	add    $0x14,%esp
  80191d:	5b                   	pop    %ebx
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	83 ec 30             	sub    $0x30,%esp
  801928:	8b 75 08             	mov    0x8(%ebp),%esi
  80192b:	8a 45 0c             	mov    0xc(%ebp),%al
  80192e:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801931:	89 34 24             	mov    %esi,(%esp)
  801934:	e8 b7 fe ff ff       	call   8017f0 <fd2num>
  801939:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80193c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801940:	89 04 24             	mov    %eax,(%esp)
  801943:	e8 26 ff ff ff       	call   80186e <fd_lookup>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 05                	js     801953 <fd_close+0x33>
	    || fd != fd2)
  80194e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801951:	74 0d                	je     801960 <fd_close+0x40>
		return (must_exist ? r : 0);
  801953:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801957:	75 46                	jne    80199f <fd_close+0x7f>
  801959:	bb 00 00 00 00       	mov    $0x0,%ebx
  80195e:	eb 3f                	jmp    80199f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801960:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801963:	89 44 24 04          	mov    %eax,0x4(%esp)
  801967:	8b 06                	mov    (%esi),%eax
  801969:	89 04 24             	mov    %eax,(%esp)
  80196c:	e8 53 ff ff ff       	call   8018c4 <dev_lookup>
  801971:	89 c3                	mov    %eax,%ebx
  801973:	85 c0                	test   %eax,%eax
  801975:	78 18                	js     80198f <fd_close+0x6f>
		if (dev->dev_close)
  801977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197a:	8b 40 10             	mov    0x10(%eax),%eax
  80197d:	85 c0                	test   %eax,%eax
  80197f:	74 09                	je     80198a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801981:	89 34 24             	mov    %esi,(%esp)
  801984:	ff d0                	call   *%eax
  801986:	89 c3                	mov    %eax,%ebx
  801988:	eb 05                	jmp    80198f <fd_close+0x6f>
		else
			r = 0;
  80198a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80198f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801993:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199a:	e8 45 f7 ff ff       	call   8010e4 <sys_page_unmap>
	return r;
}
  80199f:	89 d8                	mov    %ebx,%eax
  8019a1:	83 c4 30             	add    $0x30,%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5e                   	pop    %esi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	89 04 24             	mov    %eax,(%esp)
  8019bb:	e8 ae fe ff ff       	call   80186e <fd_lookup>
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	78 13                	js     8019d7 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019c4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019cb:	00 
  8019cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cf:	89 04 24             	mov    %eax,(%esp)
  8019d2:	e8 49 ff ff ff       	call   801920 <fd_close>
}
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <close_all>:

void
close_all(void)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	53                   	push   %ebx
  8019dd:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8019e0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8019e5:	89 1c 24             	mov    %ebx,(%esp)
  8019e8:	e8 bb ff ff ff       	call   8019a8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8019ed:	43                   	inc    %ebx
  8019ee:	83 fb 20             	cmp    $0x20,%ebx
  8019f1:	75 f2                	jne    8019e5 <close_all+0xc>
		close(i);
}
  8019f3:	83 c4 14             	add    $0x14,%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	57                   	push   %edi
  8019fd:	56                   	push   %esi
  8019fe:	53                   	push   %ebx
  8019ff:	83 ec 4c             	sub    $0x4c,%esp
  801a02:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a05:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0f:	89 04 24             	mov    %eax,(%esp)
  801a12:	e8 57 fe ff ff       	call   80186e <fd_lookup>
  801a17:	89 c3                	mov    %eax,%ebx
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	0f 88 e1 00 00 00    	js     801b02 <dup+0x109>
		return r;
	close(newfdnum);
  801a21:	89 3c 24             	mov    %edi,(%esp)
  801a24:	e8 7f ff ff ff       	call   8019a8 <close>

	newfd = INDEX2FD(newfdnum);
  801a29:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a2f:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a35:	89 04 24             	mov    %eax,(%esp)
  801a38:	e8 c3 fd ff ff       	call   801800 <fd2data>
  801a3d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a3f:	89 34 24             	mov    %esi,(%esp)
  801a42:	e8 b9 fd ff ff       	call   801800 <fd2data>
  801a47:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801a4a:	89 d8                	mov    %ebx,%eax
  801a4c:	c1 e8 16             	shr    $0x16,%eax
  801a4f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a56:	a8 01                	test   $0x1,%al
  801a58:	74 46                	je     801aa0 <dup+0xa7>
  801a5a:	89 d8                	mov    %ebx,%eax
  801a5c:	c1 e8 0c             	shr    $0xc,%eax
  801a5f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a66:	f6 c2 01             	test   $0x1,%dl
  801a69:	74 35                	je     801aa0 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a6b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a72:	25 07 0e 00 00       	and    $0xe07,%eax
  801a77:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a7b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a89:	00 
  801a8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a95:	e8 f7 f5 ff ff       	call   801091 <sys_page_map>
  801a9a:	89 c3                	mov    %eax,%ebx
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	78 3b                	js     801adb <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801aa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa3:	89 c2                	mov    %eax,%edx
  801aa5:	c1 ea 0c             	shr    $0xc,%edx
  801aa8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801aaf:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801ab5:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ab9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801abd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ac4:	00 
  801ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad0:	e8 bc f5 ff ff       	call   801091 <sys_page_map>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	79 25                	jns    801b00 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801adb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801adf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae6:	e8 f9 f5 ff ff       	call   8010e4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801aeb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801aee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af9:	e8 e6 f5 ff ff       	call   8010e4 <sys_page_unmap>
	return r;
  801afe:	eb 02                	jmp    801b02 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801b00:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801b02:	89 d8                	mov    %ebx,%eax
  801b04:	83 c4 4c             	add    $0x4c,%esp
  801b07:	5b                   	pop    %ebx
  801b08:	5e                   	pop    %esi
  801b09:	5f                   	pop    %edi
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	53                   	push   %ebx
  801b10:	83 ec 24             	sub    $0x24,%esp
  801b13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b16:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1d:	89 1c 24             	mov    %ebx,(%esp)
  801b20:	e8 49 fd ff ff       	call   80186e <fd_lookup>
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 6f                	js     801b98 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b33:	8b 00                	mov    (%eax),%eax
  801b35:	89 04 24             	mov    %eax,(%esp)
  801b38:	e8 87 fd ff ff       	call   8018c4 <dev_lookup>
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	78 57                	js     801b98 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b44:	8b 50 08             	mov    0x8(%eax),%edx
  801b47:	83 e2 03             	and    $0x3,%edx
  801b4a:	83 fa 01             	cmp    $0x1,%edx
  801b4d:	75 25                	jne    801b74 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801b4f:	a1 04 50 80 00       	mov    0x805004,%eax
  801b54:	8b 00                	mov    (%eax),%eax
  801b56:	8b 40 48             	mov    0x48(%eax),%eax
  801b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b61:	c7 04 24 b5 34 80 00 	movl   $0x8034b5,(%esp)
  801b68:	e8 33 eb ff ff       	call   8006a0 <cprintf>
		return -E_INVAL;
  801b6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b72:	eb 24                	jmp    801b98 <read+0x8c>
	}
	if (!dev->dev_read)
  801b74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b77:	8b 52 08             	mov    0x8(%edx),%edx
  801b7a:	85 d2                	test   %edx,%edx
  801b7c:	74 15                	je     801b93 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801b7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b81:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b88:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b8c:	89 04 24             	mov    %eax,(%esp)
  801b8f:	ff d2                	call   *%edx
  801b91:	eb 05                	jmp    801b98 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801b93:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801b98:	83 c4 24             	add    $0x24,%esp
  801b9b:	5b                   	pop    %ebx
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    

00801b9e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801baa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bb2:	eb 23                	jmp    801bd7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801bb4:	89 f0                	mov    %esi,%eax
  801bb6:	29 d8                	sub    %ebx,%eax
  801bb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbf:	01 d8                	add    %ebx,%eax
  801bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc5:	89 3c 24             	mov    %edi,(%esp)
  801bc8:	e8 3f ff ff ff       	call   801b0c <read>
		if (m < 0)
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	78 10                	js     801be1 <readn+0x43>
			return m;
		if (m == 0)
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	74 0a                	je     801bdf <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801bd5:	01 c3                	add    %eax,%ebx
  801bd7:	39 f3                	cmp    %esi,%ebx
  801bd9:	72 d9                	jb     801bb4 <readn+0x16>
  801bdb:	89 d8                	mov    %ebx,%eax
  801bdd:	eb 02                	jmp    801be1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801bdf:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801be1:	83 c4 1c             	add    $0x1c,%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	53                   	push   %ebx
  801bed:	83 ec 24             	sub    $0x24,%esp
  801bf0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bf3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfa:	89 1c 24             	mov    %ebx,(%esp)
  801bfd:	e8 6c fc ff ff       	call   80186e <fd_lookup>
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 6a                	js     801c70 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c10:	8b 00                	mov    (%eax),%eax
  801c12:	89 04 24             	mov    %eax,(%esp)
  801c15:	e8 aa fc ff ff       	call   8018c4 <dev_lookup>
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	78 52                	js     801c70 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c21:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c25:	75 25                	jne    801c4c <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801c27:	a1 04 50 80 00       	mov    0x805004,%eax
  801c2c:	8b 00                	mov    (%eax),%eax
  801c2e:	8b 40 48             	mov    0x48(%eax),%eax
  801c31:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c39:	c7 04 24 d1 34 80 00 	movl   $0x8034d1,(%esp)
  801c40:	e8 5b ea ff ff       	call   8006a0 <cprintf>
		return -E_INVAL;
  801c45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c4a:	eb 24                	jmp    801c70 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801c4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c4f:	8b 52 0c             	mov    0xc(%edx),%edx
  801c52:	85 d2                	test   %edx,%edx
  801c54:	74 15                	je     801c6b <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c56:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c60:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c64:	89 04 24             	mov    %eax,(%esp)
  801c67:	ff d2                	call   *%edx
  801c69:	eb 05                	jmp    801c70 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801c6b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801c70:	83 c4 24             	add    $0x24,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    

00801c76 <seek>:

int
seek(int fdnum, off_t offset)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c7c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c83:	8b 45 08             	mov    0x8(%ebp),%eax
  801c86:	89 04 24             	mov    %eax,(%esp)
  801c89:	e8 e0 fb ff ff       	call   80186e <fd_lookup>
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 0e                	js     801ca0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801c92:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c98:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 24             	sub    $0x24,%esp
  801ca9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801cac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801caf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb3:	89 1c 24             	mov    %ebx,(%esp)
  801cb6:	e8 b3 fb ff ff       	call   80186e <fd_lookup>
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 63                	js     801d22 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cbf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc9:	8b 00                	mov    (%eax),%eax
  801ccb:	89 04 24             	mov    %eax,(%esp)
  801cce:	e8 f1 fb ff ff       	call   8018c4 <dev_lookup>
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 4b                	js     801d22 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cda:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801cde:	75 25                	jne    801d05 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ce0:	a1 04 50 80 00       	mov    0x805004,%eax
  801ce5:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801ce7:	8b 40 48             	mov    0x48(%eax),%eax
  801cea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf2:	c7 04 24 94 34 80 00 	movl   $0x803494,(%esp)
  801cf9:	e8 a2 e9 ff ff       	call   8006a0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801cfe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d03:	eb 1d                	jmp    801d22 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801d05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d08:	8b 52 18             	mov    0x18(%edx),%edx
  801d0b:	85 d2                	test   %edx,%edx
  801d0d:	74 0e                	je     801d1d <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d16:	89 04 24             	mov    %eax,(%esp)
  801d19:	ff d2                	call   *%edx
  801d1b:	eb 05                	jmp    801d22 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801d1d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801d22:	83 c4 24             	add    $0x24,%esp
  801d25:	5b                   	pop    %ebx
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	53                   	push   %ebx
  801d2c:	83 ec 24             	sub    $0x24,%esp
  801d2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 2a fb ff ff       	call   80186e <fd_lookup>
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 52                	js     801d9a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d52:	8b 00                	mov    (%eax),%eax
  801d54:	89 04 24             	mov    %eax,(%esp)
  801d57:	e8 68 fb ff ff       	call   8018c4 <dev_lookup>
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	78 3a                	js     801d9a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d63:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801d67:	74 2c                	je     801d95 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d69:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d6c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d73:	00 00 00 
	stat->st_isdir = 0;
  801d76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d7d:	00 00 00 
	stat->st_dev = dev;
  801d80:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d8d:	89 14 24             	mov    %edx,(%esp)
  801d90:	ff 50 14             	call   *0x14(%eax)
  801d93:	eb 05                	jmp    801d9a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d95:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d9a:	83 c4 24             	add    $0x24,%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5d                   	pop    %ebp
  801d9f:	c3                   	ret    

00801da0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	56                   	push   %esi
  801da4:	53                   	push   %ebx
  801da5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801da8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801daf:	00 
  801db0:	8b 45 08             	mov    0x8(%ebp),%eax
  801db3:	89 04 24             	mov    %eax,(%esp)
  801db6:	e8 88 02 00 00       	call   802043 <open>
  801dbb:	89 c3                	mov    %eax,%ebx
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	78 1b                	js     801ddc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc8:	89 1c 24             	mov    %ebx,(%esp)
  801dcb:	e8 58 ff ff ff       	call   801d28 <fstat>
  801dd0:	89 c6                	mov    %eax,%esi
	close(fd);
  801dd2:	89 1c 24             	mov    %ebx,(%esp)
  801dd5:	e8 ce fb ff ff       	call   8019a8 <close>
	return r;
  801dda:	89 f3                	mov    %esi,%ebx
}
  801ddc:	89 d8                	mov    %ebx,%eax
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
  801de5:	00 00                	add    %al,(%eax)
	...

00801de8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	56                   	push   %esi
  801dec:	53                   	push   %ebx
  801ded:	83 ec 10             	sub    $0x10,%esp
  801df0:	89 c3                	mov    %eax,%ebx
  801df2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801df4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801dfb:	75 11                	jne    801e0e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801dfd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801e04:	e8 8a 0e 00 00       	call   802c93 <ipc_find_env>
  801e09:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801e0e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e15:	00 
  801e16:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801e1d:	00 
  801e1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e22:	a1 00 50 80 00       	mov    0x805000,%eax
  801e27:	89 04 24             	mov    %eax,(%esp)
  801e2a:	e8 fe 0d 00 00       	call   802c2d <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801e2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e36:	00 
  801e37:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e42:	e8 79 0d 00 00       	call   802bc0 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801e47:	83 c4 10             	add    $0x10,%esp
  801e4a:	5b                   	pop    %ebx
  801e4b:	5e                   	pop    %esi
  801e4c:	5d                   	pop    %ebp
  801e4d:	c3                   	ret    

00801e4e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801e54:	8b 45 08             	mov    0x8(%ebp),%eax
  801e57:	8b 40 0c             	mov    0xc(%eax),%eax
  801e5a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e62:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801e67:	ba 00 00 00 00       	mov    $0x0,%edx
  801e6c:	b8 02 00 00 00       	mov    $0x2,%eax
  801e71:	e8 72 ff ff ff       	call   801de8 <fsipc>
}
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    

00801e78 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e81:	8b 40 0c             	mov    0xc(%eax),%eax
  801e84:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801e89:	ba 00 00 00 00       	mov    $0x0,%edx
  801e8e:	b8 06 00 00 00       	mov    $0x6,%eax
  801e93:	e8 50 ff ff ff       	call   801de8 <fsipc>
}
  801e98:	c9                   	leave  
  801e99:	c3                   	ret    

00801e9a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	53                   	push   %ebx
  801e9e:	83 ec 14             	sub    $0x14,%esp
  801ea1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea7:	8b 40 0c             	mov    0xc(%eax),%eax
  801eaa:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801eaf:	ba 00 00 00 00       	mov    $0x0,%edx
  801eb4:	b8 05 00 00 00       	mov    $0x5,%eax
  801eb9:	e8 2a ff ff ff       	call   801de8 <fsipc>
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 2b                	js     801eed <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ec2:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ec9:	00 
  801eca:	89 1c 24             	mov    %ebx,(%esp)
  801ecd:	e8 79 ed ff ff       	call   800c4b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ed2:	a1 80 60 80 00       	mov    0x806080,%eax
  801ed7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801edd:	a1 84 60 80 00       	mov    0x806084,%eax
  801ee2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ee8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eed:	83 c4 14             	add    $0x14,%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    

00801ef3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	53                   	push   %ebx
  801ef7:	83 ec 14             	sub    $0x14,%esp
  801efa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801efd:	8b 45 08             	mov    0x8(%ebp),%eax
  801f00:	8b 40 0c             	mov    0xc(%eax),%eax
  801f03:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801f08:	89 d8                	mov    %ebx,%eax
  801f0a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801f10:	76 05                	jbe    801f17 <devfile_write+0x24>
  801f12:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801f17:	a3 04 60 80 00       	mov    %eax,0x806004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801f1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f27:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801f2e:	e8 fb ee ff ff       	call   800e2e <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801f33:	ba 00 00 00 00       	mov    $0x0,%edx
  801f38:	b8 04 00 00 00       	mov    $0x4,%eax
  801f3d:	e8 a6 fe ff ff       	call   801de8 <fsipc>
  801f42:	85 c0                	test   %eax,%eax
  801f44:	78 53                	js     801f99 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801f46:	39 c3                	cmp    %eax,%ebx
  801f48:	73 24                	jae    801f6e <devfile_write+0x7b>
  801f4a:	c7 44 24 0c 00 35 80 	movl   $0x803500,0xc(%esp)
  801f51:	00 
  801f52:	c7 44 24 08 07 35 80 	movl   $0x803507,0x8(%esp)
  801f59:	00 
  801f5a:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801f61:	00 
  801f62:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  801f69:	e8 3a e6 ff ff       	call   8005a8 <_panic>
	assert(r <= PGSIZE);
  801f6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f73:	7e 24                	jle    801f99 <devfile_write+0xa6>
  801f75:	c7 44 24 0c 27 35 80 	movl   $0x803527,0xc(%esp)
  801f7c:	00 
  801f7d:	c7 44 24 08 07 35 80 	movl   $0x803507,0x8(%esp)
  801f84:	00 
  801f85:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801f8c:	00 
  801f8d:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  801f94:	e8 0f e6 ff ff       	call   8005a8 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801f99:	83 c4 14             	add    $0x14,%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 10             	sub    $0x10,%esp
  801fa7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801faa:	8b 45 08             	mov    0x8(%ebp),%eax
  801fad:	8b 40 0c             	mov    0xc(%eax),%eax
  801fb0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801fb5:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801fbb:	ba 00 00 00 00       	mov    $0x0,%edx
  801fc0:	b8 03 00 00 00       	mov    $0x3,%eax
  801fc5:	e8 1e fe ff ff       	call   801de8 <fsipc>
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	78 6a                	js     80203a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801fd0:	39 c6                	cmp    %eax,%esi
  801fd2:	73 24                	jae    801ff8 <devfile_read+0x59>
  801fd4:	c7 44 24 0c 00 35 80 	movl   $0x803500,0xc(%esp)
  801fdb:	00 
  801fdc:	c7 44 24 08 07 35 80 	movl   $0x803507,0x8(%esp)
  801fe3:	00 
  801fe4:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801feb:	00 
  801fec:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  801ff3:	e8 b0 e5 ff ff       	call   8005a8 <_panic>
	assert(r <= PGSIZE);
  801ff8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ffd:	7e 24                	jle    802023 <devfile_read+0x84>
  801fff:	c7 44 24 0c 27 35 80 	movl   $0x803527,0xc(%esp)
  802006:	00 
  802007:	c7 44 24 08 07 35 80 	movl   $0x803507,0x8(%esp)
  80200e:	00 
  80200f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  802016:	00 
  802017:	c7 04 24 1c 35 80 00 	movl   $0x80351c,(%esp)
  80201e:	e8 85 e5 ff ff       	call   8005a8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802023:	89 44 24 08          	mov    %eax,0x8(%esp)
  802027:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80202e:	00 
  80202f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802032:	89 04 24             	mov    %eax,(%esp)
  802035:	e8 8a ed ff ff       	call   800dc4 <memmove>
	return r;
}
  80203a:	89 d8                	mov    %ebx,%eax
  80203c:	83 c4 10             	add    $0x10,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5d                   	pop    %ebp
  802042:	c3                   	ret    

00802043 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802043:	55                   	push   %ebp
  802044:	89 e5                	mov    %esp,%ebp
  802046:	56                   	push   %esi
  802047:	53                   	push   %ebx
  802048:	83 ec 20             	sub    $0x20,%esp
  80204b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80204e:	89 34 24             	mov    %esi,(%esp)
  802051:	e8 c2 eb ff ff       	call   800c18 <strlen>
  802056:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80205b:	7f 60                	jg     8020bd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80205d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802060:	89 04 24             	mov    %eax,(%esp)
  802063:	e8 b3 f7 ff ff       	call   80181b <fd_alloc>
  802068:	89 c3                	mov    %eax,%ebx
  80206a:	85 c0                	test   %eax,%eax
  80206c:	78 54                	js     8020c2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80206e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802072:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802079:	e8 cd eb ff ff       	call   800c4b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80207e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802081:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802086:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802089:	b8 01 00 00 00       	mov    $0x1,%eax
  80208e:	e8 55 fd ff ff       	call   801de8 <fsipc>
  802093:	89 c3                	mov    %eax,%ebx
  802095:	85 c0                	test   %eax,%eax
  802097:	79 15                	jns    8020ae <open+0x6b>
		fd_close(fd, 0);
  802099:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020a0:	00 
  8020a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a4:	89 04 24             	mov    %eax,(%esp)
  8020a7:	e8 74 f8 ff ff       	call   801920 <fd_close>
		return r;
  8020ac:	eb 14                	jmp    8020c2 <open+0x7f>
	}

	return fd2num(fd);
  8020ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 37 f7 ff ff       	call   8017f0 <fd2num>
  8020b9:	89 c3                	mov    %eax,%ebx
  8020bb:	eb 05                	jmp    8020c2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8020bd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8020c2:	89 d8                	mov    %ebx,%eax
  8020c4:	83 c4 20             	add    $0x20,%esp
  8020c7:	5b                   	pop    %ebx
  8020c8:	5e                   	pop    %esi
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8020d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8020d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8020db:	e8 08 fd ff ff       	call   801de8 <fsipc>
}
  8020e0:	c9                   	leave  
  8020e1:	c3                   	ret    
	...

008020e4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	57                   	push   %edi
  8020e8:	56                   	push   %esi
  8020e9:	53                   	push   %ebx
  8020ea:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8020f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020f7:	00 
  8020f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020fb:	89 04 24             	mov    %eax,(%esp)
  8020fe:	e8 40 ff ff ff       	call   802043 <open>
  802103:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802109:	85 c0                	test   %eax,%eax
  80210b:	0f 88 77 05 00 00    	js     802688 <spawn+0x5a4>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802111:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802118:	00 
  802119:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80211f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802123:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802129:	89 04 24             	mov    %eax,(%esp)
  80212c:	e8 6d fa ff ff       	call   801b9e <readn>
  802131:	3d 00 02 00 00       	cmp    $0x200,%eax
  802136:	75 0c                	jne    802144 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  802138:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80213f:	45 4c 46 
  802142:	74 3b                	je     80217f <spawn+0x9b>
		close(fd);
  802144:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80214a:	89 04 24             	mov    %eax,(%esp)
  80214d:	e8 56 f8 ff ff       	call   8019a8 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802152:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802159:	46 
  80215a:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  802160:	89 44 24 04          	mov    %eax,0x4(%esp)
  802164:	c7 04 24 33 35 80 00 	movl   $0x803533,(%esp)
  80216b:	e8 30 e5 ff ff       	call   8006a0 <cprintf>
		return -E_NOT_EXEC;
  802170:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  802177:	ff ff ff 
  80217a:	e9 15 05 00 00       	jmp    802694 <spawn+0x5b0>
  80217f:	ba 07 00 00 00       	mov    $0x7,%edx
  802184:	89 d0                	mov    %edx,%eax
  802186:	cd 30                	int    $0x30
  802188:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80218e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802194:	85 c0                	test   %eax,%eax
  802196:	0f 88 f8 04 00 00    	js     802694 <spawn+0x5b0>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80219c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8021a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8021a8:	c1 e0 07             	shl    $0x7,%eax
  8021ab:	29 d0                	sub    %edx,%eax
  8021ad:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  8021b3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8021b9:	b9 11 00 00 00       	mov    $0x11,%ecx
  8021be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8021c0:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8021c6:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8021cc:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8021d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021d9:	eb 0d                	jmp    8021e8 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8021db:	89 04 24             	mov    %eax,(%esp)
  8021de:	e8 35 ea ff ff       	call   800c18 <strlen>
  8021e3:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8021e7:	46                   	inc    %esi
  8021e8:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8021ea:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8021f1:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8021f4:	85 c0                	test   %eax,%eax
  8021f6:	75 e3                	jne    8021db <spawn+0xf7>
  8021f8:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  8021fe:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802204:	bf 00 10 40 00       	mov    $0x401000,%edi
  802209:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80220b:	89 f8                	mov    %edi,%eax
  80220d:	83 e0 fc             	and    $0xfffffffc,%eax
  802210:	f7 d2                	not    %edx
  802212:	8d 14 90             	lea    (%eax,%edx,4),%edx
  802215:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	83 e8 08             	sub    $0x8,%eax
  802220:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802225:	0f 86 7a 04 00 00    	jbe    8026a5 <spawn+0x5c1>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80222b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802232:	00 
  802233:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80223a:	00 
  80223b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802242:	e8 f6 ed ff ff       	call   80103d <sys_page_alloc>
  802247:	85 c0                	test   %eax,%eax
  802249:	0f 88 5b 04 00 00    	js     8026aa <spawn+0x5c6>
  80224f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802254:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  80225a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80225d:	eb 2e                	jmp    80228d <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80225f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802265:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80226b:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80226e:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802271:	89 44 24 04          	mov    %eax,0x4(%esp)
  802275:	89 3c 24             	mov    %edi,(%esp)
  802278:	e8 ce e9 ff ff       	call   800c4b <strcpy>
		string_store += strlen(argv[i]) + 1;
  80227d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802280:	89 04 24             	mov    %eax,(%esp)
  802283:	e8 90 e9 ff ff       	call   800c18 <strlen>
  802288:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80228c:	43                   	inc    %ebx
  80228d:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802293:	7c ca                	jl     80225f <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802295:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80229b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8022a1:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8022a8:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8022ae:	74 24                	je     8022d4 <spawn+0x1f0>
  8022b0:	c7 44 24 0c a8 35 80 	movl   $0x8035a8,0xc(%esp)
  8022b7:	00 
  8022b8:	c7 44 24 08 07 35 80 	movl   $0x803507,0x8(%esp)
  8022bf:	00 
  8022c0:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  8022c7:	00 
  8022c8:	c7 04 24 4d 35 80 00 	movl   $0x80354d,(%esp)
  8022cf:	e8 d4 e2 ff ff       	call   8005a8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8022d4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8022da:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8022df:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8022e5:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8022e8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8022ee:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8022f1:	89 d0                	mov    %edx,%eax
  8022f3:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8022f8:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8022fe:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  802305:	00 
  802306:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  80230d:	ee 
  80230e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802314:	89 44 24 08          	mov    %eax,0x8(%esp)
  802318:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80231f:	00 
  802320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802327:	e8 65 ed ff ff       	call   801091 <sys_page_map>
  80232c:	89 c3                	mov    %eax,%ebx
  80232e:	85 c0                	test   %eax,%eax
  802330:	78 1a                	js     80234c <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802332:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802339:	00 
  80233a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802341:	e8 9e ed ff ff       	call   8010e4 <sys_page_unmap>
  802346:	89 c3                	mov    %eax,%ebx
  802348:	85 c0                	test   %eax,%eax
  80234a:	79 1f                	jns    80236b <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  80234c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802353:	00 
  802354:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235b:	e8 84 ed ff ff       	call   8010e4 <sys_page_unmap>
	return r;
  802360:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  802366:	e9 29 03 00 00       	jmp    802694 <spawn+0x5b0>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80236b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  802371:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  802377:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80237d:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  802384:	00 00 00 
  802387:	e9 bb 01 00 00       	jmp    802547 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  80238c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802392:	83 38 01             	cmpl   $0x1,(%eax)
  802395:	0f 85 9f 01 00 00    	jne    80253a <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80239b:	89 c2                	mov    %eax,%edx
  80239d:	8b 40 18             	mov    0x18(%eax),%eax
  8023a0:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8023a3:	83 f8 01             	cmp    $0x1,%eax
  8023a6:	19 c0                	sbb    %eax,%eax
  8023a8:	83 e0 fe             	and    $0xfffffffe,%eax
  8023ab:	83 c0 07             	add    $0x7,%eax
  8023ae:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8023b4:	8b 52 04             	mov    0x4(%edx),%edx
  8023b7:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  8023bd:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8023c3:	8b 40 10             	mov    0x10(%eax),%eax
  8023c6:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8023cc:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8023d2:	8b 52 14             	mov    0x14(%edx),%edx
  8023d5:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8023db:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8023e1:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8023e4:	89 f8                	mov    %edi,%eax
  8023e6:	25 ff 0f 00 00       	and    $0xfff,%eax
  8023eb:	74 16                	je     802403 <spawn+0x31f>
		va -= i;
  8023ed:	29 c7                	sub    %eax,%edi
		memsz += i;
  8023ef:	01 c2                	add    %eax,%edx
  8023f1:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  8023f7:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8023fd:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802403:	bb 00 00 00 00       	mov    $0x0,%ebx
  802408:	e9 1f 01 00 00       	jmp    80252c <spawn+0x448>
		if (i >= filesz) {
  80240d:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  802413:	72 2b                	jb     802440 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802415:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  80241b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80241f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802423:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802429:	89 04 24             	mov    %eax,(%esp)
  80242c:	e8 0c ec ff ff       	call   80103d <sys_page_alloc>
  802431:	85 c0                	test   %eax,%eax
  802433:	0f 89 e7 00 00 00    	jns    802520 <spawn+0x43c>
  802439:	89 c6                	mov    %eax,%esi
  80243b:	e9 24 02 00 00       	jmp    802664 <spawn+0x580>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802440:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802447:	00 
  802448:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80244f:	00 
  802450:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802457:	e8 e1 eb ff ff       	call   80103d <sys_page_alloc>
  80245c:	85 c0                	test   %eax,%eax
  80245e:	0f 88 f6 01 00 00    	js     80265a <spawn+0x576>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802464:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  80246a:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80246c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802470:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802476:	89 04 24             	mov    %eax,(%esp)
  802479:	e8 f8 f7 ff ff       	call   801c76 <seek>
  80247e:	85 c0                	test   %eax,%eax
  802480:	0f 88 d8 01 00 00    	js     80265e <spawn+0x57a>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802486:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80248c:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80248e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802493:	76 05                	jbe    80249a <spawn+0x3b6>
  802495:	b8 00 10 00 00       	mov    $0x1000,%eax
  80249a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80249e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8024a5:	00 
  8024a6:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8024ac:	89 04 24             	mov    %eax,(%esp)
  8024af:	e8 ea f6 ff ff       	call   801b9e <readn>
  8024b4:	85 c0                	test   %eax,%eax
  8024b6:	0f 88 a6 01 00 00    	js     802662 <spawn+0x57e>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8024bc:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8024c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8024c6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024ca:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8024d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024d4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8024db:	00 
  8024dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024e3:	e8 a9 eb ff ff       	call   801091 <sys_page_map>
  8024e8:	85 c0                	test   %eax,%eax
  8024ea:	79 20                	jns    80250c <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  8024ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024f0:	c7 44 24 08 59 35 80 	movl   $0x803559,0x8(%esp)
  8024f7:	00 
  8024f8:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  8024ff:	00 
  802500:	c7 04 24 4d 35 80 00 	movl   $0x80354d,(%esp)
  802507:	e8 9c e0 ff ff       	call   8005a8 <_panic>
			sys_page_unmap(0, UTEMP);
  80250c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802513:	00 
  802514:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80251b:	e8 c4 eb ff ff       	call   8010e4 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802520:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802526:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80252c:	89 de                	mov    %ebx,%esi
  80252e:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  802534:	0f 82 d3 fe ff ff    	jb     80240d <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80253a:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802540:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802547:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80254e:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  802554:	0f 8c 32 fe ff ff    	jl     80238c <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80255a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802560:	89 04 24             	mov    %eax,(%esp)
  802563:	e8 40 f4 ff ff       	call   8019a8 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  802568:	be 00 00 00 00       	mov    $0x0,%esi
  80256d:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
		if ((uvpd[PDX(va)] & PTE_P)&&(uvpt[PGNUM(va)] & PTE_P)&&(uvpt[PGNUM(va)]&PTE_U)&&(uvpt[PGNUM(va)]&PTE_SHARE)){
  802573:	89 f0                	mov    %esi,%eax
  802575:	c1 e8 16             	shr    $0x16,%eax
  802578:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80257f:	a8 01                	test   $0x1,%al
  802581:	74 49                	je     8025cc <spawn+0x4e8>
  802583:	89 f0                	mov    %esi,%eax
  802585:	c1 e8 0c             	shr    $0xc,%eax
  802588:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80258f:	f6 c2 01             	test   $0x1,%dl
  802592:	74 38                	je     8025cc <spawn+0x4e8>
  802594:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80259b:	f6 c2 04             	test   $0x4,%dl
  80259e:	74 2c                	je     8025cc <spawn+0x4e8>
  8025a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8025a7:	f6 c4 04             	test   $0x4,%ah
  8025aa:	74 20                	je     8025cc <spawn+0x4e8>
			if ((r = sys_page_map(0,(void*)va,child,(void*)va,PTE_SYSCALL))<0);
  8025ac:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  8025b3:	00 
  8025b4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8025b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025c7:	e8 c5 ea ff ff       	call   801091 <sys_page_map>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	for (uintptr_t va = 0; va < UTOP; va+=PGSIZE){
  8025cc:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8025d2:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  8025d8:	75 99                	jne    802573 <spawn+0x48f>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8025da:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8025e1:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8025e4:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8025ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025ee:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8025f4:	89 04 24             	mov    %eax,(%esp)
  8025f7:	e8 8e eb ff ff       	call   80118a <sys_env_set_trapframe>
  8025fc:	85 c0                	test   %eax,%eax
  8025fe:	79 20                	jns    802620 <spawn+0x53c>
		panic("sys_env_set_trapframe: %e", r);
  802600:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802604:	c7 44 24 08 76 35 80 	movl   $0x803576,0x8(%esp)
  80260b:	00 
  80260c:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802613:	00 
  802614:	c7 04 24 4d 35 80 00 	movl   $0x80354d,(%esp)
  80261b:	e8 88 df ff ff       	call   8005a8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802620:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802627:	00 
  802628:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80262e:	89 04 24             	mov    %eax,(%esp)
  802631:	e8 01 eb ff ff       	call   801137 <sys_env_set_status>
  802636:	85 c0                	test   %eax,%eax
  802638:	79 5a                	jns    802694 <spawn+0x5b0>
		panic("sys_env_set_status: %e", r);
  80263a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263e:	c7 44 24 08 90 35 80 	movl   $0x803590,0x8(%esp)
  802645:	00 
  802646:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  80264d:	00 
  80264e:	c7 04 24 4d 35 80 00 	movl   $0x80354d,(%esp)
  802655:	e8 4e df ff ff       	call   8005a8 <_panic>
  80265a:	89 c6                	mov    %eax,%esi
  80265c:	eb 06                	jmp    802664 <spawn+0x580>
  80265e:	89 c6                	mov    %eax,%esi
  802660:	eb 02                	jmp    802664 <spawn+0x580>
  802662:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802664:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80266a:	89 04 24             	mov    %eax,(%esp)
  80266d:	e8 3b e9 ff ff       	call   800fad <sys_env_destroy>
	close(fd);
  802672:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802678:	89 04 24             	mov    %eax,(%esp)
  80267b:	e8 28 f3 ff ff       	call   8019a8 <close>
	return r;
  802680:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  802686:	eb 0c                	jmp    802694 <spawn+0x5b0>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802688:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80268e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802694:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80269a:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  8026a0:	5b                   	pop    %ebx
  8026a1:	5e                   	pop    %esi
  8026a2:	5f                   	pop    %edi
  8026a3:	5d                   	pop    %ebp
  8026a4:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8026a5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  8026aa:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  8026b0:	eb e2                	jmp    802694 <spawn+0x5b0>

008026b2 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8026b2:	55                   	push   %ebp
  8026b3:	89 e5                	mov    %esp,%ebp
  8026b5:	57                   	push   %edi
  8026b6:	56                   	push   %esi
  8026b7:	53                   	push   %ebx
  8026b8:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  8026bb:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8026be:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8026c3:	eb 03                	jmp    8026c8 <spawnl+0x16>
		argc++;
  8026c5:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8026c6:	89 d0                	mov    %edx,%eax
  8026c8:	8d 50 04             	lea    0x4(%eax),%edx
  8026cb:	83 38 00             	cmpl   $0x0,(%eax)
  8026ce:	75 f5                	jne    8026c5 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8026d0:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8026d7:	83 e0 f0             	and    $0xfffffff0,%eax
  8026da:	29 c4                	sub    %eax,%esp
  8026dc:	8d 7c 24 17          	lea    0x17(%esp),%edi
  8026e0:	83 e7 f0             	and    $0xfffffff0,%edi
  8026e3:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  8026e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026e8:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  8026ea:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  8026f1:	00 

	va_start(vl, arg0);
  8026f2:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8026f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8026fa:	eb 09                	jmp    802705 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  8026fc:	40                   	inc    %eax
  8026fd:	8b 1a                	mov    (%edx),%ebx
  8026ff:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802702:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802705:	39 c8                	cmp    %ecx,%eax
  802707:	75 f3                	jne    8026fc <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802709:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80270d:	8b 45 08             	mov    0x8(%ebp),%eax
  802710:	89 04 24             	mov    %eax,(%esp)
  802713:	e8 cc f9 ff ff       	call   8020e4 <spawn>
}
  802718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80271b:	5b                   	pop    %ebx
  80271c:	5e                   	pop    %esi
  80271d:	5f                   	pop    %edi
  80271e:	5d                   	pop    %ebp
  80271f:	c3                   	ret    

00802720 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802720:	55                   	push   %ebp
  802721:	89 e5                	mov    %esp,%ebp
  802723:	56                   	push   %esi
  802724:	53                   	push   %ebx
  802725:	83 ec 10             	sub    $0x10,%esp
  802728:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80272b:	8b 45 08             	mov    0x8(%ebp),%eax
  80272e:	89 04 24             	mov    %eax,(%esp)
  802731:	e8 ca f0 ff ff       	call   801800 <fd2data>
  802736:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802738:	c7 44 24 04 ce 35 80 	movl   $0x8035ce,0x4(%esp)
  80273f:	00 
  802740:	89 34 24             	mov    %esi,(%esp)
  802743:	e8 03 e5 ff ff       	call   800c4b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802748:	8b 43 04             	mov    0x4(%ebx),%eax
  80274b:	2b 03                	sub    (%ebx),%eax
  80274d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802753:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80275a:	00 00 00 
	stat->st_dev = &devpipe;
  80275d:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802764:	40 80 00 
	return 0;
}
  802767:	b8 00 00 00 00       	mov    $0x0,%eax
  80276c:	83 c4 10             	add    $0x10,%esp
  80276f:	5b                   	pop    %ebx
  802770:	5e                   	pop    %esi
  802771:	5d                   	pop    %ebp
  802772:	c3                   	ret    

00802773 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802773:	55                   	push   %ebp
  802774:	89 e5                	mov    %esp,%ebp
  802776:	53                   	push   %ebx
  802777:	83 ec 14             	sub    $0x14,%esp
  80277a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80277d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802781:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802788:	e8 57 e9 ff ff       	call   8010e4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80278d:	89 1c 24             	mov    %ebx,(%esp)
  802790:	e8 6b f0 ff ff       	call   801800 <fd2data>
  802795:	89 44 24 04          	mov    %eax,0x4(%esp)
  802799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027a0:	e8 3f e9 ff ff       	call   8010e4 <sys_page_unmap>
}
  8027a5:	83 c4 14             	add    $0x14,%esp
  8027a8:	5b                   	pop    %ebx
  8027a9:	5d                   	pop    %ebp
  8027aa:	c3                   	ret    

008027ab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8027ab:	55                   	push   %ebp
  8027ac:	89 e5                	mov    %esp,%ebp
  8027ae:	57                   	push   %edi
  8027af:	56                   	push   %esi
  8027b0:	53                   	push   %ebx
  8027b1:	83 ec 2c             	sub    $0x2c,%esp
  8027b4:	89 c7                	mov    %eax,%edi
  8027b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8027b9:	a1 04 50 80 00       	mov    0x805004,%eax
  8027be:	8b 00                	mov    (%eax),%eax
  8027c0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8027c3:	89 3c 24             	mov    %edi,(%esp)
  8027c6:	e8 0d 05 00 00       	call   802cd8 <pageref>
  8027cb:	89 c6                	mov    %eax,%esi
  8027cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8027d0:	89 04 24             	mov    %eax,(%esp)
  8027d3:	e8 00 05 00 00       	call   802cd8 <pageref>
  8027d8:	39 c6                	cmp    %eax,%esi
  8027da:	0f 94 c0             	sete   %al
  8027dd:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8027e0:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8027e6:	8b 12                	mov    (%edx),%edx
  8027e8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8027eb:	39 cb                	cmp    %ecx,%ebx
  8027ed:	75 08                	jne    8027f7 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8027ef:	83 c4 2c             	add    $0x2c,%esp
  8027f2:	5b                   	pop    %ebx
  8027f3:	5e                   	pop    %esi
  8027f4:	5f                   	pop    %edi
  8027f5:	5d                   	pop    %ebp
  8027f6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8027f7:	83 f8 01             	cmp    $0x1,%eax
  8027fa:	75 bd                	jne    8027b9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8027fc:	8b 42 58             	mov    0x58(%edx),%eax
  8027ff:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802806:	00 
  802807:	89 44 24 08          	mov    %eax,0x8(%esp)
  80280b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80280f:	c7 04 24 d5 35 80 00 	movl   $0x8035d5,(%esp)
  802816:	e8 85 de ff ff       	call   8006a0 <cprintf>
  80281b:	eb 9c                	jmp    8027b9 <_pipeisclosed+0xe>

0080281d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80281d:	55                   	push   %ebp
  80281e:	89 e5                	mov    %esp,%ebp
  802820:	57                   	push   %edi
  802821:	56                   	push   %esi
  802822:	53                   	push   %ebx
  802823:	83 ec 1c             	sub    $0x1c,%esp
  802826:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802829:	89 34 24             	mov    %esi,(%esp)
  80282c:	e8 cf ef ff ff       	call   801800 <fd2data>
  802831:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802833:	bf 00 00 00 00       	mov    $0x0,%edi
  802838:	eb 3c                	jmp    802876 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80283a:	89 da                	mov    %ebx,%edx
  80283c:	89 f0                	mov    %esi,%eax
  80283e:	e8 68 ff ff ff       	call   8027ab <_pipeisclosed>
  802843:	85 c0                	test   %eax,%eax
  802845:	75 38                	jne    80287f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802847:	e8 d2 e7 ff ff       	call   80101e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80284c:	8b 43 04             	mov    0x4(%ebx),%eax
  80284f:	8b 13                	mov    (%ebx),%edx
  802851:	83 c2 20             	add    $0x20,%edx
  802854:	39 d0                	cmp    %edx,%eax
  802856:	73 e2                	jae    80283a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802858:	8b 55 0c             	mov    0xc(%ebp),%edx
  80285b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80285e:	89 c2                	mov    %eax,%edx
  802860:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802866:	79 05                	jns    80286d <devpipe_write+0x50>
  802868:	4a                   	dec    %edx
  802869:	83 ca e0             	or     $0xffffffe0,%edx
  80286c:	42                   	inc    %edx
  80286d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802871:	40                   	inc    %eax
  802872:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802875:	47                   	inc    %edi
  802876:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802879:	75 d1                	jne    80284c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80287b:	89 f8                	mov    %edi,%eax
  80287d:	eb 05                	jmp    802884 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80287f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802884:	83 c4 1c             	add    $0x1c,%esp
  802887:	5b                   	pop    %ebx
  802888:	5e                   	pop    %esi
  802889:	5f                   	pop    %edi
  80288a:	5d                   	pop    %ebp
  80288b:	c3                   	ret    

0080288c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80288c:	55                   	push   %ebp
  80288d:	89 e5                	mov    %esp,%ebp
  80288f:	57                   	push   %edi
  802890:	56                   	push   %esi
  802891:	53                   	push   %ebx
  802892:	83 ec 1c             	sub    $0x1c,%esp
  802895:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802898:	89 3c 24             	mov    %edi,(%esp)
  80289b:	e8 60 ef ff ff       	call   801800 <fd2data>
  8028a0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028a2:	be 00 00 00 00       	mov    $0x0,%esi
  8028a7:	eb 3a                	jmp    8028e3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8028a9:	85 f6                	test   %esi,%esi
  8028ab:	74 04                	je     8028b1 <devpipe_read+0x25>
				return i;
  8028ad:	89 f0                	mov    %esi,%eax
  8028af:	eb 40                	jmp    8028f1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8028b1:	89 da                	mov    %ebx,%edx
  8028b3:	89 f8                	mov    %edi,%eax
  8028b5:	e8 f1 fe ff ff       	call   8027ab <_pipeisclosed>
  8028ba:	85 c0                	test   %eax,%eax
  8028bc:	75 2e                	jne    8028ec <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8028be:	e8 5b e7 ff ff       	call   80101e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8028c3:	8b 03                	mov    (%ebx),%eax
  8028c5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8028c8:	74 df                	je     8028a9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8028ca:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8028cf:	79 05                	jns    8028d6 <devpipe_read+0x4a>
  8028d1:	48                   	dec    %eax
  8028d2:	83 c8 e0             	or     $0xffffffe0,%eax
  8028d5:	40                   	inc    %eax
  8028d6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8028da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028dd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8028e0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8028e2:	46                   	inc    %esi
  8028e3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8028e6:	75 db                	jne    8028c3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8028e8:	89 f0                	mov    %esi,%eax
  8028ea:	eb 05                	jmp    8028f1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8028ec:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8028f1:	83 c4 1c             	add    $0x1c,%esp
  8028f4:	5b                   	pop    %ebx
  8028f5:	5e                   	pop    %esi
  8028f6:	5f                   	pop    %edi
  8028f7:	5d                   	pop    %ebp
  8028f8:	c3                   	ret    

008028f9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8028f9:	55                   	push   %ebp
  8028fa:	89 e5                	mov    %esp,%ebp
  8028fc:	57                   	push   %edi
  8028fd:	56                   	push   %esi
  8028fe:	53                   	push   %ebx
  8028ff:	83 ec 3c             	sub    $0x3c,%esp
  802902:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802905:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802908:	89 04 24             	mov    %eax,(%esp)
  80290b:	e8 0b ef ff ff       	call   80181b <fd_alloc>
  802910:	89 c3                	mov    %eax,%ebx
  802912:	85 c0                	test   %eax,%eax
  802914:	0f 88 45 01 00 00    	js     802a5f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80291a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802921:	00 
  802922:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802925:	89 44 24 04          	mov    %eax,0x4(%esp)
  802929:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802930:	e8 08 e7 ff ff       	call   80103d <sys_page_alloc>
  802935:	89 c3                	mov    %eax,%ebx
  802937:	85 c0                	test   %eax,%eax
  802939:	0f 88 20 01 00 00    	js     802a5f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80293f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802942:	89 04 24             	mov    %eax,(%esp)
  802945:	e8 d1 ee ff ff       	call   80181b <fd_alloc>
  80294a:	89 c3                	mov    %eax,%ebx
  80294c:	85 c0                	test   %eax,%eax
  80294e:	0f 88 f8 00 00 00    	js     802a4c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802954:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80295b:	00 
  80295c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80295f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802963:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80296a:	e8 ce e6 ff ff       	call   80103d <sys_page_alloc>
  80296f:	89 c3                	mov    %eax,%ebx
  802971:	85 c0                	test   %eax,%eax
  802973:	0f 88 d3 00 00 00    	js     802a4c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802979:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80297c:	89 04 24             	mov    %eax,(%esp)
  80297f:	e8 7c ee ff ff       	call   801800 <fd2data>
  802984:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802986:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80298d:	00 
  80298e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802992:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802999:	e8 9f e6 ff ff       	call   80103d <sys_page_alloc>
  80299e:	89 c3                	mov    %eax,%ebx
  8029a0:	85 c0                	test   %eax,%eax
  8029a2:	0f 88 91 00 00 00    	js     802a39 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8029a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8029ab:	89 04 24             	mov    %eax,(%esp)
  8029ae:	e8 4d ee ff ff       	call   801800 <fd2data>
  8029b3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8029ba:	00 
  8029bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8029c6:	00 
  8029c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029d2:	e8 ba e6 ff ff       	call   801091 <sys_page_map>
  8029d7:	89 c3                	mov    %eax,%ebx
  8029d9:	85 c0                	test   %eax,%eax
  8029db:	78 4c                	js     802a29 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8029dd:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8029e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8029e6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8029e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8029eb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8029f2:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8029f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8029fb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8029fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a00:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802a07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a0a:	89 04 24             	mov    %eax,(%esp)
  802a0d:	e8 de ed ff ff       	call   8017f0 <fd2num>
  802a12:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802a14:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a17:	89 04 24             	mov    %eax,(%esp)
  802a1a:	e8 d1 ed ff ff       	call   8017f0 <fd2num>
  802a1f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802a22:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a27:	eb 36                	jmp    802a5f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802a29:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a34:	e8 ab e6 ff ff       	call   8010e4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802a39:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a47:	e8 98 e6 ff ff       	call   8010e4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802a4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a5a:	e8 85 e6 ff ff       	call   8010e4 <sys_page_unmap>
    err:
	return r;
}
  802a5f:	89 d8                	mov    %ebx,%eax
  802a61:	83 c4 3c             	add    $0x3c,%esp
  802a64:	5b                   	pop    %ebx
  802a65:	5e                   	pop    %esi
  802a66:	5f                   	pop    %edi
  802a67:	5d                   	pop    %ebp
  802a68:	c3                   	ret    

00802a69 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802a69:	55                   	push   %ebp
  802a6a:	89 e5                	mov    %esp,%ebp
  802a6c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a72:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a76:	8b 45 08             	mov    0x8(%ebp),%eax
  802a79:	89 04 24             	mov    %eax,(%esp)
  802a7c:	e8 ed ed ff ff       	call   80186e <fd_lookup>
  802a81:	85 c0                	test   %eax,%eax
  802a83:	78 15                	js     802a9a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a88:	89 04 24             	mov    %eax,(%esp)
  802a8b:	e8 70 ed ff ff       	call   801800 <fd2data>
	return _pipeisclosed(fd, p);
  802a90:	89 c2                	mov    %eax,%edx
  802a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a95:	e8 11 fd ff ff       	call   8027ab <_pipeisclosed>
}
  802a9a:	c9                   	leave  
  802a9b:	c3                   	ret    

00802a9c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802a9c:	55                   	push   %ebp
  802a9d:	89 e5                	mov    %esp,%ebp
  802a9f:	56                   	push   %esi
  802aa0:	53                   	push   %ebx
  802aa1:	83 ec 10             	sub    $0x10,%esp
  802aa4:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802aa7:	85 f6                	test   %esi,%esi
  802aa9:	75 24                	jne    802acf <wait+0x33>
  802aab:	c7 44 24 0c ed 35 80 	movl   $0x8035ed,0xc(%esp)
  802ab2:	00 
  802ab3:	c7 44 24 08 07 35 80 	movl   $0x803507,0x8(%esp)
  802aba:	00 
  802abb:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802ac2:	00 
  802ac3:	c7 04 24 f8 35 80 00 	movl   $0x8035f8,(%esp)
  802aca:	e8 d9 da ff ff       	call   8005a8 <_panic>
	e = &envs[ENVX(envid)];
  802acf:	89 f3                	mov    %esi,%ebx
  802ad1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802ad7:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  802ade:	c1 e3 07             	shl    $0x7,%ebx
  802ae1:	29 c3                	sub    %eax,%ebx
  802ae3:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ae9:	eb 05                	jmp    802af0 <wait+0x54>
		sys_yield();
  802aeb:	e8 2e e5 ff ff       	call   80101e <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802af0:	8b 43 48             	mov    0x48(%ebx),%eax
  802af3:	39 f0                	cmp    %esi,%eax
  802af5:	75 07                	jne    802afe <wait+0x62>
  802af7:	8b 43 54             	mov    0x54(%ebx),%eax
  802afa:	85 c0                	test   %eax,%eax
  802afc:	75 ed                	jne    802aeb <wait+0x4f>
		sys_yield();
}
  802afe:	83 c4 10             	add    $0x10,%esp
  802b01:	5b                   	pop    %ebx
  802b02:	5e                   	pop    %esi
  802b03:	5d                   	pop    %ebp
  802b04:	c3                   	ret    
  802b05:	00 00                	add    %al,(%eax)
	...

00802b08 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802b08:	55                   	push   %ebp
  802b09:	89 e5                	mov    %esp,%ebp
  802b0b:	53                   	push   %ebx
  802b0c:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802b0f:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802b16:	75 6f                	jne    802b87 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  802b18:	e8 e2 e4 ff ff       	call   800fff <sys_getenvid>
  802b1d:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  802b1f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802b26:	00 
  802b27:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802b2e:	ee 
  802b2f:	89 04 24             	mov    %eax,(%esp)
  802b32:	e8 06 e5 ff ff       	call   80103d <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  802b37:	85 c0                	test   %eax,%eax
  802b39:	79 1c                	jns    802b57 <set_pgfault_handler+0x4f>
  802b3b:	c7 44 24 08 04 36 80 	movl   $0x803604,0x8(%esp)
  802b42:	00 
  802b43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802b4a:	00 
  802b4b:	c7 04 24 60 36 80 00 	movl   $0x803660,(%esp)
  802b52:	e8 51 da ff ff       	call   8005a8 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  802b57:	c7 44 24 04 98 2b 80 	movl   $0x802b98,0x4(%esp)
  802b5e:	00 
  802b5f:	89 1c 24             	mov    %ebx,(%esp)
  802b62:	e8 76 e6 ff ff       	call   8011dd <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  802b67:	85 c0                	test   %eax,%eax
  802b69:	79 1c                	jns    802b87 <set_pgfault_handler+0x7f>
  802b6b:	c7 44 24 08 2c 36 80 	movl   $0x80362c,0x8(%esp)
  802b72:	00 
  802b73:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  802b7a:	00 
  802b7b:	c7 04 24 60 36 80 00 	movl   $0x803660,(%esp)
  802b82:	e8 21 da ff ff       	call   8005a8 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b87:	8b 45 08             	mov    0x8(%ebp),%eax
  802b8a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802b8f:	83 c4 14             	add    $0x14,%esp
  802b92:	5b                   	pop    %ebx
  802b93:	5d                   	pop    %ebp
  802b94:	c3                   	ret    
  802b95:	00 00                	add    %al,(%eax)
	...

00802b98 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b98:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b99:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802b9e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ba0:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  802ba3:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  802ba7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  802bac:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  802bb0:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  802bb2:	83 c4 08             	add    $0x8,%esp
	popal
  802bb5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  802bb6:	83 c4 04             	add    $0x4,%esp
	popfl
  802bb9:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  802bba:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802bbd:	c3                   	ret    
	...

00802bc0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802bc0:	55                   	push   %ebp
  802bc1:	89 e5                	mov    %esp,%ebp
  802bc3:	56                   	push   %esi
  802bc4:	53                   	push   %ebx
  802bc5:	83 ec 10             	sub    $0x10,%esp
  802bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  802bce:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802bd1:	85 c0                	test   %eax,%eax
  802bd3:	75 05                	jne    802bda <ipc_recv+0x1a>
  802bd5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  802bda:	89 04 24             	mov    %eax,(%esp)
  802bdd:	e8 71 e6 ff ff       	call   801253 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  802be2:	85 c0                	test   %eax,%eax
  802be4:	79 16                	jns    802bfc <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  802be6:	85 db                	test   %ebx,%ebx
  802be8:	74 06                	je     802bf0 <ipc_recv+0x30>
  802bea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  802bf0:	85 f6                	test   %esi,%esi
  802bf2:	74 32                	je     802c26 <ipc_recv+0x66>
  802bf4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802bfa:	eb 2a                	jmp    802c26 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802bfc:	85 db                	test   %ebx,%ebx
  802bfe:	74 0c                	je     802c0c <ipc_recv+0x4c>
  802c00:	a1 04 50 80 00       	mov    0x805004,%eax
  802c05:	8b 00                	mov    (%eax),%eax
  802c07:	8b 40 74             	mov    0x74(%eax),%eax
  802c0a:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802c0c:	85 f6                	test   %esi,%esi
  802c0e:	74 0c                	je     802c1c <ipc_recv+0x5c>
  802c10:	a1 04 50 80 00       	mov    0x805004,%eax
  802c15:	8b 00                	mov    (%eax),%eax
  802c17:	8b 40 78             	mov    0x78(%eax),%eax
  802c1a:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  802c1c:	a1 04 50 80 00       	mov    0x805004,%eax
  802c21:	8b 00                	mov    (%eax),%eax
  802c23:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  802c26:	83 c4 10             	add    $0x10,%esp
  802c29:	5b                   	pop    %ebx
  802c2a:	5e                   	pop    %esi
  802c2b:	5d                   	pop    %ebp
  802c2c:	c3                   	ret    

00802c2d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802c2d:	55                   	push   %ebp
  802c2e:	89 e5                	mov    %esp,%ebp
  802c30:	57                   	push   %edi
  802c31:	56                   	push   %esi
  802c32:	53                   	push   %ebx
  802c33:	83 ec 1c             	sub    $0x1c,%esp
  802c36:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802c39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802c3c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802c3f:	85 db                	test   %ebx,%ebx
  802c41:	75 05                	jne    802c48 <ipc_send+0x1b>
  802c43:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  802c48:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802c4c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c50:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c54:	8b 45 08             	mov    0x8(%ebp),%eax
  802c57:	89 04 24             	mov    %eax,(%esp)
  802c5a:	e8 d1 e5 ff ff       	call   801230 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  802c5f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802c62:	75 07                	jne    802c6b <ipc_send+0x3e>
  802c64:	e8 b5 e3 ff ff       	call   80101e <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  802c69:	eb dd                	jmp    802c48 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  802c6b:	85 c0                	test   %eax,%eax
  802c6d:	79 1c                	jns    802c8b <ipc_send+0x5e>
  802c6f:	c7 44 24 08 6e 36 80 	movl   $0x80366e,0x8(%esp)
  802c76:	00 
  802c77:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802c7e:	00 
  802c7f:	c7 04 24 80 36 80 00 	movl   $0x803680,(%esp)
  802c86:	e8 1d d9 ff ff       	call   8005a8 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  802c8b:	83 c4 1c             	add    $0x1c,%esp
  802c8e:	5b                   	pop    %ebx
  802c8f:	5e                   	pop    %esi
  802c90:	5f                   	pop    %edi
  802c91:	5d                   	pop    %ebp
  802c92:	c3                   	ret    

00802c93 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802c93:	55                   	push   %ebp
  802c94:	89 e5                	mov    %esp,%ebp
  802c96:	53                   	push   %ebx
  802c97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802c9a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802c9f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802ca6:	89 c2                	mov    %eax,%edx
  802ca8:	c1 e2 07             	shl    $0x7,%edx
  802cab:	29 ca                	sub    %ecx,%edx
  802cad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802cb3:	8b 52 50             	mov    0x50(%edx),%edx
  802cb6:	39 da                	cmp    %ebx,%edx
  802cb8:	75 0f                	jne    802cc9 <ipc_find_env+0x36>
			return envs[i].env_id;
  802cba:	c1 e0 07             	shl    $0x7,%eax
  802cbd:	29 c8                	sub    %ecx,%eax
  802cbf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802cc4:	8b 40 40             	mov    0x40(%eax),%eax
  802cc7:	eb 0c                	jmp    802cd5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802cc9:	40                   	inc    %eax
  802cca:	3d 00 04 00 00       	cmp    $0x400,%eax
  802ccf:	75 ce                	jne    802c9f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802cd1:	66 b8 00 00          	mov    $0x0,%ax
}
  802cd5:	5b                   	pop    %ebx
  802cd6:	5d                   	pop    %ebp
  802cd7:	c3                   	ret    

00802cd8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802cd8:	55                   	push   %ebp
  802cd9:	89 e5                	mov    %esp,%ebp
  802cdb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  802cde:	89 c2                	mov    %eax,%edx
  802ce0:	c1 ea 16             	shr    $0x16,%edx
  802ce3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802cea:	f6 c2 01             	test   $0x1,%dl
  802ced:	74 1e                	je     802d0d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802cef:	c1 e8 0c             	shr    $0xc,%eax
  802cf2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802cf9:	a8 01                	test   $0x1,%al
  802cfb:	74 17                	je     802d14 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802cfd:	c1 e8 0c             	shr    $0xc,%eax
  802d00:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802d07:	ef 
  802d08:	0f b7 c0             	movzwl %ax,%eax
  802d0b:	eb 0c                	jmp    802d19 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  802d12:	eb 05                	jmp    802d19 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802d14:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802d19:	5d                   	pop    %ebp
  802d1a:	c3                   	ret    
	...

00802d1c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802d1c:	55                   	push   %ebp
  802d1d:	57                   	push   %edi
  802d1e:	56                   	push   %esi
  802d1f:	83 ec 10             	sub    $0x10,%esp
  802d22:	8b 74 24 20          	mov    0x20(%esp),%esi
  802d26:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802d2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d2e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802d32:	89 cd                	mov    %ecx,%ebp
  802d34:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802d38:	85 c0                	test   %eax,%eax
  802d3a:	75 2c                	jne    802d68 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802d3c:	39 f9                	cmp    %edi,%ecx
  802d3e:	77 68                	ja     802da8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802d40:	85 c9                	test   %ecx,%ecx
  802d42:	75 0b                	jne    802d4f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802d44:	b8 01 00 00 00       	mov    $0x1,%eax
  802d49:	31 d2                	xor    %edx,%edx
  802d4b:	f7 f1                	div    %ecx
  802d4d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802d4f:	31 d2                	xor    %edx,%edx
  802d51:	89 f8                	mov    %edi,%eax
  802d53:	f7 f1                	div    %ecx
  802d55:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802d57:	89 f0                	mov    %esi,%eax
  802d59:	f7 f1                	div    %ecx
  802d5b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d5d:	89 f0                	mov    %esi,%eax
  802d5f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d61:	83 c4 10             	add    $0x10,%esp
  802d64:	5e                   	pop    %esi
  802d65:	5f                   	pop    %edi
  802d66:	5d                   	pop    %ebp
  802d67:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802d68:	39 f8                	cmp    %edi,%eax
  802d6a:	77 2c                	ja     802d98 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802d6c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802d6f:	83 f6 1f             	xor    $0x1f,%esi
  802d72:	75 4c                	jne    802dc0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802d74:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802d76:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802d7b:	72 0a                	jb     802d87 <__udivdi3+0x6b>
  802d7d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802d81:	0f 87 ad 00 00 00    	ja     802e34 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802d87:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d8c:	89 f0                	mov    %esi,%eax
  802d8e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d90:	83 c4 10             	add    $0x10,%esp
  802d93:	5e                   	pop    %esi
  802d94:	5f                   	pop    %edi
  802d95:	5d                   	pop    %ebp
  802d96:	c3                   	ret    
  802d97:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802d98:	31 ff                	xor    %edi,%edi
  802d9a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d9c:	89 f0                	mov    %esi,%eax
  802d9e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802da0:	83 c4 10             	add    $0x10,%esp
  802da3:	5e                   	pop    %esi
  802da4:	5f                   	pop    %edi
  802da5:	5d                   	pop    %ebp
  802da6:	c3                   	ret    
  802da7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802da8:	89 fa                	mov    %edi,%edx
  802daa:	89 f0                	mov    %esi,%eax
  802dac:	f7 f1                	div    %ecx
  802dae:	89 c6                	mov    %eax,%esi
  802db0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802db2:	89 f0                	mov    %esi,%eax
  802db4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802db6:	83 c4 10             	add    $0x10,%esp
  802db9:	5e                   	pop    %esi
  802dba:	5f                   	pop    %edi
  802dbb:	5d                   	pop    %ebp
  802dbc:	c3                   	ret    
  802dbd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802dc0:	89 f1                	mov    %esi,%ecx
  802dc2:	d3 e0                	shl    %cl,%eax
  802dc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802dc8:	b8 20 00 00 00       	mov    $0x20,%eax
  802dcd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802dcf:	89 ea                	mov    %ebp,%edx
  802dd1:	88 c1                	mov    %al,%cl
  802dd3:	d3 ea                	shr    %cl,%edx
  802dd5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802dd9:	09 ca                	or     %ecx,%edx
  802ddb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802ddf:	89 f1                	mov    %esi,%ecx
  802de1:	d3 e5                	shl    %cl,%ebp
  802de3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802de7:	89 fd                	mov    %edi,%ebp
  802de9:	88 c1                	mov    %al,%cl
  802deb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802ded:	89 fa                	mov    %edi,%edx
  802def:	89 f1                	mov    %esi,%ecx
  802df1:	d3 e2                	shl    %cl,%edx
  802df3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802df7:	88 c1                	mov    %al,%cl
  802df9:	d3 ef                	shr    %cl,%edi
  802dfb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802dfd:	89 f8                	mov    %edi,%eax
  802dff:	89 ea                	mov    %ebp,%edx
  802e01:	f7 74 24 08          	divl   0x8(%esp)
  802e05:	89 d1                	mov    %edx,%ecx
  802e07:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802e09:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802e0d:	39 d1                	cmp    %edx,%ecx
  802e0f:	72 17                	jb     802e28 <__udivdi3+0x10c>
  802e11:	74 09                	je     802e1c <__udivdi3+0x100>
  802e13:	89 fe                	mov    %edi,%esi
  802e15:	31 ff                	xor    %edi,%edi
  802e17:	e9 41 ff ff ff       	jmp    802d5d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802e1c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802e20:	89 f1                	mov    %esi,%ecx
  802e22:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802e24:	39 c2                	cmp    %eax,%edx
  802e26:	73 eb                	jae    802e13 <__udivdi3+0xf7>
		{
		  q0--;
  802e28:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802e2b:	31 ff                	xor    %edi,%edi
  802e2d:	e9 2b ff ff ff       	jmp    802d5d <__udivdi3+0x41>
  802e32:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802e34:	31 f6                	xor    %esi,%esi
  802e36:	e9 22 ff ff ff       	jmp    802d5d <__udivdi3+0x41>
	...

00802e3c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802e3c:	55                   	push   %ebp
  802e3d:	57                   	push   %edi
  802e3e:	56                   	push   %esi
  802e3f:	83 ec 20             	sub    $0x20,%esp
  802e42:	8b 44 24 30          	mov    0x30(%esp),%eax
  802e46:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802e4a:	89 44 24 14          	mov    %eax,0x14(%esp)
  802e4e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802e52:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802e56:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802e5a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802e5c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802e5e:	85 ed                	test   %ebp,%ebp
  802e60:	75 16                	jne    802e78 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802e62:	39 f1                	cmp    %esi,%ecx
  802e64:	0f 86 a6 00 00 00    	jbe    802f10 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802e6a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802e6c:	89 d0                	mov    %edx,%eax
  802e6e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802e70:	83 c4 20             	add    $0x20,%esp
  802e73:	5e                   	pop    %esi
  802e74:	5f                   	pop    %edi
  802e75:	5d                   	pop    %ebp
  802e76:	c3                   	ret    
  802e77:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802e78:	39 f5                	cmp    %esi,%ebp
  802e7a:	0f 87 ac 00 00 00    	ja     802f2c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802e80:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802e83:	83 f0 1f             	xor    $0x1f,%eax
  802e86:	89 44 24 10          	mov    %eax,0x10(%esp)
  802e8a:	0f 84 a8 00 00 00    	je     802f38 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802e90:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802e94:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802e96:	bf 20 00 00 00       	mov    $0x20,%edi
  802e9b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802e9f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ea3:	89 f9                	mov    %edi,%ecx
  802ea5:	d3 e8                	shr    %cl,%eax
  802ea7:	09 e8                	or     %ebp,%eax
  802ea9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802ead:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802eb1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802eb5:	d3 e0                	shl    %cl,%eax
  802eb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ebb:	89 f2                	mov    %esi,%edx
  802ebd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802ebf:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ec3:	d3 e0                	shl    %cl,%eax
  802ec5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ec9:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ecd:	89 f9                	mov    %edi,%ecx
  802ecf:	d3 e8                	shr    %cl,%eax
  802ed1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802ed3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802ed5:	89 f2                	mov    %esi,%edx
  802ed7:	f7 74 24 18          	divl   0x18(%esp)
  802edb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802edd:	f7 64 24 0c          	mull   0xc(%esp)
  802ee1:	89 c5                	mov    %eax,%ebp
  802ee3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ee5:	39 d6                	cmp    %edx,%esi
  802ee7:	72 67                	jb     802f50 <__umoddi3+0x114>
  802ee9:	74 75                	je     802f60 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802eeb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802eef:	29 e8                	sub    %ebp,%eax
  802ef1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802ef3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ef7:	d3 e8                	shr    %cl,%eax
  802ef9:	89 f2                	mov    %esi,%edx
  802efb:	89 f9                	mov    %edi,%ecx
  802efd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802eff:	09 d0                	or     %edx,%eax
  802f01:	89 f2                	mov    %esi,%edx
  802f03:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802f07:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802f09:	83 c4 20             	add    $0x20,%esp
  802f0c:	5e                   	pop    %esi
  802f0d:	5f                   	pop    %edi
  802f0e:	5d                   	pop    %ebp
  802f0f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802f10:	85 c9                	test   %ecx,%ecx
  802f12:	75 0b                	jne    802f1f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802f14:	b8 01 00 00 00       	mov    $0x1,%eax
  802f19:	31 d2                	xor    %edx,%edx
  802f1b:	f7 f1                	div    %ecx
  802f1d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802f1f:	89 f0                	mov    %esi,%eax
  802f21:	31 d2                	xor    %edx,%edx
  802f23:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802f25:	89 f8                	mov    %edi,%eax
  802f27:	e9 3e ff ff ff       	jmp    802e6a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802f2c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802f2e:	83 c4 20             	add    $0x20,%esp
  802f31:	5e                   	pop    %esi
  802f32:	5f                   	pop    %edi
  802f33:	5d                   	pop    %ebp
  802f34:	c3                   	ret    
  802f35:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802f38:	39 f5                	cmp    %esi,%ebp
  802f3a:	72 04                	jb     802f40 <__umoddi3+0x104>
  802f3c:	39 f9                	cmp    %edi,%ecx
  802f3e:	77 06                	ja     802f46 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802f40:	89 f2                	mov    %esi,%edx
  802f42:	29 cf                	sub    %ecx,%edi
  802f44:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802f46:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802f48:	83 c4 20             	add    $0x20,%esp
  802f4b:	5e                   	pop    %esi
  802f4c:	5f                   	pop    %edi
  802f4d:	5d                   	pop    %ebp
  802f4e:	c3                   	ret    
  802f4f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802f50:	89 d1                	mov    %edx,%ecx
  802f52:	89 c5                	mov    %eax,%ebp
  802f54:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802f58:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802f5c:	eb 8d                	jmp    802eeb <__umoddi3+0xaf>
  802f5e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802f60:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802f64:	72 ea                	jb     802f50 <__umoddi3+0x114>
  802f66:	89 f1                	mov    %esi,%ecx
  802f68:	eb 81                	jmp    802eeb <__umoddi3+0xaf>
