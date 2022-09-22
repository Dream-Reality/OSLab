
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 0a 10 00 00       	call   80104c <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 1b 0b 00 00       	call   800b6b <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 40 26 80 00 	movl   $0x802640,(%esp)
  80005f:	e8 a8 01 00 00       	call   80020c <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 42 13 00 00       	call   8013c9 <ipc_send>
	}
	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 ba 12 00 00       	call   80135c <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 bf 0a 00 00       	call   800b6b <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 56 26 80 00 	movl   $0x802656,(%esp)
  8000bf:	e8 48 01 00 00       	call   80020c <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 25                	je     8000ee <umain+0xba>
			return;
		i++;
  8000c9:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d1:	00 
  8000d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d9:	00 
  8000da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 04 24             	mov    %eax,(%esp)
  8000e4:	e8 e0 12 00 00       	call   8013c9 <ipc_send>
		if (i == 10)
  8000e9:	83 fb 0a             	cmp    $0xa,%ebx
  8000ec:	75 9c                	jne    80008a <umain+0x56>
			return;
	}

}
  8000ee:	83 c4 2c             	add    $0x2c,%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
	...

008000f8 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 20             	sub    $0x20,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800106:	e8 60 0a 00 00       	call   800b6b <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800124:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800127:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012c:	85 f6                	test   %esi,%esi
  80012e:	7e 07                	jle    800137 <libmain+0x3f>
		binaryname = argv[0];
  800130:	8b 03                	mov    (%ebx),%eax
  800132:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013b:	89 34 24             	mov    %esi,(%esp)
  80013e:	e8 f1 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800143:	e8 08 00 00 00       	call   800150 <exit>
}
  800148:	83 c4 20             	add    $0x20,%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800156:	e8 02 15 00 00       	call   80165d <close_all>
	sys_env_destroy(0);
  80015b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800162:	e8 b2 09 00 00       	call   800b19 <sys_env_destroy>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
	...

0080016c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	53                   	push   %ebx
  800170:	83 ec 14             	sub    $0x14,%esp
  800173:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800176:	8b 03                	mov    (%ebx),%eax
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017f:	40                   	inc    %eax
  800180:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800182:	3d ff 00 00 00       	cmp    $0xff,%eax
  800187:	75 19                	jne    8001a2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800189:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800190:	00 
  800191:	8d 43 08             	lea    0x8(%ebx),%eax
  800194:	89 04 24             	mov    %eax,(%esp)
  800197:	e8 40 09 00 00       	call   800adc <sys_cputs>
		b->idx = 0;
  80019c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001a2:	ff 43 04             	incl   0x4(%ebx)
}
  8001a5:	83 c4 14             	add    $0x14,%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bb:	00 00 00 
	b.cnt = 0;
  8001be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e0:	c7 04 24 6c 01 80 00 	movl   $0x80016c,(%esp)
  8001e7:	e8 82 01 00 00       	call   80036e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ec:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fc:	89 04 24             	mov    %eax,(%esp)
  8001ff:	e8 d8 08 00 00       	call   800adc <sys_cputs>

	return b.cnt;
}
  800204:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800212:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800215:	89 44 24 04          	mov    %eax,0x4(%esp)
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	89 04 24             	mov    %eax,(%esp)
  80021f:	e8 87 ff ff ff       	call   8001ab <vcprintf>
	va_end(ap);

	return cnt;
}
  800224:	c9                   	leave  
  800225:	c3                   	ret    
	...

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 3c             	sub    $0x3c,%esp
  800231:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800234:	89 d7                	mov    %edx,%edi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80023c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800245:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800248:	85 c0                	test   %eax,%eax
  80024a:	75 08                	jne    800254 <printnum+0x2c>
  80024c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800252:	77 57                	ja     8002ab <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800254:	89 74 24 10          	mov    %esi,0x10(%esp)
  800258:	4b                   	dec    %ebx
  800259:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80025d:	8b 45 10             	mov    0x10(%ebp),%eax
  800260:	89 44 24 08          	mov    %eax,0x8(%esp)
  800264:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800268:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80026c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800273:	00 
  800274:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800277:	89 04 24             	mov    %eax,(%esp)
  80027a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800281:	e8 52 21 00 00       	call   8023d8 <__udivdi3>
  800286:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80028a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028e:	89 04 24             	mov    %eax,(%esp)
  800291:	89 54 24 04          	mov    %edx,0x4(%esp)
  800295:	89 fa                	mov    %edi,%edx
  800297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029a:	e8 89 ff ff ff       	call   800228 <printnum>
  80029f:	eb 0f                	jmp    8002b0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a5:	89 34 24             	mov    %esi,(%esp)
  8002a8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	4b                   	dec    %ebx
  8002ac:	85 db                	test   %ebx,%ebx
  8002ae:	7f f1                	jg     8002a1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c6:	00 
  8002c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d4:	e8 1f 22 00 00       	call   8024f8 <__umoddi3>
  8002d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002dd:	0f be 80 73 26 80 00 	movsbl 0x802673(%eax),%eax
  8002e4:	89 04 24             	mov    %eax,(%esp)
  8002e7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ea:	83 c4 3c             	add    $0x3c,%esp
  8002ed:	5b                   	pop    %ebx
  8002ee:	5e                   	pop    %esi
  8002ef:	5f                   	pop    %edi
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f5:	83 fa 01             	cmp    $0x1,%edx
  8002f8:	7e 0e                	jle    800308 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	8b 52 04             	mov    0x4(%edx),%edx
  800306:	eb 22                	jmp    80032a <getuint+0x38>
	else if (lflag)
  800308:	85 d2                	test   %edx,%edx
  80030a:	74 10                	je     80031c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
  80031a:	eb 0e                	jmp    80032a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 02                	mov    (%edx),%eax
  800325:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800332:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800335:	8b 10                	mov    (%eax),%edx
  800337:	3b 50 04             	cmp    0x4(%eax),%edx
  80033a:	73 08                	jae    800344 <sprintputch+0x18>
		*b->buf++ = ch;
  80033c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033f:	88 0a                	mov    %cl,(%edx)
  800341:	42                   	inc    %edx
  800342:	89 10                	mov    %edx,(%eax)
}
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80034c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800353:	8b 45 10             	mov    0x10(%ebp),%eax
  800356:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800361:	8b 45 08             	mov    0x8(%ebp),%eax
  800364:	89 04 24             	mov    %eax,(%esp)
  800367:	e8 02 00 00 00       	call   80036e <vprintfmt>
	va_end(ap);
}
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
  800374:	83 ec 4c             	sub    $0x4c,%esp
  800377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037a:	8b 75 10             	mov    0x10(%ebp),%esi
  80037d:	eb 12                	jmp    800391 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037f:	85 c0                	test   %eax,%eax
  800381:	0f 84 6b 03 00 00    	je     8006f2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800387:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80038b:	89 04 24             	mov    %eax,(%esp)
  80038e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800391:	0f b6 06             	movzbl (%esi),%eax
  800394:	46                   	inc    %esi
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e5                	jne    80037f <vprintfmt+0x11>
  80039a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80039e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003a5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003aa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b6:	eb 26                	jmp    8003de <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003bf:	eb 1d                	jmp    8003de <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c8:	eb 14                	jmp    8003de <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003cd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d4:	eb 08                	jmp    8003de <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003d9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	0f b6 06             	movzbl (%esi),%eax
  8003e1:	8d 56 01             	lea    0x1(%esi),%edx
  8003e4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003e7:	8a 16                	mov    (%esi),%dl
  8003e9:	83 ea 23             	sub    $0x23,%edx
  8003ec:	80 fa 55             	cmp    $0x55,%dl
  8003ef:	0f 87 e1 02 00 00    	ja     8006d6 <vprintfmt+0x368>
  8003f5:	0f b6 d2             	movzbl %dl,%edx
  8003f8:	ff 24 95 c0 27 80 00 	jmp    *0x8027c0(,%edx,4)
  8003ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800402:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800407:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80040a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80040e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800411:	8d 50 d0             	lea    -0x30(%eax),%edx
  800414:	83 fa 09             	cmp    $0x9,%edx
  800417:	77 2a                	ja     800443 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800419:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80041a:	eb eb                	jmp    800407 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80042a:	eb 17                	jmp    800443 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80042c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800430:	78 98                	js     8003ca <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800435:	eb a7                	jmp    8003de <vprintfmt+0x70>
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800441:	eb 9b                	jmp    8003de <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800447:	79 95                	jns    8003de <vprintfmt+0x70>
  800449:	eb 8b                	jmp    8003d6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044f:	eb 8d                	jmp    8003de <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800469:	e9 23 ff ff ff       	jmp    800391 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	85 c0                	test   %eax,%eax
  80047b:	79 02                	jns    80047f <vprintfmt+0x111>
  80047d:	f7 d8                	neg    %eax
  80047f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800481:	83 f8 0f             	cmp    $0xf,%eax
  800484:	7f 0b                	jg     800491 <vprintfmt+0x123>
  800486:	8b 04 85 20 29 80 00 	mov    0x802920(,%eax,4),%eax
  80048d:	85 c0                	test   %eax,%eax
  80048f:	75 23                	jne    8004b4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800491:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800495:	c7 44 24 08 8b 26 80 	movl   $0x80268b,0x8(%esp)
  80049c:	00 
  80049d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 9a fe ff ff       	call   800346 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004af:	e9 dd fe ff ff       	jmp    800391 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b8:	c7 44 24 08 b5 2a 80 	movl   $0x802ab5,0x8(%esp)
  8004bf:	00 
  8004c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c7:	89 14 24             	mov    %edx,(%esp)
  8004ca:	e8 77 fe ff ff       	call   800346 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004d2:	e9 ba fe ff ff       	jmp    800391 <vprintfmt+0x23>
  8004d7:	89 f9                	mov    %edi,%ecx
  8004d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	8b 30                	mov    (%eax),%esi
  8004ea:	85 f6                	test   %esi,%esi
  8004ec:	75 05                	jne    8004f3 <vprintfmt+0x185>
				p = "(null)";
  8004ee:	be 84 26 80 00       	mov    $0x802684,%esi
			if (width > 0 && padc != '-')
  8004f3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f7:	0f 8e 84 00 00 00    	jle    800581 <vprintfmt+0x213>
  8004fd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800501:	74 7e                	je     800581 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800507:	89 34 24             	mov    %esi,(%esp)
  80050a:	e8 8b 02 00 00       	call   80079a <strnlen>
  80050f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800512:	29 c2                	sub    %eax,%edx
  800514:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800517:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80051b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80051e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800521:	89 de                	mov    %ebx,%esi
  800523:	89 d3                	mov    %edx,%ebx
  800525:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	eb 0b                	jmp    800534 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800529:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052d:	89 3c 24             	mov    %edi,(%esp)
  800530:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	4b                   	dec    %ebx
  800534:	85 db                	test   %ebx,%ebx
  800536:	7f f1                	jg     800529 <vprintfmt+0x1bb>
  800538:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80053b:	89 f3                	mov    %esi,%ebx
  80053d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800540:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800543:	85 c0                	test   %eax,%eax
  800545:	79 05                	jns    80054c <vprintfmt+0x1de>
  800547:	b8 00 00 00 00       	mov    $0x0,%eax
  80054c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054f:	29 c2                	sub    %eax,%edx
  800551:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800554:	eb 2b                	jmp    800581 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800556:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055a:	74 18                	je     800574 <vprintfmt+0x206>
  80055c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80055f:	83 fa 5e             	cmp    $0x5e,%edx
  800562:	76 10                	jbe    800574 <vprintfmt+0x206>
					putch('?', putdat);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056f:	ff 55 08             	call   *0x8(%ebp)
  800572:	eb 0a                	jmp    80057e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800574:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800578:	89 04 24             	mov    %eax,(%esp)
  80057b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	ff 4d e4             	decl   -0x1c(%ebp)
  800581:	0f be 06             	movsbl (%esi),%eax
  800584:	46                   	inc    %esi
  800585:	85 c0                	test   %eax,%eax
  800587:	74 21                	je     8005aa <vprintfmt+0x23c>
  800589:	85 ff                	test   %edi,%edi
  80058b:	78 c9                	js     800556 <vprintfmt+0x1e8>
  80058d:	4f                   	dec    %edi
  80058e:	79 c6                	jns    800556 <vprintfmt+0x1e8>
  800590:	8b 7d 08             	mov    0x8(%ebp),%edi
  800593:	89 de                	mov    %ebx,%esi
  800595:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a7:	4b                   	dec    %ebx
  8005a8:	eb 08                	jmp    8005b2 <vprintfmt+0x244>
  8005aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ad:	89 de                	mov    %ebx,%esi
  8005af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005b2:	85 db                	test   %ebx,%ebx
  8005b4:	7f e4                	jg     80059a <vprintfmt+0x22c>
  8005b6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005b9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005be:	e9 ce fd ff ff       	jmp    800391 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c3:	83 f9 01             	cmp    $0x1,%ecx
  8005c6:	7e 10                	jle    8005d8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 08             	lea    0x8(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 30                	mov    (%eax),%esi
  8005d3:	8b 78 04             	mov    0x4(%eax),%edi
  8005d6:	eb 26                	jmp    8005fe <vprintfmt+0x290>
	else if (lflag)
  8005d8:	85 c9                	test   %ecx,%ecx
  8005da:	74 12                	je     8005ee <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 30                	mov    (%eax),%esi
  8005e7:	89 f7                	mov    %esi,%edi
  8005e9:	c1 ff 1f             	sar    $0x1f,%edi
  8005ec:	eb 10                	jmp    8005fe <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 30                	mov    (%eax),%esi
  8005f9:	89 f7                	mov    %esi,%edi
  8005fb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fe:	85 ff                	test   %edi,%edi
  800600:	78 0a                	js     80060c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	e9 8c 00 00 00       	jmp    800698 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80060c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800610:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80061a:	f7 de                	neg    %esi
  80061c:	83 d7 00             	adc    $0x0,%edi
  80061f:	f7 df                	neg    %edi
			}
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
  800626:	eb 70                	jmp    800698 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800628:	89 ca                	mov    %ecx,%edx
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 c0 fc ff ff       	call   8002f2 <getuint>
  800632:	89 c6                	mov    %eax,%esi
  800634:	89 d7                	mov    %edx,%edi
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80063b:	eb 5b                	jmp    800698 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  80063d:	89 ca                	mov    %ecx,%edx
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 ab fc ff ff       	call   8002f2 <getuint>
  800647:	89 c6                	mov    %eax,%esi
  800649:	89 d7                	mov    %edx,%edi
			base = 8;
  80064b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800650:	eb 46                	jmp    800698 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800652:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800656:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80065d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800664:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8d 50 04             	lea    0x4(%eax),%edx
  800674:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800677:	8b 30                	mov    (%eax),%esi
  800679:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800683:	eb 13                	jmp    800698 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800685:	89 ca                	mov    %ecx,%edx
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
  80068a:	e8 63 fc ff ff       	call   8002f2 <getuint>
  80068f:	89 c6                	mov    %eax,%esi
  800691:	89 d7                	mov    %edx,%edi
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800698:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80069c:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ab:	89 34 24             	mov    %esi,(%esp)
  8006ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b2:	89 da                	mov    %ebx,%edx
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	e8 6c fb ff ff       	call   800228 <printnum>
			break;
  8006bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006bf:	e9 cd fc ff ff       	jmp    800391 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	89 04 24             	mov    %eax,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d1:	e9 bb fc ff ff       	jmp    800391 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006da:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e4:	eb 01                	jmp    8006e7 <vprintfmt+0x379>
  8006e6:	4e                   	dec    %esi
  8006e7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006eb:	75 f9                	jne    8006e6 <vprintfmt+0x378>
  8006ed:	e9 9f fc ff ff       	jmp    800391 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006f2:	83 c4 4c             	add    $0x4c,%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 28             	sub    $0x28,%esp
  800700:	8b 45 08             	mov    0x8(%ebp),%eax
  800703:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800706:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800709:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800710:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800717:	85 c0                	test   %eax,%eax
  800719:	74 30                	je     80074b <vsnprintf+0x51>
  80071b:	85 d2                	test   %edx,%edx
  80071d:	7e 33                	jle    800752 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800726:	8b 45 10             	mov    0x10(%ebp),%eax
  800729:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800730:	89 44 24 04          	mov    %eax,0x4(%esp)
  800734:	c7 04 24 2c 03 80 00 	movl   $0x80032c,(%esp)
  80073b:	e8 2e fc ff ff       	call   80036e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800740:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800743:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	eb 0c                	jmp    800757 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800750:	eb 05                	jmp    800757 <vsnprintf+0x5d>
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800766:	8b 45 10             	mov    0x10(%ebp),%eax
  800769:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800770:	89 44 24 04          	mov    %eax,0x4(%esp)
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	89 04 24             	mov    %eax,(%esp)
  80077a:	e8 7b ff ff ff       	call   8006fa <vsnprintf>
	va_end(ap);

	return rc;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    
  800781:	00 00                	add    %al,(%eax)
	...

