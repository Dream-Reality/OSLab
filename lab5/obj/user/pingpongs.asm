
obj/user/pingpongs.debug:     file format elf32-i386


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
  80003d:	e8 c8 11 00 00       	call   80120a <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5f                	je     8000a8 <umain+0x74>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	a1 08 40 80 00       	mov    0x804008,%eax
  80004e:	8b 18                	mov    (%eax),%ebx
  800050:	e8 6a 0b 00 00       	call   800bbf <sys_getenvid>
  800055:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800059:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005d:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  800064:	e8 f7 01 00 00       	call   800260 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800069:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006c:	e8 4e 0b 00 00       	call   800bbf <sys_getenvid>
  800071:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800075:	89 44 24 04          	mov    %eax,0x4(%esp)
  800079:	c7 04 24 9a 26 80 00 	movl   $0x80269a,(%esp)
  800080:	e8 db 01 00 00       	call   800260 <cprintf>
		ipc_send(who, 0, 0, 0);
  800085:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008c:	00 
  80008d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800094:	00 
  800095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009c:	00 
  80009d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000a0:	89 04 24             	mov    %eax,(%esp)
  8000a3:	e8 75 13 00 00       	call   80141d <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 ed 12 00 00       	call   8013b0 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8000c8:	8b 18                	mov    (%eax),%ebx
  8000ca:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000d0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000d6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d9:	e8 e1 0a 00 00       	call   800bbf <sys_getenvid>
  8000de:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000ed:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f5:	c7 04 24 b0 26 80 00 	movl   $0x8026b0,(%esp)
  8000fc:	e8 5f 01 00 00       	call   800260 <cprintf>
		if (val == 10)
  800101:	a1 04 40 80 00       	mov    0x804004,%eax
  800106:	83 f8 0a             	cmp    $0xa,%eax
  800109:	74 36                	je     800141 <umain+0x10d>
			return;
		++val;
  80010b:	40                   	inc    %eax
  80010c:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 e9 12 00 00       	call   80141d <ipc_send>
		if (val == 10)
  800134:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
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
  80015a:	e8 60 0a 00 00       	call   800bbf <sys_getenvid>
  80015f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800164:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80016b:	c1 e0 07             	shl    $0x7,%eax
  80016e:	29 d0                	sub    %edx,%eax
  800170:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800175:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800178:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80017b:	a3 08 40 80 00       	mov    %eax,0x804008
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800180:	85 f6                	test   %esi,%esi
  800182:	7e 07                	jle    80018b <libmain+0x3f>
		binaryname = argv[0];
  800184:	8b 03                	mov    (%ebx),%eax
  800186:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80018b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018f:	89 34 24             	mov    %esi,(%esp)
  800192:	e8 9d fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800197:	e8 08 00 00 00       	call   8001a4 <exit>
}
  80019c:	83 c4 20             	add    $0x20,%esp
  80019f:	5b                   	pop    %ebx
  8001a0:	5e                   	pop    %esi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    
	...

008001a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001aa:	e8 02 15 00 00       	call   8016b1 <close_all>
	sys_env_destroy(0);
  8001af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b6:	e8 b2 09 00 00       	call   800b6d <sys_env_destroy>
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    
  8001bd:	00 00                	add    %al,(%eax)
	...

008001c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 14             	sub    $0x14,%esp
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ca:	8b 03                	mov    (%ebx),%eax
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d3:	40                   	inc    %eax
  8001d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	75 19                	jne    8001f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e4:	00 
  8001e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 40 09 00 00       	call   800b30 <sys_cputs>
		b->idx = 0;
  8001f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f6:	ff 43 04             	incl   0x4(%ebx)
}
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800208:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020f:	00 00 00 
	b.cnt = 0;
  800212:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800219:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	c7 04 24 c0 01 80 00 	movl   $0x8001c0,(%esp)
  80023b:	e8 82 01 00 00       	call   8003c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800240:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 d8 08 00 00       	call   800b30 <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	e8 87 ff ff ff       	call   8001ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    
	...

0080027c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 3c             	sub    $0x3c,%esp
  800285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800288:	89 d7                	mov    %edx,%edi
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800299:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029c:	85 c0                	test   %eax,%eax
  80029e:	75 08                	jne    8002a8 <printnum+0x2c>
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a6:	77 57                	ja     8002ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ac:	4b                   	dec    %ebx
  8002ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c7:	00 
  8002c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	e8 52 21 00 00       	call   80242c <__udivdi3>
  8002da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e9:	89 fa                	mov    %edi,%edx
  8002eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ee:	e8 89 ff ff ff       	call   80027c <printnum>
  8002f3:	eb 0f                	jmp    800304 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ff:	4b                   	dec    %ebx
  800300:	85 db                	test   %ebx,%ebx
  800302:	7f f1                	jg     8002f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800304:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800308:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800313:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031a:	00 
  80031b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031e:	89 04 24             	mov    %eax,(%esp)
  800321:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800324:	89 44 24 04          	mov    %eax,0x4(%esp)
  800328:	e8 1f 22 00 00       	call   80254c <__umoddi3>
  80032d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800331:	0f be 80 e0 26 80 00 	movsbl 0x8026e0(%eax),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033e:	83 c4 3c             	add    $0x3c,%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7e 0e                	jle    80035c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 08             	lea    0x8(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	8b 52 04             	mov    0x4(%edx),%edx
  80035a:	eb 22                	jmp    80037e <getuint+0x38>
	else if (lflag)
  80035c:	85 d2                	test   %edx,%edx
  80035e:	74 10                	je     800370 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	eb 0e                	jmp    80037e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800386:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	3b 50 04             	cmp    0x4(%eax),%edx
  80038e:	73 08                	jae    800398 <sprintputch+0x18>
		*b->buf++ = ch;
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	88 0a                	mov    %cl,(%edx)
  800395:	42                   	inc    %edx
  800396:	89 10                	mov    %edx,(%eax)
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 02 00 00 00       	call   8003c2 <vprintfmt>
	va_end(ap);
}
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    

