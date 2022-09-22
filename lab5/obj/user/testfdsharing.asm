
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 eb 01 00 00       	call   80021c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800044:	00 
  800045:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  80004c:	e8 da 1c 00 00       	call   801d2b <open>
  800051:	89 c3                	mov    %eax,%ebx
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("open motd: %e", fd);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 c5 27 80 	movl   $0x8027c5,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 d3 27 80 00 	movl   $0x8027d3,(%esp)
  800072:	e8 19 02 00 00       	call   800290 <_panic>
	seek(fd, 0);
  800077:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007e:	00 
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 d7 18 00 00       	call   80195e <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800087:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 20 42 80 	movl   $0x804220,0x4(%esp)
  800096:	00 
  800097:	89 1c 24             	mov    %ebx,(%esp)
  80009a:	e8 e7 17 00 00       	call   801886 <readn>
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	7f 20                	jg     8000c5 <umain+0x91>
		panic("readn: %e", n);
  8000a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a9:	c7 44 24 08 e8 27 80 	movl   $0x8027e8,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b8:	00 
  8000b9:	c7 04 24 d3 27 80 00 	movl   $0x8027d3,(%esp)
  8000c0:	e8 cb 01 00 00       	call   800290 <_panic>

	if ((r = fork()) < 0)
  8000c5:	e8 fe 10 00 00       	call   8011c8 <fork>
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	85 c0                	test   %eax,%eax
  8000ce:	79 20                	jns    8000f0 <umain+0xbc>
		panic("fork: %e", r);
  8000d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d4:	c7 44 24 08 f2 27 80 	movl   $0x8027f2,0x8(%esp)
  8000db:	00 
  8000dc:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e3:	00 
  8000e4:	c7 04 24 d3 27 80 00 	movl   $0x8027d3,(%esp)
  8000eb:	e8 a0 01 00 00       	call   800290 <_panic>
	if (r == 0) {
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	0f 85 bd 00 00 00    	jne    8001b5 <umain+0x181>
		seek(fd, 0);
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 1c 24             	mov    %ebx,(%esp)
  800103:	e8 56 18 00 00       	call   80195e <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800108:	c7 04 24 30 28 80 00 	movl   $0x802830,(%esp)
  80010f:	e8 74 02 00 00       	call   800388 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800114:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011b:	00 
  80011c:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800123:	00 
  800124:	89 1c 24             	mov    %ebx,(%esp)
  800127:	e8 5a 17 00 00       	call   801886 <readn>
  80012c:	39 f8                	cmp    %edi,%eax
  80012e:	74 24                	je     800154 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  800130:	89 44 24 10          	mov    %eax,0x10(%esp)
  800134:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800138:	c7 44 24 08 74 28 80 	movl   $0x802874,0x8(%esp)
  80013f:	00 
  800140:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800147:	00 
  800148:	c7 04 24 d3 27 80 00 	movl   $0x8027d3,(%esp)
  80014f:	e8 3c 01 00 00       	call   800290 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800154:	89 44 24 08          	mov    %eax,0x8(%esp)
  800158:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80015f:	00 
  800160:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  800167:	e8 cb 09 00 00       	call   800b37 <memcmp>
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 1c                	je     80018c <umain+0x158>
			panic("read in parent got different bytes from read in child");
  800170:	c7 44 24 08 a0 28 80 	movl   $0x8028a0,0x8(%esp)
  800177:	00 
  800178:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017f:	00 
  800180:	c7 04 24 d3 27 80 00 	movl   $0x8027d3,(%esp)
  800187:	e8 04 01 00 00       	call   800290 <_panic>
		cprintf("read in child succeeded\n");
  80018c:	c7 04 24 fb 27 80 00 	movl   $0x8027fb,(%esp)
  800193:	e8 f0 01 00 00       	call   800388 <cprintf>
		seek(fd, 0);
  800198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019f:	00 
  8001a0:	89 1c 24             	mov    %ebx,(%esp)
  8001a3:	e8 b6 17 00 00       	call   80195e <seek>
		close(fd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 e0 14 00 00       	call   801690 <close>
		exit();
  8001b0:	e8 bf 00 00 00       	call   800274 <exit>
	}
	wait(r);
  8001b5:	89 34 24             	mov    %esi,(%esp)
  8001b8:	e8 8b 1f 00 00       	call   802148 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  8001cc:	00 
  8001cd:	89 1c 24             	mov    %ebx,(%esp)
  8001d0:	e8 b1 16 00 00       	call   801886 <readn>
  8001d5:	39 f8                	cmp    %edi,%eax
  8001d7:	74 24                	je     8001fd <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e1:	c7 44 24 08 d8 28 80 	movl   $0x8028d8,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 d3 27 80 00 	movl   $0x8027d3,(%esp)
  8001f8:	e8 93 00 00 00       	call   800290 <_panic>
	cprintf("read in parent succeeded\n");
  8001fd:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  800204:	e8 7f 01 00 00       	call   800388 <cprintf>
	close(fd);
  800209:	89 1c 24             	mov    %ebx,(%esp)
  80020c:	e8 7f 14 00 00       	call   801690 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800211:	cc                   	int3   

	breakpoint();
}
  800212:	83 c4 2c             	add    $0x2c,%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
	...

0080021c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 20             	sub    $0x20,%esp
  800224:	8b 75 08             	mov    0x8(%ebp),%esi
  800227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80022a:	e8 b8 0a 00 00       	call   800ce7 <sys_getenvid>
  80022f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800234:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80023b:	c1 e0 07             	shl    $0x7,%eax
  80023e:	29 d0                	sub    %edx,%eax
  800240:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800245:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80024b:	a3 20 44 80 00       	mov    %eax,0x804420
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800250:	85 f6                	test   %esi,%esi
  800252:	7e 07                	jle    80025b <libmain+0x3f>
		binaryname = argv[0];
  800254:	8b 03                	mov    (%ebx),%eax
  800256:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80025b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80025f:	89 34 24             	mov    %esi,(%esp)
  800262:	e8 cd fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800267:	e8 08 00 00 00       	call   800274 <exit>
}
  80026c:	83 c4 20             	add    $0x20,%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
	...

00800274 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80027a:	e8 42 14 00 00       	call   8016c1 <close_all>
	sys_env_destroy(0);
  80027f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800286:	e8 0a 0a 00 00       	call   800c95 <sys_env_destroy>
}
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    
  80028d:	00 00                	add    %al,(%eax)
	...

00800290 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800298:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002a1:	e8 41 0a 00 00       	call   800ce7 <sys_getenvid>
  8002a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	c7 04 24 08 29 80 00 	movl   $0x802908,(%esp)
  8002c3:	e8 c0 00 00 00       	call   800388 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	e8 50 00 00 00       	call   800327 <vcprintf>
	cprintf("\n");
  8002d7:	c7 04 24 90 2c 80 00 	movl   $0x802c90,(%esp)
  8002de:	e8 a5 00 00 00       	call   800388 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002e3:	cc                   	int3   
  8002e4:	eb fd                	jmp    8002e3 <_panic+0x53>
	...

008002e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 14             	sub    $0x14,%esp
  8002ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002f2:	8b 03                	mov    (%ebx),%eax
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002fb:	40                   	inc    %eax
  8002fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800303:	75 19                	jne    80031e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800305:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80030c:	00 
  80030d:	8d 43 08             	lea    0x8(%ebx),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 40 09 00 00       	call   800c58 <sys_cputs>
		b->idx = 0;
  800318:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80031e:	ff 43 04             	incl   0x4(%ebx)
}
  800321:	83 c4 14             	add    $0x14,%esp
  800324:	5b                   	pop    %ebx
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800330:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800337:	00 00 00 
	b.cnt = 0;
  80033a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800341:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800344:	8b 45 0c             	mov    0xc(%ebp),%eax
  800347:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80034b:	8b 45 08             	mov    0x8(%ebp),%eax
  80034e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800352:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035c:	c7 04 24 e8 02 80 00 	movl   $0x8002e8,(%esp)
  800363:	e8 82 01 00 00       	call   8004ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800368:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80036e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800372:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800378:	89 04 24             	mov    %eax,(%esp)
  80037b:	e8 d8 08 00 00       	call   800c58 <sys_cputs>

	return b.cnt;
}
  800380:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80038e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800391:	89 44 24 04          	mov    %eax,0x4(%esp)
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	e8 87 ff ff ff       	call   800327 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a0:	c9                   	leave  
  8003a1:	c3                   	ret    
	...

008003a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 3c             	sub    $0x3c,%esp
  8003ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b0:	89 d7                	mov    %edx,%edi
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003be:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003c1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c4:	85 c0                	test   %eax,%eax
  8003c6:	75 08                	jne    8003d0 <printnum+0x2c>
  8003c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003ce:	77 57                	ja     800427 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003d4:	4b                   	dec    %ebx
  8003d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003e4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ef:	00 
  8003f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003f3:	89 04 24             	mov    %eax,(%esp)
  8003f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fd:	e8 66 21 00 00       	call   802568 <__udivdi3>
  800402:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800406:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80040a:	89 04 24             	mov    %eax,(%esp)
  80040d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800411:	89 fa                	mov    %edi,%edx
  800413:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800416:	e8 89 ff ff ff       	call   8003a4 <printnum>
  80041b:	eb 0f                	jmp    80042c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80041d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800421:	89 34 24             	mov    %esi,(%esp)
  800424:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800427:	4b                   	dec    %ebx
  800428:	85 db                	test   %ebx,%ebx
  80042a:	7f f1                	jg     80041d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80042c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800430:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800434:	8b 45 10             	mov    0x10(%ebp),%eax
  800437:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800442:	00 
  800443:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800446:	89 04 24             	mov    %eax,(%esp)
  800449:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80044c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800450:	e8 33 22 00 00       	call   802688 <__umoddi3>
  800455:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800459:	0f be 80 2b 29 80 00 	movsbl 0x80292b(%eax),%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800466:	83 c4 3c             	add    $0x3c,%esp
  800469:	5b                   	pop    %ebx
  80046a:	5e                   	pop    %esi
  80046b:	5f                   	pop    %edi
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800471:	83 fa 01             	cmp    $0x1,%edx
  800474:	7e 0e                	jle    800484 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800476:	8b 10                	mov    (%eax),%edx
  800478:	8d 4a 08             	lea    0x8(%edx),%ecx
  80047b:	89 08                	mov    %ecx,(%eax)
  80047d:	8b 02                	mov    (%edx),%eax
  80047f:	8b 52 04             	mov    0x4(%edx),%edx
  800482:	eb 22                	jmp    8004a6 <getuint+0x38>
	else if (lflag)
  800484:	85 d2                	test   %edx,%edx
  800486:	74 10                	je     800498 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800488:	8b 10                	mov    (%eax),%edx
  80048a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048d:	89 08                	mov    %ecx,(%eax)
  80048f:	8b 02                	mov    (%edx),%eax
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 0e                	jmp    8004a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049d:	89 08                	mov    %ecx,(%eax)
  80049f:	8b 02                	mov    (%edx),%eax
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004a6:	5d                   	pop    %ebp
  8004a7:	c3                   	ret    

008004a8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ae:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004b1:	8b 10                	mov    (%eax),%edx
  8004b3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b6:	73 08                	jae    8004c0 <sprintputch+0x18>
		*b->buf++ = ch;
  8004b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004bb:	88 0a                	mov    %cl,(%edx)
  8004bd:	42                   	inc    %edx
  8004be:	89 10                	mov    %edx,(%eax)
}
  8004c0:	5d                   	pop    %ebp
  8004c1:	c3                   	ret    

008004c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	e8 02 00 00 00       	call   8004ea <vprintfmt>
	va_end(ap);
}
  8004e8:	c9                   	leave  
  8004e9:	c3                   	ret    