00800784 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
  80078f:	eb 01                	jmp    800792 <strlen+0xe>
		n++;
  800791:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800792:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800796:	75 f9                	jne    800791 <strlen+0xd>
		n++;
	return n;
}
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007a0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a8:	eb 01                	jmp    8007ab <strnlen+0x11>
		n++;
  8007aa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	39 d0                	cmp    %edx,%eax
  8007ad:	74 06                	je     8007b5 <strnlen+0x1b>
  8007af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b3:	75 f5                	jne    8007aa <strnlen+0x10>
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007cc:	42                   	inc    %edx
  8007cd:	84 c9                	test   %cl,%cl
  8007cf:	75 f5                	jne    8007c6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d1:	5b                   	pop    %ebx
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	83 ec 08             	sub    $0x8,%esp
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007de:	89 1c 24             	mov    %ebx,(%esp)
  8007e1:	e8 9e ff ff ff       	call   800784 <strlen>
	strcpy(dst + len, src);
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ed:	01 d8                	add    %ebx,%eax
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	e8 c0 ff ff ff       	call   8007b7 <strcpy>
	return dst;
}
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	83 c4 08             	add    $0x8,%esp
  8007fc:	5b                   	pop    %ebx
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800812:	eb 0c                	jmp    800820 <strncpy+0x21>
		*dst++ = *src;
  800814:	8a 1a                	mov    (%edx),%bl
  800816:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800819:	80 3a 01             	cmpb   $0x1,(%edx)
  80081c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081f:	41                   	inc    %ecx
  800820:	39 f1                	cmp    %esi,%ecx
  800822:	75 f0                	jne    800814 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800833:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800836:	85 d2                	test   %edx,%edx
  800838:	75 0a                	jne    800844 <strlcpy+0x1c>
  80083a:	89 f0                	mov    %esi,%eax
  80083c:	eb 1a                	jmp    800858 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083e:	88 18                	mov    %bl,(%eax)
  800840:	40                   	inc    %eax
  800841:	41                   	inc    %ecx
  800842:	eb 02                	jmp    800846 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800844:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800846:	4a                   	dec    %edx
  800847:	74 0a                	je     800853 <strlcpy+0x2b>
  800849:	8a 19                	mov    (%ecx),%bl
  80084b:	84 db                	test   %bl,%bl
  80084d:	75 ef                	jne    80083e <strlcpy+0x16>
  80084f:	89 c2                	mov    %eax,%edx
  800851:	eb 02                	jmp    800855 <strlcpy+0x2d>
  800853:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800855:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800858:	29 f0                	sub    %esi,%eax
}
  80085a:	5b                   	pop    %ebx
  80085b:	5e                   	pop    %esi
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800864:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800867:	eb 02                	jmp    80086b <strcmp+0xd>
		p++, q++;
  800869:	41                   	inc    %ecx
  80086a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086b:	8a 01                	mov    (%ecx),%al
  80086d:	84 c0                	test   %al,%al
  80086f:	74 04                	je     800875 <strcmp+0x17>
  800871:	3a 02                	cmp    (%edx),%al
  800873:	74 f4                	je     800869 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800875:	0f b6 c0             	movzbl %al,%eax
  800878:	0f b6 12             	movzbl (%edx),%edx
  80087b:	29 d0                	sub    %edx,%eax
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	53                   	push   %ebx
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800889:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80088c:	eb 03                	jmp    800891 <strncmp+0x12>
		n--, p++, q++;
  80088e:	4a                   	dec    %edx
  80088f:	40                   	inc    %eax
  800890:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800891:	85 d2                	test   %edx,%edx
  800893:	74 14                	je     8008a9 <strncmp+0x2a>
  800895:	8a 18                	mov    (%eax),%bl
  800897:	84 db                	test   %bl,%bl
  800899:	74 04                	je     80089f <strncmp+0x20>
  80089b:	3a 19                	cmp    (%ecx),%bl
  80089d:	74 ef                	je     80088e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089f:	0f b6 00             	movzbl (%eax),%eax
  8008a2:	0f b6 11             	movzbl (%ecx),%edx
  8008a5:	29 d0                	sub    %edx,%eax
  8008a7:	eb 05                	jmp    8008ae <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ba:	eb 05                	jmp    8008c1 <strchr+0x10>
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	74 0c                	je     8008cc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c0:	40                   	inc    %eax
  8008c1:	8a 10                	mov    (%eax),%dl
  8008c3:	84 d2                	test   %dl,%dl
  8008c5:	75 f5                	jne    8008bc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d7:	eb 05                	jmp    8008de <strfind+0x10>
		if (*s == c)
  8008d9:	38 ca                	cmp    %cl,%dl
  8008db:	74 07                	je     8008e4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008dd:	40                   	inc    %eax
  8008de:	8a 10                	mov    (%eax),%dl
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	75 f5                	jne    8008d9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	57                   	push   %edi
  8008ea:	56                   	push   %esi
  8008eb:	53                   	push   %ebx
  8008ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f5:	85 c9                	test   %ecx,%ecx
  8008f7:	74 30                	je     800929 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ff:	75 25                	jne    800926 <memset+0x40>
  800901:	f6 c1 03             	test   $0x3,%cl
  800904:	75 20                	jne    800926 <memset+0x40>
		c &= 0xFF;
  800906:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800909:	89 d3                	mov    %edx,%ebx
  80090b:	c1 e3 08             	shl    $0x8,%ebx
  80090e:	89 d6                	mov    %edx,%esi
  800910:	c1 e6 18             	shl    $0x18,%esi
  800913:	89 d0                	mov    %edx,%eax
  800915:	c1 e0 10             	shl    $0x10,%eax
  800918:	09 f0                	or     %esi,%eax
  80091a:	09 d0                	or     %edx,%eax
  80091c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800921:	fc                   	cld    
  800922:	f3 ab                	rep stos %eax,%es:(%edi)
  800924:	eb 03                	jmp    800929 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800926:	fc                   	cld    
  800927:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800929:	89 f8                	mov    %edi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	57                   	push   %edi
  800934:	56                   	push   %esi
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093e:	39 c6                	cmp    %eax,%esi
  800940:	73 34                	jae    800976 <memmove+0x46>
  800942:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800945:	39 d0                	cmp    %edx,%eax
  800947:	73 2d                	jae    800976 <memmove+0x46>
		s += n;
		d += n;
  800949:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094c:	f6 c2 03             	test   $0x3,%dl
  80094f:	75 1b                	jne    80096c <memmove+0x3c>
  800951:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800957:	75 13                	jne    80096c <memmove+0x3c>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 0e                	jne    80096c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095e:	83 ef 04             	sub    $0x4,%edi
  800961:	8d 72 fc             	lea    -0x4(%edx),%esi
  800964:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800967:	fd                   	std    
  800968:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096a:	eb 07                	jmp    800973 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096c:	4f                   	dec    %edi
  80096d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800970:	fd                   	std    
  800971:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800973:	fc                   	cld    
  800974:	eb 20                	jmp    800996 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800976:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097c:	75 13                	jne    800991 <memmove+0x61>
  80097e:	a8 03                	test   $0x3,%al
  800980:	75 0f                	jne    800991 <memmove+0x61>
  800982:	f6 c1 03             	test   $0x3,%cl
  800985:	75 0a                	jne    800991 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800987:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80098a:	89 c7                	mov    %eax,%edi
  80098c:	fc                   	cld    
  80098d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098f:	eb 05                	jmp    800996 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800991:	89 c7                	mov    %eax,%edi
  800993:	fc                   	cld    
  800994:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800996:	5e                   	pop    %esi
  800997:	5f                   	pop    %edi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	89 04 24             	mov    %eax,(%esp)
  8009b4:	e8 77 ff ff ff       	call   800930 <memmove>
}
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	57                   	push   %edi
  8009bf:	56                   	push   %esi
  8009c0:	53                   	push   %ebx
  8009c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cf:	eb 16                	jmp    8009e7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009d4:	42                   	inc    %edx
  8009d5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009d9:	38 c8                	cmp    %cl,%al
  8009db:	74 0a                	je     8009e7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009dd:	0f b6 c0             	movzbl %al,%eax
  8009e0:	0f b6 c9             	movzbl %cl,%ecx
  8009e3:	29 c8                	sub    %ecx,%eax
  8009e5:	eb 09                	jmp    8009f0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e7:	39 da                	cmp    %ebx,%edx
  8009e9:	75 e6                	jne    8009d1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fe:	89 c2                	mov    %eax,%edx
  800a00:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a03:	eb 05                	jmp    800a0a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a05:	38 08                	cmp    %cl,(%eax)
  800a07:	74 05                	je     800a0e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a09:	40                   	inc    %eax
  800a0a:	39 d0                	cmp    %edx,%eax
  800a0c:	72 f7                	jb     800a05 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 55 08             	mov    0x8(%ebp),%edx
  800a19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1c:	eb 01                	jmp    800a1f <strtol+0xf>
		s++;
  800a1e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1f:	8a 02                	mov    (%edx),%al
  800a21:	3c 20                	cmp    $0x20,%al
  800a23:	74 f9                	je     800a1e <strtol+0xe>
  800a25:	3c 09                	cmp    $0x9,%al
  800a27:	74 f5                	je     800a1e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a29:	3c 2b                	cmp    $0x2b,%al
  800a2b:	75 08                	jne    800a35 <strtol+0x25>
		s++;
  800a2d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a33:	eb 13                	jmp    800a48 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a35:	3c 2d                	cmp    $0x2d,%al
  800a37:	75 0a                	jne    800a43 <strtol+0x33>
		s++, neg = 1;
  800a39:	8d 52 01             	lea    0x1(%edx),%edx
  800a3c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a41:	eb 05                	jmp    800a48 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a43:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a48:	85 db                	test   %ebx,%ebx
  800a4a:	74 05                	je     800a51 <strtol+0x41>
  800a4c:	83 fb 10             	cmp    $0x10,%ebx
  800a4f:	75 28                	jne    800a79 <strtol+0x69>
  800a51:	8a 02                	mov    (%edx),%al
  800a53:	3c 30                	cmp    $0x30,%al
  800a55:	75 10                	jne    800a67 <strtol+0x57>
  800a57:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a5b:	75 0a                	jne    800a67 <strtol+0x57>
		s += 2, base = 16;
  800a5d:	83 c2 02             	add    $0x2,%edx
  800a60:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a65:	eb 12                	jmp    800a79 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a67:	85 db                	test   %ebx,%ebx
  800a69:	75 0e                	jne    800a79 <strtol+0x69>
  800a6b:	3c 30                	cmp    $0x30,%al
  800a6d:	75 05                	jne    800a74 <strtol+0x64>
		s++, base = 8;
  800a6f:	42                   	inc    %edx
  800a70:	b3 08                	mov    $0x8,%bl
  800a72:	eb 05                	jmp    800a79 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a74:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a79:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a80:	8a 0a                	mov    (%edx),%cl
  800a82:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a85:	80 fb 09             	cmp    $0x9,%bl
  800a88:	77 08                	ja     800a92 <strtol+0x82>
			dig = *s - '0';
  800a8a:	0f be c9             	movsbl %cl,%ecx
  800a8d:	83 e9 30             	sub    $0x30,%ecx
  800a90:	eb 1e                	jmp    800ab0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a92:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a95:	80 fb 19             	cmp    $0x19,%bl
  800a98:	77 08                	ja     800aa2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a9a:	0f be c9             	movsbl %cl,%ecx
  800a9d:	83 e9 57             	sub    $0x57,%ecx
  800aa0:	eb 0e                	jmp    800ab0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aa2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 12                	ja     800abc <strtol+0xac>
			dig = *s - 'A' + 10;
  800aaa:	0f be c9             	movsbl %cl,%ecx
  800aad:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ab0:	39 f1                	cmp    %esi,%ecx
  800ab2:	7d 0c                	jge    800ac0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ab4:	42                   	inc    %edx
  800ab5:	0f af c6             	imul   %esi,%eax
  800ab8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aba:	eb c4                	jmp    800a80 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800abc:	89 c1                	mov    %eax,%ecx
  800abe:	eb 02                	jmp    800ac2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac6:	74 05                	je     800acd <strtol+0xbd>
		*endptr = (char *) s;
  800ac8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800acb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800acd:	85 ff                	test   %edi,%edi
  800acf:	74 04                	je     800ad5 <strtol+0xc5>
  800ad1:	89 c8                	mov    %ecx,%eax
  800ad3:	f7 d8                	neg    %eax
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    
	...