008003c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	57                   	push   %edi
  8003c6:	56                   	push   %esi
  8003c7:	53                   	push   %ebx
  8003c8:	83 ec 4c             	sub    $0x4c,%esp
  8003cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d1:	eb 12                	jmp    8003e5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	0f 84 6b 03 00 00    	je     800746 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e5:	0f b6 06             	movzbl (%esi),%eax
  8003e8:	46                   	inc    %esi
  8003e9:	83 f8 25             	cmp    $0x25,%eax
  8003ec:	75 e5                	jne    8003d3 <vprintfmt+0x11>
  8003ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800405:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040a:	eb 26                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800413:	eb 1d                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800418:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80041c:	eb 14                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800421:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800428:	eb 08                	jmp    800432 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80042d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	0f b6 06             	movzbl (%esi),%eax
  800435:	8d 56 01             	lea    0x1(%esi),%edx
  800438:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043b:	8a 16                	mov    (%esi),%dl
  80043d:	83 ea 23             	sub    $0x23,%edx
  800440:	80 fa 55             	cmp    $0x55,%dl
  800443:	0f 87 e1 02 00 00    	ja     80072a <vprintfmt+0x368>
  800449:	0f b6 d2             	movzbl %dl,%edx
  80044c:	ff 24 95 20 28 80 00 	jmp    *0x802820(,%edx,4)
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800456:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80045e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800462:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800465:	8d 50 d0             	lea    -0x30(%eax),%edx
  800468:	83 fa 09             	cmp    $0x9,%edx
  80046b:	77 2a                	ja     800497 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046e:	eb eb                	jmp    80045b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047e:	eb 17                	jmp    800497 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800480:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800484:	78 98                	js     80041e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800489:	eb a7                	jmp    800432 <vprintfmt+0x70>
  80048b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800495:	eb 9b                	jmp    800432 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049b:	79 95                	jns    800432 <vprintfmt+0x70>
  80049d:	eb 8b                	jmp    80042a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a3:	eb 8d                	jmp    800432 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004bd:	e9 23 ff ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	79 02                	jns    8004d3 <vprintfmt+0x111>
  8004d1:	f7 d8                	neg    %eax
  8004d3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d5:	83 f8 0f             	cmp    $0xf,%eax
  8004d8:	7f 0b                	jg     8004e5 <vprintfmt+0x123>
  8004da:	8b 04 85 80 29 80 00 	mov    0x802980(,%eax,4),%eax
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	75 23                	jne    800508 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e9:	c7 44 24 08 f8 26 80 	movl   $0x8026f8,0x8(%esp)
  8004f0:	00 
  8004f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	e8 9a fe ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800503:	e9 dd fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800508:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050c:	c7 44 24 08 15 2b 80 	movl   $0x802b15,0x8(%esp)
  800513:	00 
  800514:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800518:	8b 55 08             	mov    0x8(%ebp),%edx
  80051b:	89 14 24             	mov    %edx,(%esp)
  80051e:	e8 77 fe ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800526:	e9 ba fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
  80052b:	89 f9                	mov    %edi,%ecx
  80052d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800530:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 30                	mov    (%eax),%esi
  80053e:	85 f6                	test   %esi,%esi
  800540:	75 05                	jne    800547 <vprintfmt+0x185>
				p = "(null)";
  800542:	be f1 26 80 00       	mov    $0x8026f1,%esi
			if (width > 0 && padc != '-')
  800547:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054b:	0f 8e 84 00 00 00    	jle    8005d5 <vprintfmt+0x213>
  800551:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800555:	74 7e                	je     8005d5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055b:	89 34 24             	mov    %esi,(%esp)
  80055e:	e8 8b 02 00 00       	call   8007ee <strnlen>
  800563:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800566:	29 c2                	sub    %eax,%edx
  800568:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80056b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80056f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800572:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800575:	89 de                	mov    %ebx,%esi
  800577:	89 d3                	mov    %edx,%ebx
  800579:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	eb 0b                	jmp    800588 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80057d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800581:	89 3c 24             	mov    %edi,(%esp)
  800584:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800587:	4b                   	dec    %ebx
  800588:	85 db                	test   %ebx,%ebx
  80058a:	7f f1                	jg     80057d <vprintfmt+0x1bb>
  80058c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80058f:	89 f3                	mov    %esi,%ebx
  800591:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	79 05                	jns    8005a0 <vprintfmt+0x1de>
  80059b:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a3:	29 c2                	sub    %eax,%edx
  8005a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a8:	eb 2b                	jmp    8005d5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ae:	74 18                	je     8005c8 <vprintfmt+0x206>
  8005b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b3:	83 fa 5e             	cmp    $0x5e,%edx
  8005b6:	76 10                	jbe    8005c8 <vprintfmt+0x206>
					putch('?', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
  8005c6:	eb 0a                	jmp    8005d2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	89 04 24             	mov    %eax,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d5:	0f be 06             	movsbl (%esi),%eax
  8005d8:	46                   	inc    %esi
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	74 21                	je     8005fe <vprintfmt+0x23c>
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	78 c9                	js     8005aa <vprintfmt+0x1e8>
  8005e1:	4f                   	dec    %edi
  8005e2:	79 c6                	jns    8005aa <vprintfmt+0x1e8>
  8005e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e7:	89 de                	mov    %ebx,%esi
  8005e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ec:	eb 18                	jmp    800606 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fb:	4b                   	dec    %ebx
  8005fc:	eb 08                	jmp    800606 <vprintfmt+0x244>
  8005fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800601:	89 de                	mov    %ebx,%esi
  800603:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800606:	85 db                	test   %ebx,%ebx
  800608:	7f e4                	jg     8005ee <vprintfmt+0x22c>
  80060a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80060d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800612:	e9 ce fd ff ff       	jmp    8003e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800617:	83 f9 01             	cmp    $0x1,%ecx
  80061a:	7e 10                	jle    80062c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 08             	lea    0x8(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 30                	mov    (%eax),%esi
  800627:	8b 78 04             	mov    0x4(%eax),%edi
  80062a:	eb 26                	jmp    800652 <vprintfmt+0x290>
	else if (lflag)
  80062c:	85 c9                	test   %ecx,%ecx
  80062e:	74 12                	je     800642 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 04             	lea    0x4(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	8b 30                	mov    (%eax),%esi
  80063b:	89 f7                	mov    %esi,%edi
  80063d:	c1 ff 1f             	sar    $0x1f,%edi
  800640:	eb 10                	jmp    800652 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	8b 30                	mov    (%eax),%esi
  80064d:	89 f7                	mov    %esi,%edi
  80064f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800652:	85 ff                	test   %edi,%edi
  800654:	78 0a                	js     800660 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 8c 00 00 00       	jmp    8006ec <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800664:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066e:	f7 de                	neg    %esi
  800670:	83 d7 00             	adc    $0x0,%edi
  800673:	f7 df                	neg    %edi
			}
			base = 10;
  800675:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067a:	eb 70                	jmp    8006ec <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067c:	89 ca                	mov    %ecx,%edx
  80067e:	8d 45 14             	lea    0x14(%ebp),%eax
  800681:	e8 c0 fc ff ff       	call   800346 <getuint>
  800686:	89 c6                	mov    %eax,%esi
  800688:	89 d7                	mov    %edx,%edi
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80068f:	eb 5b                	jmp    8006ec <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800691:	89 ca                	mov    %ecx,%edx
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 ab fc ff ff       	call   800346 <getuint>
  80069b:	89 c6                	mov    %eax,%esi
  80069d:	89 d7                	mov    %edx,%edi
			base = 8;
  80069f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006a4:	eb 46                	jmp    8006ec <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 04             	lea    0x4(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cb:	8b 30                	mov    (%eax),%esi
  8006cd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d7:	eb 13                	jmp    8006ec <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d9:	89 ca                	mov    %ecx,%edx
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
  8006de:	e8 63 fc ff ff       	call   800346 <getuint>
  8006e3:	89 c6                	mov    %eax,%esi
  8006e5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ec:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ff:	89 34 24             	mov    %esi,(%esp)
  800702:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800706:	89 da                	mov    %ebx,%edx
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	e8 6c fb ff ff       	call   80027c <printnum>
			break;
  800710:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800713:	e9 cd fc ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800718:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800725:	e9 bb fc ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	eb 01                	jmp    80073b <vprintfmt+0x379>
  80073a:	4e                   	dec    %esi
  80073b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80073f:	75 f9                	jne    80073a <vprintfmt+0x378>
  800741:	e9 9f fc ff ff       	jmp    8003e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800746:	83 c4 4c             	add    $0x4c,%esp
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	5f                   	pop    %edi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	83 ec 28             	sub    $0x28,%esp
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800761:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800764:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076b:	85 c0                	test   %eax,%eax
  80076d:	74 30                	je     80079f <vsnprintf+0x51>
  80076f:	85 d2                	test   %edx,%edx
  800771:	7e 33                	jle    8007a6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077a:	8b 45 10             	mov    0x10(%ebp),%eax
  80077d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800781:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	c7 04 24 80 03 80 00 	movl   $0x800380,(%esp)
  80078f:	e8 2e fc ff ff       	call   8003c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800797:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079d:	eb 0c                	jmp    8007ab <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a4:	eb 05                	jmp    8007ab <vsnprintf+0x5d>
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	89 04 24             	mov    %eax,(%esp)
  8007ce:	e8 7b ff ff ff       	call   80074e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    
  8007d5:	00 00                	add    %al,(%eax)
	...

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 01                	jmp    8007e6 <strlen+0xe>
		n++;
  8007e5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ea:	75 f9                	jne    8007e5 <strlen+0xd>
		n++;
	return n;
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	eb 01                	jmp    8007ff <strnlen+0x11>
		n++;
  8007fe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ff:	39 d0                	cmp    %edx,%eax
  800801:	74 06                	je     800809 <strnlen+0x1b>
  800803:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800807:	75 f5                	jne    8007fe <strnlen+0x10>
		n++;
	return n;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800815:	ba 00 00 00 00       	mov    $0x0,%edx
  80081a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80081d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800820:	42                   	inc    %edx
  800821:	84 c9                	test   %cl,%cl
  800823:	75 f5                	jne    80081a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800825:	5b                   	pop    %ebx
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800832:	89 1c 24             	mov    %ebx,(%esp)
  800835:	e8 9e ff ff ff       	call   8007d8 <strlen>
	strcpy(dst + len, src);
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800841:	01 d8                	add    %ebx,%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 c0 ff ff ff       	call   80080b <strcpy>
	return dst;
}
  80084b:	89 d8                	mov    %ebx,%eax
  80084d:	83 c4 08             	add    $0x8,%esp
  800850:	5b                   	pop    %ebx
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	b9 00 00 00 00       	mov    $0x0,%ecx
  800866:	eb 0c                	jmp    800874 <strncpy+0x21>
		*dst++ = *src;
  800868:	8a 1a                	mov    (%edx),%bl
  80086a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086d:	80 3a 01             	cmpb   $0x1,(%edx)
  800870:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800873:	41                   	inc    %ecx
  800874:	39 f1                	cmp    %esi,%ecx
  800876:	75 f0                	jne    800868 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800887:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088a:	85 d2                	test   %edx,%edx
  80088c:	75 0a                	jne    800898 <strlcpy+0x1c>
  80088e:	89 f0                	mov    %esi,%eax
  800890:	eb 1a                	jmp    8008ac <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800892:	88 18                	mov    %bl,(%eax)
  800894:	40                   	inc    %eax
  800895:	41                   	inc    %ecx
  800896:	eb 02                	jmp    80089a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800898:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089a:	4a                   	dec    %edx
  80089b:	74 0a                	je     8008a7 <strlcpy+0x2b>
  80089d:	8a 19                	mov    (%ecx),%bl
  80089f:	84 db                	test   %bl,%bl
  8008a1:	75 ef                	jne    800892 <strlcpy+0x16>
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	eb 02                	jmp    8008a9 <strlcpy+0x2d>
  8008a7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008ac:	29 f0                	sub    %esi,%eax
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bb:	eb 02                	jmp    8008bf <strcmp+0xd>
		p++, q++;
  8008bd:	41                   	inc    %ecx
  8008be:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bf:	8a 01                	mov    (%ecx),%al
  8008c1:	84 c0                	test   %al,%al
  8008c3:	74 04                	je     8008c9 <strcmp+0x17>
  8008c5:	3a 02                	cmp    (%edx),%al
  8008c7:	74 f4                	je     8008bd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 c0             	movzbl %al,%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e0:	eb 03                	jmp    8008e5 <strncmp+0x12>
		n--, p++, q++;
  8008e2:	4a                   	dec    %edx
  8008e3:	40                   	inc    %eax
  8008e4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e5:	85 d2                	test   %edx,%edx
  8008e7:	74 14                	je     8008fd <strncmp+0x2a>
  8008e9:	8a 18                	mov    (%eax),%bl
  8008eb:	84 db                	test   %bl,%bl
  8008ed:	74 04                	je     8008f3 <strncmp+0x20>
  8008ef:	3a 19                	cmp    (%ecx),%bl
  8008f1:	74 ef                	je     8008e2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f3:	0f b6 00             	movzbl (%eax),%eax
  8008f6:	0f b6 11             	movzbl (%ecx),%edx
  8008f9:	29 d0                	sub    %edx,%eax
  8008fb:	eb 05                	jmp    800902 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090e:	eb 05                	jmp    800915 <strchr+0x10>
		if (*s == c)
  800910:	38 ca                	cmp    %cl,%dl
  800912:	74 0c                	je     800920 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800914:	40                   	inc    %eax
  800915:	8a 10                	mov    (%eax),%dl
  800917:	84 d2                	test   %dl,%dl
  800919:	75 f5                	jne    800910 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092b:	eb 05                	jmp    800932 <strfind+0x10>
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 07                	je     800938 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800931:	40                   	inc    %eax
  800932:	8a 10                	mov    (%eax),%dl
  800934:	84 d2                	test   %dl,%dl
  800936:	75 f5                	jne    80092d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800949:	85 c9                	test   %ecx,%ecx
  80094b:	74 30                	je     80097d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800953:	75 25                	jne    80097a <memset+0x40>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 20                	jne    80097a <memset+0x40>
		c &= 0xFF;
  80095a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095d:	89 d3                	mov    %edx,%ebx
  80095f:	c1 e3 08             	shl    $0x8,%ebx
  800962:	89 d6                	mov    %edx,%esi
  800964:	c1 e6 18             	shl    $0x18,%esi
  800967:	89 d0                	mov    %edx,%eax
  800969:	c1 e0 10             	shl    $0x10,%eax
  80096c:	09 f0                	or     %esi,%eax
  80096e:	09 d0                	or     %edx,%eax
  800970:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800972:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 03                	jmp    80097d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 34                	jae    8009ca <memmove+0x46>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2d                	jae    8009ca <memmove+0x46>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	f6 c2 03             	test   $0x3,%dl
  8009a3:	75 1b                	jne    8009c0 <memmove+0x3c>
  8009a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ab:	75 13                	jne    8009c0 <memmove+0x3c>
  8009ad:	f6 c1 03             	test   $0x3,%cl
  8009b0:	75 0e                	jne    8009c0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b2:	83 ef 04             	sub    $0x4,%edi
  8009b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bb:	fd                   	std    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 07                	jmp    8009c7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c0:	4f                   	dec    %edi
  8009c1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c4:	fd                   	std    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c7:	fc                   	cld    
  8009c8:	eb 20                	jmp    8009ea <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d0:	75 13                	jne    8009e5 <memmove+0x61>
  8009d2:	a8 03                	test   $0x3,%al
  8009d4:	75 0f                	jne    8009e5 <memmove+0x61>
  8009d6:	f6 c1 03             	test   $0x3,%cl
  8009d9:	75 0a                	jne    8009e5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009db:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009de:	89 c7                	mov    %eax,%edi
  8009e0:	fc                   	cld    
  8009e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e3:	eb 05                	jmp    8009ea <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 77 ff ff ff       	call   800984 <memmove>
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a23:	eb 16                	jmp    800a3b <memcmp+0x2c>
		if (*s1 != *s2)
  800a25:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a28:	42                   	inc    %edx
  800a29:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a2d:	38 c8                	cmp    %cl,%al
  800a2f:	74 0a                	je     800a3b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a31:	0f b6 c0             	movzbl %al,%eax
  800a34:	0f b6 c9             	movzbl %cl,%ecx
  800a37:	29 c8                	sub    %ecx,%eax
  800a39:	eb 09                	jmp    800a44 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3b:	39 da                	cmp    %ebx,%edx
  800a3d:	75 e6                	jne    800a25 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a57:	eb 05                	jmp    800a5e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a59:	38 08                	cmp    %cl,(%eax)
  800a5b:	74 05                	je     800a62 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5d:	40                   	inc    %eax
  800a5e:	39 d0                	cmp    %edx,%eax
  800a60:	72 f7                	jb     800a59 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a70:	eb 01                	jmp    800a73 <strtol+0xf>
		s++;
  800a72:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a73:	8a 02                	mov    (%edx),%al
  800a75:	3c 20                	cmp    $0x20,%al
  800a77:	74 f9                	je     800a72 <strtol+0xe>
  800a79:	3c 09                	cmp    $0x9,%al
  800a7b:	74 f5                	je     800a72 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7d:	3c 2b                	cmp    $0x2b,%al
  800a7f:	75 08                	jne    800a89 <strtol+0x25>
		s++;
  800a81:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
  800a87:	eb 13                	jmp    800a9c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a89:	3c 2d                	cmp    $0x2d,%al
  800a8b:	75 0a                	jne    800a97 <strtol+0x33>
		s++, neg = 1;
  800a8d:	8d 52 01             	lea    0x1(%edx),%edx
  800a90:	bf 01 00 00 00       	mov    $0x1,%edi
  800a95:	eb 05                	jmp    800a9c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	74 05                	je     800aa5 <strtol+0x41>
  800aa0:	83 fb 10             	cmp    $0x10,%ebx
  800aa3:	75 28                	jne    800acd <strtol+0x69>
  800aa5:	8a 02                	mov    (%edx),%al
  800aa7:	3c 30                	cmp    $0x30,%al
  800aa9:	75 10                	jne    800abb <strtol+0x57>
  800aab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aaf:	75 0a                	jne    800abb <strtol+0x57>
		s += 2, base = 16;
  800ab1:	83 c2 02             	add    $0x2,%edx
  800ab4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab9:	eb 12                	jmp    800acd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	75 0e                	jne    800acd <strtol+0x69>
  800abf:	3c 30                	cmp    $0x30,%al
  800ac1:	75 05                	jne    800ac8 <strtol+0x64>
		s++, base = 8;
  800ac3:	42                   	inc    %edx
  800ac4:	b3 08                	mov    $0x8,%bl
  800ac6:	eb 05                	jmp    800acd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad4:	8a 0a                	mov    (%edx),%cl
  800ad6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x82>
			dig = *s - '0';
  800ade:	0f be c9             	movsbl %cl,%ecx
  800ae1:	83 e9 30             	sub    $0x30,%ecx
  800ae4:	eb 1e                	jmp    800b04 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 57             	sub    $0x57,%ecx
  800af4:	eb 0e                	jmp    800b04 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 12                	ja     800b10 <strtol+0xac>
			dig = *s - 'A' + 10;
  800afe:	0f be c9             	movsbl %cl,%ecx
  800b01:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b04:	39 f1                	cmp    %esi,%ecx
  800b06:	7d 0c                	jge    800b14 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b08:	42                   	inc    %edx
  800b09:	0f af c6             	imul   %esi,%eax
  800b0c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b0e:	eb c4                	jmp    800ad4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b10:	89 c1                	mov    %eax,%ecx
  800b12:	eb 02                	jmp    800b16 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b14:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1a:	74 05                	je     800b21 <strtol+0xbd>
		*endptr = (char *) s;
  800b1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b21:	85 ff                	test   %edi,%edi
  800b23:	74 04                	je     800b29 <strtol+0xc5>
  800b25:	89 c8                	mov    %ecx,%eax
  800b27:	f7 d8                	neg    %eax
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    
	...

00800b30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	89 c7                	mov    %eax,%edi
  800b45:	89 c6                	mov    %eax,%esi
  800b47:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
  800b83:	89 cb                	mov    %ecx,%ebx
  800b85:	89 cf                	mov    %ecx,%edi
  800b87:	89 ce                	mov    %ecx,%esi
  800b89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7e 28                	jle    800bb7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b93:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9a:	00 
  800b9b:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800ba2:	00 
  800ba3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800baa:	00 
  800bab:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800bb2:	e8 21 17 00 00       	call   8022d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb7:	83 c4 2c             	add    $0x2c,%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_yield>:

void
sys_yield(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	be 00 00 00 00       	mov    $0x0,%esi
  800c0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 f7                	mov    %esi,%edi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 28                	jle    800c49 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c25:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c2c:	00 
  800c2d:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800c34:	00 
  800c35:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3c:	00 
  800c3d:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800c44:	e8 8f 16 00 00       	call   8022d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c49:	83 c4 2c             	add    $0x2c,%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 28                	jle    800c9c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c78:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c7f:	00 
  800c80:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800c87:	00 
  800c88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8f:	00 
  800c90:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800c97:	e8 3c 16 00 00       	call   8022d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c9c:	83 c4 2c             	add    $0x2c,%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 df                	mov    %ebx,%edi
  800cbf:	89 de                	mov    %ebx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 28                	jle    800cef <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800cda:	00 
  800cdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce2:	00 
  800ce3:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800cea:	e8 e9 15 00 00       	call   8022d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cef:	83 c4 2c             	add    $0x2c,%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d05:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d10:	89 df                	mov    %ebx,%edi
  800d12:	89 de                	mov    %ebx,%esi
  800d14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 28                	jle    800d42 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d25:	00 
  800d26:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800d2d:	00 
  800d2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d35:	00 
  800d36:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800d3d:	e8 96 15 00 00       	call   8022d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d42:	83 c4 2c             	add    $0x2c,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 28                	jle    800d95 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d71:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d78:	00 
  800d79:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800d80:	00 
  800d81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d88:	00 
  800d89:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800d90:	e8 43 15 00 00       	call   8022d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d95:	83 c4 2c             	add    $0x2c,%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dab:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 df                	mov    %ebx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7e 28                	jle    800de8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dcb:	00 
  800dcc:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddb:	00 
  800ddc:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800de3:	e8 f0 14 00 00       	call   8022d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de8:	83 c4 2c             	add    $0x2c,%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	be 00 00 00 00       	mov    $0x0,%esi
  800dfb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e21:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 cb                	mov    %ecx,%ebx
  800e2b:	89 cf                	mov    %ecx,%edi
  800e2d:	89 ce                	mov    %ecx,%esi
  800e2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 28                	jle    800e5d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e39:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e40:	00 
  800e41:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800e48:	00 
  800e49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e50:	00 
  800e51:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800e58:	e8 7b 14 00 00       	call   8022d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e5d:	83 c4 2c             	add    $0x2c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	00 00                	add    %al,(%eax)
	...

00800e68 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 3c             	sub    $0x3c,%esp
  800e71:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800e74:	89 d6                	mov    %edx,%esi
  800e76:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800e79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e80:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800e83:	e8 37 fd ff ff       	call   800bbf <sys_getenvid>
  800e88:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800e8a:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800e91:	74 31                	je     800ec4 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800e93:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800e9a:	00 
  800e9b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ea2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eaa:	89 3c 24             	mov    %edi,(%esp)
  800ead:	e8 9f fd ff ff       	call   800c51 <sys_page_map>
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	0f 8e ae 00 00 00    	jle    800f68 <duppage+0x100>
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebf:	e9 a4 00 00 00       	jmp    800f68 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ec7:	25 02 08 00 00       	and    $0x802,%eax
  800ecc:	83 f8 01             	cmp    $0x1,%eax
  800ecf:	19 db                	sbb    %ebx,%ebx
  800ed1:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800ed7:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800edd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800ee1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ee5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ee8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eec:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef0:	89 3c 24             	mov    %edi,(%esp)
  800ef3:	e8 59 fd ff ff       	call   800c51 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	79 1c                	jns    800f18 <duppage+0xb0>
  800efc:	c7 44 24 08 0a 2a 80 	movl   $0x802a0a,0x8(%esp)
  800f03:	00 
  800f04:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800f0b:	00 
  800f0c:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  800f13:	e8 c0 13 00 00       	call   8022d8 <_panic>
	if ((perm|~pte)&PTE_COW){
  800f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1b:	f7 d0                	not    %eax
  800f1d:	09 d8                	or     %ebx,%eax
  800f1f:	f6 c4 08             	test   $0x8,%ah
  800f22:	74 38                	je     800f5c <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800f24:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800f28:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f2c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f30:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f34:	89 3c 24             	mov    %edi,(%esp)
  800f37:	e8 15 fd ff ff       	call   800c51 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	79 23                	jns    800f63 <duppage+0xfb>
  800f40:	c7 44 24 08 0a 2a 80 	movl   $0x802a0a,0x8(%esp)
  800f47:	00 
  800f48:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800f4f:	00 
  800f50:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  800f57:	e8 7c 13 00 00       	call   8022d8 <_panic>
	}
	return 0;
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f61:	eb 05                	jmp    800f68 <duppage+0x100>
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  800f68:	83 c4 3c             	add    $0x3c,%esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 20             	sub    $0x20,%esp
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f7b:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800f7d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f81:	75 1c                	jne    800f9f <pgfault+0x2f>
		panic("pgfault: error!\n");
  800f83:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f92:	00 
  800f93:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  800f9a:	e8 39 13 00 00       	call   8022d8 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800f9f:	89 f0                	mov    %esi,%eax
  800fa1:	c1 e8 0c             	shr    $0xc,%eax
  800fa4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fab:	f6 c4 08             	test   $0x8,%ah
  800fae:	75 1c                	jne    800fcc <pgfault+0x5c>
		panic("pgfault: error!\n");
  800fb0:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800fbf:	00 
  800fc0:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  800fc7:	e8 0c 13 00 00       	call   8022d8 <_panic>
	envid_t envid = sys_getenvid();
  800fcc:	e8 ee fb ff ff       	call   800bbf <sys_getenvid>
  800fd1:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800fd3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fe2:	00 
  800fe3:	89 04 24             	mov    %eax,(%esp)
  800fe6:	e8 12 fc ff ff       	call   800bfd <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800feb:	85 c0                	test   %eax,%eax
  800fed:	79 1c                	jns    80100b <pgfault+0x9b>
  800fef:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800ffe:	00 
  800fff:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  801006:	e8 cd 12 00 00       	call   8022d8 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  80100b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  801011:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801018:	00 
  801019:	89 74 24 04          	mov    %esi,0x4(%esp)
  80101d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801024:	e8 c5 f9 ff ff       	call   8009ee <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  801029:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801030:	00 
  801031:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801035:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801039:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801040:	00 
  801041:	89 1c 24             	mov    %ebx,(%esp)
  801044:	e8 08 fc ff ff       	call   800c51 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 1c                	jns    801069 <pgfault+0xf9>
  80104d:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  801064:	e8 6f 12 00 00       	call   8022d8 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801069:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801070:	00 
  801071:	89 1c 24             	mov    %ebx,(%esp)
  801074:	e8 2b fc ff ff       	call   800ca4 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  801079:	85 c0                	test   %eax,%eax
  80107b:	79 1c                	jns    801099 <pgfault+0x129>
  80107d:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  801084:	00 
  801085:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80108c:	00 
  80108d:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  801094:	e8 3f 12 00 00       	call   8022d8 <_panic>
	return;
	panic("pgfault not implemented");
}
  801099:	83 c4 20             	add    $0x20,%esp
  80109c:	5b                   	pop    %ebx
  80109d:	5e                   	pop    %esi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8010a9:	c7 04 24 70 0f 80 00 	movl   $0x800f70,(%esp)
  8010b0:	e8 7b 12 00 00       	call   802330 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010b5:	bf 07 00 00 00       	mov    $0x7,%edi
  8010ba:	89 f8                	mov    %edi,%eax
  8010bc:	cd 30                	int    $0x30
  8010be:	89 c7                	mov    %eax,%edi
  8010c0:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	79 1c                	jns    8010e2 <fork+0x42>
		panic("fork : error!\n");
  8010c6:	c7 44 24 08 43 2a 80 	movl   $0x802a43,0x8(%esp)
  8010cd:	00 
  8010ce:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  8010d5:	00 
  8010d6:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8010dd:	e8 f6 11 00 00       	call   8022d8 <_panic>
	if (envid==0){
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	75 28                	jne    80110e <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  8010e6:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8010ec:	e8 ce fa ff ff       	call   800bbf <sys_getenvid>
  8010f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010f6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010fd:	c1 e0 07             	shl    $0x7,%eax
  801100:	29 d0                	sub    %edx,%eax
  801102:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801107:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  801109:	e9 f2 00 00 00       	jmp    801200 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  80110e:	e8 ac fa ff ff       	call   800bbf <sys_getenvid>
  801113:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801116:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  80111b:	89 d8                	mov    %ebx,%eax
  80111d:	c1 e8 16             	shr    $0x16,%eax
  801120:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801127:	a8 01                	test   $0x1,%al
  801129:	74 17                	je     801142 <fork+0xa2>
  80112b:	89 da                	mov    %ebx,%edx
  80112d:	c1 ea 0c             	shr    $0xc,%edx
  801130:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801137:	a8 01                	test   $0x1,%al
  801139:	74 07                	je     801142 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  80113b:	89 f0                	mov    %esi,%eax
  80113d:	e8 26 fd ff ff       	call   800e68 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801142:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801148:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80114e:	75 cb                	jne    80111b <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801150:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801157:	00 
  801158:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80115f:	ee 
  801160:	89 3c 24             	mov    %edi,(%esp)
  801163:	e8 95 fa ff ff       	call   800bfd <sys_page_alloc>
  801168:	85 c0                	test   %eax,%eax
  80116a:	79 1c                	jns    801188 <fork+0xe8>
  80116c:	c7 44 24 08 43 2a 80 	movl   $0x802a43,0x8(%esp)
  801173:	00 
  801174:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  801183:	e8 50 11 00 00       	call   8022d8 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  801188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80118b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801190:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801197:	c1 e0 07             	shl    $0x7,%eax
  80119a:	29 d0                	sub    %edx,%eax
  80119c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a1:	8b 40 64             	mov    0x64(%eax),%eax
  8011a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a8:	89 3c 24             	mov    %edi,(%esp)
  8011ab:	e8 ed fb ff ff       	call   800d9d <sys_env_set_pgfault_upcall>
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	79 1c                	jns    8011d0 <fork+0x130>
  8011b4:	c7 44 24 08 43 2a 80 	movl   $0x802a43,0x8(%esp)
  8011bb:	00 
  8011bc:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8011c3:	00 
  8011c4:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8011cb:	e8 08 11 00 00       	call   8022d8 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8011d0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011d7:	00 
  8011d8:	89 3c 24             	mov    %edi,(%esp)
  8011db:	e8 17 fb ff ff       	call   800cf7 <sys_env_set_status>
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	79 1c                	jns    801200 <fork+0x160>
  8011e4:	c7 44 24 08 43 2a 80 	movl   $0x802a43,0x8(%esp)
  8011eb:	00 
  8011ec:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8011f3:	00 
  8011f4:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8011fb:	e8 d8 10 00 00       	call   8022d8 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801200:	89 f8                	mov    %edi,%eax
  801202:	83 c4 2c             	add    $0x2c,%esp
  801205:	5b                   	pop    %ebx
  801206:	5e                   	pop    %esi
  801207:	5f                   	pop    %edi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <sfork>:

// Challenge!
int
sfork(void)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	57                   	push   %edi
  80120e:	56                   	push   %esi
  80120f:	53                   	push   %ebx
  801210:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  801213:	c7 04 24 70 0f 80 00 	movl   $0x800f70,(%esp)
  80121a:	e8 11 11 00 00       	call   802330 <set_pgfault_handler>
  80121f:	ba 07 00 00 00       	mov    $0x7,%edx
  801224:	89 d0                	mov    %edx,%eax
  801226:	cd 30                	int    $0x30
  801228:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80122b:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  80122d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801231:	c7 04 24 37 2a 80 00 	movl   $0x802a37,(%esp)
  801238:	e8 23 f0 ff ff       	call   800260 <cprintf>
	if (envid<0)
  80123d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801241:	79 1c                	jns    80125f <sfork+0x55>
		panic("sfork : error!\n");
  801243:	c7 44 24 08 42 2a 80 	movl   $0x802a42,0x8(%esp)
  80124a:	00 
  80124b:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  801252:	00 
  801253:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  80125a:	e8 79 10 00 00       	call   8022d8 <_panic>
	if (envid==0){
  80125f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801263:	75 28                	jne    80128d <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  801265:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80126b:	e8 4f f9 ff ff       	call   800bbf <sys_getenvid>
  801270:	25 ff 03 00 00       	and    $0x3ff,%eax
  801275:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80127c:	c1 e0 07             	shl    $0x7,%eax
  80127f:	29 d0                	sub    %edx,%eax
  801281:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801286:	89 03                	mov    %eax,(%ebx)
		return envid;
  801288:	e9 18 01 00 00       	jmp    8013a5 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  80128d:	e8 2d f9 ff ff       	call   800bbf <sys_getenvid>
  801292:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801294:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801299:	89 d8                	mov    %ebx,%eax
  80129b:	c1 e8 16             	shr    $0x16,%eax
  80129e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012a5:	a8 01                	test   $0x1,%al
  8012a7:	74 2c                	je     8012d5 <sfork+0xcb>
  8012a9:	89 d8                	mov    %ebx,%eax
  8012ab:	c1 e8 0c             	shr    $0xc,%eax
  8012ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b5:	a8 01                	test   $0x1,%al
  8012b7:	74 1c                	je     8012d5 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8012b9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012c0:	00 
  8012c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012c5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012cd:	89 3c 24             	mov    %edi,(%esp)
  8012d0:	e8 7c f9 ff ff       	call   800c51 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8012d5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012db:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8012e1:	75 b6                	jne    801299 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  8012e3:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  8012e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012eb:	e8 78 fb ff ff       	call   800e68 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  8012f0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012f7:	00 
  8012f8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012ff:	ee 
  801300:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801303:	89 04 24             	mov    %eax,(%esp)
  801306:	e8 f2 f8 ff ff       	call   800bfd <sys_page_alloc>
  80130b:	85 c0                	test   %eax,%eax
  80130d:	79 1c                	jns    80132b <sfork+0x121>
  80130f:	c7 44 24 08 42 2a 80 	movl   $0x802a42,0x8(%esp)
  801316:	00 
  801317:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  80131e:	00 
  80131f:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  801326:	e8 ad 0f 00 00       	call   8022d8 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  80132b:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801331:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801338:	c1 e7 07             	shl    $0x7,%edi
  80133b:	29 d7                	sub    %edx,%edi
  80133d:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  801343:	89 44 24 04          	mov    %eax,0x4(%esp)
  801347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80134a:	89 04 24             	mov    %eax,(%esp)
  80134d:	e8 4b fa ff ff       	call   800d9d <sys_env_set_pgfault_upcall>
  801352:	85 c0                	test   %eax,%eax
  801354:	79 1c                	jns    801372 <sfork+0x168>
  801356:	c7 44 24 08 42 2a 80 	movl   $0x802a42,0x8(%esp)
  80135d:	00 
  80135e:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  801365:	00 
  801366:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  80136d:	e8 66 0f 00 00       	call   8022d8 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  801372:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801379:	00 
  80137a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80137d:	89 04 24             	mov    %eax,(%esp)
  801380:	e8 72 f9 ff ff       	call   800cf7 <sys_env_set_status>
  801385:	85 c0                	test   %eax,%eax
  801387:	79 1c                	jns    8013a5 <sfork+0x19b>
  801389:	c7 44 24 08 42 2a 80 	movl   $0x802a42,0x8(%esp)
  801390:	00 
  801391:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801398:	00 
  801399:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8013a0:	e8 33 0f 00 00       	call   8022d8 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8013a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a8:	83 c4 3c             	add    $0x3c,%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5e                   	pop    %esi
  8013ad:	5f                   	pop    %edi
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	56                   	push   %esi
  8013b4:	53                   	push   %ebx
  8013b5:	83 ec 10             	sub    $0x10,%esp
  8013b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013be:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	75 05                	jne    8013ca <ipc_recv+0x1a>
  8013c5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  8013ca:	89 04 24             	mov    %eax,(%esp)
  8013cd:	e8 41 fa ff ff       	call   800e13 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	79 16                	jns    8013ec <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  8013d6:	85 db                	test   %ebx,%ebx
  8013d8:	74 06                	je     8013e0 <ipc_recv+0x30>
  8013da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  8013e0:	85 f6                	test   %esi,%esi
  8013e2:	74 32                	je     801416 <ipc_recv+0x66>
  8013e4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8013ea:	eb 2a                	jmp    801416 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8013ec:	85 db                	test   %ebx,%ebx
  8013ee:	74 0c                	je     8013fc <ipc_recv+0x4c>
  8013f0:	a1 08 40 80 00       	mov    0x804008,%eax
  8013f5:	8b 00                	mov    (%eax),%eax
  8013f7:	8b 40 74             	mov    0x74(%eax),%eax
  8013fa:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8013fc:	85 f6                	test   %esi,%esi
  8013fe:	74 0c                	je     80140c <ipc_recv+0x5c>
  801400:	a1 08 40 80 00       	mov    0x804008,%eax
  801405:	8b 00                	mov    (%eax),%eax
  801407:	8b 40 78             	mov    0x78(%eax),%eax
  80140a:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  80140c:	a1 08 40 80 00       	mov    0x804008,%eax
  801411:	8b 00                	mov    (%eax),%eax
  801413:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	5b                   	pop    %ebx
  80141a:	5e                   	pop    %esi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	57                   	push   %edi
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
  801423:	83 ec 1c             	sub    $0x1c,%esp
  801426:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801429:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80142c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80142f:	85 db                	test   %ebx,%ebx
  801431:	75 05                	jne    801438 <ipc_send+0x1b>
  801433:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801438:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80143c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801440:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	89 04 24             	mov    %eax,(%esp)
  80144a:	e8 a1 f9 ff ff       	call   800df0 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  80144f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801452:	75 07                	jne    80145b <ipc_send+0x3e>
  801454:	e8 85 f7 ff ff       	call   800bde <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801459:	eb dd                	jmp    801438 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  80145b:	85 c0                	test   %eax,%eax
  80145d:	79 1c                	jns    80147b <ipc_send+0x5e>
  80145f:	c7 44 24 08 52 2a 80 	movl   $0x802a52,0x8(%esp)
  801466:	00 
  801467:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80146e:	00 
  80146f:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  801476:	e8 5d 0e 00 00       	call   8022d8 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  80147b:	83 c4 1c             	add    $0x1c,%esp
  80147e:	5b                   	pop    %ebx
  80147f:	5e                   	pop    %esi
  801480:	5f                   	pop    %edi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	53                   	push   %ebx
  801487:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80148a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80148f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801496:	89 c2                	mov    %eax,%edx
  801498:	c1 e2 07             	shl    $0x7,%edx
  80149b:	29 ca                	sub    %ecx,%edx
  80149d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014a3:	8b 52 50             	mov    0x50(%edx),%edx
  8014a6:	39 da                	cmp    %ebx,%edx
  8014a8:	75 0f                	jne    8014b9 <ipc_find_env+0x36>
			return envs[i].env_id;
  8014aa:	c1 e0 07             	shl    $0x7,%eax
  8014ad:	29 c8                	sub    %ecx,%eax
  8014af:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014b4:	8b 40 40             	mov    0x40(%eax),%eax
  8014b7:	eb 0c                	jmp    8014c5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014b9:	40                   	inc    %eax
  8014ba:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014bf:	75 ce                	jne    80148f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014c1:	66 b8 00 00          	mov    $0x0,%ax
}
  8014c5:	5b                   	pop    %ebx
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    

008014c8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8014d3:	c1 e8 0c             	shr    $0xc,%eax
}
  8014d6:	5d                   	pop    %ebp
  8014d7:	c3                   	ret    

008014d8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014de:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e1:	89 04 24             	mov    %eax,(%esp)
  8014e4:	e8 df ff ff ff       	call   8014c8 <fd2num>
  8014e9:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014ee:	c1 e0 0c             	shl    $0xc,%eax
}
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	53                   	push   %ebx
  8014f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014fa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014ff:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801501:	89 c2                	mov    %eax,%edx
  801503:	c1 ea 16             	shr    $0x16,%edx
  801506:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80150d:	f6 c2 01             	test   $0x1,%dl
  801510:	74 11                	je     801523 <fd_alloc+0x30>
  801512:	89 c2                	mov    %eax,%edx
  801514:	c1 ea 0c             	shr    $0xc,%edx
  801517:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80151e:	f6 c2 01             	test   $0x1,%dl
  801521:	75 09                	jne    80152c <fd_alloc+0x39>
			*fd_store = fd;
  801523:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801525:	b8 00 00 00 00       	mov    $0x0,%eax
  80152a:	eb 17                	jmp    801543 <fd_alloc+0x50>
  80152c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801531:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801536:	75 c7                	jne    8014ff <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801538:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80153e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801543:	5b                   	pop    %ebx
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    

00801546 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80154c:	83 f8 1f             	cmp    $0x1f,%eax
  80154f:	77 36                	ja     801587 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801551:	05 00 00 0d 00       	add    $0xd0000,%eax
  801556:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801559:	89 c2                	mov    %eax,%edx
  80155b:	c1 ea 16             	shr    $0x16,%edx
  80155e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801565:	f6 c2 01             	test   $0x1,%dl
  801568:	74 24                	je     80158e <fd_lookup+0x48>
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	c1 ea 0c             	shr    $0xc,%edx
  80156f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801576:	f6 c2 01             	test   $0x1,%dl
  801579:	74 1a                	je     801595 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80157b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157e:	89 02                	mov    %eax,(%edx)
	return 0;
  801580:	b8 00 00 00 00       	mov    $0x0,%eax
  801585:	eb 13                	jmp    80159a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801587:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158c:	eb 0c                	jmp    80159a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80158e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801593:	eb 05                	jmp    80159a <fd_lookup+0x54>
  801595:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    

0080159c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 14             	sub    $0x14,%esp
  8015a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8015a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ae:	eb 0e                	jmp    8015be <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8015b0:	39 08                	cmp    %ecx,(%eax)
  8015b2:	75 09                	jne    8015bd <dev_lookup+0x21>
			*dev = devtab[i];
  8015b4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bb:	eb 35                	jmp    8015f2 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015bd:	42                   	inc    %edx
  8015be:	8b 04 95 ec 2a 80 00 	mov    0x802aec(,%edx,4),%eax
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	75 e7                	jne    8015b0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ce:	8b 00                	mov    (%eax),%eax
  8015d0:	8b 40 48             	mov    0x48(%eax),%eax
  8015d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015db:	c7 04 24 70 2a 80 00 	movl   $0x802a70,(%esp)
  8015e2:	e8 79 ec ff ff       	call   800260 <cprintf>
	*dev = 0;
  8015e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015f2:	83 c4 14             	add    $0x14,%esp
  8015f5:	5b                   	pop    %ebx
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    

008015f8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 30             	sub    $0x30,%esp
  801600:	8b 75 08             	mov    0x8(%ebp),%esi
  801603:	8a 45 0c             	mov    0xc(%ebp),%al
  801606:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801609:	89 34 24             	mov    %esi,(%esp)
  80160c:	e8 b7 fe ff ff       	call   8014c8 <fd2num>
  801611:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801614:	89 54 24 04          	mov    %edx,0x4(%esp)
  801618:	89 04 24             	mov    %eax,(%esp)
  80161b:	e8 26 ff ff ff       	call   801546 <fd_lookup>
  801620:	89 c3                	mov    %eax,%ebx
  801622:	85 c0                	test   %eax,%eax
  801624:	78 05                	js     80162b <fd_close+0x33>
	    || fd != fd2)
  801626:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801629:	74 0d                	je     801638 <fd_close+0x40>
		return (must_exist ? r : 0);
  80162b:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80162f:	75 46                	jne    801677 <fd_close+0x7f>
  801631:	bb 00 00 00 00       	mov    $0x0,%ebx
  801636:	eb 3f                	jmp    801677 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801638:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163f:	8b 06                	mov    (%esi),%eax
  801641:	89 04 24             	mov    %eax,(%esp)
  801644:	e8 53 ff ff ff       	call   80159c <dev_lookup>
  801649:	89 c3                	mov    %eax,%ebx
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 18                	js     801667 <fd_close+0x6f>
		if (dev->dev_close)
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	8b 40 10             	mov    0x10(%eax),%eax
  801655:	85 c0                	test   %eax,%eax
  801657:	74 09                	je     801662 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801659:	89 34 24             	mov    %esi,(%esp)
  80165c:	ff d0                	call   *%eax
  80165e:	89 c3                	mov    %eax,%ebx
  801660:	eb 05                	jmp    801667 <fd_close+0x6f>
		else
			r = 0;
  801662:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801667:	89 74 24 04          	mov    %esi,0x4(%esp)
  80166b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801672:	e8 2d f6 ff ff       	call   800ca4 <sys_page_unmap>
	return r;
}
  801677:	89 d8                	mov    %ebx,%eax
  801679:	83 c4 30             	add    $0x30,%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801686:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168d:	8b 45 08             	mov    0x8(%ebp),%eax
  801690:	89 04 24             	mov    %eax,(%esp)
  801693:	e8 ae fe ff ff       	call   801546 <fd_lookup>
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 13                	js     8016af <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80169c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016a3:	00 
  8016a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a7:	89 04 24             	mov    %eax,(%esp)
  8016aa:	e8 49 ff ff ff       	call   8015f8 <fd_close>
}
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <close_all>:

void
close_all(void)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016bd:	89 1c 24             	mov    %ebx,(%esp)
  8016c0:	e8 bb ff ff ff       	call   801680 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016c5:	43                   	inc    %ebx
  8016c6:	83 fb 20             	cmp    $0x20,%ebx
  8016c9:	75 f2                	jne    8016bd <close_all+0xc>
		close(i);
}
  8016cb:	83 c4 14             	add    $0x14,%esp
  8016ce:	5b                   	pop    %ebx
  8016cf:	5d                   	pop    %ebp
  8016d0:	c3                   	ret    

008016d1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	57                   	push   %edi
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
  8016d7:	83 ec 4c             	sub    $0x4c,%esp
  8016da:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	89 04 24             	mov    %eax,(%esp)
  8016ea:	e8 57 fe ff ff       	call   801546 <fd_lookup>
  8016ef:	89 c3                	mov    %eax,%ebx
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	0f 88 e1 00 00 00    	js     8017da <dup+0x109>
		return r;
	close(newfdnum);
  8016f9:	89 3c 24             	mov    %edi,(%esp)
  8016fc:	e8 7f ff ff ff       	call   801680 <close>

	newfd = INDEX2FD(newfdnum);
  801701:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801707:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80170a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80170d:	89 04 24             	mov    %eax,(%esp)
  801710:	e8 c3 fd ff ff       	call   8014d8 <fd2data>
  801715:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801717:	89 34 24             	mov    %esi,(%esp)
  80171a:	e8 b9 fd ff ff       	call   8014d8 <fd2data>
  80171f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801722:	89 d8                	mov    %ebx,%eax
  801724:	c1 e8 16             	shr    $0x16,%eax
  801727:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80172e:	a8 01                	test   $0x1,%al
  801730:	74 46                	je     801778 <dup+0xa7>
  801732:	89 d8                	mov    %ebx,%eax
  801734:	c1 e8 0c             	shr    $0xc,%eax
  801737:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80173e:	f6 c2 01             	test   $0x1,%dl
  801741:	74 35                	je     801778 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801743:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80174a:	25 07 0e 00 00       	and    $0xe07,%eax
  80174f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801753:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801756:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80175a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801761:	00 
  801762:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801766:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176d:	e8 df f4 ff ff       	call   800c51 <sys_page_map>
  801772:	89 c3                	mov    %eax,%ebx
  801774:	85 c0                	test   %eax,%eax
  801776:	78 3b                	js     8017b3 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801778:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	c1 ea 0c             	shr    $0xc,%edx
  801780:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801787:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80178d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801791:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801795:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80179c:	00 
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a8:	e8 a4 f4 ff ff       	call   800c51 <sys_page_map>
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	79 25                	jns    8017d8 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017be:	e8 e1 f4 ff ff       	call   800ca4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d1:	e8 ce f4 ff ff       	call   800ca4 <sys_page_unmap>
	return r;
  8017d6:	eb 02                	jmp    8017da <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017d8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017da:	89 d8                	mov    %ebx,%eax
  8017dc:	83 c4 4c             	add    $0x4c,%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5e                   	pop    %esi
  8017e1:	5f                   	pop    %edi
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    