008004ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	57                   	push   %edi
  8004ee:	56                   	push   %esi
  8004ef:	53                   	push   %ebx
  8004f0:	83 ec 4c             	sub    $0x4c,%esp
  8004f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f6:	8b 75 10             	mov    0x10(%ebp),%esi
  8004f9:	eb 12                	jmp    80050d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	0f 84 6b 03 00 00    	je     80086e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800503:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800507:	89 04 24             	mov    %eax,(%esp)
  80050a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050d:	0f b6 06             	movzbl (%esi),%eax
  800510:	46                   	inc    %esi
  800511:	83 f8 25             	cmp    $0x25,%eax
  800514:	75 e5                	jne    8004fb <vprintfmt+0x11>
  800516:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80051a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800521:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800526:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80052d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800532:	eb 26                	jmp    80055a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800537:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80053b:	eb 1d                	jmp    80055a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800540:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800544:	eb 14                	jmp    80055a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800549:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800550:	eb 08                	jmp    80055a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800552:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800555:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	0f b6 06             	movzbl (%esi),%eax
  80055d:	8d 56 01             	lea    0x1(%esi),%edx
  800560:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800563:	8a 16                	mov    (%esi),%dl
  800565:	83 ea 23             	sub    $0x23,%edx
  800568:	80 fa 55             	cmp    $0x55,%dl
  80056b:	0f 87 e1 02 00 00    	ja     800852 <vprintfmt+0x368>
  800571:	0f b6 d2             	movzbl %dl,%edx
  800574:	ff 24 95 60 2a 80 00 	jmp    *0x802a60(,%edx,4)
  80057b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80057e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800583:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800586:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80058a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80058d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800590:	83 fa 09             	cmp    $0x9,%edx
  800593:	77 2a                	ja     8005bf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800595:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800596:	eb eb                	jmp    800583 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8d 50 04             	lea    0x4(%eax),%edx
  80059e:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a6:	eb 17                	jmp    8005bf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ac:	78 98                	js     800546 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b1:	eb a7                	jmp    80055a <vprintfmt+0x70>
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005bd:	eb 9b                	jmp    80055a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c3:	79 95                	jns    80055a <vprintfmt+0x70>
  8005c5:	eb 8b                	jmp    800552 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005c7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005cb:	eb 8d                	jmp    80055a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005e5:	e9 23 ff ff ff       	jmp    80050d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 04             	lea    0x4(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	79 02                	jns    8005fb <vprintfmt+0x111>
  8005f9:	f7 d8                	neg    %eax
  8005fb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fd:	83 f8 0f             	cmp    $0xf,%eax
  800600:	7f 0b                	jg     80060d <vprintfmt+0x123>
  800602:	8b 04 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%eax
  800609:	85 c0                	test   %eax,%eax
  80060b:	75 23                	jne    800630 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80060d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800611:	c7 44 24 08 43 29 80 	movl   $0x802943,0x8(%esp)
  800618:	00 
  800619:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061d:	8b 45 08             	mov    0x8(%ebp),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	e8 9a fe ff ff       	call   8004c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800628:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80062b:	e9 dd fe ff ff       	jmp    80050d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800630:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800634:	c7 44 24 08 39 2d 80 	movl   $0x802d39,0x8(%esp)
  80063b:	00 
  80063c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800640:	8b 55 08             	mov    0x8(%ebp),%edx
  800643:	89 14 24             	mov    %edx,(%esp)
  800646:	e8 77 fe ff ff       	call   8004c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064e:	e9 ba fe ff ff       	jmp    80050d <vprintfmt+0x23>
  800653:	89 f9                	mov    %edi,%ecx
  800655:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800658:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8d 50 04             	lea    0x4(%eax),%edx
  800661:	89 55 14             	mov    %edx,0x14(%ebp)
  800664:	8b 30                	mov    (%eax),%esi
  800666:	85 f6                	test   %esi,%esi
  800668:	75 05                	jne    80066f <vprintfmt+0x185>
				p = "(null)";
  80066a:	be 3c 29 80 00       	mov    $0x80293c,%esi
			if (width > 0 && padc != '-')
  80066f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800673:	0f 8e 84 00 00 00    	jle    8006fd <vprintfmt+0x213>
  800679:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80067d:	74 7e                	je     8006fd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800683:	89 34 24             	mov    %esi,(%esp)
  800686:	e8 8b 02 00 00       	call   800916 <strnlen>
  80068b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80068e:	29 c2                	sub    %eax,%edx
  800690:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800693:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800697:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80069a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80069d:	89 de                	mov    %ebx,%esi
  80069f:	89 d3                	mov    %edx,%ebx
  8006a1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a3:	eb 0b                	jmp    8006b0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a9:	89 3c 24             	mov    %edi,(%esp)
  8006ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006af:	4b                   	dec    %ebx
  8006b0:	85 db                	test   %ebx,%ebx
  8006b2:	7f f1                	jg     8006a5 <vprintfmt+0x1bb>
  8006b4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006b7:	89 f3                	mov    %esi,%ebx
  8006b9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	79 05                	jns    8006c8 <vprintfmt+0x1de>
  8006c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006cb:	29 c2                	sub    %eax,%edx
  8006cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006d0:	eb 2b                	jmp    8006fd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d6:	74 18                	je     8006f0 <vprintfmt+0x206>
  8006d8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006db:	83 fa 5e             	cmp    $0x5e,%edx
  8006de:	76 10                	jbe    8006f0 <vprintfmt+0x206>
					putch('?', putdat);
  8006e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006eb:	ff 55 08             	call   *0x8(%ebp)
  8006ee:	eb 0a                	jmp    8006fa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fa:	ff 4d e4             	decl   -0x1c(%ebp)
  8006fd:	0f be 06             	movsbl (%esi),%eax
  800700:	46                   	inc    %esi
  800701:	85 c0                	test   %eax,%eax
  800703:	74 21                	je     800726 <vprintfmt+0x23c>
  800705:	85 ff                	test   %edi,%edi
  800707:	78 c9                	js     8006d2 <vprintfmt+0x1e8>
  800709:	4f                   	dec    %edi
  80070a:	79 c6                	jns    8006d2 <vprintfmt+0x1e8>
  80070c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070f:	89 de                	mov    %ebx,%esi
  800711:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800714:	eb 18                	jmp    80072e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800716:	89 74 24 04          	mov    %esi,0x4(%esp)
  80071a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800721:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800723:	4b                   	dec    %ebx
  800724:	eb 08                	jmp    80072e <vprintfmt+0x244>
  800726:	8b 7d 08             	mov    0x8(%ebp),%edi
  800729:	89 de                	mov    %ebx,%esi
  80072b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80072e:	85 db                	test   %ebx,%ebx
  800730:	7f e4                	jg     800716 <vprintfmt+0x22c>
  800732:	89 7d 08             	mov    %edi,0x8(%ebp)
  800735:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800737:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80073a:	e9 ce fd ff ff       	jmp    80050d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073f:	83 f9 01             	cmp    $0x1,%ecx
  800742:	7e 10                	jle    800754 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 50 08             	lea    0x8(%eax),%edx
  80074a:	89 55 14             	mov    %edx,0x14(%ebp)
  80074d:	8b 30                	mov    (%eax),%esi
  80074f:	8b 78 04             	mov    0x4(%eax),%edi
  800752:	eb 26                	jmp    80077a <vprintfmt+0x290>
	else if (lflag)
  800754:	85 c9                	test   %ecx,%ecx
  800756:	74 12                	je     80076a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 50 04             	lea    0x4(%eax),%edx
  80075e:	89 55 14             	mov    %edx,0x14(%ebp)
  800761:	8b 30                	mov    (%eax),%esi
  800763:	89 f7                	mov    %esi,%edi
  800765:	c1 ff 1f             	sar    $0x1f,%edi
  800768:	eb 10                	jmp    80077a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8d 50 04             	lea    0x4(%eax),%edx
  800770:	89 55 14             	mov    %edx,0x14(%ebp)
  800773:	8b 30                	mov    (%eax),%esi
  800775:	89 f7                	mov    %esi,%edi
  800777:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80077a:	85 ff                	test   %edi,%edi
  80077c:	78 0a                	js     800788 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80077e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800783:	e9 8c 00 00 00       	jmp    800814 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800788:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800796:	f7 de                	neg    %esi
  800798:	83 d7 00             	adc    $0x0,%edi
  80079b:	f7 df                	neg    %edi
			}
			base = 10;
  80079d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a2:	eb 70                	jmp    800814 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007a4:	89 ca                	mov    %ecx,%edx
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a9:	e8 c0 fc ff ff       	call   80046e <getuint>
  8007ae:	89 c6                	mov    %eax,%esi
  8007b0:	89 d7                	mov    %edx,%edi
			base = 10;
  8007b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007b7:	eb 5b                	jmp    800814 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8007b9:	89 ca                	mov    %ecx,%edx
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007be:	e8 ab fc ff ff       	call   80046e <getuint>
  8007c3:	89 c6                	mov    %eax,%esi
  8007c5:	89 d7                	mov    %edx,%edi
			base = 8;
  8007c7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007cc:	eb 46                	jmp    800814 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007d9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007e7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8d 50 04             	lea    0x4(%eax),%edx
  8007f0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007f3:	8b 30                	mov    (%eax),%esi
  8007f5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007fa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007ff:	eb 13                	jmp    800814 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800801:	89 ca                	mov    %ecx,%edx
  800803:	8d 45 14             	lea    0x14(%ebp),%eax
  800806:	e8 63 fc ff ff       	call   80046e <getuint>
  80080b:	89 c6                	mov    %eax,%esi
  80080d:	89 d7                	mov    %edx,%edi
			base = 16;
  80080f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800814:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800818:	89 54 24 10          	mov    %edx,0x10(%esp)
  80081c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80081f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800823:	89 44 24 08          	mov    %eax,0x8(%esp)
  800827:	89 34 24             	mov    %esi,(%esp)
  80082a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80082e:	89 da                	mov    %ebx,%edx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	e8 6c fb ff ff       	call   8003a4 <printnum>
			break;
  800838:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80083b:	e9 cd fc ff ff       	jmp    80050d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800840:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800844:	89 04 24             	mov    %eax,(%esp)
  800847:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084d:	e9 bb fc ff ff       	jmp    80050d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800852:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800856:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80085d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800860:	eb 01                	jmp    800863 <vprintfmt+0x379>
  800862:	4e                   	dec    %esi
  800863:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800867:	75 f9                	jne    800862 <vprintfmt+0x378>
  800869:	e9 9f fc ff ff       	jmp    80050d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80086e:	83 c4 4c             	add    $0x4c,%esp
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	5f                   	pop    %edi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	83 ec 28             	sub    $0x28,%esp
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800882:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800885:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800889:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800893:	85 c0                	test   %eax,%eax
  800895:	74 30                	je     8008c7 <vsnprintf+0x51>
  800897:	85 d2                	test   %edx,%edx
  800899:	7e 33                	jle    8008ce <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089b:	8b 45 14             	mov    0x14(%ebp),%eax
  80089e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b0:	c7 04 24 a8 04 80 00 	movl   $0x8004a8,(%esp)
  8008b7:	e8 2e fc ff ff       	call   8004ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c5:	eb 0c                	jmp    8008d3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008cc:	eb 05                	jmp    8008d3 <vsnprintf+0x5d>
  8008ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	89 04 24             	mov    %eax,(%esp)
  8008f6:	e8 7b ff ff ff       	call   800876 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    
  8008fd:	00 00                	add    %al,(%eax)
	...

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	eb 01                	jmp    80090e <strlen+0xe>
		n++;
  80090d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80090e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800912:	75 f9                	jne    80090d <strlen+0xd>
		n++;
	return n;
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
  800924:	eb 01                	jmp    800927 <strnlen+0x11>
		n++;
  800926:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800927:	39 d0                	cmp    %edx,%eax
  800929:	74 06                	je     800931 <strnlen+0x1b>
  80092b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80092f:	75 f5                	jne    800926 <strnlen+0x10>
		n++;
	return n;
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80093d:	ba 00 00 00 00       	mov    $0x0,%edx
  800942:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800945:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800948:	42                   	inc    %edx
  800949:	84 c9                	test   %cl,%cl
  80094b:	75 f5                	jne    800942 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80094d:	5b                   	pop    %ebx
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	53                   	push   %ebx
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80095a:	89 1c 24             	mov    %ebx,(%esp)
  80095d:	e8 9e ff ff ff       	call   800900 <strlen>
	strcpy(dst + len, src);
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
  800965:	89 54 24 04          	mov    %edx,0x4(%esp)
  800969:	01 d8                	add    %ebx,%eax
  80096b:	89 04 24             	mov    %eax,(%esp)
  80096e:	e8 c0 ff ff ff       	call   800933 <strcpy>
	return dst;
}
  800973:	89 d8                	mov    %ebx,%eax
  800975:	83 c4 08             	add    $0x8,%esp
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
  800986:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800989:	b9 00 00 00 00       	mov    $0x0,%ecx
  80098e:	eb 0c                	jmp    80099c <strncpy+0x21>
		*dst++ = *src;
  800990:	8a 1a                	mov    (%edx),%bl
  800992:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800995:	80 3a 01             	cmpb   $0x1,(%edx)
  800998:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099b:	41                   	inc    %ecx
  80099c:	39 f1                	cmp    %esi,%ecx
  80099e:	75 f0                	jne    800990 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009af:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	75 0a                	jne    8009c0 <strlcpy+0x1c>
  8009b6:	89 f0                	mov    %esi,%eax
  8009b8:	eb 1a                	jmp    8009d4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ba:	88 18                	mov    %bl,(%eax)
  8009bc:	40                   	inc    %eax
  8009bd:	41                   	inc    %ecx
  8009be:	eb 02                	jmp    8009c2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009c2:	4a                   	dec    %edx
  8009c3:	74 0a                	je     8009cf <strlcpy+0x2b>
  8009c5:	8a 19                	mov    (%ecx),%bl
  8009c7:	84 db                	test   %bl,%bl
  8009c9:	75 ef                	jne    8009ba <strlcpy+0x16>
  8009cb:	89 c2                	mov    %eax,%edx
  8009cd:	eb 02                	jmp    8009d1 <strlcpy+0x2d>
  8009cf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009d1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009d4:	29 f0                	sub    %esi,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009e3:	eb 02                	jmp    8009e7 <strcmp+0xd>
		p++, q++;
  8009e5:	41                   	inc    %ecx
  8009e6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009e7:	8a 01                	mov    (%ecx),%al
  8009e9:	84 c0                	test   %al,%al
  8009eb:	74 04                	je     8009f1 <strcmp+0x17>
  8009ed:	3a 02                	cmp    (%edx),%al
  8009ef:	74 f4                	je     8009e5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f1:	0f b6 c0             	movzbl %al,%eax
  8009f4:	0f b6 12             	movzbl (%edx),%edx
  8009f7:	29 d0                	sub    %edx,%eax
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a08:	eb 03                	jmp    800a0d <strncmp+0x12>
		n--, p++, q++;
  800a0a:	4a                   	dec    %edx
  800a0b:	40                   	inc    %eax
  800a0c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a0d:	85 d2                	test   %edx,%edx
  800a0f:	74 14                	je     800a25 <strncmp+0x2a>
  800a11:	8a 18                	mov    (%eax),%bl
  800a13:	84 db                	test   %bl,%bl
  800a15:	74 04                	je     800a1b <strncmp+0x20>
  800a17:	3a 19                	cmp    (%ecx),%bl
  800a19:	74 ef                	je     800a0a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1b:	0f b6 00             	movzbl (%eax),%eax
  800a1e:	0f b6 11             	movzbl (%ecx),%edx
  800a21:	29 d0                	sub    %edx,%eax
  800a23:	eb 05                	jmp    800a2a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a36:	eb 05                	jmp    800a3d <strchr+0x10>
		if (*s == c)
  800a38:	38 ca                	cmp    %cl,%dl
  800a3a:	74 0c                	je     800a48 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a3c:	40                   	inc    %eax
  800a3d:	8a 10                	mov    (%eax),%dl
  800a3f:	84 d2                	test   %dl,%dl
  800a41:	75 f5                	jne    800a38 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a53:	eb 05                	jmp    800a5a <strfind+0x10>
		if (*s == c)
  800a55:	38 ca                	cmp    %cl,%dl
  800a57:	74 07                	je     800a60 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a59:	40                   	inc    %eax
  800a5a:	8a 10                	mov    (%eax),%dl
  800a5c:	84 d2                	test   %dl,%dl
  800a5e:	75 f5                	jne    800a55 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a71:	85 c9                	test   %ecx,%ecx
  800a73:	74 30                	je     800aa5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a75:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7b:	75 25                	jne    800aa2 <memset+0x40>
  800a7d:	f6 c1 03             	test   $0x3,%cl
  800a80:	75 20                	jne    800aa2 <memset+0x40>
		c &= 0xFF;
  800a82:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a85:	89 d3                	mov    %edx,%ebx
  800a87:	c1 e3 08             	shl    $0x8,%ebx
  800a8a:	89 d6                	mov    %edx,%esi
  800a8c:	c1 e6 18             	shl    $0x18,%esi
  800a8f:	89 d0                	mov    %edx,%eax
  800a91:	c1 e0 10             	shl    $0x10,%eax
  800a94:	09 f0                	or     %esi,%eax
  800a96:	09 d0                	or     %edx,%eax
  800a98:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a9a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a9d:	fc                   	cld    
  800a9e:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa0:	eb 03                	jmp    800aa5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa2:	fc                   	cld    
  800aa3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa5:	89 f8                	mov    %edi,%eax
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aba:	39 c6                	cmp    %eax,%esi
  800abc:	73 34                	jae    800af2 <memmove+0x46>
  800abe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac1:	39 d0                	cmp    %edx,%eax
  800ac3:	73 2d                	jae    800af2 <memmove+0x46>
		s += n;
		d += n;
  800ac5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac8:	f6 c2 03             	test   $0x3,%dl
  800acb:	75 1b                	jne    800ae8 <memmove+0x3c>
  800acd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad3:	75 13                	jne    800ae8 <memmove+0x3c>
  800ad5:	f6 c1 03             	test   $0x3,%cl
  800ad8:	75 0e                	jne    800ae8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ada:	83 ef 04             	sub    $0x4,%edi
  800add:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ae3:	fd                   	std    
  800ae4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae6:	eb 07                	jmp    800aef <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae8:	4f                   	dec    %edi
  800ae9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aec:	fd                   	std    
  800aed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aef:	fc                   	cld    
  800af0:	eb 20                	jmp    800b12 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af8:	75 13                	jne    800b0d <memmove+0x61>
  800afa:	a8 03                	test   $0x3,%al
  800afc:	75 0f                	jne    800b0d <memmove+0x61>
  800afe:	f6 c1 03             	test   $0x3,%cl
  800b01:	75 0a                	jne    800b0d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b03:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	fc                   	cld    
  800b09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0b:	eb 05                	jmp    800b12 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0d:	89 c7                	mov    %eax,%edi
  800b0f:	fc                   	cld    
  800b10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	89 04 24             	mov    %eax,(%esp)
  800b30:	e8 77 ff ff ff       	call   800aac <memmove>
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	eb 16                	jmp    800b63 <memcmp+0x2c>
		if (*s1 != *s2)
  800b4d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b50:	42                   	inc    %edx
  800b51:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b55:	38 c8                	cmp    %cl,%al
  800b57:	74 0a                	je     800b63 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b59:	0f b6 c0             	movzbl %al,%eax
  800b5c:	0f b6 c9             	movzbl %cl,%ecx
  800b5f:	29 c8                	sub    %ecx,%eax
  800b61:	eb 09                	jmp    800b6c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b63:	39 da                	cmp    %ebx,%edx
  800b65:	75 e6                	jne    800b4d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	8b 45 08             	mov    0x8(%ebp),%eax
  800b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b7a:	89 c2                	mov    %eax,%edx
  800b7c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7f:	eb 05                	jmp    800b86 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b81:	38 08                	cmp    %cl,(%eax)
  800b83:	74 05                	je     800b8a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b85:	40                   	inc    %eax
  800b86:	39 d0                	cmp    %edx,%eax
  800b88:	72 f7                	jb     800b81 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b98:	eb 01                	jmp    800b9b <strtol+0xf>
		s++;
  800b9a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9b:	8a 02                	mov    (%edx),%al
  800b9d:	3c 20                	cmp    $0x20,%al
  800b9f:	74 f9                	je     800b9a <strtol+0xe>
  800ba1:	3c 09                	cmp    $0x9,%al
  800ba3:	74 f5                	je     800b9a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba5:	3c 2b                	cmp    $0x2b,%al
  800ba7:	75 08                	jne    800bb1 <strtol+0x25>
		s++;
  800ba9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800baa:	bf 00 00 00 00       	mov    $0x0,%edi
  800baf:	eb 13                	jmp    800bc4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb1:	3c 2d                	cmp    $0x2d,%al
  800bb3:	75 0a                	jne    800bbf <strtol+0x33>
		s++, neg = 1;
  800bb5:	8d 52 01             	lea    0x1(%edx),%edx
  800bb8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bbd:	eb 05                	jmp    800bc4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bbf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc4:	85 db                	test   %ebx,%ebx
  800bc6:	74 05                	je     800bcd <strtol+0x41>
  800bc8:	83 fb 10             	cmp    $0x10,%ebx
  800bcb:	75 28                	jne    800bf5 <strtol+0x69>
  800bcd:	8a 02                	mov    (%edx),%al
  800bcf:	3c 30                	cmp    $0x30,%al
  800bd1:	75 10                	jne    800be3 <strtol+0x57>
  800bd3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd7:	75 0a                	jne    800be3 <strtol+0x57>
		s += 2, base = 16;
  800bd9:	83 c2 02             	add    $0x2,%edx
  800bdc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be1:	eb 12                	jmp    800bf5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800be3:	85 db                	test   %ebx,%ebx
  800be5:	75 0e                	jne    800bf5 <strtol+0x69>
  800be7:	3c 30                	cmp    $0x30,%al
  800be9:	75 05                	jne    800bf0 <strtol+0x64>
		s++, base = 8;
  800beb:	42                   	inc    %edx
  800bec:	b3 08                	mov    $0x8,%bl
  800bee:	eb 05                	jmp    800bf5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bf0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bfc:	8a 0a                	mov    (%edx),%cl
  800bfe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c01:	80 fb 09             	cmp    $0x9,%bl
  800c04:	77 08                	ja     800c0e <strtol+0x82>
			dig = *s - '0';
  800c06:	0f be c9             	movsbl %cl,%ecx
  800c09:	83 e9 30             	sub    $0x30,%ecx
  800c0c:	eb 1e                	jmp    800c2c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c11:	80 fb 19             	cmp    $0x19,%bl
  800c14:	77 08                	ja     800c1e <strtol+0x92>
			dig = *s - 'a' + 10;
  800c16:	0f be c9             	movsbl %cl,%ecx
  800c19:	83 e9 57             	sub    $0x57,%ecx
  800c1c:	eb 0e                	jmp    800c2c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c21:	80 fb 19             	cmp    $0x19,%bl
  800c24:	77 12                	ja     800c38 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c26:	0f be c9             	movsbl %cl,%ecx
  800c29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c2c:	39 f1                	cmp    %esi,%ecx
  800c2e:	7d 0c                	jge    800c3c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c30:	42                   	inc    %edx
  800c31:	0f af c6             	imul   %esi,%eax
  800c34:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c36:	eb c4                	jmp    800bfc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c38:	89 c1                	mov    %eax,%ecx
  800c3a:	eb 02                	jmp    800c3e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c3c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c42:	74 05                	je     800c49 <strtol+0xbd>
		*endptr = (char *) s;
  800c44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c47:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c49:	85 ff                	test   %edi,%edi
  800c4b:	74 04                	je     800c51 <strtol+0xc5>
  800c4d:	89 c8                	mov    %ecx,%eax
  800c4f:	f7 d8                	neg    %eax
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    
	...

