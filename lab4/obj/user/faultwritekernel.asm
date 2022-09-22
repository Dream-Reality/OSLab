
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 20             	sub    $0x20,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800052:	e8 68 0a 00 00       	call   800abf <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	29 d0                	sub    %edx,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800070:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800073:	a3 04 20 80 00       	mov    %eax,0x802004
  800078:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  80007c:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  800083:	e8 d8 00 00 00       	call   800160 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	85 f6                	test   %esi,%esi
  80008a:	7e 07                	jle    800093 <libmain+0x4f>
		binaryname = argv[0];
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800093:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800097:	89 34 24             	mov    %esi,(%esp)
  80009a:	e8 95 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009f:	e8 08 00 00 00       	call   8000ac <exit>
}
  8000a4:	83 c4 20             	add    $0x20,%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 af 09 00 00       	call   800a6d <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 14             	sub    $0x14,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 03                	mov    (%ebx),%eax
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d3:	40                   	inc    %eax
  8000d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 19                	jne    8000f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000e4:	00 
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	89 04 24             	mov    %eax,(%esp)
  8000eb:	e8 40 09 00 00       	call   800a30 <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f6:	ff 43 04             	incl   0x4(%ebx)
}
  8000f9:	83 c4 14             	add    $0x14,%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800108:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010f:	00 00 00 
	b.cnt = 0;
  800112:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800119:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800123:	8b 45 08             	mov    0x8(%ebp),%eax
  800126:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800130:	89 44 24 04          	mov    %eax,0x4(%esp)
  800134:	c7 04 24 c0 00 80 00 	movl   $0x8000c0,(%esp)
  80013b:	e8 82 01 00 00       	call   8002c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800140:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800150:	89 04 24             	mov    %eax,(%esp)
  800153:	e8 d8 08 00 00       	call   800a30 <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	89 04 24             	mov    %eax,(%esp)
  800173:	e8 87 ff ff ff       	call   8000ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800178:	c9                   	leave  
  800179:	c3                   	ret    
	...

0080017c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 3c             	sub    $0x3c,%esp
  800185:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800188:	89 d7                	mov    %edx,%edi
  80018a:	8b 45 08             	mov    0x8(%ebp),%eax
  80018d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800190:	8b 45 0c             	mov    0xc(%ebp),%eax
  800193:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800196:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800199:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019c:	85 c0                	test   %eax,%eax
  80019e:	75 08                	jne    8001a8 <printnum+0x2c>
  8001a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a6:	77 57                	ja     8001ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001ac:	4b                   	dec    %ebx
  8001ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c7:	00 
  8001c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	e8 92 0b 00 00       	call   800d6c <__udivdi3>
  8001da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e9:	89 fa                	mov    %edi,%edx
  8001eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ee:	e8 89 ff ff ff       	call   80017c <printnum>
  8001f3:	eb 0f                	jmp    800204 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f9:	89 34 24             	mov    %esi,(%esp)
  8001fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	4b                   	dec    %ebx
  800200:	85 db                	test   %ebx,%ebx
  800202:	7f f1                	jg     8001f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800204:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800208:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80020c:	8b 45 10             	mov    0x10(%ebp),%eax
  80020f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800213:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021a:	00 
  80021b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800224:	89 44 24 04          	mov    %eax,0x4(%esp)
  800228:	e8 5f 0c 00 00       	call   800e8c <__umoddi3>
  80022d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800231:	0f be 80 ce 0f 80 00 	movsbl 0x800fce(%eax),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80023e:	83 c4 3c             	add    $0x3c,%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5f                   	pop    %edi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800249:	83 fa 01             	cmp    $0x1,%edx
  80024c:	7e 0e                	jle    80025c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024e:	8b 10                	mov    (%eax),%edx
  800250:	8d 4a 08             	lea    0x8(%edx),%ecx
  800253:	89 08                	mov    %ecx,(%eax)
  800255:	8b 02                	mov    (%edx),%eax
  800257:	8b 52 04             	mov    0x4(%edx),%edx
  80025a:	eb 22                	jmp    80027e <getuint+0x38>
	else if (lflag)
  80025c:	85 d2                	test   %edx,%edx
  80025e:	74 10                	je     800270 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
  80026e:	eb 0e                	jmp    80027e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 04             	lea    0x4(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800286:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	3b 50 04             	cmp    0x4(%eax),%edx
  80028e:	73 08                	jae    800298 <sprintputch+0x18>
		*b->buf++ = ch;
  800290:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800293:	88 0a                	mov    %cl,(%edx)
  800295:	42                   	inc    %edx
  800296:	89 10                	mov    %edx,(%eax)
}
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    

0080029a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	e8 02 00 00 00       	call   8002c2 <vprintfmt>
	va_end(ap);
}
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    