008017e4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 24             	sub    $0x24,%esp
  8017eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f5:	89 1c 24             	mov    %ebx,(%esp)
  8017f8:	e8 49 fd ff ff       	call   801546 <fd_lookup>
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 6f                	js     801870 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801801:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801804:	89 44 24 04          	mov    %eax,0x4(%esp)
  801808:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180b:	8b 00                	mov    (%eax),%eax
  80180d:	89 04 24             	mov    %eax,(%esp)
  801810:	e8 87 fd ff ff       	call   80159c <dev_lookup>
  801815:	85 c0                	test   %eax,%eax
  801817:	78 57                	js     801870 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181c:	8b 50 08             	mov    0x8(%eax),%edx
  80181f:	83 e2 03             	and    $0x3,%edx
  801822:	83 fa 01             	cmp    $0x1,%edx
  801825:	75 25                	jne    80184c <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801827:	a1 08 40 80 00       	mov    0x804008,%eax
  80182c:	8b 00                	mov    (%eax),%eax
  80182e:	8b 40 48             	mov    0x48(%eax),%eax
  801831:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801835:	89 44 24 04          	mov    %eax,0x4(%esp)
  801839:	c7 04 24 b1 2a 80 00 	movl   $0x802ab1,(%esp)
  801840:	e8 1b ea ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  801845:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80184a:	eb 24                	jmp    801870 <read+0x8c>
	}
	if (!dev->dev_read)
  80184c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184f:	8b 52 08             	mov    0x8(%edx),%edx
  801852:	85 d2                	test   %edx,%edx
  801854:	74 15                	je     80186b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801856:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801859:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80185d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801860:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801864:	89 04 24             	mov    %eax,(%esp)
  801867:	ff d2                	call   *%edx
  801869:	eb 05                	jmp    801870 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80186b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801870:	83 c4 24             	add    $0x24,%esp
  801873:	5b                   	pop    %ebx
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	57                   	push   %edi
  80187a:	56                   	push   %esi
  80187b:	53                   	push   %ebx
  80187c:	83 ec 1c             	sub    $0x1c,%esp
  80187f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801882:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801885:	bb 00 00 00 00       	mov    $0x0,%ebx
  80188a:	eb 23                	jmp    8018af <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80188c:	89 f0                	mov    %esi,%eax
  80188e:	29 d8                	sub    %ebx,%eax
  801890:	89 44 24 08          	mov    %eax,0x8(%esp)
  801894:	8b 45 0c             	mov    0xc(%ebp),%eax
  801897:	01 d8                	add    %ebx,%eax
  801899:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189d:	89 3c 24             	mov    %edi,(%esp)
  8018a0:	e8 3f ff ff ff       	call   8017e4 <read>
		if (m < 0)
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 10                	js     8018b9 <readn+0x43>
			return m;
		if (m == 0)
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	74 0a                	je     8018b7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018ad:	01 c3                	add    %eax,%ebx
  8018af:	39 f3                	cmp    %esi,%ebx
  8018b1:	72 d9                	jb     80188c <readn+0x16>
  8018b3:	89 d8                	mov    %ebx,%eax
  8018b5:	eb 02                	jmp    8018b9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018b7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018b9:	83 c4 1c             	add    $0x1c,%esp
  8018bc:	5b                   	pop    %ebx
  8018bd:	5e                   	pop    %esi
  8018be:	5f                   	pop    %edi
  8018bf:	5d                   	pop    %ebp
  8018c0:	c3                   	ret    

