
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 f6 0a 00 00       	call   800b37 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	81 38 7c 00 c0 ee    	cmpl   $0xeec0007c,(%eax)
  80004e:	75 34                	jne    800084 <umain+0x50>
		while (1) {
			ipc_recv(&who, 0, 0);
  800050:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800053:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80005a:	00 
  80005b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800062:	00 
  800063:	89 34 24             	mov    %esi,(%esp)
  800066:	e8 75 0d 00 00       	call   800de0 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800072:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800076:	c7 04 24 00 20 80 00 	movl   $0x802000,(%esp)
  80007d:	e8 56 01 00 00       	call   8001d8 <cprintf>
  800082:	eb cf                	jmp    800053 <umain+0x1f>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800084:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800089:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	c7 04 24 11 20 80 00 	movl   $0x802011,(%esp)
  800098:	e8 3b 01 00 00       	call   8001d8 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009d:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a9:	00 
  8000aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b1:	00 
  8000b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b9:	00 
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 8b 0d 00 00       	call   800e4d <ipc_send>
  8000c2:	eb d9                	jmp    80009d <umain+0x69>

008000c4 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 20             	sub    $0x20,%esp
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8000d2:	e8 60 0a 00 00       	call   800b37 <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e3:	c1 e0 07             	shl    $0x7,%eax
  8000e6:	29 d0                	sub    %edx,%eax
  8000e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000f3:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f8:	85 f6                	test   %esi,%esi
  8000fa:	7e 07                	jle    800103 <libmain+0x3f>
		binaryname = argv[0];
  8000fc:	8b 03                	mov    (%ebx),%eax
  8000fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800107:	89 34 24             	mov    %esi,(%esp)
  80010a:	e8 25 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80010f:	e8 08 00 00 00       	call   80011c <exit>
}
  800114:	83 c4 20             	add    $0x20,%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    
	...

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800122:	e8 ba 0f 00 00       	call   8010e1 <close_all>
	sys_env_destroy(0);
  800127:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012e:	e8 b2 09 00 00       	call   800ae5 <sys_env_destroy>
}
  800133:	c9                   	leave  
  800134:	c3                   	ret    
  800135:	00 00                	add    %al,(%eax)
	...

00800138 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	53                   	push   %ebx
  80013c:	83 ec 14             	sub    $0x14,%esp
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800142:	8b 03                	mov    (%ebx),%eax
  800144:	8b 55 08             	mov    0x8(%ebp),%edx
  800147:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80014b:	40                   	inc    %eax
  80014c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800153:	75 19                	jne    80016e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800155:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80015c:	00 
  80015d:	8d 43 08             	lea    0x8(%ebx),%eax
  800160:	89 04 24             	mov    %eax,(%esp)
  800163:	e8 40 09 00 00       	call   800aa8 <sys_cputs>
		b->idx = 0;
  800168:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016e:	ff 43 04             	incl   0x4(%ebx)
}
  800171:	83 c4 14             	add    $0x14,%esp
  800174:	5b                   	pop    %ebx
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800180:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800187:	00 00 00 
	b.cnt = 0;
  80018a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800191:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019b:	8b 45 08             	mov    0x8(%ebp),%eax
  80019e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ac:	c7 04 24 38 01 80 00 	movl   $0x800138,(%esp)
  8001b3:	e8 82 01 00 00       	call   80033a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c8:	89 04 24             	mov    %eax,(%esp)
  8001cb:	e8 d8 08 00 00       	call   800aa8 <sys_cputs>

	return b.cnt;
}
  8001d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 87 ff ff ff       	call   800177 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    
	...

008001f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	57                   	push   %edi
  8001f8:	56                   	push   %esi
  8001f9:	53                   	push   %ebx
  8001fa:	83 ec 3c             	sub    $0x3c,%esp
  8001fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800200:	89 d7                	mov    %edx,%edi
  800202:	8b 45 08             	mov    0x8(%ebp),%eax
  800205:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800211:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800214:	85 c0                	test   %eax,%eax
  800216:	75 08                	jne    800220 <printnum+0x2c>
  800218:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021e:	77 57                	ja     800277 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800220:	89 74 24 10          	mov    %esi,0x10(%esp)
  800224:	4b                   	dec    %ebx
  800225:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800229:	8b 45 10             	mov    0x10(%ebp),%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800234:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800238:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023f:	00 
  800240:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	e8 52 1b 00 00       	call   801da4 <__udivdi3>
  800252:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800256:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800261:	89 fa                	mov    %edi,%edx
  800263:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800266:	e8 89 ff ff ff       	call   8001f4 <printnum>
  80026b:	eb 0f                	jmp    80027c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800271:	89 34 24             	mov    %esi,(%esp)
  800274:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800277:	4b                   	dec    %ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f f1                	jg     80026d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800280:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800284:	8b 45 10             	mov    0x10(%ebp),%eax
  800287:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800292:	00 
  800293:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800296:	89 04 24             	mov    %eax,(%esp)
  800299:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80029c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a0:	e8 1f 1c 00 00       	call   801ec4 <__umoddi3>
  8002a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a9:	0f be 80 32 20 80 00 	movsbl 0x802032(%eax),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002b6:	83 c4 3c             	add    $0x3c,%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800301:	8b 10                	mov    (%eax),%edx
  800303:	3b 50 04             	cmp    0x4(%eax),%edx
  800306:	73 08                	jae    800310 <sprintputch+0x18>
		*b->buf++ = ch;
  800308:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030b:	88 0a                	mov    %cl,(%edx)
  80030d:	42                   	inc    %edx
  80030e:	89 10                	mov    %edx,(%eax)
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800318:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031f:	8b 45 10             	mov    0x10(%ebp),%eax
  800322:	89 44 24 08          	mov    %eax,0x8(%esp)
  800326:	8b 45 0c             	mov    0xc(%ebp),%eax
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	e8 02 00 00 00       	call   80033a <vprintfmt>
	va_end(ap);
}
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 4c             	sub    $0x4c,%esp
  800343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800346:	8b 75 10             	mov    0x10(%ebp),%esi
  800349:	eb 12                	jmp    80035d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034b:	85 c0                	test   %eax,%eax
  80034d:	0f 84 6b 03 00 00    	je     8006be <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800353:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800357:	89 04 24             	mov    %eax,(%esp)
  80035a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035d:	0f b6 06             	movzbl (%esi),%eax
  800360:	46                   	inc    %esi
  800361:	83 f8 25             	cmp    $0x25,%eax
  800364:	75 e5                	jne    80034b <vprintfmt+0x11>
  800366:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80036a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800371:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800376:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80037d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800382:	eb 26                	jmp    8003aa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800387:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80038b:	eb 1d                	jmp    8003aa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800390:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800394:	eb 14                	jmp    8003aa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800399:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003a0:	eb 08                	jmp    8003aa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003a2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003a5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	0f b6 06             	movzbl (%esi),%eax
  8003ad:	8d 56 01             	lea    0x1(%esi),%edx
  8003b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003b3:	8a 16                	mov    (%esi),%dl
  8003b5:	83 ea 23             	sub    $0x23,%edx
  8003b8:	80 fa 55             	cmp    $0x55,%dl
  8003bb:	0f 87 e1 02 00 00    	ja     8006a2 <vprintfmt+0x368>
  8003c1:	0f b6 d2             	movzbl %dl,%edx
  8003c4:	ff 24 95 80 21 80 00 	jmp    *0x802180(,%edx,4)
  8003cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ce:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003d6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003da:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003dd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003e0:	83 fa 09             	cmp    $0x9,%edx
  8003e3:	77 2a                	ja     80040f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e6:	eb eb                	jmp    8003d3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f6:	eb 17                	jmp    80040f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fc:	78 98                	js     800396 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800401:	eb a7                	jmp    8003aa <vprintfmt+0x70>
  800403:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800406:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80040d:	eb 9b                	jmp    8003aa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80040f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800413:	79 95                	jns    8003aa <vprintfmt+0x70>
  800415:	eb 8b                	jmp    8003a2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800417:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041b:	eb 8d                	jmp    8003aa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 50 04             	lea    0x4(%eax),%edx
  800423:	89 55 14             	mov    %edx,0x14(%ebp)
  800426:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800435:	e9 23 ff ff ff       	jmp    80035d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 50 04             	lea    0x4(%eax),%edx
  800440:	89 55 14             	mov    %edx,0x14(%ebp)
  800443:	8b 00                	mov    (%eax),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	79 02                	jns    80044b <vprintfmt+0x111>
  800449:	f7 d8                	neg    %eax
  80044b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044d:	83 f8 0f             	cmp    $0xf,%eax
  800450:	7f 0b                	jg     80045d <vprintfmt+0x123>
  800452:	8b 04 85 e0 22 80 00 	mov    0x8022e0(,%eax,4),%eax
  800459:	85 c0                	test   %eax,%eax
  80045b:	75 23                	jne    800480 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80045d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800461:	c7 44 24 08 4a 20 80 	movl   $0x80204a,0x8(%esp)
  800468:	00 
  800469:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80046d:	8b 45 08             	mov    0x8(%ebp),%eax
  800470:	89 04 24             	mov    %eax,(%esp)
  800473:	e8 9a fe ff ff       	call   800312 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047b:	e9 dd fe ff ff       	jmp    80035d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800480:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800484:	c7 44 24 08 2d 24 80 	movl   $0x80242d,0x8(%esp)
  80048b:	00 
  80048c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800490:	8b 55 08             	mov    0x8(%ebp),%edx
  800493:	89 14 24             	mov    %edx,(%esp)
  800496:	e8 77 fe ff ff       	call   800312 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049e:	e9 ba fe ff ff       	jmp    80035d <vprintfmt+0x23>
  8004a3:	89 f9                	mov    %edi,%ecx
  8004a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 50 04             	lea    0x4(%eax),%edx
  8004b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b4:	8b 30                	mov    (%eax),%esi
  8004b6:	85 f6                	test   %esi,%esi
  8004b8:	75 05                	jne    8004bf <vprintfmt+0x185>
				p = "(null)";
  8004ba:	be 43 20 80 00       	mov    $0x802043,%esi
			if (width > 0 && padc != '-')
  8004bf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c3:	0f 8e 84 00 00 00    	jle    80054d <vprintfmt+0x213>
  8004c9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004cd:	74 7e                	je     80054d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d3:	89 34 24             	mov    %esi,(%esp)
  8004d6:	e8 8b 02 00 00       	call   800766 <strnlen>
  8004db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004de:	29 c2                	sub    %eax,%edx
  8004e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004e3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004e7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004ea:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004ed:	89 de                	mov    %ebx,%esi
  8004ef:	89 d3                	mov    %edx,%ebx
  8004f1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	eb 0b                	jmp    800500 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f9:	89 3c 24             	mov    %edi,(%esp)
  8004fc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	4b                   	dec    %ebx
  800500:	85 db                	test   %ebx,%ebx
  800502:	7f f1                	jg     8004f5 <vprintfmt+0x1bb>
  800504:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800507:	89 f3                	mov    %esi,%ebx
  800509:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80050c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	79 05                	jns    800518 <vprintfmt+0x1de>
  800513:	b8 00 00 00 00       	mov    $0x0,%eax
  800518:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051b:	29 c2                	sub    %eax,%edx
  80051d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800520:	eb 2b                	jmp    80054d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800522:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800526:	74 18                	je     800540 <vprintfmt+0x206>
  800528:	8d 50 e0             	lea    -0x20(%eax),%edx
  80052b:	83 fa 5e             	cmp    $0x5e,%edx
  80052e:	76 10                	jbe    800540 <vprintfmt+0x206>
					putch('?', putdat);
  800530:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800534:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80053b:	ff 55 08             	call   *0x8(%ebp)
  80053e:	eb 0a                	jmp    80054a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800540:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054a:	ff 4d e4             	decl   -0x1c(%ebp)
  80054d:	0f be 06             	movsbl (%esi),%eax
  800550:	46                   	inc    %esi
  800551:	85 c0                	test   %eax,%eax
  800553:	74 21                	je     800576 <vprintfmt+0x23c>
  800555:	85 ff                	test   %edi,%edi
  800557:	78 c9                	js     800522 <vprintfmt+0x1e8>
  800559:	4f                   	dec    %edi
  80055a:	79 c6                	jns    800522 <vprintfmt+0x1e8>
  80055c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80055f:	89 de                	mov    %ebx,%esi
  800561:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800564:	eb 18                	jmp    80057e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800571:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800573:	4b                   	dec    %ebx
  800574:	eb 08                	jmp    80057e <vprintfmt+0x244>
  800576:	8b 7d 08             	mov    0x8(%ebp),%edi
  800579:	89 de                	mov    %ebx,%esi
  80057b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80057e:	85 db                	test   %ebx,%ebx
  800580:	7f e4                	jg     800566 <vprintfmt+0x22c>
  800582:	89 7d 08             	mov    %edi,0x8(%ebp)
  800585:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80058a:	e9 ce fd ff ff       	jmp    80035d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058f:	83 f9 01             	cmp    $0x1,%ecx
  800592:	7e 10                	jle    8005a4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 08             	lea    0x8(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 30                	mov    (%eax),%esi
  80059f:	8b 78 04             	mov    0x4(%eax),%edi
  8005a2:	eb 26                	jmp    8005ca <vprintfmt+0x290>
	else if (lflag)
  8005a4:	85 c9                	test   %ecx,%ecx
  8005a6:	74 12                	je     8005ba <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 30                	mov    (%eax),%esi
  8005b3:	89 f7                	mov    %esi,%edi
  8005b5:	c1 ff 1f             	sar    $0x1f,%edi
  8005b8:	eb 10                	jmp    8005ca <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 50 04             	lea    0x4(%eax),%edx
  8005c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c3:	8b 30                	mov    (%eax),%esi
  8005c5:	89 f7                	mov    %esi,%edi
  8005c7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ca:	85 ff                	test   %edi,%edi
  8005cc:	78 0a                	js     8005d8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d3:	e9 8c 00 00 00       	jmp    800664 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005e3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e6:	f7 de                	neg    %esi
  8005e8:	83 d7 00             	adc    $0x0,%edi
  8005eb:	f7 df                	neg    %edi
			}
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f2:	eb 70                	jmp    800664 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f4:	89 ca                	mov    %ecx,%edx
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 c0 fc ff ff       	call   8002be <getuint>
  8005fe:	89 c6                	mov    %eax,%esi
  800600:	89 d7                	mov    %edx,%edi
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800607:	eb 5b                	jmp    800664 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800609:	89 ca                	mov    %ecx,%edx
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 ab fc ff ff       	call   8002be <getuint>
  800613:	89 c6                	mov    %eax,%esi
  800615:	89 d7                	mov    %edx,%edi
			base = 8;
  800617:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80061c:	eb 46                	jmp    800664 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80061e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800622:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800629:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800630:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800637:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800643:	8b 30                	mov    (%eax),%esi
  800645:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064f:	eb 13                	jmp    800664 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800651:	89 ca                	mov    %ecx,%edx
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 63 fc ff ff       	call   8002be <getuint>
  80065b:	89 c6                	mov    %eax,%esi
  80065d:	89 d7                	mov    %edx,%edi
			base = 16;
  80065f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800664:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800668:	89 54 24 10          	mov    %edx,0x10(%esp)
  80066c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800673:	89 44 24 08          	mov    %eax,0x8(%esp)
  800677:	89 34 24             	mov    %esi,(%esp)
  80067a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067e:	89 da                	mov    %ebx,%edx
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	e8 6c fb ff ff       	call   8001f4 <printnum>
			break;
  800688:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068b:	e9 cd fc ff ff       	jmp    80035d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80069d:	e9 bb fc ff ff       	jmp    80035d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ad:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b0:	eb 01                	jmp    8006b3 <vprintfmt+0x379>
  8006b2:	4e                   	dec    %esi
  8006b3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b7:	75 f9                	jne    8006b2 <vprintfmt+0x378>
  8006b9:	e9 9f fc ff ff       	jmp    80035d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006be:	83 c4 4c             	add    $0x4c,%esp
  8006c1:	5b                   	pop    %ebx
  8006c2:	5e                   	pop    %esi
  8006c3:	5f                   	pop    %edi
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 28             	sub    $0x28,%esp
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	74 30                	je     800717 <vsnprintf+0x51>
  8006e7:	85 d2                	test   %edx,%edx
  8006e9:	7e 33                	jle    80071e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800700:	c7 04 24 f8 02 80 00 	movl   $0x8002f8,(%esp)
  800707:	e8 2e fc ff ff       	call   80033a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800715:	eb 0c                	jmp    800723 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071c:	eb 05                	jmp    800723 <vsnprintf+0x5d>
  80071e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    