008002c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	57                   	push   %edi
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	83 ec 4c             	sub    $0x4c,%esp
  8002cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d1:	eb 12                	jmp    8002e5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	0f 84 6b 03 00 00    	je     800646 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e5:	0f b6 06             	movzbl (%esi),%eax
  8002e8:	46                   	inc    %esi
  8002e9:	83 f8 25             	cmp    $0x25,%eax
  8002ec:	75 e5                	jne    8002d3 <vprintfmt+0x11>
  8002ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8002f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8002fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800305:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030a:	eb 26                	jmp    800332 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800313:	eb 1d                	jmp    800332 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800318:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80031c:	eb 14                	jmp    800332 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800321:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800328:	eb 08                	jmp    800332 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80032a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80032d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	0f b6 06             	movzbl (%esi),%eax
  800335:	8d 56 01             	lea    0x1(%esi),%edx
  800338:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80033b:	8a 16                	mov    (%esi),%dl
  80033d:	83 ea 23             	sub    $0x23,%edx
  800340:	80 fa 55             	cmp    $0x55,%dl
  800343:	0f 87 e1 02 00 00    	ja     80062a <vprintfmt+0x368>
  800349:	0f b6 d2             	movzbl %dl,%edx
  80034c:	ff 24 95 a0 10 80 00 	jmp    *0x8010a0(,%edx,4)
  800353:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800356:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80035e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800362:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800365:	8d 50 d0             	lea    -0x30(%eax),%edx
  800368:	83 fa 09             	cmp    $0x9,%edx
  80036b:	77 2a                	ja     800397 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036e:	eb eb                	jmp    80035b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 50 04             	lea    0x4(%eax),%edx
  800376:	89 55 14             	mov    %edx,0x14(%ebp)
  800379:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037e:	eb 17                	jmp    800397 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800380:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800384:	78 98                	js     80031e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800389:	eb a7                	jmp    800332 <vprintfmt+0x70>
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800395:	eb 9b                	jmp    800332 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800397:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039b:	79 95                	jns    800332 <vprintfmt+0x70>
  80039d:	eb 8b                	jmp    80032a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a3:	eb 8d                	jmp    800332 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 50 04             	lea    0x4(%eax),%edx
  8003ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b2:	8b 00                	mov    (%eax),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003bd:	e9 23 ff ff ff       	jmp    8002e5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 50 04             	lea    0x4(%eax),%edx
  8003c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	79 02                	jns    8003d3 <vprintfmt+0x111>
  8003d1:	f7 d8                	neg    %eax
  8003d3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d5:	83 f8 08             	cmp    $0x8,%eax
  8003d8:	7f 0b                	jg     8003e5 <vprintfmt+0x123>
  8003da:	8b 04 85 00 12 80 00 	mov    0x801200(,%eax,4),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	75 23                	jne    800408 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e9:	c7 44 24 08 e6 0f 80 	movl   $0x800fe6,0x8(%esp)
  8003f0:	00 
  8003f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	e8 9a fe ff ff       	call   80029a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800403:	e9 dd fe ff ff       	jmp    8002e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800408:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040c:	c7 44 24 08 ef 0f 80 	movl   $0x800fef,0x8(%esp)
  800413:	00 
  800414:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800418:	8b 55 08             	mov    0x8(%ebp),%edx
  80041b:	89 14 24             	mov    %edx,(%esp)
  80041e:	e8 77 fe ff ff       	call   80029a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800426:	e9 ba fe ff ff       	jmp    8002e5 <vprintfmt+0x23>
  80042b:	89 f9                	mov    %edi,%ecx
  80042d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800430:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 50 04             	lea    0x4(%eax),%edx
  800439:	89 55 14             	mov    %edx,0x14(%ebp)
  80043c:	8b 30                	mov    (%eax),%esi
  80043e:	85 f6                	test   %esi,%esi
  800440:	75 05                	jne    800447 <vprintfmt+0x185>
				p = "(null)";
  800442:	be df 0f 80 00       	mov    $0x800fdf,%esi
			if (width > 0 && padc != '-')
  800447:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80044b:	0f 8e 84 00 00 00    	jle    8004d5 <vprintfmt+0x213>
  800451:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800455:	74 7e                	je     8004d5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80045b:	89 34 24             	mov    %esi,(%esp)
  80045e:	e8 8b 02 00 00       	call   8006ee <strnlen>
  800463:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800466:	29 c2                	sub    %eax,%edx
  800468:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80046b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80046f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800472:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800475:	89 de                	mov    %ebx,%esi
  800477:	89 d3                	mov    %edx,%ebx
  800479:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	eb 0b                	jmp    800488 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80047d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800481:	89 3c 24             	mov    %edi,(%esp)
  800484:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800487:	4b                   	dec    %ebx
  800488:	85 db                	test   %ebx,%ebx
  80048a:	7f f1                	jg     80047d <vprintfmt+0x1bb>
  80048c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80048f:	89 f3                	mov    %esi,%ebx
  800491:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800494:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800497:	85 c0                	test   %eax,%eax
  800499:	79 05                	jns    8004a0 <vprintfmt+0x1de>
  80049b:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a3:	29 c2                	sub    %eax,%edx
  8004a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004a8:	eb 2b                	jmp    8004d5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ae:	74 18                	je     8004c8 <vprintfmt+0x206>
  8004b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004b3:	83 fa 5e             	cmp    $0x5e,%edx
  8004b6:	76 10                	jbe    8004c8 <vprintfmt+0x206>
					putch('?', putdat);
  8004b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004c3:	ff 55 08             	call   *0x8(%ebp)
  8004c6:	eb 0a                	jmp    8004d2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004d5:	0f be 06             	movsbl (%esi),%eax
  8004d8:	46                   	inc    %esi
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	74 21                	je     8004fe <vprintfmt+0x23c>
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	78 c9                	js     8004aa <vprintfmt+0x1e8>
  8004e1:	4f                   	dec    %edi
  8004e2:	79 c6                	jns    8004aa <vprintfmt+0x1e8>
  8004e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004e7:	89 de                	mov    %ebx,%esi
  8004e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004ec:	eb 18                	jmp    800506 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8004f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004fb:	4b                   	dec    %ebx
  8004fc:	eb 08                	jmp    800506 <vprintfmt+0x244>
  8004fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800501:	89 de                	mov    %ebx,%esi
  800503:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800506:	85 db                	test   %ebx,%ebx
  800508:	7f e4                	jg     8004ee <vprintfmt+0x22c>
  80050a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80050d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800512:	e9 ce fd ff ff       	jmp    8002e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800517:	83 f9 01             	cmp    $0x1,%ecx
  80051a:	7e 10                	jle    80052c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8d 50 08             	lea    0x8(%eax),%edx
  800522:	89 55 14             	mov    %edx,0x14(%ebp)
  800525:	8b 30                	mov    (%eax),%esi
  800527:	8b 78 04             	mov    0x4(%eax),%edi
  80052a:	eb 26                	jmp    800552 <vprintfmt+0x290>
	else if (lflag)
  80052c:	85 c9                	test   %ecx,%ecx
  80052e:	74 12                	je     800542 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 30                	mov    (%eax),%esi
  80053b:	89 f7                	mov    %esi,%edi
  80053d:	c1 ff 1f             	sar    $0x1f,%edi
  800540:	eb 10                	jmp    800552 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 30                	mov    (%eax),%esi
  80054d:	89 f7                	mov    %esi,%edi
  80054f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800552:	85 ff                	test   %edi,%edi
  800554:	78 0a                	js     800560 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800556:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055b:	e9 8c 00 00 00       	jmp    8005ec <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800564:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80056e:	f7 de                	neg    %esi
  800570:	83 d7 00             	adc    $0x0,%edi
  800573:	f7 df                	neg    %edi
			}
			base = 10;
  800575:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057a:	eb 70                	jmp    8005ec <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057c:	89 ca                	mov    %ecx,%edx
  80057e:	8d 45 14             	lea    0x14(%ebp),%eax
  800581:	e8 c0 fc ff ff       	call   800246 <getuint>
  800586:	89 c6                	mov    %eax,%esi
  800588:	89 d7                	mov    %edx,%edi
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80058f:	eb 5b                	jmp    8005ec <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800591:	89 ca                	mov    %ecx,%edx
  800593:	8d 45 14             	lea    0x14(%ebp),%eax
  800596:	e8 ab fc ff ff       	call   800246 <getuint>
  80059b:	89 c6                	mov    %eax,%esi
  80059d:	89 d7                	mov    %edx,%edi
			base = 8;
  80059f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005a4:	eb 46                	jmp    8005ec <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005b1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cb:	8b 30                	mov    (%eax),%esi
  8005cd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005d7:	eb 13                	jmp    8005ec <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d9:	89 ca                	mov    %ecx,%edx
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 63 fc ff ff       	call   800246 <getuint>
  8005e3:	89 c6                	mov    %eax,%esi
  8005e5:	89 d7                	mov    %edx,%edi
			base = 16;
  8005e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ec:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005f0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ff:	89 34 24             	mov    %esi,(%esp)
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	89 da                	mov    %ebx,%edx
  800608:	8b 45 08             	mov    0x8(%ebp),%eax
  80060b:	e8 6c fb ff ff       	call   80017c <printnum>
			break;
  800610:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800613:	e9 cd fc ff ff       	jmp    8002e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800625:	e9 bb fc ff ff       	jmp    8002e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80062a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800635:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800638:	eb 01                	jmp    80063b <vprintfmt+0x379>
  80063a:	4e                   	dec    %esi
  80063b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80063f:	75 f9                	jne    80063a <vprintfmt+0x378>
  800641:	e9 9f fc ff ff       	jmp    8002e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800646:	83 c4 4c             	add    $0x4c,%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	83 ec 28             	sub    $0x28,%esp
  800654:	8b 45 08             	mov    0x8(%ebp),%eax
  800657:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800661:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800664:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066b:	85 c0                	test   %eax,%eax
  80066d:	74 30                	je     80069f <vsnprintf+0x51>
  80066f:	85 d2                	test   %edx,%edx
  800671:	7e 33                	jle    8006a6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067a:	8b 45 10             	mov    0x10(%ebp),%eax
  80067d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800681:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800684:	89 44 24 04          	mov    %eax,0x4(%esp)
  800688:	c7 04 24 80 02 80 00 	movl   $0x800280,(%esp)
  80068f:	e8 2e fc ff ff       	call   8002c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800694:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800697:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80069a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069d:	eb 0c                	jmp    8006ab <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a4:	eb 05                	jmp    8006ab <vsnprintf+0x5d>
  8006a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ab:	c9                   	leave  
  8006ac:	c3                   	ret    