00800c58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	89 c3                	mov    %eax,%ebx
  800c6b:	89 c7                	mov    %eax,%edi
  800c6d:	89 c6                	mov    %eax,%esi
  800c6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c81:	b8 01 00 00 00       	mov    $0x1,%eax
  800c86:	89 d1                	mov    %edx,%ecx
  800c88:	89 d3                	mov    %edx,%ebx
  800c8a:	89 d7                	mov    %edx,%edi
  800c8c:	89 d6                	mov    %edx,%esi
  800c8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	89 cb                	mov    %ecx,%ebx
  800cad:	89 cf                	mov    %ecx,%edi
  800caf:	89 ce                	mov    %ecx,%esi
  800cb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800cda:	e8 b1 f5 ff ff       	call   800290 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf7:	89 d1                	mov    %edx,%ecx
  800cf9:	89 d3                	mov    %edx,%ebx
  800cfb:	89 d7                	mov    %edx,%edi
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_yield>:

void
sys_yield(void)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d16:	89 d1                	mov    %edx,%ecx
  800d18:	89 d3                	mov    %edx,%ebx
  800d1a:	89 d7                	mov    %edx,%edi
  800d1c:	89 d6                	mov    %edx,%esi
  800d1e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	be 00 00 00 00       	mov    $0x0,%esi
  800d33:	b8 04 00 00 00       	mov    $0x4,%eax
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	89 f7                	mov    %esi,%edi
  800d43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 28                	jle    800d71 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d54:	00 
  800d55:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d64:	00 
  800d65:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800d6c:	e8 1f f5 ff ff       	call   800290 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d71:	83 c4 2c             	add    $0x2c,%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	b8 05 00 00 00       	mov    $0x5,%eax
  800d87:	8b 75 18             	mov    0x18(%ebp),%esi
  800d8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 28                	jle    800dc4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800da7:	00 
  800da8:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800daf:	00 
  800db0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db7:	00 
  800db8:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800dbf:	e8 cc f4 ff ff       	call   800290 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc4:	83 c4 2c             	add    $0x2c,%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dda:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 df                	mov    %ebx,%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 28                	jle    800e17 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800e02:	00 
  800e03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0a:	00 
  800e0b:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800e12:	e8 79 f4 ff ff       	call   800290 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e17:	83 c4 2c             	add    $0x2c,%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	89 df                	mov    %ebx,%edi
  800e3a:	89 de                	mov    %ebx,%esi
  800e3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7e 28                	jle    800e6a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e46:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800e55:	00 
  800e56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5d:	00 
  800e5e:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800e65:	e8 26 f4 ff ff       	call   800290 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e6a:	83 c4 2c             	add    $0x2c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e80:	b8 09 00 00 00       	mov    $0x9,%eax
  800e85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e88:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8b:	89 df                	mov    %ebx,%edi
  800e8d:	89 de                	mov    %ebx,%esi
  800e8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e91:	85 c0                	test   %eax,%eax
  800e93:	7e 28                	jle    800ebd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e99:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb0:	00 
  800eb1:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800eb8:	e8 d3 f3 ff ff       	call   800290 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ebd:	83 c4 2c             	add    $0x2c,%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	57                   	push   %edi
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
  800ecb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ece:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	89 df                	mov    %ebx,%edi
  800ee0:	89 de                	mov    %ebx,%esi
  800ee2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 28                	jle    800f10 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eec:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800efb:	00 
  800efc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f03:	00 
  800f04:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800f0b:	e8 80 f3 ff ff       	call   800290 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f10:	83 c4 2c             	add    $0x2c,%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	57                   	push   %edi
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1e:	be 00 00 00 00       	mov    $0x0,%esi
  800f23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f31:	8b 55 08             	mov    0x8(%ebp),%edx
  800f34:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	57                   	push   %edi
  800f3f:	56                   	push   %esi
  800f40:	53                   	push   %ebx
  800f41:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f51:	89 cb                	mov    %ecx,%ebx
  800f53:	89 cf                	mov    %ecx,%edi
  800f55:	89 ce                	mov    %ecx,%esi
  800f57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	7e 28                	jle    800f85 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f61:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f68:	00 
  800f69:	c7 44 24 08 1f 2c 80 	movl   $0x802c1f,0x8(%esp)
  800f70:	00 
  800f71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f78:	00 
  800f79:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  800f80:	e8 0b f3 ff ff       	call   800290 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f85:	83 c4 2c             	add    $0x2c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	00 00                	add    %al,(%eax)
	...

00800f90 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 3c             	sub    $0x3c,%esp
  800f99:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800f9c:	89 d6                	mov    %edx,%esi
  800f9e:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800fa1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800fab:	e8 37 fd ff ff       	call   800ce7 <sys_getenvid>
  800fb0:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800fb2:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800fb9:	74 31                	je     800fec <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800fbb:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800fc2:	00 
  800fc3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fce:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd2:	89 3c 24             	mov    %edi,(%esp)
  800fd5:	e8 9f fd ff ff       	call   800d79 <sys_page_map>
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	0f 8e ae 00 00 00    	jle    801090 <duppage+0x100>
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe7:	e9 a4 00 00 00       	jmp    801090 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800fec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fef:	25 02 08 00 00       	and    $0x802,%eax
  800ff4:	83 f8 01             	cmp    $0x1,%eax
  800ff7:	19 db                	sbb    %ebx,%ebx
  800ff9:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800fff:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  801005:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801009:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80100d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801010:	89 44 24 08          	mov    %eax,0x8(%esp)
  801014:	89 74 24 04          	mov    %esi,0x4(%esp)
  801018:	89 3c 24             	mov    %edi,(%esp)
  80101b:	e8 59 fd ff ff       	call   800d79 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  801020:	85 c0                	test   %eax,%eax
  801022:	79 1c                	jns    801040 <duppage+0xb0>
  801024:	c7 44 24 08 4a 2c 80 	movl   $0x802c4a,0x8(%esp)
  80102b:	00 
  80102c:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801033:	00 
  801034:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  80103b:	e8 50 f2 ff ff       	call   800290 <_panic>
	if ((perm|~pte)&PTE_COW){
  801040:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801043:	f7 d0                	not    %eax
  801045:	09 d8                	or     %ebx,%eax
  801047:	f6 c4 08             	test   $0x8,%ah
  80104a:	74 38                	je     801084 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  80104c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801050:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801054:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801058:	89 74 24 04          	mov    %esi,0x4(%esp)
  80105c:	89 3c 24             	mov    %edi,(%esp)
  80105f:	e8 15 fd ff ff       	call   800d79 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  801064:	85 c0                	test   %eax,%eax
  801066:	79 23                	jns    80108b <duppage+0xfb>
  801068:	c7 44 24 08 4a 2c 80 	movl   $0x802c4a,0x8(%esp)
  80106f:	00 
  801070:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801077:	00 
  801078:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  80107f:	e8 0c f2 ff ff       	call   800290 <_panic>
	}
	return 0;
  801084:	b8 00 00 00 00       	mov    $0x0,%eax
  801089:	eb 05                	jmp    801090 <duppage+0x100>
  80108b:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  801090:	83 c4 3c             	add    $0x3c,%esp
  801093:	5b                   	pop    %ebx
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    

