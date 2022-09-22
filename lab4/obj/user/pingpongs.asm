
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 3b 11 00 00       	call   80117d <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5f                	je     8000a8 <umain+0x74>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	a1 08 20 80 00       	mov    0x802008,%eax
  80004e:	8b 18                	mov    (%eax),%ebx
  800050:	e8 72 0b 00 00       	call   800bc7 <sys_getenvid>
  800055:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800059:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005d:	c7 04 24 a0 17 80 00 	movl   $0x8017a0,(%esp)
  800064:	e8 ff 01 00 00       	call   800268 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800069:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006c:	e8 56 0b 00 00       	call   800bc7 <sys_getenvid>
  800071:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800075:	89 44 24 04          	mov    %eax,0x4(%esp)
  800079:	c7 04 24 ba 17 80 00 	movl   $0x8017ba,(%esp)
  800080:	e8 e3 01 00 00       	call   800268 <cprintf>
		ipc_send(who, 0, 0, 0);
  800085:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008c:	00 
  80008d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800094:	00 
  800095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009c:	00 
  80009d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000a0:	89 04 24             	mov    %eax,(%esp)
  8000a3:	e8 e9 12 00 00       	call   801391 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 61 12 00 00       	call   801324 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c3:	a1 08 20 80 00       	mov    0x802008,%eax
  8000c8:	8b 18                	mov    (%eax),%ebx
  8000ca:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000d0:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d9:	e8 e9 0a 00 00       	call   800bc7 <sys_getenvid>
  8000de:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000ed:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f5:	c7 04 24 d0 17 80 00 	movl   $0x8017d0,(%esp)
  8000fc:	e8 67 01 00 00       	call   800268 <cprintf>
		if (val == 10)
  800101:	a1 04 20 80 00       	mov    0x802004,%eax
  800106:	83 f8 0a             	cmp    $0xa,%eax
  800109:	74 36                	je     800141 <umain+0x10d>
			return;
		++val;
  80010b:	40                   	inc    %eax
  80010c:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 5d 12 00 00       	call   801391 <ipc_send>
		if (val == 10)
  800134:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  80013b:	0f 85 67 ff ff ff    	jne    8000a8 <umain+0x74>
			return;
	}

}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
  800151:	83 ec 20             	sub    $0x20,%esp
  800154:	8b 75 08             	mov    0x8(%ebp),%esi
  800157:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80015a:	e8 68 0a 00 00       	call   800bc7 <sys_getenvid>
  80015f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800164:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80016b:	c1 e0 07             	shl    $0x7,%eax
  80016e:	29 d0                	sub    %edx,%eax
  800170:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800175:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800178:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80017b:	a3 08 20 80 00       	mov    %eax,0x802008
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  800184:	c7 04 24 cc 17 80 00 	movl   $0x8017cc,(%esp)
  80018b:	e8 d8 00 00 00       	call   800268 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800190:	85 f6                	test   %esi,%esi
  800192:	7e 07                	jle    80019b <libmain+0x4f>
		binaryname = argv[0];
  800194:	8b 03                	mov    (%ebx),%eax
  800196:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80019b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80019f:	89 34 24             	mov    %esi,(%esp)
  8001a2:	e8 8d fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001a7:	e8 08 00 00 00       	call   8001b4 <exit>
}
  8001ac:	83 c4 20             	add    $0x20,%esp
  8001af:	5b                   	pop    %ebx
  8001b0:	5e                   	pop    %esi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    
	...

008001b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001c1:	e8 af 09 00 00       	call   800b75 <sys_env_destroy>
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  8001cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d2:	8b 03                	mov    (%ebx),%eax
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001db:	40                   	inc    %eax
  8001dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e3:	75 19                	jne    8001fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ec:	00 
  8001ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 40 09 00 00       	call   800b38 <sys_cputs>
		b->idx = 0;
  8001f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fe:	ff 43 04             	incl   0x4(%ebx)
}
  800201:	83 c4 14             	add    $0x14,%esp
  800204:	5b                   	pop    %ebx
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800210:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800217:	00 00 00 
	b.cnt = 0;
  80021a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800221:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	c7 04 24 c8 01 80 00 	movl   $0x8001c8,(%esp)
  800243:	e8 82 01 00 00       	call   8003ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800248:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800252:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	e8 d8 08 00 00       	call   800b38 <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 87 ff ff ff       	call   800207 <vcprintf>
	va_end(ap);

	return cnt;
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    
	...

