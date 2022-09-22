
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 e0 0f 80 00 	movl   $0x800fe0,(%esp)
  80004a:	e8 21 01 00 00       	call   800170 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 20             	sub    $0x20,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800062:	e8 68 0a 00 00       	call   800acf <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  80008c:	c7 04 24 fe 0f 80 00 	movl   $0x800ffe,(%esp)
  800093:	e8 d8 00 00 00       	call   800170 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800098:	85 f6                	test   %esi,%esi
  80009a:	7e 07                	jle    8000a3 <libmain+0x4f>
		binaryname = argv[0];
  80009c:	8b 03                	mov    (%ebx),%eax
  80009e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a7:	89 34 24             	mov    %esi,(%esp)
  8000aa:	e8 85 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000af:	e8 08 00 00 00       	call   8000bc <exit>
}
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    
	...

008000bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c9:	e8 af 09 00 00       	call   800a7d <sys_env_destroy>
}
  8000ce:	c9                   	leave  
  8000cf:	c3                   	ret    

008000d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 14             	sub    $0x14,%esp
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000da:	8b 03                	mov    (%ebx),%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e3:	40                   	inc    %eax
  8000e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000eb:	75 19                	jne    800106 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000f4:	00 
  8000f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 40 09 00 00       	call   800a40 <sys_cputs>
		b->idx = 0;
  800100:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800106:	ff 43 04             	incl   0x4(%ebx)
}
  800109:	83 c4 14             	add    $0x14,%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800133:	8b 45 08             	mov    0x8(%ebp),%eax
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800140:	89 44 24 04          	mov    %eax,0x4(%esp)
  800144:	c7 04 24 d0 00 80 00 	movl   $0x8000d0,(%esp)
  80014b:	e8 82 01 00 00       	call   8002d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800150:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800160:	89 04 24             	mov    %eax,(%esp)
  800163:	e8 d8 08 00 00       	call   800a40 <sys_cputs>

	return b.cnt;
}
  800168:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800176:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800179:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017d:	8b 45 08             	mov    0x8(%ebp),%eax
  800180:	89 04 24             	mov    %eax,(%esp)
  800183:	e8 87 ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800188:	c9                   	leave  
  800189:	c3                   	ret    
	...