00800725 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800732:	8b 45 10             	mov    0x10(%ebp),%eax
  800735:	89 44 24 08          	mov    %eax,0x8(%esp)
  800739:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	89 04 24             	mov    %eax,(%esp)
  800746:	e8 7b ff ff ff       	call   8006c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    
  80074d:	00 00                	add    %al,(%eax)
	...

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	eb 01                	jmp    80075e <strlen+0xe>
		n++;
  80075d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800762:	75 f9                	jne    80075d <strlen+0xd>
		n++;
	return n;
}
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80076c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
  800774:	eb 01                	jmp    800777 <strnlen+0x11>
		n++;
  800776:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	39 d0                	cmp    %edx,%eax
  800779:	74 06                	je     800781 <strnlen+0x1b>
  80077b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077f:	75 f5                	jne    800776 <strnlen+0x10>
		n++;
	return n;
}
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078d:	ba 00 00 00 00       	mov    $0x0,%edx
  800792:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800795:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800798:	42                   	inc    %edx
  800799:	84 c9                	test   %cl,%cl
  80079b:	75 f5                	jne    800792 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	89 1c 24             	mov    %ebx,(%esp)
  8007ad:	e8 9e ff ff ff       	call   800750 <strlen>
	strcpy(dst + len, src);
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b9:	01 d8                	add    %ebx,%eax
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	e8 c0 ff ff ff       	call   800783 <strcpy>
	return dst;
}
  8007c3:	89 d8                	mov    %ebx,%eax
  8007c5:	83 c4 08             	add    $0x8,%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007de:	eb 0c                	jmp    8007ec <strncpy+0x21>
		*dst++ = *src;
  8007e0:	8a 1a                	mov    (%edx),%bl
  8007e2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007eb:	41                   	inc    %ecx
  8007ec:	39 f1                	cmp    %esi,%ecx
  8007ee:	75 f0                	jne    8007e0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	56                   	push   %esi
  8007f8:	53                   	push   %ebx
  8007f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ff:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800802:	85 d2                	test   %edx,%edx
  800804:	75 0a                	jne    800810 <strlcpy+0x1c>
  800806:	89 f0                	mov    %esi,%eax
  800808:	eb 1a                	jmp    800824 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080a:	88 18                	mov    %bl,(%eax)
  80080c:	40                   	inc    %eax
  80080d:	41                   	inc    %ecx
  80080e:	eb 02                	jmp    800812 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800810:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800812:	4a                   	dec    %edx
  800813:	74 0a                	je     80081f <strlcpy+0x2b>
  800815:	8a 19                	mov    (%ecx),%bl
  800817:	84 db                	test   %bl,%bl
  800819:	75 ef                	jne    80080a <strlcpy+0x16>
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	eb 02                	jmp    800821 <strlcpy+0x2d>
  80081f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800821:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800824:	29 f0                	sub    %esi,%eax
}
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800833:	eb 02                	jmp    800837 <strcmp+0xd>
		p++, q++;
  800835:	41                   	inc    %ecx
  800836:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800837:	8a 01                	mov    (%ecx),%al
  800839:	84 c0                	test   %al,%al
  80083b:	74 04                	je     800841 <strcmp+0x17>
  80083d:	3a 02                	cmp    (%edx),%al
  80083f:	74 f4                	je     800835 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800841:	0f b6 c0             	movzbl %al,%eax
  800844:	0f b6 12             	movzbl (%edx),%edx
  800847:	29 d0                	sub    %edx,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800855:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800858:	eb 03                	jmp    80085d <strncmp+0x12>
		n--, p++, q++;
  80085a:	4a                   	dec    %edx
  80085b:	40                   	inc    %eax
  80085c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085d:	85 d2                	test   %edx,%edx
  80085f:	74 14                	je     800875 <strncmp+0x2a>
  800861:	8a 18                	mov    (%eax),%bl
  800863:	84 db                	test   %bl,%bl
  800865:	74 04                	je     80086b <strncmp+0x20>
  800867:	3a 19                	cmp    (%ecx),%bl
  800869:	74 ef                	je     80085a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 00             	movzbl (%eax),%eax
  80086e:	0f b6 11             	movzbl (%ecx),%edx
  800871:	29 d0                	sub    %edx,%eax
  800873:	eb 05                	jmp    80087a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087a:	5b                   	pop    %ebx
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800886:	eb 05                	jmp    80088d <strchr+0x10>
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	74 0c                	je     800898 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088c:	40                   	inc    %eax
  80088d:	8a 10                	mov    (%eax),%dl
  80088f:	84 d2                	test   %dl,%dl
  800891:	75 f5                	jne    800888 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a3:	eb 05                	jmp    8008aa <strfind+0x10>
		if (*s == c)
  8008a5:	38 ca                	cmp    %cl,%dl
  8008a7:	74 07                	je     8008b0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a9:	40                   	inc    %eax
  8008aa:	8a 10                	mov    (%eax),%dl
  8008ac:	84 d2                	test   %dl,%dl
  8008ae:	75 f5                	jne    8008a5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	57                   	push   %edi
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c1:	85 c9                	test   %ecx,%ecx
  8008c3:	74 30                	je     8008f5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cb:	75 25                	jne    8008f2 <memset+0x40>
  8008cd:	f6 c1 03             	test   $0x3,%cl
  8008d0:	75 20                	jne    8008f2 <memset+0x40>
		c &= 0xFF;
  8008d2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d5:	89 d3                	mov    %edx,%ebx
  8008d7:	c1 e3 08             	shl    $0x8,%ebx
  8008da:	89 d6                	mov    %edx,%esi
  8008dc:	c1 e6 18             	shl    $0x18,%esi
  8008df:	89 d0                	mov    %edx,%eax
  8008e1:	c1 e0 10             	shl    $0x10,%eax
  8008e4:	09 f0                	or     %esi,%eax
  8008e6:	09 d0                	or     %edx,%eax
  8008e8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ea:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008ed:	fc                   	cld    
  8008ee:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f0:	eb 03                	jmp    8008f5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f2:	fc                   	cld    
  8008f3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f5:	89 f8                	mov    %edi,%eax
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5f                   	pop    %edi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	57                   	push   %edi
  800900:	56                   	push   %esi
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8b 75 0c             	mov    0xc(%ebp),%esi
  800907:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090a:	39 c6                	cmp    %eax,%esi
  80090c:	73 34                	jae    800942 <memmove+0x46>
  80090e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800911:	39 d0                	cmp    %edx,%eax
  800913:	73 2d                	jae    800942 <memmove+0x46>
		s += n;
		d += n;
  800915:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800918:	f6 c2 03             	test   $0x3,%dl
  80091b:	75 1b                	jne    800938 <memmove+0x3c>
  80091d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800923:	75 13                	jne    800938 <memmove+0x3c>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 0e                	jne    800938 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80092a:	83 ef 04             	sub    $0x4,%edi
  80092d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800930:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800933:	fd                   	std    
  800934:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800936:	eb 07                	jmp    80093f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800938:	4f                   	dec    %edi
  800939:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093c:	fd                   	std    
  80093d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093f:	fc                   	cld    
  800940:	eb 20                	jmp    800962 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800948:	75 13                	jne    80095d <memmove+0x61>
  80094a:	a8 03                	test   $0x3,%al
  80094c:	75 0f                	jne    80095d <memmove+0x61>
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 0a                	jne    80095d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800953:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800956:	89 c7                	mov    %eax,%edi
  800958:	fc                   	cld    
  800959:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095b:	eb 05                	jmp    800962 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80095d:	89 c7                	mov    %eax,%edi
  80095f:	fc                   	cld    
  800960:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800962:	5e                   	pop    %esi
  800963:	5f                   	pop    %edi
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80096c:	8b 45 10             	mov    0x10(%ebp),%eax
  80096f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	89 04 24             	mov    %eax,(%esp)
  800980:	e8 77 ff ff ff       	call   8008fc <memmove>
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800996:	ba 00 00 00 00       	mov    $0x0,%edx
  80099b:	eb 16                	jmp    8009b3 <memcmp+0x2c>
		if (*s1 != *s2)
  80099d:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009a0:	42                   	inc    %edx
  8009a1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009a5:	38 c8                	cmp    %cl,%al
  8009a7:	74 0a                	je     8009b3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009a9:	0f b6 c0             	movzbl %al,%eax
  8009ac:	0f b6 c9             	movzbl %cl,%ecx
  8009af:	29 c8                	sub    %ecx,%eax
  8009b1:	eb 09                	jmp    8009bc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	39 da                	cmp    %ebx,%edx
  8009b5:	75 e6                	jne    80099d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5f                   	pop    %edi
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ca:	89 c2                	mov    %eax,%edx
  8009cc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009cf:	eb 05                	jmp    8009d6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d1:	38 08                	cmp    %cl,(%eax)
  8009d3:	74 05                	je     8009da <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d5:	40                   	inc    %eax
  8009d6:	39 d0                	cmp    %edx,%eax
  8009d8:	72 f7                	jb     8009d1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e8:	eb 01                	jmp    8009eb <strtol+0xf>
		s++;
  8009ea:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009eb:	8a 02                	mov    (%edx),%al
  8009ed:	3c 20                	cmp    $0x20,%al
  8009ef:	74 f9                	je     8009ea <strtol+0xe>
  8009f1:	3c 09                	cmp    $0x9,%al
  8009f3:	74 f5                	je     8009ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f5:	3c 2b                	cmp    $0x2b,%al
  8009f7:	75 08                	jne    800a01 <strtol+0x25>
		s++;
  8009f9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ff:	eb 13                	jmp    800a14 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a01:	3c 2d                	cmp    $0x2d,%al
  800a03:	75 0a                	jne    800a0f <strtol+0x33>
		s++, neg = 1;
  800a05:	8d 52 01             	lea    0x1(%edx),%edx
  800a08:	bf 01 00 00 00       	mov    $0x1,%edi
  800a0d:	eb 05                	jmp    800a14 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a14:	85 db                	test   %ebx,%ebx
  800a16:	74 05                	je     800a1d <strtol+0x41>
  800a18:	83 fb 10             	cmp    $0x10,%ebx
  800a1b:	75 28                	jne    800a45 <strtol+0x69>
  800a1d:	8a 02                	mov    (%edx),%al
  800a1f:	3c 30                	cmp    $0x30,%al
  800a21:	75 10                	jne    800a33 <strtol+0x57>
  800a23:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a27:	75 0a                	jne    800a33 <strtol+0x57>
		s += 2, base = 16;
  800a29:	83 c2 02             	add    $0x2,%edx
  800a2c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a31:	eb 12                	jmp    800a45 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a33:	85 db                	test   %ebx,%ebx
  800a35:	75 0e                	jne    800a45 <strtol+0x69>
  800a37:	3c 30                	cmp    $0x30,%al
  800a39:	75 05                	jne    800a40 <strtol+0x64>
		s++, base = 8;
  800a3b:	42                   	inc    %edx
  800a3c:	b3 08                	mov    $0x8,%bl
  800a3e:	eb 05                	jmp    800a45 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a40:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4c:	8a 0a                	mov    (%edx),%cl
  800a4e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a51:	80 fb 09             	cmp    $0x9,%bl
  800a54:	77 08                	ja     800a5e <strtol+0x82>
			dig = *s - '0';
  800a56:	0f be c9             	movsbl %cl,%ecx
  800a59:	83 e9 30             	sub    $0x30,%ecx
  800a5c:	eb 1e                	jmp    800a7c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a5e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a61:	80 fb 19             	cmp    $0x19,%bl
  800a64:	77 08                	ja     800a6e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a66:	0f be c9             	movsbl %cl,%ecx
  800a69:	83 e9 57             	sub    $0x57,%ecx
  800a6c:	eb 0e                	jmp    800a7c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a6e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a71:	80 fb 19             	cmp    $0x19,%bl
  800a74:	77 12                	ja     800a88 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a76:	0f be c9             	movsbl %cl,%ecx
  800a79:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a7c:	39 f1                	cmp    %esi,%ecx
  800a7e:	7d 0c                	jge    800a8c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a80:	42                   	inc    %edx
  800a81:	0f af c6             	imul   %esi,%eax
  800a84:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a86:	eb c4                	jmp    800a4c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a88:	89 c1                	mov    %eax,%ecx
  800a8a:	eb 02                	jmp    800a8e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a8c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a92:	74 05                	je     800a99 <strtol+0xbd>
		*endptr = (char *) s;
  800a94:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a97:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a99:	85 ff                	test   %edi,%edi
  800a9b:	74 04                	je     800aa1 <strtol+0xc5>
  800a9d:	89 c8                	mov    %ecx,%eax
  800a9f:	f7 d8                	neg    %eax
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    
	...