00800adc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aea:	8b 55 08             	mov    0x8(%ebp),%edx
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	89 c7                	mov    %eax,%edi
  800af1:	89 c6                	mov    %eax,%esi
  800af3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_cgetc>:

int
sys_cgetc(void)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b27:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	89 cb                	mov    %ecx,%ebx
  800b31:	89 cf                	mov    %ecx,%edi
  800b33:	89 ce                	mov    %ecx,%esi
  800b35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b37:	85 c0                	test   %eax,%eax
  800b39:	7e 28                	jle    800b63 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b3f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b46:	00 
  800b47:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800b4e:	00 
  800b4f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b56:	00 
  800b57:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800b5e:	e8 21 17 00 00       	call   802284 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b63:	83 c4 2c             	add    $0x2c,%esp
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b71:	ba 00 00 00 00       	mov    $0x0,%edx
  800b76:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7b:	89 d1                	mov    %edx,%ecx
  800b7d:	89 d3                	mov    %edx,%ebx
  800b7f:	89 d7                	mov    %edx,%edi
  800b81:	89 d6                	mov    %edx,%esi
  800b83:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <sys_yield>:

void
sys_yield(void)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b90:	ba 00 00 00 00       	mov    $0x0,%edx
  800b95:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9a:	89 d1                	mov    %edx,%ecx
  800b9c:	89 d3                	mov    %edx,%ebx
  800b9e:	89 d7                	mov    %edx,%edi
  800ba0:	89 d6                	mov    %edx,%esi
  800ba2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	be 00 00 00 00       	mov    $0x0,%esi
  800bb7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	89 f7                	mov    %esi,%edi
  800bc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	7e 28                	jle    800bf5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd8:	00 
  800bd9:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800be0:	00 
  800be1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be8:	00 
  800be9:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800bf0:	e8 8f 16 00 00       	call   802284 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf5:	83 c4 2c             	add    $0x2c,%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c06:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7e 28                	jle    800c48 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c24:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c2b:	00 
  800c2c:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800c33:	00 
  800c34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3b:	00 
  800c3c:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800c43:	e8 3c 16 00 00       	call   802284 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c48:	83 c4 2c             	add    $0x2c,%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	89 df                	mov    %ebx,%edi
  800c6b:	89 de                	mov    %ebx,%esi
  800c6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	7e 28                	jle    800c9b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c77:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800c86:	00 
  800c87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8e:	00 
  800c8f:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800c96:	e8 e9 15 00 00       	call   802284 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9b:	83 c4 2c             	add    $0x2c,%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 28                	jle    800cee <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cca:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cd1:	00 
  800cd2:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800cd9:	00 
  800cda:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce1:	00 
  800ce2:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800ce9:	e8 96 15 00 00       	call   802284 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cee:	83 c4 2c             	add    $0x2c,%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d04:	b8 09 00 00 00       	mov    $0x9,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 df                	mov    %ebx,%edi
  800d11:	89 de                	mov    %ebx,%esi
  800d13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7e 28                	jle    800d41 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d24:	00 
  800d25:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800d2c:	00 
  800d2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d34:	00 
  800d35:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800d3c:	e8 43 15 00 00       	call   802284 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d41:	83 c4 2c             	add    $0x2c,%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d57:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	89 df                	mov    %ebx,%edi
  800d64:	89 de                	mov    %ebx,%esi
  800d66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	7e 28                	jle    800d94 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d70:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d77:	00 
  800d78:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800d7f:	00 
  800d80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d87:	00 
  800d88:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800d8f:	e8 f0 14 00 00       	call   802284 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d94:	83 c4 2c             	add    $0x2c,%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da2:	be 00 00 00 00       	mov    $0x0,%esi
  800da7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dac:	8b 7d 14             	mov    0x14(%ebp),%edi
  800daf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	89 cb                	mov    %ecx,%ebx
  800dd7:	89 cf                	mov    %ecx,%edi
  800dd9:	89 ce                	mov    %ecx,%esi
  800ddb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	7e 28                	jle    800e09 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dec:	00 
  800ded:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800df4:	00 
  800df5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfc:	00 
  800dfd:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800e04:	e8 7b 14 00 00       	call   802284 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e09:	83 c4 2c             	add    $0x2c,%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    
  800e11:	00 00                	add    %al,(%eax)
	...