008006ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8006bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	89 04 24             	mov    %eax,(%esp)
  8006ce:	e8 7b ff ff ff       	call   80064e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    
  8006d5:	00 00                	add    %al,(%eax)
	...

008006d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	eb 01                	jmp    8006e6 <strlen+0xe>
		n++;
  8006e5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ea:	75 f9                	jne    8006e5 <strlen+0xd>
		n++;
	return n;
}
  8006ec:	5d                   	pop    %ebp
  8006ed:	c3                   	ret    

008006ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fc:	eb 01                	jmp    8006ff <strnlen+0x11>
		n++;
  8006fe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ff:	39 d0                	cmp    %edx,%eax
  800701:	74 06                	je     800709 <strnlen+0x1b>
  800703:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800707:	75 f5                	jne    8006fe <strnlen+0x10>
		n++;
	return n;
}
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	53                   	push   %ebx
  80070f:	8b 45 08             	mov    0x8(%ebp),%eax
  800712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800715:	ba 00 00 00 00       	mov    $0x0,%edx
  80071a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80071d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800720:	42                   	inc    %edx
  800721:	84 c9                	test   %cl,%cl
  800723:	75 f5                	jne    80071a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800725:	5b                   	pop    %ebx
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800732:	89 1c 24             	mov    %ebx,(%esp)
  800735:	e8 9e ff ff ff       	call   8006d8 <strlen>
	strcpy(dst + len, src);
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800741:	01 d8                	add    %ebx,%eax
  800743:	89 04 24             	mov    %eax,(%esp)
  800746:	e8 c0 ff ff ff       	call   80070b <strcpy>
	return dst;
}
  80074b:	89 d8                	mov    %ebx,%eax
  80074d:	83 c4 08             	add    $0x8,%esp
  800750:	5b                   	pop    %ebx
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	56                   	push   %esi
  800757:	53                   	push   %ebx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800761:	b9 00 00 00 00       	mov    $0x0,%ecx
  800766:	eb 0c                	jmp    800774 <strncpy+0x21>
		*dst++ = *src;
  800768:	8a 1a                	mov    (%edx),%bl
  80076a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076d:	80 3a 01             	cmpb   $0x1,(%edx)
  800770:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800773:	41                   	inc    %ecx
  800774:	39 f1                	cmp    %esi,%ecx
  800776:	75 f0                	jne    800768 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800778:	5b                   	pop    %ebx
  800779:	5e                   	pop    %esi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	56                   	push   %esi
  800780:	53                   	push   %ebx
  800781:	8b 75 08             	mov    0x8(%ebp),%esi
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800787:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078a:	85 d2                	test   %edx,%edx
  80078c:	75 0a                	jne    800798 <strlcpy+0x1c>
  80078e:	89 f0                	mov    %esi,%eax
  800790:	eb 1a                	jmp    8007ac <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800792:	88 18                	mov    %bl,(%eax)
  800794:	40                   	inc    %eax
  800795:	41                   	inc    %ecx
  800796:	eb 02                	jmp    80079a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800798:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80079a:	4a                   	dec    %edx
  80079b:	74 0a                	je     8007a7 <strlcpy+0x2b>
  80079d:	8a 19                	mov    (%ecx),%bl
  80079f:	84 db                	test   %bl,%bl
  8007a1:	75 ef                	jne    800792 <strlcpy+0x16>
  8007a3:	89 c2                	mov    %eax,%edx
  8007a5:	eb 02                	jmp    8007a9 <strlcpy+0x2d>
  8007a7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007a9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007ac:	29 f0                	sub    %esi,%eax
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bb:	eb 02                	jmp    8007bf <strcmp+0xd>
		p++, q++;
  8007bd:	41                   	inc    %ecx
  8007be:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007bf:	8a 01                	mov    (%ecx),%al
  8007c1:	84 c0                	test   %al,%al
  8007c3:	74 04                	je     8007c9 <strcmp+0x17>
  8007c5:	3a 02                	cmp    (%edx),%al
  8007c7:	74 f4                	je     8007bd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c9:	0f b6 c0             	movzbl %al,%eax
  8007cc:	0f b6 12             	movzbl (%edx),%edx
  8007cf:	29 d0                	sub    %edx,%eax
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007dd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007e0:	eb 03                	jmp    8007e5 <strncmp+0x12>
		n--, p++, q++;
  8007e2:	4a                   	dec    %edx
  8007e3:	40                   	inc    %eax
  8007e4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e5:	85 d2                	test   %edx,%edx
  8007e7:	74 14                	je     8007fd <strncmp+0x2a>
  8007e9:	8a 18                	mov    (%eax),%bl
  8007eb:	84 db                	test   %bl,%bl
  8007ed:	74 04                	je     8007f3 <strncmp+0x20>
  8007ef:	3a 19                	cmp    (%ecx),%bl
  8007f1:	74 ef                	je     8007e2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f3:	0f b6 00             	movzbl (%eax),%eax
  8007f6:	0f b6 11             	movzbl (%ecx),%edx
  8007f9:	29 d0                	sub    %edx,%eax
  8007fb:	eb 05                	jmp    800802 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800802:	5b                   	pop    %ebx
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80080e:	eb 05                	jmp    800815 <strchr+0x10>
		if (*s == c)
  800810:	38 ca                	cmp    %cl,%dl
  800812:	74 0c                	je     800820 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800814:	40                   	inc    %eax
  800815:	8a 10                	mov    (%eax),%dl
  800817:	84 d2                	test   %dl,%dl
  800819:	75 f5                	jne    800810 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80082b:	eb 05                	jmp    800832 <strfind+0x10>
		if (*s == c)
  80082d:	38 ca                	cmp    %cl,%dl
  80082f:	74 07                	je     800838 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800831:	40                   	inc    %eax
  800832:	8a 10                	mov    (%eax),%dl
  800834:	84 d2                	test   %dl,%dl
  800836:	75 f5                	jne    80082d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	57                   	push   %edi
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 7d 08             	mov    0x8(%ebp),%edi
  800843:	8b 45 0c             	mov    0xc(%ebp),%eax
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 30                	je     80087d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800853:	75 25                	jne    80087a <memset+0x40>
  800855:	f6 c1 03             	test   $0x3,%cl
  800858:	75 20                	jne    80087a <memset+0x40>
		c &= 0xFF;
  80085a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085d:	89 d3                	mov    %edx,%ebx
  80085f:	c1 e3 08             	shl    $0x8,%ebx
  800862:	89 d6                	mov    %edx,%esi
  800864:	c1 e6 18             	shl    $0x18,%esi
  800867:	89 d0                	mov    %edx,%eax
  800869:	c1 e0 10             	shl    $0x10,%eax
  80086c:	09 f0                	or     %esi,%eax
  80086e:	09 d0                	or     %edx,%eax
  800870:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800872:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800875:	fc                   	cld    
  800876:	f3 ab                	rep stos %eax,%es:(%edi)
  800878:	eb 03                	jmp    80087d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087a:	fc                   	cld    
  80087b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80087d:	89 f8                	mov    %edi,%eax
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5f                   	pop    %edi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	57                   	push   %edi
  800888:	56                   	push   %esi
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800892:	39 c6                	cmp    %eax,%esi
  800894:	73 34                	jae    8008ca <memmove+0x46>
  800896:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800899:	39 d0                	cmp    %edx,%eax
  80089b:	73 2d                	jae    8008ca <memmove+0x46>
		s += n;
		d += n;
  80089d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a0:	f6 c2 03             	test   $0x3,%dl
  8008a3:	75 1b                	jne    8008c0 <memmove+0x3c>
  8008a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ab:	75 13                	jne    8008c0 <memmove+0x3c>
  8008ad:	f6 c1 03             	test   $0x3,%cl
  8008b0:	75 0e                	jne    8008c0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b2:	83 ef 04             	sub    $0x4,%edi
  8008b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008bb:	fd                   	std    
  8008bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008be:	eb 07                	jmp    8008c7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c0:	4f                   	dec    %edi
  8008c1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c4:	fd                   	std    
  8008c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c7:	fc                   	cld    
  8008c8:	eb 20                	jmp    8008ea <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d0:	75 13                	jne    8008e5 <memmove+0x61>
  8008d2:	a8 03                	test   $0x3,%al
  8008d4:	75 0f                	jne    8008e5 <memmove+0x61>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 0a                	jne    8008e5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008db:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008de:	89 c7                	mov    %eax,%edi
  8008e0:	fc                   	cld    
  8008e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e3:	eb 05                	jmp    8008ea <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e5:	89 c7                	mov    %eax,%edi
  8008e7:	fc                   	cld    
  8008e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	89 04 24             	mov    %eax,(%esp)
  800908:	e8 77 ff ff ff       	call   800884 <memmove>
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	57                   	push   %edi
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 7d 08             	mov    0x8(%ebp),%edi
  800918:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091e:	ba 00 00 00 00       	mov    $0x0,%edx
  800923:	eb 16                	jmp    80093b <memcmp+0x2c>
		if (*s1 != *s2)
  800925:	8a 04 17             	mov    (%edi,%edx,1),%al
  800928:	42                   	inc    %edx
  800929:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80092d:	38 c8                	cmp    %cl,%al
  80092f:	74 0a                	je     80093b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800931:	0f b6 c0             	movzbl %al,%eax
  800934:	0f b6 c9             	movzbl %cl,%ecx
  800937:	29 c8                	sub    %ecx,%eax
  800939:	eb 09                	jmp    800944 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093b:	39 da                	cmp    %ebx,%edx
  80093d:	75 e6                	jne    800925 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5f                   	pop    %edi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800952:	89 c2                	mov    %eax,%edx
  800954:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800957:	eb 05                	jmp    80095e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800959:	38 08                	cmp    %cl,(%eax)
  80095b:	74 05                	je     800962 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095d:	40                   	inc    %eax
  80095e:	39 d0                	cmp    %edx,%eax
  800960:	72 f7                	jb     800959 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	57                   	push   %edi
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 55 08             	mov    0x8(%ebp),%edx
  80096d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800970:	eb 01                	jmp    800973 <strtol+0xf>
		s++;
  800972:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800973:	8a 02                	mov    (%edx),%al
  800975:	3c 20                	cmp    $0x20,%al
  800977:	74 f9                	je     800972 <strtol+0xe>
  800979:	3c 09                	cmp    $0x9,%al
  80097b:	74 f5                	je     800972 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097d:	3c 2b                	cmp    $0x2b,%al
  80097f:	75 08                	jne    800989 <strtol+0x25>
		s++;
  800981:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800982:	bf 00 00 00 00       	mov    $0x0,%edi
  800987:	eb 13                	jmp    80099c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800989:	3c 2d                	cmp    $0x2d,%al
  80098b:	75 0a                	jne    800997 <strtol+0x33>
		s++, neg = 1;
  80098d:	8d 52 01             	lea    0x1(%edx),%edx
  800990:	bf 01 00 00 00       	mov    $0x1,%edi
  800995:	eb 05                	jmp    80099c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800997:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099c:	85 db                	test   %ebx,%ebx
  80099e:	74 05                	je     8009a5 <strtol+0x41>
  8009a0:	83 fb 10             	cmp    $0x10,%ebx
  8009a3:	75 28                	jne    8009cd <strtol+0x69>
  8009a5:	8a 02                	mov    (%edx),%al
  8009a7:	3c 30                	cmp    $0x30,%al
  8009a9:	75 10                	jne    8009bb <strtol+0x57>
  8009ab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009af:	75 0a                	jne    8009bb <strtol+0x57>
		s += 2, base = 16;
  8009b1:	83 c2 02             	add    $0x2,%edx
  8009b4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b9:	eb 12                	jmp    8009cd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009bb:	85 db                	test   %ebx,%ebx
  8009bd:	75 0e                	jne    8009cd <strtol+0x69>
  8009bf:	3c 30                	cmp    $0x30,%al
  8009c1:	75 05                	jne    8009c8 <strtol+0x64>
		s++, base = 8;
  8009c3:	42                   	inc    %edx
  8009c4:	b3 08                	mov    $0x8,%bl
  8009c6:	eb 05                	jmp    8009cd <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009c8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d4:	8a 0a                	mov    (%edx),%cl
  8009d6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009d9:	80 fb 09             	cmp    $0x9,%bl
  8009dc:	77 08                	ja     8009e6 <strtol+0x82>
			dig = *s - '0';
  8009de:	0f be c9             	movsbl %cl,%ecx
  8009e1:	83 e9 30             	sub    $0x30,%ecx
  8009e4:	eb 1e                	jmp    800a04 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009e6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009e9:	80 fb 19             	cmp    $0x19,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009ee:	0f be c9             	movsbl %cl,%ecx
  8009f1:	83 e9 57             	sub    $0x57,%ecx
  8009f4:	eb 0e                	jmp    800a04 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009f6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8009f9:	80 fb 19             	cmp    $0x19,%bl
  8009fc:	77 12                	ja     800a10 <strtol+0xac>
			dig = *s - 'A' + 10;
  8009fe:	0f be c9             	movsbl %cl,%ecx
  800a01:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a04:	39 f1                	cmp    %esi,%ecx
  800a06:	7d 0c                	jge    800a14 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a08:	42                   	inc    %edx
  800a09:	0f af c6             	imul   %esi,%eax
  800a0c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a0e:	eb c4                	jmp    8009d4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a10:	89 c1                	mov    %eax,%ecx
  800a12:	eb 02                	jmp    800a16 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a14:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1a:	74 05                	je     800a21 <strtol+0xbd>
		*endptr = (char *) s;
  800a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a1f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a21:	85 ff                	test   %edi,%edi
  800a23:	74 04                	je     800a29 <strtol+0xc5>
  800a25:	89 c8                	mov    %ecx,%eax
  800a27:	f7 d8                	neg    %eax
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5e                   	pop    %esi
  800a2b:	5f                   	pop    %edi
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    
	...