00801098 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
  80109d:	83 ec 20             	sub    $0x20,%esp
  8010a0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010a3:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  8010a5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010a9:	75 1c                	jne    8010c7 <pgfault+0x2f>
		panic("pgfault: error!\n");
  8010ab:	c7 44 24 08 66 2c 80 	movl   $0x802c66,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  8010c2:	e8 c9 f1 ff ff       	call   800290 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  8010c7:	89 f0                	mov    %esi,%eax
  8010c9:	c1 e8 0c             	shr    $0xc,%eax
  8010cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d3:	f6 c4 08             	test   $0x8,%ah
  8010d6:	75 1c                	jne    8010f4 <pgfault+0x5c>
		panic("pgfault: error!\n");
  8010d8:	c7 44 24 08 66 2c 80 	movl   $0x802c66,0x8(%esp)
  8010df:	00 
  8010e0:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8010e7:	00 
  8010e8:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  8010ef:	e8 9c f1 ff ff       	call   800290 <_panic>
	envid_t envid = sys_getenvid();
  8010f4:	e8 ee fb ff ff       	call   800ce7 <sys_getenvid>
  8010f9:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  8010fb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801102:	00 
  801103:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80110a:	00 
  80110b:	89 04 24             	mov    %eax,(%esp)
  80110e:	e8 12 fc ff ff       	call   800d25 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  801113:	85 c0                	test   %eax,%eax
  801115:	79 1c                	jns    801133 <pgfault+0x9b>
  801117:	c7 44 24 08 66 2c 80 	movl   $0x802c66,0x8(%esp)
  80111e:	00 
  80111f:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801126:	00 
  801127:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  80112e:	e8 5d f1 ff ff       	call   800290 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  801133:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  801139:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801140:	00 
  801141:	89 74 24 04          	mov    %esi,0x4(%esp)
  801145:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80114c:	e8 c5 f9 ff ff       	call   800b16 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  801151:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801158:	00 
  801159:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80115d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801161:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801168:	00 
  801169:	89 1c 24             	mov    %ebx,(%esp)
  80116c:	e8 08 fc ff ff       	call   800d79 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801171:	85 c0                	test   %eax,%eax
  801173:	79 1c                	jns    801191 <pgfault+0xf9>
  801175:	c7 44 24 08 66 2c 80 	movl   $0x802c66,0x8(%esp)
  80117c:	00 
  80117d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801184:	00 
  801185:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  80118c:	e8 ff f0 ff ff       	call   800290 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801191:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801198:	00 
  801199:	89 1c 24             	mov    %ebx,(%esp)
  80119c:	e8 2b fc ff ff       	call   800dcc <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	79 1c                	jns    8011c1 <pgfault+0x129>
  8011a5:	c7 44 24 08 66 2c 80 	movl   $0x802c66,0x8(%esp)
  8011ac:	00 
  8011ad:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8011b4:	00 
  8011b5:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  8011bc:	e8 cf f0 ff ff       	call   800290 <_panic>
	return;
	panic("pgfault not implemented");
}
  8011c1:	83 c4 20             	add    $0x20,%esp
  8011c4:	5b                   	pop    %ebx
  8011c5:	5e                   	pop    %esi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	57                   	push   %edi
  8011cc:	56                   	push   %esi
  8011cd:	53                   	push   %ebx
  8011ce:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8011d1:	c7 04 24 98 10 80 00 	movl   $0x801098,(%esp)
  8011d8:	e8 77 11 00 00       	call   802354 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8011dd:	bf 07 00 00 00       	mov    $0x7,%edi
  8011e2:	89 f8                	mov    %edi,%eax
  8011e4:	cd 30                	int    $0x30
  8011e6:	89 c7                	mov    %eax,%edi
  8011e8:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	79 1c                	jns    80120a <fork+0x42>
		panic("fork : error!\n");
  8011ee:	c7 44 24 08 83 2c 80 	movl   $0x802c83,0x8(%esp)
  8011f5:	00 
  8011f6:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  8011fd:	00 
  8011fe:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  801205:	e8 86 f0 ff ff       	call   800290 <_panic>
	if (envid==0){
  80120a:	85 c0                	test   %eax,%eax
  80120c:	75 28                	jne    801236 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  80120e:	8b 1d 20 44 80 00    	mov    0x804420,%ebx
  801214:	e8 ce fa ff ff       	call   800ce7 <sys_getenvid>
  801219:	25 ff 03 00 00       	and    $0x3ff,%eax
  80121e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801225:	c1 e0 07             	shl    $0x7,%eax
  801228:	29 d0                	sub    %edx,%eax
  80122a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80122f:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  801231:	e9 f2 00 00 00       	jmp    801328 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  801236:	e8 ac fa ff ff       	call   800ce7 <sys_getenvid>
  80123b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80123e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  801243:	89 d8                	mov    %ebx,%eax
  801245:	c1 e8 16             	shr    $0x16,%eax
  801248:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80124f:	a8 01                	test   $0x1,%al
  801251:	74 17                	je     80126a <fork+0xa2>
  801253:	89 da                	mov    %ebx,%edx
  801255:	c1 ea 0c             	shr    $0xc,%edx
  801258:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80125f:	a8 01                	test   $0x1,%al
  801261:	74 07                	je     80126a <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801263:	89 f0                	mov    %esi,%eax
  801265:	e8 26 fd ff ff       	call   800f90 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80126a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801270:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801276:	75 cb                	jne    801243 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801278:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80127f:	00 
  801280:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801287:	ee 
  801288:	89 3c 24             	mov    %edi,(%esp)
  80128b:	e8 95 fa ff ff       	call   800d25 <sys_page_alloc>
  801290:	85 c0                	test   %eax,%eax
  801292:	79 1c                	jns    8012b0 <fork+0xe8>
  801294:	c7 44 24 08 83 2c 80 	movl   $0x802c83,0x8(%esp)
  80129b:	00 
  80129c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8012a3:	00 
  8012a4:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  8012ab:	e8 e0 ef ff ff       	call   800290 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  8012b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8012bf:	c1 e0 07             	shl    $0x7,%eax
  8012c2:	29 d0                	sub    %edx,%eax
  8012c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012c9:	8b 40 64             	mov    0x64(%eax),%eax
  8012cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d0:	89 3c 24             	mov    %edi,(%esp)
  8012d3:	e8 ed fb ff ff       	call   800ec5 <sys_env_set_pgfault_upcall>
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	79 1c                	jns    8012f8 <fork+0x130>
  8012dc:	c7 44 24 08 83 2c 80 	movl   $0x802c83,0x8(%esp)
  8012e3:	00 
  8012e4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8012eb:	00 
  8012ec:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  8012f3:	e8 98 ef ff ff       	call   800290 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8012f8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012ff:	00 
  801300:	89 3c 24             	mov    %edi,(%esp)
  801303:	e8 17 fb ff ff       	call   800e1f <sys_env_set_status>
  801308:	85 c0                	test   %eax,%eax
  80130a:	79 1c                	jns    801328 <fork+0x160>
  80130c:	c7 44 24 08 83 2c 80 	movl   $0x802c83,0x8(%esp)
  801313:	00 
  801314:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  80131b:	00 
  80131c:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  801323:	e8 68 ef ff ff       	call   800290 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801328:	89 f8                	mov    %edi,%eax
  80132a:	83 c4 2c             	add    $0x2c,%esp
  80132d:	5b                   	pop    %ebx
  80132e:	5e                   	pop    %esi
  80132f:	5f                   	pop    %edi
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <sfork>:

// Challenge!
int
sfork(void)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	57                   	push   %edi
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
  801338:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  80133b:	c7 04 24 98 10 80 00 	movl   $0x801098,(%esp)
  801342:	e8 0d 10 00 00       	call   802354 <set_pgfault_handler>
  801347:	ba 07 00 00 00       	mov    $0x7,%edx
  80134c:	89 d0                	mov    %edx,%eax
  80134e:	cd 30                	int    $0x30
  801350:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801353:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801355:	89 44 24 04          	mov    %eax,0x4(%esp)
  801359:	c7 04 24 77 2c 80 00 	movl   $0x802c77,(%esp)
  801360:	e8 23 f0 ff ff       	call   800388 <cprintf>
	if (envid<0)
  801365:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801369:	79 1c                	jns    801387 <sfork+0x55>
		panic("sfork : error!\n");
  80136b:	c7 44 24 08 82 2c 80 	movl   $0x802c82,0x8(%esp)
  801372:	00 
  801373:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  80137a:	00 
  80137b:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  801382:	e8 09 ef ff ff       	call   800290 <_panic>
	if (envid==0){
  801387:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80138b:	75 28                	jne    8013b5 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  80138d:	8b 1d 20 44 80 00    	mov    0x804420,%ebx
  801393:	e8 4f f9 ff ff       	call   800ce7 <sys_getenvid>
  801398:	25 ff 03 00 00       	and    $0x3ff,%eax
  80139d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013a4:	c1 e0 07             	shl    $0x7,%eax
  8013a7:	29 d0                	sub    %edx,%eax
  8013a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013ae:	89 03                	mov    %eax,(%ebx)
		return envid;
  8013b0:	e9 18 01 00 00       	jmp    8014cd <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  8013b5:	e8 2d f9 ff ff       	call   800ce7 <sys_getenvid>
  8013ba:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8013bc:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8013c1:	89 d8                	mov    %ebx,%eax
  8013c3:	c1 e8 16             	shr    $0x16,%eax
  8013c6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cd:	a8 01                	test   $0x1,%al
  8013cf:	74 2c                	je     8013fd <sfork+0xcb>
  8013d1:	89 d8                	mov    %ebx,%eax
  8013d3:	c1 e8 0c             	shr    $0xc,%eax
  8013d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013dd:	a8 01                	test   $0x1,%al
  8013df:	74 1c                	je     8013fd <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8013e1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013e8:	00 
  8013e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013ed:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013f5:	89 3c 24             	mov    %edi,(%esp)
  8013f8:	e8 7c f9 ff ff       	call   800d79 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8013fd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801403:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801409:	75 b6                	jne    8013c1 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  80140b:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801410:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801413:	e8 78 fb ff ff       	call   800f90 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801418:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80141f:	00 
  801420:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801427:	ee 
  801428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80142b:	89 04 24             	mov    %eax,(%esp)
  80142e:	e8 f2 f8 ff ff       	call   800d25 <sys_page_alloc>
  801433:	85 c0                	test   %eax,%eax
  801435:	79 1c                	jns    801453 <sfork+0x121>
  801437:	c7 44 24 08 82 2c 80 	movl   $0x802c82,0x8(%esp)
  80143e:	00 
  80143f:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  801446:	00 
  801447:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  80144e:	e8 3d ee ff ff       	call   800290 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  801453:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801459:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801460:	c1 e7 07             	shl    $0x7,%edi
  801463:	29 d7                	sub    %edx,%edi
  801465:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80146b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801472:	89 04 24             	mov    %eax,(%esp)
  801475:	e8 4b fa ff ff       	call   800ec5 <sys_env_set_pgfault_upcall>
  80147a:	85 c0                	test   %eax,%eax
  80147c:	79 1c                	jns    80149a <sfork+0x168>
  80147e:	c7 44 24 08 82 2c 80 	movl   $0x802c82,0x8(%esp)
  801485:	00 
  801486:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  80148d:	00 
  80148e:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  801495:	e8 f6 ed ff ff       	call   800290 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  80149a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8014a1:	00 
  8014a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a5:	89 04 24             	mov    %eax,(%esp)
  8014a8:	e8 72 f9 ff ff       	call   800e1f <sys_env_set_status>
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	79 1c                	jns    8014cd <sfork+0x19b>
  8014b1:	c7 44 24 08 82 2c 80 	movl   $0x802c82,0x8(%esp)
  8014b8:	00 
  8014b9:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8014c0:	00 
  8014c1:	c7 04 24 5b 2c 80 00 	movl   $0x802c5b,(%esp)
  8014c8:	e8 c3 ed ff ff       	call   800290 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8014cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d0:	83 c4 3c             	add    $0x3c,%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5e                   	pop    %esi
  8014d5:	5f                   	pop    %edi
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014db:	8b 45 08             	mov    0x8(%ebp),%eax
  8014de:	05 00 00 00 30       	add    $0x30000000,%eax
  8014e3:	c1 e8 0c             	shr    $0xc,%eax
}
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f1:	89 04 24             	mov    %eax,(%esp)
  8014f4:	e8 df ff ff ff       	call   8014d8 <fd2num>
  8014f9:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014fe:	c1 e0 0c             	shl    $0xc,%eax
}
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80150a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80150f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801511:	89 c2                	mov    %eax,%edx
  801513:	c1 ea 16             	shr    $0x16,%edx
  801516:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80151d:	f6 c2 01             	test   $0x1,%dl
  801520:	74 11                	je     801533 <fd_alloc+0x30>
  801522:	89 c2                	mov    %eax,%edx
  801524:	c1 ea 0c             	shr    $0xc,%edx
  801527:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80152e:	f6 c2 01             	test   $0x1,%dl
  801531:	75 09                	jne    80153c <fd_alloc+0x39>
			*fd_store = fd;
  801533:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801535:	b8 00 00 00 00       	mov    $0x0,%eax
  80153a:	eb 17                	jmp    801553 <fd_alloc+0x50>
  80153c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801541:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801546:	75 c7                	jne    80150f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801548:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80154e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801553:	5b                   	pop    %ebx
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80155c:	83 f8 1f             	cmp    $0x1f,%eax
  80155f:	77 36                	ja     801597 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801561:	05 00 00 0d 00       	add    $0xd0000,%eax
  801566:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801569:	89 c2                	mov    %eax,%edx
  80156b:	c1 ea 16             	shr    $0x16,%edx
  80156e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801575:	f6 c2 01             	test   $0x1,%dl
  801578:	74 24                	je     80159e <fd_lookup+0x48>
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	c1 ea 0c             	shr    $0xc,%edx
  80157f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801586:	f6 c2 01             	test   $0x1,%dl
  801589:	74 1a                	je     8015a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80158b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158e:	89 02                	mov    %eax,(%edx)
	return 0;
  801590:	b8 00 00 00 00       	mov    $0x0,%eax
  801595:	eb 13                	jmp    8015aa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159c:	eb 0c                	jmp    8015aa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80159e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a3:	eb 05                	jmp    8015aa <fd_lookup+0x54>
  8015a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 14             	sub    $0x14,%esp
  8015b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8015b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015be:	eb 0e                	jmp    8015ce <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8015c0:	39 08                	cmp    %ecx,(%eax)
  8015c2:	75 09                	jne    8015cd <dev_lookup+0x21>
			*dev = devtab[i];
  8015c4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cb:	eb 35                	jmp    801602 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015cd:	42                   	inc    %edx
  8015ce:	8b 04 95 10 2d 80 00 	mov    0x802d10(,%edx,4),%eax
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	75 e7                	jne    8015c0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015d9:	a1 20 44 80 00       	mov    0x804420,%eax
  8015de:	8b 00                	mov    (%eax),%eax
  8015e0:	8b 40 48             	mov    0x48(%eax),%eax
  8015e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	c7 04 24 94 2c 80 00 	movl   $0x802c94,(%esp)
  8015f2:	e8 91 ed ff ff       	call   800388 <cprintf>
	*dev = 0;
  8015f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801602:	83 c4 14             	add    $0x14,%esp
  801605:	5b                   	pop    %ebx
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	83 ec 30             	sub    $0x30,%esp
  801610:	8b 75 08             	mov    0x8(%ebp),%esi
  801613:	8a 45 0c             	mov    0xc(%ebp),%al
  801616:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801619:	89 34 24             	mov    %esi,(%esp)
  80161c:	e8 b7 fe ff ff       	call   8014d8 <fd2num>
  801621:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801624:	89 54 24 04          	mov    %edx,0x4(%esp)
  801628:	89 04 24             	mov    %eax,(%esp)
  80162b:	e8 26 ff ff ff       	call   801556 <fd_lookup>
  801630:	89 c3                	mov    %eax,%ebx
  801632:	85 c0                	test   %eax,%eax
  801634:	78 05                	js     80163b <fd_close+0x33>
	    || fd != fd2)
  801636:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801639:	74 0d                	je     801648 <fd_close+0x40>
		return (must_exist ? r : 0);
  80163b:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80163f:	75 46                	jne    801687 <fd_close+0x7f>
  801641:	bb 00 00 00 00       	mov    $0x0,%ebx
  801646:	eb 3f                	jmp    801687 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164f:	8b 06                	mov    (%esi),%eax
  801651:	89 04 24             	mov    %eax,(%esp)
  801654:	e8 53 ff ff ff       	call   8015ac <dev_lookup>
  801659:	89 c3                	mov    %eax,%ebx
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 18                	js     801677 <fd_close+0x6f>
		if (dev->dev_close)
  80165f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801662:	8b 40 10             	mov    0x10(%eax),%eax
  801665:	85 c0                	test   %eax,%eax
  801667:	74 09                	je     801672 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801669:	89 34 24             	mov    %esi,(%esp)
  80166c:	ff d0                	call   *%eax
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	eb 05                	jmp    801677 <fd_close+0x6f>
		else
			r = 0;
  801672:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801677:	89 74 24 04          	mov    %esi,0x4(%esp)
  80167b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801682:	e8 45 f7 ff ff       	call   800dcc <sys_page_unmap>
	return r;
}
  801687:	89 d8                	mov    %ebx,%eax
  801689:	83 c4 30             	add    $0x30,%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5e                   	pop    %esi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169d:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a0:	89 04 24             	mov    %eax,(%esp)
  8016a3:	e8 ae fe ff ff       	call   801556 <fd_lookup>
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	78 13                	js     8016bf <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016b3:	00 
  8016b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b7:	89 04 24             	mov    %eax,(%esp)
  8016ba:	e8 49 ff ff ff       	call   801608 <fd_close>
}
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <close_all>:

void
close_all(void)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016c8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016cd:	89 1c 24             	mov    %ebx,(%esp)
  8016d0:	e8 bb ff ff ff       	call   801690 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016d5:	43                   	inc    %ebx
  8016d6:	83 fb 20             	cmp    $0x20,%ebx
  8016d9:	75 f2                	jne    8016cd <close_all+0xc>
		close(i);
}
  8016db:	83 c4 14             	add    $0x14,%esp
  8016de:	5b                   	pop    %ebx
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	57                   	push   %edi
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 4c             	sub    $0x4c,%esp
  8016ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f7:	89 04 24             	mov    %eax,(%esp)
  8016fa:	e8 57 fe ff ff       	call   801556 <fd_lookup>
  8016ff:	89 c3                	mov    %eax,%ebx
  801701:	85 c0                	test   %eax,%eax
  801703:	0f 88 e1 00 00 00    	js     8017ea <dup+0x109>
		return r;
	close(newfdnum);
  801709:	89 3c 24             	mov    %edi,(%esp)
  80170c:	e8 7f ff ff ff       	call   801690 <close>

	newfd = INDEX2FD(newfdnum);
  801711:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801717:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80171a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171d:	89 04 24             	mov    %eax,(%esp)
  801720:	e8 c3 fd ff ff       	call   8014e8 <fd2data>
  801725:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801727:	89 34 24             	mov    %esi,(%esp)
  80172a:	e8 b9 fd ff ff       	call   8014e8 <fd2data>
  80172f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801732:	89 d8                	mov    %ebx,%eax
  801734:	c1 e8 16             	shr    $0x16,%eax
  801737:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80173e:	a8 01                	test   $0x1,%al
  801740:	74 46                	je     801788 <dup+0xa7>
  801742:	89 d8                	mov    %ebx,%eax
  801744:	c1 e8 0c             	shr    $0xc,%eax
  801747:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80174e:	f6 c2 01             	test   $0x1,%dl
  801751:	74 35                	je     801788 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801753:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80175a:	25 07 0e 00 00       	and    $0xe07,%eax
  80175f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801763:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801766:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80176a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801771:	00 
  801772:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801776:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80177d:	e8 f7 f5 ff ff       	call   800d79 <sys_page_map>
  801782:	89 c3                	mov    %eax,%ebx
  801784:	85 c0                	test   %eax,%eax
  801786:	78 3b                	js     8017c3 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801788:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	c1 ea 0c             	shr    $0xc,%edx
  801790:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801797:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80179d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017a1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ac:	00 
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b8:	e8 bc f5 ff ff       	call   800d79 <sys_page_map>
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	79 25                	jns    8017e8 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ce:	e8 f9 f5 ff ff       	call   800dcc <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e1:	e8 e6 f5 ff ff       	call   800dcc <sys_page_unmap>
	return r;
  8017e6:	eb 02                	jmp    8017ea <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017e8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017ea:	89 d8                	mov    %ebx,%eax
  8017ec:	83 c4 4c             	add    $0x4c,%esp
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5f                   	pop    %edi
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	53                   	push   %ebx
  8017f8:	83 ec 24             	sub    $0x24,%esp
  8017fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801801:	89 44 24 04          	mov    %eax,0x4(%esp)
  801805:	89 1c 24             	mov    %ebx,(%esp)
  801808:	e8 49 fd ff ff       	call   801556 <fd_lookup>
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 6f                	js     801880 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801814:	89 44 24 04          	mov    %eax,0x4(%esp)
  801818:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181b:	8b 00                	mov    (%eax),%eax
  80181d:	89 04 24             	mov    %eax,(%esp)
  801820:	e8 87 fd ff ff       	call   8015ac <dev_lookup>
  801825:	85 c0                	test   %eax,%eax
  801827:	78 57                	js     801880 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182c:	8b 50 08             	mov    0x8(%eax),%edx
  80182f:	83 e2 03             	and    $0x3,%edx
  801832:	83 fa 01             	cmp    $0x1,%edx
  801835:	75 25                	jne    80185c <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801837:	a1 20 44 80 00       	mov    0x804420,%eax
  80183c:	8b 00                	mov    (%eax),%eax
  80183e:	8b 40 48             	mov    0x48(%eax),%eax
  801841:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801845:	89 44 24 04          	mov    %eax,0x4(%esp)
  801849:	c7 04 24 d5 2c 80 00 	movl   $0x802cd5,(%esp)
  801850:	e8 33 eb ff ff       	call   800388 <cprintf>
		return -E_INVAL;
  801855:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185a:	eb 24                	jmp    801880 <read+0x8c>
	}
	if (!dev->dev_read)
  80185c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185f:	8b 52 08             	mov    0x8(%edx),%edx
  801862:	85 d2                	test   %edx,%edx
  801864:	74 15                	je     80187b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801866:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801869:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80186d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801870:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801874:	89 04 24             	mov    %eax,(%esp)
  801877:	ff d2                	call   *%edx
  801879:	eb 05                	jmp    801880 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80187b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801880:	83 c4 24             	add    $0x24,%esp
  801883:	5b                   	pop    %ebx
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	57                   	push   %edi
  80188a:	56                   	push   %esi
  80188b:	53                   	push   %ebx
  80188c:	83 ec 1c             	sub    $0x1c,%esp
  80188f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801892:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801895:	bb 00 00 00 00       	mov    $0x0,%ebx
  80189a:	eb 23                	jmp    8018bf <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80189c:	89 f0                	mov    %esi,%eax
  80189e:	29 d8                	sub    %ebx,%eax
  8018a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a7:	01 d8                	add    %ebx,%eax
  8018a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ad:	89 3c 24             	mov    %edi,(%esp)
  8018b0:	e8 3f ff ff ff       	call   8017f4 <read>
		if (m < 0)
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 10                	js     8018c9 <readn+0x43>
			return m;
		if (m == 0)
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	74 0a                	je     8018c7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018bd:	01 c3                	add    %eax,%ebx
  8018bf:	39 f3                	cmp    %esi,%ebx
  8018c1:	72 d9                	jb     80189c <readn+0x16>
  8018c3:	89 d8                	mov    %ebx,%eax
  8018c5:	eb 02                	jmp    8018c9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018c7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018c9:	83 c4 1c             	add    $0x1c,%esp
  8018cc:	5b                   	pop    %ebx
  8018cd:	5e                   	pop    %esi
  8018ce:	5f                   	pop    %edi
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    

008018d1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	53                   	push   %ebx
  8018d5:	83 ec 24             	sub    $0x24,%esp
  8018d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	89 1c 24             	mov    %ebx,(%esp)
  8018e5:	e8 6c fc ff ff       	call   801556 <fd_lookup>
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 6a                	js     801958 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f8:	8b 00                	mov    (%eax),%eax
  8018fa:	89 04 24             	mov    %eax,(%esp)
  8018fd:	e8 aa fc ff ff       	call   8015ac <dev_lookup>
  801902:	85 c0                	test   %eax,%eax
  801904:	78 52                	js     801958 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801906:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801909:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80190d:	75 25                	jne    801934 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80190f:	a1 20 44 80 00       	mov    0x804420,%eax
  801914:	8b 00                	mov    (%eax),%eax
  801916:	8b 40 48             	mov    0x48(%eax),%eax
  801919:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	c7 04 24 f1 2c 80 00 	movl   $0x802cf1,(%esp)
  801928:	e8 5b ea ff ff       	call   800388 <cprintf>
		return -E_INVAL;
  80192d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801932:	eb 24                	jmp    801958 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801934:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801937:	8b 52 0c             	mov    0xc(%edx),%edx
  80193a:	85 d2                	test   %edx,%edx
  80193c:	74 15                	je     801953 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80193e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801941:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801945:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801948:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80194c:	89 04 24             	mov    %eax,(%esp)
  80194f:	ff d2                	call   *%edx
  801951:	eb 05                	jmp    801958 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801953:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801958:	83 c4 24             	add    $0x24,%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <seek>:

int
seek(int fdnum, off_t offset)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801964:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801967:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196b:	8b 45 08             	mov    0x8(%ebp),%eax
  80196e:	89 04 24             	mov    %eax,(%esp)
  801971:	e8 e0 fb ff ff       	call   801556 <fd_lookup>
  801976:	85 c0                	test   %eax,%eax
  801978:	78 0e                	js     801988 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80197a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80197d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801980:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	53                   	push   %ebx
  80198e:	83 ec 24             	sub    $0x24,%esp
  801991:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801994:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199b:	89 1c 24             	mov    %ebx,(%esp)
  80199e:	e8 b3 fb ff ff       	call   801556 <fd_lookup>
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	78 63                	js     801a0a <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b1:	8b 00                	mov    (%eax),%eax
  8019b3:	89 04 24             	mov    %eax,(%esp)
  8019b6:	e8 f1 fb ff ff       	call   8015ac <dev_lookup>
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 4b                	js     801a0a <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019c6:	75 25                	jne    8019ed <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019c8:	a1 20 44 80 00       	mov    0x804420,%eax
  8019cd:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019cf:	8b 40 48             	mov    0x48(%eax),%eax
  8019d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019da:	c7 04 24 b4 2c 80 00 	movl   $0x802cb4,(%esp)
  8019e1:	e8 a2 e9 ff ff       	call   800388 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019eb:	eb 1d                	jmp    801a0a <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8019ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f0:	8b 52 18             	mov    0x18(%edx),%edx
  8019f3:	85 d2                	test   %edx,%edx
  8019f5:	74 0e                	je     801a05 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	ff d2                	call   *%edx
  801a03:	eb 05                	jmp    801a0a <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a05:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a0a:	83 c4 24             	add    $0x24,%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	53                   	push   %ebx
  801a14:	83 ec 24             	sub    $0x24,%esp
  801a17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	89 04 24             	mov    %eax,(%esp)
  801a27:	e8 2a fb ff ff       	call   801556 <fd_lookup>
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 52                	js     801a82 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3a:	8b 00                	mov    (%eax),%eax
  801a3c:	89 04 24             	mov    %eax,(%esp)
  801a3f:	e8 68 fb ff ff       	call   8015ac <dev_lookup>
  801a44:	85 c0                	test   %eax,%eax
  801a46:	78 3a                	js     801a82 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a4f:	74 2c                	je     801a7d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a51:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a54:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a5b:	00 00 00 
	stat->st_isdir = 0;
  801a5e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a65:	00 00 00 
	stat->st_dev = dev;
  801a68:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a72:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a75:	89 14 24             	mov    %edx,(%esp)
  801a78:	ff 50 14             	call   *0x14(%eax)
  801a7b:	eb 05                	jmp    801a82 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a7d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a82:	83 c4 24             	add    $0x24,%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    