00800284 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 3c             	sub    $0x3c,%esp
  80028d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800290:	89 d7                	mov    %edx,%edi
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a4:	85 c0                	test   %eax,%eax
  8002a6:	75 08                	jne    8002b0 <printnum+0x2c>
  8002a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 57                	ja     800307 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b4:	4b                   	dec    %ebx
  8002b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cf:	00 
  8002d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	e8 6a 12 00 00       	call   80154c <__udivdi3>
  8002e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ea:	89 04 24             	mov    %eax,(%esp)
  8002ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f1:	89 fa                	mov    %edi,%edx
  8002f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f6:	e8 89 ff ff ff       	call   800284 <printnum>
  8002fb:	eb 0f                	jmp    80030c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800301:	89 34 24             	mov    %esi,(%esp)
  800304:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800307:	4b                   	dec    %ebx
  800308:	85 db                	test   %ebx,%ebx
  80030a:	7f f1                	jg     8002fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 10             	mov    0x10(%ebp),%eax
  800317:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800322:	00 
  800323:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800330:	e8 37 13 00 00       	call   80166c <__umoddi3>
  800335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800339:	0f be 80 00 18 80 00 	movsbl 0x801800(%eax),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800346:	83 c4 3c             	add    $0x3c,%esp
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800351:	83 fa 01             	cmp    $0x1,%edx
  800354:	7e 0e                	jle    800364 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800356:	8b 10                	mov    (%eax),%edx
  800358:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035b:	89 08                	mov    %ecx,(%eax)
  80035d:	8b 02                	mov    (%edx),%eax
  80035f:	8b 52 04             	mov    0x4(%edx),%edx
  800362:	eb 22                	jmp    800386 <getuint+0x38>
	else if (lflag)
  800364:	85 d2                	test   %edx,%edx
  800366:	74 10                	je     800378 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	eb 0e                	jmp    800386 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 02                	mov    (%edx),%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800391:	8b 10                	mov    (%eax),%edx
  800393:	3b 50 04             	cmp    0x4(%eax),%edx
  800396:	73 08                	jae    8003a0 <sprintputch+0x18>
		*b->buf++ = ch;
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	88 0a                	mov    %cl,(%edx)
  80039d:	42                   	inc    %edx
  80039e:	89 10                	mov    %edx,(%eax)
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003af:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 02 00 00 00       	call   8003ca <vprintfmt>
	va_end(ap);
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 4c             	sub    $0x4c,%esp
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d9:	eb 12                	jmp    8003ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	0f 84 6b 03 00 00    	je     80074e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	0f b6 06             	movzbl (%esi),%eax
  8003f0:	46                   	inc    %esi
  8003f1:	83 f8 25             	cmp    $0x25,%eax
  8003f4:	75 e5                	jne    8003db <vprintfmt+0x11>
  8003f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800401:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800406:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800412:	eb 26                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800417:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80041b:	eb 1d                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800424:	eb 14                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800429:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800430:	eb 08                	jmp    80043a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800432:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800435:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	0f b6 06             	movzbl (%esi),%eax
  80043d:	8d 56 01             	lea    0x1(%esi),%edx
  800440:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800443:	8a 16                	mov    (%esi),%dl
  800445:	83 ea 23             	sub    $0x23,%edx
  800448:	80 fa 55             	cmp    $0x55,%dl
  80044b:	0f 87 e1 02 00 00    	ja     800732 <vprintfmt+0x368>
  800451:	0f b6 d2             	movzbl %dl,%edx
  800454:	ff 24 95 c0 18 80 00 	jmp    *0x8018c0(,%edx,4)
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800463:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800466:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80046a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80046d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800470:	83 fa 09             	cmp    $0x9,%edx
  800473:	77 2a                	ja     80049f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800475:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800476:	eb eb                	jmp    800463 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800486:	eb 17                	jmp    80049f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800488:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048c:	78 98                	js     800426 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800491:	eb a7                	jmp    80043a <vprintfmt+0x70>
  800493:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800496:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80049d:	eb 9b                	jmp    80043a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a3:	79 95                	jns    80043a <vprintfmt+0x70>
  8004a5:	eb 8b                	jmp    800432 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ab:	eb 8d                	jmp    80043a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c5:	e9 23 ff ff ff       	jmp    8003ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 50 04             	lea    0x4(%eax),%edx
  8004d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	79 02                	jns    8004db <vprintfmt+0x111>
  8004d9:	f7 d8                	neg    %eax
  8004db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004dd:	83 f8 08             	cmp    $0x8,%eax
  8004e0:	7f 0b                	jg     8004ed <vprintfmt+0x123>
  8004e2:	8b 04 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	75 23                	jne    800510 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f1:	c7 44 24 08 18 18 80 	movl   $0x801818,0x8(%esp)
  8004f8:	00 
  8004f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	e8 9a fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80050b:	e9 dd fe ff ff       	jmp    8003ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800510:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800514:	c7 44 24 08 21 18 80 	movl   $0x801821,0x8(%esp)
  80051b:	00 
  80051c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800520:	8b 55 08             	mov    0x8(%ebp),%edx
  800523:	89 14 24             	mov    %edx,(%esp)
  800526:	e8 77 fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052e:	e9 ba fe ff ff       	jmp    8003ed <vprintfmt+0x23>
  800533:	89 f9                	mov    %edi,%ecx
  800535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800538:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 30                	mov    (%eax),%esi
  800546:	85 f6                	test   %esi,%esi
  800548:	75 05                	jne    80054f <vprintfmt+0x185>
				p = "(null)";
  80054a:	be 11 18 80 00       	mov    $0x801811,%esi
			if (width > 0 && padc != '-')
  80054f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800553:	0f 8e 84 00 00 00    	jle    8005dd <vprintfmt+0x213>
  800559:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80055d:	74 7e                	je     8005dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800563:	89 34 24             	mov    %esi,(%esp)
  800566:	e8 8b 02 00 00       	call   8007f6 <strnlen>
  80056b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056e:	29 c2                	sub    %eax,%edx
  800570:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800573:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800577:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80057a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80057d:	89 de                	mov    %ebx,%esi
  80057f:	89 d3                	mov    %edx,%ebx
  800581:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	eb 0b                	jmp    800590 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800585:	89 74 24 04          	mov    %esi,0x4(%esp)
  800589:	89 3c 24             	mov    %edi,(%esp)
  80058c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	4b                   	dec    %ebx
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f f1                	jg     800585 <vprintfmt+0x1bb>
  800594:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800597:	89 f3                	mov    %esi,%ebx
  800599:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80059c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	79 05                	jns    8005a8 <vprintfmt+0x1de>
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ab:	29 c2                	sub    %eax,%edx
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b0:	eb 2b                	jmp    8005dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b6:	74 18                	je     8005d0 <vprintfmt+0x206>
  8005b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005bb:	83 fa 5e             	cmp    $0x5e,%edx
  8005be:	76 10                	jbe    8005d0 <vprintfmt+0x206>
					putch('?', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
  8005ce:	eb 0a                	jmp    8005da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	ff 4d e4             	decl   -0x1c(%ebp)
  8005dd:	0f be 06             	movsbl (%esi),%eax
  8005e0:	46                   	inc    %esi
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	74 21                	je     800606 <vprintfmt+0x23c>
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	78 c9                	js     8005b2 <vprintfmt+0x1e8>
  8005e9:	4f                   	dec    %edi
  8005ea:	79 c6                	jns    8005b2 <vprintfmt+0x1e8>
  8005ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ef:	89 de                	mov    %ebx,%esi
  8005f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f4:	eb 18                	jmp    80060e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800601:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800603:	4b                   	dec    %ebx
  800604:	eb 08                	jmp    80060e <vprintfmt+0x244>
  800606:	8b 7d 08             	mov    0x8(%ebp),%edi
  800609:	89 de                	mov    %ebx,%esi
  80060b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060e:	85 db                	test   %ebx,%ebx
  800610:	7f e4                	jg     8005f6 <vprintfmt+0x22c>
  800612:	89 7d 08             	mov    %edi,0x8(%ebp)
  800615:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061a:	e9 ce fd ff ff       	jmp    8003ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7e 10                	jle    800634 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 08             	lea    0x8(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 30                	mov    (%eax),%esi
  80062f:	8b 78 04             	mov    0x4(%eax),%edi
  800632:	eb 26                	jmp    80065a <vprintfmt+0x290>
	else if (lflag)
  800634:	85 c9                	test   %ecx,%ecx
  800636:	74 12                	je     80064a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 30                	mov    (%eax),%esi
  800643:	89 f7                	mov    %esi,%edi
  800645:	c1 ff 1f             	sar    $0x1f,%edi
  800648:	eb 10                	jmp    80065a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 30                	mov    (%eax),%esi
  800655:	89 f7                	mov    %esi,%edi
  800657:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065a:	85 ff                	test   %edi,%edi
  80065c:	78 0a                	js     800668 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800663:	e9 8c 00 00 00       	jmp    8006f4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800676:	f7 de                	neg    %esi
  800678:	83 d7 00             	adc    $0x0,%edi
  80067b:	f7 df                	neg    %edi
			}
			base = 10;
  80067d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800682:	eb 70                	jmp    8006f4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800684:	89 ca                	mov    %ecx,%edx
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 c0 fc ff ff       	call   80034e <getuint>
  80068e:	89 c6                	mov    %eax,%esi
  800690:	89 d7                	mov    %edx,%edi
			base = 10;
  800692:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800697:	eb 5b                	jmp    8006f4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 ab fc ff ff       	call   80034e <getuint>
  8006a3:	89 c6                	mov    %eax,%esi
  8006a5:	89 d7                	mov    %edx,%edi
			base = 8;
  8006a7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006ac:	eb 46                	jmp    8006f4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d3:	8b 30                	mov    (%eax),%esi
  8006d5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006df:	eb 13                	jmp    8006f4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 63 fc ff ff       	call   80034e <getuint>
  8006eb:	89 c6                	mov    %eax,%esi
  8006ed:	89 d7                	mov    %edx,%edi
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800703:	89 44 24 08          	mov    %eax,0x8(%esp)
  800707:	89 34 24             	mov    %esi,(%esp)
  80070a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070e:	89 da                	mov    %ebx,%edx
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	e8 6c fb ff ff       	call   800284 <printnum>
			break;
  800718:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80071b:	e9 cd fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072d:	e9 bb fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800736:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800740:	eb 01                	jmp    800743 <vprintfmt+0x379>
  800742:	4e                   	dec    %esi
  800743:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800747:	75 f9                	jne    800742 <vprintfmt+0x378>
  800749:	e9 9f fc ff ff       	jmp    8003ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074e:	83 c4 4c             	add    $0x4c,%esp
  800751:	5b                   	pop    %ebx
  800752:	5e                   	pop    %esi
  800753:	5f                   	pop    %edi
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	83 ec 28             	sub    $0x28,%esp
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800762:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800765:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800769:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800773:	85 c0                	test   %eax,%eax
  800775:	74 30                	je     8007a7 <vsnprintf+0x51>
  800777:	85 d2                	test   %edx,%edx
  800779:	7e 33                	jle    8007ae <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800782:	8b 45 10             	mov    0x10(%ebp),%eax
  800785:	89 44 24 08          	mov    %eax,0x8(%esp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800790:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  800797:	e8 2e fc ff ff       	call   8003ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a5:	eb 0c                	jmp    8007b3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ac:	eb 05                	jmp    8007b3 <vsnprintf+0x5d>
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	89 04 24             	mov    %eax,(%esp)
  8007d6:	e8 7b ff ff ff       	call   800756 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 01                	jmp    8007ee <strlen+0xe>
		n++;
  8007ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f2:	75 f9                	jne    8007ed <strlen+0xd>
		n++;
	return n;
}
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800804:	eb 01                	jmp    800807 <strnlen+0x11>
		n++;
  800806:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	39 d0                	cmp    %edx,%eax
  800809:	74 06                	je     800811 <strnlen+0x1b>
  80080b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080f:	75 f5                	jne    800806 <strnlen+0x10>
		n++;
	return n;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
  800822:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800825:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800828:	42                   	inc    %edx
  800829:	84 c9                	test   %cl,%cl
  80082b:	75 f5                	jne    800822 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80082d:	5b                   	pop    %ebx
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	89 1c 24             	mov    %ebx,(%esp)
  80083d:	e8 9e ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
  800845:	89 54 24 04          	mov    %edx,0x4(%esp)
  800849:	01 d8                	add    %ebx,%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 c0 ff ff ff       	call   800813 <strcpy>
	return dst;
}
  800853:	89 d8                	mov    %ebx,%eax
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
  800866:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086e:	eb 0c                	jmp    80087c <strncpy+0x21>
		*dst++ = *src;
  800870:	8a 1a                	mov    (%edx),%bl
  800872:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800875:	80 3a 01             	cmpb   $0x1,(%edx)
  800878:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087b:	41                   	inc    %ecx
  80087c:	39 f1                	cmp    %esi,%ecx
  80087e:	75 f0                	jne    800870 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	75 0a                	jne    8008a0 <strlcpy+0x1c>
  800896:	89 f0                	mov    %esi,%eax
  800898:	eb 1a                	jmp    8008b4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089a:	88 18                	mov    %bl,(%eax)
  80089c:	40                   	inc    %eax
  80089d:	41                   	inc    %ecx
  80089e:	eb 02                	jmp    8008a2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008a2:	4a                   	dec    %edx
  8008a3:	74 0a                	je     8008af <strlcpy+0x2b>
  8008a5:	8a 19                	mov    (%ecx),%bl
  8008a7:	84 db                	test   %bl,%bl
  8008a9:	75 ef                	jne    80089a <strlcpy+0x16>
  8008ab:	89 c2                	mov    %eax,%edx
  8008ad:	eb 02                	jmp    8008b1 <strlcpy+0x2d>
  8008af:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b4:	29 f0                	sub    %esi,%eax
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c3:	eb 02                	jmp    8008c7 <strcmp+0xd>
		p++, q++;
  8008c5:	41                   	inc    %ecx
  8008c6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c7:	8a 01                	mov    (%ecx),%al
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 04                	je     8008d1 <strcmp+0x17>
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	74 f4                	je     8008c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 c0             	movzbl %al,%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e8:	eb 03                	jmp    8008ed <strncmp+0x12>
		n--, p++, q++;
  8008ea:	4a                   	dec    %edx
  8008eb:	40                   	inc    %eax
  8008ec:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ed:	85 d2                	test   %edx,%edx
  8008ef:	74 14                	je     800905 <strncmp+0x2a>
  8008f1:	8a 18                	mov    (%eax),%bl
  8008f3:	84 db                	test   %bl,%bl
  8008f5:	74 04                	je     8008fb <strncmp+0x20>
  8008f7:	3a 19                	cmp    (%ecx),%bl
  8008f9:	74 ef                	je     8008ea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 00             	movzbl (%eax),%eax
  8008fe:	0f b6 11             	movzbl (%ecx),%edx
  800901:	29 d0                	sub    %edx,%eax
  800903:	eb 05                	jmp    80090a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090a:	5b                   	pop    %ebx
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800916:	eb 05                	jmp    80091d <strchr+0x10>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 0c                	je     800928 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091c:	40                   	inc    %eax
  80091d:	8a 10                	mov    (%eax),%dl
  80091f:	84 d2                	test   %dl,%dl
  800921:	75 f5                	jne    800918 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800933:	eb 05                	jmp    80093a <strfind+0x10>
		if (*s == c)
  800935:	38 ca                	cmp    %cl,%dl
  800937:	74 07                	je     800940 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800939:	40                   	inc    %eax
  80093a:	8a 10                	mov    (%eax),%dl
  80093c:	84 d2                	test   %dl,%dl
  80093e:	75 f5                	jne    800935 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800951:	85 c9                	test   %ecx,%ecx
  800953:	74 30                	je     800985 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800955:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095b:	75 25                	jne    800982 <memset+0x40>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 20                	jne    800982 <memset+0x40>
		c &= 0xFF;
  800962:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800965:	89 d3                	mov    %edx,%ebx
  800967:	c1 e3 08             	shl    $0x8,%ebx
  80096a:	89 d6                	mov    %edx,%esi
  80096c:	c1 e6 18             	shl    $0x18,%esi
  80096f:	89 d0                	mov    %edx,%eax
  800971:	c1 e0 10             	shl    $0x10,%eax
  800974:	09 f0                	or     %esi,%eax
  800976:	09 d0                	or     %edx,%eax
  800978:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80097d:	fc                   	cld    
  80097e:	f3 ab                	rep stos %eax,%es:(%edi)
  800980:	eb 03                	jmp    800985 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800982:	fc                   	cld    
  800983:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800985:	89 f8                	mov    %edi,%eax
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 75 0c             	mov    0xc(%ebp),%esi
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099a:	39 c6                	cmp    %eax,%esi
  80099c:	73 34                	jae    8009d2 <memmove+0x46>
  80099e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a1:	39 d0                	cmp    %edx,%eax
  8009a3:	73 2d                	jae    8009d2 <memmove+0x46>
		s += n;
		d += n;
  8009a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	f6 c2 03             	test   $0x3,%dl
  8009ab:	75 1b                	jne    8009c8 <memmove+0x3c>
  8009ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b3:	75 13                	jne    8009c8 <memmove+0x3c>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0e                	jne    8009c8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ba:	83 ef 04             	sub    $0x4,%edi
  8009bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c3:	fd                   	std    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 07                	jmp    8009cf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c8:	4f                   	dec    %edi
  8009c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cc:	fd                   	std    
  8009cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cf:	fc                   	cld    
  8009d0:	eb 20                	jmp    8009f2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d8:	75 13                	jne    8009ed <memmove+0x61>
  8009da:	a8 03                	test   $0x3,%al
  8009dc:	75 0f                	jne    8009ed <memmove+0x61>
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 0a                	jne    8009ed <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb 05                	jmp    8009f2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	89 04 24             	mov    %eax,(%esp)
  800a10:	e8 77 ff ff ff       	call   80098c <memmove>
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	eb 16                	jmp    800a43 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a30:	42                   	inc    %edx
  800a31:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a35:	38 c8                	cmp    %cl,%al
  800a37:	74 0a                	je     800a43 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a39:	0f b6 c0             	movzbl %al,%eax
  800a3c:	0f b6 c9             	movzbl %cl,%ecx
  800a3f:	29 c8                	sub    %ecx,%eax
  800a41:	eb 09                	jmp    800a4c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a43:	39 da                	cmp    %ebx,%edx
  800a45:	75 e6                	jne    800a2d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5a:	89 c2                	mov    %eax,%edx
  800a5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5f:	eb 05                	jmp    800a66 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	38 08                	cmp    %cl,(%eax)
  800a63:	74 05                	je     800a6a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a65:	40                   	inc    %eax
  800a66:	39 d0                	cmp    %edx,%eax
  800a68:	72 f7                	jb     800a61 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a78:	eb 01                	jmp    800a7b <strtol+0xf>
		s++;
  800a7a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7b:	8a 02                	mov    (%edx),%al
  800a7d:	3c 20                	cmp    $0x20,%al
  800a7f:	74 f9                	je     800a7a <strtol+0xe>
  800a81:	3c 09                	cmp    $0x9,%al
  800a83:	74 f5                	je     800a7a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a85:	3c 2b                	cmp    $0x2b,%al
  800a87:	75 08                	jne    800a91 <strtol+0x25>
		s++;
  800a89:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8f:	eb 13                	jmp    800aa4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a91:	3c 2d                	cmp    $0x2d,%al
  800a93:	75 0a                	jne    800a9f <strtol+0x33>
		s++, neg = 1;
  800a95:	8d 52 01             	lea    0x1(%edx),%edx
  800a98:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9d:	eb 05                	jmp    800aa4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	74 05                	je     800aad <strtol+0x41>
  800aa8:	83 fb 10             	cmp    $0x10,%ebx
  800aab:	75 28                	jne    800ad5 <strtol+0x69>
  800aad:	8a 02                	mov    (%edx),%al
  800aaf:	3c 30                	cmp    $0x30,%al
  800ab1:	75 10                	jne    800ac3 <strtol+0x57>
  800ab3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab7:	75 0a                	jne    800ac3 <strtol+0x57>
		s += 2, base = 16;
  800ab9:	83 c2 02             	add    $0x2,%edx
  800abc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac1:	eb 12                	jmp    800ad5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac3:	85 db                	test   %ebx,%ebx
  800ac5:	75 0e                	jne    800ad5 <strtol+0x69>
  800ac7:	3c 30                	cmp    $0x30,%al
  800ac9:	75 05                	jne    800ad0 <strtol+0x64>
		s++, base = 8;
  800acb:	42                   	inc    %edx
  800acc:	b3 08                	mov    $0x8,%bl
  800ace:	eb 05                	jmp    800ad5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adc:	8a 0a                	mov    (%edx),%cl
  800ade:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae1:	80 fb 09             	cmp    $0x9,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x82>
			dig = *s - '0';
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 30             	sub    $0x30,%ecx
  800aec:	eb 1e                	jmp    800b0c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 08                	ja     800afe <strtol+0x92>
			dig = *s - 'a' + 10;
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 57             	sub    $0x57,%ecx
  800afc:	eb 0e                	jmp    800b0c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 12                	ja     800b18 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b06:	0f be c9             	movsbl %cl,%ecx
  800b09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b0c:	39 f1                	cmp    %esi,%ecx
  800b0e:	7d 0c                	jge    800b1c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b10:	42                   	inc    %edx
  800b11:	0f af c6             	imul   %esi,%eax
  800b14:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb c4                	jmp    800adc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	89 c1                	mov    %eax,%ecx
  800b1a:	eb 02                	jmp    800b1e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b22:	74 05                	je     800b29 <strtol+0xbd>
		*endptr = (char *) s;
  800b24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b27:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b29:	85 ff                	test   %edi,%edi
  800b2b:	74 04                	je     800b31 <strtol+0xc5>
  800b2d:	89 c8                	mov    %ecx,%eax
  800b2f:	f7 d8                	neg    %eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
	...