00800e14 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 3c             	sub    $0x3c,%esp
  800e1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800e20:	89 d6                	mov    %edx,%esi
  800e22:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800e25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800e2f:	e8 37 fd ff ff       	call   800b6b <sys_getenvid>
  800e34:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800e36:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800e3d:	74 31                	je     800e70 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800e3f:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800e46:	00 
  800e47:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e52:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e56:	89 3c 24             	mov    %edi,(%esp)
  800e59:	e8 9f fd ff ff       	call   800bfd <sys_page_map>
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	0f 8e ae 00 00 00    	jle    800f14 <duppage+0x100>
  800e66:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6b:	e9 a4 00 00 00       	jmp    800f14 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e73:	25 02 08 00 00       	and    $0x802,%eax
  800e78:	83 f8 01             	cmp    $0x1,%eax
  800e7b:	19 db                	sbb    %ebx,%ebx
  800e7d:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800e83:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800e89:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e8d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e91:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e94:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e98:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e9c:	89 3c 24             	mov    %edi,(%esp)
  800e9f:	e8 59 fd ff ff       	call   800bfd <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	79 1c                	jns    800ec4 <duppage+0xb0>
  800ea8:	c7 44 24 08 aa 29 80 	movl   $0x8029aa,0x8(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800eb7:	00 
  800eb8:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800ebf:	e8 c0 13 00 00       	call   802284 <_panic>
	if ((perm|~pte)&PTE_COW){
  800ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ec7:	f7 d0                	not    %eax
  800ec9:	09 d8                	or     %ebx,%eax
  800ecb:	f6 c4 08             	test   $0x8,%ah
  800ece:	74 38                	je     800f08 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800ed0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800ed4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ed8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800edc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee0:	89 3c 24             	mov    %edi,(%esp)
  800ee3:	e8 15 fd ff ff       	call   800bfd <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	79 23                	jns    800f0f <duppage+0xfb>
  800eec:	c7 44 24 08 aa 29 80 	movl   $0x8029aa,0x8(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800efb:	00 
  800efc:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800f03:	e8 7c 13 00 00       	call   802284 <_panic>
	}
	return 0;
  800f08:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0d:	eb 05                	jmp    800f14 <duppage+0x100>
  800f0f:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  800f14:	83 c4 3c             	add    $0x3c,%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 20             	sub    $0x20,%esp
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f27:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800f29:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f2d:	75 1c                	jne    800f4b <pgfault+0x2f>
		panic("pgfault: error!\n");
  800f2f:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800f46:	e8 39 13 00 00       	call   802284 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800f4b:	89 f0                	mov    %esi,%eax
  800f4d:	c1 e8 0c             	shr    $0xc,%eax
  800f50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f57:	f6 c4 08             	test   $0x8,%ah
  800f5a:	75 1c                	jne    800f78 <pgfault+0x5c>
		panic("pgfault: error!\n");
  800f5c:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  800f63:	00 
  800f64:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800f6b:	00 
  800f6c:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800f73:	e8 0c 13 00 00       	call   802284 <_panic>
	envid_t envid = sys_getenvid();
  800f78:	e8 ee fb ff ff       	call   800b6b <sys_getenvid>
  800f7d:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800f7f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f86:	00 
  800f87:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f8e:	00 
  800f8f:	89 04 24             	mov    %eax,(%esp)
  800f92:	e8 12 fc ff ff       	call   800ba9 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800f97:	85 c0                	test   %eax,%eax
  800f99:	79 1c                	jns    800fb7 <pgfault+0x9b>
  800f9b:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  800fa2:	00 
  800fa3:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800faa:	00 
  800fab:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800fb2:	e8 cd 12 00 00       	call   802284 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800fb7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  800fbd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fc4:	00 
  800fc5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fd0:	e8 c5 f9 ff ff       	call   80099a <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  800fd5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fdc:	00 
  800fdd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fe1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fe5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fec:	00 
  800fed:	89 1c 24             	mov    %ebx,(%esp)
  800ff0:	e8 08 fc ff ff       	call   800bfd <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 1c                	jns    801015 <pgfault+0xf9>
  800ff9:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  801000:	00 
  801001:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801008:	00 
  801009:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  801010:	e8 6f 12 00 00       	call   802284 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801015:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80101c:	00 
  80101d:	89 1c 24             	mov    %ebx,(%esp)
  801020:	e8 2b fc ff ff       	call   800c50 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  801025:	85 c0                	test   %eax,%eax
  801027:	79 1c                	jns    801045 <pgfault+0x129>
  801029:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  801030:	00 
  801031:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801038:	00 
  801039:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  801040:	e8 3f 12 00 00       	call   802284 <_panic>
	return;
	panic("pgfault not implemented");
}
  801045:	83 c4 20             	add    $0x20,%esp
  801048:	5b                   	pop    %ebx
  801049:	5e                   	pop    %esi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	57                   	push   %edi
  801050:	56                   	push   %esi
  801051:	53                   	push   %ebx
  801052:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801055:	c7 04 24 1c 0f 80 00 	movl   $0x800f1c,(%esp)
  80105c:	e8 7b 12 00 00       	call   8022dc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801061:	bf 07 00 00 00       	mov    $0x7,%edi
  801066:	89 f8                	mov    %edi,%eax
  801068:	cd 30                	int    $0x30
  80106a:	89 c7                	mov    %eax,%edi
  80106c:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 1c                	jns    80108e <fork+0x42>
		panic("fork : error!\n");
  801072:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  801079:	00 
  80107a:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  801081:	00 
  801082:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  801089:	e8 f6 11 00 00       	call   802284 <_panic>
	if (envid==0){
  80108e:	85 c0                	test   %eax,%eax
  801090:	75 28                	jne    8010ba <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  801092:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801098:	e8 ce fa ff ff       	call   800b6b <sys_getenvid>
  80109d:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010a2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010a9:	c1 e0 07             	shl    $0x7,%eax
  8010ac:	29 d0                	sub    %edx,%eax
  8010ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010b3:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  8010b5:	e9 f2 00 00 00       	jmp    8011ac <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  8010ba:	e8 ac fa ff ff       	call   800b6b <sys_getenvid>
  8010bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8010c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  8010c7:	89 d8                	mov    %ebx,%eax
  8010c9:	c1 e8 16             	shr    $0x16,%eax
  8010cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d3:	a8 01                	test   $0x1,%al
  8010d5:	74 17                	je     8010ee <fork+0xa2>
  8010d7:	89 da                	mov    %ebx,%edx
  8010d9:	c1 ea 0c             	shr    $0xc,%edx
  8010dc:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010e3:	a8 01                	test   $0x1,%al
  8010e5:	74 07                	je     8010ee <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	e8 26 fd ff ff       	call   800e14 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8010ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010fa:	75 cb                	jne    8010c7 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  8010fc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801103:	00 
  801104:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80110b:	ee 
  80110c:	89 3c 24             	mov    %edi,(%esp)
  80110f:	e8 95 fa ff ff       	call   800ba9 <sys_page_alloc>
  801114:	85 c0                	test   %eax,%eax
  801116:	79 1c                	jns    801134 <fork+0xe8>
  801118:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  80111f:	00 
  801120:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801127:	00 
  801128:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  80112f:	e8 50 11 00 00       	call   802284 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  801134:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801137:	25 ff 03 00 00       	and    $0x3ff,%eax
  80113c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801143:	c1 e0 07             	shl    $0x7,%eax
  801146:	29 d0                	sub    %edx,%eax
  801148:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80114d:	8b 40 64             	mov    0x64(%eax),%eax
  801150:	89 44 24 04          	mov    %eax,0x4(%esp)
  801154:	89 3c 24             	mov    %edi,(%esp)
  801157:	e8 ed fb ff ff       	call   800d49 <sys_env_set_pgfault_upcall>
  80115c:	85 c0                	test   %eax,%eax
  80115e:	79 1c                	jns    80117c <fork+0x130>
  801160:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  801167:	00 
  801168:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80116f:	00 
  801170:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  801177:	e8 08 11 00 00       	call   802284 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  80117c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801183:	00 
  801184:	89 3c 24             	mov    %edi,(%esp)
  801187:	e8 17 fb ff ff       	call   800ca3 <sys_env_set_status>
  80118c:	85 c0                	test   %eax,%eax
  80118e:	79 1c                	jns    8011ac <fork+0x160>
  801190:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  801197:	00 
  801198:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  80119f:	00 
  8011a0:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  8011a7:	e8 d8 10 00 00       	call   802284 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  8011ac:	89 f8                	mov    %edi,%eax
  8011ae:	83 c4 2c             	add    $0x2c,%esp
  8011b1:	5b                   	pop    %ebx
  8011b2:	5e                   	pop    %esi
  8011b3:	5f                   	pop    %edi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	57                   	push   %edi
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8011bf:	c7 04 24 1c 0f 80 00 	movl   $0x800f1c,(%esp)
  8011c6:	e8 11 11 00 00       	call   8022dc <set_pgfault_handler>
  8011cb:	ba 07 00 00 00       	mov    $0x7,%edx
  8011d0:	89 d0                	mov    %edx,%eax
  8011d2:	cd 30                	int    $0x30
  8011d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011d7:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  8011d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011dd:	c7 04 24 d7 29 80 00 	movl   $0x8029d7,(%esp)
  8011e4:	e8 23 f0 ff ff       	call   80020c <cprintf>
	if (envid<0)
  8011e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011ed:	79 1c                	jns    80120b <sfork+0x55>
		panic("sfork : error!\n");
  8011ef:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  8011fe:	00 
  8011ff:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  801206:	e8 79 10 00 00       	call   802284 <_panic>
	if (envid==0){
  80120b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80120f:	75 28                	jne    801239 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  801211:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801217:	e8 4f f9 ff ff       	call   800b6b <sys_getenvid>
  80121c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801221:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801228:	c1 e0 07             	shl    $0x7,%eax
  80122b:	29 d0                	sub    %edx,%eax
  80122d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801232:	89 03                	mov    %eax,(%ebx)
		return envid;
  801234:	e9 18 01 00 00       	jmp    801351 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801239:	e8 2d f9 ff ff       	call   800b6b <sys_getenvid>
  80123e:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801240:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801245:	89 d8                	mov    %ebx,%eax
  801247:	c1 e8 16             	shr    $0x16,%eax
  80124a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801251:	a8 01                	test   $0x1,%al
  801253:	74 2c                	je     801281 <sfork+0xcb>
  801255:	89 d8                	mov    %ebx,%eax
  801257:	c1 e8 0c             	shr    $0xc,%eax
  80125a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801261:	a8 01                	test   $0x1,%al
  801263:	74 1c                	je     801281 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  801265:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80126c:	00 
  80126d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801271:	89 74 24 08          	mov    %esi,0x8(%esp)
  801275:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801279:	89 3c 24             	mov    %edi,(%esp)
  80127c:	e8 7c f9 ff ff       	call   800bfd <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801281:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801287:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  80128d:	75 b6                	jne    801245 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  80128f:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801294:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801297:	e8 78 fb ff ff       	call   800e14 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  80129c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012a3:	00 
  8012a4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012ab:	ee 
  8012ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012af:	89 04 24             	mov    %eax,(%esp)
  8012b2:	e8 f2 f8 ff ff       	call   800ba9 <sys_page_alloc>
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	79 1c                	jns    8012d7 <sfork+0x121>
  8012bb:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  8012c2:	00 
  8012c3:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8012ca:	00 
  8012cb:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  8012d2:	e8 ad 0f 00 00       	call   802284 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  8012d7:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  8012dd:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  8012e4:	c1 e7 07             	shl    $0x7,%edi
  8012e7:	29 d7                	sub    %edx,%edi
  8012e9:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  8012ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f6:	89 04 24             	mov    %eax,(%esp)
  8012f9:	e8 4b fa ff ff       	call   800d49 <sys_env_set_pgfault_upcall>
  8012fe:	85 c0                	test   %eax,%eax
  801300:	79 1c                	jns    80131e <sfork+0x168>
  801302:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  801309:	00 
  80130a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  801311:	00 
  801312:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  801319:	e8 66 0f 00 00       	call   802284 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  80131e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801325:	00 
  801326:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801329:	89 04 24             	mov    %eax,(%esp)
  80132c:	e8 72 f9 ff ff       	call   800ca3 <sys_env_set_status>
  801331:	85 c0                	test   %eax,%eax
  801333:	79 1c                	jns    801351 <sfork+0x19b>
  801335:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  80133c:	00 
  80133d:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801344:	00 
  801345:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  80134c:	e8 33 0f 00 00       	call   802284 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  801351:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801354:	83 c4 3c             	add    $0x3c,%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5f                   	pop    %edi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	56                   	push   %esi
  801360:	53                   	push   %ebx
  801361:	83 ec 10             	sub    $0x10,%esp
  801364:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801367:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80136d:	85 c0                	test   %eax,%eax
  80136f:	75 05                	jne    801376 <ipc_recv+0x1a>
  801371:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801376:	89 04 24             	mov    %eax,(%esp)
  801379:	e8 41 fa ff ff       	call   800dbf <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80137e:	85 c0                	test   %eax,%eax
  801380:	79 16                	jns    801398 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801382:	85 db                	test   %ebx,%ebx
  801384:	74 06                	je     80138c <ipc_recv+0x30>
  801386:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  80138c:	85 f6                	test   %esi,%esi
  80138e:	74 32                	je     8013c2 <ipc_recv+0x66>
  801390:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801396:	eb 2a                	jmp    8013c2 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801398:	85 db                	test   %ebx,%ebx
  80139a:	74 0c                	je     8013a8 <ipc_recv+0x4c>
  80139c:	a1 04 40 80 00       	mov    0x804004,%eax
  8013a1:	8b 00                	mov    (%eax),%eax
  8013a3:	8b 40 74             	mov    0x74(%eax),%eax
  8013a6:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8013a8:	85 f6                	test   %esi,%esi
  8013aa:	74 0c                	je     8013b8 <ipc_recv+0x5c>
  8013ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b1:	8b 00                	mov    (%eax),%eax
  8013b3:	8b 40 78             	mov    0x78(%eax),%eax
  8013b6:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  8013b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8013bd:	8b 00                	mov    (%eax),%eax
  8013bf:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    

008013c9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	57                   	push   %edi
  8013cd:	56                   	push   %esi
  8013ce:	53                   	push   %ebx
  8013cf:	83 ec 1c             	sub    $0x1c,%esp
  8013d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013d8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8013db:	85 db                	test   %ebx,%ebx
  8013dd:	75 05                	jne    8013e4 <ipc_send+0x1b>
  8013df:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8013e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8013e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f3:	89 04 24             	mov    %eax,(%esp)
  8013f6:	e8 a1 f9 ff ff       	call   800d9c <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8013fb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013fe:	75 07                	jne    801407 <ipc_send+0x3e>
  801400:	e8 85 f7 ff ff       	call   800b8a <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801405:	eb dd                	jmp    8013e4 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801407:	85 c0                	test   %eax,%eax
  801409:	79 1c                	jns    801427 <ipc_send+0x5e>
  80140b:	c7 44 24 08 f2 29 80 	movl   $0x8029f2,0x8(%esp)
  801412:	00 
  801413:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80141a:	00 
  80141b:	c7 04 24 04 2a 80 00 	movl   $0x802a04,(%esp)
  801422:	e8 5d 0e 00 00       	call   802284 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801427:	83 c4 1c             	add    $0x1c,%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5f                   	pop    %edi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	53                   	push   %ebx
  801433:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801436:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80143b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801442:	89 c2                	mov    %eax,%edx
  801444:	c1 e2 07             	shl    $0x7,%edx
  801447:	29 ca                	sub    %ecx,%edx
  801449:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80144f:	8b 52 50             	mov    0x50(%edx),%edx
  801452:	39 da                	cmp    %ebx,%edx
  801454:	75 0f                	jne    801465 <ipc_find_env+0x36>
			return envs[i].env_id;
  801456:	c1 e0 07             	shl    $0x7,%eax
  801459:	29 c8                	sub    %ecx,%eax
  80145b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801460:	8b 40 40             	mov    0x40(%eax),%eax
  801463:	eb 0c                	jmp    801471 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801465:	40                   	inc    %eax
  801466:	3d 00 04 00 00       	cmp    $0x400,%eax
  80146b:	75 ce                	jne    80143b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80146d:	66 b8 00 00          	mov    $0x0,%ax
}
  801471:	5b                   	pop    %ebx
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801477:	8b 45 08             	mov    0x8(%ebp),%eax
  80147a:	05 00 00 00 30       	add    $0x30000000,%eax
  80147f:	c1 e8 0c             	shr    $0xc,%eax
}
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80148a:	8b 45 08             	mov    0x8(%ebp),%eax
  80148d:	89 04 24             	mov    %eax,(%esp)
  801490:	e8 df ff ff ff       	call   801474 <fd2num>
  801495:	05 20 00 0d 00       	add    $0xd0020,%eax
  80149a:	c1 e0 0c             	shl    $0xc,%eax
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	53                   	push   %ebx
  8014a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014a6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014ab:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	c1 ea 16             	shr    $0x16,%edx
  8014b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014b9:	f6 c2 01             	test   $0x1,%dl
  8014bc:	74 11                	je     8014cf <fd_alloc+0x30>
  8014be:	89 c2                	mov    %eax,%edx
  8014c0:	c1 ea 0c             	shr    $0xc,%edx
  8014c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ca:	f6 c2 01             	test   $0x1,%dl
  8014cd:	75 09                	jne    8014d8 <fd_alloc+0x39>
			*fd_store = fd;
  8014cf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d6:	eb 17                	jmp    8014ef <fd_alloc+0x50>
  8014d8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014dd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014e2:	75 c7                	jne    8014ab <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014ea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014ef:	5b                   	pop    %ebx
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014f8:	83 f8 1f             	cmp    $0x1f,%eax
  8014fb:	77 36                	ja     801533 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014fd:	05 00 00 0d 00       	add    $0xd0000,%eax
  801502:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801505:	89 c2                	mov    %eax,%edx
  801507:	c1 ea 16             	shr    $0x16,%edx
  80150a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801511:	f6 c2 01             	test   $0x1,%dl
  801514:	74 24                	je     80153a <fd_lookup+0x48>
  801516:	89 c2                	mov    %eax,%edx
  801518:	c1 ea 0c             	shr    $0xc,%edx
  80151b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801522:	f6 c2 01             	test   $0x1,%dl
  801525:	74 1a                	je     801541 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801527:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152a:	89 02                	mov    %eax,(%edx)
	return 0;
  80152c:	b8 00 00 00 00       	mov    $0x0,%eax
  801531:	eb 13                	jmp    801546 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801533:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801538:	eb 0c                	jmp    801546 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80153a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153f:	eb 05                	jmp    801546 <fd_lookup+0x54>
  801541:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801546:	5d                   	pop    %ebp
  801547:	c3                   	ret    

00801548 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	53                   	push   %ebx
  80154c:	83 ec 14             	sub    $0x14,%esp
  80154f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801555:	ba 00 00 00 00       	mov    $0x0,%edx
  80155a:	eb 0e                	jmp    80156a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80155c:	39 08                	cmp    %ecx,(%eax)
  80155e:	75 09                	jne    801569 <dev_lookup+0x21>
			*dev = devtab[i];
  801560:	89 03                	mov    %eax,(%ebx)
			return 0;
  801562:	b8 00 00 00 00       	mov    $0x0,%eax
  801567:	eb 35                	jmp    80159e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801569:	42                   	inc    %edx
  80156a:	8b 04 95 8c 2a 80 00 	mov    0x802a8c(,%edx,4),%eax
  801571:	85 c0                	test   %eax,%eax
  801573:	75 e7                	jne    80155c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801575:	a1 04 40 80 00       	mov    0x804004,%eax
  80157a:	8b 00                	mov    (%eax),%eax
  80157c:	8b 40 48             	mov    0x48(%eax),%eax
  80157f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801583:	89 44 24 04          	mov    %eax,0x4(%esp)
  801587:	c7 04 24 10 2a 80 00 	movl   $0x802a10,(%esp)
  80158e:	e8 79 ec ff ff       	call   80020c <cprintf>
	*dev = 0;
  801593:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801599:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80159e:	83 c4 14             	add    $0x14,%esp
  8015a1:	5b                   	pop    %ebx
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 30             	sub    $0x30,%esp
  8015ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8015af:	8a 45 0c             	mov    0xc(%ebp),%al
  8015b2:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015b5:	89 34 24             	mov    %esi,(%esp)
  8015b8:	e8 b7 fe ff ff       	call   801474 <fd2num>
  8015bd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015c4:	89 04 24             	mov    %eax,(%esp)
  8015c7:	e8 26 ff ff ff       	call   8014f2 <fd_lookup>
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 05                	js     8015d7 <fd_close+0x33>
	    || fd != fd2)
  8015d2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015d5:	74 0d                	je     8015e4 <fd_close+0x40>
		return (must_exist ? r : 0);
  8015d7:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015db:	75 46                	jne    801623 <fd_close+0x7f>
  8015dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e2:	eb 3f                	jmp    801623 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	8b 06                	mov    (%esi),%eax
  8015ed:	89 04 24             	mov    %eax,(%esp)
  8015f0:	e8 53 ff ff ff       	call   801548 <dev_lookup>
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 18                	js     801613 <fd_close+0x6f>
		if (dev->dev_close)
  8015fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fe:	8b 40 10             	mov    0x10(%eax),%eax
  801601:	85 c0                	test   %eax,%eax
  801603:	74 09                	je     80160e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801605:	89 34 24             	mov    %esi,(%esp)
  801608:	ff d0                	call   *%eax
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	eb 05                	jmp    801613 <fd_close+0x6f>
		else
			r = 0;
  80160e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801613:	89 74 24 04          	mov    %esi,0x4(%esp)
  801617:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80161e:	e8 2d f6 ff ff       	call   800c50 <sys_page_unmap>
	return r;
}
  801623:	89 d8                	mov    %ebx,%eax
  801625:	83 c4 30             	add    $0x30,%esp
  801628:	5b                   	pop    %ebx
  801629:	5e                   	pop    %esi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    