00801a88 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a97:	00 
  801a98:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9b:	89 04 24             	mov    %eax,(%esp)
  801a9e:	e8 88 02 00 00       	call   801d2b <open>
  801aa3:	89 c3                	mov    %eax,%ebx
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 1b                	js     801ac4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab0:	89 1c 24             	mov    %ebx,(%esp)
  801ab3:	e8 58 ff ff ff       	call   801a10 <fstat>
  801ab8:	89 c6                	mov    %eax,%esi
	close(fd);
  801aba:	89 1c 24             	mov    %ebx,(%esp)
  801abd:	e8 ce fb ff ff       	call   801690 <close>
	return r;
  801ac2:	89 f3                	mov    %esi,%ebx
}
  801ac4:	89 d8                	mov    %ebx,%eax
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    
  801acd:	00 00                	add    %al,(%eax)
	...

00801ad0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 10             	sub    $0x10,%esp
  801ad8:	89 c3                	mov    %eax,%ebx
  801ada:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801adc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ae3:	75 11                	jne    801af6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ae5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801aec:	e8 ee 09 00 00       	call   8024df <ipc_find_env>
  801af1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801af6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801afd:	00 
  801afe:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b05:	00 
  801b06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b0a:	a1 00 40 80 00       	mov    0x804000,%eax
  801b0f:	89 04 24             	mov    %eax,(%esp)
  801b12:	e8 62 09 00 00       	call   802479 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801b17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b1e:	00 
  801b1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2a:	e8 dd 08 00 00       	call   80240c <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	5b                   	pop    %ebx
  801b33:	5e                   	pop    %esi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b42:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b54:	b8 02 00 00 00       	mov    $0x2,%eax
  801b59:	e8 72 ff ff ff       	call   801ad0 <fsipc>
}
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b66:	8b 45 08             	mov    0x8(%ebp),%eax
  801b69:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b71:	ba 00 00 00 00       	mov    $0x0,%edx
  801b76:	b8 06 00 00 00       	mov    $0x6,%eax
  801b7b:	e8 50 ff ff ff       	call   801ad0 <fsipc>
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	53                   	push   %ebx
  801b86:	83 ec 14             	sub    $0x14,%esp
  801b89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b92:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b97:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9c:	b8 05 00 00 00       	mov    $0x5,%eax
  801ba1:	e8 2a ff ff ff       	call   801ad0 <fsipc>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 2b                	js     801bd5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801baa:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bb1:	00 
  801bb2:	89 1c 24             	mov    %ebx,(%esp)
  801bb5:	e8 79 ed ff ff       	call   800933 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bba:	a1 80 50 80 00       	mov    0x805080,%eax
  801bbf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bc5:	a1 84 50 80 00       	mov    0x805084,%eax
  801bca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bd5:	83 c4 14             	add    $0x14,%esp
  801bd8:	5b                   	pop    %ebx
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	53                   	push   %ebx
  801bdf:	83 ec 14             	sub    $0x14,%esp
  801be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	8b 40 0c             	mov    0xc(%eax),%eax
  801beb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801bf8:	76 05                	jbe    801bff <devfile_write+0x24>
  801bfa:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801bff:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801c04:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0f:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801c16:	e8 fb ee ff ff       	call   800b16 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c20:	b8 04 00 00 00       	mov    $0x4,%eax
  801c25:	e8 a6 fe ff ff       	call   801ad0 <fsipc>
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 53                	js     801c81 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801c2e:	39 c3                	cmp    %eax,%ebx
  801c30:	73 24                	jae    801c56 <devfile_write+0x7b>
  801c32:	c7 44 24 0c 20 2d 80 	movl   $0x802d20,0xc(%esp)
  801c39:	00 
  801c3a:	c7 44 24 08 27 2d 80 	movl   $0x802d27,0x8(%esp)
  801c41:	00 
  801c42:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801c49:	00 
  801c4a:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801c51:	e8 3a e6 ff ff       	call   800290 <_panic>
	assert(r <= PGSIZE);
  801c56:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c5b:	7e 24                	jle    801c81 <devfile_write+0xa6>
  801c5d:	c7 44 24 0c 47 2d 80 	movl   $0x802d47,0xc(%esp)
  801c64:	00 
  801c65:	c7 44 24 08 27 2d 80 	movl   $0x802d27,0x8(%esp)
  801c6c:	00 
  801c6d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801c74:	00 
  801c75:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801c7c:	e8 0f e6 ff ff       	call   800290 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801c81:	83 c4 14             	add    $0x14,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	56                   	push   %esi
  801c8b:	53                   	push   %ebx
  801c8c:	83 ec 10             	sub    $0x10,%esp
  801c8f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	8b 40 0c             	mov    0xc(%eax),%eax
  801c98:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c9d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ca3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca8:	b8 03 00 00 00       	mov    $0x3,%eax
  801cad:	e8 1e fe ff ff       	call   801ad0 <fsipc>
  801cb2:	89 c3                	mov    %eax,%ebx
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	78 6a                	js     801d22 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801cb8:	39 c6                	cmp    %eax,%esi
  801cba:	73 24                	jae    801ce0 <devfile_read+0x59>
  801cbc:	c7 44 24 0c 20 2d 80 	movl   $0x802d20,0xc(%esp)
  801cc3:	00 
  801cc4:	c7 44 24 08 27 2d 80 	movl   $0x802d27,0x8(%esp)
  801ccb:	00 
  801ccc:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801cd3:	00 
  801cd4:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801cdb:	e8 b0 e5 ff ff       	call   800290 <_panic>
	assert(r <= PGSIZE);
  801ce0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ce5:	7e 24                	jle    801d0b <devfile_read+0x84>
  801ce7:	c7 44 24 0c 47 2d 80 	movl   $0x802d47,0xc(%esp)
  801cee:	00 
  801cef:	c7 44 24 08 27 2d 80 	movl   $0x802d27,0x8(%esp)
  801cf6:	00 
  801cf7:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801cfe:	00 
  801cff:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
  801d06:	e8 85 e5 ff ff       	call   800290 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d0f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d16:	00 
  801d17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1a:	89 04 24             	mov    %eax,(%esp)
  801d1d:	e8 8a ed ff ff       	call   800aac <memmove>
	return r;
}
  801d22:	89 d8                	mov    %ebx,%eax
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	56                   	push   %esi
  801d2f:	53                   	push   %ebx
  801d30:	83 ec 20             	sub    $0x20,%esp
  801d33:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d36:	89 34 24             	mov    %esi,(%esp)
  801d39:	e8 c2 eb ff ff       	call   800900 <strlen>
  801d3e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d43:	7f 60                	jg     801da5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d48:	89 04 24             	mov    %eax,(%esp)
  801d4b:	e8 b3 f7 ff ff       	call   801503 <fd_alloc>
  801d50:	89 c3                	mov    %eax,%ebx
  801d52:	85 c0                	test   %eax,%eax
  801d54:	78 54                	js     801daa <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d5a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d61:	e8 cd eb ff ff       	call   800933 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d69:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d71:	b8 01 00 00 00       	mov    $0x1,%eax
  801d76:	e8 55 fd ff ff       	call   801ad0 <fsipc>
  801d7b:	89 c3                	mov    %eax,%ebx
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	79 15                	jns    801d96 <open+0x6b>
		fd_close(fd, 0);
  801d81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d88:	00 
  801d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8c:	89 04 24             	mov    %eax,(%esp)
  801d8f:	e8 74 f8 ff ff       	call   801608 <fd_close>
		return r;
  801d94:	eb 14                	jmp    801daa <open+0x7f>
	}

	return fd2num(fd);
  801d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d99:	89 04 24             	mov    %eax,(%esp)
  801d9c:	e8 37 f7 ff ff       	call   8014d8 <fd2num>
  801da1:	89 c3                	mov    %eax,%ebx
  801da3:	eb 05                	jmp    801daa <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801da5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801daa:	89 d8                	mov    %ebx,%eax
  801dac:	83 c4 20             	add    $0x20,%esp
  801daf:	5b                   	pop    %ebx
  801db0:	5e                   	pop    %esi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    

00801db3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801db9:	ba 00 00 00 00       	mov    $0x0,%edx
  801dbe:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc3:	e8 08 fd ff ff       	call   801ad0 <fsipc>
}
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    
	...

00801dcc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	83 ec 10             	sub    $0x10,%esp
  801dd4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dda:	89 04 24             	mov    %eax,(%esp)
  801ddd:	e8 06 f7 ff ff       	call   8014e8 <fd2data>
  801de2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801de4:	c7 44 24 04 53 2d 80 	movl   $0x802d53,0x4(%esp)
  801deb:	00 
  801dec:	89 34 24             	mov    %esi,(%esp)
  801def:	e8 3f eb ff ff       	call   800933 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801df4:	8b 43 04             	mov    0x4(%ebx),%eax
  801df7:	2b 03                	sub    (%ebx),%eax
  801df9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801dff:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e06:	00 00 00 
	stat->st_dev = &devpipe;
  801e09:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801e10:	30 80 00 
	return 0;
}
  801e13:	b8 00 00 00 00       	mov    $0x0,%eax
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	5b                   	pop    %ebx
  801e1c:	5e                   	pop    %esi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	53                   	push   %ebx
  801e23:	83 ec 14             	sub    $0x14,%esp
  801e26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e34:	e8 93 ef ff ff       	call   800dcc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e39:	89 1c 24             	mov    %ebx,(%esp)
  801e3c:	e8 a7 f6 ff ff       	call   8014e8 <fd2data>
  801e41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4c:	e8 7b ef ff ff       	call   800dcc <sys_page_unmap>
}
  801e51:	83 c4 14             	add    $0x14,%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	57                   	push   %edi
  801e5b:	56                   	push   %esi
  801e5c:	53                   	push   %ebx
  801e5d:	83 ec 2c             	sub    $0x2c,%esp
  801e60:	89 c7                	mov    %eax,%edi
  801e62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e65:	a1 20 44 80 00       	mov    0x804420,%eax
  801e6a:	8b 00                	mov    (%eax),%eax
  801e6c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e6f:	89 3c 24             	mov    %edi,(%esp)
  801e72:	e8 ad 06 00 00       	call   802524 <pageref>
  801e77:	89 c6                	mov    %eax,%esi
  801e79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 a0 06 00 00       	call   802524 <pageref>
  801e84:	39 c6                	cmp    %eax,%esi
  801e86:	0f 94 c0             	sete   %al
  801e89:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e8c:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801e92:	8b 12                	mov    (%edx),%edx
  801e94:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e97:	39 cb                	cmp    %ecx,%ebx
  801e99:	75 08                	jne    801ea3 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e9b:	83 c4 2c             	add    $0x2c,%esp
  801e9e:	5b                   	pop    %ebx
  801e9f:	5e                   	pop    %esi
  801ea0:	5f                   	pop    %edi
  801ea1:	5d                   	pop    %ebp
  801ea2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ea3:	83 f8 01             	cmp    $0x1,%eax
  801ea6:	75 bd                	jne    801e65 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ea8:	8b 42 58             	mov    0x58(%edx),%eax
  801eab:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801eb2:	00 
  801eb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ebb:	c7 04 24 5a 2d 80 00 	movl   $0x802d5a,(%esp)
  801ec2:	e8 c1 e4 ff ff       	call   800388 <cprintf>
  801ec7:	eb 9c                	jmp    801e65 <_pipeisclosed+0xe>

00801ec9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	57                   	push   %edi
  801ecd:	56                   	push   %esi
  801ece:	53                   	push   %ebx
  801ecf:	83 ec 1c             	sub    $0x1c,%esp
  801ed2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ed5:	89 34 24             	mov    %esi,(%esp)
  801ed8:	e8 0b f6 ff ff       	call   8014e8 <fd2data>
  801edd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801edf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ee4:	eb 3c                	jmp    801f22 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ee6:	89 da                	mov    %ebx,%edx
  801ee8:	89 f0                	mov    %esi,%eax
  801eea:	e8 68 ff ff ff       	call   801e57 <_pipeisclosed>
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	75 38                	jne    801f2b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ef3:	e8 0e ee ff ff       	call   800d06 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ef8:	8b 43 04             	mov    0x4(%ebx),%eax
  801efb:	8b 13                	mov    (%ebx),%edx
  801efd:	83 c2 20             	add    $0x20,%edx
  801f00:	39 d0                	cmp    %edx,%eax
  801f02:	73 e2                	jae    801ee6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f07:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f0a:	89 c2                	mov    %eax,%edx
  801f0c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f12:	79 05                	jns    801f19 <devpipe_write+0x50>
  801f14:	4a                   	dec    %edx
  801f15:	83 ca e0             	or     $0xffffffe0,%edx
  801f18:	42                   	inc    %edx
  801f19:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f1d:	40                   	inc    %eax
  801f1e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f21:	47                   	inc    %edi
  801f22:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f25:	75 d1                	jne    801ef8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f27:	89 f8                	mov    %edi,%eax
  801f29:	eb 05                	jmp    801f30 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f30:	83 c4 1c             	add    $0x1c,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	57                   	push   %edi
  801f3c:	56                   	push   %esi
  801f3d:	53                   	push   %ebx
  801f3e:	83 ec 1c             	sub    $0x1c,%esp
  801f41:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f44:	89 3c 24             	mov    %edi,(%esp)
  801f47:	e8 9c f5 ff ff       	call   8014e8 <fd2data>
  801f4c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4e:	be 00 00 00 00       	mov    $0x0,%esi
  801f53:	eb 3a                	jmp    801f8f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f55:	85 f6                	test   %esi,%esi
  801f57:	74 04                	je     801f5d <devpipe_read+0x25>
				return i;
  801f59:	89 f0                	mov    %esi,%eax
  801f5b:	eb 40                	jmp    801f9d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f5d:	89 da                	mov    %ebx,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	e8 f1 fe ff ff       	call   801e57 <_pipeisclosed>
  801f66:	85 c0                	test   %eax,%eax
  801f68:	75 2e                	jne    801f98 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f6a:	e8 97 ed ff ff       	call   800d06 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f6f:	8b 03                	mov    (%ebx),%eax
  801f71:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f74:	74 df                	je     801f55 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f76:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f7b:	79 05                	jns    801f82 <devpipe_read+0x4a>
  801f7d:	48                   	dec    %eax
  801f7e:	83 c8 e0             	or     $0xffffffe0,%eax
  801f81:	40                   	inc    %eax
  801f82:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f86:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f89:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f8c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8e:	46                   	inc    %esi
  801f8f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f92:	75 db                	jne    801f6f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f94:	89 f0                	mov    %esi,%eax
  801f96:	eb 05                	jmp    801f9d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f9d:	83 c4 1c             	add    $0x1c,%esp
  801fa0:	5b                   	pop    %ebx
  801fa1:	5e                   	pop    %esi
  801fa2:	5f                   	pop    %edi
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    