00800aa8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	89 c6                	mov    %eax,%esi
  800abf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad6:	89 d1                	mov    %edx,%ecx
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	89 d7                	mov    %edx,%edi
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af3:	b8 03 00 00 00       	mov    $0x3,%eax
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	89 cb                	mov    %ecx,%ebx
  800afd:	89 cf                	mov    %ecx,%edi
  800aff:	89 ce                	mov    %ecx,%esi
  800b01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	7e 28                	jle    800b2f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b12:	00 
  800b13:	c7 44 24 08 3f 23 80 	movl   $0x80233f,0x8(%esp)
  800b1a:	00 
  800b1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b22:	00 
  800b23:	c7 04 24 5c 23 80 00 	movl   $0x80235c,(%esp)
  800b2a:	e8 d9 11 00 00       	call   801d08 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2f:	83 c4 2c             	add    $0x2c,%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b42:	b8 02 00 00 00       	mov    $0x2,%eax
  800b47:	89 d1                	mov    %edx,%ecx
  800b49:	89 d3                	mov    %edx,%ebx
  800b4b:	89 d7                	mov    %edx,%edi
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_yield>:

void
sys_yield(void)
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
  800b61:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b7e:	be 00 00 00 00       	mov    $0x0,%esi
  800b83:	b8 04 00 00 00       	mov    $0x4,%eax
  800b88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	89 f7                	mov    %esi,%edi
  800b93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b95:	85 c0                	test   %eax,%eax
  800b97:	7e 28                	jle    800bc1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ba4:	00 
  800ba5:	c7 44 24 08 3f 23 80 	movl   $0x80233f,0x8(%esp)
  800bac:	00 
  800bad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb4:	00 
  800bb5:	c7 04 24 5c 23 80 00 	movl   $0x80235c,(%esp)
  800bbc:	e8 47 11 00 00       	call   801d08 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc1:	83 c4 2c             	add    $0x2c,%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be8:	85 c0                	test   %eax,%eax
  800bea:	7e 28                	jle    800c14 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bf7:	00 
  800bf8:	c7 44 24 08 3f 23 80 	movl   $0x80233f,0x8(%esp)
  800bff:	00 
  800c00:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c07:	00 
  800c08:	c7 04 24 5c 23 80 00 	movl   $0x80235c,(%esp)
  800c0f:	e8 f4 10 00 00       	call   801d08 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c14:	83 c4 2c             	add    $0x2c,%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 df                	mov    %ebx,%edi
  800c37:	89 de                	mov    %ebx,%esi
  800c39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 28                	jle    800c67 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c43:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 08 3f 23 80 	movl   $0x80233f,0x8(%esp)
  800c52:	00 
  800c53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5a:	00 
  800c5b:	c7 04 24 5c 23 80 00 	movl   $0x80235c,(%esp)
  800c62:	e8 a1 10 00 00       	call   801d08 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c67:	83 c4 2c             	add    $0x2c,%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	89 df                	mov    %ebx,%edi
  800c8a:	89 de                	mov    %ebx,%esi
  800c8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7e 28                	jle    800cba <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c96:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c9d:	00 
  800c9e:	c7 44 24 08 3f 23 80 	movl   $0x80233f,0x8(%esp)
  800ca5:	00 
  800ca6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cad:	00 
  800cae:	c7 04 24 5c 23 80 00 	movl   $0x80235c,(%esp)
  800cb5:	e8 4e 10 00 00       	call   801d08 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cba:	83 c4 2c             	add    $0x2c,%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 28                	jle    800d0d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 08 3f 23 80 	movl   $0x80233f,0x8(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d00:	00 
  800d01:	c7 04 24 5c 23 80 00 	movl   $0x80235c,(%esp)
  800d08:	e8 fb 0f 00 00       	call   801d08 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d0d:	83 c4 2c             	add    $0x2c,%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	57                   	push   %edi
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d23:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	89 df                	mov    %ebx,%edi
  800d30:	89 de                	mov    %ebx,%esi
  800d32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 28                	jle    800d60 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d43:	00 
  800d44:	c7 44 24 08 3f 23 80 	movl   $0x80233f,0x8(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d53:	00 
  800d54:	c7 04 24 5c 23 80 00 	movl   $0x80235c,(%esp)
  800d5b:	e8 a8 0f 00 00       	call   801d08 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d60:	83 c4 2c             	add    $0x2c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	be 00 00 00 00       	mov    $0x0,%esi
  800d73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d99:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 cb                	mov    %ecx,%ebx
  800da3:	89 cf                	mov    %ecx,%edi
  800da5:	89 ce                	mov    %ecx,%esi
  800da7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 28                	jle    800dd5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800db8:	00 
  800db9:	c7 44 24 08 3f 23 80 	movl   $0x80233f,0x8(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc8:	00 
  800dc9:	c7 04 24 5c 23 80 00 	movl   $0x80235c,(%esp)
  800dd0:	e8 33 0f 00 00       	call   801d08 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd5:	83 c4 2c             	add    $0x2c,%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    
  800ddd:	00 00                	add    %al,(%eax)
	...

00800de0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 10             	sub    $0x10,%esp
  800de8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800deb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dee:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  800df1:	85 c0                	test   %eax,%eax
  800df3:	75 05                	jne    800dfa <ipc_recv+0x1a>
  800df5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  800dfa:	89 04 24             	mov    %eax,(%esp)
  800dfd:	e8 89 ff ff ff       	call   800d8b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  800e02:	85 c0                	test   %eax,%eax
  800e04:	79 16                	jns    800e1c <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  800e06:	85 db                	test   %ebx,%ebx
  800e08:	74 06                	je     800e10 <ipc_recv+0x30>
  800e0a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  800e10:	85 f6                	test   %esi,%esi
  800e12:	74 32                	je     800e46 <ipc_recv+0x66>
  800e14:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800e1a:	eb 2a                	jmp    800e46 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  800e1c:	85 db                	test   %ebx,%ebx
  800e1e:	74 0c                	je     800e2c <ipc_recv+0x4c>
  800e20:	a1 04 40 80 00       	mov    0x804004,%eax
  800e25:	8b 00                	mov    (%eax),%eax
  800e27:	8b 40 74             	mov    0x74(%eax),%eax
  800e2a:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  800e2c:	85 f6                	test   %esi,%esi
  800e2e:	74 0c                	je     800e3c <ipc_recv+0x5c>
  800e30:	a1 04 40 80 00       	mov    0x804004,%eax
  800e35:	8b 00                	mov    (%eax),%eax
  800e37:	8b 40 78             	mov    0x78(%eax),%eax
  800e3a:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  800e3c:	a1 04 40 80 00       	mov    0x804004,%eax
  800e41:	8b 00                	mov    (%eax),%eax
  800e43:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  800e46:	83 c4 10             	add    $0x10,%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 1c             	sub    $0x1c,%esp
  800e56:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  800e5f:	85 db                	test   %ebx,%ebx
  800e61:	75 05                	jne    800e68 <ipc_send+0x1b>
  800e63:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  800e68:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e70:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
  800e77:	89 04 24             	mov    %eax,(%esp)
  800e7a:	e8 e9 fe ff ff       	call   800d68 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  800e7f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e82:	75 07                	jne    800e8b <ipc_send+0x3e>
  800e84:	e8 cd fc ff ff       	call   800b56 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  800e89:	eb dd                	jmp    800e68 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	79 1c                	jns    800eab <ipc_send+0x5e>
  800e8f:	c7 44 24 08 6a 23 80 	movl   $0x80236a,0x8(%esp)
  800e96:	00 
  800e97:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800e9e:	00 
  800e9f:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800ea6:	e8 5d 0e 00 00       	call   801d08 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  800eab:	83 c4 1c             	add    $0x1c,%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	53                   	push   %ebx
  800eb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800ebf:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800ec6:	89 c2                	mov    %eax,%edx
  800ec8:	c1 e2 07             	shl    $0x7,%edx
  800ecb:	29 ca                	sub    %ecx,%edx
  800ecd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ed3:	8b 52 50             	mov    0x50(%edx),%edx
  800ed6:	39 da                	cmp    %ebx,%edx
  800ed8:	75 0f                	jne    800ee9 <ipc_find_env+0x36>
			return envs[i].env_id;
  800eda:	c1 e0 07             	shl    $0x7,%eax
  800edd:	29 c8                	sub    %ecx,%eax
  800edf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800ee4:	8b 40 40             	mov    0x40(%eax),%eax
  800ee7:	eb 0c                	jmp    800ef5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ee9:	40                   	inc    %eax
  800eea:	3d 00 04 00 00       	cmp    $0x400,%eax
  800eef:	75 ce                	jne    800ebf <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800ef1:	66 b8 00 00          	mov    $0x0,%ax
}
  800ef5:	5b                   	pop    %ebx
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
  800efe:	05 00 00 00 30       	add    $0x30000000,%eax
  800f03:	c1 e8 0c             	shr    $0xc,%eax
}
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	89 04 24             	mov    %eax,(%esp)
  800f14:	e8 df ff ff ff       	call   800ef8 <fd2num>
  800f19:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f1e:	c1 e0 0c             	shl    $0xc,%eax
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	53                   	push   %ebx
  800f27:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f2a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f2f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f31:	89 c2                	mov    %eax,%edx
  800f33:	c1 ea 16             	shr    $0x16,%edx
  800f36:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f3d:	f6 c2 01             	test   $0x1,%dl
  800f40:	74 11                	je     800f53 <fd_alloc+0x30>
  800f42:	89 c2                	mov    %eax,%edx
  800f44:	c1 ea 0c             	shr    $0xc,%edx
  800f47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4e:	f6 c2 01             	test   $0x1,%dl
  800f51:	75 09                	jne    800f5c <fd_alloc+0x39>
			*fd_store = fd;
  800f53:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f55:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5a:	eb 17                	jmp    800f73 <fd_alloc+0x50>
  800f5c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f61:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f66:	75 c7                	jne    800f2f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f68:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f6e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f73:	5b                   	pop    %ebx
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f7c:	83 f8 1f             	cmp    $0x1f,%eax
  800f7f:	77 36                	ja     800fb7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f81:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f86:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f89:	89 c2                	mov    %eax,%edx
  800f8b:	c1 ea 16             	shr    $0x16,%edx
  800f8e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f95:	f6 c2 01             	test   $0x1,%dl
  800f98:	74 24                	je     800fbe <fd_lookup+0x48>
  800f9a:	89 c2                	mov    %eax,%edx
  800f9c:	c1 ea 0c             	shr    $0xc,%edx
  800f9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fa6:	f6 c2 01             	test   $0x1,%dl
  800fa9:	74 1a                	je     800fc5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fae:	89 02                	mov    %eax,(%edx)
	return 0;
  800fb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb5:	eb 13                	jmp    800fca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fbc:	eb 0c                	jmp    800fca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc3:	eb 05                	jmp    800fca <fd_lookup+0x54>
  800fc5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 14             	sub    $0x14,%esp
  800fd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fde:	eb 0e                	jmp    800fee <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fe0:	39 08                	cmp    %ecx,(%eax)
  800fe2:	75 09                	jne    800fed <dev_lookup+0x21>
			*dev = devtab[i];
  800fe4:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fe6:	b8 00 00 00 00       	mov    $0x0,%eax
  800feb:	eb 35                	jmp    801022 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fed:	42                   	inc    %edx
  800fee:	8b 04 95 04 24 80 00 	mov    0x802404(,%edx,4),%eax
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	75 e7                	jne    800fe0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ff9:	a1 04 40 80 00       	mov    0x804004,%eax
  800ffe:	8b 00                	mov    (%eax),%eax
  801000:	8b 40 48             	mov    0x48(%eax),%eax
  801003:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801007:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100b:	c7 04 24 88 23 80 00 	movl   $0x802388,(%esp)
  801012:	e8 c1 f1 ff ff       	call   8001d8 <cprintf>
	*dev = 0;
  801017:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80101d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801022:	83 c4 14             	add    $0x14,%esp
  801025:	5b                   	pop    %ebx
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 30             	sub    $0x30,%esp
  801030:	8b 75 08             	mov    0x8(%ebp),%esi
  801033:	8a 45 0c             	mov    0xc(%ebp),%al
  801036:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801039:	89 34 24             	mov    %esi,(%esp)
  80103c:	e8 b7 fe ff ff       	call   800ef8 <fd2num>
  801041:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801044:	89 54 24 04          	mov    %edx,0x4(%esp)
  801048:	89 04 24             	mov    %eax,(%esp)
  80104b:	e8 26 ff ff ff       	call   800f76 <fd_lookup>
  801050:	89 c3                	mov    %eax,%ebx
  801052:	85 c0                	test   %eax,%eax
  801054:	78 05                	js     80105b <fd_close+0x33>
	    || fd != fd2)
  801056:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801059:	74 0d                	je     801068 <fd_close+0x40>
		return (must_exist ? r : 0);
  80105b:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80105f:	75 46                	jne    8010a7 <fd_close+0x7f>
  801061:	bb 00 00 00 00       	mov    $0x0,%ebx
  801066:	eb 3f                	jmp    8010a7 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801068:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106f:	8b 06                	mov    (%esi),%eax
  801071:	89 04 24             	mov    %eax,(%esp)
  801074:	e8 53 ff ff ff       	call   800fcc <dev_lookup>
  801079:	89 c3                	mov    %eax,%ebx
  80107b:	85 c0                	test   %eax,%eax
  80107d:	78 18                	js     801097 <fd_close+0x6f>
		if (dev->dev_close)
  80107f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801082:	8b 40 10             	mov    0x10(%eax),%eax
  801085:	85 c0                	test   %eax,%eax
  801087:	74 09                	je     801092 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801089:	89 34 24             	mov    %esi,(%esp)
  80108c:	ff d0                	call   *%eax
  80108e:	89 c3                	mov    %eax,%ebx
  801090:	eb 05                	jmp    801097 <fd_close+0x6f>
		else
			r = 0;
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801097:	89 74 24 04          	mov    %esi,0x4(%esp)
  80109b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a2:	e8 75 fb ff ff       	call   800c1c <sys_page_unmap>
	return r;
}
  8010a7:	89 d8                	mov    %ebx,%eax
  8010a9:	83 c4 30             	add    $0x30,%esp
  8010ac:	5b                   	pop    %ebx
  8010ad:	5e                   	pop    %esi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c0:	89 04 24             	mov    %eax,(%esp)
  8010c3:	e8 ae fe ff ff       	call   800f76 <fd_lookup>
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 13                	js     8010df <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010cc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d3:	00 
  8010d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d7:	89 04 24             	mov    %eax,(%esp)
  8010da:	e8 49 ff ff ff       	call   801028 <fd_close>
}
  8010df:	c9                   	leave  
  8010e0:	c3                   	ret    

