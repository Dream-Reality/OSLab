
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	83 ec 20             	sub    $0x20,%esp
  800044:	8b 75 08             	mov    0x8(%ebp),%esi
  800047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80004a:	e8 68 0a 00 00       	call   800ab7 <sys_getenvid>
  80004f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800054:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005b:	c1 e0 07             	shl    $0x7,%eax
  80005e:	29 d0                	sub    %edx,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800068:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  800074:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  80007b:	e8 d8 00 00 00       	call   800158 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 f6                	test   %esi,%esi
  800082:	7e 07                	jle    80008b <libmain+0x4f>
		binaryname = argv[0];
  800084:	8b 03                	mov    (%ebx),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008f:	89 34 24             	mov    %esi,(%esp)
  800092:	e8 9d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800097:	e8 08 00 00 00       	call   8000a4 <exit>
}
  80009c:	83 c4 20             	add    $0x20,%esp
  80009f:	5b                   	pop    %ebx
  8000a0:	5e                   	pop    %esi
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 af 09 00 00       	call   800a65 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 14             	sub    $0x14,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 03                	mov    (%ebx),%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cb:	40                   	inc    %eax
  8000cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	75 19                	jne    8000ee <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000d5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000dc:	00 
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	89 04 24             	mov    %eax,(%esp)
  8000e3:	e8 40 09 00 00       	call   800a28 <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000ee:	ff 43 04             	incl   0x4(%ebx)
}
  8000f1:	83 c4 14             	add    $0x14,%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800100:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800107:	00 00 00 
	b.cnt = 0;
  80010a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800111:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800114:	8b 45 0c             	mov    0xc(%ebp),%eax
  800117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011b:	8b 45 08             	mov    0x8(%ebp),%eax
  80011e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800122:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012c:	c7 04 24 b8 00 80 00 	movl   $0x8000b8,(%esp)
  800133:	e8 82 01 00 00       	call   8002ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800138:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800142:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800148:	89 04 24             	mov    %eax,(%esp)
  80014b:	e8 d8 08 00 00       	call   800a28 <sys_cputs>

	return b.cnt;
}
  800150:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800161:	89 44 24 04          	mov    %eax,0x4(%esp)
  800165:	8b 45 08             	mov    0x8(%ebp),%eax
  800168:	89 04 24             	mov    %eax,(%esp)
  80016b:	e8 87 ff ff ff       	call   8000f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800170:	c9                   	leave  
  800171:	c3                   	ret    
	...

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 3c             	sub    $0x3c,%esp
  80017d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800180:	89 d7                	mov    %edx,%edi
  800182:	8b 45 08             	mov    0x8(%ebp),%eax
  800185:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800191:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800194:	85 c0                	test   %eax,%eax
  800196:	75 08                	jne    8001a0 <printnum+0x2c>
  800198:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80019b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019e:	77 57                	ja     8001f7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001a4:	4b                   	dec    %ebx
  8001a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001b4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001bf:	00 
  8001c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	e8 92 0b 00 00       	call   800d64 <__udivdi3>
  8001d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001da:	89 04 24             	mov    %eax,(%esp)
  8001dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e1:	89 fa                	mov    %edi,%edx
  8001e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001e6:	e8 89 ff ff ff       	call   800174 <printnum>
  8001eb:	eb 0f                	jmp    8001fc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f1:	89 34 24             	mov    %esi,(%esp)
  8001f4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f7:	4b                   	dec    %ebx
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7f f1                	jg     8001ed <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800200:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800204:	8b 45 10             	mov    0x10(%ebp),%eax
  800207:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800212:	00 
  800213:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800216:	89 04 24             	mov    %eax,(%esp)
  800219:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	e8 5f 0c 00 00       	call   800e84 <__umoddi3>
  800225:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800229:	0f be 80 ce 0f 80 00 	movsbl 0x800fce(%eax),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800236:	83 c4 3c             	add    $0x3c,%esp
  800239:	5b                   	pop    %ebx
  80023a:	5e                   	pop    %esi
  80023b:	5f                   	pop    %edi
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800241:	83 fa 01             	cmp    $0x1,%edx
  800244:	7e 0e                	jle    800254 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800246:	8b 10                	mov    (%eax),%edx
  800248:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024b:	89 08                	mov    %ecx,(%eax)
  80024d:	8b 02                	mov    (%edx),%eax
  80024f:	8b 52 04             	mov    0x4(%edx),%edx
  800252:	eb 22                	jmp    800276 <getuint+0x38>
	else if (lflag)
  800254:	85 d2                	test   %edx,%edx
  800256:	74 10                	je     800268 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	ba 00 00 00 00       	mov    $0x0,%edx
  800266:	eb 0e                	jmp    800276 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800281:	8b 10                	mov    (%eax),%edx
  800283:	3b 50 04             	cmp    0x4(%eax),%edx
  800286:	73 08                	jae    800290 <sprintputch+0x18>
		*b->buf++ = ch;
  800288:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028b:	88 0a                	mov    %cl,(%edx)
  80028d:	42                   	inc    %edx
  80028e:	89 10                	mov    %edx,(%eax)
}
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800298:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029f:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 02 00 00 00       	call   8002ba <vprintfmt>
	va_end(ap);
}
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	57                   	push   %edi
  8002be:	56                   	push   %esi
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 4c             	sub    $0x4c,%esp
  8002c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c6:	8b 75 10             	mov    0x10(%ebp),%esi
  8002c9:	eb 12                	jmp    8002dd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	0f 84 6b 03 00 00    	je     80063e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002dd:	0f b6 06             	movzbl (%esi),%eax
  8002e0:	46                   	inc    %esi
  8002e1:	83 f8 25             	cmp    $0x25,%eax
  8002e4:	75 e5                	jne    8002cb <vprintfmt+0x11>
  8002e6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002ea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800302:	eb 26                	jmp    80032a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800307:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80030b:	eb 1d                	jmp    80032a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800310:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800314:	eb 14                	jmp    80032a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800319:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800320:	eb 08                	jmp    80032a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800322:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800325:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	0f b6 06             	movzbl (%esi),%eax
  80032d:	8d 56 01             	lea    0x1(%esi),%edx
  800330:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800333:	8a 16                	mov    (%esi),%dl
  800335:	83 ea 23             	sub    $0x23,%edx
  800338:	80 fa 55             	cmp    $0x55,%dl
  80033b:	0f 87 e1 02 00 00    	ja     800622 <vprintfmt+0x368>
  800341:	0f b6 d2             	movzbl %dl,%edx
  800344:	ff 24 95 a0 10 80 00 	jmp    *0x8010a0(,%edx,4)
  80034b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80034e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800353:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800356:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80035a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80035d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800360:	83 fa 09             	cmp    $0x9,%edx
  800363:	77 2a                	ja     80038f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800365:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800366:	eb eb                	jmp    800353 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8d 50 04             	lea    0x4(%eax),%edx
  80036e:	89 55 14             	mov    %edx,0x14(%ebp)
  800371:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800376:	eb 17                	jmp    80038f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800378:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80037c:	78 98                	js     800316 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800381:	eb a7                	jmp    80032a <vprintfmt+0x70>
  800383:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800386:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80038d:	eb 9b                	jmp    80032a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80038f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800393:	79 95                	jns    80032a <vprintfmt+0x70>
  800395:	eb 8b                	jmp    800322 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800397:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80039b:	eb 8d                	jmp    80032a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 50 04             	lea    0x4(%eax),%edx
  8003a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003aa:	8b 00                	mov    (%eax),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b5:	e9 23 ff ff ff       	jmp    8002dd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 50 04             	lea    0x4(%eax),%edx
  8003c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c3:	8b 00                	mov    (%eax),%eax
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	79 02                	jns    8003cb <vprintfmt+0x111>
  8003c9:	f7 d8                	neg    %eax
  8003cb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003cd:	83 f8 08             	cmp    $0x8,%eax
  8003d0:	7f 0b                	jg     8003dd <vprintfmt+0x123>
  8003d2:	8b 04 85 00 12 80 00 	mov    0x801200(,%eax,4),%eax
  8003d9:	85 c0                	test   %eax,%eax
  8003db:	75 23                	jne    800400 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e1:	c7 44 24 08 e6 0f 80 	movl   $0x800fe6,0x8(%esp)
  8003e8:	00 
  8003e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	89 04 24             	mov    %eax,(%esp)
  8003f3:	e8 9a fe ff ff       	call   800292 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003fb:	e9 dd fe ff ff       	jmp    8002dd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800400:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800404:	c7 44 24 08 ef 0f 80 	movl   $0x800fef,0x8(%esp)
  80040b:	00 
  80040c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800410:	8b 55 08             	mov    0x8(%ebp),%edx
  800413:	89 14 24             	mov    %edx,(%esp)
  800416:	e8 77 fe ff ff       	call   800292 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80041e:	e9 ba fe ff ff       	jmp    8002dd <vprintfmt+0x23>
  800423:	89 f9                	mov    %edi,%ecx
  800425:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800428:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 50 04             	lea    0x4(%eax),%edx
  800431:	89 55 14             	mov    %edx,0x14(%ebp)
  800434:	8b 30                	mov    (%eax),%esi
  800436:	85 f6                	test   %esi,%esi
  800438:	75 05                	jne    80043f <vprintfmt+0x185>
				p = "(null)";
  80043a:	be df 0f 80 00       	mov    $0x800fdf,%esi
			if (width > 0 && padc != '-')
  80043f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800443:	0f 8e 84 00 00 00    	jle    8004cd <vprintfmt+0x213>
  800449:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80044d:	74 7e                	je     8004cd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800453:	89 34 24             	mov    %esi,(%esp)
  800456:	e8 8b 02 00 00       	call   8006e6 <strnlen>
  80045b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80045e:	29 c2                	sub    %eax,%edx
  800460:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800463:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800467:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80046a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80046d:	89 de                	mov    %ebx,%esi
  80046f:	89 d3                	mov    %edx,%ebx
  800471:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	eb 0b                	jmp    800480 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800475:	89 74 24 04          	mov    %esi,0x4(%esp)
  800479:	89 3c 24             	mov    %edi,(%esp)
  80047c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	4b                   	dec    %ebx
  800480:	85 db                	test   %ebx,%ebx
  800482:	7f f1                	jg     800475 <vprintfmt+0x1bb>
  800484:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800487:	89 f3                	mov    %esi,%ebx
  800489:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80048c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80048f:	85 c0                	test   %eax,%eax
  800491:	79 05                	jns    800498 <vprintfmt+0x1de>
  800493:	b8 00 00 00 00       	mov    $0x0,%eax
  800498:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049b:	29 c2                	sub    %eax,%edx
  80049d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004a0:	eb 2b                	jmp    8004cd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004a6:	74 18                	je     8004c0 <vprintfmt+0x206>
  8004a8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ab:	83 fa 5e             	cmp    $0x5e,%edx
  8004ae:	76 10                	jbe    8004c0 <vprintfmt+0x206>
					putch('?', putdat);
  8004b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004bb:	ff 55 08             	call   *0x8(%ebp)
  8004be:	eb 0a                	jmp    8004ca <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	ff 4d e4             	decl   -0x1c(%ebp)
  8004cd:	0f be 06             	movsbl (%esi),%eax
  8004d0:	46                   	inc    %esi
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 21                	je     8004f6 <vprintfmt+0x23c>
  8004d5:	85 ff                	test   %edi,%edi
  8004d7:	78 c9                	js     8004a2 <vprintfmt+0x1e8>
  8004d9:	4f                   	dec    %edi
  8004da:	79 c6                	jns    8004a2 <vprintfmt+0x1e8>
  8004dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004df:	89 de                	mov    %ebx,%esi
  8004e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004e4:	eb 18                	jmp    8004fe <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004f1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f3:	4b                   	dec    %ebx
  8004f4:	eb 08                	jmp    8004fe <vprintfmt+0x244>
  8004f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f9:	89 de                	mov    %ebx,%esi
  8004fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004fe:	85 db                	test   %ebx,%ebx
  800500:	7f e4                	jg     8004e6 <vprintfmt+0x22c>
  800502:	89 7d 08             	mov    %edi,0x8(%ebp)
  800505:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050a:	e9 ce fd ff ff       	jmp    8002dd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050f:	83 f9 01             	cmp    $0x1,%ecx
  800512:	7e 10                	jle    800524 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 50 08             	lea    0x8(%eax),%edx
  80051a:	89 55 14             	mov    %edx,0x14(%ebp)
  80051d:	8b 30                	mov    (%eax),%esi
  80051f:	8b 78 04             	mov    0x4(%eax),%edi
  800522:	eb 26                	jmp    80054a <vprintfmt+0x290>
	else if (lflag)
  800524:	85 c9                	test   %ecx,%ecx
  800526:	74 12                	je     80053a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 30                	mov    (%eax),%esi
  800533:	89 f7                	mov    %esi,%edi
  800535:	c1 ff 1f             	sar    $0x1f,%edi
  800538:	eb 10                	jmp    80054a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 30                	mov    (%eax),%esi
  800545:	89 f7                	mov    %esi,%edi
  800547:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80054a:	85 ff                	test   %edi,%edi
  80054c:	78 0a                	js     800558 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800553:	e9 8c 00 00 00       	jmp    8005e4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800558:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800566:	f7 de                	neg    %esi
  800568:	83 d7 00             	adc    $0x0,%edi
  80056b:	f7 df                	neg    %edi
			}
			base = 10;
  80056d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800572:	eb 70                	jmp    8005e4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800574:	89 ca                	mov    %ecx,%edx
  800576:	8d 45 14             	lea    0x14(%ebp),%eax
  800579:	e8 c0 fc ff ff       	call   80023e <getuint>
  80057e:	89 c6                	mov    %eax,%esi
  800580:	89 d7                	mov    %edx,%edi
			base = 10;
  800582:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800587:	eb 5b                	jmp    8005e4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800589:	89 ca                	mov    %ecx,%edx
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	e8 ab fc ff ff       	call   80023e <getuint>
  800593:	89 c6                	mov    %eax,%esi
  800595:	89 d7                	mov    %edx,%edi
			base = 8;
  800597:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80059c:	eb 46                	jmp    8005e4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80059e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005a9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 50 04             	lea    0x4(%eax),%edx
  8005c0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c3:	8b 30                	mov    (%eax),%esi
  8005c5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005cf:	eb 13                	jmp    8005e4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d1:	89 ca                	mov    %ecx,%edx
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	e8 63 fc ff ff       	call   80023e <getuint>
  8005db:	89 c6                	mov    %eax,%esi
  8005dd:	89 d7                	mov    %edx,%edi
			base = 16;
  8005df:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005e8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f7:	89 34 24             	mov    %esi,(%esp)
  8005fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fe:	89 da                	mov    %ebx,%edx
  800600:	8b 45 08             	mov    0x8(%ebp),%eax
  800603:	e8 6c fb ff ff       	call   800174 <printnum>
			break;
  800608:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060b:	e9 cd fc ff ff       	jmp    8002dd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80061d:	e9 bb fc ff ff       	jmp    8002dd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800622:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800626:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80062d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800630:	eb 01                	jmp    800633 <vprintfmt+0x379>
  800632:	4e                   	dec    %esi
  800633:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800637:	75 f9                	jne    800632 <vprintfmt+0x378>
  800639:	e9 9f fc ff ff       	jmp    8002dd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80063e:	83 c4 4c             	add    $0x4c,%esp
  800641:	5b                   	pop    %ebx
  800642:	5e                   	pop    %esi
  800643:	5f                   	pop    %edi
  800644:	5d                   	pop    %ebp
  800645:	c3                   	ret    