0080162c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801635:	89 44 24 04          	mov    %eax,0x4(%esp)
  801639:	8b 45 08             	mov    0x8(%ebp),%eax
  80163c:	89 04 24             	mov    %eax,(%esp)
  80163f:	e8 ae fe ff ff       	call   8014f2 <fd_lookup>
  801644:	85 c0                	test   %eax,%eax
  801646:	78 13                	js     80165b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801648:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80164f:	00 
  801650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801653:	89 04 24             	mov    %eax,(%esp)
  801656:	e8 49 ff ff ff       	call   8015a4 <fd_close>
}
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <close_all>:

void
close_all(void)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	53                   	push   %ebx
  801661:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801664:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801669:	89 1c 24             	mov    %ebx,(%esp)
  80166c:	e8 bb ff ff ff       	call   80162c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801671:	43                   	inc    %ebx
  801672:	83 fb 20             	cmp    $0x20,%ebx
  801675:	75 f2                	jne    801669 <close_all+0xc>
		close(i);
}
  801677:	83 c4 14             	add    $0x14,%esp
  80167a:	5b                   	pop    %ebx
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	57                   	push   %edi
  801681:	56                   	push   %esi
  801682:	53                   	push   %ebx
  801683:	83 ec 4c             	sub    $0x4c,%esp
  801686:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801689:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80168c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801690:	8b 45 08             	mov    0x8(%ebp),%eax
  801693:	89 04 24             	mov    %eax,(%esp)
  801696:	e8 57 fe ff ff       	call   8014f2 <fd_lookup>
  80169b:	89 c3                	mov    %eax,%ebx
  80169d:	85 c0                	test   %eax,%eax
  80169f:	0f 88 e1 00 00 00    	js     801786 <dup+0x109>
		return r;
	close(newfdnum);
  8016a5:	89 3c 24             	mov    %edi,(%esp)
  8016a8:	e8 7f ff ff ff       	call   80162c <close>

	newfd = INDEX2FD(newfdnum);
  8016ad:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016b3:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016b9:	89 04 24             	mov    %eax,(%esp)
  8016bc:	e8 c3 fd ff ff       	call   801484 <fd2data>
  8016c1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016c3:	89 34 24             	mov    %esi,(%esp)
  8016c6:	e8 b9 fd ff ff       	call   801484 <fd2data>
  8016cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ce:	89 d8                	mov    %ebx,%eax
  8016d0:	c1 e8 16             	shr    $0x16,%eax
  8016d3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016da:	a8 01                	test   $0x1,%al
  8016dc:	74 46                	je     801724 <dup+0xa7>
  8016de:	89 d8                	mov    %ebx,%eax
  8016e0:	c1 e8 0c             	shr    $0xc,%eax
  8016e3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ea:	f6 c2 01             	test   $0x1,%dl
  8016ed:	74 35                	je     801724 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8016fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801702:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801706:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170d:	00 
  80170e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801712:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801719:	e8 df f4 ff ff       	call   800bfd <sys_page_map>
  80171e:	89 c3                	mov    %eax,%ebx
  801720:	85 c0                	test   %eax,%eax
  801722:	78 3b                	js     80175f <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801724:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801727:	89 c2                	mov    %eax,%edx
  801729:	c1 ea 0c             	shr    $0xc,%edx
  80172c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801733:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801739:	89 54 24 10          	mov    %edx,0x10(%esp)
  80173d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801741:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801748:	00 
  801749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801754:	e8 a4 f4 ff ff       	call   800bfd <sys_page_map>
  801759:	89 c3                	mov    %eax,%ebx
  80175b:	85 c0                	test   %eax,%eax
  80175d:	79 25                	jns    801784 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80175f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801763:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176a:	e8 e1 f4 ff ff       	call   800c50 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80176f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801772:	89 44 24 04          	mov    %eax,0x4(%esp)
  801776:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80177d:	e8 ce f4 ff ff       	call   800c50 <sys_page_unmap>
	return r;
  801782:	eb 02                	jmp    801786 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801784:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801786:	89 d8                	mov    %ebx,%eax
  801788:	83 c4 4c             	add    $0x4c,%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5f                   	pop    %edi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	53                   	push   %ebx
  801794:	83 ec 24             	sub    $0x24,%esp
  801797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	89 1c 24             	mov    %ebx,(%esp)
  8017a4:	e8 49 fd ff ff       	call   8014f2 <fd_lookup>
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 6f                	js     80181c <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b7:	8b 00                	mov    (%eax),%eax
  8017b9:	89 04 24             	mov    %eax,(%esp)
  8017bc:	e8 87 fd ff ff       	call   801548 <dev_lookup>
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 57                	js     80181c <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c8:	8b 50 08             	mov    0x8(%eax),%edx
  8017cb:	83 e2 03             	and    $0x3,%edx
  8017ce:	83 fa 01             	cmp    $0x1,%edx
  8017d1:	75 25                	jne    8017f8 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8017d8:	8b 00                	mov    (%eax),%eax
  8017da:	8b 40 48             	mov    0x48(%eax),%eax
  8017dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e5:	c7 04 24 51 2a 80 00 	movl   $0x802a51,(%esp)
  8017ec:	e8 1b ea ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  8017f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f6:	eb 24                	jmp    80181c <read+0x8c>
	}
	if (!dev->dev_read)
  8017f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017fb:	8b 52 08             	mov    0x8(%edx),%edx
  8017fe:	85 d2                	test   %edx,%edx
  801800:	74 15                	je     801817 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801802:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801805:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801809:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80180c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801810:	89 04 24             	mov    %eax,(%esp)
  801813:	ff d2                	call   *%edx
  801815:	eb 05                	jmp    80181c <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801817:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80181c:	83 c4 24             	add    $0x24,%esp
  80181f:	5b                   	pop    %ebx
  801820:	5d                   	pop    %ebp
  801821:	c3                   	ret    

00801822 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	57                   	push   %edi
  801826:	56                   	push   %esi
  801827:	53                   	push   %ebx
  801828:	83 ec 1c             	sub    $0x1c,%esp
  80182b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801831:	bb 00 00 00 00       	mov    $0x0,%ebx
  801836:	eb 23                	jmp    80185b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801838:	89 f0                	mov    %esi,%eax
  80183a:	29 d8                	sub    %ebx,%eax
  80183c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801840:	8b 45 0c             	mov    0xc(%ebp),%eax
  801843:	01 d8                	add    %ebx,%eax
  801845:	89 44 24 04          	mov    %eax,0x4(%esp)
  801849:	89 3c 24             	mov    %edi,(%esp)
  80184c:	e8 3f ff ff ff       	call   801790 <read>
		if (m < 0)
  801851:	85 c0                	test   %eax,%eax
  801853:	78 10                	js     801865 <readn+0x43>
			return m;
		if (m == 0)
  801855:	85 c0                	test   %eax,%eax
  801857:	74 0a                	je     801863 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801859:	01 c3                	add    %eax,%ebx
  80185b:	39 f3                	cmp    %esi,%ebx
  80185d:	72 d9                	jb     801838 <readn+0x16>
  80185f:	89 d8                	mov    %ebx,%eax
  801861:	eb 02                	jmp    801865 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801863:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801865:	83 c4 1c             	add    $0x1c,%esp
  801868:	5b                   	pop    %ebx
  801869:	5e                   	pop    %esi
  80186a:	5f                   	pop    %edi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    

0080186d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	53                   	push   %ebx
  801871:	83 ec 24             	sub    $0x24,%esp
  801874:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801877:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187e:	89 1c 24             	mov    %ebx,(%esp)
  801881:	e8 6c fc ff ff       	call   8014f2 <fd_lookup>
  801886:	85 c0                	test   %eax,%eax
  801888:	78 6a                	js     8018f4 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801894:	8b 00                	mov    (%eax),%eax
  801896:	89 04 24             	mov    %eax,(%esp)
  801899:	e8 aa fc ff ff       	call   801548 <dev_lookup>
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 52                	js     8018f4 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a9:	75 25                	jne    8018d0 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8018b0:	8b 00                	mov    (%eax),%eax
  8018b2:	8b 40 48             	mov    0x48(%eax),%eax
  8018b5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bd:	c7 04 24 6d 2a 80 00 	movl   $0x802a6d,(%esp)
  8018c4:	e8 43 e9 ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  8018c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018ce:	eb 24                	jmp    8018f4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d6:	85 d2                	test   %edx,%edx
  8018d8:	74 15                	je     8018ef <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018e4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018e8:	89 04 24             	mov    %eax,(%esp)
  8018eb:	ff d2                	call   *%edx
  8018ed:	eb 05                	jmp    8018f4 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018f4:	83 c4 24             	add    $0x24,%esp
  8018f7:	5b                   	pop    %ebx
  8018f8:	5d                   	pop    %ebp
  8018f9:	c3                   	ret    

008018fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801900:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801903:	89 44 24 04          	mov    %eax,0x4(%esp)
  801907:	8b 45 08             	mov    0x8(%ebp),%eax
  80190a:	89 04 24             	mov    %eax,(%esp)
  80190d:	e8 e0 fb ff ff       	call   8014f2 <fd_lookup>
  801912:	85 c0                	test   %eax,%eax
  801914:	78 0e                	js     801924 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801916:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80191f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	53                   	push   %ebx
  80192a:	83 ec 24             	sub    $0x24,%esp
  80192d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801930:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801933:	89 44 24 04          	mov    %eax,0x4(%esp)
  801937:	89 1c 24             	mov    %ebx,(%esp)
  80193a:	e8 b3 fb ff ff       	call   8014f2 <fd_lookup>
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 63                	js     8019a6 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801943:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194d:	8b 00                	mov    (%eax),%eax
  80194f:	89 04 24             	mov    %eax,(%esp)
  801952:	e8 f1 fb ff ff       	call   801548 <dev_lookup>
  801957:	85 c0                	test   %eax,%eax
  801959:	78 4b                	js     8019a6 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80195b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801962:	75 25                	jne    801989 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801964:	a1 04 40 80 00       	mov    0x804004,%eax
  801969:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80196b:	8b 40 48             	mov    0x48(%eax),%eax
  80196e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801972:	89 44 24 04          	mov    %eax,0x4(%esp)
  801976:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  80197d:	e8 8a e8 ff ff       	call   80020c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801982:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801987:	eb 1d                	jmp    8019a6 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801989:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198c:	8b 52 18             	mov    0x18(%edx),%edx
  80198f:	85 d2                	test   %edx,%edx
  801991:	74 0e                	je     8019a1 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801993:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801996:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80199a:	89 04 24             	mov    %eax,(%esp)
  80199d:	ff d2                	call   *%edx
  80199f:	eb 05                	jmp    8019a6 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019a6:	83 c4 24             	add    $0x24,%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5d                   	pop    %ebp
  8019ab:	c3                   	ret    