008010e1 <close_all>:

void
close_all(void)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010e8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ed:	89 1c 24             	mov    %ebx,(%esp)
  8010f0:	e8 bb ff ff ff       	call   8010b0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010f5:	43                   	inc    %ebx
  8010f6:	83 fb 20             	cmp    $0x20,%ebx
  8010f9:	75 f2                	jne    8010ed <close_all+0xc>
		close(i);
}
  8010fb:	83 c4 14             	add    $0x14,%esp
  8010fe:	5b                   	pop    %ebx
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	57                   	push   %edi
  801105:	56                   	push   %esi
  801106:	53                   	push   %ebx
  801107:	83 ec 4c             	sub    $0x4c,%esp
  80110a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80110d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801110:	89 44 24 04          	mov    %eax,0x4(%esp)
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	89 04 24             	mov    %eax,(%esp)
  80111a:	e8 57 fe ff ff       	call   800f76 <fd_lookup>
  80111f:	89 c3                	mov    %eax,%ebx
  801121:	85 c0                	test   %eax,%eax
  801123:	0f 88 e1 00 00 00    	js     80120a <dup+0x109>
		return r;
	close(newfdnum);
  801129:	89 3c 24             	mov    %edi,(%esp)
  80112c:	e8 7f ff ff ff       	call   8010b0 <close>

	newfd = INDEX2FD(newfdnum);
  801131:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801137:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80113a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80113d:	89 04 24             	mov    %eax,(%esp)
  801140:	e8 c3 fd ff ff       	call   800f08 <fd2data>
  801145:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801147:	89 34 24             	mov    %esi,(%esp)
  80114a:	e8 b9 fd ff ff       	call   800f08 <fd2data>
  80114f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801152:	89 d8                	mov    %ebx,%eax
  801154:	c1 e8 16             	shr    $0x16,%eax
  801157:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80115e:	a8 01                	test   $0x1,%al
  801160:	74 46                	je     8011a8 <dup+0xa7>
  801162:	89 d8                	mov    %ebx,%eax
  801164:	c1 e8 0c             	shr    $0xc,%eax
  801167:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80116e:	f6 c2 01             	test   $0x1,%dl
  801171:	74 35                	je     8011a8 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801173:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80117a:	25 07 0e 00 00       	and    $0xe07,%eax
  80117f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801183:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801186:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801191:	00 
  801192:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801196:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80119d:	e8 27 fa ff ff       	call   800bc9 <sys_page_map>
  8011a2:	89 c3                	mov    %eax,%ebx
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	78 3b                	js     8011e3 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	c1 ea 0c             	shr    $0xc,%edx
  8011b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011cc:	00 
  8011cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d8:	e8 ec f9 ff ff       	call   800bc9 <sys_page_map>
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	79 25                	jns    801208 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ee:	e8 29 fa ff ff       	call   800c1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801201:	e8 16 fa ff ff       	call   800c1c <sys_page_unmap>
	return r;
  801206:	eb 02                	jmp    80120a <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801208:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80120a:	89 d8                	mov    %ebx,%eax
  80120c:	83 c4 4c             	add    $0x4c,%esp
  80120f:	5b                   	pop    %ebx
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	53                   	push   %ebx
  801218:	83 ec 24             	sub    $0x24,%esp
  80121b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801221:	89 44 24 04          	mov    %eax,0x4(%esp)
  801225:	89 1c 24             	mov    %ebx,(%esp)
  801228:	e8 49 fd ff ff       	call   800f76 <fd_lookup>
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 6f                	js     8012a0 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801231:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801234:	89 44 24 04          	mov    %eax,0x4(%esp)
  801238:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123b:	8b 00                	mov    (%eax),%eax
  80123d:	89 04 24             	mov    %eax,(%esp)
  801240:	e8 87 fd ff ff       	call   800fcc <dev_lookup>
  801245:	85 c0                	test   %eax,%eax
  801247:	78 57                	js     8012a0 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124c:	8b 50 08             	mov    0x8(%eax),%edx
  80124f:	83 e2 03             	and    $0x3,%edx
  801252:	83 fa 01             	cmp    $0x1,%edx
  801255:	75 25                	jne    80127c <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801257:	a1 04 40 80 00       	mov    0x804004,%eax
  80125c:	8b 00                	mov    (%eax),%eax
  80125e:	8b 40 48             	mov    0x48(%eax),%eax
  801261:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801265:	89 44 24 04          	mov    %eax,0x4(%esp)
  801269:	c7 04 24 c9 23 80 00 	movl   $0x8023c9,(%esp)
  801270:	e8 63 ef ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  801275:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127a:	eb 24                	jmp    8012a0 <read+0x8c>
	}
	if (!dev->dev_read)
  80127c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127f:	8b 52 08             	mov    0x8(%edx),%edx
  801282:	85 d2                	test   %edx,%edx
  801284:	74 15                	je     80129b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801286:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801289:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80128d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801290:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801294:	89 04 24             	mov    %eax,(%esp)
  801297:	ff d2                	call   *%edx
  801299:	eb 05                	jmp    8012a0 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80129b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012a0:	83 c4 24             	add    $0x24,%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	57                   	push   %edi
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 1c             	sub    $0x1c,%esp
  8012af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ba:	eb 23                	jmp    8012df <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012bc:	89 f0                	mov    %esi,%eax
  8012be:	29 d8                	sub    %ebx,%eax
  8012c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c7:	01 d8                	add    %ebx,%eax
  8012c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cd:	89 3c 24             	mov    %edi,(%esp)
  8012d0:	e8 3f ff ff ff       	call   801214 <read>
		if (m < 0)
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 10                	js     8012e9 <readn+0x43>
			return m;
		if (m == 0)
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	74 0a                	je     8012e7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012dd:	01 c3                	add    %eax,%ebx
  8012df:	39 f3                	cmp    %esi,%ebx
  8012e1:	72 d9                	jb     8012bc <readn+0x16>
  8012e3:	89 d8                	mov    %ebx,%eax
  8012e5:	eb 02                	jmp    8012e9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012e7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012e9:	83 c4 1c             	add    $0x1c,%esp
  8012ec:	5b                   	pop    %ebx
  8012ed:	5e                   	pop    %esi
  8012ee:	5f                   	pop    %edi
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    