008018c1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	53                   	push   %ebx
  8018c5:	83 ec 24             	sub    $0x24,%esp
  8018c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d2:	89 1c 24             	mov    %ebx,(%esp)
  8018d5:	e8 6c fc ff ff       	call   801546 <fd_lookup>
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 6a                	js     801948 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e8:	8b 00                	mov    (%eax),%eax
  8018ea:	89 04 24             	mov    %eax,(%esp)
  8018ed:	e8 aa fc ff ff       	call   80159c <dev_lookup>
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	78 52                	js     801948 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018fd:	75 25                	jne    801924 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018ff:	a1 08 40 80 00       	mov    0x804008,%eax
  801904:	8b 00                	mov    (%eax),%eax
  801906:	8b 40 48             	mov    0x48(%eax),%eax
  801909:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80190d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801911:	c7 04 24 cd 2a 80 00 	movl   $0x802acd,(%esp)
  801918:	e8 43 e9 ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  80191d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801922:	eb 24                	jmp    801948 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801924:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801927:	8b 52 0c             	mov    0xc(%edx),%edx
  80192a:	85 d2                	test   %edx,%edx
  80192c:	74 15                	je     801943 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80192e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801931:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801935:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801938:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	ff d2                	call   *%edx
  801941:	eb 05                	jmp    801948 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801943:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801948:	83 c4 24             	add    $0x24,%esp
  80194b:	5b                   	pop    %ebx
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <seek>:

int
seek(int fdnum, off_t offset)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801954:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	89 04 24             	mov    %eax,(%esp)
  801961:	e8 e0 fb ff ff       	call   801546 <fd_lookup>
  801966:	85 c0                	test   %eax,%eax
  801968:	78 0e                	js     801978 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80196a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80196d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801970:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	53                   	push   %ebx
  80197e:	83 ec 24             	sub    $0x24,%esp
  801981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801984:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198b:	89 1c 24             	mov    %ebx,(%esp)
  80198e:	e8 b3 fb ff ff       	call   801546 <fd_lookup>
  801993:	85 c0                	test   %eax,%eax
  801995:	78 63                	js     8019fa <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801997:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a1:	8b 00                	mov    (%eax),%eax
  8019a3:	89 04 24             	mov    %eax,(%esp)
  8019a6:	e8 f1 fb ff ff       	call   80159c <dev_lookup>
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 4b                	js     8019fa <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019b6:	75 25                	jne    8019dd <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8019bd:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019bf:	8b 40 48             	mov    0x48(%eax),%eax
  8019c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ca:	c7 04 24 90 2a 80 00 	movl   $0x802a90,(%esp)
  8019d1:	e8 8a e8 ff ff       	call   800260 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019db:	eb 1d                	jmp    8019fa <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8019dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e0:	8b 52 18             	mov    0x18(%edx),%edx
  8019e3:	85 d2                	test   %edx,%edx
  8019e5:	74 0e                	je     8019f5 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ea:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	ff d2                	call   *%edx
  8019f3:	eb 05                	jmp    8019fa <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019fa:	83 c4 24             	add    $0x24,%esp
  8019fd:	5b                   	pop    %ebx
  8019fe:	5d                   	pop    %ebp
  8019ff:	c3                   	ret    

00801a00 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	53                   	push   %ebx
  801a04:	83 ec 24             	sub    $0x24,%esp
  801a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	89 04 24             	mov    %eax,(%esp)
  801a17:	e8 2a fb ff ff       	call   801546 <fd_lookup>
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 52                	js     801a72 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a2a:	8b 00                	mov    (%eax),%eax
  801a2c:	89 04 24             	mov    %eax,(%esp)
  801a2f:	e8 68 fb ff ff       	call   80159c <dev_lookup>
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 3a                	js     801a72 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a3f:	74 2c                	je     801a6d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a41:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a44:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a4b:	00 00 00 
	stat->st_isdir = 0;
  801a4e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a55:	00 00 00 
	stat->st_dev = dev;
  801a58:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a62:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a65:	89 14 24             	mov    %edx,(%esp)
  801a68:	ff 50 14             	call   *0x14(%eax)
  801a6b:	eb 05                	jmp    801a72 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a6d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a72:	83 c4 24             	add    $0x24,%esp
  801a75:	5b                   	pop    %ebx
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    