00800646 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
  800649:	83 ec 28             	sub    $0x28,%esp
  80064c:	8b 45 08             	mov    0x8(%ebp),%eax
  80064f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800652:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800655:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800659:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800663:	85 c0                	test   %eax,%eax
  800665:	74 30                	je     800697 <vsnprintf+0x51>
  800667:	85 d2                	test   %edx,%edx
  800669:	7e 33                	jle    80069e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800672:	8b 45 10             	mov    0x10(%ebp),%eax
  800675:	89 44 24 08          	mov    %eax,0x8(%esp)
  800679:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80067c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800680:	c7 04 24 78 02 80 00 	movl   $0x800278,(%esp)
  800687:	e8 2e fc ff ff       	call   8002ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80068c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800695:	eb 0c                	jmp    8006a3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800697:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069c:	eb 05                	jmp    8006a3 <vsnprintf+0x5d>
  80069e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a3:	c9                   	leave  
  8006a4:	c3                   	ret    

008006a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	89 04 24             	mov    %eax,(%esp)
  8006c6:	e8 7b ff ff ff       	call   800646 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    
  8006cd:	00 00                	add    %al,(%eax)
	...

008006d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006db:	eb 01                	jmp    8006de <strlen+0xe>
		n++;
  8006dd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e2:	75 f9                	jne    8006dd <strlen+0xd>
		n++;
	return n;
}
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006ec:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f4:	eb 01                	jmp    8006f7 <strnlen+0x11>
		n++;
  8006f6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f7:	39 d0                	cmp    %edx,%eax
  8006f9:	74 06                	je     800701 <strnlen+0x1b>
  8006fb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006ff:	75 f5                	jne    8006f6 <strnlen+0x10>
		n++;
	return n;
}
  800701:	5d                   	pop    %ebp
  800702:	c3                   	ret    