00801fa5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	57                   	push   %edi
  801fa9:	56                   	push   %esi
  801faa:	53                   	push   %ebx
  801fab:	83 ec 3c             	sub    $0x3c,%esp
  801fae:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fb1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fb4:	89 04 24             	mov    %eax,(%esp)
  801fb7:	e8 47 f5 ff ff       	call   801503 <fd_alloc>
  801fbc:	89 c3                	mov    %eax,%ebx
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	0f 88 45 01 00 00    	js     80210b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fcd:	00 
  801fce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fdc:	e8 44 ed ff ff       	call   800d25 <sys_page_alloc>
  801fe1:	89 c3                	mov    %eax,%ebx
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	0f 88 20 01 00 00    	js     80210b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801feb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fee:	89 04 24             	mov    %eax,(%esp)
  801ff1:	e8 0d f5 ff ff       	call   801503 <fd_alloc>
  801ff6:	89 c3                	mov    %eax,%ebx
  801ff8:	85 c0                	test   %eax,%eax
  801ffa:	0f 88 f8 00 00 00    	js     8020f8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802000:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802007:	00 
  802008:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80200b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802016:	e8 0a ed ff ff       	call   800d25 <sys_page_alloc>
  80201b:	89 c3                	mov    %eax,%ebx
  80201d:	85 c0                	test   %eax,%eax
  80201f:	0f 88 d3 00 00 00    	js     8020f8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802025:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802028:	89 04 24             	mov    %eax,(%esp)
  80202b:	e8 b8 f4 ff ff       	call   8014e8 <fd2data>
  802030:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802032:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802039:	00 
  80203a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802045:	e8 db ec ff ff       	call   800d25 <sys_page_alloc>
  80204a:	89 c3                	mov    %eax,%ebx
  80204c:	85 c0                	test   %eax,%eax
  80204e:	0f 88 91 00 00 00    	js     8020e5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802054:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802057:	89 04 24             	mov    %eax,(%esp)
  80205a:	e8 89 f4 ff ff       	call   8014e8 <fd2data>
  80205f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802066:	00 
  802067:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802072:	00 
  802073:	89 74 24 04          	mov    %esi,0x4(%esp)
  802077:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207e:	e8 f6 ec ff ff       	call   800d79 <sys_page_map>
  802083:	89 c3                	mov    %eax,%ebx
  802085:	85 c0                	test   %eax,%eax
  802087:	78 4c                	js     8020d5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802089:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80208f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802092:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802094:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802097:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80209e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020a7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020ac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020b6:	89 04 24             	mov    %eax,(%esp)
  8020b9:	e8 1a f4 ff ff       	call   8014d8 <fd2num>
  8020be:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020c3:	89 04 24             	mov    %eax,(%esp)
  8020c6:	e8 0d f4 ff ff       	call   8014d8 <fd2num>
  8020cb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8020ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d3:	eb 36                	jmp    80210b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8020d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e0:	e8 e7 ec ff ff       	call   800dcc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f3:	e8 d4 ec ff ff       	call   800dcc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802106:	e8 c1 ec ff ff       	call   800dcc <sys_page_unmap>
    err:
	return r;
}
  80210b:	89 d8                	mov    %ebx,%eax
  80210d:	83 c4 3c             	add    $0x3c,%esp
  802110:	5b                   	pop    %ebx
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    

00802115 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802122:	8b 45 08             	mov    0x8(%ebp),%eax
  802125:	89 04 24             	mov    %eax,(%esp)
  802128:	e8 29 f4 ff ff       	call   801556 <fd_lookup>
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 15                	js     802146 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802131:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802134:	89 04 24             	mov    %eax,(%esp)
  802137:	e8 ac f3 ff ff       	call   8014e8 <fd2data>
	return _pipeisclosed(fd, p);
  80213c:	89 c2                	mov    %eax,%edx
  80213e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802141:	e8 11 fd ff ff       	call   801e57 <_pipeisclosed>
}
  802146:	c9                   	leave  
  802147:	c3                   	ret    

00802148 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
  80214b:	56                   	push   %esi
  80214c:	53                   	push   %ebx
  80214d:	83 ec 10             	sub    $0x10,%esp
  802150:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802153:	85 f6                	test   %esi,%esi
  802155:	75 24                	jne    80217b <wait+0x33>
  802157:	c7 44 24 0c 72 2d 80 	movl   $0x802d72,0xc(%esp)
  80215e:	00 
  80215f:	c7 44 24 08 27 2d 80 	movl   $0x802d27,0x8(%esp)
  802166:	00 
  802167:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80216e:	00 
  80216f:	c7 04 24 7d 2d 80 00 	movl   $0x802d7d,(%esp)
  802176:	e8 15 e1 ff ff       	call   800290 <_panic>
	e = &envs[ENVX(envid)];
  80217b:	89 f3                	mov    %esi,%ebx
  80217d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802183:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  80218a:	c1 e3 07             	shl    $0x7,%ebx
  80218d:	29 c3                	sub    %eax,%ebx
  80218f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802195:	eb 05                	jmp    80219c <wait+0x54>
		sys_yield();
  802197:	e8 6a eb ff ff       	call   800d06 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80219c:	8b 43 48             	mov    0x48(%ebx),%eax
  80219f:	39 f0                	cmp    %esi,%eax
  8021a1:	75 07                	jne    8021aa <wait+0x62>
  8021a3:	8b 43 54             	mov    0x54(%ebx),%eax
  8021a6:	85 c0                	test   %eax,%eax
  8021a8:	75 ed                	jne    802197 <wait+0x4f>
		sys_yield();
}
  8021aa:	83 c4 10             	add    $0x10,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    
  8021b1:	00 00                	add    %al,(%eax)
	...

008021b4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    

008021be <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8021c4:	c7 44 24 04 88 2d 80 	movl   $0x802d88,0x4(%esp)
  8021cb:	00 
  8021cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cf:	89 04 24             	mov    %eax,(%esp)
  8021d2:	e8 5c e7 ff ff       	call   800933 <strcpy>
	return 0;
}
  8021d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    

008021de <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021f5:	eb 30                	jmp    802227 <devcons_write+0x49>
		m = n - tot;
  8021f7:	8b 75 10             	mov    0x10(%ebp),%esi
  8021fa:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8021fc:	83 fe 7f             	cmp    $0x7f,%esi
  8021ff:	76 05                	jbe    802206 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802201:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802206:	89 74 24 08          	mov    %esi,0x8(%esp)
  80220a:	03 45 0c             	add    0xc(%ebp),%eax
  80220d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802211:	89 3c 24             	mov    %edi,(%esp)
  802214:	e8 93 e8 ff ff       	call   800aac <memmove>
		sys_cputs(buf, m);
  802219:	89 74 24 04          	mov    %esi,0x4(%esp)
  80221d:	89 3c 24             	mov    %edi,(%esp)
  802220:	e8 33 ea ff ff       	call   800c58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802225:	01 f3                	add    %esi,%ebx
  802227:	89 d8                	mov    %ebx,%eax
  802229:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80222c:	72 c9                	jb     8021f7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80222e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    

00802239 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80223f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802243:	75 07                	jne    80224c <devcons_read+0x13>
  802245:	eb 25                	jmp    80226c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802247:	e8 ba ea ff ff       	call   800d06 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80224c:	e8 25 ea ff ff       	call   800c76 <sys_cgetc>
  802251:	85 c0                	test   %eax,%eax
  802253:	74 f2                	je     802247 <devcons_read+0xe>
  802255:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802257:	85 c0                	test   %eax,%eax
  802259:	78 1d                	js     802278 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80225b:	83 f8 04             	cmp    $0x4,%eax
  80225e:	74 13                	je     802273 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802260:	8b 45 0c             	mov    0xc(%ebp),%eax
  802263:	88 10                	mov    %dl,(%eax)
	return 1;
  802265:	b8 01 00 00 00       	mov    $0x1,%eax
  80226a:	eb 0c                	jmp    802278 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80226c:	b8 00 00 00 00       	mov    $0x0,%eax
  802271:	eb 05                	jmp    802278 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802273:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802278:	c9                   	leave  
  802279:	c3                   	ret    

0080227a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80227a:	55                   	push   %ebp
  80227b:	89 e5                	mov    %esp,%ebp
  80227d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802280:	8b 45 08             	mov    0x8(%ebp),%eax
  802283:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802286:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80228d:	00 
  80228e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802291:	89 04 24             	mov    %eax,(%esp)
  802294:	e8 bf e9 ff ff       	call   800c58 <sys_cputs>
}
  802299:	c9                   	leave  
  80229a:	c3                   	ret    

0080229b <getchar>:

int
getchar(void)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8022a8:	00 
  8022a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b7:	e8 38 f5 ff ff       	call   8017f4 <read>
	if (r < 0)
  8022bc:	85 c0                	test   %eax,%eax
  8022be:	78 0f                	js     8022cf <getchar+0x34>
		return r;
	if (r < 1)
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	7e 06                	jle    8022ca <getchar+0x2f>
		return -E_EOF;
	return c;
  8022c4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022c8:	eb 05                	jmp    8022cf <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022ca:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022cf:	c9                   	leave  
  8022d0:	c3                   	ret    

008022d1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022de:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e1:	89 04 24             	mov    %eax,(%esp)
  8022e4:	e8 6d f2 ff ff       	call   801556 <fd_lookup>
  8022e9:	85 c0                	test   %eax,%eax
  8022eb:	78 11                	js     8022fe <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022f6:	39 10                	cmp    %edx,(%eax)
  8022f8:	0f 94 c0             	sete   %al
  8022fb:	0f b6 c0             	movzbl %al,%eax
}
  8022fe:	c9                   	leave  
  8022ff:	c3                   	ret    

00802300 <opencons>:

int
opencons(void)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802309:	89 04 24             	mov    %eax,(%esp)
  80230c:	e8 f2 f1 ff ff       	call   801503 <fd_alloc>
  802311:	85 c0                	test   %eax,%eax
  802313:	78 3c                	js     802351 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802315:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80231c:	00 
  80231d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802320:	89 44 24 04          	mov    %eax,0x4(%esp)
  802324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80232b:	e8 f5 e9 ff ff       	call   800d25 <sys_page_alloc>
  802330:	85 c0                	test   %eax,%eax
  802332:	78 1d                	js     802351 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802334:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80233a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80233f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802342:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802349:	89 04 24             	mov    %eax,(%esp)
  80234c:	e8 87 f1 ff ff       	call   8014d8 <fd2num>
}
  802351:	c9                   	leave  
  802352:	c3                   	ret    
	...

00802354 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	53                   	push   %ebx
  802358:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80235b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802362:	75 6f                	jne    8023d3 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  802364:	e8 7e e9 ff ff       	call   800ce7 <sys_getenvid>
  802369:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80236b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802372:	00 
  802373:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80237a:	ee 
  80237b:	89 04 24             	mov    %eax,(%esp)
  80237e:	e8 a2 e9 ff ff       	call   800d25 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  802383:	85 c0                	test   %eax,%eax
  802385:	79 1c                	jns    8023a3 <set_pgfault_handler+0x4f>
  802387:	c7 44 24 08 94 2d 80 	movl   $0x802d94,0x8(%esp)
  80238e:	00 
  80238f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802396:	00 
  802397:	c7 04 24 f0 2d 80 00 	movl   $0x802df0,(%esp)
  80239e:	e8 ed de ff ff       	call   800290 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8023a3:	c7 44 24 04 e4 23 80 	movl   $0x8023e4,0x4(%esp)
  8023aa:	00 
  8023ab:	89 1c 24             	mov    %ebx,(%esp)
  8023ae:	e8 12 eb ff ff       	call   800ec5 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  8023b3:	85 c0                	test   %eax,%eax
  8023b5:	79 1c                	jns    8023d3 <set_pgfault_handler+0x7f>
  8023b7:	c7 44 24 08 bc 2d 80 	movl   $0x802dbc,0x8(%esp)
  8023be:	00 
  8023bf:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8023c6:	00 
  8023c7:	c7 04 24 f0 2d 80 00 	movl   $0x802df0,(%esp)
  8023ce:	e8 bd de ff ff       	call   800290 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d6:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8023db:	83 c4 14             	add    $0x14,%esp
  8023de:	5b                   	pop    %ebx
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    
  8023e1:	00 00                	add    %al,(%eax)
	...

008023e4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023e4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023e5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8023ea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023ec:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8023ef:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8023f3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8023f8:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  8023fc:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  8023fe:	83 c4 08             	add    $0x8,%esp
	popal
  802401:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  802402:	83 c4 04             	add    $0x4,%esp
	popfl
  802405:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  802406:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802409:	c3                   	ret    
	...

0080240c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80240c:	55                   	push   %ebp
  80240d:	89 e5                	mov    %esp,%ebp
  80240f:	56                   	push   %esi
  802410:	53                   	push   %ebx
  802411:	83 ec 10             	sub    $0x10,%esp
  802414:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802417:	8b 45 0c             	mov    0xc(%ebp),%eax
  80241a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80241d:	85 c0                	test   %eax,%eax
  80241f:	75 05                	jne    802426 <ipc_recv+0x1a>
  802421:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  802426:	89 04 24             	mov    %eax,(%esp)
  802429:	e8 0d eb ff ff       	call   800f3b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80242e:	85 c0                	test   %eax,%eax
  802430:	79 16                	jns    802448 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  802432:	85 db                	test   %ebx,%ebx
  802434:	74 06                	je     80243c <ipc_recv+0x30>
  802436:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  80243c:	85 f6                	test   %esi,%esi
  80243e:	74 32                	je     802472 <ipc_recv+0x66>
  802440:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802446:	eb 2a                	jmp    802472 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802448:	85 db                	test   %ebx,%ebx
  80244a:	74 0c                	je     802458 <ipc_recv+0x4c>
  80244c:	a1 20 44 80 00       	mov    0x804420,%eax
  802451:	8b 00                	mov    (%eax),%eax
  802453:	8b 40 74             	mov    0x74(%eax),%eax
  802456:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802458:	85 f6                	test   %esi,%esi
  80245a:	74 0c                	je     802468 <ipc_recv+0x5c>
  80245c:	a1 20 44 80 00       	mov    0x804420,%eax
  802461:	8b 00                	mov    (%eax),%eax
  802463:	8b 40 78             	mov    0x78(%eax),%eax
  802466:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  802468:	a1 20 44 80 00       	mov    0x804420,%eax
  80246d:	8b 00                	mov    (%eax),%eax
  80246f:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	5b                   	pop    %ebx
  802476:	5e                   	pop    %esi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    