00801a78 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a80:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a87:	00 
  801a88:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8b:	89 04 24             	mov    %eax,(%esp)
  801a8e:	e8 88 02 00 00       	call   801d1b <open>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	85 c0                	test   %eax,%eax
  801a97:	78 1b                	js     801ab4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa0:	89 1c 24             	mov    %ebx,(%esp)
  801aa3:	e8 58 ff ff ff       	call   801a00 <fstat>
  801aa8:	89 c6                	mov    %eax,%esi
	close(fd);
  801aaa:	89 1c 24             	mov    %ebx,(%esp)
  801aad:	e8 ce fb ff ff       	call   801680 <close>
	return r;
  801ab2:	89 f3                	mov    %esi,%ebx
}
  801ab4:	89 d8                	mov    %ebx,%eax
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5e                   	pop    %esi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    
  801abd:	00 00                	add    %al,(%eax)
	...

00801ac0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 10             	sub    $0x10,%esp
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801acc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ad3:	75 11                	jne    801ae6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ad5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801adc:	e8 a2 f9 ff ff       	call   801483 <ipc_find_env>
  801ae1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ae6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801aed:	00 
  801aee:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801af5:	00 
  801af6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801afa:	a1 00 40 80 00       	mov    0x804000,%eax
  801aff:	89 04 24             	mov    %eax,(%esp)
  801b02:	e8 16 f9 ff ff       	call   80141d <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801b07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b0e:	00 
  801b0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1a:	e8 91 f8 ff ff       	call   8013b0 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b32:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b3a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b44:	b8 02 00 00 00       	mov    $0x2,%eax
  801b49:	e8 72 ff ff ff       	call   801ac0 <fsipc>
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b61:	ba 00 00 00 00       	mov    $0x0,%edx
  801b66:	b8 06 00 00 00       	mov    $0x6,%eax
  801b6b:	e8 50 ff ff ff       	call   801ac0 <fsipc>
}
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    

00801b72 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	53                   	push   %ebx
  801b76:	83 ec 14             	sub    $0x14,%esp
  801b79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b82:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b87:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8c:	b8 05 00 00 00       	mov    $0x5,%eax
  801b91:	e8 2a ff ff ff       	call   801ac0 <fsipc>
  801b96:	85 c0                	test   %eax,%eax
  801b98:	78 2b                	js     801bc5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b9a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801ba1:	00 
  801ba2:	89 1c 24             	mov    %ebx,(%esp)
  801ba5:	e8 61 ec ff ff       	call   80080b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801baa:	a1 80 50 80 00       	mov    0x805080,%eax
  801baf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bb5:	a1 84 50 80 00       	mov    0x805084,%eax
  801bba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bc5:	83 c4 14             	add    $0x14,%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    

00801bcb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 14             	sub    $0x14,%esp
  801bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	8b 40 0c             	mov    0xc(%eax),%eax
  801bdb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801be0:	89 d8                	mov    %ebx,%eax
  801be2:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801be8:	76 05                	jbe    801bef <devfile_write+0x24>
  801bea:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801bef:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801bf4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bff:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801c06:	e8 e3 ed ff ff       	call   8009ee <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c10:	b8 04 00 00 00       	mov    $0x4,%eax
  801c15:	e8 a6 fe ff ff       	call   801ac0 <fsipc>
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	78 53                	js     801c71 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801c1e:	39 c3                	cmp    %eax,%ebx
  801c20:	73 24                	jae    801c46 <devfile_write+0x7b>
  801c22:	c7 44 24 0c fc 2a 80 	movl   $0x802afc,0xc(%esp)
  801c29:	00 
  801c2a:	c7 44 24 08 03 2b 80 	movl   $0x802b03,0x8(%esp)
  801c31:	00 
  801c32:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801c39:	00 
  801c3a:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  801c41:	e8 92 06 00 00       	call   8022d8 <_panic>
	assert(r <= PGSIZE);
  801c46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c4b:	7e 24                	jle    801c71 <devfile_write+0xa6>
  801c4d:	c7 44 24 0c 23 2b 80 	movl   $0x802b23,0xc(%esp)
  801c54:	00 
  801c55:	c7 44 24 08 03 2b 80 	movl   $0x802b03,0x8(%esp)
  801c5c:	00 
  801c5d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801c64:	00 
  801c65:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  801c6c:	e8 67 06 00 00       	call   8022d8 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801c71:	83 c4 14             	add    $0x14,%esp
  801c74:	5b                   	pop    %ebx
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	56                   	push   %esi
  801c7b:	53                   	push   %ebx
  801c7c:	83 ec 10             	sub    $0x10,%esp
  801c7f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	8b 40 0c             	mov    0xc(%eax),%eax
  801c88:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c8d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c93:	ba 00 00 00 00       	mov    $0x0,%edx
  801c98:	b8 03 00 00 00       	mov    $0x3,%eax
  801c9d:	e8 1e fe ff ff       	call   801ac0 <fsipc>
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	78 6a                	js     801d12 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ca8:	39 c6                	cmp    %eax,%esi
  801caa:	73 24                	jae    801cd0 <devfile_read+0x59>
  801cac:	c7 44 24 0c fc 2a 80 	movl   $0x802afc,0xc(%esp)
  801cb3:	00 
  801cb4:	c7 44 24 08 03 2b 80 	movl   $0x802b03,0x8(%esp)
  801cbb:	00 
  801cbc:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801cc3:	00 
  801cc4:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  801ccb:	e8 08 06 00 00       	call   8022d8 <_panic>
	assert(r <= PGSIZE);
  801cd0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cd5:	7e 24                	jle    801cfb <devfile_read+0x84>
  801cd7:	c7 44 24 0c 23 2b 80 	movl   $0x802b23,0xc(%esp)
  801cde:	00 
  801cdf:	c7 44 24 08 03 2b 80 	movl   $0x802b03,0x8(%esp)
  801ce6:	00 
  801ce7:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801cee:	00 
  801cef:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  801cf6:	e8 dd 05 00 00       	call   8022d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cff:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d06:	00 
  801d07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0a:	89 04 24             	mov    %eax,(%esp)
  801d0d:	e8 72 ec ff ff       	call   800984 <memmove>
	return r;
}
  801d12:	89 d8                	mov    %ebx,%eax
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	56                   	push   %esi
  801d1f:	53                   	push   %ebx
  801d20:	83 ec 20             	sub    $0x20,%esp
  801d23:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d26:	89 34 24             	mov    %esi,(%esp)
  801d29:	e8 aa ea ff ff       	call   8007d8 <strlen>
  801d2e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d33:	7f 60                	jg     801d95 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d38:	89 04 24             	mov    %eax,(%esp)
  801d3b:	e8 b3 f7 ff ff       	call   8014f3 <fd_alloc>
  801d40:	89 c3                	mov    %eax,%ebx
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 54                	js     801d9a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d51:	e8 b5 ea ff ff       	call   80080b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d59:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d61:	b8 01 00 00 00       	mov    $0x1,%eax
  801d66:	e8 55 fd ff ff       	call   801ac0 <fsipc>
  801d6b:	89 c3                	mov    %eax,%ebx
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	79 15                	jns    801d86 <open+0x6b>
		fd_close(fd, 0);
  801d71:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d78:	00 
  801d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7c:	89 04 24             	mov    %eax,(%esp)
  801d7f:	e8 74 f8 ff ff       	call   8015f8 <fd_close>
		return r;
  801d84:	eb 14                	jmp    801d9a <open+0x7f>
	}

	return fd2num(fd);
  801d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d89:	89 04 24             	mov    %eax,(%esp)
  801d8c:	e8 37 f7 ff ff       	call   8014c8 <fd2num>
  801d91:	89 c3                	mov    %eax,%ebx
  801d93:	eb 05                	jmp    801d9a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d95:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d9a:	89 d8                	mov    %ebx,%eax
  801d9c:	83 c4 20             	add    $0x20,%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801da9:	ba 00 00 00 00       	mov    $0x0,%edx
  801dae:	b8 08 00 00 00       	mov    $0x8,%eax
  801db3:	e8 08 fd ff ff       	call   801ac0 <fsipc>
}
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    
	...

00801dbc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	83 ec 10             	sub    $0x10,%esp
  801dc4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dca:	89 04 24             	mov    %eax,(%esp)
  801dcd:	e8 06 f7 ff ff       	call   8014d8 <fd2data>
  801dd2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801dd4:	c7 44 24 04 2f 2b 80 	movl   $0x802b2f,0x4(%esp)
  801ddb:	00 
  801ddc:	89 34 24             	mov    %esi,(%esp)
  801ddf:	e8 27 ea ff ff       	call   80080b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801de4:	8b 43 04             	mov    0x4(%ebx),%eax
  801de7:	2b 03                	sub    (%ebx),%eax
  801de9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801def:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801df6:	00 00 00 
	stat->st_dev = &devpipe;
  801df9:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801e00:	30 80 00 
	return 0;
}
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	5b                   	pop    %ebx
  801e0c:	5e                   	pop    %esi
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    

00801e0f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	53                   	push   %ebx
  801e13:	83 ec 14             	sub    $0x14,%esp
  801e16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e24:	e8 7b ee ff ff       	call   800ca4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e29:	89 1c 24             	mov    %ebx,(%esp)
  801e2c:	e8 a7 f6 ff ff       	call   8014d8 <fd2data>
  801e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e3c:	e8 63 ee ff ff       	call   800ca4 <sys_page_unmap>
}
  801e41:	83 c4 14             	add    $0x14,%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5d                   	pop    %ebp
  801e46:	c3                   	ret    

00801e47 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	57                   	push   %edi
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
  801e4d:	83 ec 2c             	sub    $0x2c,%esp
  801e50:	89 c7                	mov    %eax,%edi
  801e52:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e55:	a1 08 40 80 00       	mov    0x804008,%eax
  801e5a:	8b 00                	mov    (%eax),%eax
  801e5c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e5f:	89 3c 24             	mov    %edi,(%esp)
  801e62:	e8 81 05 00 00       	call   8023e8 <pageref>
  801e67:	89 c6                	mov    %eax,%esi
  801e69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6c:	89 04 24             	mov    %eax,(%esp)
  801e6f:	e8 74 05 00 00       	call   8023e8 <pageref>
  801e74:	39 c6                	cmp    %eax,%esi
  801e76:	0f 94 c0             	sete   %al
  801e79:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e7c:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e82:	8b 12                	mov    (%edx),%edx
  801e84:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e87:	39 cb                	cmp    %ecx,%ebx
  801e89:	75 08                	jne    801e93 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e8b:	83 c4 2c             	add    $0x2c,%esp
  801e8e:	5b                   	pop    %ebx
  801e8f:	5e                   	pop    %esi
  801e90:	5f                   	pop    %edi
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e93:	83 f8 01             	cmp    $0x1,%eax
  801e96:	75 bd                	jne    801e55 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e98:	8b 42 58             	mov    0x58(%edx),%eax
  801e9b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801ea2:	00 
  801ea3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ea7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eab:	c7 04 24 36 2b 80 00 	movl   $0x802b36,(%esp)
  801eb2:	e8 a9 e3 ff ff       	call   800260 <cprintf>
  801eb7:	eb 9c                	jmp    801e55 <_pipeisclosed+0xe>

00801eb9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	57                   	push   %edi
  801ebd:	56                   	push   %esi
  801ebe:	53                   	push   %ebx
  801ebf:	83 ec 1c             	sub    $0x1c,%esp
  801ec2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ec5:	89 34 24             	mov    %esi,(%esp)
  801ec8:	e8 0b f6 ff ff       	call   8014d8 <fd2data>
  801ecd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ecf:	bf 00 00 00 00       	mov    $0x0,%edi
  801ed4:	eb 3c                	jmp    801f12 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ed6:	89 da                	mov    %ebx,%edx
  801ed8:	89 f0                	mov    %esi,%eax
  801eda:	e8 68 ff ff ff       	call   801e47 <_pipeisclosed>
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	75 38                	jne    801f1b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ee3:	e8 f6 ec ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ee8:	8b 43 04             	mov    0x4(%ebx),%eax
  801eeb:	8b 13                	mov    (%ebx),%edx
  801eed:	83 c2 20             	add    $0x20,%edx
  801ef0:	39 d0                	cmp    %edx,%eax
  801ef2:	73 e2                	jae    801ed6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ef4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801efa:	89 c2                	mov    %eax,%edx
  801efc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f02:	79 05                	jns    801f09 <devpipe_write+0x50>
  801f04:	4a                   	dec    %edx
  801f05:	83 ca e0             	or     $0xffffffe0,%edx
  801f08:	42                   	inc    %edx
  801f09:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f0d:	40                   	inc    %eax
  801f0e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f11:	47                   	inc    %edi
  801f12:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f15:	75 d1                	jne    801ee8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f17:	89 f8                	mov    %edi,%eax
  801f19:	eb 05                	jmp    801f20 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f1b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f20:	83 c4 1c             	add    $0x1c,%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    

