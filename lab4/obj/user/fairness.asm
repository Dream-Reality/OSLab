
obj/user/fairness:     file format elf32-i386


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
  80003c:	e8 fe 0a 00 00       	call   800b3f <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
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
  800066:	e8 29 0d 00 00       	call   800d94 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800072:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800076:	c7 04 24 60 11 80 00 	movl   $0x801160,(%esp)
  80007d:	e8 5e 01 00 00       	call   8001e0 <cprintf>
  800082:	eb cf                	jmp    800053 <umain+0x1f>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800084:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800089:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	c7 04 24 71 11 80 00 	movl   $0x801171,(%esp)
  800098:	e8 43 01 00 00       	call   8001e0 <cprintf>
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
  8000bd:	e8 3f 0d 00 00       	call   800e01 <ipc_send>
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
  8000d2:	e8 68 0a 00 00       	call   800b3f <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e3:	c1 e0 07             	shl    $0x7,%eax
  8000e6:	29 d0                	sub    %edx,%eax
  8000e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000f3:	a3 04 20 80 00       	mov    %eax,0x802004
  8000f8:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  8000fc:	c7 04 24 6d 11 80 00 	movl   $0x80116d,(%esp)
  800103:	e8 d8 00 00 00       	call   8001e0 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800108:	85 f6                	test   %esi,%esi
  80010a:	7e 07                	jle    800113 <libmain+0x4f>
		binaryname = argv[0];
  80010c:	8b 03                	mov    (%ebx),%eax
  80010e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800113:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800117:	89 34 24             	mov    %esi,(%esp)
  80011a:	e8 15 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80011f:	e8 08 00 00 00       	call   80012c <exit>
}
  800124:	83 c4 20             	add    $0x20,%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    
	...

0080012c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800139:	e8 af 09 00 00       	call   800aed <sys_env_destroy>
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	53                   	push   %ebx
  800144:	83 ec 14             	sub    $0x14,%esp
  800147:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014a:	8b 03                	mov    (%ebx),%eax
  80014c:	8b 55 08             	mov    0x8(%ebp),%edx
  80014f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800153:	40                   	inc    %eax
  800154:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800156:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015b:	75 19                	jne    800176 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80015d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800164:	00 
  800165:	8d 43 08             	lea    0x8(%ebx),%eax
  800168:	89 04 24             	mov    %eax,(%esp)
  80016b:	e8 40 09 00 00       	call   800ab0 <sys_cputs>
		b->idx = 0;
  800170:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800176:	ff 43 04             	incl   0x4(%ebx)
}
  800179:	83 c4 14             	add    $0x14,%esp
  80017c:	5b                   	pop    %ebx
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800188:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018f:	00 00 00 
	b.cnt = 0;
  800192:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800199:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 40 01 80 00 	movl   $0x800140,(%esp)
  8001bb:	e8 82 01 00 00       	call   800342 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 d8 08 00 00       	call   800ab0 <sys_cputs>

	return b.cnt;
}
  8001d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 87 ff ff ff       	call   80017f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    
	...