00802479 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802479:	55                   	push   %ebp
  80247a:	89 e5                	mov    %esp,%ebp
  80247c:	57                   	push   %edi
  80247d:	56                   	push   %esi
  80247e:	53                   	push   %ebx
  80247f:	83 ec 1c             	sub    $0x1c,%esp
  802482:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802485:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802488:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80248b:	85 db                	test   %ebx,%ebx
  80248d:	75 05                	jne    802494 <ipc_send+0x1b>
  80248f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  802494:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802498:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80249c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a3:	89 04 24             	mov    %eax,(%esp)
  8024a6:	e8 6d ea ff ff       	call   800f18 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8024ab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024ae:	75 07                	jne    8024b7 <ipc_send+0x3e>
  8024b0:	e8 51 e8 ff ff       	call   800d06 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8024b5:	eb dd                	jmp    802494 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8024b7:	85 c0                	test   %eax,%eax
  8024b9:	79 1c                	jns    8024d7 <ipc_send+0x5e>
  8024bb:	c7 44 24 08 fe 2d 80 	movl   $0x802dfe,0x8(%esp)
  8024c2:	00 
  8024c3:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8024ca:	00 
  8024cb:	c7 04 24 10 2e 80 00 	movl   $0x802e10,(%esp)
  8024d2:	e8 b9 dd ff ff       	call   800290 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  8024d7:	83 c4 1c             	add    $0x1c,%esp
  8024da:	5b                   	pop    %ebx
  8024db:	5e                   	pop    %esi
  8024dc:	5f                   	pop    %edi
  8024dd:	5d                   	pop    %ebp
  8024de:	c3                   	ret    

008024df <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024df:	55                   	push   %ebp
  8024e0:	89 e5                	mov    %esp,%ebp
  8024e2:	53                   	push   %ebx
  8024e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8024e6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024eb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8024f2:	89 c2                	mov    %eax,%edx
  8024f4:	c1 e2 07             	shl    $0x7,%edx
  8024f7:	29 ca                	sub    %ecx,%edx
  8024f9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024ff:	8b 52 50             	mov    0x50(%edx),%edx
  802502:	39 da                	cmp    %ebx,%edx
  802504:	75 0f                	jne    802515 <ipc_find_env+0x36>
			return envs[i].env_id;
  802506:	c1 e0 07             	shl    $0x7,%eax
  802509:	29 c8                	sub    %ecx,%eax
  80250b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802510:	8b 40 40             	mov    0x40(%eax),%eax
  802513:	eb 0c                	jmp    802521 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802515:	40                   	inc    %eax
  802516:	3d 00 04 00 00       	cmp    $0x400,%eax
  80251b:	75 ce                	jne    8024eb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80251d:	66 b8 00 00          	mov    $0x0,%ax
}
  802521:	5b                   	pop    %ebx
  802522:	5d                   	pop    %ebp
  802523:	c3                   	ret    

00802524 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802524:	55                   	push   %ebp
  802525:	89 e5                	mov    %esp,%ebp
  802527:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  80252a:	89 c2                	mov    %eax,%edx
  80252c:	c1 ea 16             	shr    $0x16,%edx
  80252f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802536:	f6 c2 01             	test   $0x1,%dl
  802539:	74 1e                	je     802559 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80253b:	c1 e8 0c             	shr    $0xc,%eax
  80253e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802545:	a8 01                	test   $0x1,%al
  802547:	74 17                	je     802560 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802549:	c1 e8 0c             	shr    $0xc,%eax
  80254c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802553:	ef 
  802554:	0f b7 c0             	movzwl %ax,%eax
  802557:	eb 0c                	jmp    802565 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802559:	b8 00 00 00 00       	mov    $0x0,%eax
  80255e:	eb 05                	jmp    802565 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802560:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802565:	5d                   	pop    %ebp
  802566:	c3                   	ret    
	...

00802568 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802568:	55                   	push   %ebp
  802569:	57                   	push   %edi
  80256a:	56                   	push   %esi
  80256b:	83 ec 10             	sub    $0x10,%esp
  80256e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802572:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80257a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80257e:	89 cd                	mov    %ecx,%ebp
  802580:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802584:	85 c0                	test   %eax,%eax
  802586:	75 2c                	jne    8025b4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802588:	39 f9                	cmp    %edi,%ecx
  80258a:	77 68                	ja     8025f4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80258c:	85 c9                	test   %ecx,%ecx
  80258e:	75 0b                	jne    80259b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802590:	b8 01 00 00 00       	mov    $0x1,%eax
  802595:	31 d2                	xor    %edx,%edx
  802597:	f7 f1                	div    %ecx
  802599:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	89 f8                	mov    %edi,%eax
  80259f:	f7 f1                	div    %ecx
  8025a1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025a3:	89 f0                	mov    %esi,%eax
  8025a5:	f7 f1                	div    %ecx
  8025a7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025a9:	89 f0                	mov    %esi,%eax
  8025ab:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025ad:	83 c4 10             	add    $0x10,%esp
  8025b0:	5e                   	pop    %esi
  8025b1:	5f                   	pop    %edi
  8025b2:	5d                   	pop    %ebp
  8025b3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025b4:	39 f8                	cmp    %edi,%eax
  8025b6:	77 2c                	ja     8025e4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025b8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8025bb:	83 f6 1f             	xor    $0x1f,%esi
  8025be:	75 4c                	jne    80260c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025c0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025c2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025c7:	72 0a                	jb     8025d3 <__udivdi3+0x6b>
  8025c9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8025cd:	0f 87 ad 00 00 00    	ja     802680 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025d3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025d8:	89 f0                	mov    %esi,%eax
  8025da:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025dc:	83 c4 10             	add    $0x10,%esp
  8025df:	5e                   	pop    %esi
  8025e0:	5f                   	pop    %edi
  8025e1:	5d                   	pop    %ebp
  8025e2:	c3                   	ret    
  8025e3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025e4:	31 ff                	xor    %edi,%edi
  8025e6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025e8:	89 f0                	mov    %esi,%eax
  8025ea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025ec:	83 c4 10             	add    $0x10,%esp
  8025ef:	5e                   	pop    %esi
  8025f0:	5f                   	pop    %edi
  8025f1:	5d                   	pop    %ebp
  8025f2:	c3                   	ret    
  8025f3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025f4:	89 fa                	mov    %edi,%edx
  8025f6:	89 f0                	mov    %esi,%eax
  8025f8:	f7 f1                	div    %ecx
  8025fa:	89 c6                	mov    %eax,%esi
  8025fc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025fe:	89 f0                	mov    %esi,%eax
  802600:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802602:	83 c4 10             	add    $0x10,%esp
  802605:	5e                   	pop    %esi
  802606:	5f                   	pop    %edi
  802607:	5d                   	pop    %ebp
  802608:	c3                   	ret    
  802609:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80260c:	89 f1                	mov    %esi,%ecx
  80260e:	d3 e0                	shl    %cl,%eax
  802610:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802614:	b8 20 00 00 00       	mov    $0x20,%eax
  802619:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80261b:	89 ea                	mov    %ebp,%edx
  80261d:	88 c1                	mov    %al,%cl
  80261f:	d3 ea                	shr    %cl,%edx
  802621:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802625:	09 ca                	or     %ecx,%edx
  802627:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80262b:	89 f1                	mov    %esi,%ecx
  80262d:	d3 e5                	shl    %cl,%ebp
  80262f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802633:	89 fd                	mov    %edi,%ebp
  802635:	88 c1                	mov    %al,%cl
  802637:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802639:	89 fa                	mov    %edi,%edx
  80263b:	89 f1                	mov    %esi,%ecx
  80263d:	d3 e2                	shl    %cl,%edx
  80263f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802643:	88 c1                	mov    %al,%cl
  802645:	d3 ef                	shr    %cl,%edi
  802647:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802649:	89 f8                	mov    %edi,%eax
  80264b:	89 ea                	mov    %ebp,%edx
  80264d:	f7 74 24 08          	divl   0x8(%esp)
  802651:	89 d1                	mov    %edx,%ecx
  802653:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802655:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802659:	39 d1                	cmp    %edx,%ecx
  80265b:	72 17                	jb     802674 <__udivdi3+0x10c>
  80265d:	74 09                	je     802668 <__udivdi3+0x100>
  80265f:	89 fe                	mov    %edi,%esi
  802661:	31 ff                	xor    %edi,%edi
  802663:	e9 41 ff ff ff       	jmp    8025a9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802668:	8b 54 24 04          	mov    0x4(%esp),%edx
  80266c:	89 f1                	mov    %esi,%ecx
  80266e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802670:	39 c2                	cmp    %eax,%edx
  802672:	73 eb                	jae    80265f <__udivdi3+0xf7>
		{
		  q0--;
  802674:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802677:	31 ff                	xor    %edi,%edi
  802679:	e9 2b ff ff ff       	jmp    8025a9 <__udivdi3+0x41>
  80267e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802680:	31 f6                	xor    %esi,%esi
  802682:	e9 22 ff ff ff       	jmp    8025a9 <__udivdi3+0x41>
	...

00802688 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802688:	55                   	push   %ebp
  802689:	57                   	push   %edi
  80268a:	56                   	push   %esi
  80268b:	83 ec 20             	sub    $0x20,%esp
  80268e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802692:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802696:	89 44 24 14          	mov    %eax,0x14(%esp)
  80269a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80269e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026a2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8026a6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8026a8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026aa:	85 ed                	test   %ebp,%ebp
  8026ac:	75 16                	jne    8026c4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8026ae:	39 f1                	cmp    %esi,%ecx
  8026b0:	0f 86 a6 00 00 00    	jbe    80275c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026b6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8026b8:	89 d0                	mov    %edx,%eax
  8026ba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026bc:	83 c4 20             	add    $0x20,%esp
  8026bf:	5e                   	pop    %esi
  8026c0:	5f                   	pop    %edi
  8026c1:	5d                   	pop    %ebp
  8026c2:	c3                   	ret    
  8026c3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8026c4:	39 f5                	cmp    %esi,%ebp
  8026c6:	0f 87 ac 00 00 00    	ja     802778 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8026cc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8026cf:	83 f0 1f             	xor    $0x1f,%eax
  8026d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8026d6:	0f 84 a8 00 00 00    	je     802784 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8026dc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026e0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8026e2:	bf 20 00 00 00       	mov    $0x20,%edi
  8026e7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8026eb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026ef:	89 f9                	mov    %edi,%ecx
  8026f1:	d3 e8                	shr    %cl,%eax
  8026f3:	09 e8                	or     %ebp,%eax
  8026f5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8026f9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026fd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802701:	d3 e0                	shl    %cl,%eax
  802703:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802707:	89 f2                	mov    %esi,%edx
  802709:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80270b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80270f:	d3 e0                	shl    %cl,%eax
  802711:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802715:	8b 44 24 14          	mov    0x14(%esp),%eax
  802719:	89 f9                	mov    %edi,%ecx
  80271b:	d3 e8                	shr    %cl,%eax
  80271d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80271f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802721:	89 f2                	mov    %esi,%edx
  802723:	f7 74 24 18          	divl   0x18(%esp)
  802727:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802729:	f7 64 24 0c          	mull   0xc(%esp)
  80272d:	89 c5                	mov    %eax,%ebp
  80272f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802731:	39 d6                	cmp    %edx,%esi
  802733:	72 67                	jb     80279c <__umoddi3+0x114>
  802735:	74 75                	je     8027ac <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802737:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80273b:	29 e8                	sub    %ebp,%eax
  80273d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80273f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802743:	d3 e8                	shr    %cl,%eax
  802745:	89 f2                	mov    %esi,%edx
  802747:	89 f9                	mov    %edi,%ecx
  802749:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80274b:	09 d0                	or     %edx,%eax
  80274d:	89 f2                	mov    %esi,%edx
  80274f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802753:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802755:	83 c4 20             	add    $0x20,%esp
  802758:	5e                   	pop    %esi
  802759:	5f                   	pop    %edi
  80275a:	5d                   	pop    %ebp
  80275b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80275c:	85 c9                	test   %ecx,%ecx
  80275e:	75 0b                	jne    80276b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802760:	b8 01 00 00 00       	mov    $0x1,%eax
  802765:	31 d2                	xor    %edx,%edx
  802767:	f7 f1                	div    %ecx
  802769:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80276b:	89 f0                	mov    %esi,%eax
  80276d:	31 d2                	xor    %edx,%edx
  80276f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802771:	89 f8                	mov    %edi,%eax
  802773:	e9 3e ff ff ff       	jmp    8026b6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802778:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80277a:	83 c4 20             	add    $0x20,%esp
  80277d:	5e                   	pop    %esi
  80277e:	5f                   	pop    %edi
  80277f:	5d                   	pop    %ebp
  802780:	c3                   	ret    
  802781:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802784:	39 f5                	cmp    %esi,%ebp
  802786:	72 04                	jb     80278c <__umoddi3+0x104>
  802788:	39 f9                	cmp    %edi,%ecx
  80278a:	77 06                	ja     802792 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80278c:	89 f2                	mov    %esi,%edx
  80278e:	29 cf                	sub    %ecx,%edi
  802790:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802792:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802794:	83 c4 20             	add    $0x20,%esp
  802797:	5e                   	pop    %esi
  802798:	5f                   	pop    %edi
  802799:	5d                   	pop    %ebp
  80279a:	c3                   	ret    
  80279b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80279c:	89 d1                	mov    %edx,%ecx
  80279e:	89 c5                	mov    %eax,%ebp
  8027a0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8027a4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8027a8:	eb 8d                	jmp    802737 <__umoddi3+0xaf>
  8027aa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027ac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8027b0:	72 ea                	jb     80279c <__umoddi3+0x114>
  8027b2:	89 f1                	mov    %esi,%ecx
  8027b4:	eb 81                	jmp    802737 <__umoddi3+0xaf>