00801f28 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	57                   	push   %edi
  801f2c:	56                   	push   %esi
  801f2d:	53                   	push   %ebx
  801f2e:	83 ec 1c             	sub    $0x1c,%esp
  801f31:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f34:	89 3c 24             	mov    %edi,(%esp)
  801f37:	e8 9c f5 ff ff       	call   8014d8 <fd2data>
  801f3c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3e:	be 00 00 00 00       	mov    $0x0,%esi
  801f43:	eb 3a                	jmp    801f7f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f45:	85 f6                	test   %esi,%esi
  801f47:	74 04                	je     801f4d <devpipe_read+0x25>
				return i;
  801f49:	89 f0                	mov    %esi,%eax
  801f4b:	eb 40                	jmp    801f8d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f4d:	89 da                	mov    %ebx,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	e8 f1 fe ff ff       	call   801e47 <_pipeisclosed>
  801f56:	85 c0                	test   %eax,%eax
  801f58:	75 2e                	jne    801f88 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f5a:	e8 7f ec ff ff       	call   800bde <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f5f:	8b 03                	mov    (%ebx),%eax
  801f61:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f64:	74 df                	je     801f45 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f66:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f6b:	79 05                	jns    801f72 <devpipe_read+0x4a>
  801f6d:	48                   	dec    %eax
  801f6e:	83 c8 e0             	or     $0xffffffe0,%eax
  801f71:	40                   	inc    %eax
  801f72:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f76:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f79:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f7c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f7e:	46                   	inc    %esi
  801f7f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f82:	75 db                	jne    801f5f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f84:	89 f0                	mov    %esi,%eax
  801f86:	eb 05                	jmp    801f8d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f88:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f8d:	83 c4 1c             	add    $0x1c,%esp
  801f90:	5b                   	pop    %ebx
  801f91:	5e                   	pop    %esi
  801f92:	5f                   	pop    %edi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    

00801f95 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	57                   	push   %edi
  801f99:	56                   	push   %esi
  801f9a:	53                   	push   %ebx
  801f9b:	83 ec 3c             	sub    $0x3c,%esp
  801f9e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fa1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fa4:	89 04 24             	mov    %eax,(%esp)
  801fa7:	e8 47 f5 ff ff       	call   8014f3 <fd_alloc>
  801fac:	89 c3                	mov    %eax,%ebx
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	0f 88 45 01 00 00    	js     8020fb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fb6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fbd:	00 
  801fbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fcc:	e8 2c ec ff ff       	call   800bfd <sys_page_alloc>
  801fd1:	89 c3                	mov    %eax,%ebx
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	0f 88 20 01 00 00    	js     8020fb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fdb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fde:	89 04 24             	mov    %eax,(%esp)
  801fe1:	e8 0d f5 ff ff       	call   8014f3 <fd_alloc>
  801fe6:	89 c3                	mov    %eax,%ebx
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	0f 88 f8 00 00 00    	js     8020e8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ff7:	00 
  801ff8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ffb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802006:	e8 f2 eb ff ff       	call   800bfd <sys_page_alloc>
  80200b:	89 c3                	mov    %eax,%ebx
  80200d:	85 c0                	test   %eax,%eax
  80200f:	0f 88 d3 00 00 00    	js     8020e8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802015:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802018:	89 04 24             	mov    %eax,(%esp)
  80201b:	e8 b8 f4 ff ff       	call   8014d8 <fd2data>
  802020:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802022:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802029:	00 
  80202a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80202e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802035:	e8 c3 eb ff ff       	call   800bfd <sys_page_alloc>
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	85 c0                	test   %eax,%eax
  80203e:	0f 88 91 00 00 00    	js     8020d5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802044:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802047:	89 04 24             	mov    %eax,(%esp)
  80204a:	e8 89 f4 ff ff       	call   8014d8 <fd2data>
  80204f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802056:	00 
  802057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802062:	00 
  802063:	89 74 24 04          	mov    %esi,0x4(%esp)
  802067:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80206e:	e8 de eb ff ff       	call   800c51 <sys_page_map>
  802073:	89 c3                	mov    %eax,%ebx
  802075:	85 c0                	test   %eax,%eax
  802077:	78 4c                	js     8020c5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802079:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80207f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802082:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802084:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802087:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80208e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802094:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802097:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802099:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80209c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020a6:	89 04 24             	mov    %eax,(%esp)
  8020a9:	e8 1a f4 ff ff       	call   8014c8 <fd2num>
  8020ae:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020b3:	89 04 24             	mov    %eax,(%esp)
  8020b6:	e8 0d f4 ff ff       	call   8014c8 <fd2num>
  8020bb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8020be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c3:	eb 36                	jmp    8020fb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8020c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d0:	e8 cf eb ff ff       	call   800ca4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e3:	e8 bc eb ff ff       	call   800ca4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f6:	e8 a9 eb ff ff       	call   800ca4 <sys_page_unmap>
    err:
	return r;
}
  8020fb:	89 d8                	mov    %ebx,%eax
  8020fd:	83 c4 3c             	add    $0x3c,%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80210b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802112:	8b 45 08             	mov    0x8(%ebp),%eax
  802115:	89 04 24             	mov    %eax,(%esp)
  802118:	e8 29 f4 ff ff       	call   801546 <fd_lookup>
  80211d:	85 c0                	test   %eax,%eax
  80211f:	78 15                	js     802136 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802121:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802124:	89 04 24             	mov    %eax,(%esp)
  802127:	e8 ac f3 ff ff       	call   8014d8 <fd2data>
	return _pipeisclosed(fd, p);
  80212c:	89 c2                	mov    %eax,%edx
  80212e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802131:	e8 11 fd ff ff       	call   801e47 <_pipeisclosed>
}
  802136:	c9                   	leave  
  802137:	c3                   	ret    

00802138 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80213b:	b8 00 00 00 00       	mov    $0x0,%eax
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    

00802142 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802148:	c7 44 24 04 4e 2b 80 	movl   $0x802b4e,0x4(%esp)
  80214f:	00 
  802150:	8b 45 0c             	mov    0xc(%ebp),%eax
  802153:	89 04 24             	mov    %eax,(%esp)
  802156:	e8 b0 e6 ff ff       	call   80080b <strcpy>
	return 0;
}
  80215b:	b8 00 00 00 00       	mov    $0x0,%eax
  802160:	c9                   	leave  
  802161:	c3                   	ret    

00802162 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	57                   	push   %edi
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
  802168:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80216e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802173:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802179:	eb 30                	jmp    8021ab <devcons_write+0x49>
		m = n - tot;
  80217b:	8b 75 10             	mov    0x10(%ebp),%esi
  80217e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802180:	83 fe 7f             	cmp    $0x7f,%esi
  802183:	76 05                	jbe    80218a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802185:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80218a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80218e:	03 45 0c             	add    0xc(%ebp),%eax
  802191:	89 44 24 04          	mov    %eax,0x4(%esp)
  802195:	89 3c 24             	mov    %edi,(%esp)
  802198:	e8 e7 e7 ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  80219d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a1:	89 3c 24             	mov    %edi,(%esp)
  8021a4:	e8 87 e9 ff ff       	call   800b30 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a9:	01 f3                	add    %esi,%ebx
  8021ab:	89 d8                	mov    %ebx,%eax
  8021ad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021b0:	72 c9                	jb     80217b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021b2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021b8:	5b                   	pop    %ebx
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    

008021bd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021bd:	55                   	push   %ebp
  8021be:	89 e5                	mov    %esp,%ebp
  8021c0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8021c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021c7:	75 07                	jne    8021d0 <devcons_read+0x13>
  8021c9:	eb 25                	jmp    8021f0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021cb:	e8 0e ea ff ff       	call   800bde <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021d0:	e8 79 e9 ff ff       	call   800b4e <sys_cgetc>
  8021d5:	85 c0                	test   %eax,%eax
  8021d7:	74 f2                	je     8021cb <devcons_read+0xe>
  8021d9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	78 1d                	js     8021fc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021df:	83 f8 04             	cmp    $0x4,%eax
  8021e2:	74 13                	je     8021f7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e7:	88 10                	mov    %dl,(%eax)
	return 1;
  8021e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ee:	eb 0c                	jmp    8021fc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f5:	eb 05                	jmp    8021fc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021f7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    

008021fe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802204:	8b 45 08             	mov    0x8(%ebp),%eax
  802207:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80220a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802211:	00 
  802212:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802215:	89 04 24             	mov    %eax,(%esp)
  802218:	e8 13 e9 ff ff       	call   800b30 <sys_cputs>
}
  80221d:	c9                   	leave  
  80221e:	c3                   	ret    

0080221f <getchar>:

int
getchar(void)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802225:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80222c:	00 
  80222d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802230:	89 44 24 04          	mov    %eax,0x4(%esp)
  802234:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80223b:	e8 a4 f5 ff ff       	call   8017e4 <read>
	if (r < 0)
  802240:	85 c0                	test   %eax,%eax
  802242:	78 0f                	js     802253 <getchar+0x34>
		return r;
	if (r < 1)
  802244:	85 c0                	test   %eax,%eax
  802246:	7e 06                	jle    80224e <getchar+0x2f>
		return -E_EOF;
	return c;
  802248:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80224c:	eb 05                	jmp    802253 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80224e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802253:	c9                   	leave  
  802254:	c3                   	ret    

00802255 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80225b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802262:	8b 45 08             	mov    0x8(%ebp),%eax
  802265:	89 04 24             	mov    %eax,(%esp)
  802268:	e8 d9 f2 ff ff       	call   801546 <fd_lookup>
  80226d:	85 c0                	test   %eax,%eax
  80226f:	78 11                	js     802282 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802271:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802274:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80227a:	39 10                	cmp    %edx,(%eax)
  80227c:	0f 94 c0             	sete   %al
  80227f:	0f b6 c0             	movzbl %al,%eax
}
  802282:	c9                   	leave  
  802283:	c3                   	ret    

00802284 <opencons>:

int
opencons(void)
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80228a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228d:	89 04 24             	mov    %eax,(%esp)
  802290:	e8 5e f2 ff ff       	call   8014f3 <fd_alloc>
  802295:	85 c0                	test   %eax,%eax
  802297:	78 3c                	js     8022d5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802299:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022a0:	00 
  8022a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022af:	e8 49 e9 ff ff       	call   800bfd <sys_page_alloc>
  8022b4:	85 c0                	test   %eax,%eax
  8022b6:	78 1d                	js     8022d5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022b8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022cd:	89 04 24             	mov    %eax,(%esp)
  8022d0:	e8 f3 f1 ff ff       	call   8014c8 <fd2num>
}
  8022d5:	c9                   	leave  
  8022d6:	c3                   	ret    
	...

008022d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022d8:	55                   	push   %ebp
  8022d9:	89 e5                	mov    %esp,%ebp
  8022db:	56                   	push   %esi
  8022dc:	53                   	push   %ebx
  8022dd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8022e0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022e3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8022e9:	e8 d1 e8 ff ff       	call   800bbf <sys_getenvid>
  8022ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8022f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8022f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802300:	89 44 24 04          	mov    %eax,0x4(%esp)
  802304:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  80230b:	e8 50 df ff ff       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802310:	89 74 24 04          	mov    %esi,0x4(%esp)
  802314:	8b 45 10             	mov    0x10(%ebp),%eax
  802317:	89 04 24             	mov    %eax,(%esp)
  80231a:	e8 e0 de ff ff       	call   8001ff <vcprintf>
	cprintf("\n");
  80231f:	c7 04 24 50 2a 80 00 	movl   $0x802a50,(%esp)
  802326:	e8 35 df ff ff       	call   800260 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80232b:	cc                   	int3   
  80232c:	eb fd                	jmp    80232b <_panic+0x53>
	...