008012f1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 24             	sub    $0x24,%esp
  8012f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801302:	89 1c 24             	mov    %ebx,(%esp)
  801305:	e8 6c fc ff ff       	call   800f76 <fd_lookup>
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 6a                	js     801378 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801311:	89 44 24 04          	mov    %eax,0x4(%esp)
  801315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801318:	8b 00                	mov    (%eax),%eax
  80131a:	89 04 24             	mov    %eax,(%esp)
  80131d:	e8 aa fc ff ff       	call   800fcc <dev_lookup>
  801322:	85 c0                	test   %eax,%eax
  801324:	78 52                	js     801378 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801326:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801329:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80132d:	75 25                	jne    801354 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80132f:	a1 04 40 80 00       	mov    0x804004,%eax
  801334:	8b 00                	mov    (%eax),%eax
  801336:	8b 40 48             	mov    0x48(%eax),%eax
  801339:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80133d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801341:	c7 04 24 e5 23 80 00 	movl   $0x8023e5,(%esp)
  801348:	e8 8b ee ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  80134d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801352:	eb 24                	jmp    801378 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801354:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801357:	8b 52 0c             	mov    0xc(%edx),%edx
  80135a:	85 d2                	test   %edx,%edx
  80135c:	74 15                	je     801373 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80135e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801361:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801365:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801368:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80136c:	89 04 24             	mov    %eax,(%esp)
  80136f:	ff d2                	call   *%edx
  801371:	eb 05                	jmp    801378 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801373:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801378:	83 c4 24             	add    $0x24,%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <seek>:

int
seek(int fdnum, off_t offset)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801384:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801387:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138b:	8b 45 08             	mov    0x8(%ebp),%eax
  80138e:	89 04 24             	mov    %eax,(%esp)
  801391:	e8 e0 fb ff ff       	call   800f76 <fd_lookup>
  801396:	85 c0                	test   %eax,%eax
  801398:	78 0e                	js     8013a8 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80139a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80139d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 24             	sub    $0x24,%esp
  8013b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bb:	89 1c 24             	mov    %ebx,(%esp)
  8013be:	e8 b3 fb ff ff       	call   800f76 <fd_lookup>
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 63                	js     80142a <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d1:	8b 00                	mov    (%eax),%eax
  8013d3:	89 04 24             	mov    %eax,(%esp)
  8013d6:	e8 f1 fb ff ff       	call   800fcc <dev_lookup>
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 4b                	js     80142a <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013e6:	75 25                	jne    80140d <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ed:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ef:	8b 40 48             	mov    0x48(%eax),%eax
  8013f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fa:	c7 04 24 a8 23 80 00 	movl   $0x8023a8,(%esp)
  801401:	e8 d2 ed ff ff       	call   8001d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80140b:	eb 1d                	jmp    80142a <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  80140d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801410:	8b 52 18             	mov    0x18(%edx),%edx
  801413:	85 d2                	test   %edx,%edx
  801415:	74 0e                	je     801425 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801417:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80141a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80141e:	89 04 24             	mov    %eax,(%esp)
  801421:	ff d2                	call   *%edx
  801423:	eb 05                	jmp    80142a <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801425:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80142a:	83 c4 24             	add    $0x24,%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	53                   	push   %ebx
  801434:	83 ec 24             	sub    $0x24,%esp
  801437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801441:	8b 45 08             	mov    0x8(%ebp),%eax
  801444:	89 04 24             	mov    %eax,(%esp)
  801447:	e8 2a fb ff ff       	call   800f76 <fd_lookup>
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 52                	js     8014a2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801450:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801453:	89 44 24 04          	mov    %eax,0x4(%esp)
  801457:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145a:	8b 00                	mov    (%eax),%eax
  80145c:	89 04 24             	mov    %eax,(%esp)
  80145f:	e8 68 fb ff ff       	call   800fcc <dev_lookup>
  801464:	85 c0                	test   %eax,%eax
  801466:	78 3a                	js     8014a2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80146f:	74 2c                	je     80149d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801471:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801474:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80147b:	00 00 00 
	stat->st_isdir = 0;
  80147e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801485:	00 00 00 
	stat->st_dev = dev;
  801488:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80148e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801492:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801495:	89 14 24             	mov    %edx,(%esp)
  801498:	ff 50 14             	call   *0x14(%eax)
  80149b:	eb 05                	jmp    8014a2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80149d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014a2:	83 c4 24             	add    $0x24,%esp
  8014a5:	5b                   	pop    %ebx
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    

008014a8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	56                   	push   %esi
  8014ac:	53                   	push   %ebx
  8014ad:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014b7:	00 
  8014b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bb:	89 04 24             	mov    %eax,(%esp)
  8014be:	e8 88 02 00 00       	call   80174b <open>
  8014c3:	89 c3                	mov    %eax,%ebx
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 1b                	js     8014e4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d0:	89 1c 24             	mov    %ebx,(%esp)
  8014d3:	e8 58 ff ff ff       	call   801430 <fstat>
  8014d8:	89 c6                	mov    %eax,%esi
	close(fd);
  8014da:	89 1c 24             	mov    %ebx,(%esp)
  8014dd:	e8 ce fb ff ff       	call   8010b0 <close>
	return r;
  8014e2:	89 f3                	mov    %esi,%ebx
}
  8014e4:	89 d8                	mov    %ebx,%eax
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    
  8014ed:	00 00                	add    %al,(%eax)
	...