008001fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	57                   	push   %edi
  800200:	56                   	push   %esi
  800201:	53                   	push   %ebx
  800202:	83 ec 3c             	sub    $0x3c,%esp
  800205:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800208:	89 d7                	mov    %edx,%edi
  80020a:	8b 45 08             	mov    0x8(%ebp),%eax
  80020d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800210:	8b 45 0c             	mov    0xc(%ebp),%eax
  800213:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800219:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021c:	85 c0                	test   %eax,%eax
  80021e:	75 08                	jne    800228 <printnum+0x2c>
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	39 45 10             	cmp    %eax,0x10(%ebp)
  800226:	77 57                	ja     80027f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800228:	89 74 24 10          	mov    %esi,0x10(%esp)
  80022c:	4b                   	dec    %ebx
  80022d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800231:	8b 45 10             	mov    0x10(%ebp),%eax
  800234:	89 44 24 08          	mov    %eax,0x8(%esp)
  800238:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80023c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800240:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800247:	00 
  800248:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024b:	89 04 24             	mov    %eax,(%esp)
  80024e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	e8 aa 0c 00 00       	call   800f04 <__udivdi3>
  80025a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80025e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	89 54 24 04          	mov    %edx,0x4(%esp)
  800269:	89 fa                	mov    %edi,%edx
  80026b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026e:	e8 89 ff ff ff       	call   8001fc <printnum>
  800273:	eb 0f                	jmp    800284 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800275:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800279:	89 34 24             	mov    %esi,(%esp)
  80027c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027f:	4b                   	dec    %ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f f1                	jg     800275 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800288:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80028c:	8b 45 10             	mov    0x10(%ebp),%eax
  80028f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800293:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029a:	00 
  80029b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029e:	89 04 24             	mov    %eax,(%esp)
  8002a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a8:	e8 77 0d 00 00       	call   801024 <__umoddi3>
  8002ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b1:	0f be 80 92 11 80 00 	movsbl 0x801192(%eax),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002be:	83 c4 3c             	add    $0x3c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	3b 50 04             	cmp    0x4(%eax),%edx
  80030e:	73 08                	jae    800318 <sprintputch+0x18>
		*b->buf++ = ch;
  800310:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800313:	88 0a                	mov    %cl,(%edx)
  800315:	42                   	inc    %edx
  800316:	89 10                	mov    %edx,(%eax)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800327:	8b 45 10             	mov    0x10(%ebp),%eax
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 02 00 00 00       	call   800342 <vprintfmt>
	va_end(ap);
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	57                   	push   %edi
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
  800348:	83 ec 4c             	sub    $0x4c,%esp
  80034b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034e:	8b 75 10             	mov    0x10(%ebp),%esi
  800351:	eb 12                	jmp    800365 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800353:	85 c0                	test   %eax,%eax
  800355:	0f 84 6b 03 00 00    	je     8006c6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80035b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80035f:	89 04 24             	mov    %eax,(%esp)
  800362:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800365:	0f b6 06             	movzbl (%esi),%eax
  800368:	46                   	inc    %esi
  800369:	83 f8 25             	cmp    $0x25,%eax
  80036c:	75 e5                	jne    800353 <vprintfmt+0x11>
  80036e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800372:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800379:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80037e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800385:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038a:	eb 26                	jmp    8003b2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800393:	eb 1d                	jmp    8003b2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800398:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80039c:	eb 14                	jmp    8003b2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003a8:	eb 08                	jmp    8003b2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003aa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	0f b6 06             	movzbl (%esi),%eax
  8003b5:	8d 56 01             	lea    0x1(%esi),%edx
  8003b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003bb:	8a 16                	mov    (%esi),%dl
  8003bd:	83 ea 23             	sub    $0x23,%edx
  8003c0:	80 fa 55             	cmp    $0x55,%dl
  8003c3:	0f 87 e1 02 00 00    	ja     8006aa <vprintfmt+0x368>
  8003c9:	0f b6 d2             	movzbl %dl,%edx
  8003cc:	ff 24 95 60 12 80 00 	jmp    *0x801260(,%edx,4)
  8003d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003d6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003db:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003de:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003e2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003e5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003e8:	83 fa 09             	cmp    $0x9,%edx
  8003eb:	77 2a                	ja     800417 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ed:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ee:	eb eb                	jmp    8003db <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003fe:	eb 17                	jmp    800417 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800400:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800404:	78 98                	js     80039e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800409:	eb a7                	jmp    8003b2 <vprintfmt+0x70>
  80040b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800415:	eb 9b                	jmp    8003b2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800417:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80041b:	79 95                	jns    8003b2 <vprintfmt+0x70>
  80041d:	eb 8b                	jmp    8003aa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800423:	eb 8d                	jmp    8003b2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	89 55 14             	mov    %edx,0x14(%ebp)
  80042e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800432:	8b 00                	mov    (%eax),%eax
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043d:	e9 23 ff ff ff       	jmp    800365 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	85 c0                	test   %eax,%eax
  80044f:	79 02                	jns    800453 <vprintfmt+0x111>
  800451:	f7 d8                	neg    %eax
  800453:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800455:	83 f8 08             	cmp    $0x8,%eax
  800458:	7f 0b                	jg     800465 <vprintfmt+0x123>
  80045a:	8b 04 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%eax
  800461:	85 c0                	test   %eax,%eax
  800463:	75 23                	jne    800488 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800465:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800469:	c7 44 24 08 aa 11 80 	movl   $0x8011aa,0x8(%esp)
  800470:	00 
  800471:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800475:	8b 45 08             	mov    0x8(%ebp),%eax
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	e8 9a fe ff ff       	call   80031a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800483:	e9 dd fe ff ff       	jmp    800365 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800488:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048c:	c7 44 24 08 b3 11 80 	movl   $0x8011b3,0x8(%esp)
  800493:	00 
  800494:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800498:	8b 55 08             	mov    0x8(%ebp),%edx
  80049b:	89 14 24             	mov    %edx,(%esp)
  80049e:	e8 77 fe ff ff       	call   80031a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004a6:	e9 ba fe ff ff       	jmp    800365 <vprintfmt+0x23>
  8004ab:	89 f9                	mov    %edi,%ecx
  8004ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 50 04             	lea    0x4(%eax),%edx
  8004b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bc:	8b 30                	mov    (%eax),%esi
  8004be:	85 f6                	test   %esi,%esi
  8004c0:	75 05                	jne    8004c7 <vprintfmt+0x185>
				p = "(null)";
  8004c2:	be a3 11 80 00       	mov    $0x8011a3,%esi
			if (width > 0 && padc != '-')
  8004c7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004cb:	0f 8e 84 00 00 00    	jle    800555 <vprintfmt+0x213>
  8004d1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004d5:	74 7e                	je     800555 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004db:	89 34 24             	mov    %esi,(%esp)
  8004de:	e8 8b 02 00 00       	call   80076e <strnlen>
  8004e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004e6:	29 c2                	sub    %eax,%edx
  8004e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004eb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004ef:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004f2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004f5:	89 de                	mov    %ebx,%esi
  8004f7:	89 d3                	mov    %edx,%ebx
  8004f9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	eb 0b                	jmp    800508 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800501:	89 3c 24             	mov    %edi,(%esp)
  800504:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800507:	4b                   	dec    %ebx
  800508:	85 db                	test   %ebx,%ebx
  80050a:	7f f1                	jg     8004fd <vprintfmt+0x1bb>
  80050c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80050f:	89 f3                	mov    %esi,%ebx
  800511:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800514:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800517:	85 c0                	test   %eax,%eax
  800519:	79 05                	jns    800520 <vprintfmt+0x1de>
  80051b:	b8 00 00 00 00       	mov    $0x0,%eax
  800520:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800523:	29 c2                	sub    %eax,%edx
  800525:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800528:	eb 2b                	jmp    800555 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80052e:	74 18                	je     800548 <vprintfmt+0x206>
  800530:	8d 50 e0             	lea    -0x20(%eax),%edx
  800533:	83 fa 5e             	cmp    $0x5e,%edx
  800536:	76 10                	jbe    800548 <vprintfmt+0x206>
					putch('?', putdat);
  800538:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800543:	ff 55 08             	call   *0x8(%ebp)
  800546:	eb 0a                	jmp    800552 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800548:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054c:	89 04 24             	mov    %eax,(%esp)
  80054f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800552:	ff 4d e4             	decl   -0x1c(%ebp)
  800555:	0f be 06             	movsbl (%esi),%eax
  800558:	46                   	inc    %esi
  800559:	85 c0                	test   %eax,%eax
  80055b:	74 21                	je     80057e <vprintfmt+0x23c>
  80055d:	85 ff                	test   %edi,%edi
  80055f:	78 c9                	js     80052a <vprintfmt+0x1e8>
  800561:	4f                   	dec    %edi
  800562:	79 c6                	jns    80052a <vprintfmt+0x1e8>
  800564:	8b 7d 08             	mov    0x8(%ebp),%edi
  800567:	89 de                	mov    %ebx,%esi
  800569:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80056c:	eb 18                	jmp    800586 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800572:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800579:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057b:	4b                   	dec    %ebx
  80057c:	eb 08                	jmp    800586 <vprintfmt+0x244>
  80057e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800581:	89 de                	mov    %ebx,%esi
  800583:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800586:	85 db                	test   %ebx,%ebx
  800588:	7f e4                	jg     80056e <vprintfmt+0x22c>
  80058a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80058d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800592:	e9 ce fd ff ff       	jmp    800365 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800597:	83 f9 01             	cmp    $0x1,%ecx
  80059a:	7e 10                	jle    8005ac <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 08             	lea    0x8(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 30                	mov    (%eax),%esi
  8005a7:	8b 78 04             	mov    0x4(%eax),%edi
  8005aa:	eb 26                	jmp    8005d2 <vprintfmt+0x290>
	else if (lflag)
  8005ac:	85 c9                	test   %ecx,%ecx
  8005ae:	74 12                	je     8005c2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 30                	mov    (%eax),%esi
  8005bb:	89 f7                	mov    %esi,%edi
  8005bd:	c1 ff 1f             	sar    $0x1f,%edi
  8005c0:	eb 10                	jmp    8005d2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 30                	mov    (%eax),%esi
  8005cd:	89 f7                	mov    %esi,%edi
  8005cf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005d2:	85 ff                	test   %edi,%edi
  8005d4:	78 0a                	js     8005e0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005db:	e9 8c 00 00 00       	jmp    80066c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005eb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ee:	f7 de                	neg    %esi
  8005f0:	83 d7 00             	adc    $0x0,%edi
  8005f3:	f7 df                	neg    %edi
			}
			base = 10;
  8005f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fa:	eb 70                	jmp    80066c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fc:	89 ca                	mov    %ecx,%edx
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 c0 fc ff ff       	call   8002c6 <getuint>
  800606:	89 c6                	mov    %eax,%esi
  800608:	89 d7                	mov    %edx,%edi
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80060f:	eb 5b                	jmp    80066c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800611:	89 ca                	mov    %ecx,%edx
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 ab fc ff ff       	call   8002c6 <getuint>
  80061b:	89 c6                	mov    %eax,%esi
  80061d:	89 d7                	mov    %edx,%edi
			base = 8;
  80061f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800624:	eb 46                	jmp    80066c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800626:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800631:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80063f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80064b:	8b 30                	mov    (%eax),%esi
  80064d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800652:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800657:	eb 13                	jmp    80066c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800659:	89 ca                	mov    %ecx,%edx
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 63 fc ff ff       	call   8002c6 <getuint>
  800663:	89 c6                	mov    %eax,%esi
  800665:	89 d7                	mov    %edx,%edi
			base = 16;
  800667:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80066c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800670:	89 54 24 10          	mov    %edx,0x10(%esp)
  800674:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800677:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80067b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80067f:	89 34 24             	mov    %esi,(%esp)
  800682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800686:	89 da                	mov    %ebx,%edx
  800688:	8b 45 08             	mov    0x8(%ebp),%eax
  80068b:	e8 6c fb ff ff       	call   8001fc <printnum>
			break;
  800690:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800693:	e9 cd fc ff ff       	jmp    800365 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069c:	89 04 24             	mov    %eax,(%esp)
  80069f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a5:	e9 bb fc ff ff       	jmp    800365 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b8:	eb 01                	jmp    8006bb <vprintfmt+0x379>
  8006ba:	4e                   	dec    %esi
  8006bb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006bf:	75 f9                	jne    8006ba <vprintfmt+0x378>
  8006c1:	e9 9f fc ff ff       	jmp    800365 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006c6:	83 c4 4c             	add    $0x4c,%esp
  8006c9:	5b                   	pop    %ebx
  8006ca:	5e                   	pop    %esi
  8006cb:	5f                   	pop    %edi
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 28             	sub    $0x28,%esp
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	74 30                	je     80071f <vsnprintf+0x51>
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	7e 33                	jle    800726 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800701:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800704:	89 44 24 04          	mov    %eax,0x4(%esp)
  800708:	c7 04 24 00 03 80 00 	movl   $0x800300,(%esp)
  80070f:	e8 2e fc ff ff       	call   800342 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800714:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800717:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071d:	eb 0c                	jmp    80072b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800724:	eb 05                	jmp    80072b <vsnprintf+0x5d>
  800726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    