00800a30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a41:	89 c3                	mov    %eax,%ebx
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	89 c6                	mov    %eax,%esi
  800a47:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a54:	ba 00 00 00 00       	mov    $0x0,%edx
  800a59:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5e:	89 d1                	mov    %edx,%ecx
  800a60:	89 d3                	mov    %edx,%ebx
  800a62:	89 d7                	mov    %edx,%edi
  800a64:	89 d6                	mov    %edx,%esi
  800a66:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a80:	8b 55 08             	mov    0x8(%ebp),%edx
  800a83:	89 cb                	mov    %ecx,%ebx
  800a85:	89 cf                	mov    %ecx,%edi
  800a87:	89 ce                	mov    %ecx,%esi
  800a89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8b:	85 c0                	test   %eax,%eax
  800a8d:	7e 28                	jle    800ab7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a93:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800a9a:	00 
  800a9b:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800aa2:	00 
  800aa3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aaa:	00 
  800aab:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800ab2:	e8 5d 02 00 00       	call   800d14 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab7:	83 c4 2c             	add    $0x2c,%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 02 00 00 00       	mov    $0x2,%eax
  800acf:	89 d1                	mov    %edx,%ecx
  800ad1:	89 d3                	mov    %edx,%ebx
  800ad3:	89 d7                	mov    %edx,%edi
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_yield>:

void
sys_yield(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	be 00 00 00 00       	mov    $0x0,%esi
  800b0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
  800b19:	89 f7                	mov    %esi,%edi
  800b1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	7e 28                	jle    800b49 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b25:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b2c:	00 
  800b2d:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800b34:	00 
  800b35:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b3c:	00 
  800b3d:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800b44:	e8 cb 01 00 00       	call   800d14 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b49:	83 c4 2c             	add    $0x2c,%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b70:	85 c0                	test   %eax,%eax
  800b72:	7e 28                	jle    800b9c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b78:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b7f:	00 
  800b80:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800b87:	00 
  800b88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8f:	00 
  800b90:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800b97:	e8 78 01 00 00       	call   800d14 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9c:	83 c4 2c             	add    $0x2c,%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	89 df                	mov    %ebx,%edi
  800bbf:	89 de                	mov    %ebx,%esi
  800bc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	7e 28                	jle    800bef <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bcb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bd2:	00 
  800bd3:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800bda:	00 
  800bdb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be2:	00 
  800be3:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800bea:	e8 25 01 00 00       	call   800d14 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bef:	83 c4 2c             	add    $0x2c,%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c05:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 df                	mov    %ebx,%edi
  800c12:	89 de                	mov    %ebx,%esi
  800c14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 28                	jle    800c42 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c25:	00 
  800c26:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800c2d:	00 
  800c2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c35:	00 
  800c36:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800c3d:	e8 d2 00 00 00       	call   800d14 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c42:	83 c4 2c             	add    $0x2c,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 28                	jle    800c95 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c71:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c78:	00 
  800c79:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800c80:	00 
  800c81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c88:	00 
  800c89:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800c90:	e8 7f 00 00 00       	call   800d14 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c95:	83 c4 2c             	add    $0x2c,%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	be 00 00 00 00       	mov    $0x0,%esi
  800ca8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cad:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cce:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	89 cb                	mov    %ecx,%ebx
  800cd8:	89 cf                	mov    %ecx,%edi
  800cda:	89 ce                	mov    %ecx,%esi
  800cdc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 28                	jle    800d0a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ced:	00 
  800cee:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfd:	00 
  800cfe:	c7 04 24 41 12 80 00 	movl   $0x801241,(%esp)
  800d05:	e8 0a 00 00 00       	call   800d14 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0a:	83 c4 2c             	add    $0x2c,%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
	...

00800d14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d1c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d1f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d25:	e8 95 fd ff ff       	call   800abf <sys_getenvid>
  800d2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d2d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d38:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d40:	c7 04 24 50 12 80 00 	movl   $0x801250,(%esp)
  800d47:	e8 14 f4 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d50:	8b 45 10             	mov    0x10(%ebp),%eax
  800d53:	89 04 24             	mov    %eax,(%esp)
  800d56:	e8 a4 f3 ff ff       	call   8000ff <vcprintf>
	cprintf("\n");
  800d5b:	c7 04 24 c2 0f 80 00 	movl   $0x800fc2,(%esp)
  800d62:	e8 f9 f3 ff ff       	call   800160 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d67:	cc                   	int3   
  800d68:	eb fd                	jmp    800d67 <_panic+0x53>
	...

00800d6c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d6c:	55                   	push   %ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	83 ec 10             	sub    $0x10,%esp
  800d72:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d76:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d82:	89 cd                	mov    %ecx,%ebp
  800d84:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	75 2c                	jne    800db8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d8c:	39 f9                	cmp    %edi,%ecx
  800d8e:	77 68                	ja     800df8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d90:	85 c9                	test   %ecx,%ecx
  800d92:	75 0b                	jne    800d9f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d94:	b8 01 00 00 00       	mov    $0x1,%eax
  800d99:	31 d2                	xor    %edx,%edx
  800d9b:	f7 f1                	div    %ecx
  800d9d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d9f:	31 d2                	xor    %edx,%edx
  800da1:	89 f8                	mov    %edi,%eax
  800da3:	f7 f1                	div    %ecx
  800da5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	f7 f1                	div    %ecx
  800dab:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dad:	89 f0                	mov    %esi,%eax
  800daf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800db8:	39 f8                	cmp    %edi,%eax
  800dba:	77 2c                	ja     800de8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dbc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800dbf:	83 f6 1f             	xor    $0x1f,%esi
  800dc2:	75 4c                	jne    800e10 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dc6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dcb:	72 0a                	jb     800dd7 <__udivdi3+0x6b>
  800dcd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dd1:	0f 87 ad 00 00 00    	ja     800e84 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dd7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ddc:	89 f0                	mov    %esi,%eax
  800dde:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    
  800de7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de8:	31 ff                	xor    %edi,%edi
  800dea:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dec:	89 f0                	mov    %esi,%eax
  800dee:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800df0:	83 c4 10             	add    $0x10,%esp
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    
  800df7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df8:	89 fa                	mov    %edi,%edx
  800dfa:	89 f0                	mov    %esi,%eax
  800dfc:	f7 f1                	div    %ecx
  800dfe:	89 c6                	mov    %eax,%esi
  800e00:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e02:	89 f0                	mov    %esi,%eax
  800e04:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    
  800e0d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e10:	89 f1                	mov    %esi,%ecx
  800e12:	d3 e0                	shl    %cl,%eax
  800e14:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e18:	b8 20 00 00 00       	mov    $0x20,%eax
  800e1d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e1f:	89 ea                	mov    %ebp,%edx
  800e21:	88 c1                	mov    %al,%cl
  800e23:	d3 ea                	shr    %cl,%edx
  800e25:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e29:	09 ca                	or     %ecx,%edx
  800e2b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e2f:	89 f1                	mov    %esi,%ecx
  800e31:	d3 e5                	shl    %cl,%ebp
  800e33:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e37:	89 fd                	mov    %edi,%ebp
  800e39:	88 c1                	mov    %al,%cl
  800e3b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e3d:	89 fa                	mov    %edi,%edx
  800e3f:	89 f1                	mov    %esi,%ecx
  800e41:	d3 e2                	shl    %cl,%edx
  800e43:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e47:	88 c1                	mov    %al,%cl
  800e49:	d3 ef                	shr    %cl,%edi
  800e4b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e4d:	89 f8                	mov    %edi,%eax
  800e4f:	89 ea                	mov    %ebp,%edx
  800e51:	f7 74 24 08          	divl   0x8(%esp)
  800e55:	89 d1                	mov    %edx,%ecx
  800e57:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e59:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e5d:	39 d1                	cmp    %edx,%ecx
  800e5f:	72 17                	jb     800e78 <__udivdi3+0x10c>
  800e61:	74 09                	je     800e6c <__udivdi3+0x100>
  800e63:	89 fe                	mov    %edi,%esi
  800e65:	31 ff                	xor    %edi,%edi
  800e67:	e9 41 ff ff ff       	jmp    800dad <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e6c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e70:	89 f1                	mov    %esi,%ecx
  800e72:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e74:	39 c2                	cmp    %eax,%edx
  800e76:	73 eb                	jae    800e63 <__udivdi3+0xf7>
		{
		  q0--;
  800e78:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e7b:	31 ff                	xor    %edi,%edi
  800e7d:	e9 2b ff ff ff       	jmp    800dad <__udivdi3+0x41>
  800e82:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e84:	31 f6                	xor    %esi,%esi
  800e86:	e9 22 ff ff ff       	jmp    800dad <__udivdi3+0x41>
	...

00800e8c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e8c:	55                   	push   %ebp
  800e8d:	57                   	push   %edi
  800e8e:	56                   	push   %esi
  800e8f:	83 ec 20             	sub    $0x20,%esp
  800e92:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e96:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e9a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e9e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800ea2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ea6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800eaa:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800eac:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800eae:	85 ed                	test   %ebp,%ebp
  800eb0:	75 16                	jne    800ec8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800eb2:	39 f1                	cmp    %esi,%ecx
  800eb4:	0f 86 a6 00 00 00    	jbe    800f60 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eba:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ebc:	89 d0                	mov    %edx,%eax
  800ebe:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ec0:	83 c4 20             	add    $0x20,%esp
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    
  800ec7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ec8:	39 f5                	cmp    %esi,%ebp
  800eca:	0f 87 ac 00 00 00    	ja     800f7c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ed0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800ed3:	83 f0 1f             	xor    $0x1f,%eax
  800ed6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eda:	0f 84 a8 00 00 00    	je     800f88 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ee0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ee4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ee6:	bf 20 00 00 00       	mov    $0x20,%edi
  800eeb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800eef:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ef3:	89 f9                	mov    %edi,%ecx
  800ef5:	d3 e8                	shr    %cl,%eax
  800ef7:	09 e8                	or     %ebp,%eax
  800ef9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800efd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f01:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f05:	d3 e0                	shl    %cl,%eax
  800f07:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f0b:	89 f2                	mov    %esi,%edx
  800f0d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f0f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f13:	d3 e0                	shl    %cl,%eax
  800f15:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f19:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f1d:	89 f9                	mov    %edi,%ecx
  800f1f:	d3 e8                	shr    %cl,%eax
  800f21:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f23:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f25:	89 f2                	mov    %esi,%edx
  800f27:	f7 74 24 18          	divl   0x18(%esp)
  800f2b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f2d:	f7 64 24 0c          	mull   0xc(%esp)
  800f31:	89 c5                	mov    %eax,%ebp
  800f33:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f35:	39 d6                	cmp    %edx,%esi
  800f37:	72 67                	jb     800fa0 <__umoddi3+0x114>
  800f39:	74 75                	je     800fb0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f3b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f3f:	29 e8                	sub    %ebp,%eax
  800f41:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f43:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f47:	d3 e8                	shr    %cl,%eax
  800f49:	89 f2                	mov    %esi,%edx
  800f4b:	89 f9                	mov    %edi,%ecx
  800f4d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f4f:	09 d0                	or     %edx,%eax
  800f51:	89 f2                	mov    %esi,%edx
  800f53:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f57:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f59:	83 c4 20             	add    $0x20,%esp
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f60:	85 c9                	test   %ecx,%ecx
  800f62:	75 0b                	jne    800f6f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f64:	b8 01 00 00 00       	mov    $0x1,%eax
  800f69:	31 d2                	xor    %edx,%edx
  800f6b:	f7 f1                	div    %ecx
  800f6d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f6f:	89 f0                	mov    %esi,%eax
  800f71:	31 d2                	xor    %edx,%edx
  800f73:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f75:	89 f8                	mov    %edi,%eax
  800f77:	e9 3e ff ff ff       	jmp    800eba <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f7c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f7e:	83 c4 20             	add    $0x20,%esp
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    
  800f85:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f88:	39 f5                	cmp    %esi,%ebp
  800f8a:	72 04                	jb     800f90 <__umoddi3+0x104>
  800f8c:	39 f9                	cmp    %edi,%ecx
  800f8e:	77 06                	ja     800f96 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f90:	89 f2                	mov    %esi,%edx
  800f92:	29 cf                	sub    %ecx,%edi
  800f94:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f96:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f98:	83 c4 20             	add    $0x20,%esp
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    
  800f9f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fa0:	89 d1                	mov    %edx,%ecx
  800fa2:	89 c5                	mov    %eax,%ebp
  800fa4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fa8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fac:	eb 8d                	jmp    800f3b <__umoddi3+0xaf>
  800fae:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fb0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fb4:	72 ea                	jb     800fa0 <__umoddi3+0x114>
  800fb6:	89 f1                	mov    %esi,%ecx
  800fb8:	eb 81                	jmp    800f3b <__umoddi3+0xaf>