00800703 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	53                   	push   %ebx
  800707:	8b 45 08             	mov    0x8(%ebp),%eax
  80070a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80070d:	ba 00 00 00 00       	mov    $0x0,%edx
  800712:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800715:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800718:	42                   	inc    %edx
  800719:	84 c9                	test   %cl,%cl
  80071b:	75 f5                	jne    800712 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80071d:	5b                   	pop    %ebx
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	53                   	push   %ebx
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072a:	89 1c 24             	mov    %ebx,(%esp)
  80072d:	e8 9e ff ff ff       	call   8006d0 <strlen>
	strcpy(dst + len, src);
  800732:	8b 55 0c             	mov    0xc(%ebp),%edx
  800735:	89 54 24 04          	mov    %edx,0x4(%esp)
  800739:	01 d8                	add    %ebx,%eax
  80073b:	89 04 24             	mov    %eax,(%esp)
  80073e:	e8 c0 ff ff ff       	call   800703 <strcpy>
	return dst;
}
  800743:	89 d8                	mov    %ebx,%eax
  800745:	83 c4 08             	add    $0x8,%esp
  800748:	5b                   	pop    %ebx
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	56                   	push   %esi
  80074f:	53                   	push   %ebx
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
  800756:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800759:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075e:	eb 0c                	jmp    80076c <strncpy+0x21>
		*dst++ = *src;
  800760:	8a 1a                	mov    (%edx),%bl
  800762:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800765:	80 3a 01             	cmpb   $0x1,(%edx)
  800768:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076b:	41                   	inc    %ecx
  80076c:	39 f1                	cmp    %esi,%ecx
  80076e:	75 f0                	jne    800760 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800770:	5b                   	pop    %ebx
  800771:	5e                   	pop    %esi
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	56                   	push   %esi
  800778:	53                   	push   %ebx
  800779:	8b 75 08             	mov    0x8(%ebp),%esi
  80077c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800782:	85 d2                	test   %edx,%edx
  800784:	75 0a                	jne    800790 <strlcpy+0x1c>
  800786:	89 f0                	mov    %esi,%eax
  800788:	eb 1a                	jmp    8007a4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078a:	88 18                	mov    %bl,(%eax)
  80078c:	40                   	inc    %eax
  80078d:	41                   	inc    %ecx
  80078e:	eb 02                	jmp    800792 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800790:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800792:	4a                   	dec    %edx
  800793:	74 0a                	je     80079f <strlcpy+0x2b>
  800795:	8a 19                	mov    (%ecx),%bl
  800797:	84 db                	test   %bl,%bl
  800799:	75 ef                	jne    80078a <strlcpy+0x16>
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	eb 02                	jmp    8007a1 <strlcpy+0x2d>
  80079f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007a1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007a4:	29 f0                	sub    %esi,%eax
}
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b3:	eb 02                	jmp    8007b7 <strcmp+0xd>
		p++, q++;
  8007b5:	41                   	inc    %ecx
  8007b6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b7:	8a 01                	mov    (%ecx),%al
  8007b9:	84 c0                	test   %al,%al
  8007bb:	74 04                	je     8007c1 <strcmp+0x17>
  8007bd:	3a 02                	cmp    (%edx),%al
  8007bf:	74 f4                	je     8007b5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c1:	0f b6 c0             	movzbl %al,%eax
  8007c4:	0f b6 12             	movzbl (%edx),%edx
  8007c7:	29 d0                	sub    %edx,%eax
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007d8:	eb 03                	jmp    8007dd <strncmp+0x12>
		n--, p++, q++;
  8007da:	4a                   	dec    %edx
  8007db:	40                   	inc    %eax
  8007dc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007dd:	85 d2                	test   %edx,%edx
  8007df:	74 14                	je     8007f5 <strncmp+0x2a>
  8007e1:	8a 18                	mov    (%eax),%bl
  8007e3:	84 db                	test   %bl,%bl
  8007e5:	74 04                	je     8007eb <strncmp+0x20>
  8007e7:	3a 19                	cmp    (%ecx),%bl
  8007e9:	74 ef                	je     8007da <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007eb:	0f b6 00             	movzbl (%eax),%eax
  8007ee:	0f b6 11             	movzbl (%ecx),%edx
  8007f1:	29 d0                	sub    %edx,%eax
  8007f3:	eb 05                	jmp    8007fa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fa:	5b                   	pop    %ebx
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800806:	eb 05                	jmp    80080d <strchr+0x10>
		if (*s == c)
  800808:	38 ca                	cmp    %cl,%dl
  80080a:	74 0c                	je     800818 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80080c:	40                   	inc    %eax
  80080d:	8a 10                	mov    (%eax),%dl
  80080f:	84 d2                	test   %dl,%dl
  800811:	75 f5                	jne    800808 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800823:	eb 05                	jmp    80082a <strfind+0x10>
		if (*s == c)
  800825:	38 ca                	cmp    %cl,%dl
  800827:	74 07                	je     800830 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800829:	40                   	inc    %eax
  80082a:	8a 10                	mov    (%eax),%dl
  80082c:	84 d2                	test   %dl,%dl
  80082e:	75 f5                	jne    800825 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	57                   	push   %edi
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800841:	85 c9                	test   %ecx,%ecx
  800843:	74 30                	je     800875 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800845:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084b:	75 25                	jne    800872 <memset+0x40>
  80084d:	f6 c1 03             	test   $0x3,%cl
  800850:	75 20                	jne    800872 <memset+0x40>
		c &= 0xFF;
  800852:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800855:	89 d3                	mov    %edx,%ebx
  800857:	c1 e3 08             	shl    $0x8,%ebx
  80085a:	89 d6                	mov    %edx,%esi
  80085c:	c1 e6 18             	shl    $0x18,%esi
  80085f:	89 d0                	mov    %edx,%eax
  800861:	c1 e0 10             	shl    $0x10,%eax
  800864:	09 f0                	or     %esi,%eax
  800866:	09 d0                	or     %edx,%eax
  800868:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80086a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80086d:	fc                   	cld    
  80086e:	f3 ab                	rep stos %eax,%es:(%edi)
  800870:	eb 03                	jmp    800875 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800872:	fc                   	cld    
  800873:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800875:	89 f8                	mov    %edi,%eax
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5f                   	pop    %edi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	57                   	push   %edi
  800880:	56                   	push   %esi
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8b 75 0c             	mov    0xc(%ebp),%esi
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80088a:	39 c6                	cmp    %eax,%esi
  80088c:	73 34                	jae    8008c2 <memmove+0x46>
  80088e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800891:	39 d0                	cmp    %edx,%eax
  800893:	73 2d                	jae    8008c2 <memmove+0x46>
		s += n;
		d += n;
  800895:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800898:	f6 c2 03             	test   $0x3,%dl
  80089b:	75 1b                	jne    8008b8 <memmove+0x3c>
  80089d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a3:	75 13                	jne    8008b8 <memmove+0x3c>
  8008a5:	f6 c1 03             	test   $0x3,%cl
  8008a8:	75 0e                	jne    8008b8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008aa:	83 ef 04             	sub    $0x4,%edi
  8008ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008b3:	fd                   	std    
  8008b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b6:	eb 07                	jmp    8008bf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008b8:	4f                   	dec    %edi
  8008b9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008bc:	fd                   	std    
  8008bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bf:	fc                   	cld    
  8008c0:	eb 20                	jmp    8008e2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c8:	75 13                	jne    8008dd <memmove+0x61>
  8008ca:	a8 03                	test   $0x3,%al
  8008cc:	75 0f                	jne    8008dd <memmove+0x61>
  8008ce:	f6 c1 03             	test   $0x3,%cl
  8008d1:	75 0a                	jne    8008dd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008d3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008d6:	89 c7                	mov    %eax,%edi
  8008d8:	fc                   	cld    
  8008d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008db:	eb 05                	jmp    8008e2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008dd:	89 c7                	mov    %eax,%edi
  8008df:	fc                   	cld    
  8008e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e2:	5e                   	pop    %esi
  8008e3:	5f                   	pop    %edi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	89 04 24             	mov    %eax,(%esp)
  800900:	e8 77 ff ff ff       	call   80087c <memmove>
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800910:	8b 75 0c             	mov    0xc(%ebp),%esi
  800913:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800916:	ba 00 00 00 00       	mov    $0x0,%edx
  80091b:	eb 16                	jmp    800933 <memcmp+0x2c>
		if (*s1 != *s2)
  80091d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800920:	42                   	inc    %edx
  800921:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800925:	38 c8                	cmp    %cl,%al
  800927:	74 0a                	je     800933 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800929:	0f b6 c0             	movzbl %al,%eax
  80092c:	0f b6 c9             	movzbl %cl,%ecx
  80092f:	29 c8                	sub    %ecx,%eax
  800931:	eb 09                	jmp    80093c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800933:	39 da                	cmp    %ebx,%edx
  800935:	75 e6                	jne    80091d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5f                   	pop    %edi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80094a:	89 c2                	mov    %eax,%edx
  80094c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80094f:	eb 05                	jmp    800956 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800951:	38 08                	cmp    %cl,(%eax)
  800953:	74 05                	je     80095a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800955:	40                   	inc    %eax
  800956:	39 d0                	cmp    %edx,%eax
  800958:	72 f7                	jb     800951 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	57                   	push   %edi
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 55 08             	mov    0x8(%ebp),%edx
  800965:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800968:	eb 01                	jmp    80096b <strtol+0xf>
		s++;
  80096a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096b:	8a 02                	mov    (%edx),%al
  80096d:	3c 20                	cmp    $0x20,%al
  80096f:	74 f9                	je     80096a <strtol+0xe>
  800971:	3c 09                	cmp    $0x9,%al
  800973:	74 f5                	je     80096a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800975:	3c 2b                	cmp    $0x2b,%al
  800977:	75 08                	jne    800981 <strtol+0x25>
		s++;
  800979:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80097a:	bf 00 00 00 00       	mov    $0x0,%edi
  80097f:	eb 13                	jmp    800994 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800981:	3c 2d                	cmp    $0x2d,%al
  800983:	75 0a                	jne    80098f <strtol+0x33>
		s++, neg = 1;
  800985:	8d 52 01             	lea    0x1(%edx),%edx
  800988:	bf 01 00 00 00       	mov    $0x1,%edi
  80098d:	eb 05                	jmp    800994 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800994:	85 db                	test   %ebx,%ebx
  800996:	74 05                	je     80099d <strtol+0x41>
  800998:	83 fb 10             	cmp    $0x10,%ebx
  80099b:	75 28                	jne    8009c5 <strtol+0x69>
  80099d:	8a 02                	mov    (%edx),%al
  80099f:	3c 30                	cmp    $0x30,%al
  8009a1:	75 10                	jne    8009b3 <strtol+0x57>
  8009a3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009a7:	75 0a                	jne    8009b3 <strtol+0x57>
		s += 2, base = 16;
  8009a9:	83 c2 02             	add    $0x2,%edx
  8009ac:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b1:	eb 12                	jmp    8009c5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009b3:	85 db                	test   %ebx,%ebx
  8009b5:	75 0e                	jne    8009c5 <strtol+0x69>
  8009b7:	3c 30                	cmp    $0x30,%al
  8009b9:	75 05                	jne    8009c0 <strtol+0x64>
		s++, base = 8;
  8009bb:	42                   	inc    %edx
  8009bc:	b3 08                	mov    $0x8,%bl
  8009be:	eb 05                	jmp    8009c5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009c0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ca:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009cc:	8a 0a                	mov    (%edx),%cl
  8009ce:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009d1:	80 fb 09             	cmp    $0x9,%bl
  8009d4:	77 08                	ja     8009de <strtol+0x82>
			dig = *s - '0';
  8009d6:	0f be c9             	movsbl %cl,%ecx
  8009d9:	83 e9 30             	sub    $0x30,%ecx
  8009dc:	eb 1e                	jmp    8009fc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009de:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009e1:	80 fb 19             	cmp    $0x19,%bl
  8009e4:	77 08                	ja     8009ee <strtol+0x92>
			dig = *s - 'a' + 10;
  8009e6:	0f be c9             	movsbl %cl,%ecx
  8009e9:	83 e9 57             	sub    $0x57,%ecx
  8009ec:	eb 0e                	jmp    8009fc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009ee:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 12                	ja     800a08 <strtol+0xac>
			dig = *s - 'A' + 10;
  8009f6:	0f be c9             	movsbl %cl,%ecx
  8009f9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8009fc:	39 f1                	cmp    %esi,%ecx
  8009fe:	7d 0c                	jge    800a0c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a00:	42                   	inc    %edx
  800a01:	0f af c6             	imul   %esi,%eax
  800a04:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a06:	eb c4                	jmp    8009cc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a08:	89 c1                	mov    %eax,%ecx
  800a0a:	eb 02                	jmp    800a0e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a0c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a12:	74 05                	je     800a19 <strtol+0xbd>
		*endptr = (char *) s;
  800a14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a17:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a19:	85 ff                	test   %edi,%edi
  800a1b:	74 04                	je     800a21 <strtol+0xc5>
  800a1d:	89 c8                	mov    %ecx,%eax
  800a1f:	f7 d8                	neg    %eax
}
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    
	...