008014f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	56                   	push   %esi
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 10             	sub    $0x10,%esp
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014fc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801503:	75 11                	jne    801516 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801505:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80150c:	e8 a2 f9 ff ff       	call   800eb3 <ipc_find_env>
  801511:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801516:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80151d:	00 
  80151e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801525:	00 
  801526:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80152a:	a1 00 40 80 00       	mov    0x804000,%eax
  80152f:	89 04 24             	mov    %eax,(%esp)
  801532:	e8 16 f9 ff ff       	call   800e4d <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801537:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80153e:	00 
  80153f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801543:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80154a:	e8 91 f8 ff ff       	call   800de0 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80155c:	8b 45 08             	mov    0x8(%ebp),%eax
  80155f:	8b 40 0c             	mov    0xc(%eax),%eax
  801562:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801567:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80156f:	ba 00 00 00 00       	mov    $0x0,%edx
  801574:	b8 02 00 00 00       	mov    $0x2,%eax
  801579:	e8 72 ff ff ff       	call   8014f0 <fsipc>
}
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801586:	8b 45 08             	mov    0x8(%ebp),%eax
  801589:	8b 40 0c             	mov    0xc(%eax),%eax
  80158c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801591:	ba 00 00 00 00       	mov    $0x0,%edx
  801596:	b8 06 00 00 00       	mov    $0x6,%eax
  80159b:	e8 50 ff ff ff       	call   8014f0 <fsipc>
}
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 14             	sub    $0x14,%esp
  8015a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8015af:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c1:	e8 2a ff ff ff       	call   8014f0 <fsipc>
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 2b                	js     8015f5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015ca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015d1:	00 
  8015d2:	89 1c 24             	mov    %ebx,(%esp)
  8015d5:	e8 a9 f1 ff ff       	call   800783 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015da:	a1 80 50 80 00       	mov    0x805080,%eax
  8015df:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015e5:	a1 84 50 80 00       	mov    0x805084,%eax
  8015ea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f5:	83 c4 14             	add    $0x14,%esp
  8015f8:	5b                   	pop    %ebx
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    

008015fb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	53                   	push   %ebx
  8015ff:	83 ec 14             	sub    $0x14,%esp
  801602:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801605:	8b 45 08             	mov    0x8(%ebp),%eax
  801608:	8b 40 0c             	mov    0xc(%eax),%eax
  80160b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801610:	89 d8                	mov    %ebx,%eax
  801612:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801618:	76 05                	jbe    80161f <devfile_write+0x24>
  80161a:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  80161f:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801624:	89 44 24 08          	mov    %eax,0x8(%esp)
  801628:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162f:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801636:	e8 2b f3 ff ff       	call   800966 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  80163b:	ba 00 00 00 00       	mov    $0x0,%edx
  801640:	b8 04 00 00 00       	mov    $0x4,%eax
  801645:	e8 a6 fe ff ff       	call   8014f0 <fsipc>
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 53                	js     8016a1 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  80164e:	39 c3                	cmp    %eax,%ebx
  801650:	73 24                	jae    801676 <devfile_write+0x7b>
  801652:	c7 44 24 0c 14 24 80 	movl   $0x802414,0xc(%esp)
  801659:	00 
  80165a:	c7 44 24 08 1b 24 80 	movl   $0x80241b,0x8(%esp)
  801661:	00 
  801662:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801669:	00 
  80166a:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  801671:	e8 92 06 00 00       	call   801d08 <_panic>
	assert(r <= PGSIZE);
  801676:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80167b:	7e 24                	jle    8016a1 <devfile_write+0xa6>
  80167d:	c7 44 24 0c 3b 24 80 	movl   $0x80243b,0xc(%esp)
  801684:	00 
  801685:	c7 44 24 08 1b 24 80 	movl   $0x80241b,0x8(%esp)
  80168c:	00 
  80168d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801694:	00 
  801695:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  80169c:	e8 67 06 00 00       	call   801d08 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  8016a1:	83 c4 14             	add    $0x14,%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	56                   	push   %esi
  8016ab:	53                   	push   %ebx
  8016ac:	83 ec 10             	sub    $0x10,%esp
  8016af:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016bd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8016cd:	e8 1e fe ff ff       	call   8014f0 <fsipc>
  8016d2:	89 c3                	mov    %eax,%ebx
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 6a                	js     801742 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016d8:	39 c6                	cmp    %eax,%esi
  8016da:	73 24                	jae    801700 <devfile_read+0x59>
  8016dc:	c7 44 24 0c 14 24 80 	movl   $0x802414,0xc(%esp)
  8016e3:	00 
  8016e4:	c7 44 24 08 1b 24 80 	movl   $0x80241b,0x8(%esp)
  8016eb:	00 
  8016ec:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8016f3:	00 
  8016f4:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  8016fb:	e8 08 06 00 00       	call   801d08 <_panic>
	assert(r <= PGSIZE);
  801700:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801705:	7e 24                	jle    80172b <devfile_read+0x84>
  801707:	c7 44 24 0c 3b 24 80 	movl   $0x80243b,0xc(%esp)
  80170e:	00 
  80170f:	c7 44 24 08 1b 24 80 	movl   $0x80241b,0x8(%esp)
  801716:	00 
  801717:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  80171e:	00 
  80171f:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  801726:	e8 dd 05 00 00       	call   801d08 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80172b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80172f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801736:	00 
  801737:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173a:	89 04 24             	mov    %eax,(%esp)
  80173d:	e8 ba f1 ff ff       	call   8008fc <memmove>
	return r;
}
  801742:	89 d8                	mov    %ebx,%eax
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	5b                   	pop    %ebx
  801748:	5e                   	pop    %esi
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	83 ec 20             	sub    $0x20,%esp
  801753:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801756:	89 34 24             	mov    %esi,(%esp)
  801759:	e8 f2 ef ff ff       	call   800750 <strlen>
  80175e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801763:	7f 60                	jg     8017c5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801765:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801768:	89 04 24             	mov    %eax,(%esp)
  80176b:	e8 b3 f7 ff ff       	call   800f23 <fd_alloc>
  801770:	89 c3                	mov    %eax,%ebx
  801772:	85 c0                	test   %eax,%eax
  801774:	78 54                	js     8017ca <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801776:	89 74 24 04          	mov    %esi,0x4(%esp)
  80177a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801781:	e8 fd ef ff ff       	call   800783 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801786:	8b 45 0c             	mov    0xc(%ebp),%eax
  801789:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80178e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801791:	b8 01 00 00 00       	mov    $0x1,%eax
  801796:	e8 55 fd ff ff       	call   8014f0 <fsipc>
  80179b:	89 c3                	mov    %eax,%ebx
  80179d:	85 c0                	test   %eax,%eax
  80179f:	79 15                	jns    8017b6 <open+0x6b>
		fd_close(fd, 0);
  8017a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017a8:	00 
  8017a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ac:	89 04 24             	mov    %eax,(%esp)
  8017af:	e8 74 f8 ff ff       	call   801028 <fd_close>
		return r;
  8017b4:	eb 14                	jmp    8017ca <open+0x7f>
	}

	return fd2num(fd);
  8017b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b9:	89 04 24             	mov    %eax,(%esp)
  8017bc:	e8 37 f7 ff ff       	call   800ef8 <fd2num>
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	eb 05                	jmp    8017ca <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017c5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017ca:	89 d8                	mov    %ebx,%eax
  8017cc:	83 c4 20             	add    $0x20,%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017de:	b8 08 00 00 00       	mov    $0x8,%eax
  8017e3:	e8 08 fd ff ff       	call   8014f0 <fsipc>
}
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    
	...

008017ec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 10             	sub    $0x10,%esp
  8017f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	e8 06 f7 ff ff       	call   800f08 <fd2data>
  801802:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801804:	c7 44 24 04 47 24 80 	movl   $0x802447,0x4(%esp)
  80180b:	00 
  80180c:	89 34 24             	mov    %esi,(%esp)
  80180f:	e8 6f ef ff ff       	call   800783 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801814:	8b 43 04             	mov    0x4(%ebx),%eax
  801817:	2b 03                	sub    (%ebx),%eax
  801819:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80181f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801826:	00 00 00 
	stat->st_dev = &devpipe;
  801829:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801830:	30 80 00 
	return 0;
}
  801833:	b8 00 00 00 00       	mov    $0x0,%eax
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5e                   	pop    %esi
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	53                   	push   %ebx
  801843:	83 ec 14             	sub    $0x14,%esp
  801846:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801849:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80184d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801854:	e8 c3 f3 ff ff       	call   800c1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801859:	89 1c 24             	mov    %ebx,(%esp)
  80185c:	e8 a7 f6 ff ff       	call   800f08 <fd2data>
  801861:	89 44 24 04          	mov    %eax,0x4(%esp)
  801865:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80186c:	e8 ab f3 ff ff       	call   800c1c <sys_page_unmap>
}
  801871:	83 c4 14             	add    $0x14,%esp
  801874:	5b                   	pop    %ebx
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	57                   	push   %edi
  80187b:	56                   	push   %esi
  80187c:	53                   	push   %ebx
  80187d:	83 ec 2c             	sub    $0x2c,%esp
  801880:	89 c7                	mov    %eax,%edi
  801882:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801885:	a1 04 40 80 00       	mov    0x804004,%eax
  80188a:	8b 00                	mov    (%eax),%eax
  80188c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80188f:	89 3c 24             	mov    %edi,(%esp)
  801892:	e8 c9 04 00 00       	call   801d60 <pageref>
  801897:	89 c6                	mov    %eax,%esi
  801899:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80189c:	89 04 24             	mov    %eax,(%esp)
  80189f:	e8 bc 04 00 00       	call   801d60 <pageref>
  8018a4:	39 c6                	cmp    %eax,%esi
  8018a6:	0f 94 c0             	sete   %al
  8018a9:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018ac:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018b2:	8b 12                	mov    (%edx),%edx
  8018b4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018b7:	39 cb                	cmp    %ecx,%ebx
  8018b9:	75 08                	jne    8018c3 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8018bb:	83 c4 2c             	add    $0x2c,%esp
  8018be:	5b                   	pop    %ebx
  8018bf:	5e                   	pop    %esi
  8018c0:	5f                   	pop    %edi
  8018c1:	5d                   	pop    %ebp
  8018c2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8018c3:	83 f8 01             	cmp    $0x1,%eax
  8018c6:	75 bd                	jne    801885 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018c8:	8b 42 58             	mov    0x58(%edx),%eax
  8018cb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8018d2:	00 
  8018d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018db:	c7 04 24 4e 24 80 00 	movl   $0x80244e,(%esp)
  8018e2:	e8 f1 e8 ff ff       	call   8001d8 <cprintf>
  8018e7:	eb 9c                	jmp    801885 <_pipeisclosed+0xe>