008019ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	53                   	push   %ebx
  8019b0:	83 ec 24             	sub    $0x24,%esp
  8019b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c0:	89 04 24             	mov    %eax,(%esp)
  8019c3:	e8 2a fb ff ff       	call   8014f2 <fd_lookup>
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 52                	js     801a1e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d6:	8b 00                	mov    (%eax),%eax
  8019d8:	89 04 24             	mov    %eax,(%esp)
  8019db:	e8 68 fb ff ff       	call   801548 <dev_lookup>
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	78 3a                	js     801a1e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019eb:	74 2c                	je     801a19 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019ed:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019f0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019f7:	00 00 00 
	stat->st_isdir = 0;
  8019fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a01:	00 00 00 
	stat->st_dev = dev;
  801a04:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a11:	89 14 24             	mov    %edx,(%esp)
  801a14:	ff 50 14             	call   *0x14(%eax)
  801a17:	eb 05                	jmp    801a1e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a19:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a1e:	83 c4 24             	add    $0x24,%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
  801a29:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a2c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a33:	00 
  801a34:	8b 45 08             	mov    0x8(%ebp),%eax
  801a37:	89 04 24             	mov    %eax,(%esp)
  801a3a:	e8 88 02 00 00       	call   801cc7 <open>
  801a3f:	89 c3                	mov    %eax,%ebx
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 1b                	js     801a60 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4c:	89 1c 24             	mov    %ebx,(%esp)
  801a4f:	e8 58 ff ff ff       	call   8019ac <fstat>
  801a54:	89 c6                	mov    %eax,%esi
	close(fd);
  801a56:	89 1c 24             	mov    %ebx,(%esp)
  801a59:	e8 ce fb ff ff       	call   80162c <close>
	return r;
  801a5e:	89 f3                	mov    %esi,%ebx
}
  801a60:	89 d8                	mov    %ebx,%eax
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    
  801a69:	00 00                	add    %al,(%eax)
	...

00801a6c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	56                   	push   %esi
  801a70:	53                   	push   %ebx
  801a71:	83 ec 10             	sub    $0x10,%esp
  801a74:	89 c3                	mov    %eax,%ebx
  801a76:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a78:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a7f:	75 11                	jne    801a92 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a88:	e8 a2 f9 ff ff       	call   80142f <ipc_find_env>
  801a8d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a92:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a99:	00 
  801a9a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801aa1:	00 
  801aa2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aa6:	a1 00 40 80 00       	mov    0x804000,%eax
  801aab:	89 04 24             	mov    %eax,(%esp)
  801aae:	e8 16 f9 ff ff       	call   8013c9 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801ab3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aba:	00 
  801abb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801abf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac6:	e8 91 f8 ff ff       	call   80135c <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  801adb:	8b 40 0c             	mov    0xc(%eax),%eax
  801ade:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  801af0:	b8 02 00 00 00       	mov    $0x2,%eax
  801af5:	e8 72 ff ff ff       	call   801a6c <fsipc>
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b02:	8b 45 08             	mov    0x8(%ebp),%eax
  801b05:	8b 40 0c             	mov    0xc(%eax),%eax
  801b08:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b12:	b8 06 00 00 00       	mov    $0x6,%eax
  801b17:	e8 50 ff ff ff       	call   801a6c <fsipc>
}
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	53                   	push   %ebx
  801b22:	83 ec 14             	sub    $0x14,%esp
  801b25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
  801b38:	b8 05 00 00 00       	mov    $0x5,%eax
  801b3d:	e8 2a ff ff ff       	call   801a6c <fsipc>
  801b42:	85 c0                	test   %eax,%eax
  801b44:	78 2b                	js     801b71 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b46:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b4d:	00 
  801b4e:	89 1c 24             	mov    %ebx,(%esp)
  801b51:	e8 61 ec ff ff       	call   8007b7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b56:	a1 80 50 80 00       	mov    0x805080,%eax
  801b5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b61:	a1 84 50 80 00       	mov    0x805084,%eax
  801b66:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b71:	83 c4 14             	add    $0x14,%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	53                   	push   %ebx
  801b7b:	83 ec 14             	sub    $0x14,%esp
  801b7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b81:	8b 45 08             	mov    0x8(%ebp),%eax
  801b84:	8b 40 0c             	mov    0xc(%eax),%eax
  801b87:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801b8c:	89 d8                	mov    %ebx,%eax
  801b8e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801b94:	76 05                	jbe    801b9b <devfile_write+0x24>
  801b96:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801b9b:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801ba0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bab:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801bb2:	e8 e3 ed ff ff       	call   80099a <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbc:	b8 04 00 00 00       	mov    $0x4,%eax
  801bc1:	e8 a6 fe ff ff       	call   801a6c <fsipc>
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 53                	js     801c1d <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801bca:	39 c3                	cmp    %eax,%ebx
  801bcc:	73 24                	jae    801bf2 <devfile_write+0x7b>
  801bce:	c7 44 24 0c 9c 2a 80 	movl   $0x802a9c,0xc(%esp)
  801bd5:	00 
  801bd6:	c7 44 24 08 a3 2a 80 	movl   $0x802aa3,0x8(%esp)
  801bdd:	00 
  801bde:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801be5:	00 
  801be6:	c7 04 24 b8 2a 80 00 	movl   $0x802ab8,(%esp)
  801bed:	e8 92 06 00 00       	call   802284 <_panic>
	assert(r <= PGSIZE);
  801bf2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bf7:	7e 24                	jle    801c1d <devfile_write+0xa6>
  801bf9:	c7 44 24 0c c3 2a 80 	movl   $0x802ac3,0xc(%esp)
  801c00:	00 
  801c01:	c7 44 24 08 a3 2a 80 	movl   $0x802aa3,0x8(%esp)
  801c08:	00 
  801c09:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801c10:	00 
  801c11:	c7 04 24 b8 2a 80 00 	movl   $0x802ab8,(%esp)
  801c18:	e8 67 06 00 00       	call   802284 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801c1d:	83 c4 14             	add    $0x14,%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	56                   	push   %esi
  801c27:	53                   	push   %ebx
  801c28:	83 ec 10             	sub    $0x10,%esp
  801c2b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c31:	8b 40 0c             	mov    0xc(%eax),%eax
  801c34:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c39:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c44:	b8 03 00 00 00       	mov    $0x3,%eax
  801c49:	e8 1e fe ff ff       	call   801a6c <fsipc>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	85 c0                	test   %eax,%eax
  801c52:	78 6a                	js     801cbe <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c54:	39 c6                	cmp    %eax,%esi
  801c56:	73 24                	jae    801c7c <devfile_read+0x59>
  801c58:	c7 44 24 0c 9c 2a 80 	movl   $0x802a9c,0xc(%esp)
  801c5f:	00 
  801c60:	c7 44 24 08 a3 2a 80 	movl   $0x802aa3,0x8(%esp)
  801c67:	00 
  801c68:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801c6f:	00 
  801c70:	c7 04 24 b8 2a 80 00 	movl   $0x802ab8,(%esp)
  801c77:	e8 08 06 00 00       	call   802284 <_panic>
	assert(r <= PGSIZE);
  801c7c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c81:	7e 24                	jle    801ca7 <devfile_read+0x84>
  801c83:	c7 44 24 0c c3 2a 80 	movl   $0x802ac3,0xc(%esp)
  801c8a:	00 
  801c8b:	c7 44 24 08 a3 2a 80 	movl   $0x802aa3,0x8(%esp)
  801c92:	00 
  801c93:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801c9a:	00 
  801c9b:	c7 04 24 b8 2a 80 00 	movl   $0x802ab8,(%esp)
  801ca2:	e8 dd 05 00 00       	call   802284 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ca7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cab:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cb2:	00 
  801cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb6:	89 04 24             	mov    %eax,(%esp)
  801cb9:	e8 72 ec ff ff       	call   800930 <memmove>
	return r;
}
  801cbe:	89 d8                	mov    %ebx,%eax
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	5b                   	pop    %ebx
  801cc4:	5e                   	pop    %esi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	56                   	push   %esi
  801ccb:	53                   	push   %ebx
  801ccc:	83 ec 20             	sub    $0x20,%esp
  801ccf:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cd2:	89 34 24             	mov    %esi,(%esp)
  801cd5:	e8 aa ea ff ff       	call   800784 <strlen>
  801cda:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cdf:	7f 60                	jg     801d41 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ce1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce4:	89 04 24             	mov    %eax,(%esp)
  801ce7:	e8 b3 f7 ff ff       	call   80149f <fd_alloc>
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 54                	js     801d46 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cf6:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cfd:	e8 b5 ea ff ff       	call   8007b7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d05:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d12:	e8 55 fd ff ff       	call   801a6c <fsipc>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	79 15                	jns    801d32 <open+0x6b>
		fd_close(fd, 0);
  801d1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d24:	00 
  801d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d28:	89 04 24             	mov    %eax,(%esp)
  801d2b:	e8 74 f8 ff ff       	call   8015a4 <fd_close>
		return r;
  801d30:	eb 14                	jmp    801d46 <open+0x7f>
	}

	return fd2num(fd);
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	89 04 24             	mov    %eax,(%esp)
  801d38:	e8 37 f7 ff ff       	call   801474 <fd2num>
  801d3d:	89 c3                	mov    %eax,%ebx
  801d3f:	eb 05                	jmp    801d46 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d41:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d46:	89 d8                	mov    %ebx,%eax
  801d48:	83 c4 20             	add    $0x20,%esp
  801d4b:	5b                   	pop    %ebx
  801d4c:	5e                   	pop    %esi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d55:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5a:	b8 08 00 00 00       	mov    $0x8,%eax
  801d5f:	e8 08 fd ff ff       	call   801a6c <fsipc>
}
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    
	...

00801d68 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	56                   	push   %esi
  801d6c:	53                   	push   %ebx
  801d6d:	83 ec 10             	sub    $0x10,%esp
  801d70:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d73:	8b 45 08             	mov    0x8(%ebp),%eax
  801d76:	89 04 24             	mov    %eax,(%esp)
  801d79:	e8 06 f7 ff ff       	call   801484 <fd2data>
  801d7e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d80:	c7 44 24 04 cf 2a 80 	movl   $0x802acf,0x4(%esp)
  801d87:	00 
  801d88:	89 34 24             	mov    %esi,(%esp)
  801d8b:	e8 27 ea ff ff       	call   8007b7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d90:	8b 43 04             	mov    0x4(%ebx),%eax
  801d93:	2b 03                	sub    (%ebx),%eax
  801d95:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801d9b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801da2:	00 00 00 
	stat->st_dev = &devpipe;
  801da5:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801dac:	30 80 00 
	return 0;
}
  801daf:	b8 00 00 00 00       	mov    $0x0,%eax
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 14             	sub    $0x14,%esp
  801dc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd0:	e8 7b ee ff ff       	call   800c50 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dd5:	89 1c 24             	mov    %ebx,(%esp)
  801dd8:	e8 a7 f6 ff ff       	call   801484 <fd2data>
  801ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de8:	e8 63 ee ff ff       	call   800c50 <sys_page_unmap>
}
  801ded:	83 c4 14             	add    $0x14,%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5d                   	pop    %ebp
  801df2:	c3                   	ret    

00801df3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	57                   	push   %edi
  801df7:	56                   	push   %esi
  801df8:	53                   	push   %ebx
  801df9:	83 ec 2c             	sub    $0x2c,%esp
  801dfc:	89 c7                	mov    %eax,%edi
  801dfe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e01:	a1 04 40 80 00       	mov    0x804004,%eax
  801e06:	8b 00                	mov    (%eax),%eax
  801e08:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e0b:	89 3c 24             	mov    %edi,(%esp)
  801e0e:	e8 81 05 00 00       	call   802394 <pageref>
  801e13:	89 c6                	mov    %eax,%esi
  801e15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e18:	89 04 24             	mov    %eax,(%esp)
  801e1b:	e8 74 05 00 00       	call   802394 <pageref>
  801e20:	39 c6                	cmp    %eax,%esi
  801e22:	0f 94 c0             	sete   %al
  801e25:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e28:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e2e:	8b 12                	mov    (%edx),%edx
  801e30:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e33:	39 cb                	cmp    %ecx,%ebx
  801e35:	75 08                	jne    801e3f <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e37:	83 c4 2c             	add    $0x2c,%esp
  801e3a:	5b                   	pop    %ebx
  801e3b:	5e                   	pop    %esi
  801e3c:	5f                   	pop    %edi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e3f:	83 f8 01             	cmp    $0x1,%eax
  801e42:	75 bd                	jne    801e01 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e44:	8b 42 58             	mov    0x58(%edx),%eax
  801e47:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801e4e:	00 
  801e4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e57:	c7 04 24 d6 2a 80 00 	movl   $0x802ad6,(%esp)
  801e5e:	e8 a9 e3 ff ff       	call   80020c <cprintf>
  801e63:	eb 9c                	jmp    801e01 <_pipeisclosed+0xe>