00800a28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a36:	8b 55 08             	mov    0x8(%ebp),%edx
  800a39:	89 c3                	mov    %eax,%ebx
  800a3b:	89 c7                	mov    %eax,%edi
  800a3d:	89 c6                	mov    %eax,%esi
  800a3f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	b8 01 00 00 00       	mov    $0x1,%eax
  800a56:	89 d1                	mov    %edx,%ecx
  800a58:	89 d3                	mov    %edx,%ebx
  800a5a:	89 d7                	mov    %edx,%edi
  800a5c:	89 d6                	mov    %edx,%esi
  800a5e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a73:	b8 03 00 00 00       	mov    $0x3,%eax
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	89 cb                	mov    %ecx,%ebx
  800a7d:	89 cf                	mov    %ecx,%edi
  800a7f:	89 ce                	mov    %ecx,%esi
  800a81:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a83:	85 c0                	test   %eax,%eax
  800a85:	7e 28                	jle    800aaf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a8b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a92:	00 
  800a93:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800a9a:	00 
  800a9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aa2:	00 
  800aa3:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800aaa:	e8 5d 02 00 00       	call   800d0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aaf:	83 c4 2c             	add    $0x2c,%esp
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5f                   	pop    %edi
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac7:	89 d1                	mov    %edx,%ecx
  800ac9:	89 d3                	mov    %edx,%ebx
  800acb:	89 d7                	mov    %edx,%edi
  800acd:	89 d6                	mov    %edx,%esi
  800acf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <sys_yield>:

void
sys_yield(void)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae6:	89 d1                	mov    %edx,%ecx
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	89 d7                	mov    %edx,%edi
  800aec:	89 d6                	mov    %edx,%esi
  800aee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afe:	be 00 00 00 00       	mov    $0x0,%esi
  800b03:	b8 04 00 00 00       	mov    $0x4,%eax
  800b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	89 f7                	mov    %esi,%edi
  800b13:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b15:	85 c0                	test   %eax,%eax
  800b17:	7e 28                	jle    800b41 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b1d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b24:	00 
  800b25:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800b2c:	00 
  800b2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b34:	00 
  800b35:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800b3c:	e8 cb 01 00 00       	call   800d0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b41:	83 c4 2c             	add    $0x2c,%esp
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b52:	b8 05 00 00 00       	mov    $0x5,%eax
  800b57:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
  800b66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7e 28                	jle    800b94 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b70:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b77:	00 
  800b78:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800b7f:	00 
  800b80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b87:	00 
  800b88:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800b8f:	e8 78 01 00 00       	call   800d0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b94:	83 c4 2c             	add    $0x2c,%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800baa:	b8 06 00 00 00       	mov    $0x6,%eax
  800baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb5:	89 df                	mov    %ebx,%edi
  800bb7:	89 de                	mov    %ebx,%esi
  800bb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 28                	jle    800be7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bca:	00 
  800bcb:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800bd2:	00 
  800bd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bda:	00 
  800bdb:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800be2:	e8 25 01 00 00       	call   800d0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be7:	83 c4 2c             	add    $0x2c,%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfd:	b8 08 00 00 00       	mov    $0x8,%eax
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	89 df                	mov    %ebx,%edi
  800c0a:	89 de                	mov    %ebx,%esi
  800c0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7e 28                	jle    800c3a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c12:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c16:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c1d:	00 
  800c1e:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800c25:	00 
  800c26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2d:	00 
  800c2e:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800c35:	e8 d2 00 00 00       	call   800d0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3a:	83 c4 2c             	add    $0x2c,%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 09 00 00 00       	mov    $0x9,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 28                	jle    800c8d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c69:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c70:	00 
  800c71:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800c78:	00 
  800c79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c80:	00 
  800c81:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800c88:	e8 7f 00 00 00       	call   800d0c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8d:	83 c4 2c             	add    $0x2c,%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9b:	be 00 00 00 00       	mov    $0x0,%esi
  800ca0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	89 cb                	mov    %ecx,%ebx
  800cd0:	89 cf                	mov    %ecx,%edi
  800cd2:	89 ce                	mov    %ecx,%esi
  800cd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7e 28                	jle    800d02 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cde:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ce5:	00 
  800ce6:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800ced:	00 
  800cee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf5:	00 
  800cf6:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800cfd:	e8 0a 00 00 00       	call   800d0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d02:	83 c4 2c             	add    $0x2c,%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    
	...