00802330 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	53                   	push   %ebx
  802334:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802337:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80233e:	75 6f                	jne    8023af <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  802340:	e8 7a e8 ff ff       	call   800bbf <sys_getenvid>
  802345:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  802347:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80234e:	00 
  80234f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802356:	ee 
  802357:	89 04 24             	mov    %eax,(%esp)
  80235a:	e8 9e e8 ff ff       	call   800bfd <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  80235f:	85 c0                	test   %eax,%eax
  802361:	79 1c                	jns    80237f <set_pgfault_handler+0x4f>
  802363:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80236a:	00 
  80236b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802372:	00 
  802373:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  80237a:	e8 59 ff ff ff       	call   8022d8 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80237f:	c7 44 24 04 c0 23 80 	movl   $0x8023c0,0x4(%esp)
  802386:	00 
  802387:	89 1c 24             	mov    %ebx,(%esp)
  80238a:	e8 0e ea ff ff       	call   800d9d <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  80238f:	85 c0                	test   %eax,%eax
  802391:	79 1c                	jns    8023af <set_pgfault_handler+0x7f>
  802393:	c7 44 24 08 a8 2b 80 	movl   $0x802ba8,0x8(%esp)
  80239a:	00 
  80239b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8023a2:	00 
  8023a3:	c7 04 24 dc 2b 80 00 	movl   $0x802bdc,(%esp)
  8023aa:	e8 29 ff ff ff       	call   8022d8 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023af:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b2:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8023b7:	83 c4 14             	add    $0x14,%esp
  8023ba:	5b                   	pop    %ebx
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    
  8023bd:	00 00                	add    %al,(%eax)
	...

008023c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023c1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8023c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023c8:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8023cb:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8023cf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8023d4:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  8023d8:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  8023da:	83 c4 08             	add    $0x8,%esp
	popal
  8023dd:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  8023de:	83 c4 04             	add    $0x4,%esp
	popfl
  8023e1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  8023e2:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8023e5:	c3                   	ret    
	...

008023e8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
  8023eb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  8023ee:	89 c2                	mov    %eax,%edx
  8023f0:	c1 ea 16             	shr    $0x16,%edx
  8023f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023fa:	f6 c2 01             	test   $0x1,%dl
  8023fd:	74 1e                	je     80241d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023ff:	c1 e8 0c             	shr    $0xc,%eax
  802402:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802409:	a8 01                	test   $0x1,%al
  80240b:	74 17                	je     802424 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80240d:	c1 e8 0c             	shr    $0xc,%eax
  802410:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802417:	ef 
  802418:	0f b7 c0             	movzwl %ax,%eax
  80241b:	eb 0c                	jmp    802429 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80241d:	b8 00 00 00 00       	mov    $0x0,%eax
  802422:	eb 05                	jmp    802429 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802424:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802429:	5d                   	pop    %ebp
  80242a:	c3                   	ret    
	...

0080242c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80242c:	55                   	push   %ebp
  80242d:	57                   	push   %edi
  80242e:	56                   	push   %esi
  80242f:	83 ec 10             	sub    $0x10,%esp
  802432:	8b 74 24 20          	mov    0x20(%esp),%esi
  802436:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80243a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80243e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802442:	89 cd                	mov    %ecx,%ebp
  802444:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802448:	85 c0                	test   %eax,%eax
  80244a:	75 2c                	jne    802478 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80244c:	39 f9                	cmp    %edi,%ecx
  80244e:	77 68                	ja     8024b8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802450:	85 c9                	test   %ecx,%ecx
  802452:	75 0b                	jne    80245f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802454:	b8 01 00 00 00       	mov    $0x1,%eax
  802459:	31 d2                	xor    %edx,%edx
  80245b:	f7 f1                	div    %ecx
  80245d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80245f:	31 d2                	xor    %edx,%edx
  802461:	89 f8                	mov    %edi,%eax
  802463:	f7 f1                	div    %ecx
  802465:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802467:	89 f0                	mov    %esi,%eax
  802469:	f7 f1                	div    %ecx
  80246b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80246d:	89 f0                	mov    %esi,%eax
  80246f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802471:	83 c4 10             	add    $0x10,%esp
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802478:	39 f8                	cmp    %edi,%eax
  80247a:	77 2c                	ja     8024a8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80247c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80247f:	83 f6 1f             	xor    $0x1f,%esi
  802482:	75 4c                	jne    8024d0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802484:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802486:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80248b:	72 0a                	jb     802497 <__udivdi3+0x6b>
  80248d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802491:	0f 87 ad 00 00 00    	ja     802544 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802497:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80249c:	89 f0                	mov    %esi,%eax
  80249e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024a0:	83 c4 10             	add    $0x10,%esp
  8024a3:	5e                   	pop    %esi
  8024a4:	5f                   	pop    %edi
  8024a5:	5d                   	pop    %ebp
  8024a6:	c3                   	ret    
  8024a7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024a8:	31 ff                	xor    %edi,%edi
  8024aa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024ac:	89 f0                	mov    %esi,%eax
  8024ae:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024b0:	83 c4 10             	add    $0x10,%esp
  8024b3:	5e                   	pop    %esi
  8024b4:	5f                   	pop    %edi
  8024b5:	5d                   	pop    %ebp
  8024b6:	c3                   	ret    
  8024b7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024b8:	89 fa                	mov    %edi,%edx
  8024ba:	89 f0                	mov    %esi,%eax
  8024bc:	f7 f1                	div    %ecx
  8024be:	89 c6                	mov    %eax,%esi
  8024c0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024c2:	89 f0                	mov    %esi,%eax
  8024c4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024c6:	83 c4 10             	add    $0x10,%esp
  8024c9:	5e                   	pop    %esi
  8024ca:	5f                   	pop    %edi
  8024cb:	5d                   	pop    %ebp
  8024cc:	c3                   	ret    
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024d0:	89 f1                	mov    %esi,%ecx
  8024d2:	d3 e0                	shl    %cl,%eax
  8024d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024d8:	b8 20 00 00 00       	mov    $0x20,%eax
  8024dd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8024df:	89 ea                	mov    %ebp,%edx
  8024e1:	88 c1                	mov    %al,%cl
  8024e3:	d3 ea                	shr    %cl,%edx
  8024e5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8024e9:	09 ca                	or     %ecx,%edx
  8024eb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8024ef:	89 f1                	mov    %esi,%ecx
  8024f1:	d3 e5                	shl    %cl,%ebp
  8024f3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8024f7:	89 fd                	mov    %edi,%ebp
  8024f9:	88 c1                	mov    %al,%cl
  8024fb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8024fd:	89 fa                	mov    %edi,%edx
  8024ff:	89 f1                	mov    %esi,%ecx
  802501:	d3 e2                	shl    %cl,%edx
  802503:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802507:	88 c1                	mov    %al,%cl
  802509:	d3 ef                	shr    %cl,%edi
  80250b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80250d:	89 f8                	mov    %edi,%eax
  80250f:	89 ea                	mov    %ebp,%edx
  802511:	f7 74 24 08          	divl   0x8(%esp)
  802515:	89 d1                	mov    %edx,%ecx
  802517:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802519:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80251d:	39 d1                	cmp    %edx,%ecx
  80251f:	72 17                	jb     802538 <__udivdi3+0x10c>
  802521:	74 09                	je     80252c <__udivdi3+0x100>
  802523:	89 fe                	mov    %edi,%esi
  802525:	31 ff                	xor    %edi,%edi
  802527:	e9 41 ff ff ff       	jmp    80246d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80252c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802530:	89 f1                	mov    %esi,%ecx
  802532:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802534:	39 c2                	cmp    %eax,%edx
  802536:	73 eb                	jae    802523 <__udivdi3+0xf7>
		{
		  q0--;
  802538:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80253b:	31 ff                	xor    %edi,%edi
  80253d:	e9 2b ff ff ff       	jmp    80246d <__udivdi3+0x41>
  802542:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802544:	31 f6                	xor    %esi,%esi
  802546:	e9 22 ff ff ff       	jmp    80246d <__udivdi3+0x41>
	...

0080254c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80254c:	55                   	push   %ebp
  80254d:	57                   	push   %edi
  80254e:	56                   	push   %esi
  80254f:	83 ec 20             	sub    $0x20,%esp
  802552:	8b 44 24 30          	mov    0x30(%esp),%eax
  802556:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80255a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80255e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802562:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802566:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80256a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80256c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80256e:	85 ed                	test   %ebp,%ebp
  802570:	75 16                	jne    802588 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802572:	39 f1                	cmp    %esi,%ecx
  802574:	0f 86 a6 00 00 00    	jbe    802620 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80257a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80257c:	89 d0                	mov    %edx,%eax
  80257e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802580:	83 c4 20             	add    $0x20,%esp
  802583:	5e                   	pop    %esi
  802584:	5f                   	pop    %edi
  802585:	5d                   	pop    %ebp
  802586:	c3                   	ret    
  802587:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802588:	39 f5                	cmp    %esi,%ebp
  80258a:	0f 87 ac 00 00 00    	ja     80263c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802590:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802593:	83 f0 1f             	xor    $0x1f,%eax
  802596:	89 44 24 10          	mov    %eax,0x10(%esp)
  80259a:	0f 84 a8 00 00 00    	je     802648 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025a0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025a4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025a6:	bf 20 00 00 00       	mov    $0x20,%edi
  8025ab:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8025af:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025b3:	89 f9                	mov    %edi,%ecx
  8025b5:	d3 e8                	shr    %cl,%eax
  8025b7:	09 e8                	or     %ebp,%eax
  8025b9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8025bd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025c1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025c5:	d3 e0                	shl    %cl,%eax
  8025c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025cb:	89 f2                	mov    %esi,%edx
  8025cd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8025cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025d3:	d3 e0                	shl    %cl,%eax
  8025d5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025d9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025dd:	89 f9                	mov    %edi,%ecx
  8025df:	d3 e8                	shr    %cl,%eax
  8025e1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8025e3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025e5:	89 f2                	mov    %esi,%edx
  8025e7:	f7 74 24 18          	divl   0x18(%esp)
  8025eb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8025ed:	f7 64 24 0c          	mull   0xc(%esp)
  8025f1:	89 c5                	mov    %eax,%ebp
  8025f3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025f5:	39 d6                	cmp    %edx,%esi
  8025f7:	72 67                	jb     802660 <__umoddi3+0x114>
  8025f9:	74 75                	je     802670 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8025fb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025ff:	29 e8                	sub    %ebp,%eax
  802601:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802603:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802607:	d3 e8                	shr    %cl,%eax
  802609:	89 f2                	mov    %esi,%edx
  80260b:	89 f9                	mov    %edi,%ecx
  80260d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80260f:	09 d0                	or     %edx,%eax
  802611:	89 f2                	mov    %esi,%edx
  802613:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802617:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802619:	83 c4 20             	add    $0x20,%esp
  80261c:	5e                   	pop    %esi
  80261d:	5f                   	pop    %edi
  80261e:	5d                   	pop    %ebp
  80261f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802620:	85 c9                	test   %ecx,%ecx
  802622:	75 0b                	jne    80262f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802624:	b8 01 00 00 00       	mov    $0x1,%eax
  802629:	31 d2                	xor    %edx,%edx
  80262b:	f7 f1                	div    %ecx
  80262d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80262f:	89 f0                	mov    %esi,%eax
  802631:	31 d2                	xor    %edx,%edx
  802633:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802635:	89 f8                	mov    %edi,%eax
  802637:	e9 3e ff ff ff       	jmp    80257a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80263c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80263e:	83 c4 20             	add    $0x20,%esp
  802641:	5e                   	pop    %esi
  802642:	5f                   	pop    %edi
  802643:	5d                   	pop    %ebp
  802644:	c3                   	ret    
  802645:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802648:	39 f5                	cmp    %esi,%ebp
  80264a:	72 04                	jb     802650 <__umoddi3+0x104>
  80264c:	39 f9                	cmp    %edi,%ecx
  80264e:	77 06                	ja     802656 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802650:	89 f2                	mov    %esi,%edx
  802652:	29 cf                	sub    %ecx,%edi
  802654:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802656:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802658:	83 c4 20             	add    $0x20,%esp
  80265b:	5e                   	pop    %esi
  80265c:	5f                   	pop    %edi
  80265d:	5d                   	pop    %ebp
  80265e:	c3                   	ret    
  80265f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802660:	89 d1                	mov    %edx,%ecx
  802662:	89 c5                	mov    %eax,%ebp
  802664:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802668:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80266c:	eb 8d                	jmp    8025fb <__umoddi3+0xaf>
  80266e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802670:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802674:	72 ea                	jb     802660 <__umoddi3+0x114>
  802676:	89 f1                	mov    %esi,%ecx
  802678:	eb 81                	jmp    8025fb <__umoddi3+0xaf>