0080072d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800736:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800741:	8b 45 0c             	mov    0xc(%ebp),%eax
  800744:	89 44 24 04          	mov    %eax,0x4(%esp)
  800748:	8b 45 08             	mov    0x8(%ebp),%eax
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	e8 7b ff ff ff       	call   8006ce <vsnprintf>
	va_end(ap);

	return rc;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    
  800755:	00 00                	add    %al,(%eax)
	...

00800758 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	b8 00 00 00 00       	mov    $0x0,%eax
  800763:	eb 01                	jmp    800766 <strlen+0xe>
		n++;
  800765:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076a:	75 f9                	jne    800765 <strlen+0xd>
		n++;
	return n;
}
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800774:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	b8 00 00 00 00       	mov    $0x0,%eax
  80077c:	eb 01                	jmp    80077f <strnlen+0x11>
		n++;
  80077e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	39 d0                	cmp    %edx,%eax
  800781:	74 06                	je     800789 <strnlen+0x1b>
  800783:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800787:	75 f5                	jne    80077e <strnlen+0x10>
		n++;
	return n;
}
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800795:	ba 00 00 00 00       	mov    $0x0,%edx
  80079a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80079d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007a0:	42                   	inc    %edx
  8007a1:	84 c9                	test   %cl,%cl
  8007a3:	75 f5                	jne    80079a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a5:	5b                   	pop    %ebx
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b2:	89 1c 24             	mov    %ebx,(%esp)
  8007b5:	e8 9e ff ff ff       	call   800758 <strlen>
	strcpy(dst + len, src);
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c1:	01 d8                	add    %ebx,%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	e8 c0 ff ff ff       	call   80078b <strcpy>
	return dst;
}
  8007cb:	89 d8                	mov    %ebx,%eax
  8007cd:	83 c4 08             	add    $0x8,%esp
  8007d0:	5b                   	pop    %ebx
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007de:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e6:	eb 0c                	jmp    8007f4 <strncpy+0x21>
		*dst++ = *src;
  8007e8:	8a 1a                	mov    (%edx),%bl
  8007ea:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ed:	80 3a 01             	cmpb   $0x1,(%edx)
  8007f0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f3:	41                   	inc    %ecx
  8007f4:	39 f1                	cmp    %esi,%ecx
  8007f6:	75 f0                	jne    8007e8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5e                   	pop    %esi
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	56                   	push   %esi
  800800:	53                   	push   %ebx
  800801:	8b 75 08             	mov    0x8(%ebp),%esi
  800804:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800807:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080a:	85 d2                	test   %edx,%edx
  80080c:	75 0a                	jne    800818 <strlcpy+0x1c>
  80080e:	89 f0                	mov    %esi,%eax
  800810:	eb 1a                	jmp    80082c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800812:	88 18                	mov    %bl,(%eax)
  800814:	40                   	inc    %eax
  800815:	41                   	inc    %ecx
  800816:	eb 02                	jmp    80081a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800818:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80081a:	4a                   	dec    %edx
  80081b:	74 0a                	je     800827 <strlcpy+0x2b>
  80081d:	8a 19                	mov    (%ecx),%bl
  80081f:	84 db                	test   %bl,%bl
  800821:	75 ef                	jne    800812 <strlcpy+0x16>
  800823:	89 c2                	mov    %eax,%edx
  800825:	eb 02                	jmp    800829 <strlcpy+0x2d>
  800827:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800829:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80082c:	29 f0                	sub    %esi,%eax
}
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083b:	eb 02                	jmp    80083f <strcmp+0xd>
		p++, q++;
  80083d:	41                   	inc    %ecx
  80083e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083f:	8a 01                	mov    (%ecx),%al
  800841:	84 c0                	test   %al,%al
  800843:	74 04                	je     800849 <strcmp+0x17>
  800845:	3a 02                	cmp    (%edx),%al
  800847:	74 f4                	je     80083d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	0f b6 12             	movzbl (%edx),%edx
  80084f:	29 d0                	sub    %edx,%eax
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800860:	eb 03                	jmp    800865 <strncmp+0x12>
		n--, p++, q++;
  800862:	4a                   	dec    %edx
  800863:	40                   	inc    %eax
  800864:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800865:	85 d2                	test   %edx,%edx
  800867:	74 14                	je     80087d <strncmp+0x2a>
  800869:	8a 18                	mov    (%eax),%bl
  80086b:	84 db                	test   %bl,%bl
  80086d:	74 04                	je     800873 <strncmp+0x20>
  80086f:	3a 19                	cmp    (%ecx),%bl
  800871:	74 ef                	je     800862 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 00             	movzbl (%eax),%eax
  800876:	0f b6 11             	movzbl (%ecx),%edx
  800879:	29 d0                	sub    %edx,%eax
  80087b:	eb 05                	jmp    800882 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800882:	5b                   	pop    %ebx
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088e:	eb 05                	jmp    800895 <strchr+0x10>
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	74 0c                	je     8008a0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800894:	40                   	inc    %eax
  800895:	8a 10                	mov    (%eax),%dl
  800897:	84 d2                	test   %dl,%dl
  800899:	75 f5                	jne    800890 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ab:	eb 05                	jmp    8008b2 <strfind+0x10>
		if (*s == c)
  8008ad:	38 ca                	cmp    %cl,%dl
  8008af:	74 07                	je     8008b8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b1:	40                   	inc    %eax
  8008b2:	8a 10                	mov    (%eax),%dl
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	75 f5                	jne    8008ad <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	57                   	push   %edi
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c9:	85 c9                	test   %ecx,%ecx
  8008cb:	74 30                	je     8008fd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d3:	75 25                	jne    8008fa <memset+0x40>
  8008d5:	f6 c1 03             	test   $0x3,%cl
  8008d8:	75 20                	jne    8008fa <memset+0x40>
		c &= 0xFF;
  8008da:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dd:	89 d3                	mov    %edx,%ebx
  8008df:	c1 e3 08             	shl    $0x8,%ebx
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	c1 e6 18             	shl    $0x18,%esi
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	c1 e0 10             	shl    $0x10,%eax
  8008ec:	09 f0                	or     %esi,%eax
  8008ee:	09 d0                	or     %edx,%eax
  8008f0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f5:	fc                   	cld    
  8008f6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f8:	eb 03                	jmp    8008fd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fa:	fc                   	cld    
  8008fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fd:	89 f8                	mov    %edi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	57                   	push   %edi
  800908:	56                   	push   %esi
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800912:	39 c6                	cmp    %eax,%esi
  800914:	73 34                	jae    80094a <memmove+0x46>
  800916:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800919:	39 d0                	cmp    %edx,%eax
  80091b:	73 2d                	jae    80094a <memmove+0x46>
		s += n;
		d += n;
  80091d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800920:	f6 c2 03             	test   $0x3,%dl
  800923:	75 1b                	jne    800940 <memmove+0x3c>
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 13                	jne    800940 <memmove+0x3c>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0e                	jne    800940 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800932:	83 ef 04             	sub    $0x4,%edi
  800935:	8d 72 fc             	lea    -0x4(%edx),%esi
  800938:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80093b:	fd                   	std    
  80093c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 07                	jmp    800947 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800940:	4f                   	dec    %edi
  800941:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800944:	fd                   	std    
  800945:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800947:	fc                   	cld    
  800948:	eb 20                	jmp    80096a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800950:	75 13                	jne    800965 <memmove+0x61>
  800952:	a8 03                	test   $0x3,%al
  800954:	75 0f                	jne    800965 <memmove+0x61>
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 0a                	jne    800965 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80095b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80095e:	89 c7                	mov    %eax,%edi
  800960:	fc                   	cld    
  800961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800963:	eb 05                	jmp    80096a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800965:	89 c7                	mov    %eax,%edi
  800967:	fc                   	cld    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800974:	8b 45 10             	mov    0x10(%ebp),%eax
  800977:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 77 ff ff ff       	call   800904 <memmove>
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	57                   	push   %edi
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 7d 08             	mov    0x8(%ebp),%edi
  800998:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099e:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a3:	eb 16                	jmp    8009bb <memcmp+0x2c>
		if (*s1 != *s2)
  8009a5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009a8:	42                   	inc    %edx
  8009a9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009ad:	38 c8                	cmp    %cl,%al
  8009af:	74 0a                	je     8009bb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009b1:	0f b6 c0             	movzbl %al,%eax
  8009b4:	0f b6 c9             	movzbl %cl,%ecx
  8009b7:	29 c8                	sub    %ecx,%eax
  8009b9:	eb 09                	jmp    8009c4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bb:	39 da                	cmp    %ebx,%edx
  8009bd:	75 e6                	jne    8009a5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d2:	89 c2                	mov    %eax,%edx
  8009d4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d7:	eb 05                	jmp    8009de <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d9:	38 08                	cmp    %cl,(%eax)
  8009db:	74 05                	je     8009e2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009dd:	40                   	inc    %eax
  8009de:	39 d0                	cmp    %edx,%eax
  8009e0:	72 f7                	jb     8009d9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f0:	eb 01                	jmp    8009f3 <strtol+0xf>
		s++;
  8009f2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f3:	8a 02                	mov    (%edx),%al
  8009f5:	3c 20                	cmp    $0x20,%al
  8009f7:	74 f9                	je     8009f2 <strtol+0xe>
  8009f9:	3c 09                	cmp    $0x9,%al
  8009fb:	74 f5                	je     8009f2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fd:	3c 2b                	cmp    $0x2b,%al
  8009ff:	75 08                	jne    800a09 <strtol+0x25>
		s++;
  800a01:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
  800a07:	eb 13                	jmp    800a1c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a09:	3c 2d                	cmp    $0x2d,%al
  800a0b:	75 0a                	jne    800a17 <strtol+0x33>
		s++, neg = 1;
  800a0d:	8d 52 01             	lea    0x1(%edx),%edx
  800a10:	bf 01 00 00 00       	mov    $0x1,%edi
  800a15:	eb 05                	jmp    800a1c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1c:	85 db                	test   %ebx,%ebx
  800a1e:	74 05                	je     800a25 <strtol+0x41>
  800a20:	83 fb 10             	cmp    $0x10,%ebx
  800a23:	75 28                	jne    800a4d <strtol+0x69>
  800a25:	8a 02                	mov    (%edx),%al
  800a27:	3c 30                	cmp    $0x30,%al
  800a29:	75 10                	jne    800a3b <strtol+0x57>
  800a2b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a2f:	75 0a                	jne    800a3b <strtol+0x57>
		s += 2, base = 16;
  800a31:	83 c2 02             	add    $0x2,%edx
  800a34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a39:	eb 12                	jmp    800a4d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	75 0e                	jne    800a4d <strtol+0x69>
  800a3f:	3c 30                	cmp    $0x30,%al
  800a41:	75 05                	jne    800a48 <strtol+0x64>
		s++, base = 8;
  800a43:	42                   	inc    %edx
  800a44:	b3 08                	mov    $0x8,%bl
  800a46:	eb 05                	jmp    800a4d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a48:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a54:	8a 0a                	mov    (%edx),%cl
  800a56:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a59:	80 fb 09             	cmp    $0x9,%bl
  800a5c:	77 08                	ja     800a66 <strtol+0x82>
			dig = *s - '0';
  800a5e:	0f be c9             	movsbl %cl,%ecx
  800a61:	83 e9 30             	sub    $0x30,%ecx
  800a64:	eb 1e                	jmp    800a84 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a66:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a69:	80 fb 19             	cmp    $0x19,%bl
  800a6c:	77 08                	ja     800a76 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a6e:	0f be c9             	movsbl %cl,%ecx
  800a71:	83 e9 57             	sub    $0x57,%ecx
  800a74:	eb 0e                	jmp    800a84 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a76:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 12                	ja     800a90 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a7e:	0f be c9             	movsbl %cl,%ecx
  800a81:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a84:	39 f1                	cmp    %esi,%ecx
  800a86:	7d 0c                	jge    800a94 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a88:	42                   	inc    %edx
  800a89:	0f af c6             	imul   %esi,%eax
  800a8c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a8e:	eb c4                	jmp    800a54 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a90:	89 c1                	mov    %eax,%ecx
  800a92:	eb 02                	jmp    800a96 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a94:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9a:	74 05                	je     800aa1 <strtol+0xbd>
		*endptr = (char *) s;
  800a9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a9f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800aa1:	85 ff                	test   %edi,%edi
  800aa3:	74 04                	je     800aa9 <strtol+0xc5>
  800aa5:	89 c8                	mov    %ecx,%eax
  800aa7:	f7 d8                	neg    %eax
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    
	...