00800d0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d14:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d17:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d1d:	e8 95 fd ff ff       	call   800ab7 <sys_getenvid>
  800d22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d25:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d30:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d38:	c7 04 24 50 12 80 00 	movl   $0x801250,(%esp)
  800d3f:	e8 14 f4 ff ff       	call   800158 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d48:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4b:	89 04 24             	mov    %eax,(%esp)
  800d4e:	e8 a4 f3 ff ff       	call   8000f7 <vcprintf>
	cprintf("\n");
  800d53:	c7 04 24 c2 0f 80 00 	movl   $0x800fc2,(%esp)
  800d5a:	e8 f9 f3 ff ff       	call   800158 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d5f:	cc                   	int3   
  800d60:	eb fd                	jmp    800d5f <_panic+0x53>
	...

00800d64 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d64:	55                   	push   %ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	83 ec 10             	sub    $0x10,%esp
  800d6a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d6e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d72:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d76:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d7a:	89 cd                	mov    %ecx,%ebp
  800d7c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	75 2c                	jne    800db0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d84:	39 f9                	cmp    %edi,%ecx
  800d86:	77 68                	ja     800df0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d88:	85 c9                	test   %ecx,%ecx
  800d8a:	75 0b                	jne    800d97 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d91:	31 d2                	xor    %edx,%edx
  800d93:	f7 f1                	div    %ecx
  800d95:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d97:	31 d2                	xor    %edx,%edx
  800d99:	89 f8                	mov    %edi,%eax
  800d9b:	f7 f1                	div    %ecx
  800d9d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d9f:	89 f0                	mov    %esi,%eax
  800da1:	f7 f1                	div    %ecx
  800da3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800da5:	89 f0                	mov    %esi,%eax
  800da7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800da9:	83 c4 10             	add    $0x10,%esp
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800db0:	39 f8                	cmp    %edi,%eax
  800db2:	77 2c                	ja     800de0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800db4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800db7:	83 f6 1f             	xor    $0x1f,%esi
  800dba:	75 4c                	jne    800e08 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dbc:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dbe:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc3:	72 0a                	jb     800dcf <__udivdi3+0x6b>
  800dc5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dc9:	0f 87 ad 00 00 00    	ja     800e7c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dcf:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dd4:	89 f0                	mov    %esi,%eax
  800dd6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
  800ddf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de0:	31 ff                	xor    %edi,%edi
  800de2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de4:	89 f0                	mov    %esi,%eax
  800de6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
  800def:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df0:	89 fa                	mov    %edi,%edx
  800df2:	89 f0                	mov    %esi,%eax
  800df4:	f7 f1                	div    %ecx
  800df6:	89 c6                	mov    %eax,%esi
  800df8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dfa:	89 f0                	mov    %esi,%eax
  800dfc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e08:	89 f1                	mov    %esi,%ecx
  800e0a:	d3 e0                	shl    %cl,%eax
  800e0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e10:	b8 20 00 00 00       	mov    $0x20,%eax
  800e15:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e17:	89 ea                	mov    %ebp,%edx
  800e19:	88 c1                	mov    %al,%cl
  800e1b:	d3 ea                	shr    %cl,%edx
  800e1d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e21:	09 ca                	or     %ecx,%edx
  800e23:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e27:	89 f1                	mov    %esi,%ecx
  800e29:	d3 e5                	shl    %cl,%ebp
  800e2b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e2f:	89 fd                	mov    %edi,%ebp
  800e31:	88 c1                	mov    %al,%cl
  800e33:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e35:	89 fa                	mov    %edi,%edx
  800e37:	89 f1                	mov    %esi,%ecx
  800e39:	d3 e2                	shl    %cl,%edx
  800e3b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e3f:	88 c1                	mov    %al,%cl
  800e41:	d3 ef                	shr    %cl,%edi
  800e43:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e45:	89 f8                	mov    %edi,%eax
  800e47:	89 ea                	mov    %ebp,%edx
  800e49:	f7 74 24 08          	divl   0x8(%esp)
  800e4d:	89 d1                	mov    %edx,%ecx
  800e4f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e51:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e55:	39 d1                	cmp    %edx,%ecx
  800e57:	72 17                	jb     800e70 <__udivdi3+0x10c>
  800e59:	74 09                	je     800e64 <__udivdi3+0x100>
  800e5b:	89 fe                	mov    %edi,%esi
  800e5d:	31 ff                	xor    %edi,%edi
  800e5f:	e9 41 ff ff ff       	jmp    800da5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e64:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e68:	89 f1                	mov    %esi,%ecx
  800e6a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e6c:	39 c2                	cmp    %eax,%edx
  800e6e:	73 eb                	jae    800e5b <__udivdi3+0xf7>
		{
		  q0--;
  800e70:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e73:	31 ff                	xor    %edi,%edi
  800e75:	e9 2b ff ff ff       	jmp    800da5 <__udivdi3+0x41>
  800e7a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e7c:	31 f6                	xor    %esi,%esi
  800e7e:	e9 22 ff ff ff       	jmp    800da5 <__udivdi3+0x41>
	...

00800e84 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e84:	55                   	push   %ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	83 ec 20             	sub    $0x20,%esp
  800e8a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e8e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e92:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e96:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e9a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e9e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ea2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800ea4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ea6:	85 ed                	test   %ebp,%ebp
  800ea8:	75 16                	jne    800ec0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800eaa:	39 f1                	cmp    %esi,%ecx
  800eac:	0f 86 a6 00 00 00    	jbe    800f58 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800eb4:	89 d0                	mov    %edx,%eax
  800eb6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eb8:	83 c4 20             	add    $0x20,%esp
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    
  800ebf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ec0:	39 f5                	cmp    %esi,%ebp
  800ec2:	0f 87 ac 00 00 00    	ja     800f74 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ec8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800ecb:	83 f0 1f             	xor    $0x1f,%eax
  800ece:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed2:	0f 84 a8 00 00 00    	je     800f80 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ed8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800edc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ede:	bf 20 00 00 00       	mov    $0x20,%edi
  800ee3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ee7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eeb:	89 f9                	mov    %edi,%ecx
  800eed:	d3 e8                	shr    %cl,%eax
  800eef:	09 e8                	or     %ebp,%eax
  800ef1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800ef5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ef9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800efd:	d3 e0                	shl    %cl,%eax
  800eff:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f03:	89 f2                	mov    %esi,%edx
  800f05:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f07:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f0b:	d3 e0                	shl    %cl,%eax
  800f0d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f11:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f15:	89 f9                	mov    %edi,%ecx
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f1b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	f7 74 24 18          	divl   0x18(%esp)
  800f23:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f25:	f7 64 24 0c          	mull   0xc(%esp)
  800f29:	89 c5                	mov    %eax,%ebp
  800f2b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f2d:	39 d6                	cmp    %edx,%esi
  800f2f:	72 67                	jb     800f98 <__umoddi3+0x114>
  800f31:	74 75                	je     800fa8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f33:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f37:	29 e8                	sub    %ebp,%eax
  800f39:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f3b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f3f:	d3 e8                	shr    %cl,%eax
  800f41:	89 f2                	mov    %esi,%edx
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f47:	09 d0                	or     %edx,%eax
  800f49:	89 f2                	mov    %esi,%edx
  800f4b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f51:	83 c4 20             	add    $0x20,%esp
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f58:	85 c9                	test   %ecx,%ecx
  800f5a:	75 0b                	jne    800f67 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f61:	31 d2                	xor    %edx,%edx
  800f63:	f7 f1                	div    %ecx
  800f65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f67:	89 f0                	mov    %esi,%eax
  800f69:	31 d2                	xor    %edx,%edx
  800f6b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f6d:	89 f8                	mov    %edi,%eax
  800f6f:	e9 3e ff ff ff       	jmp    800eb2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f74:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f76:	83 c4 20             	add    $0x20,%esp
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f80:	39 f5                	cmp    %esi,%ebp
  800f82:	72 04                	jb     800f88 <__umoddi3+0x104>
  800f84:	39 f9                	cmp    %edi,%ecx
  800f86:	77 06                	ja     800f8e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f88:	89 f2                	mov    %esi,%edx
  800f8a:	29 cf                	sub    %ecx,%edi
  800f8c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f8e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f90:	83 c4 20             	add    $0x20,%esp
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    
  800f97:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f98:	89 d1                	mov    %edx,%ecx
  800f9a:	89 c5                	mov    %eax,%ebp
  800f9c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fa0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fa4:	eb 8d                	jmp    800f33 <__umoddi3+0xaf>
  800fa6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fa8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fac:	72 ea                	jb     800f98 <__umoddi3+0x114>
  800fae:	89 f1                	mov    %esi,%ecx
  800fb0:	eb 81                	jmp    800f33 <__umoddi3+0xaf>