0080018c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 3c             	sub    $0x3c,%esp
  800195:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800198:	89 d7                	mov    %edx,%edi
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	75 08                	jne    8001b8 <printnum+0x2c>
  8001b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b6:	77 57                	ja     80020f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001bc:	4b                   	dec    %ebx
  8001bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001cc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d7:	00 
  8001d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	e8 92 0b 00 00       	call   800d7c <__udivdi3>
  8001ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f9:	89 fa                	mov    %edi,%edx
  8001fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fe:	e8 89 ff ff ff       	call   80018c <printnum>
  800203:	eb 0f                	jmp    800214 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800205:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800209:	89 34 24             	mov    %esi,(%esp)
  80020c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020f:	4b                   	dec    %ebx
  800210:	85 db                	test   %ebx,%ebx
  800212:	7f f1                	jg     800205 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800214:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800218:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021c:	8b 45 10             	mov    0x10(%ebp),%eax
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022a:	00 
  80022b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	e8 5f 0c 00 00       	call   800e9c <__umoddi3>
  80023d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800241:	0f be 80 0c 10 80 00 	movsbl 0x80100c(%eax),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80024e:	83 c4 3c             	add    $0x3c,%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800259:	83 fa 01             	cmp    $0x1,%edx
  80025c:	7e 0e                	jle    80026c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 4a 08             	lea    0x8(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	8b 52 04             	mov    0x4(%edx),%edx
  80026a:	eb 22                	jmp    80028e <getuint+0x38>
	else if (lflag)
  80026c:	85 d2                	test   %edx,%edx
  80026e:	74 10                	je     800280 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 04             	lea    0x4(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
  80027e:	eb 0e                	jmp    80028e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 04             	lea    0x4(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    

00800290 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800296:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	3b 50 04             	cmp    0x4(%eax),%edx
  80029e:	73 08                	jae    8002a8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a3:	88 0a                	mov    %cl,(%edx)
  8002a5:	42                   	inc    %edx
  8002a6:	89 10                	mov    %edx,(%eax)
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	e8 02 00 00 00       	call   8002d2 <vprintfmt>
	va_end(ap);
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 4c             	sub    $0x4c,%esp
  8002db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002de:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e1:	eb 12                	jmp    8002f5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	0f 84 6b 03 00 00    	je     800656 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f5:	0f b6 06             	movzbl (%esi),%eax
  8002f8:	46                   	inc    %esi
  8002f9:	83 f8 25             	cmp    $0x25,%eax
  8002fc:	75 e5                	jne    8002e3 <vprintfmt+0x11>
  8002fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800302:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800309:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80030e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800315:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031a:	eb 26                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800323:	eb 1d                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800328:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80032c:	eb 14                	jmp    800342 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800331:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800338:	eb 08                	jmp    800342 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80033a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80033d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	0f b6 06             	movzbl (%esi),%eax
  800345:	8d 56 01             	lea    0x1(%esi),%edx
  800348:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80034b:	8a 16                	mov    (%esi),%dl
  80034d:	83 ea 23             	sub    $0x23,%edx
  800350:	80 fa 55             	cmp    $0x55,%dl
  800353:	0f 87 e1 02 00 00    	ja     80063a <vprintfmt+0x368>
  800359:	0f b6 d2             	movzbl %dl,%edx
  80035c:	ff 24 95 e0 10 80 00 	jmp    *0x8010e0(,%edx,4)
  800363:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800366:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80036e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800372:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800375:	8d 50 d0             	lea    -0x30(%eax),%edx
  800378:	83 fa 09             	cmp    $0x9,%edx
  80037b:	77 2a                	ja     8003a7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037e:	eb eb                	jmp    80036b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 50 04             	lea    0x4(%eax),%edx
  800386:	89 55 14             	mov    %edx,0x14(%ebp)
  800389:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038e:	eb 17                	jmp    8003a7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800390:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800394:	78 98                	js     80032e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800399:	eb a7                	jmp    800342 <vprintfmt+0x70>
  80039b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003a5:	eb 9b                	jmp    800342 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ab:	79 95                	jns    800342 <vprintfmt+0x70>
  8003ad:	eb 8b                	jmp    80033a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003af:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b3:	eb 8d                	jmp    800342 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 50 04             	lea    0x4(%eax),%edx
  8003bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003cd:	e9 23 ff ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 50 04             	lea    0x4(%eax),%edx
  8003d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	79 02                	jns    8003e3 <vprintfmt+0x111>
  8003e1:	f7 d8                	neg    %eax
  8003e3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e5:	83 f8 08             	cmp    $0x8,%eax
  8003e8:	7f 0b                	jg     8003f5 <vprintfmt+0x123>
  8003ea:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  8003f1:	85 c0                	test   %eax,%eax
  8003f3:	75 23                	jne    800418 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f9:	c7 44 24 08 24 10 80 	movl   $0x801024,0x8(%esp)
  800400:	00 
  800401:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 9a fe ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800413:	e9 dd fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800418:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041c:	c7 44 24 08 2d 10 80 	movl   $0x80102d,0x8(%esp)
  800423:	00 
  800424:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800428:	8b 55 08             	mov    0x8(%ebp),%edx
  80042b:	89 14 24             	mov    %edx,(%esp)
  80042e:	e8 77 fe ff ff       	call   8002aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800436:	e9 ba fe ff ff       	jmp    8002f5 <vprintfmt+0x23>
  80043b:	89 f9                	mov    %edi,%ecx
  80043d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800440:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 30                	mov    (%eax),%esi
  80044e:	85 f6                	test   %esi,%esi
  800450:	75 05                	jne    800457 <vprintfmt+0x185>
				p = "(null)";
  800452:	be 1d 10 80 00       	mov    $0x80101d,%esi
			if (width > 0 && padc != '-')
  800457:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045b:	0f 8e 84 00 00 00    	jle    8004e5 <vprintfmt+0x213>
  800461:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800465:	74 7e                	je     8004e5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80046b:	89 34 24             	mov    %esi,(%esp)
  80046e:	e8 8b 02 00 00       	call   8006fe <strnlen>
  800473:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800476:	29 c2                	sub    %eax,%edx
  800478:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80047b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80047f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800482:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800485:	89 de                	mov    %ebx,%esi
  800487:	89 d3                	mov    %edx,%ebx
  800489:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	eb 0b                	jmp    800498 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80048d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800491:	89 3c 24             	mov    %edi,(%esp)
  800494:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	4b                   	dec    %ebx
  800498:	85 db                	test   %ebx,%ebx
  80049a:	7f f1                	jg     80048d <vprintfmt+0x1bb>
  80049c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80049f:	89 f3                	mov    %esi,%ebx
  8004a1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	79 05                	jns    8004b0 <vprintfmt+0x1de>
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b3:	29 c2                	sub    %eax,%edx
  8004b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b8:	eb 2b                	jmp    8004e5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004be:	74 18                	je     8004d8 <vprintfmt+0x206>
  8004c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c3:	83 fa 5e             	cmp    $0x5e,%edx
  8004c6:	76 10                	jbe    8004d8 <vprintfmt+0x206>
					putch('?', putdat);
  8004c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
  8004d6:	eb 0a                	jmp    8004e2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e5:	0f be 06             	movsbl (%esi),%eax
  8004e8:	46                   	inc    %esi
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	74 21                	je     80050e <vprintfmt+0x23c>
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	78 c9                	js     8004ba <vprintfmt+0x1e8>
  8004f1:	4f                   	dec    %edi
  8004f2:	79 c6                	jns    8004ba <vprintfmt+0x1e8>
  8004f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004f7:	89 de                	mov    %ebx,%esi
  8004f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004fc:	eb 18                	jmp    800516 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800502:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800509:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050b:	4b                   	dec    %ebx
  80050c:	eb 08                	jmp    800516 <vprintfmt+0x244>
  80050e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800511:	89 de                	mov    %ebx,%esi
  800513:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800516:	85 db                	test   %ebx,%ebx
  800518:	7f e4                	jg     8004fe <vprintfmt+0x22c>
  80051a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80051d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800522:	e9 ce fd ff ff       	jmp    8002f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800527:	83 f9 01             	cmp    $0x1,%ecx
  80052a:	7e 10                	jle    80053c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 08             	lea    0x8(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	8b 30                	mov    (%eax),%esi
  800537:	8b 78 04             	mov    0x4(%eax),%edi
  80053a:	eb 26                	jmp    800562 <vprintfmt+0x290>
	else if (lflag)
  80053c:	85 c9                	test   %ecx,%ecx
  80053e:	74 12                	je     800552 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 30                	mov    (%eax),%esi
  80054b:	89 f7                	mov    %esi,%edi
  80054d:	c1 ff 1f             	sar    $0x1f,%edi
  800550:	eb 10                	jmp    800562 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 30                	mov    (%eax),%esi
  80055d:	89 f7                	mov    %esi,%edi
  80055f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800562:	85 ff                	test   %edi,%edi
  800564:	78 0a                	js     800570 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056b:	e9 8c 00 00 00       	jmp    8005fc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80057b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80057e:	f7 de                	neg    %esi
  800580:	83 d7 00             	adc    $0x0,%edi
  800583:	f7 df                	neg    %edi
			}
			base = 10;
  800585:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058a:	eb 70                	jmp    8005fc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058c:	89 ca                	mov    %ecx,%edx
  80058e:	8d 45 14             	lea    0x14(%ebp),%eax
  800591:	e8 c0 fc ff ff       	call   800256 <getuint>
  800596:	89 c6                	mov    %eax,%esi
  800598:	89 d7                	mov    %edx,%edi
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80059f:	eb 5b                	jmp    8005fc <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005a1:	89 ca                	mov    %ecx,%edx
  8005a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a6:	e8 ab fc ff ff       	call   800256 <getuint>
  8005ab:	89 c6                	mov    %eax,%esi
  8005ad:	89 d7                	mov    %edx,%edi
			base = 8;
  8005af:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005b4:	eb 46                	jmp    8005fc <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ba:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005c1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005db:	8b 30                	mov    (%eax),%esi
  8005dd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005e7:	eb 13                	jmp    8005fc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e9:	89 ca                	mov    %ecx,%edx
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 63 fc ff ff       	call   800256 <getuint>
  8005f3:	89 c6                	mov    %eax,%esi
  8005f5:	89 d7                	mov    %edx,%edi
			base = 16;
  8005f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005fc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800600:	89 54 24 10          	mov    %edx,0x10(%esp)
  800604:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800607:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060f:	89 34 24             	mov    %esi,(%esp)
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	89 da                	mov    %ebx,%edx
  800618:	8b 45 08             	mov    0x8(%ebp),%eax
  80061b:	e8 6c fb ff ff       	call   80018c <printnum>
			break;
  800620:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800623:	e9 cd fc ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	89 04 24             	mov    %eax,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800635:	e9 bb fc ff ff       	jmp    8002f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800648:	eb 01                	jmp    80064b <vprintfmt+0x379>
  80064a:	4e                   	dec    %esi
  80064b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80064f:	75 f9                	jne    80064a <vprintfmt+0x378>
  800651:	e9 9f fc ff ff       	jmp    8002f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800656:	83 c4 4c             	add    $0x4c,%esp
  800659:	5b                   	pop    %ebx
  80065a:	5e                   	pop    %esi
  80065b:	5f                   	pop    %edi
  80065c:	5d                   	pop    %ebp
  80065d:	c3                   	ret    

0080065e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065e:	55                   	push   %ebp
  80065f:	89 e5                	mov    %esp,%ebp
  800661:	83 ec 28             	sub    $0x28,%esp
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80066d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800671:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800674:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067b:	85 c0                	test   %eax,%eax
  80067d:	74 30                	je     8006af <vsnprintf+0x51>
  80067f:	85 d2                	test   %edx,%edx
  800681:	7e 33                	jle    8006b6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068a:	8b 45 10             	mov    0x10(%ebp),%eax
  80068d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800691:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800694:	89 44 24 04          	mov    %eax,0x4(%esp)
  800698:	c7 04 24 90 02 80 00 	movl   $0x800290,(%esp)
  80069f:	e8 2e fc ff ff       	call   8002d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ad:	eb 0c                	jmp    8006bb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b4:	eb 05                	jmp    8006bb <vsnprintf+0x5d>
  8006b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	e8 7b ff ff ff       	call   80065e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    
  8006e5:	00 00                	add    %al,(%eax)
	...

008006e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f3:	eb 01                	jmp    8006f6 <strlen+0xe>
		n++;
  8006f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fa:	75 f9                	jne    8006f5 <strlen+0xd>
		n++;
	return n;
}
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800704:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
  80070c:	eb 01                	jmp    80070f <strnlen+0x11>
		n++;
  80070e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070f:	39 d0                	cmp    %edx,%eax
  800711:	74 06                	je     800719 <strnlen+0x1b>
  800713:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800717:	75 f5                	jne    80070e <strnlen+0x10>
		n++;
	return n;
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800725:	ba 00 00 00 00       	mov    $0x0,%edx
  80072a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80072d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800730:	42                   	inc    %edx
  800731:	84 c9                	test   %cl,%cl
  800733:	75 f5                	jne    80072a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800735:	5b                   	pop    %ebx
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800742:	89 1c 24             	mov    %ebx,(%esp)
  800745:	e8 9e ff ff ff       	call   8006e8 <strlen>
	strcpy(dst + len, src);
  80074a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800751:	01 d8                	add    %ebx,%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 c0 ff ff ff       	call   80071b <strcpy>
	return dst;
}
  80075b:	89 d8                	mov    %ebx,%eax
  80075d:	83 c4 08             	add    $0x8,%esp
  800760:	5b                   	pop    %ebx
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	56                   	push   %esi
  800767:	53                   	push   %ebx
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800771:	b9 00 00 00 00       	mov    $0x0,%ecx
  800776:	eb 0c                	jmp    800784 <strncpy+0x21>
		*dst++ = *src;
  800778:	8a 1a                	mov    (%edx),%bl
  80077a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077d:	80 3a 01             	cmpb   $0x1,(%edx)
  800780:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800783:	41                   	inc    %ecx
  800784:	39 f1                	cmp    %esi,%ecx
  800786:	75 f0                	jne    800778 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	56                   	push   %esi
  800790:	53                   	push   %ebx
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800797:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079a:	85 d2                	test   %edx,%edx
  80079c:	75 0a                	jne    8007a8 <strlcpy+0x1c>
  80079e:	89 f0                	mov    %esi,%eax
  8007a0:	eb 1a                	jmp    8007bc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a2:	88 18                	mov    %bl,(%eax)
  8007a4:	40                   	inc    %eax
  8007a5:	41                   	inc    %ecx
  8007a6:	eb 02                	jmp    8007aa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007aa:	4a                   	dec    %edx
  8007ab:	74 0a                	je     8007b7 <strlcpy+0x2b>
  8007ad:	8a 19                	mov    (%ecx),%bl
  8007af:	84 db                	test   %bl,%bl
  8007b1:	75 ef                	jne    8007a2 <strlcpy+0x16>
  8007b3:	89 c2                	mov    %eax,%edx
  8007b5:	eb 02                	jmp    8007b9 <strlcpy+0x2d>
  8007b7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007b9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007bc:	29 f0                	sub    %esi,%eax
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cb:	eb 02                	jmp    8007cf <strcmp+0xd>
		p++, q++;
  8007cd:	41                   	inc    %ecx
  8007ce:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cf:	8a 01                	mov    (%ecx),%al
  8007d1:	84 c0                	test   %al,%al
  8007d3:	74 04                	je     8007d9 <strcmp+0x17>
  8007d5:	3a 02                	cmp    (%edx),%al
  8007d7:	74 f4                	je     8007cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d9:	0f b6 c0             	movzbl %al,%eax
  8007dc:	0f b6 12             	movzbl (%edx),%edx
  8007df:	29 d0                	sub    %edx,%eax
}
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ed:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007f0:	eb 03                	jmp    8007f5 <strncmp+0x12>
		n--, p++, q++;
  8007f2:	4a                   	dec    %edx
  8007f3:	40                   	inc    %eax
  8007f4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f5:	85 d2                	test   %edx,%edx
  8007f7:	74 14                	je     80080d <strncmp+0x2a>
  8007f9:	8a 18                	mov    (%eax),%bl
  8007fb:	84 db                	test   %bl,%bl
  8007fd:	74 04                	je     800803 <strncmp+0x20>
  8007ff:	3a 19                	cmp    (%ecx),%bl
  800801:	74 ef                	je     8007f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800803:	0f b6 00             	movzbl (%eax),%eax
  800806:	0f b6 11             	movzbl (%ecx),%edx
  800809:	29 d0                	sub    %edx,%eax
  80080b:	eb 05                	jmp    800812 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80081e:	eb 05                	jmp    800825 <strchr+0x10>
		if (*s == c)
  800820:	38 ca                	cmp    %cl,%dl
  800822:	74 0c                	je     800830 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800824:	40                   	inc    %eax
  800825:	8a 10                	mov    (%eax),%dl
  800827:	84 d2                	test   %dl,%dl
  800829:	75 f5                	jne    800820 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80083b:	eb 05                	jmp    800842 <strfind+0x10>
		if (*s == c)
  80083d:	38 ca                	cmp    %cl,%dl
  80083f:	74 07                	je     800848 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800841:	40                   	inc    %eax
  800842:	8a 10                	mov    (%eax),%dl
  800844:	84 d2                	test   %dl,%dl
  800846:	75 f5                	jne    80083d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	57                   	push   %edi
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 7d 08             	mov    0x8(%ebp),%edi
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
  800856:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800859:	85 c9                	test   %ecx,%ecx
  80085b:	74 30                	je     80088d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800863:	75 25                	jne    80088a <memset+0x40>
  800865:	f6 c1 03             	test   $0x3,%cl
  800868:	75 20                	jne    80088a <memset+0x40>
		c &= 0xFF;
  80086a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086d:	89 d3                	mov    %edx,%ebx
  80086f:	c1 e3 08             	shl    $0x8,%ebx
  800872:	89 d6                	mov    %edx,%esi
  800874:	c1 e6 18             	shl    $0x18,%esi
  800877:	89 d0                	mov    %edx,%eax
  800879:	c1 e0 10             	shl    $0x10,%eax
  80087c:	09 f0                	or     %esi,%eax
  80087e:	09 d0                	or     %edx,%eax
  800880:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800882:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800885:	fc                   	cld    
  800886:	f3 ab                	rep stos %eax,%es:(%edi)
  800888:	eb 03                	jmp    80088d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088a:	fc                   	cld    
  80088b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80088d:	89 f8                	mov    %edi,%eax
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5f                   	pop    %edi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	57                   	push   %edi
  800898:	56                   	push   %esi
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a2:	39 c6                	cmp    %eax,%esi
  8008a4:	73 34                	jae    8008da <memmove+0x46>
  8008a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a9:	39 d0                	cmp    %edx,%eax
  8008ab:	73 2d                	jae    8008da <memmove+0x46>
		s += n;
		d += n;
  8008ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b0:	f6 c2 03             	test   $0x3,%dl
  8008b3:	75 1b                	jne    8008d0 <memmove+0x3c>
  8008b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bb:	75 13                	jne    8008d0 <memmove+0x3c>
  8008bd:	f6 c1 03             	test   $0x3,%cl
  8008c0:	75 0e                	jne    8008d0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008c2:	83 ef 04             	sub    $0x4,%edi
  8008c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008cb:	fd                   	std    
  8008cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ce:	eb 07                	jmp    8008d7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008d0:	4f                   	dec    %edi
  8008d1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d4:	fd                   	std    
  8008d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d7:	fc                   	cld    
  8008d8:	eb 20                	jmp    8008fa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e0:	75 13                	jne    8008f5 <memmove+0x61>
  8008e2:	a8 03                	test   $0x3,%al
  8008e4:	75 0f                	jne    8008f5 <memmove+0x61>
  8008e6:	f6 c1 03             	test   $0x3,%cl
  8008e9:	75 0a                	jne    8008f5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008eb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ee:	89 c7                	mov    %eax,%edi
  8008f0:	fc                   	cld    
  8008f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f3:	eb 05                	jmp    8008fa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f5:	89 c7                	mov    %eax,%edi
  8008f7:	fc                   	cld    
  8008f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800904:	8b 45 10             	mov    0x10(%ebp),%eax
  800907:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	89 04 24             	mov    %eax,(%esp)
  800918:	e8 77 ff ff ff       	call   800894 <memmove>
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	57                   	push   %edi
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
  800925:	8b 7d 08             	mov    0x8(%ebp),%edi
  800928:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092e:	ba 00 00 00 00       	mov    $0x0,%edx
  800933:	eb 16                	jmp    80094b <memcmp+0x2c>
		if (*s1 != *s2)
  800935:	8a 04 17             	mov    (%edi,%edx,1),%al
  800938:	42                   	inc    %edx
  800939:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80093d:	38 c8                	cmp    %cl,%al
  80093f:	74 0a                	je     80094b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800941:	0f b6 c0             	movzbl %al,%eax
  800944:	0f b6 c9             	movzbl %cl,%ecx
  800947:	29 c8                	sub    %ecx,%eax
  800949:	eb 09                	jmp    800954 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	39 da                	cmp    %ebx,%edx
  80094d:	75 e6                	jne    800935 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5f                   	pop    %edi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800962:	89 c2                	mov    %eax,%edx
  800964:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800967:	eb 05                	jmp    80096e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800969:	38 08                	cmp    %cl,(%eax)
  80096b:	74 05                	je     800972 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096d:	40                   	inc    %eax
  80096e:	39 d0                	cmp    %edx,%eax
  800970:	72 f7                	jb     800969 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 55 08             	mov    0x8(%ebp),%edx
  80097d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800980:	eb 01                	jmp    800983 <strtol+0xf>
		s++;
  800982:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800983:	8a 02                	mov    (%edx),%al
  800985:	3c 20                	cmp    $0x20,%al
  800987:	74 f9                	je     800982 <strtol+0xe>
  800989:	3c 09                	cmp    $0x9,%al
  80098b:	74 f5                	je     800982 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098d:	3c 2b                	cmp    $0x2b,%al
  80098f:	75 08                	jne    800999 <strtol+0x25>
		s++;
  800991:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800992:	bf 00 00 00 00       	mov    $0x0,%edi
  800997:	eb 13                	jmp    8009ac <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800999:	3c 2d                	cmp    $0x2d,%al
  80099b:	75 0a                	jne    8009a7 <strtol+0x33>
		s++, neg = 1;
  80099d:	8d 52 01             	lea    0x1(%edx),%edx
  8009a0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009a5:	eb 05                	jmp    8009ac <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ac:	85 db                	test   %ebx,%ebx
  8009ae:	74 05                	je     8009b5 <strtol+0x41>
  8009b0:	83 fb 10             	cmp    $0x10,%ebx
  8009b3:	75 28                	jne    8009dd <strtol+0x69>
  8009b5:	8a 02                	mov    (%edx),%al
  8009b7:	3c 30                	cmp    $0x30,%al
  8009b9:	75 10                	jne    8009cb <strtol+0x57>
  8009bb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009bf:	75 0a                	jne    8009cb <strtol+0x57>
		s += 2, base = 16;
  8009c1:	83 c2 02             	add    $0x2,%edx
  8009c4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c9:	eb 12                	jmp    8009dd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009cb:	85 db                	test   %ebx,%ebx
  8009cd:	75 0e                	jne    8009dd <strtol+0x69>
  8009cf:	3c 30                	cmp    $0x30,%al
  8009d1:	75 05                	jne    8009d8 <strtol+0x64>
		s++, base = 8;
  8009d3:	42                   	inc    %edx
  8009d4:	b3 08                	mov    $0x8,%bl
  8009d6:	eb 05                	jmp    8009dd <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009d8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e4:	8a 0a                	mov    (%edx),%cl
  8009e6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009e9:	80 fb 09             	cmp    $0x9,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0x82>
			dig = *s - '0';
  8009ee:	0f be c9             	movsbl %cl,%ecx
  8009f1:	83 e9 30             	sub    $0x30,%ecx
  8009f4:	eb 1e                	jmp    800a14 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009f6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009f9:	80 fb 19             	cmp    $0x19,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0x92>
			dig = *s - 'a' + 10;
  8009fe:	0f be c9             	movsbl %cl,%ecx
  800a01:	83 e9 57             	sub    $0x57,%ecx
  800a04:	eb 0e                	jmp    800a14 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a06:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a09:	80 fb 19             	cmp    $0x19,%bl
  800a0c:	77 12                	ja     800a20 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a0e:	0f be c9             	movsbl %cl,%ecx
  800a11:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a14:	39 f1                	cmp    %esi,%ecx
  800a16:	7d 0c                	jge    800a24 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a18:	42                   	inc    %edx
  800a19:	0f af c6             	imul   %esi,%eax
  800a1c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a1e:	eb c4                	jmp    8009e4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a20:	89 c1                	mov    %eax,%ecx
  800a22:	eb 02                	jmp    800a26 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a24:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2a:	74 05                	je     800a31 <strtol+0xbd>
		*endptr = (char *) s;
  800a2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a2f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a31:	85 ff                	test   %edi,%edi
  800a33:	74 04                	je     800a39 <strtol+0xc5>
  800a35:	89 c8                	mov    %ecx,%eax
  800a37:	f7 d8                	neg    %eax
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    
	...