008018e9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	57                   	push   %edi
  8018ed:	56                   	push   %esi
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 1c             	sub    $0x1c,%esp
  8018f2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018f5:	89 34 24             	mov    %esi,(%esp)
  8018f8:	e8 0b f6 ff ff       	call   800f08 <fd2data>
  8018fd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801904:	eb 3c                	jmp    801942 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801906:	89 da                	mov    %ebx,%edx
  801908:	89 f0                	mov    %esi,%eax
  80190a:	e8 68 ff ff ff       	call   801877 <_pipeisclosed>
  80190f:	85 c0                	test   %eax,%eax
  801911:	75 38                	jne    80194b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801913:	e8 3e f2 ff ff       	call   800b56 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801918:	8b 43 04             	mov    0x4(%ebx),%eax
  80191b:	8b 13                	mov    (%ebx),%edx
  80191d:	83 c2 20             	add    $0x20,%edx
  801920:	39 d0                	cmp    %edx,%eax
  801922:	73 e2                	jae    801906 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801924:	8b 55 0c             	mov    0xc(%ebp),%edx
  801927:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80192a:	89 c2                	mov    %eax,%edx
  80192c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801932:	79 05                	jns    801939 <devpipe_write+0x50>
  801934:	4a                   	dec    %edx
  801935:	83 ca e0             	or     $0xffffffe0,%edx
  801938:	42                   	inc    %edx
  801939:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80193d:	40                   	inc    %eax
  80193e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801941:	47                   	inc    %edi
  801942:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801945:	75 d1                	jne    801918 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801947:	89 f8                	mov    %edi,%eax
  801949:	eb 05                	jmp    801950 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801950:	83 c4 1c             	add    $0x1c,%esp
  801953:	5b                   	pop    %ebx
  801954:	5e                   	pop    %esi
  801955:	5f                   	pop    %edi
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    

00801958 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	57                   	push   %edi
  80195c:	56                   	push   %esi
  80195d:	53                   	push   %ebx
  80195e:	83 ec 1c             	sub    $0x1c,%esp
  801961:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801964:	89 3c 24             	mov    %edi,(%esp)
  801967:	e8 9c f5 ff ff       	call   800f08 <fd2data>
  80196c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80196e:	be 00 00 00 00       	mov    $0x0,%esi
  801973:	eb 3a                	jmp    8019af <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801975:	85 f6                	test   %esi,%esi
  801977:	74 04                	je     80197d <devpipe_read+0x25>
				return i;
  801979:	89 f0                	mov    %esi,%eax
  80197b:	eb 40                	jmp    8019bd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80197d:	89 da                	mov    %ebx,%edx
  80197f:	89 f8                	mov    %edi,%eax
  801981:	e8 f1 fe ff ff       	call   801877 <_pipeisclosed>
  801986:	85 c0                	test   %eax,%eax
  801988:	75 2e                	jne    8019b8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80198a:	e8 c7 f1 ff ff       	call   800b56 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80198f:	8b 03                	mov    (%ebx),%eax
  801991:	3b 43 04             	cmp    0x4(%ebx),%eax
  801994:	74 df                	je     801975 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801996:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80199b:	79 05                	jns    8019a2 <devpipe_read+0x4a>
  80199d:	48                   	dec    %eax
  80199e:	83 c8 e0             	or     $0xffffffe0,%eax
  8019a1:	40                   	inc    %eax
  8019a2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019a9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019ac:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ae:	46                   	inc    %esi
  8019af:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019b2:	75 db                	jne    80198f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019b4:	89 f0                	mov    %esi,%eax
  8019b6:	eb 05                	jmp    8019bd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019bd:	83 c4 1c             	add    $0x1c,%esp
  8019c0:	5b                   	pop    %ebx
  8019c1:	5e                   	pop    %esi
  8019c2:	5f                   	pop    %edi
  8019c3:	5d                   	pop    %ebp
  8019c4:	c3                   	ret    

008019c5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	57                   	push   %edi
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	83 ec 3c             	sub    $0x3c,%esp
  8019ce:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019d4:	89 04 24             	mov    %eax,(%esp)
  8019d7:	e8 47 f5 ff ff       	call   800f23 <fd_alloc>
  8019dc:	89 c3                	mov    %eax,%ebx
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	0f 88 45 01 00 00    	js     801b2b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019ed:	00 
  8019ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fc:	e8 74 f1 ff ff       	call   800b75 <sys_page_alloc>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	85 c0                	test   %eax,%eax
  801a05:	0f 88 20 01 00 00    	js     801b2b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a0b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	e8 0d f5 ff ff       	call   800f23 <fd_alloc>
  801a16:	89 c3                	mov    %eax,%ebx
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	0f 88 f8 00 00 00    	js     801b18 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a20:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a27:	00 
  801a28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a36:	e8 3a f1 ff ff       	call   800b75 <sys_page_alloc>
  801a3b:	89 c3                	mov    %eax,%ebx
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	0f 88 d3 00 00 00    	js     801b18 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a48:	89 04 24             	mov    %eax,(%esp)
  801a4b:	e8 b8 f4 ff ff       	call   800f08 <fd2data>
  801a50:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a59:	00 
  801a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a65:	e8 0b f1 ff ff       	call   800b75 <sys_page_alloc>
  801a6a:	89 c3                	mov    %eax,%ebx
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	0f 88 91 00 00 00    	js     801b05 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a77:	89 04 24             	mov    %eax,(%esp)
  801a7a:	e8 89 f4 ff ff       	call   800f08 <fd2data>
  801a7f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801a86:	00 
  801a87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a92:	00 
  801a93:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9e:	e8 26 f1 ff ff       	call   800bc9 <sys_page_map>
  801aa3:	89 c3                	mov    %eax,%ebx
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 4c                	js     801af5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801aa9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ab4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801abe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ac4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ac7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ac9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801acc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad6:	89 04 24             	mov    %eax,(%esp)
  801ad9:	e8 1a f4 ff ff       	call   800ef8 <fd2num>
  801ade:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ae0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ae3:	89 04 24             	mov    %eax,(%esp)
  801ae6:	e8 0d f4 ff ff       	call   800ef8 <fd2num>
  801aeb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801aee:	bb 00 00 00 00       	mov    $0x0,%ebx
  801af3:	eb 36                	jmp    801b2b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801af5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801af9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b00:	e8 17 f1 ff ff       	call   800c1c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801b05:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b13:	e8 04 f1 ff ff       	call   800c1c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b26:	e8 f1 f0 ff ff       	call   800c1c <sys_page_unmap>
    err:
	return r;
}
  801b2b:	89 d8                	mov    %ebx,%eax
  801b2d:	83 c4 3c             	add    $0x3c,%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5f                   	pop    %edi
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	89 04 24             	mov    %eax,(%esp)
  801b48:	e8 29 f4 ff ff       	call   800f76 <fd_lookup>
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	78 15                	js     801b66 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b54:	89 04 24             	mov    %eax,(%esp)
  801b57:	e8 ac f3 ff ff       	call   800f08 <fd2data>
	return _pipeisclosed(fd, p);
  801b5c:	89 c2                	mov    %eax,%edx
  801b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b61:	e8 11 fd ff ff       	call   801877 <_pipeisclosed>
}
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801b78:	c7 44 24 04 66 24 80 	movl   $0x802466,0x4(%esp)
  801b7f:	00 
  801b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b83:	89 04 24             	mov    %eax,(%esp)
  801b86:	e8 f8 eb ff ff       	call   800783 <strcpy>
	return 0;
}
  801b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	57                   	push   %edi
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b9e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ba3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ba9:	eb 30                	jmp    801bdb <devcons_write+0x49>
		m = n - tot;
  801bab:	8b 75 10             	mov    0x10(%ebp),%esi
  801bae:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801bb0:	83 fe 7f             	cmp    $0x7f,%esi
  801bb3:	76 05                	jbe    801bba <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801bb5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801bba:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bbe:	03 45 0c             	add    0xc(%ebp),%eax
  801bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc5:	89 3c 24             	mov    %edi,(%esp)
  801bc8:	e8 2f ed ff ff       	call   8008fc <memmove>
		sys_cputs(buf, m);
  801bcd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bd1:	89 3c 24             	mov    %edi,(%esp)
  801bd4:	e8 cf ee ff ff       	call   800aa8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bd9:	01 f3                	add    %esi,%ebx
  801bdb:	89 d8                	mov    %ebx,%eax
  801bdd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801be0:	72 c9                	jb     801bab <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801be2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801be8:	5b                   	pop    %ebx
  801be9:	5e                   	pop    %esi
  801bea:	5f                   	pop    %edi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801bf3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bf7:	75 07                	jne    801c00 <devcons_read+0x13>
  801bf9:	eb 25                	jmp    801c20 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bfb:	e8 56 ef ff ff       	call   800b56 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c00:	e8 c1 ee ff ff       	call   800ac6 <sys_cgetc>
  801c05:	85 c0                	test   %eax,%eax
  801c07:	74 f2                	je     801bfb <devcons_read+0xe>
  801c09:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 1d                	js     801c2c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c0f:	83 f8 04             	cmp    $0x4,%eax
  801c12:	74 13                	je     801c27 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c17:	88 10                	mov    %dl,(%eax)
	return 1;
  801c19:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1e:	eb 0c                	jmp    801c2c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c20:	b8 00 00 00 00       	mov    $0x0,%eax
  801c25:	eb 05                	jmp    801c2c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c27:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801c34:	8b 45 08             	mov    0x8(%ebp),%eax
  801c37:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c3a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c41:	00 
  801c42:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c45:	89 04 24             	mov    %eax,(%esp)
  801c48:	e8 5b ee ff ff       	call   800aa8 <sys_cputs>
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <getchar>:

int
getchar(void)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c55:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801c5c:	00 
  801c5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c6b:	e8 a4 f5 ff ff       	call   801214 <read>
	if (r < 0)
  801c70:	85 c0                	test   %eax,%eax
  801c72:	78 0f                	js     801c83 <getchar+0x34>
		return r;
	if (r < 1)
  801c74:	85 c0                	test   %eax,%eax
  801c76:	7e 06                	jle    801c7e <getchar+0x2f>
		return -E_EOF;
	return c;
  801c78:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c7c:	eb 05                	jmp    801c83 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c7e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c83:	c9                   	leave  
  801c84:	c3                   	ret    

00801c85 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	89 04 24             	mov    %eax,(%esp)
  801c98:	e8 d9 f2 ff ff       	call   800f76 <fd_lookup>
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 11                	js     801cb2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801caa:	39 10                	cmp    %edx,(%eax)
  801cac:	0f 94 c0             	sete   %al
  801caf:	0f b6 c0             	movzbl %al,%eax
}
  801cb2:	c9                   	leave  
  801cb3:	c3                   	ret    

00801cb4 <opencons>:

int
opencons(void)
{
  801cb4:	55                   	push   %ebp
  801cb5:	89 e5                	mov    %esp,%ebp
  801cb7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbd:	89 04 24             	mov    %eax,(%esp)
  801cc0:	e8 5e f2 ff ff       	call   800f23 <fd_alloc>
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 3c                	js     801d05 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801cd0:	00 
  801cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cdf:	e8 91 ee ff ff       	call   800b75 <sys_page_alloc>
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 1d                	js     801d05 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cfd:	89 04 24             	mov    %eax,(%esp)
  801d00:	e8 f3 f1 ff ff       	call   800ef8 <fd2num>
}
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    
	...