00800b38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	89 c6                	mov    %eax,%esi
  800b4f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	b8 03 00 00 00       	mov    $0x3,%eax
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	89 cb                	mov    %ecx,%ebx
  800b8d:	89 cf                	mov    %ecx,%edi
  800b8f:	89 ce                	mov    %ecx,%esi
  800b91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7e 28                	jle    800bbf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba2:	00 
  800ba3:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800baa:	00 
  800bab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb2:	00 
  800bb3:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800bba:	e8 7d 08 00 00       	call   80143c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbf:	83 c4 2c             	add    $0x2c,%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd7:	89 d1                	mov    %edx,%ecx
  800bd9:	89 d3                	mov    %edx,%ebx
  800bdb:	89 d7                	mov    %edx,%edi
  800bdd:	89 d6                	mov    %edx,%esi
  800bdf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_yield>:

void
sys_yield(void)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf6:	89 d1                	mov    %edx,%ecx
  800bf8:	89 d3                	mov    %edx,%ebx
  800bfa:	89 d7                	mov    %edx,%edi
  800bfc:	89 d6                	mov    %edx,%esi
  800bfe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	be 00 00 00 00       	mov    $0x0,%esi
  800c13:	b8 04 00 00 00       	mov    $0x4,%eax
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 f7                	mov    %esi,%edi
  800c23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 28                	jle    800c51 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c34:	00 
  800c35:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800c3c:	00 
  800c3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c44:	00 
  800c45:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800c4c:	e8 eb 07 00 00       	call   80143c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c51:	83 c4 2c             	add    $0x2c,%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	b8 05 00 00 00       	mov    $0x5,%eax
  800c67:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	7e 28                	jle    800ca4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c80:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c87:	00 
  800c88:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800c8f:	00 
  800c90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c97:	00 
  800c98:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800c9f:	e8 98 07 00 00       	call   80143c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca4:	83 c4 2c             	add    $0x2c,%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	89 df                	mov    %ebx,%edi
  800cc7:	89 de                	mov    %ebx,%esi
  800cc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 28                	jle    800cf7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cda:	00 
  800cdb:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cea:	00 
  800ceb:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800cf2:	e8 45 07 00 00       	call   80143c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf7:	83 c4 2c             	add    $0x2c,%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	89 df                	mov    %ebx,%edi
  800d1a:	89 de                	mov    %ebx,%esi
  800d1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7e 28                	jle    800d4a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d26:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d2d:	00 
  800d2e:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800d35:	00 
  800d36:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3d:	00 
  800d3e:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800d45:	e8 f2 06 00 00       	call   80143c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4a:	83 c4 2c             	add    $0x2c,%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d60:	b8 09 00 00 00       	mov    $0x9,%eax
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	89 df                	mov    %ebx,%edi
  800d6d:	89 de                	mov    %ebx,%esi
  800d6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7e 28                	jle    800d9d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d79:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d80:	00 
  800d81:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800d88:	00 
  800d89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d90:	00 
  800d91:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800d98:	e8 9f 06 00 00       	call   80143c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9d:	83 c4 2c             	add    $0x2c,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	be 00 00 00 00       	mov    $0x0,%esi
  800db0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 cb                	mov    %ecx,%ebx
  800de0:	89 cf                	mov    %ecx,%edi
  800de2:	89 ce                	mov    %ecx,%esi
  800de4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de6:	85 c0                	test   %eax,%eax
  800de8:	7e 28                	jle    800e12 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dee:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800df5:	00 
  800df6:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800dfd:	00 
  800dfe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e05:	00 
  800e06:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800e0d:	e8 2a 06 00 00       	call   80143c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e12:	83 c4 2c             	add    $0x2c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
	...