00801e65 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	57                   	push   %edi
  801e69:	56                   	push   %esi
  801e6a:	53                   	push   %ebx
  801e6b:	83 ec 1c             	sub    $0x1c,%esp
  801e6e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e71:	89 34 24             	mov    %esi,(%esp)
  801e74:	e8 0b f6 ff ff       	call   801484 <fd2data>
  801e79:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e7b:	bf 00 00 00 00       	mov    $0x0,%edi
  801e80:	eb 3c                	jmp    801ebe <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e82:	89 da                	mov    %ebx,%edx
  801e84:	89 f0                	mov    %esi,%eax
  801e86:	e8 68 ff ff ff       	call   801df3 <_pipeisclosed>
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	75 38                	jne    801ec7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e8f:	e8 f6 ec ff ff       	call   800b8a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e94:	8b 43 04             	mov    0x4(%ebx),%eax
  801e97:	8b 13                	mov    (%ebx),%edx
  801e99:	83 c2 20             	add    $0x20,%edx
  801e9c:	39 d0                	cmp    %edx,%eax
  801e9e:	73 e2                	jae    801e82 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ea0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ea3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801ea6:	89 c2                	mov    %eax,%edx
  801ea8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801eae:	79 05                	jns    801eb5 <devpipe_write+0x50>
  801eb0:	4a                   	dec    %edx
  801eb1:	83 ca e0             	or     $0xffffffe0,%edx
  801eb4:	42                   	inc    %edx
  801eb5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801eb9:	40                   	inc    %eax
  801eba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ebd:	47                   	inc    %edi
  801ebe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ec1:	75 d1                	jne    801e94 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ec3:	89 f8                	mov    %edi,%eax
  801ec5:	eb 05                	jmp    801ecc <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ec7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ecc:	83 c4 1c             	add    $0x1c,%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	57                   	push   %edi
  801ed8:	56                   	push   %esi
  801ed9:	53                   	push   %ebx
  801eda:	83 ec 1c             	sub    $0x1c,%esp
  801edd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ee0:	89 3c 24             	mov    %edi,(%esp)
  801ee3:	e8 9c f5 ff ff       	call   801484 <fd2data>
  801ee8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eea:	be 00 00 00 00       	mov    $0x0,%esi
  801eef:	eb 3a                	jmp    801f2b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ef1:	85 f6                	test   %esi,%esi
  801ef3:	74 04                	je     801ef9 <devpipe_read+0x25>
				return i;
  801ef5:	89 f0                	mov    %esi,%eax
  801ef7:	eb 40                	jmp    801f39 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ef9:	89 da                	mov    %ebx,%edx
  801efb:	89 f8                	mov    %edi,%eax
  801efd:	e8 f1 fe ff ff       	call   801df3 <_pipeisclosed>
  801f02:	85 c0                	test   %eax,%eax
  801f04:	75 2e                	jne    801f34 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f06:	e8 7f ec ff ff       	call   800b8a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f0b:	8b 03                	mov    (%ebx),%eax
  801f0d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f10:	74 df                	je     801ef1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f12:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f17:	79 05                	jns    801f1e <devpipe_read+0x4a>
  801f19:	48                   	dec    %eax
  801f1a:	83 c8 e0             	or     $0xffffffe0,%eax
  801f1d:	40                   	inc    %eax
  801f1e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f22:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f25:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f28:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f2a:	46                   	inc    %esi
  801f2b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f2e:	75 db                	jne    801f0b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f30:	89 f0                	mov    %esi,%eax
  801f32:	eb 05                	jmp    801f39 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f34:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f39:	83 c4 1c             	add    $0x1c,%esp
  801f3c:	5b                   	pop    %ebx
  801f3d:	5e                   	pop    %esi
  801f3e:	5f                   	pop    %edi
  801f3f:	5d                   	pop    %ebp
  801f40:	c3                   	ret    

00801f41 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	57                   	push   %edi
  801f45:	56                   	push   %esi
  801f46:	53                   	push   %ebx
  801f47:	83 ec 3c             	sub    $0x3c,%esp
  801f4a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f4d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f50:	89 04 24             	mov    %eax,(%esp)
  801f53:	e8 47 f5 ff ff       	call   80149f <fd_alloc>
  801f58:	89 c3                	mov    %eax,%ebx
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	0f 88 45 01 00 00    	js     8020a7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f62:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f69:	00 
  801f6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f78:	e8 2c ec ff ff       	call   800ba9 <sys_page_alloc>
  801f7d:	89 c3                	mov    %eax,%ebx
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	0f 88 20 01 00 00    	js     8020a7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f87:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801f8a:	89 04 24             	mov    %eax,(%esp)
  801f8d:	e8 0d f5 ff ff       	call   80149f <fd_alloc>
  801f92:	89 c3                	mov    %eax,%ebx
  801f94:	85 c0                	test   %eax,%eax
  801f96:	0f 88 f8 00 00 00    	js     802094 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fa3:	00 
  801fa4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb2:	e8 f2 eb ff ff       	call   800ba9 <sys_page_alloc>
  801fb7:	89 c3                	mov    %eax,%ebx
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	0f 88 d3 00 00 00    	js     802094 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fc4:	89 04 24             	mov    %eax,(%esp)
  801fc7:	e8 b8 f4 ff ff       	call   801484 <fd2data>
  801fcc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fce:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fd5:	00 
  801fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe1:	e8 c3 eb ff ff       	call   800ba9 <sys_page_alloc>
  801fe6:	89 c3                	mov    %eax,%ebx
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	0f 88 91 00 00 00    	js     802081 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ff3:	89 04 24             	mov    %eax,(%esp)
  801ff6:	e8 89 f4 ff ff       	call   801484 <fd2data>
  801ffb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802002:	00 
  802003:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802007:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80200e:	00 
  80200f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802013:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80201a:	e8 de eb ff ff       	call   800bfd <sys_page_map>
  80201f:	89 c3                	mov    %eax,%ebx
  802021:	85 c0                	test   %eax,%eax
  802023:	78 4c                	js     802071 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802025:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80202b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80202e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802030:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802033:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80203a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802040:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802043:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802045:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802048:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80204f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802052:	89 04 24             	mov    %eax,(%esp)
  802055:	e8 1a f4 ff ff       	call   801474 <fd2num>
  80205a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80205c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80205f:	89 04 24             	mov    %eax,(%esp)
  802062:	e8 0d f4 ff ff       	call   801474 <fd2num>
  802067:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80206a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80206f:	eb 36                	jmp    8020a7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802071:	89 74 24 04          	mov    %esi,0x4(%esp)
  802075:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207c:	e8 cf eb ff ff       	call   800c50 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802081:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802084:	89 44 24 04          	mov    %eax,0x4(%esp)
  802088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80208f:	e8 bc eb ff ff       	call   800c50 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802094:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a2:	e8 a9 eb ff ff       	call   800c50 <sys_page_unmap>
    err:
	return r;
}
  8020a7:	89 d8                	mov    %ebx,%eax
  8020a9:	83 c4 3c             	add    $0x3c,%esp
  8020ac:	5b                   	pop    %ebx
  8020ad:	5e                   	pop    %esi
  8020ae:	5f                   	pop    %edi
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    

008020b1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020be:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c1:	89 04 24             	mov    %eax,(%esp)
  8020c4:	e8 29 f4 ff ff       	call   8014f2 <fd_lookup>
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	78 15                	js     8020e2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d0:	89 04 24             	mov    %eax,(%esp)
  8020d3:	e8 ac f3 ff ff       	call   801484 <fd2data>
	return _pipeisclosed(fd, p);
  8020d8:	89 c2                	mov    %eax,%edx
  8020da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dd:	e8 11 fd ff ff       	call   801df3 <_pipeisclosed>
}
  8020e2:	c9                   	leave  
  8020e3:	c3                   	ret    

008020e4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8020f4:	c7 44 24 04 ee 2a 80 	movl   $0x802aee,0x4(%esp)
  8020fb:	00 
  8020fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ff:	89 04 24             	mov    %eax,(%esp)
  802102:	e8 b0 e6 ff ff       	call   8007b7 <strcpy>
	return 0;
}
  802107:	b8 00 00 00 00       	mov    $0x0,%eax
  80210c:	c9                   	leave  
  80210d:	c3                   	ret    

0080210e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80211a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80211f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802125:	eb 30                	jmp    802157 <devcons_write+0x49>
		m = n - tot;
  802127:	8b 75 10             	mov    0x10(%ebp),%esi
  80212a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80212c:	83 fe 7f             	cmp    $0x7f,%esi
  80212f:	76 05                	jbe    802136 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802131:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802136:	89 74 24 08          	mov    %esi,0x8(%esp)
  80213a:	03 45 0c             	add    0xc(%ebp),%eax
  80213d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802141:	89 3c 24             	mov    %edi,(%esp)
  802144:	e8 e7 e7 ff ff       	call   800930 <memmove>
		sys_cputs(buf, m);
  802149:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214d:	89 3c 24             	mov    %edi,(%esp)
  802150:	e8 87 e9 ff ff       	call   800adc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802155:	01 f3                	add    %esi,%ebx
  802157:	89 d8                	mov    %ebx,%eax
  802159:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80215c:	72 c9                	jb     802127 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80215e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    

00802169 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80216f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802173:	75 07                	jne    80217c <devcons_read+0x13>
  802175:	eb 25                	jmp    80219c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802177:	e8 0e ea ff ff       	call   800b8a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80217c:	e8 79 e9 ff ff       	call   800afa <sys_cgetc>
  802181:	85 c0                	test   %eax,%eax
  802183:	74 f2                	je     802177 <devcons_read+0xe>
  802185:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802187:	85 c0                	test   %eax,%eax
  802189:	78 1d                	js     8021a8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80218b:	83 f8 04             	cmp    $0x4,%eax
  80218e:	74 13                	je     8021a3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802190:	8b 45 0c             	mov    0xc(%ebp),%eax
  802193:	88 10                	mov    %dl,(%eax)
	return 1;
  802195:	b8 01 00 00 00       	mov    $0x1,%eax
  80219a:	eb 0c                	jmp    8021a8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80219c:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a1:	eb 05                	jmp    8021a8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021a3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021a8:	c9                   	leave  
  8021a9:	c3                   	ret    

008021aa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
  8021ad:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021bd:	00 
  8021be:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021c1:	89 04 24             	mov    %eax,(%esp)
  8021c4:	e8 13 e9 ff ff       	call   800adc <sys_cputs>
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <getchar>:

int
getchar(void)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021d8:	00 
  8021d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e7:	e8 a4 f5 ff ff       	call   801790 <read>
	if (r < 0)
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	78 0f                	js     8021ff <getchar+0x34>
		return r;
	if (r < 1)
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	7e 06                	jle    8021fa <getchar+0x2f>
		return -E_EOF;
	return c;
  8021f4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8021f8:	eb 05                	jmp    8021ff <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8021fa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8021ff:	c9                   	leave  
  802200:	c3                   	ret    

00802201 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802207:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80220a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80220e:	8b 45 08             	mov    0x8(%ebp),%eax
  802211:	89 04 24             	mov    %eax,(%esp)
  802214:	e8 d9 f2 ff ff       	call   8014f2 <fd_lookup>
  802219:	85 c0                	test   %eax,%eax
  80221b:	78 11                	js     80222e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80221d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802220:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802226:	39 10                	cmp    %edx,(%eax)
  802228:	0f 94 c0             	sete   %al
  80222b:	0f b6 c0             	movzbl %al,%eax
}
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    

00802230 <opencons>:

int
opencons(void)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802239:	89 04 24             	mov    %eax,(%esp)
  80223c:	e8 5e f2 ff ff       	call   80149f <fd_alloc>
  802241:	85 c0                	test   %eax,%eax
  802243:	78 3c                	js     802281 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802245:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80224c:	00 
  80224d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802250:	89 44 24 04          	mov    %eax,0x4(%esp)
  802254:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80225b:	e8 49 e9 ff ff       	call   800ba9 <sys_page_alloc>
  802260:	85 c0                	test   %eax,%eax
  802262:	78 1d                	js     802281 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802264:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80226a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80226f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802272:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802279:	89 04 24             	mov    %eax,(%esp)
  80227c:	e8 f3 f1 ff ff       	call   801474 <fd2num>
}
  802281:	c9                   	leave  
  802282:	c3                   	ret    
	...