00801d08 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	56                   	push   %esi
  801d0c:	53                   	push   %ebx
  801d0d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801d10:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d13:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d19:	e8 19 ee ff ff       	call   800b37 <sys_getenvid>
  801d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d21:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d25:	8b 55 08             	mov    0x8(%ebp),%edx
  801d28:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d2c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d34:	c7 04 24 74 24 80 00 	movl   $0x802474,(%esp)
  801d3b:	e8 98 e4 ff ff       	call   8001d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d40:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d44:	8b 45 10             	mov    0x10(%ebp),%eax
  801d47:	89 04 24             	mov    %eax,(%esp)
  801d4a:	e8 28 e4 ff ff       	call   800177 <vcprintf>
	cprintf("\n");
  801d4f:	c7 04 24 7a 23 80 00 	movl   $0x80237a,(%esp)
  801d56:	e8 7d e4 ff ff       	call   8001d8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d5b:	cc                   	int3   
  801d5c:	eb fd                	jmp    801d5b <_panic+0x53>
	...

00801d60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801d66:	89 c2                	mov    %eax,%edx
  801d68:	c1 ea 16             	shr    $0x16,%edx
  801d6b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d72:	f6 c2 01             	test   $0x1,%dl
  801d75:	74 1e                	je     801d95 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d77:	c1 e8 0c             	shr    $0xc,%eax
  801d7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d81:	a8 01                	test   $0x1,%al
  801d83:	74 17                	je     801d9c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d85:	c1 e8 0c             	shr    $0xc,%eax
  801d88:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d8f:	ef 
  801d90:	0f b7 c0             	movzwl %ax,%eax
  801d93:	eb 0c                	jmp    801da1 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d95:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9a:	eb 05                	jmp    801da1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    
	...

00801da4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801da4:	55                   	push   %ebp
  801da5:	57                   	push   %edi
  801da6:	56                   	push   %esi
  801da7:	83 ec 10             	sub    $0x10,%esp
  801daa:	8b 74 24 20          	mov    0x20(%esp),%esi
  801dae:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801db2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801db6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801dba:	89 cd                	mov    %ecx,%ebp
  801dbc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	75 2c                	jne    801df0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801dc4:	39 f9                	cmp    %edi,%ecx
  801dc6:	77 68                	ja     801e30 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dc8:	85 c9                	test   %ecx,%ecx
  801dca:	75 0b                	jne    801dd7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dcc:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd1:	31 d2                	xor    %edx,%edx
  801dd3:	f7 f1                	div    %ecx
  801dd5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dd7:	31 d2                	xor    %edx,%edx
  801dd9:	89 f8                	mov    %edi,%eax
  801ddb:	f7 f1                	div    %ecx
  801ddd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ddf:	89 f0                	mov    %esi,%eax
  801de1:	f7 f1                	div    %ecx
  801de3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801de5:	89 f0                	mov    %esi,%eax
  801de7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	5e                   	pop    %esi
  801ded:	5f                   	pop    %edi
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801df0:	39 f8                	cmp    %edi,%eax
  801df2:	77 2c                	ja     801e20 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801df4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801df7:	83 f6 1f             	xor    $0x1f,%esi
  801dfa:	75 4c                	jne    801e48 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801dfc:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dfe:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e03:	72 0a                	jb     801e0f <__udivdi3+0x6b>
  801e05:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e09:	0f 87 ad 00 00 00    	ja     801ebc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e0f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e14:	89 f0                	mov    %esi,%eax
  801e16:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	5e                   	pop    %esi
  801e1c:	5f                   	pop    %edi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    
  801e1f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e20:	31 ff                	xor    %edi,%edi
  801e22:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e24:	89 f0                	mov    %esi,%eax
  801e26:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	5e                   	pop    %esi
  801e2c:	5f                   	pop    %edi
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    
  801e2f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e30:	89 fa                	mov    %edi,%edx
  801e32:	89 f0                	mov    %esi,%eax
  801e34:	f7 f1                	div    %ecx
  801e36:	89 c6                	mov    %eax,%esi
  801e38:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e3a:	89 f0                	mov    %esi,%eax
  801e3c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	5e                   	pop    %esi
  801e42:	5f                   	pop    %edi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    
  801e45:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e48:	89 f1                	mov    %esi,%ecx
  801e4a:	d3 e0                	shl    %cl,%eax
  801e4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e50:	b8 20 00 00 00       	mov    $0x20,%eax
  801e55:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e57:	89 ea                	mov    %ebp,%edx
  801e59:	88 c1                	mov    %al,%cl
  801e5b:	d3 ea                	shr    %cl,%edx
  801e5d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e61:	09 ca                	or     %ecx,%edx
  801e63:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801e67:	89 f1                	mov    %esi,%ecx
  801e69:	d3 e5                	shl    %cl,%ebp
  801e6b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801e6f:	89 fd                	mov    %edi,%ebp
  801e71:	88 c1                	mov    %al,%cl
  801e73:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801e75:	89 fa                	mov    %edi,%edx
  801e77:	89 f1                	mov    %esi,%ecx
  801e79:	d3 e2                	shl    %cl,%edx
  801e7b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e7f:	88 c1                	mov    %al,%cl
  801e81:	d3 ef                	shr    %cl,%edi
  801e83:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e85:	89 f8                	mov    %edi,%eax
  801e87:	89 ea                	mov    %ebp,%edx
  801e89:	f7 74 24 08          	divl   0x8(%esp)
  801e8d:	89 d1                	mov    %edx,%ecx
  801e8f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e91:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e95:	39 d1                	cmp    %edx,%ecx
  801e97:	72 17                	jb     801eb0 <__udivdi3+0x10c>
  801e99:	74 09                	je     801ea4 <__udivdi3+0x100>
  801e9b:	89 fe                	mov    %edi,%esi
  801e9d:	31 ff                	xor    %edi,%edi
  801e9f:	e9 41 ff ff ff       	jmp    801de5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ea4:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ea8:	89 f1                	mov    %esi,%ecx
  801eaa:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801eac:	39 c2                	cmp    %eax,%edx
  801eae:	73 eb                	jae    801e9b <__udivdi3+0xf7>
		{
		  q0--;
  801eb0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801eb3:	31 ff                	xor    %edi,%edi
  801eb5:	e9 2b ff ff ff       	jmp    801de5 <__udivdi3+0x41>
  801eba:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ebc:	31 f6                	xor    %esi,%esi
  801ebe:	e9 22 ff ff ff       	jmp    801de5 <__udivdi3+0x41>
	...

00801ec4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ec4:	55                   	push   %ebp
  801ec5:	57                   	push   %edi
  801ec6:	56                   	push   %esi
  801ec7:	83 ec 20             	sub    $0x20,%esp
  801eca:	8b 44 24 30          	mov    0x30(%esp),%eax
  801ece:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ed2:	89 44 24 14          	mov    %eax,0x14(%esp)
  801ed6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801eda:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ede:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801ee2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801ee4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ee6:	85 ed                	test   %ebp,%ebp
  801ee8:	75 16                	jne    801f00 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801eea:	39 f1                	cmp    %esi,%ecx
  801eec:	0f 86 a6 00 00 00    	jbe    801f98 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ef2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ef4:	89 d0                	mov    %edx,%eax
  801ef6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ef8:	83 c4 20             	add    $0x20,%esp
  801efb:	5e                   	pop    %esi
  801efc:	5f                   	pop    %edi
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    
  801eff:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f00:	39 f5                	cmp    %esi,%ebp
  801f02:	0f 87 ac 00 00 00    	ja     801fb4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f08:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801f0b:	83 f0 1f             	xor    $0x1f,%eax
  801f0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f12:	0f 84 a8 00 00 00    	je     801fc0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f18:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f1c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f1e:	bf 20 00 00 00       	mov    $0x20,%edi
  801f23:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f27:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f2b:	89 f9                	mov    %edi,%ecx
  801f2d:	d3 e8                	shr    %cl,%eax
  801f2f:	09 e8                	or     %ebp,%eax
  801f31:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801f35:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f39:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f3d:	d3 e0                	shl    %cl,%eax
  801f3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f43:	89 f2                	mov    %esi,%edx
  801f45:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f47:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f4b:	d3 e0                	shl    %cl,%eax
  801f4d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f51:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f55:	89 f9                	mov    %edi,%ecx
  801f57:	d3 e8                	shr    %cl,%eax
  801f59:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f5b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f5d:	89 f2                	mov    %esi,%edx
  801f5f:	f7 74 24 18          	divl   0x18(%esp)
  801f63:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f65:	f7 64 24 0c          	mull   0xc(%esp)
  801f69:	89 c5                	mov    %eax,%ebp
  801f6b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f6d:	39 d6                	cmp    %edx,%esi
  801f6f:	72 67                	jb     801fd8 <__umoddi3+0x114>
  801f71:	74 75                	je     801fe8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f73:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f77:	29 e8                	sub    %ebp,%eax
  801f79:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f7b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f7f:	d3 e8                	shr    %cl,%eax
  801f81:	89 f2                	mov    %esi,%edx
  801f83:	89 f9                	mov    %edi,%ecx
  801f85:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f87:	09 d0                	or     %edx,%eax
  801f89:	89 f2                	mov    %esi,%edx
  801f8b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f8f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f91:	83 c4 20             	add    $0x20,%esp
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f98:	85 c9                	test   %ecx,%ecx
  801f9a:	75 0b                	jne    801fa7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa1:	31 d2                	xor    %edx,%edx
  801fa3:	f7 f1                	div    %ecx
  801fa5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fa7:	89 f0                	mov    %esi,%eax
  801fa9:	31 d2                	xor    %edx,%edx
  801fab:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fad:	89 f8                	mov    %edi,%eax
  801faf:	e9 3e ff ff ff       	jmp    801ef2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801fb4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fb6:	83 c4 20             	add    $0x20,%esp
  801fb9:	5e                   	pop    %esi
  801fba:	5f                   	pop    %edi
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    
  801fbd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fc0:	39 f5                	cmp    %esi,%ebp
  801fc2:	72 04                	jb     801fc8 <__umoddi3+0x104>
  801fc4:	39 f9                	cmp    %edi,%ecx
  801fc6:	77 06                	ja     801fce <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fc8:	89 f2                	mov    %esi,%edx
  801fca:	29 cf                	sub    %ecx,%edi
  801fcc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801fce:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fd0:	83 c4 20             	add    $0x20,%esp
  801fd3:	5e                   	pop    %esi
  801fd4:	5f                   	pop    %edi
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    
  801fd7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801fd8:	89 d1                	mov    %edx,%ecx
  801fda:	89 c5                	mov    %eax,%ebp
  801fdc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801fe0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801fe4:	eb 8d                	jmp    801f73 <__umoddi3+0xaf>
  801fe6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fe8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801fec:	72 ea                	jb     801fd8 <__umoddi3+0x114>
  801fee:	89 f1                	mov    %esi,%ecx
  801ff0:	eb 81                	jmp    801f73 <__umoddi3+0xaf>