00800ab0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac1:	89 c3                	mov    %eax,%ebx
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	89 c6                	mov    %eax,%esi
  800ac7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <sys_cgetc>:

int
sys_cgetc(void)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ade:	89 d1                	mov    %edx,%ecx
  800ae0:	89 d3                	mov    %edx,%ebx
  800ae2:	89 d7                	mov    %edx,%edi
  800ae4:	89 d6                	mov    %edx,%esi
  800ae6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afb:	b8 03 00 00 00       	mov    $0x3,%eax
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	89 cb                	mov    %ecx,%ebx
  800b05:	89 cf                	mov    %ecx,%edi
  800b07:	89 ce                	mov    %ecx,%esi
  800b09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	7e 28                	jle    800b37 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b13:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b1a:	00 
  800b1b:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800b22:	00 
  800b23:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b2a:	00 
  800b2b:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800b32:	e8 75 03 00 00       	call   800eac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b37:	83 c4 2c             	add    $0x2c,%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4f:	89 d1                	mov    %edx,%ecx
  800b51:	89 d3                	mov    %edx,%ebx
  800b53:	89 d7                	mov    %edx,%edi
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_yield>:

void
sys_yield(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	be 00 00 00 00       	mov    $0x0,%esi
  800b8b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 f7                	mov    %esi,%edi
  800b9b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 28                	jle    800bc9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bac:	00 
  800bad:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800bb4:	00 
  800bb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bbc:	00 
  800bbd:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800bc4:	e8 e3 02 00 00       	call   800eac <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc9:	83 c4 2c             	add    $0x2c,%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdf:	8b 75 18             	mov    0x18(%ebp),%esi
  800be2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	7e 28                	jle    800c1c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bff:	00 
  800c00:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800c07:	00 
  800c08:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0f:	00 
  800c10:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800c17:	e8 90 02 00 00       	call   800eac <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1c:	83 c4 2c             	add    $0x2c,%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	b8 06 00 00 00       	mov    $0x6,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 28                	jle    800c6f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c52:	00 
  800c53:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800c5a:	00 
  800c5b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c62:	00 
  800c63:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800c6a:	e8 3d 02 00 00       	call   800eac <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6f:	83 c4 2c             	add    $0x2c,%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c85:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 df                	mov    %ebx,%edi
  800c92:	89 de                	mov    %ebx,%esi
  800c94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7e 28                	jle    800cc2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ca5:	00 
  800ca6:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800cad:	00 
  800cae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb5:	00 
  800cb6:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800cbd:	e8 ea 01 00 00       	call   800eac <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc2:	83 c4 2c             	add    $0x2c,%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 28                	jle    800d15 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cf8:	00 
  800cf9:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800d00:	00 
  800d01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d08:	00 
  800d09:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800d10:	e8 97 01 00 00       	call   800eac <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d15:	83 c4 2c             	add    $0x2c,%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	be 00 00 00 00       	mov    $0x0,%esi
  800d28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 cb                	mov    %ecx,%ebx
  800d58:	89 cf                	mov    %ecx,%edi
  800d5a:	89 ce                	mov    %ecx,%esi
  800d5c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 28                	jle    800d8a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d66:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d6d:	00 
  800d6e:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800d75:	00 
  800d76:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7d:	00 
  800d7e:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800d85:	e8 22 01 00 00       	call   800eac <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8a:	83 c4 2c             	add    $0x2c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
	...

00800d94 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 10             	sub    $0x10,%esp
  800d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	
	if (pg==NULL)pg=(void *)UTOP;
  800da5:	85 c0                	test   %eax,%eax
  800da7:	75 05                	jne    800dae <ipc_recv+0x1a>
  800da9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  800dae:	89 04 24             	mov    %eax,(%esp)
  800db1:	e8 8a ff ff ff       	call   800d40 <sys_ipc_recv>
	// cprintf("%x\n",err);
	if (err < 0){
  800db6:	85 c0                	test   %eax,%eax
  800db8:	79 16                	jns    800dd0 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  800dba:	85 db                	test   %ebx,%ebx
  800dbc:	74 06                	je     800dc4 <ipc_recv+0x30>
  800dbe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  800dc4:	85 f6                	test   %esi,%esi
  800dc6:	74 32                	je     800dfa <ipc_recv+0x66>
  800dc8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800dce:	eb 2a                	jmp    800dfa <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  800dd0:	85 db                	test   %ebx,%ebx
  800dd2:	74 0c                	je     800de0 <ipc_recv+0x4c>
  800dd4:	a1 04 20 80 00       	mov    0x802004,%eax
  800dd9:	8b 00                	mov    (%eax),%eax
  800ddb:	8b 40 74             	mov    0x74(%eax),%eax
  800dde:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  800de0:	85 f6                	test   %esi,%esi
  800de2:	74 0c                	je     800df0 <ipc_recv+0x5c>
  800de4:	a1 04 20 80 00       	mov    0x802004,%eax
  800de9:	8b 00                	mov    (%eax),%eax
  800deb:	8b 40 78             	mov    0x78(%eax),%eax
  800dee:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  800df0:	a1 04 20 80 00       	mov    0x802004,%eax
  800df5:	8b 00                	mov    (%eax),%eax
  800df7:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 1c             	sub    $0x1c,%esp
  800e0a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e10:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  800e13:	85 db                	test   %ebx,%ebx
  800e15:	75 05                	jne    800e1c <ipc_send+0x1b>
  800e17:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  800e1c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e20:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e24:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	89 04 24             	mov    %eax,(%esp)
  800e2e:	e8 ea fe ff ff       	call   800d1d <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  800e33:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e36:	75 07                	jne    800e3f <ipc_send+0x3e>
  800e38:	e8 21 fd ff ff       	call   800b5e <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  800e3d:	eb dd                	jmp    800e1c <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	79 1c                	jns    800e5f <ipc_send+0x5e>
  800e43:	c7 44 24 08 0f 14 80 	movl   $0x80140f,0x8(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800e52:	00 
  800e53:	c7 04 24 21 14 80 00 	movl   $0x801421,(%esp)
  800e5a:	e8 4d 00 00 00       	call   800eac <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  800e5f:	83 c4 1c             	add    $0x1c,%esp
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	53                   	push   %ebx
  800e6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800e6e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e73:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	c1 e2 07             	shl    $0x7,%edx
  800e7f:	29 ca                	sub    %ecx,%edx
  800e81:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e87:	8b 52 50             	mov    0x50(%edx),%edx
  800e8a:	39 da                	cmp    %ebx,%edx
  800e8c:	75 0f                	jne    800e9d <ipc_find_env+0x36>
			return envs[i].env_id;
  800e8e:	c1 e0 07             	shl    $0x7,%eax
  800e91:	29 c8                	sub    %ecx,%eax
  800e93:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800e98:	8b 40 40             	mov    0x40(%eax),%eax
  800e9b:	eb 0c                	jmp    800ea9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e9d:	40                   	inc    %eax
  800e9e:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ea3:	75 ce                	jne    800e73 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800ea5:	66 b8 00 00          	mov    $0x0,%ax
}
  800ea9:	5b                   	pop    %ebx
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800eb4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800eb7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ebd:	e8 7d fc ff ff       	call   800b3f <sys_getenvid>
  800ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ed0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed8:	c7 04 24 2c 14 80 00 	movl   $0x80142c,(%esp)
  800edf:	e8 fc f2 ff ff       	call   8001e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ee4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee8:	8b 45 10             	mov    0x10(%ebp),%eax
  800eeb:	89 04 24             	mov    %eax,(%esp)
  800eee:	e8 8c f2 ff ff       	call   80017f <vcprintf>
	cprintf("\n");
  800ef3:	c7 04 24 1f 14 80 00 	movl   $0x80141f,(%esp)
  800efa:	e8 e1 f2 ff ff       	call   8001e0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800eff:	cc                   	int3   
  800f00:	eb fd                	jmp    800eff <_panic+0x53>
	...

00800f04 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800f04:	55                   	push   %ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	83 ec 10             	sub    $0x10,%esp
  800f0a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800f0e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f12:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f16:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800f1a:	89 cd                	mov    %ecx,%ebp
  800f1c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	75 2c                	jne    800f50 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800f24:	39 f9                	cmp    %edi,%ecx
  800f26:	77 68                	ja     800f90 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f28:	85 c9                	test   %ecx,%ecx
  800f2a:	75 0b                	jne    800f37 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f31:	31 d2                	xor    %edx,%edx
  800f33:	f7 f1                	div    %ecx
  800f35:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f37:	31 d2                	xor    %edx,%edx
  800f39:	89 f8                	mov    %edi,%eax
  800f3b:	f7 f1                	div    %ecx
  800f3d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f3f:	89 f0                	mov    %esi,%eax
  800f41:	f7 f1                	div    %ecx
  800f43:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f45:	89 f0                	mov    %esi,%eax
  800f47:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f49:	83 c4 10             	add    $0x10,%esp
  800f4c:	5e                   	pop    %esi
  800f4d:	5f                   	pop    %edi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f50:	39 f8                	cmp    %edi,%eax
  800f52:	77 2c                	ja     800f80 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f54:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800f57:	83 f6 1f             	xor    $0x1f,%esi
  800f5a:	75 4c                	jne    800fa8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f5c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f5e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f63:	72 0a                	jb     800f6f <__udivdi3+0x6b>
  800f65:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f69:	0f 87 ad 00 00 00    	ja     80101c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f6f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f74:	89 f0                	mov    %esi,%eax
  800f76:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    
  800f7f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f80:	31 ff                	xor    %edi,%edi
  800f82:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f84:	89 f0                	mov    %esi,%eax
  800f86:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	5e                   	pop    %esi
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    
  800f8f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f90:	89 fa                	mov    %edi,%edx
  800f92:	89 f0                	mov    %esi,%eax
  800f94:	f7 f1                	div    %ecx
  800f96:	89 c6                	mov    %eax,%esi
  800f98:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f9a:	89 f0                	mov    %esi,%eax
  800f9c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
  800fa5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fa8:	89 f1                	mov    %esi,%ecx
  800faa:	d3 e0                	shl    %cl,%eax
  800fac:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fb0:	b8 20 00 00 00       	mov    $0x20,%eax
  800fb5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800fb7:	89 ea                	mov    %ebp,%edx
  800fb9:	88 c1                	mov    %al,%cl
  800fbb:	d3 ea                	shr    %cl,%edx
  800fbd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800fc1:	09 ca                	or     %ecx,%edx
  800fc3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800fc7:	89 f1                	mov    %esi,%ecx
  800fc9:	d3 e5                	shl    %cl,%ebp
  800fcb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800fcf:	89 fd                	mov    %edi,%ebp
  800fd1:	88 c1                	mov    %al,%cl
  800fd3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800fd5:	89 fa                	mov    %edi,%edx
  800fd7:	89 f1                	mov    %esi,%ecx
  800fd9:	d3 e2                	shl    %cl,%edx
  800fdb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fdf:	88 c1                	mov    %al,%cl
  800fe1:	d3 ef                	shr    %cl,%edi
  800fe3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fe5:	89 f8                	mov    %edi,%eax
  800fe7:	89 ea                	mov    %ebp,%edx
  800fe9:	f7 74 24 08          	divl   0x8(%esp)
  800fed:	89 d1                	mov    %edx,%ecx
  800fef:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800ff1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ff5:	39 d1                	cmp    %edx,%ecx
  800ff7:	72 17                	jb     801010 <__udivdi3+0x10c>
  800ff9:	74 09                	je     801004 <__udivdi3+0x100>
  800ffb:	89 fe                	mov    %edi,%esi
  800ffd:	31 ff                	xor    %edi,%edi
  800fff:	e9 41 ff ff ff       	jmp    800f45 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801004:	8b 54 24 04          	mov    0x4(%esp),%edx
  801008:	89 f1                	mov    %esi,%ecx
  80100a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80100c:	39 c2                	cmp    %eax,%edx
  80100e:	73 eb                	jae    800ffb <__udivdi3+0xf7>
		{
		  q0--;
  801010:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801013:	31 ff                	xor    %edi,%edi
  801015:	e9 2b ff ff ff       	jmp    800f45 <__udivdi3+0x41>
  80101a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80101c:	31 f6                	xor    %esi,%esi
  80101e:	e9 22 ff ff ff       	jmp    800f45 <__udivdi3+0x41>
	...

00801024 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801024:	55                   	push   %ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	83 ec 20             	sub    $0x20,%esp
  80102a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80102e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801032:	89 44 24 14          	mov    %eax,0x14(%esp)
  801036:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80103a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80103e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801042:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801044:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801046:	85 ed                	test   %ebp,%ebp
  801048:	75 16                	jne    801060 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80104a:	39 f1                	cmp    %esi,%ecx
  80104c:	0f 86 a6 00 00 00    	jbe    8010f8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801052:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801054:	89 d0                	mov    %edx,%eax
  801056:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	5e                   	pop    %esi
  80105c:	5f                   	pop    %edi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    
  80105f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801060:	39 f5                	cmp    %esi,%ebp
  801062:	0f 87 ac 00 00 00    	ja     801114 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801068:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80106b:	83 f0 1f             	xor    $0x1f,%eax
  80106e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801072:	0f 84 a8 00 00 00    	je     801120 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801078:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80107c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80107e:	bf 20 00 00 00       	mov    $0x20,%edi
  801083:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801087:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80108b:	89 f9                	mov    %edi,%ecx
  80108d:	d3 e8                	shr    %cl,%eax
  80108f:	09 e8                	or     %ebp,%eax
  801091:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801095:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801099:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80109d:	d3 e0                	shl    %cl,%eax
  80109f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8010a3:	89 f2                	mov    %esi,%edx
  8010a5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8010a7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010ab:	d3 e0                	shl    %cl,%eax
  8010ad:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8010b1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010b5:	89 f9                	mov    %edi,%ecx
  8010b7:	d3 e8                	shr    %cl,%eax
  8010b9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8010bb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8010bd:	89 f2                	mov    %esi,%edx
  8010bf:	f7 74 24 18          	divl   0x18(%esp)
  8010c3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8010c5:	f7 64 24 0c          	mull   0xc(%esp)
  8010c9:	89 c5                	mov    %eax,%ebp
  8010cb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010cd:	39 d6                	cmp    %edx,%esi
  8010cf:	72 67                	jb     801138 <__umoddi3+0x114>
  8010d1:	74 75                	je     801148 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8010d3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010d7:	29 e8                	sub    %ebp,%eax
  8010d9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010db:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010df:	d3 e8                	shr    %cl,%eax
  8010e1:	89 f2                	mov    %esi,%edx
  8010e3:	89 f9                	mov    %edi,%ecx
  8010e5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8010e7:	09 d0                	or     %edx,%eax
  8010e9:	89 f2                	mov    %esi,%edx
  8010eb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010ef:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010f1:	83 c4 20             	add    $0x20,%esp
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010f8:	85 c9                	test   %ecx,%ecx
  8010fa:	75 0b                	jne    801107 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8010fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801101:	31 d2                	xor    %edx,%edx
  801103:	f7 f1                	div    %ecx
  801105:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801107:	89 f0                	mov    %esi,%eax
  801109:	31 d2                	xor    %edx,%edx
  80110b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80110d:	89 f8                	mov    %edi,%eax
  80110f:	e9 3e ff ff ff       	jmp    801052 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801114:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801116:	83 c4 20             	add    $0x20,%esp
  801119:	5e                   	pop    %esi
  80111a:	5f                   	pop    %edi
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    
  80111d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801120:	39 f5                	cmp    %esi,%ebp
  801122:	72 04                	jb     801128 <__umoddi3+0x104>
  801124:	39 f9                	cmp    %edi,%ecx
  801126:	77 06                	ja     80112e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801128:	89 f2                	mov    %esi,%edx
  80112a:	29 cf                	sub    %ecx,%edi
  80112c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80112e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801130:	83 c4 20             	add    $0x20,%esp
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    
  801137:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801138:	89 d1                	mov    %edx,%ecx
  80113a:	89 c5                	mov    %eax,%ebp
  80113c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801140:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801144:	eb 8d                	jmp    8010d3 <__umoddi3+0xaf>
  801146:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801148:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80114c:	72 ea                	jb     801138 <__umoddi3+0x114>
  80114e:	89 f1                	mov    %esi,%ecx
  801150:	eb 81                	jmp    8010d3 <__umoddi3+0xaf>