00802284 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	56                   	push   %esi
  802288:	53                   	push   %ebx
  802289:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80228c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80228f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802295:	e8 d1 e8 ff ff       	call   800b6b <sys_getenvid>
  80229a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80229d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8022a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8022a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b0:	c7 04 24 fc 2a 80 00 	movl   $0x802afc,(%esp)
  8022b7:	e8 50 df ff ff       	call   80020c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8022c3:	89 04 24             	mov    %eax,(%esp)
  8022c6:	e8 e0 de ff ff       	call   8001ab <vcprintf>
	cprintf("\n");
  8022cb:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  8022d2:	e8 35 df ff ff       	call   80020c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022d7:	cc                   	int3   
  8022d8:	eb fd                	jmp    8022d7 <_panic+0x53>
	...

008022dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022dc:	55                   	push   %ebp
  8022dd:	89 e5                	mov    %esp,%ebp
  8022df:	53                   	push   %ebx
  8022e0:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022e3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8022ea:	75 6f                	jne    80235b <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8022ec:	e8 7a e8 ff ff       	call   800b6b <sys_getenvid>
  8022f1:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8022f3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022fa:	00 
  8022fb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802302:	ee 
  802303:	89 04 24             	mov    %eax,(%esp)
  802306:	e8 9e e8 ff ff       	call   800ba9 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  80230b:	85 c0                	test   %eax,%eax
  80230d:	79 1c                	jns    80232b <set_pgfault_handler+0x4f>
  80230f:	c7 44 24 08 20 2b 80 	movl   $0x802b20,0x8(%esp)
  802316:	00 
  802317:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80231e:	00 
  80231f:	c7 04 24 7c 2b 80 00 	movl   $0x802b7c,(%esp)
  802326:	e8 59 ff ff ff       	call   802284 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80232b:	c7 44 24 04 6c 23 80 	movl   $0x80236c,0x4(%esp)
  802332:	00 
  802333:	89 1c 24             	mov    %ebx,(%esp)
  802336:	e8 0e ea ff ff       	call   800d49 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  80233b:	85 c0                	test   %eax,%eax
  80233d:	79 1c                	jns    80235b <set_pgfault_handler+0x7f>
  80233f:	c7 44 24 08 48 2b 80 	movl   $0x802b48,0x8(%esp)
  802346:	00 
  802347:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80234e:	00 
  80234f:	c7 04 24 7c 2b 80 00 	movl   $0x802b7c,(%esp)
  802356:	e8 29 ff ff ff       	call   802284 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80235b:	8b 45 08             	mov    0x8(%ebp),%eax
  80235e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802363:	83 c4 14             	add    $0x14,%esp
  802366:	5b                   	pop    %ebx
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    
  802369:	00 00                	add    %al,(%eax)
	...

0080236c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80236c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80236d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802372:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802374:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  802377:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  80237b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  802380:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  802384:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  802386:	83 c4 08             	add    $0x8,%esp
	popal
  802389:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  80238a:	83 c4 04             	add    $0x4,%esp
	popfl
  80238d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  80238e:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802391:	c3                   	ret    
	...

00802394 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
  802397:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  80239a:	89 c2                	mov    %eax,%edx
  80239c:	c1 ea 16             	shr    $0x16,%edx
  80239f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023a6:	f6 c2 01             	test   $0x1,%dl
  8023a9:	74 1e                	je     8023c9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023ab:	c1 e8 0c             	shr    $0xc,%eax
  8023ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023b5:	a8 01                	test   $0x1,%al
  8023b7:	74 17                	je     8023d0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023b9:	c1 e8 0c             	shr    $0xc,%eax
  8023bc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023c3:	ef 
  8023c4:	0f b7 c0             	movzwl %ax,%eax
  8023c7:	eb 0c                	jmp    8023d5 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ce:	eb 05                	jmp    8023d5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023d0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023d5:	5d                   	pop    %ebp
  8023d6:	c3                   	ret    
	...

008023d8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8023d8:	55                   	push   %ebp
  8023d9:	57                   	push   %edi
  8023da:	56                   	push   %esi
  8023db:	83 ec 10             	sub    $0x10,%esp
  8023de:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023e2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8023ee:	89 cd                	mov    %ecx,%ebp
  8023f0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023f4:	85 c0                	test   %eax,%eax
  8023f6:	75 2c                	jne    802424 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8023f8:	39 f9                	cmp    %edi,%ecx
  8023fa:	77 68                	ja     802464 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023fc:	85 c9                	test   %ecx,%ecx
  8023fe:	75 0b                	jne    80240b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802400:	b8 01 00 00 00       	mov    $0x1,%eax
  802405:	31 d2                	xor    %edx,%edx
  802407:	f7 f1                	div    %ecx
  802409:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	89 f8                	mov    %edi,%eax
  80240f:	f7 f1                	div    %ecx
  802411:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802413:	89 f0                	mov    %esi,%eax
  802415:	f7 f1                	div    %ecx
  802417:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802419:	89 f0                	mov    %esi,%eax
  80241b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80241d:	83 c4 10             	add    $0x10,%esp
  802420:	5e                   	pop    %esi
  802421:	5f                   	pop    %edi
  802422:	5d                   	pop    %ebp
  802423:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802424:	39 f8                	cmp    %edi,%eax
  802426:	77 2c                	ja     802454 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802428:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80242b:	83 f6 1f             	xor    $0x1f,%esi
  80242e:	75 4c                	jne    80247c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802430:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802432:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802437:	72 0a                	jb     802443 <__udivdi3+0x6b>
  802439:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80243d:	0f 87 ad 00 00 00    	ja     8024f0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802443:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802448:	89 f0                	mov    %esi,%eax
  80244a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80244c:	83 c4 10             	add    $0x10,%esp
  80244f:	5e                   	pop    %esi
  802450:	5f                   	pop    %edi
  802451:	5d                   	pop    %ebp
  802452:	c3                   	ret    
  802453:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802454:	31 ff                	xor    %edi,%edi
  802456:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802458:	89 f0                	mov    %esi,%eax
  80245a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80245c:	83 c4 10             	add    $0x10,%esp
  80245f:	5e                   	pop    %esi
  802460:	5f                   	pop    %edi
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    
  802463:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802464:	89 fa                	mov    %edi,%edx
  802466:	89 f0                	mov    %esi,%eax
  802468:	f7 f1                	div    %ecx
  80246a:	89 c6                	mov    %eax,%esi
  80246c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80246e:	89 f0                	mov    %esi,%eax
  802470:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	5e                   	pop    %esi
  802476:	5f                   	pop    %edi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    
  802479:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80247c:	89 f1                	mov    %esi,%ecx
  80247e:	d3 e0                	shl    %cl,%eax
  802480:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802484:	b8 20 00 00 00       	mov    $0x20,%eax
  802489:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80248b:	89 ea                	mov    %ebp,%edx
  80248d:	88 c1                	mov    %al,%cl
  80248f:	d3 ea                	shr    %cl,%edx
  802491:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802495:	09 ca                	or     %ecx,%edx
  802497:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80249b:	89 f1                	mov    %esi,%ecx
  80249d:	d3 e5                	shl    %cl,%ebp
  80249f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8024a3:	89 fd                	mov    %edi,%ebp
  8024a5:	88 c1                	mov    %al,%cl
  8024a7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8024a9:	89 fa                	mov    %edi,%edx
  8024ab:	89 f1                	mov    %esi,%ecx
  8024ad:	d3 e2                	shl    %cl,%edx
  8024af:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024b3:	88 c1                	mov    %al,%cl
  8024b5:	d3 ef                	shr    %cl,%edi
  8024b7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024b9:	89 f8                	mov    %edi,%eax
  8024bb:	89 ea                	mov    %ebp,%edx
  8024bd:	f7 74 24 08          	divl   0x8(%esp)
  8024c1:	89 d1                	mov    %edx,%ecx
  8024c3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8024c5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024c9:	39 d1                	cmp    %edx,%ecx
  8024cb:	72 17                	jb     8024e4 <__udivdi3+0x10c>
  8024cd:	74 09                	je     8024d8 <__udivdi3+0x100>
  8024cf:	89 fe                	mov    %edi,%esi
  8024d1:	31 ff                	xor    %edi,%edi
  8024d3:	e9 41 ff ff ff       	jmp    802419 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8024d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024dc:	89 f1                	mov    %esi,%ecx
  8024de:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024e0:	39 c2                	cmp    %eax,%edx
  8024e2:	73 eb                	jae    8024cf <__udivdi3+0xf7>
		{
		  q0--;
  8024e4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024e7:	31 ff                	xor    %edi,%edi
  8024e9:	e9 2b ff ff ff       	jmp    802419 <__udivdi3+0x41>
  8024ee:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024f0:	31 f6                	xor    %esi,%esi
  8024f2:	e9 22 ff ff ff       	jmp    802419 <__udivdi3+0x41>
	...

008024f8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024f8:	55                   	push   %ebp
  8024f9:	57                   	push   %edi
  8024fa:	56                   	push   %esi
  8024fb:	83 ec 20             	sub    $0x20,%esp
  8024fe:	8b 44 24 30          	mov    0x30(%esp),%eax
  802502:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802506:	89 44 24 14          	mov    %eax,0x14(%esp)
  80250a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80250e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802512:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802516:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802518:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80251a:	85 ed                	test   %ebp,%ebp
  80251c:	75 16                	jne    802534 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80251e:	39 f1                	cmp    %esi,%ecx
  802520:	0f 86 a6 00 00 00    	jbe    8025cc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802526:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802528:	89 d0                	mov    %edx,%eax
  80252a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80252c:	83 c4 20             	add    $0x20,%esp
  80252f:	5e                   	pop    %esi
  802530:	5f                   	pop    %edi
  802531:	5d                   	pop    %ebp
  802532:	c3                   	ret    
  802533:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802534:	39 f5                	cmp    %esi,%ebp
  802536:	0f 87 ac 00 00 00    	ja     8025e8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80253c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80253f:	83 f0 1f             	xor    $0x1f,%eax
  802542:	89 44 24 10          	mov    %eax,0x10(%esp)
  802546:	0f 84 a8 00 00 00    	je     8025f4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80254c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802550:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802552:	bf 20 00 00 00       	mov    $0x20,%edi
  802557:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80255b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80255f:	89 f9                	mov    %edi,%ecx
  802561:	d3 e8                	shr    %cl,%eax
  802563:	09 e8                	or     %ebp,%eax
  802565:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802569:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80256d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802571:	d3 e0                	shl    %cl,%eax
  802573:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802577:	89 f2                	mov    %esi,%edx
  802579:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80257b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80257f:	d3 e0                	shl    %cl,%eax
  802581:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802585:	8b 44 24 14          	mov    0x14(%esp),%eax
  802589:	89 f9                	mov    %edi,%ecx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80258f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802591:	89 f2                	mov    %esi,%edx
  802593:	f7 74 24 18          	divl   0x18(%esp)
  802597:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802599:	f7 64 24 0c          	mull   0xc(%esp)
  80259d:	89 c5                	mov    %eax,%ebp
  80259f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025a1:	39 d6                	cmp    %edx,%esi
  8025a3:	72 67                	jb     80260c <__umoddi3+0x114>
  8025a5:	74 75                	je     80261c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8025a7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025ab:	29 e8                	sub    %ebp,%eax
  8025ad:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8025af:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025b3:	d3 e8                	shr    %cl,%eax
  8025b5:	89 f2                	mov    %esi,%edx
  8025b7:	89 f9                	mov    %edi,%ecx
  8025b9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8025bb:	09 d0                	or     %edx,%eax
  8025bd:	89 f2                	mov    %esi,%edx
  8025bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025c3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025c5:	83 c4 20             	add    $0x20,%esp
  8025c8:	5e                   	pop    %esi
  8025c9:	5f                   	pop    %edi
  8025ca:	5d                   	pop    %ebp
  8025cb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025cc:	85 c9                	test   %ecx,%ecx
  8025ce:	75 0b                	jne    8025db <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d5:	31 d2                	xor    %edx,%edx
  8025d7:	f7 f1                	div    %ecx
  8025d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025db:	89 f0                	mov    %esi,%eax
  8025dd:	31 d2                	xor    %edx,%edx
  8025df:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025e1:	89 f8                	mov    %edi,%eax
  8025e3:	e9 3e ff ff ff       	jmp    802526 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025e8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025ea:	83 c4 20             	add    $0x20,%esp
  8025ed:	5e                   	pop    %esi
  8025ee:	5f                   	pop    %edi
  8025ef:	5d                   	pop    %ebp
  8025f0:	c3                   	ret    
  8025f1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025f4:	39 f5                	cmp    %esi,%ebp
  8025f6:	72 04                	jb     8025fc <__umoddi3+0x104>
  8025f8:	39 f9                	cmp    %edi,%ecx
  8025fa:	77 06                	ja     802602 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025fc:	89 f2                	mov    %esi,%edx
  8025fe:	29 cf                	sub    %ecx,%edi
  802600:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802602:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802604:	83 c4 20             	add    $0x20,%esp
  802607:	5e                   	pop    %esi
  802608:	5f                   	pop    %edi
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    
  80260b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80260c:	89 d1                	mov    %edx,%ecx
  80260e:	89 c5                	mov    %eax,%ebp
  802610:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802614:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802618:	eb 8d                	jmp    8025a7 <__umoddi3+0xaf>
  80261a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80261c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802620:	72 ea                	jb     80260c <__umoddi3+0x114>
  802622:	89 f1                	mov    %esi,%ecx
  802624:	eb 81                	jmp    8025a7 <__umoddi3+0xaf>