00800e1c <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
  800e22:	83 ec 3c             	sub    $0x3c,%esp
  800e25:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800e28:	89 d6                	mov    %edx,%esi
  800e2a:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800e2d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e34:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800e37:	e8 8b fd ff ff       	call   800bc7 <sys_getenvid>
  800e3c:	89 c7                	mov    %eax,%edi
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800e3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e41:	25 02 08 00 00       	and    $0x802,%eax
  800e46:	83 f8 01             	cmp    $0x1,%eax
  800e49:	19 db                	sbb    %ebx,%ebx
  800e4b:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800e51:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800e57:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e5b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e62:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	89 3c 24             	mov    %edi,(%esp)
  800e6d:	e8 e7 fd ff ff       	call   800c59 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 1c                	jns    800e92 <duppage+0x76>
  800e76:	c7 44 24 08 6f 1a 80 	movl   $0x801a6f,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800e8d:	e8 aa 05 00 00       	call   80143c <_panic>
	if ((perm|~pte)&PTE_COW){
  800e92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e95:	f7 d0                	not    %eax
  800e97:	09 d8                	or     %ebx,%eax
  800e99:	f6 c4 08             	test   $0x8,%ah
  800e9c:	74 38                	je     800ed6 <duppage+0xba>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800e9e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800ea2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ea6:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800eaa:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eae:	89 3c 24             	mov    %edi,(%esp)
  800eb1:	e8 a3 fd ff ff       	call   800c59 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	79 1c                	jns    800ed6 <duppage+0xba>
  800eba:	c7 44 24 08 6f 1a 80 	movl   $0x801a6f,0x8(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  800ec9:	00 
  800eca:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800ed1:	e8 66 05 00 00       	call   80143c <_panic>
	}
	return 0;
	panic("duppage not implemented");
	return 0;
}
  800ed6:	b8 00 00 00 00       	mov    $0x0,%eax
  800edb:	83 c4 3c             	add    $0x3c,%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 20             	sub    $0x20,%esp
  800eeb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eee:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800ef0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ef4:	75 1c                	jne    800f12 <pgfault+0x2f>
		panic("pgfault: error!\n");
  800ef6:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  800efd:	00 
  800efe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f05:	00 
  800f06:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800f0d:	e8 2a 05 00 00       	call   80143c <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800f12:	89 f0                	mov    %esi,%eax
  800f14:	c1 e8 0c             	shr    $0xc,%eax
  800f17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f1e:	f6 c4 08             	test   $0x8,%ah
  800f21:	75 1c                	jne    800f3f <pgfault+0x5c>
		panic("pgfault: error!\n");
  800f23:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  800f2a:	00 
  800f2b:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800f32:	00 
  800f33:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800f3a:	e8 fd 04 00 00       	call   80143c <_panic>
	envid_t envid = sys_getenvid();
  800f3f:	e8 83 fc ff ff       	call   800bc7 <sys_getenvid>
  800f44:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800f46:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f4d:	00 
  800f4e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f55:	00 
  800f56:	89 04 24             	mov    %eax,(%esp)
  800f59:	e8 a7 fc ff ff       	call   800c05 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 1c                	jns    800f7e <pgfault+0x9b>
  800f62:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  800f69:	00 
  800f6a:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f71:	00 
  800f72:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800f79:	e8 be 04 00 00       	call   80143c <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800f7e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  800f84:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f8b:	00 
  800f8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f90:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f97:	e8 5a fa ff ff       	call   8009f6 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  800f9c:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fa3:	00 
  800fa4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fa8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fac:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fb3:	00 
  800fb4:	89 1c 24             	mov    %ebx,(%esp)
  800fb7:	e8 9d fc ff ff       	call   800c59 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	79 1c                	jns    800fdc <pgfault+0xf9>
  800fc0:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  800fc7:	00 
  800fc8:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  800fcf:	00 
  800fd0:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800fd7:	e8 60 04 00 00       	call   80143c <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  800fdc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe3:	00 
  800fe4:	89 1c 24             	mov    %ebx,(%esp)
  800fe7:	e8 c0 fc ff ff       	call   800cac <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  800fec:	85 c0                	test   %eax,%eax
  800fee:	79 1c                	jns    80100c <pgfault+0x129>
  800ff0:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  800ff7:	00 
  800ff8:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800fff:	00 
  801000:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  801007:	e8 30 04 00 00       	call   80143c <_panic>
	return;
	panic("pgfault not implemented");
}
  80100c:	83 c4 20             	add    $0x20,%esp
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
  801019:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80101c:	c7 04 24 e3 0e 80 00 	movl   $0x800ee3,(%esp)
  801023:	e8 6c 04 00 00       	call   801494 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801028:	bf 07 00 00 00       	mov    $0x7,%edi
  80102d:	89 f8                	mov    %edi,%eax
  80102f:	cd 30                	int    $0x30
  801031:	89 c7                	mov    %eax,%edi
  801033:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  801035:	85 c0                	test   %eax,%eax
  801037:	79 1c                	jns    801055 <fork+0x42>
		panic("fork : error!\n");
  801039:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  801040:	00 
  801041:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801048:	00 
  801049:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  801050:	e8 e7 03 00 00       	call   80143c <_panic>
	if (envid==0){
  801055:	85 c0                	test   %eax,%eax
  801057:	75 28                	jne    801081 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  801059:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80105f:	e8 63 fb ff ff       	call   800bc7 <sys_getenvid>
  801064:	25 ff 03 00 00       	and    $0x3ff,%eax
  801069:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801070:	c1 e0 07             	shl    $0x7,%eax
  801073:	29 d0                	sub    %edx,%eax
  801075:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80107a:	89 03                	mov    %eax,(%ebx)
		return envid;
  80107c:	e9 f2 00 00 00       	jmp    801173 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  801081:	e8 41 fb ff ff       	call   800bc7 <sys_getenvid>
  801086:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801089:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  80108e:	89 d8                	mov    %ebx,%eax
  801090:	c1 e8 16             	shr    $0x16,%eax
  801093:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109a:	a8 01                	test   $0x1,%al
  80109c:	74 17                	je     8010b5 <fork+0xa2>
  80109e:	89 da                	mov    %ebx,%edx
  8010a0:	c1 ea 0c             	shr    $0xc,%edx
  8010a3:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010aa:	a8 01                	test   $0x1,%al
  8010ac:	74 07                	je     8010b5 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  8010ae:	89 f0                	mov    %esi,%eax
  8010b0:	e8 67 fd ff ff       	call   800e1c <duppage>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8010b5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010bb:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010c1:	75 cb                	jne    80108e <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  8010c3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010ca:	00 
  8010cb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010d2:	ee 
  8010d3:	89 3c 24             	mov    %edi,(%esp)
  8010d6:	e8 2a fb ff ff       	call   800c05 <sys_page_alloc>
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	79 1c                	jns    8010fb <fork+0xe8>
  8010df:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  8010e6:	00 
  8010e7:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  8010ee:	00 
  8010ef:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  8010f6:	e8 41 03 00 00       	call   80143c <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  8010fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  801103:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80110a:	c1 e0 07             	shl    $0x7,%eax
  80110d:	29 d0                	sub    %edx,%eax
  80110f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801114:	8b 40 64             	mov    0x64(%eax),%eax
  801117:	89 44 24 04          	mov    %eax,0x4(%esp)
  80111b:	89 3c 24             	mov    %edi,(%esp)
  80111e:	e8 2f fc ff ff       	call   800d52 <sys_env_set_pgfault_upcall>
  801123:	85 c0                	test   %eax,%eax
  801125:	79 1c                	jns    801143 <fork+0x130>
  801127:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  80112e:	00 
  80112f:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  80113e:	e8 f9 02 00 00       	call   80143c <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  801143:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80114a:	00 
  80114b:	89 3c 24             	mov    %edi,(%esp)
  80114e:	e8 ac fb ff ff       	call   800cff <sys_env_set_status>
  801153:	85 c0                	test   %eax,%eax
  801155:	79 1c                	jns    801173 <fork+0x160>
  801157:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  801166:	00 
  801167:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  80116e:	e8 c9 02 00 00       	call   80143c <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801173:	89 f8                	mov    %edi,%eax
  801175:	83 c4 2c             	add    $0x2c,%esp
  801178:	5b                   	pop    %ebx
  801179:	5e                   	pop    %esi
  80117a:	5f                   	pop    %edi
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <sfork>:

// Challenge!
int
sfork(void)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	57                   	push   %edi
  801181:	56                   	push   %esi
  801182:	53                   	push   %ebx
  801183:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  801186:	c7 04 24 e3 0e 80 00 	movl   $0x800ee3,(%esp)
  80118d:	e8 02 03 00 00       	call   801494 <set_pgfault_handler>
  801192:	ba 07 00 00 00       	mov    $0x7,%edx
  801197:	89 d0                	mov    %edx,%eax
  801199:	cd 30                	int    $0x30
  80119b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80119e:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  8011a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a4:	c7 04 24 9c 1a 80 00 	movl   $0x801a9c,(%esp)
  8011ab:	e8 b8 f0 ff ff       	call   800268 <cprintf>
	if (envid<0)
  8011b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011b4:	79 1c                	jns    8011d2 <sfork+0x55>
		panic("sfork : error!\n");
  8011b6:	c7 44 24 08 a7 1a 80 	movl   $0x801aa7,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  8011cd:	e8 6a 02 00 00       	call   80143c <_panic>
	if (envid==0){
  8011d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011d6:	75 28                	jne    801200 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  8011d8:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8011de:	e8 e4 f9 ff ff       	call   800bc7 <sys_getenvid>
  8011e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011ef:	c1 e0 07             	shl    $0x7,%eax
  8011f2:	29 d0                	sub    %edx,%eax
  8011f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011f9:	89 03                	mov    %eax,(%ebx)
		return envid;
  8011fb:	e9 18 01 00 00       	jmp    801318 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801200:	e8 c2 f9 ff ff       	call   800bc7 <sys_getenvid>
  801205:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801207:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  80120c:	89 d8                	mov    %ebx,%eax
  80120e:	c1 e8 16             	shr    $0x16,%eax
  801211:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801218:	a8 01                	test   $0x1,%al
  80121a:	74 2c                	je     801248 <sfork+0xcb>
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	c1 e8 0c             	shr    $0xc,%eax
  801221:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801228:	a8 01                	test   $0x1,%al
  80122a:	74 1c                	je     801248 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  80122c:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801233:	00 
  801234:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801238:	89 74 24 08          	mov    %esi,0x8(%esp)
  80123c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801240:	89 3c 24             	mov    %edi,(%esp)
  801243:	e8 11 fa ff ff       	call   800c59 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801248:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80124e:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801254:	75 b6                	jne    80120c <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  801256:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  80125b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80125e:	e8 b9 fb ff ff       	call   800e1c <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801263:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80126a:	00 
  80126b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801272:	ee 
  801273:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801276:	89 04 24             	mov    %eax,(%esp)
  801279:	e8 87 f9 ff ff       	call   800c05 <sys_page_alloc>
  80127e:	85 c0                	test   %eax,%eax
  801280:	79 1c                	jns    80129e <sfork+0x121>
  801282:	c7 44 24 08 a7 1a 80 	movl   $0x801aa7,0x8(%esp)
  801289:	00 
  80128a:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  801291:	00 
  801292:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  801299:	e8 9e 01 00 00       	call   80143c <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  80129e:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  8012a4:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  8012ab:	c1 e7 07             	shl    $0x7,%edi
  8012ae:	29 d7                	sub    %edx,%edi
  8012b0:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  8012b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012bd:	89 04 24             	mov    %eax,(%esp)
  8012c0:	e8 8d fa ff ff       	call   800d52 <sys_env_set_pgfault_upcall>
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	79 1c                	jns    8012e5 <sfork+0x168>
  8012c9:	c7 44 24 08 a7 1a 80 	movl   $0x801aa7,0x8(%esp)
  8012d0:	00 
  8012d1:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8012d8:	00 
  8012d9:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  8012e0:	e8 57 01 00 00       	call   80143c <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  8012e5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012ec:	00 
  8012ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f0:	89 04 24             	mov    %eax,(%esp)
  8012f3:	e8 07 fa ff ff       	call   800cff <sys_env_set_status>
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	79 1c                	jns    801318 <sfork+0x19b>
  8012fc:	c7 44 24 08 a7 1a 80 	movl   $0x801aa7,0x8(%esp)
  801303:	00 
  801304:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  80130b:	00 
  80130c:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  801313:	e8 24 01 00 00       	call   80143c <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  801318:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80131b:	83 c4 3c             	add    $0x3c,%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    
	...

00801324 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 10             	sub    $0x10,%esp
  80132c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80132f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801332:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	
	if (pg==NULL)pg=(void *)UTOP;
  801335:	85 c0                	test   %eax,%eax
  801337:	75 05                	jne    80133e <ipc_recv+0x1a>
  801339:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  80133e:	89 04 24             	mov    %eax,(%esp)
  801341:	e8 82 fa ff ff       	call   800dc8 <sys_ipc_recv>
	// cprintf("%x\n",err);
	if (err < 0){
  801346:	85 c0                	test   %eax,%eax
  801348:	79 16                	jns    801360 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  80134a:	85 db                	test   %ebx,%ebx
  80134c:	74 06                	je     801354 <ipc_recv+0x30>
  80134e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801354:	85 f6                	test   %esi,%esi
  801356:	74 32                	je     80138a <ipc_recv+0x66>
  801358:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80135e:	eb 2a                	jmp    80138a <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801360:	85 db                	test   %ebx,%ebx
  801362:	74 0c                	je     801370 <ipc_recv+0x4c>
  801364:	a1 08 20 80 00       	mov    0x802008,%eax
  801369:	8b 00                	mov    (%eax),%eax
  80136b:	8b 40 74             	mov    0x74(%eax),%eax
  80136e:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801370:	85 f6                	test   %esi,%esi
  801372:	74 0c                	je     801380 <ipc_recv+0x5c>
  801374:	a1 08 20 80 00       	mov    0x802008,%eax
  801379:	8b 00                	mov    (%eax),%eax
  80137b:	8b 40 78             	mov    0x78(%eax),%eax
  80137e:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801380:	a1 08 20 80 00       	mov    0x802008,%eax
  801385:	8b 00                	mov    (%eax),%eax
  801387:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	57                   	push   %edi
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
  801397:	83 ec 1c             	sub    $0x1c,%esp
  80139a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80139d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8013a3:	85 db                	test   %ebx,%ebx
  8013a5:	75 05                	jne    8013ac <ipc_send+0x1b>
  8013a7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8013ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	89 04 24             	mov    %eax,(%esp)
  8013be:	e8 e2 f9 ff ff       	call   800da5 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8013c3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013c6:	75 07                	jne    8013cf <ipc_send+0x3e>
  8013c8:	e8 19 f8 ff ff       	call   800be6 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8013cd:	eb dd                	jmp    8013ac <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	79 1c                	jns    8013ef <ipc_send+0x5e>
  8013d3:	c7 44 24 08 b7 1a 80 	movl   $0x801ab7,0x8(%esp)
  8013da:	00 
  8013db:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8013e2:	00 
  8013e3:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  8013ea:	e8 4d 00 00 00       	call   80143c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  8013ef:	83 c4 1c             	add    $0x1c,%esp
  8013f2:	5b                   	pop    %ebx
  8013f3:	5e                   	pop    %esi
  8013f4:	5f                   	pop    %edi
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	53                   	push   %ebx
  8013fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8013fe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801403:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80140a:	89 c2                	mov    %eax,%edx
  80140c:	c1 e2 07             	shl    $0x7,%edx
  80140f:	29 ca                	sub    %ecx,%edx
  801411:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801417:	8b 52 50             	mov    0x50(%edx),%edx
  80141a:	39 da                	cmp    %ebx,%edx
  80141c:	75 0f                	jne    80142d <ipc_find_env+0x36>
			return envs[i].env_id;
  80141e:	c1 e0 07             	shl    $0x7,%eax
  801421:	29 c8                	sub    %ecx,%eax
  801423:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801428:	8b 40 40             	mov    0x40(%eax),%eax
  80142b:	eb 0c                	jmp    801439 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80142d:	40                   	inc    %eax
  80142e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801433:	75 ce                	jne    801403 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801435:	66 b8 00 00          	mov    $0x0,%ax
}
  801439:	5b                   	pop    %ebx
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801444:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801447:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80144d:	e8 75 f7 ff ff       	call   800bc7 <sys_getenvid>
  801452:	8b 55 0c             	mov    0xc(%ebp),%edx
  801455:	89 54 24 10          	mov    %edx,0x10(%esp)
  801459:	8b 55 08             	mov    0x8(%ebp),%edx
  80145c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801460:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  80146f:	e8 f4 ed ff ff       	call   800268 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801474:	89 74 24 04          	mov    %esi,0x4(%esp)
  801478:	8b 45 10             	mov    0x10(%ebp),%eax
  80147b:	89 04 24             	mov    %eax,(%esp)
  80147e:	e8 84 ed ff ff       	call   800207 <vcprintf>
	cprintf("\n");
  801483:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  80148a:	e8 d9 ed ff ff       	call   800268 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80148f:	cc                   	int3   
  801490:	eb fd                	jmp    80148f <_panic+0x53>
	...

00801494 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80149b:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8014a2:	75 6f                	jne    801513 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8014a4:	e8 1e f7 ff ff       	call   800bc7 <sys_getenvid>
  8014a9:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8014ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014b2:	00 
  8014b3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014ba:	ee 
  8014bb:	89 04 24             	mov    %eax,(%esp)
  8014be:	e8 42 f7 ff ff       	call   800c05 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	79 1c                	jns    8014e3 <set_pgfault_handler+0x4f>
  8014c7:	c7 44 24 08 f8 1a 80 	movl   $0x801af8,0x8(%esp)
  8014ce:	00 
  8014cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014d6:	00 
  8014d7:	c7 04 24 54 1b 80 00 	movl   $0x801b54,(%esp)
  8014de:	e8 59 ff ff ff       	call   80143c <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8014e3:	c7 44 24 04 24 15 80 	movl   $0x801524,0x4(%esp)
  8014ea:	00 
  8014eb:	89 1c 24             	mov    %ebx,(%esp)
  8014ee:	e8 5f f8 ff ff       	call   800d52 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	79 1c                	jns    801513 <set_pgfault_handler+0x7f>
  8014f7:	c7 44 24 08 20 1b 80 	movl   $0x801b20,0x8(%esp)
  8014fe:	00 
  8014ff:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801506:	00 
  801507:	c7 04 24 54 1b 80 00 	movl   $0x801b54,(%esp)
  80150e:	e8 29 ff ff ff       	call   80143c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80151b:	83 c4 14             	add    $0x14,%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5d                   	pop    %ebp
  801520:	c3                   	ret    
  801521:	00 00                	add    %al,(%eax)
	...

00801524 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801524:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801525:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80152a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80152c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  80152f:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  801533:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  801538:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  80153c:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  80153e:	83 c4 08             	add    $0x8,%esp
	popal
  801541:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  801542:	83 c4 04             	add    $0x4,%esp
	popfl
  801545:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  801546:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801549:	c3                   	ret    
	...

0080154c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80154c:	55                   	push   %ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	83 ec 10             	sub    $0x10,%esp
  801552:	8b 74 24 20          	mov    0x20(%esp),%esi
  801556:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80155a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80155e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801562:	89 cd                	mov    %ecx,%ebp
  801564:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801568:	85 c0                	test   %eax,%eax
  80156a:	75 2c                	jne    801598 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80156c:	39 f9                	cmp    %edi,%ecx
  80156e:	77 68                	ja     8015d8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801570:	85 c9                	test   %ecx,%ecx
  801572:	75 0b                	jne    80157f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801574:	b8 01 00 00 00       	mov    $0x1,%eax
  801579:	31 d2                	xor    %edx,%edx
  80157b:	f7 f1                	div    %ecx
  80157d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80157f:	31 d2                	xor    %edx,%edx
  801581:	89 f8                	mov    %edi,%eax
  801583:	f7 f1                	div    %ecx
  801585:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801587:	89 f0                	mov    %esi,%eax
  801589:	f7 f1                	div    %ecx
  80158b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80158d:	89 f0                	mov    %esi,%eax
  80158f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	5e                   	pop    %esi
  801595:	5f                   	pop    %edi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801598:	39 f8                	cmp    %edi,%eax
  80159a:	77 2c                	ja     8015c8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80159c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80159f:	83 f6 1f             	xor    $0x1f,%esi
  8015a2:	75 4c                	jne    8015f0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015a4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8015a6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015ab:	72 0a                	jb     8015b7 <__udivdi3+0x6b>
  8015ad:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8015b1:	0f 87 ad 00 00 00    	ja     801664 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8015b7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015bc:	89 f0                	mov    %esi,%eax
  8015be:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	5e                   	pop    %esi
  8015c4:	5f                   	pop    %edi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    
  8015c7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8015c8:	31 ff                	xor    %edi,%edi
  8015ca:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015cc:	89 f0                	mov    %esi,%eax
  8015ce:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    
  8015d7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8015d8:	89 fa                	mov    %edi,%edx
  8015da:	89 f0                	mov    %esi,%eax
  8015dc:	f7 f1                	div    %ecx
  8015de:	89 c6                	mov    %eax,%esi
  8015e0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015e2:	89 f0                	mov    %esi,%eax
  8015e4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	5e                   	pop    %esi
  8015ea:	5f                   	pop    %edi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    
  8015ed:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8015f0:	89 f1                	mov    %esi,%ecx
  8015f2:	d3 e0                	shl    %cl,%eax
  8015f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8015f8:	b8 20 00 00 00       	mov    $0x20,%eax
  8015fd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8015ff:	89 ea                	mov    %ebp,%edx
  801601:	88 c1                	mov    %al,%cl
  801603:	d3 ea                	shr    %cl,%edx
  801605:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801609:	09 ca                	or     %ecx,%edx
  80160b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80160f:	89 f1                	mov    %esi,%ecx
  801611:	d3 e5                	shl    %cl,%ebp
  801613:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801617:	89 fd                	mov    %edi,%ebp
  801619:	88 c1                	mov    %al,%cl
  80161b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80161d:	89 fa                	mov    %edi,%edx
  80161f:	89 f1                	mov    %esi,%ecx
  801621:	d3 e2                	shl    %cl,%edx
  801623:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801627:	88 c1                	mov    %al,%cl
  801629:	d3 ef                	shr    %cl,%edi
  80162b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80162d:	89 f8                	mov    %edi,%eax
  80162f:	89 ea                	mov    %ebp,%edx
  801631:	f7 74 24 08          	divl   0x8(%esp)
  801635:	89 d1                	mov    %edx,%ecx
  801637:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801639:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80163d:	39 d1                	cmp    %edx,%ecx
  80163f:	72 17                	jb     801658 <__udivdi3+0x10c>
  801641:	74 09                	je     80164c <__udivdi3+0x100>
  801643:	89 fe                	mov    %edi,%esi
  801645:	31 ff                	xor    %edi,%edi
  801647:	e9 41 ff ff ff       	jmp    80158d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80164c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801650:	89 f1                	mov    %esi,%ecx
  801652:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801654:	39 c2                	cmp    %eax,%edx
  801656:	73 eb                	jae    801643 <__udivdi3+0xf7>
		{
		  q0--;
  801658:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80165b:	31 ff                	xor    %edi,%edi
  80165d:	e9 2b ff ff ff       	jmp    80158d <__udivdi3+0x41>
  801662:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801664:	31 f6                	xor    %esi,%esi
  801666:	e9 22 ff ff ff       	jmp    80158d <__udivdi3+0x41>
	...

0080166c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80166c:	55                   	push   %ebp
  80166d:	57                   	push   %edi
  80166e:	56                   	push   %esi
  80166f:	83 ec 20             	sub    $0x20,%esp
  801672:	8b 44 24 30          	mov    0x30(%esp),%eax
  801676:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80167a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80167e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801682:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801686:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80168a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80168c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80168e:	85 ed                	test   %ebp,%ebp
  801690:	75 16                	jne    8016a8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801692:	39 f1                	cmp    %esi,%ecx
  801694:	0f 86 a6 00 00 00    	jbe    801740 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80169a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80169c:	89 d0                	mov    %edx,%eax
  80169e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016a0:	83 c4 20             	add    $0x20,%esp
  8016a3:	5e                   	pop    %esi
  8016a4:	5f                   	pop    %edi
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    
  8016a7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8016a8:	39 f5                	cmp    %esi,%ebp
  8016aa:	0f 87 ac 00 00 00    	ja     80175c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8016b0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8016b3:	83 f0 1f             	xor    $0x1f,%eax
  8016b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ba:	0f 84 a8 00 00 00    	je     801768 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8016c0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016c4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8016c6:	bf 20 00 00 00       	mov    $0x20,%edi
  8016cb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8016cf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8016d3:	89 f9                	mov    %edi,%ecx
  8016d5:	d3 e8                	shr    %cl,%eax
  8016d7:	09 e8                	or     %ebp,%eax
  8016d9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8016dd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8016e1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016e5:	d3 e0                	shl    %cl,%eax
  8016e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8016eb:	89 f2                	mov    %esi,%edx
  8016ed:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8016ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8016f3:	d3 e0                	shl    %cl,%eax
  8016f5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8016f9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8016fd:	89 f9                	mov    %edi,%ecx
  8016ff:	d3 e8                	shr    %cl,%eax
  801701:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801703:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801705:	89 f2                	mov    %esi,%edx
  801707:	f7 74 24 18          	divl   0x18(%esp)
  80170b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80170d:	f7 64 24 0c          	mull   0xc(%esp)
  801711:	89 c5                	mov    %eax,%ebp
  801713:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801715:	39 d6                	cmp    %edx,%esi
  801717:	72 67                	jb     801780 <__umoddi3+0x114>
  801719:	74 75                	je     801790 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80171b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80171f:	29 e8                	sub    %ebp,%eax
  801721:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801723:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801727:	d3 e8                	shr    %cl,%eax
  801729:	89 f2                	mov    %esi,%edx
  80172b:	89 f9                	mov    %edi,%ecx
  80172d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80172f:	09 d0                	or     %edx,%eax
  801731:	89 f2                	mov    %esi,%edx
  801733:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801737:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801739:	83 c4 20             	add    $0x20,%esp
  80173c:	5e                   	pop    %esi
  80173d:	5f                   	pop    %edi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801740:	85 c9                	test   %ecx,%ecx
  801742:	75 0b                	jne    80174f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801744:	b8 01 00 00 00       	mov    $0x1,%eax
  801749:	31 d2                	xor    %edx,%edx
  80174b:	f7 f1                	div    %ecx
  80174d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80174f:	89 f0                	mov    %esi,%eax
  801751:	31 d2                	xor    %edx,%edx
  801753:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801755:	89 f8                	mov    %edi,%eax
  801757:	e9 3e ff ff ff       	jmp    80169a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80175c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80175e:	83 c4 20             	add    $0x20,%esp
  801761:	5e                   	pop    %esi
  801762:	5f                   	pop    %edi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    
  801765:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801768:	39 f5                	cmp    %esi,%ebp
  80176a:	72 04                	jb     801770 <__umoddi3+0x104>
  80176c:	39 f9                	cmp    %edi,%ecx
  80176e:	77 06                	ja     801776 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801770:	89 f2                	mov    %esi,%edx
  801772:	29 cf                	sub    %ecx,%edi
  801774:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801776:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801778:	83 c4 20             	add    $0x20,%esp
  80177b:	5e                   	pop    %esi
  80177c:	5f                   	pop    %edi
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    
  80177f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801780:	89 d1                	mov    %edx,%ecx
  801782:	89 c5                	mov    %eax,%ebp
  801784:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801788:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80178c:	eb 8d                	jmp    80171b <__umoddi3+0xaf>
  80178e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801790:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801794:	72 ea                	jb     801780 <__umoddi3+0x114>
  801796:	89 f1                	mov    %esi,%ecx
  801798:	eb 81                	jmp    80171b <__umoddi3+0xaf>