00800a40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a51:	89 c3                	mov    %eax,%ebx
  800a53:	89 c7                	mov    %eax,%edi
  800a55:	89 c6                	mov    %eax,%esi
  800a57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
  800a69:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6e:	89 d1                	mov    %edx,%ecx
  800a70:	89 d3                	mov    %edx,%ebx
  800a72:	89 d7                	mov    %edx,%edi
  800a74:	89 d6                	mov    %edx,%esi
  800a76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a90:	8b 55 08             	mov    0x8(%ebp),%edx
  800a93:	89 cb                	mov    %ecx,%ebx
  800a95:	89 cf                	mov    %ecx,%edi
  800a97:	89 ce                	mov    %ecx,%esi
  800a99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a9b:	85 c0                	test   %eax,%eax
  800a9d:	7e 28                	jle    800ac7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aa3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aaa:	00 
  800aab:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800ab2:	00 
  800ab3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aba:	00 
  800abb:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800ac2:	e8 5d 02 00 00       	call   800d24 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac7:	83 c4 2c             	add    $0x2c,%esp
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 02 00 00 00       	mov    $0x2,%eax
  800adf:	89 d1                	mov    %edx,%ecx
  800ae1:	89 d3                	mov    %edx,%ebx
  800ae3:	89 d7                	mov    %edx,%edi
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_yield>:

void
sys_yield(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	be 00 00 00 00       	mov    $0x0,%esi
  800b1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	89 f7                	mov    %esi,%edi
  800b2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	7e 28                	jle    800b59 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b35:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b3c:	00 
  800b3d:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800b44:	00 
  800b45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4c:	00 
  800b4d:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800b54:	e8 cb 01 00 00       	call   800d24 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b59:	83 c4 2c             	add    $0x2c,%esp
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b80:	85 c0                	test   %eax,%eax
  800b82:	7e 28                	jle    800bac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b8f:	00 
  800b90:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800b97:	00 
  800b98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9f:	00 
  800ba0:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800ba7:	e8 78 01 00 00       	call   800d24 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bac:	83 c4 2c             	add    $0x2c,%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	89 df                	mov    %ebx,%edi
  800bcf:	89 de                	mov    %ebx,%esi
  800bd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 28                	jle    800bff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800be2:	00 
  800be3:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800bea:	00 
  800beb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf2:	00 
  800bf3:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800bfa:	e8 25 01 00 00       	call   800d24 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bff:	83 c4 2c             	add    $0x2c,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c15:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	89 df                	mov    %ebx,%edi
  800c22:	89 de                	mov    %ebx,%esi
  800c24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c26:	85 c0                	test   %eax,%eax
  800c28:	7e 28                	jle    800c52 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c35:	00 
  800c36:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800c3d:	00 
  800c3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c45:	00 
  800c46:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800c4d:	e8 d2 00 00 00       	call   800d24 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c52:	83 c4 2c             	add    $0x2c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c68:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	89 df                	mov    %ebx,%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 28                	jle    800ca5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c81:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c88:	00 
  800c89:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800c90:	00 
  800c91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c98:	00 
  800c99:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800ca0:	e8 7f 00 00 00       	call   800d24 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca5:	83 c4 2c             	add    $0x2c,%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	be 00 00 00 00       	mov    $0x0,%esi
  800cb8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	89 cb                	mov    %ecx,%ebx
  800ce8:	89 cf                	mov    %ecx,%edi
  800cea:	89 ce                	mov    %ecx,%esi
  800cec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7e 28                	jle    800d1a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800cfd:	00 
  800cfe:	c7 44 24 08 64 12 80 	movl   $0x801264,0x8(%esp)
  800d05:	00 
  800d06:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0d:	00 
  800d0e:	c7 04 24 81 12 80 00 	movl   $0x801281,(%esp)
  800d15:	e8 0a 00 00 00       	call   800d24 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1a:	83 c4 2c             	add    $0x2c,%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
	...

00800d24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d2c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d2f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d35:	e8 95 fd ff ff       	call   800acf <sys_getenvid>
  800d3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d48:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d50:	c7 04 24 90 12 80 00 	movl   $0x801290,(%esp)
  800d57:	e8 14 f4 ff ff       	call   800170 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d60:	8b 45 10             	mov    0x10(%ebp),%eax
  800d63:	89 04 24             	mov    %eax,(%esp)
  800d66:	e8 a4 f3 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  800d6b:	c7 04 24 fc 0f 80 00 	movl   $0x800ffc,(%esp)
  800d72:	e8 f9 f3 ff ff       	call   800170 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d77:	cc                   	int3   
  800d78:	eb fd                	jmp    800d77 <_panic+0x53>
	...

00800d7c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d7c:	55                   	push   %ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	83 ec 10             	sub    $0x10,%esp
  800d82:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d86:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d92:	89 cd                	mov    %ecx,%ebp
  800d94:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	75 2c                	jne    800dc8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d9c:	39 f9                	cmp    %edi,%ecx
  800d9e:	77 68                	ja     800e08 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800da0:	85 c9                	test   %ecx,%ecx
  800da2:	75 0b                	jne    800daf <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800da4:	b8 01 00 00 00       	mov    $0x1,%eax
  800da9:	31 d2                	xor    %edx,%edx
  800dab:	f7 f1                	div    %ecx
  800dad:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800daf:	31 d2                	xor    %edx,%edx
  800db1:	89 f8                	mov    %edi,%eax
  800db3:	f7 f1                	div    %ecx
  800db5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db7:	89 f0                	mov    %esi,%eax
  800db9:	f7 f1                	div    %ecx
  800dbb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dc1:	83 c4 10             	add    $0x10,%esp
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dc8:	39 f8                	cmp    %edi,%eax
  800dca:	77 2c                	ja     800df8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800dcc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800dcf:	83 f6 1f             	xor    $0x1f,%esi
  800dd2:	75 4c                	jne    800e20 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dd4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dd6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ddb:	72 0a                	jb     800de7 <__udivdi3+0x6b>
  800ddd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800de1:	0f 87 ad 00 00 00    	ja     800e94 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800de7:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dfc:	89 f0                	mov    %esi,%eax
  800dfe:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    
  800e07:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e08:	89 fa                	mov    %edi,%edx
  800e0a:	89 f0                	mov    %esi,%eax
  800e0c:	f7 f1                	div    %ecx
  800e0e:	89 c6                	mov    %eax,%esi
  800e10:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e12:	89 f0                	mov    %esi,%eax
  800e14:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    
  800e1d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e20:	89 f1                	mov    %esi,%ecx
  800e22:	d3 e0                	shl    %cl,%eax
  800e24:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e28:	b8 20 00 00 00       	mov    $0x20,%eax
  800e2d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e2f:	89 ea                	mov    %ebp,%edx
  800e31:	88 c1                	mov    %al,%cl
  800e33:	d3 ea                	shr    %cl,%edx
  800e35:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e39:	09 ca                	or     %ecx,%edx
  800e3b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e3f:	89 f1                	mov    %esi,%ecx
  800e41:	d3 e5                	shl    %cl,%ebp
  800e43:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e47:	89 fd                	mov    %edi,%ebp
  800e49:	88 c1                	mov    %al,%cl
  800e4b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e4d:	89 fa                	mov    %edi,%edx
  800e4f:	89 f1                	mov    %esi,%ecx
  800e51:	d3 e2                	shl    %cl,%edx
  800e53:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e57:	88 c1                	mov    %al,%cl
  800e59:	d3 ef                	shr    %cl,%edi
  800e5b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e5d:	89 f8                	mov    %edi,%eax
  800e5f:	89 ea                	mov    %ebp,%edx
  800e61:	f7 74 24 08          	divl   0x8(%esp)
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e69:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e6d:	39 d1                	cmp    %edx,%ecx
  800e6f:	72 17                	jb     800e88 <__udivdi3+0x10c>
  800e71:	74 09                	je     800e7c <__udivdi3+0x100>
  800e73:	89 fe                	mov    %edi,%esi
  800e75:	31 ff                	xor    %edi,%edi
  800e77:	e9 41 ff ff ff       	jmp    800dbd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e7c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e80:	89 f1                	mov    %esi,%ecx
  800e82:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e84:	39 c2                	cmp    %eax,%edx
  800e86:	73 eb                	jae    800e73 <__udivdi3+0xf7>
		{
		  q0--;
  800e88:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e8b:	31 ff                	xor    %edi,%edi
  800e8d:	e9 2b ff ff ff       	jmp    800dbd <__udivdi3+0x41>
  800e92:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e94:	31 f6                	xor    %esi,%esi
  800e96:	e9 22 ff ff ff       	jmp    800dbd <__udivdi3+0x41>
	...

00800e9c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e9c:	55                   	push   %ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	83 ec 20             	sub    $0x20,%esp
  800ea2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ea6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800eaa:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eae:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800eb2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eb6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800eba:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800ebc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ebe:	85 ed                	test   %ebp,%ebp
  800ec0:	75 16                	jne    800ed8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800ec2:	39 f1                	cmp    %esi,%ecx
  800ec4:	0f 86 a6 00 00 00    	jbe    800f70 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eca:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ecc:	89 d0                	mov    %edx,%eax
  800ece:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ed0:	83 c4 20             	add    $0x20,%esp
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    
  800ed7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ed8:	39 f5                	cmp    %esi,%ebp
  800eda:	0f 87 ac 00 00 00    	ja     800f8c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ee0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800ee3:	83 f0 1f             	xor    $0x1f,%eax
  800ee6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eea:	0f 84 a8 00 00 00    	je     800f98 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ef0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ef4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ef6:	bf 20 00 00 00       	mov    $0x20,%edi
  800efb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800eff:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f03:	89 f9                	mov    %edi,%ecx
  800f05:	d3 e8                	shr    %cl,%eax
  800f07:	09 e8                	or     %ebp,%eax
  800f09:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f0d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f11:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f15:	d3 e0                	shl    %cl,%eax
  800f17:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f1b:	89 f2                	mov    %esi,%edx
  800f1d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f1f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f23:	d3 e0                	shl    %cl,%eax
  800f25:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f29:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f2d:	89 f9                	mov    %edi,%ecx
  800f2f:	d3 e8                	shr    %cl,%eax
  800f31:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f33:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f35:	89 f2                	mov    %esi,%edx
  800f37:	f7 74 24 18          	divl   0x18(%esp)
  800f3b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f3d:	f7 64 24 0c          	mull   0xc(%esp)
  800f41:	89 c5                	mov    %eax,%ebp
  800f43:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f45:	39 d6                	cmp    %edx,%esi
  800f47:	72 67                	jb     800fb0 <__umoddi3+0x114>
  800f49:	74 75                	je     800fc0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f4b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f4f:	29 e8                	sub    %ebp,%eax
  800f51:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f53:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f57:	d3 e8                	shr    %cl,%eax
  800f59:	89 f2                	mov    %esi,%edx
  800f5b:	89 f9                	mov    %edi,%ecx
  800f5d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f5f:	09 d0                	or     %edx,%eax
  800f61:	89 f2                	mov    %esi,%edx
  800f63:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f67:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f69:	83 c4 20             	add    $0x20,%esp
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f70:	85 c9                	test   %ecx,%ecx
  800f72:	75 0b                	jne    800f7f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f74:	b8 01 00 00 00       	mov    $0x1,%eax
  800f79:	31 d2                	xor    %edx,%edx
  800f7b:	f7 f1                	div    %ecx
  800f7d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f7f:	89 f0                	mov    %esi,%eax
  800f81:	31 d2                	xor    %edx,%edx
  800f83:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f85:	89 f8                	mov    %edi,%eax
  800f87:	e9 3e ff ff ff       	jmp    800eca <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f8c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f8e:	83 c4 20             	add    $0x20,%esp
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    
  800f95:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f98:	39 f5                	cmp    %esi,%ebp
  800f9a:	72 04                	jb     800fa0 <__umoddi3+0x104>
  800f9c:	39 f9                	cmp    %edi,%ecx
  800f9e:	77 06                	ja     800fa6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fa0:	89 f2                	mov    %esi,%edx
  800fa2:	29 cf                	sub    %ecx,%edi
  800fa4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fa6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    
  800faf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fb0:	89 d1                	mov    %edx,%ecx
  800fb2:	89 c5                	mov    %eax,%ebp
  800fb4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fb8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fbc:	eb 8d                	jmp    800f4b <__umoddi3+0xaf>
  800fbe:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fc0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fc4:	72 ea                	jb     800fb0 <__umoddi3+0x114>
  800fc6:	89 f1                	mov    %esi,%ecx
  800fc8:	eb 81                	jmp    800f4b <__umoddi3+0xaf>
