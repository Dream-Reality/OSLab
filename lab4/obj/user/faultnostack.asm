
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 2c 0d 80 	movl   $0x800d2c,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 14 0c 00 00       	call   800c62 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 20             	sub    $0x20,%esp
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80006a:	e8 68 0a 00 00       	call   800ad7 <sys_getenvid>
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007b:	c1 e0 07             	shl    $0x7,%eax
  80007e:	29 d0                	sub    %edx,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800088:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80008b:	a3 04 20 80 00       	mov    %eax,0x802004
  800090:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  800094:	c7 04 24 a0 10 80 00 	movl   $0x8010a0,(%esp)
  80009b:	e8 d8 00 00 00       	call   800178 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a0:	85 f6                	test   %esi,%esi
  8000a2:	7e 07                	jle    8000ab <libmain+0x4f>
		binaryname = argv[0];
  8000a4:	8b 03                	mov    (%ebx),%eax
  8000a6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000af:	89 34 24             	mov    %esi,(%esp)
  8000b2:	e8 7d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 08 00 00 00       	call   8000c4 <exit>
}
  8000bc:	83 c4 20             	add    $0x20,%esp
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    
	...

008000c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d1:	e8 af 09 00 00       	call   800a85 <sys_env_destroy>
}
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 14             	sub    $0x14,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000eb:	40                   	inc    %eax
  8000ec:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f3:	75 19                	jne    80010e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000f5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000fc:	00 
  8000fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800100:	89 04 24             	mov    %eax,(%esp)
  800103:	e8 40 09 00 00       	call   800a48 <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010e:	ff 43 04             	incl   0x4(%ebx)
}
  800111:	83 c4 14             	add    $0x14,%esp
  800114:	5b                   	pop    %ebx
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800120:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800127:	00 00 00 
	b.cnt = 0;
  80012a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800131:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800134:	8b 45 0c             	mov    0xc(%ebp),%eax
  800137:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013b:	8b 45 08             	mov    0x8(%ebp),%eax
  80013e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800142:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014c:	c7 04 24 d8 00 80 00 	movl   $0x8000d8,(%esp)
  800153:	e8 82 01 00 00       	call   8002da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800158:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800162:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800168:	89 04 24             	mov    %eax,(%esp)
  80016b:	e8 d8 08 00 00       	call   800a48 <sys_cputs>

	return b.cnt;
}
  800170:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 87 ff ff ff       	call   800117 <vcprintf>
	va_end(ap);

	return cnt;
}
  800190:	c9                   	leave  
  800191:	c3                   	ret    
	...

00800194 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	57                   	push   %edi
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
  80019a:	83 ec 3c             	sub    $0x3c,%esp
  80019d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001a0:	89 d7                	mov    %edx,%edi
  8001a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	75 08                	jne    8001c0 <printnum+0x2c>
  8001b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001be:	77 57                	ja     800217 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001c4:	4b                   	dec    %ebx
  8001c5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001df:	00 
  8001e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	e8 4a 0c 00 00       	call   800e3c <__udivdi3>
  8001f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001fa:	89 04 24             	mov    %eax,(%esp)
  8001fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800201:	89 fa                	mov    %edi,%edx
  800203:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800206:	e8 89 ff ff ff       	call   800194 <printnum>
  80020b:	eb 0f                	jmp    80021c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800211:	89 34 24             	mov    %esi,(%esp)
  800214:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800217:	4b                   	dec    %ebx
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7f f1                	jg     80020d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800220:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800224:	8b 45 10             	mov    0x10(%ebp),%eax
  800227:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800232:	00 
  800233:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80023c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800240:	e8 17 0d 00 00       	call   800f5c <__umoddi3>
  800245:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800249:	0f be 80 ae 10 80 00 	movsbl 0x8010ae(%eax),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800256:	83 c4 3c             	add    $0x3c,%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800261:	83 fa 01             	cmp    $0x1,%edx
  800264:	7e 0e                	jle    800274 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	8b 52 04             	mov    0x4(%edx),%edx
  800272:	eb 22                	jmp    800296 <getuint+0x38>
	else if (lflag)
  800274:	85 d2                	test   %edx,%edx
  800276:	74 10                	je     800288 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
  800286:	eb 0e                	jmp    800296 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800288:	8b 10                	mov    (%eax),%edx
  80028a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 02                	mov    (%edx),%eax
  800291:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a6:	73 08                	jae    8002b0 <sprintputch+0x18>
		*b->buf++ = ch;
  8002a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ab:	88 0a                	mov    %cl,(%edx)
  8002ad:	42                   	inc    %edx
  8002ae:	89 10                	mov    %edx,(%eax)
}
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	e8 02 00 00 00       	call   8002da <vprintfmt>
	va_end(ap);
}
  8002d8:	c9                   	leave  
  8002d9:	c3                   	ret    

008002da <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 4c             	sub    $0x4c,%esp
  8002e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e6:	8b 75 10             	mov    0x10(%ebp),%esi
  8002e9:	eb 12                	jmp    8002fd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	0f 84 6b 03 00 00    	je     80065e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fd:	0f b6 06             	movzbl (%esi),%eax
  800300:	46                   	inc    %esi
  800301:	83 f8 25             	cmp    $0x25,%eax
  800304:	75 e5                	jne    8002eb <vprintfmt+0x11>
  800306:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80030a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800311:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800316:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800322:	eb 26                	jmp    80034a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800327:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80032b:	eb 1d                	jmp    80034a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800330:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800334:	eb 14                	jmp    80034a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800336:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800339:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800340:	eb 08                	jmp    80034a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800342:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800345:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	0f b6 06             	movzbl (%esi),%eax
  80034d:	8d 56 01             	lea    0x1(%esi),%edx
  800350:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800353:	8a 16                	mov    (%esi),%dl
  800355:	83 ea 23             	sub    $0x23,%edx
  800358:	80 fa 55             	cmp    $0x55,%dl
  80035b:	0f 87 e1 02 00 00    	ja     800642 <vprintfmt+0x368>
  800361:	0f b6 d2             	movzbl %dl,%edx
  800364:	ff 24 95 80 11 80 00 	jmp    *0x801180(,%edx,4)
  80036b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80036e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800373:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800376:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80037a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80037d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800380:	83 fa 09             	cmp    $0x9,%edx
  800383:	77 2a                	ja     8003af <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800385:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800386:	eb eb                	jmp    800373 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 50 04             	lea    0x4(%eax),%edx
  80038e:	89 55 14             	mov    %edx,0x14(%ebp)
  800391:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800396:	eb 17                	jmp    8003af <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800398:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039c:	78 98                	js     800336 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003a1:	eb a7                	jmp    80034a <vprintfmt+0x70>
  8003a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003ad:	eb 9b                	jmp    80034a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b3:	79 95                	jns    80034a <vprintfmt+0x70>
  8003b5:	eb 8b                	jmp    800342 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003bb:	eb 8d                	jmp    80034a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 50 04             	lea    0x4(%eax),%edx
  8003c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	89 04 24             	mov    %eax,(%esp)
  8003cf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d5:	e9 23 ff ff ff       	jmp    8002fd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 50 04             	lea    0x4(%eax),%edx
  8003e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e3:	8b 00                	mov    (%eax),%eax
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	79 02                	jns    8003eb <vprintfmt+0x111>
  8003e9:	f7 d8                	neg    %eax
  8003eb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ed:	83 f8 08             	cmp    $0x8,%eax
  8003f0:	7f 0b                	jg     8003fd <vprintfmt+0x123>
  8003f2:	8b 04 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%eax
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	75 23                	jne    800420 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800401:	c7 44 24 08 c6 10 80 	movl   $0x8010c6,0x8(%esp)
  800408:	00 
  800409:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	e8 9a fe ff ff       	call   8002b2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80041b:	e9 dd fe ff ff       	jmp    8002fd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800420:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800424:	c7 44 24 08 cf 10 80 	movl   $0x8010cf,0x8(%esp)
  80042b:	00 
  80042c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800430:	8b 55 08             	mov    0x8(%ebp),%edx
  800433:	89 14 24             	mov    %edx,(%esp)
  800436:	e8 77 fe ff ff       	call   8002b2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043e:	e9 ba fe ff ff       	jmp    8002fd <vprintfmt+0x23>
  800443:	89 f9                	mov    %edi,%ecx
  800445:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800448:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 50 04             	lea    0x4(%eax),%edx
  800451:	89 55 14             	mov    %edx,0x14(%ebp)
  800454:	8b 30                	mov    (%eax),%esi
  800456:	85 f6                	test   %esi,%esi
  800458:	75 05                	jne    80045f <vprintfmt+0x185>
				p = "(null)";
  80045a:	be bf 10 80 00       	mov    $0x8010bf,%esi
			if (width > 0 && padc != '-')
  80045f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800463:	0f 8e 84 00 00 00    	jle    8004ed <vprintfmt+0x213>
  800469:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80046d:	74 7e                	je     8004ed <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800473:	89 34 24             	mov    %esi,(%esp)
  800476:	e8 8b 02 00 00       	call   800706 <strnlen>
  80047b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80047e:	29 c2                	sub    %eax,%edx
  800480:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800483:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800487:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80048a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80048d:	89 de                	mov    %ebx,%esi
  80048f:	89 d3                	mov    %edx,%ebx
  800491:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	eb 0b                	jmp    8004a0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800495:	89 74 24 04          	mov    %esi,0x4(%esp)
  800499:	89 3c 24             	mov    %edi,(%esp)
  80049c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049f:	4b                   	dec    %ebx
  8004a0:	85 db                	test   %ebx,%ebx
  8004a2:	7f f1                	jg     800495 <vprintfmt+0x1bb>
  8004a4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004a7:	89 f3                	mov    %esi,%ebx
  8004a9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	79 05                	jns    8004b8 <vprintfmt+0x1de>
  8004b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004bb:	29 c2                	sub    %eax,%edx
  8004bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004c0:	eb 2b                	jmp    8004ed <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004c6:	74 18                	je     8004e0 <vprintfmt+0x206>
  8004c8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004cb:	83 fa 5e             	cmp    $0x5e,%edx
  8004ce:	76 10                	jbe    8004e0 <vprintfmt+0x206>
					putch('?', putdat);
  8004d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004db:	ff 55 08             	call   *0x8(%ebp)
  8004de:	eb 0a                	jmp    8004ea <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ea:	ff 4d e4             	decl   -0x1c(%ebp)
  8004ed:	0f be 06             	movsbl (%esi),%eax
  8004f0:	46                   	inc    %esi
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	74 21                	je     800516 <vprintfmt+0x23c>
  8004f5:	85 ff                	test   %edi,%edi
  8004f7:	78 c9                	js     8004c2 <vprintfmt+0x1e8>
  8004f9:	4f                   	dec    %edi
  8004fa:	79 c6                	jns    8004c2 <vprintfmt+0x1e8>
  8004fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ff:	89 de                	mov    %ebx,%esi
  800501:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800504:	eb 18                	jmp    80051e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800506:	89 74 24 04          	mov    %esi,0x4(%esp)
  80050a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800511:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800513:	4b                   	dec    %ebx
  800514:	eb 08                	jmp    80051e <vprintfmt+0x244>
  800516:	8b 7d 08             	mov    0x8(%ebp),%edi
  800519:	89 de                	mov    %ebx,%esi
  80051b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80051e:	85 db                	test   %ebx,%ebx
  800520:	7f e4                	jg     800506 <vprintfmt+0x22c>
  800522:	89 7d 08             	mov    %edi,0x8(%ebp)
  800525:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052a:	e9 ce fd ff ff       	jmp    8002fd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052f:	83 f9 01             	cmp    $0x1,%ecx
  800532:	7e 10                	jle    800544 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 08             	lea    0x8(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 30                	mov    (%eax),%esi
  80053f:	8b 78 04             	mov    0x4(%eax),%edi
  800542:	eb 26                	jmp    80056a <vprintfmt+0x290>
	else if (lflag)
  800544:	85 c9                	test   %ecx,%ecx
  800546:	74 12                	je     80055a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 50 04             	lea    0x4(%eax),%edx
  80054e:	89 55 14             	mov    %edx,0x14(%ebp)
  800551:	8b 30                	mov    (%eax),%esi
  800553:	89 f7                	mov    %esi,%edi
  800555:	c1 ff 1f             	sar    $0x1f,%edi
  800558:	eb 10                	jmp    80056a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 30                	mov    (%eax),%esi
  800565:	89 f7                	mov    %esi,%edi
  800567:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056a:	85 ff                	test   %edi,%edi
  80056c:	78 0a                	js     800578 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800573:	e9 8c 00 00 00       	jmp    800604 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800578:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800583:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800586:	f7 de                	neg    %esi
  800588:	83 d7 00             	adc    $0x0,%edi
  80058b:	f7 df                	neg    %edi
			}
			base = 10;
  80058d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800592:	eb 70                	jmp    800604 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800594:	89 ca                	mov    %ecx,%edx
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
  800599:	e8 c0 fc ff ff       	call   80025e <getuint>
  80059e:	89 c6                	mov    %eax,%esi
  8005a0:	89 d7                	mov    %edx,%edi
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a7:	eb 5b                	jmp    800604 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005a9:	89 ca                	mov    %ecx,%edx
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 ab fc ff ff       	call   80025e <getuint>
  8005b3:	89 c6                	mov    %eax,%esi
  8005b5:	89 d7                	mov    %edx,%edi
			base = 8;
  8005b7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005bc:	eb 46                	jmp    800604 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005c9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 04             	lea    0x4(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e3:	8b 30                	mov    (%eax),%esi
  8005e5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ea:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005ef:	eb 13                	jmp    800604 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f1:	89 ca                	mov    %ecx,%edx
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 63 fc ff ff       	call   80025e <getuint>
  8005fb:	89 c6                	mov    %eax,%esi
  8005fd:	89 d7                	mov    %edx,%edi
			base = 16;
  8005ff:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800604:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800608:	89 54 24 10          	mov    %edx,0x10(%esp)
  80060c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800613:	89 44 24 08          	mov    %eax,0x8(%esp)
  800617:	89 34 24             	mov    %esi,(%esp)
  80061a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061e:	89 da                	mov    %ebx,%edx
  800620:	8b 45 08             	mov    0x8(%ebp),%eax
  800623:	e8 6c fb ff ff       	call   800194 <printnum>
			break;
  800628:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80062b:	e9 cd fc ff ff       	jmp    8002fd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80063d:	e9 bb fc ff ff       	jmp    8002fd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800642:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800646:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800650:	eb 01                	jmp    800653 <vprintfmt+0x379>
  800652:	4e                   	dec    %esi
  800653:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800657:	75 f9                	jne    800652 <vprintfmt+0x378>
  800659:	e9 9f fc ff ff       	jmp    8002fd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80065e:	83 c4 4c             	add    $0x4c,%esp
  800661:	5b                   	pop    %ebx
  800662:	5e                   	pop    %esi
  800663:	5f                   	pop    %edi
  800664:	5d                   	pop    %ebp
  800665:	c3                   	ret    

00800666 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800666:	55                   	push   %ebp
  800667:	89 e5                	mov    %esp,%ebp
  800669:	83 ec 28             	sub    $0x28,%esp
  80066c:	8b 45 08             	mov    0x8(%ebp),%eax
  80066f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800672:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800675:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800679:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800683:	85 c0                	test   %eax,%eax
  800685:	74 30                	je     8006b7 <vsnprintf+0x51>
  800687:	85 d2                	test   %edx,%edx
  800689:	7e 33                	jle    8006be <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800692:	8b 45 10             	mov    0x10(%ebp),%eax
  800695:	89 44 24 08          	mov    %eax,0x8(%esp)
  800699:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a0:	c7 04 24 98 02 80 00 	movl   $0x800298,(%esp)
  8006a7:	e8 2e fc ff ff       	call   8002da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	eb 0c                	jmp    8006c3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bc:	eb 05                	jmp    8006c3 <vsnprintf+0x5d>
  8006be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    

008006c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	89 04 24             	mov    %eax,(%esp)
  8006e6:	e8 7b ff ff ff       	call   800666 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006eb:	c9                   	leave  
  8006ec:	c3                   	ret    
  8006ed:	00 00                	add    %al,(%eax)
	...

008006f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fb:	eb 01                	jmp    8006fe <strlen+0xe>
		n++;
  8006fd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800702:	75 f9                	jne    8006fd <strlen+0xd>
		n++;
	return n;
}
  800704:	5d                   	pop    %ebp
  800705:	c3                   	ret    

00800706 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80070c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	eb 01                	jmp    800717 <strnlen+0x11>
		n++;
  800716:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800717:	39 d0                	cmp    %edx,%eax
  800719:	74 06                	je     800721 <strnlen+0x1b>
  80071b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80071f:	75 f5                	jne    800716 <strnlen+0x10>
		n++;
	return n;
}
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	53                   	push   %ebx
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072d:	ba 00 00 00 00       	mov    $0x0,%edx
  800732:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800735:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800738:	42                   	inc    %edx
  800739:	84 c9                	test   %cl,%cl
  80073b:	75 f5                	jne    800732 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80073d:	5b                   	pop    %ebx
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	53                   	push   %ebx
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074a:	89 1c 24             	mov    %ebx,(%esp)
  80074d:	e8 9e ff ff ff       	call   8006f0 <strlen>
	strcpy(dst + len, src);
  800752:	8b 55 0c             	mov    0xc(%ebp),%edx
  800755:	89 54 24 04          	mov    %edx,0x4(%esp)
  800759:	01 d8                	add    %ebx,%eax
  80075b:	89 04 24             	mov    %eax,(%esp)
  80075e:	e8 c0 ff ff ff       	call   800723 <strcpy>
	return dst;
}
  800763:	89 d8                	mov    %ebx,%eax
  800765:	83 c4 08             	add    $0x8,%esp
  800768:	5b                   	pop    %ebx
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	56                   	push   %esi
  80076f:	53                   	push   %ebx
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
  800776:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800779:	b9 00 00 00 00       	mov    $0x0,%ecx
  80077e:	eb 0c                	jmp    80078c <strncpy+0x21>
		*dst++ = *src;
  800780:	8a 1a                	mov    (%edx),%bl
  800782:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800785:	80 3a 01             	cmpb   $0x1,(%edx)
  800788:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	41                   	inc    %ecx
  80078c:	39 f1                	cmp    %esi,%ecx
  80078e:	75 f0                	jne    800780 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800790:	5b                   	pop    %ebx
  800791:	5e                   	pop    %esi
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	56                   	push   %esi
  800798:	53                   	push   %ebx
  800799:	8b 75 08             	mov    0x8(%ebp),%esi
  80079c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a2:	85 d2                	test   %edx,%edx
  8007a4:	75 0a                	jne    8007b0 <strlcpy+0x1c>
  8007a6:	89 f0                	mov    %esi,%eax
  8007a8:	eb 1a                	jmp    8007c4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007aa:	88 18                	mov    %bl,(%eax)
  8007ac:	40                   	inc    %eax
  8007ad:	41                   	inc    %ecx
  8007ae:	eb 02                	jmp    8007b2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007b2:	4a                   	dec    %edx
  8007b3:	74 0a                	je     8007bf <strlcpy+0x2b>
  8007b5:	8a 19                	mov    (%ecx),%bl
  8007b7:	84 db                	test   %bl,%bl
  8007b9:	75 ef                	jne    8007aa <strlcpy+0x16>
  8007bb:	89 c2                	mov    %eax,%edx
  8007bd:	eb 02                	jmp    8007c1 <strlcpy+0x2d>
  8007bf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007c1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007c4:	29 f0                	sub    %esi,%eax
}
  8007c6:	5b                   	pop    %ebx
  8007c7:	5e                   	pop    %esi
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d3:	eb 02                	jmp    8007d7 <strcmp+0xd>
		p++, q++;
  8007d5:	41                   	inc    %ecx
  8007d6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d7:	8a 01                	mov    (%ecx),%al
  8007d9:	84 c0                	test   %al,%al
  8007db:	74 04                	je     8007e1 <strcmp+0x17>
  8007dd:	3a 02                	cmp    (%edx),%al
  8007df:	74 f4                	je     8007d5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e1:	0f b6 c0             	movzbl %al,%eax
  8007e4:	0f b6 12             	movzbl (%edx),%edx
  8007e7:	29 d0                	sub    %edx,%eax
}
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007f8:	eb 03                	jmp    8007fd <strncmp+0x12>
		n--, p++, q++;
  8007fa:	4a                   	dec    %edx
  8007fb:	40                   	inc    %eax
  8007fc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007fd:	85 d2                	test   %edx,%edx
  8007ff:	74 14                	je     800815 <strncmp+0x2a>
  800801:	8a 18                	mov    (%eax),%bl
  800803:	84 db                	test   %bl,%bl
  800805:	74 04                	je     80080b <strncmp+0x20>
  800807:	3a 19                	cmp    (%ecx),%bl
  800809:	74 ef                	je     8007fa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 00             	movzbl (%eax),%eax
  80080e:	0f b6 11             	movzbl (%ecx),%edx
  800811:	29 d0                	sub    %edx,%eax
  800813:	eb 05                	jmp    80081a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081a:	5b                   	pop    %ebx
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800826:	eb 05                	jmp    80082d <strchr+0x10>
		if (*s == c)
  800828:	38 ca                	cmp    %cl,%dl
  80082a:	74 0c                	je     800838 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082c:	40                   	inc    %eax
  80082d:	8a 10                	mov    (%eax),%dl
  80082f:	84 d2                	test   %dl,%dl
  800831:	75 f5                	jne    800828 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800843:	eb 05                	jmp    80084a <strfind+0x10>
		if (*s == c)
  800845:	38 ca                	cmp    %cl,%dl
  800847:	74 07                	je     800850 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800849:	40                   	inc    %eax
  80084a:	8a 10                	mov    (%eax),%dl
  80084c:	84 d2                	test   %dl,%dl
  80084e:	75 f5                	jne    800845 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	57                   	push   %edi
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800861:	85 c9                	test   %ecx,%ecx
  800863:	74 30                	je     800895 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800865:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086b:	75 25                	jne    800892 <memset+0x40>
  80086d:	f6 c1 03             	test   $0x3,%cl
  800870:	75 20                	jne    800892 <memset+0x40>
		c &= 0xFF;
  800872:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800875:	89 d3                	mov    %edx,%ebx
  800877:	c1 e3 08             	shl    $0x8,%ebx
  80087a:	89 d6                	mov    %edx,%esi
  80087c:	c1 e6 18             	shl    $0x18,%esi
  80087f:	89 d0                	mov    %edx,%eax
  800881:	c1 e0 10             	shl    $0x10,%eax
  800884:	09 f0                	or     %esi,%eax
  800886:	09 d0                	or     %edx,%eax
  800888:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80088a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80088d:	fc                   	cld    
  80088e:	f3 ab                	rep stos %eax,%es:(%edi)
  800890:	eb 03                	jmp    800895 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800892:	fc                   	cld    
  800893:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800895:	89 f8                	mov    %edi,%eax
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5f                   	pop    %edi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	57                   	push   %edi
  8008a0:	56                   	push   %esi
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008aa:	39 c6                	cmp    %eax,%esi
  8008ac:	73 34                	jae    8008e2 <memmove+0x46>
  8008ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b1:	39 d0                	cmp    %edx,%eax
  8008b3:	73 2d                	jae    8008e2 <memmove+0x46>
		s += n;
		d += n;
  8008b5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b8:	f6 c2 03             	test   $0x3,%dl
  8008bb:	75 1b                	jne    8008d8 <memmove+0x3c>
  8008bd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c3:	75 13                	jne    8008d8 <memmove+0x3c>
  8008c5:	f6 c1 03             	test   $0x3,%cl
  8008c8:	75 0e                	jne    8008d8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ca:	83 ef 04             	sub    $0x4,%edi
  8008cd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008d3:	fd                   	std    
  8008d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d6:	eb 07                	jmp    8008df <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008d8:	4f                   	dec    %edi
  8008d9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008dc:	fd                   	std    
  8008dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008df:	fc                   	cld    
  8008e0:	eb 20                	jmp    800902 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e8:	75 13                	jne    8008fd <memmove+0x61>
  8008ea:	a8 03                	test   $0x3,%al
  8008ec:	75 0f                	jne    8008fd <memmove+0x61>
  8008ee:	f6 c1 03             	test   $0x3,%cl
  8008f1:	75 0a                	jne    8008fd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008f3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008f6:	89 c7                	mov    %eax,%edi
  8008f8:	fc                   	cld    
  8008f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fb:	eb 05                	jmp    800902 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008fd:	89 c7                	mov    %eax,%edi
  8008ff:	fc                   	cld    
  800900:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800902:	5e                   	pop    %esi
  800903:	5f                   	pop    %edi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80090c:	8b 45 10             	mov    0x10(%ebp),%eax
  80090f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800913:	8b 45 0c             	mov    0xc(%ebp),%eax
  800916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	89 04 24             	mov    %eax,(%esp)
  800920:	e8 77 ff ff ff       	call   80089c <memmove>
}
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	57                   	push   %edi
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800936:	ba 00 00 00 00       	mov    $0x0,%edx
  80093b:	eb 16                	jmp    800953 <memcmp+0x2c>
		if (*s1 != *s2)
  80093d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800940:	42                   	inc    %edx
  800941:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800945:	38 c8                	cmp    %cl,%al
  800947:	74 0a                	je     800953 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800949:	0f b6 c0             	movzbl %al,%eax
  80094c:	0f b6 c9             	movzbl %cl,%ecx
  80094f:	29 c8                	sub    %ecx,%eax
  800951:	eb 09                	jmp    80095c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800953:	39 da                	cmp    %ebx,%edx
  800955:	75 e6                	jne    80093d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80096a:	89 c2                	mov    %eax,%edx
  80096c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80096f:	eb 05                	jmp    800976 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800971:	38 08                	cmp    %cl,(%eax)
  800973:	74 05                	je     80097a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800975:	40                   	inc    %eax
  800976:	39 d0                	cmp    %edx,%eax
  800978:	72 f7                	jb     800971 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	8b 55 08             	mov    0x8(%ebp),%edx
  800985:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800988:	eb 01                	jmp    80098b <strtol+0xf>
		s++;
  80098a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098b:	8a 02                	mov    (%edx),%al
  80098d:	3c 20                	cmp    $0x20,%al
  80098f:	74 f9                	je     80098a <strtol+0xe>
  800991:	3c 09                	cmp    $0x9,%al
  800993:	74 f5                	je     80098a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800995:	3c 2b                	cmp    $0x2b,%al
  800997:	75 08                	jne    8009a1 <strtol+0x25>
		s++;
  800999:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099a:	bf 00 00 00 00       	mov    $0x0,%edi
  80099f:	eb 13                	jmp    8009b4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a1:	3c 2d                	cmp    $0x2d,%al
  8009a3:	75 0a                	jne    8009af <strtol+0x33>
		s++, neg = 1;
  8009a5:	8d 52 01             	lea    0x1(%edx),%edx
  8009a8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ad:	eb 05                	jmp    8009b4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009af:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b4:	85 db                	test   %ebx,%ebx
  8009b6:	74 05                	je     8009bd <strtol+0x41>
  8009b8:	83 fb 10             	cmp    $0x10,%ebx
  8009bb:	75 28                	jne    8009e5 <strtol+0x69>
  8009bd:	8a 02                	mov    (%edx),%al
  8009bf:	3c 30                	cmp    $0x30,%al
  8009c1:	75 10                	jne    8009d3 <strtol+0x57>
  8009c3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009c7:	75 0a                	jne    8009d3 <strtol+0x57>
		s += 2, base = 16;
  8009c9:	83 c2 02             	add    $0x2,%edx
  8009cc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d1:	eb 12                	jmp    8009e5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009d3:	85 db                	test   %ebx,%ebx
  8009d5:	75 0e                	jne    8009e5 <strtol+0x69>
  8009d7:	3c 30                	cmp    $0x30,%al
  8009d9:	75 05                	jne    8009e0 <strtol+0x64>
		s++, base = 8;
  8009db:	42                   	inc    %edx
  8009dc:	b3 08                	mov    $0x8,%bl
  8009de:	eb 05                	jmp    8009e5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009e0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ec:	8a 0a                	mov    (%edx),%cl
  8009ee:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009f1:	80 fb 09             	cmp    $0x9,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x82>
			dig = *s - '0';
  8009f6:	0f be c9             	movsbl %cl,%ecx
  8009f9:	83 e9 30             	sub    $0x30,%ecx
  8009fc:	eb 1e                	jmp    800a1c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009fe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 08                	ja     800a0e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a06:	0f be c9             	movsbl %cl,%ecx
  800a09:	83 e9 57             	sub    $0x57,%ecx
  800a0c:	eb 0e                	jmp    800a1c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a0e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a11:	80 fb 19             	cmp    $0x19,%bl
  800a14:	77 12                	ja     800a28 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a16:	0f be c9             	movsbl %cl,%ecx
  800a19:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a1c:	39 f1                	cmp    %esi,%ecx
  800a1e:	7d 0c                	jge    800a2c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a20:	42                   	inc    %edx
  800a21:	0f af c6             	imul   %esi,%eax
  800a24:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a26:	eb c4                	jmp    8009ec <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a28:	89 c1                	mov    %eax,%ecx
  800a2a:	eb 02                	jmp    800a2e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a2c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a32:	74 05                	je     800a39 <strtol+0xbd>
		*endptr = (char *) s;
  800a34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a37:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a39:	85 ff                	test   %edi,%edi
  800a3b:	74 04                	je     800a41 <strtol+0xc5>
  800a3d:	89 c8                	mov    %ecx,%eax
  800a3f:	f7 d8                	neg    %eax
}
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    
	...

00800a48 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a56:	8b 55 08             	mov    0x8(%ebp),%edx
  800a59:	89 c3                	mov    %eax,%ebx
  800a5b:	89 c7                	mov    %eax,%edi
  800a5d:	89 c6                	mov    %eax,%esi
  800a5f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a71:	b8 01 00 00 00       	mov    $0x1,%eax
  800a76:	89 d1                	mov    %edx,%ecx
  800a78:	89 d3                	mov    %edx,%ebx
  800a7a:	89 d7                	mov    %edx,%edi
  800a7c:	89 d6                	mov    %edx,%esi
  800a7e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a93:	b8 03 00 00 00       	mov    $0x3,%eax
  800a98:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9b:	89 cb                	mov    %ecx,%ebx
  800a9d:	89 cf                	mov    %ecx,%edi
  800a9f:	89 ce                	mov    %ecx,%esi
  800aa1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	7e 28                	jle    800acf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aab:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ab2:	00 
  800ab3:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800aba:	00 
  800abb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ac2:	00 
  800ac3:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800aca:	e8 85 02 00 00       	call   800d54 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acf:	83 c4 2c             	add    $0x2c,%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae7:	89 d1                	mov    %edx,%ecx
  800ae9:	89 d3                	mov    %edx,%ebx
  800aeb:	89 d7                	mov    %edx,%edi
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_yield>:

void
sys_yield(void)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
  800b01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b06:	89 d1                	mov    %edx,%ecx
  800b08:	89 d3                	mov    %edx,%ebx
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 d6                	mov    %edx,%esi
  800b0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1e:	be 00 00 00 00       	mov    $0x0,%esi
  800b23:	b8 04 00 00 00       	mov    $0x4,%eax
  800b28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 f7                	mov    %esi,%edi
  800b33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7e 28                	jle    800b61 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b3d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b44:	00 
  800b45:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800b4c:	00 
  800b4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b54:	00 
  800b55:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800b5c:	e8 f3 01 00 00       	call   800d54 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b61:	83 c4 2c             	add    $0x2c,%esp
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	b8 05 00 00 00       	mov    $0x5,%eax
  800b77:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b88:	85 c0                	test   %eax,%eax
  800b8a:	7e 28                	jle    800bb4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b90:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b97:	00 
  800b98:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800b9f:	00 
  800ba0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba7:	00 
  800ba8:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800baf:	e8 a0 01 00 00       	call   800d54 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb4:	83 c4 2c             	add    $0x2c,%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bca:	b8 06 00 00 00       	mov    $0x6,%eax
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	89 df                	mov    %ebx,%edi
  800bd7:	89 de                	mov    %ebx,%esi
  800bd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 28                	jle    800c07 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bea:	00 
  800beb:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfa:	00 
  800bfb:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800c02:	e8 4d 01 00 00       	call   800d54 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c07:	83 c4 2c             	add    $0x2c,%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	89 df                	mov    %ebx,%edi
  800c2a:	89 de                	mov    %ebx,%esi
  800c2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 28                	jle    800c5a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c36:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c3d:	00 
  800c3e:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800c45:	00 
  800c46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4d:	00 
  800c4e:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800c55:	e8 fa 00 00 00       	call   800d54 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5a:	83 c4 2c             	add    $0x2c,%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c70:	b8 09 00 00 00       	mov    $0x9,%eax
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	89 df                	mov    %ebx,%edi
  800c7d:	89 de                	mov    %ebx,%esi
  800c7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 28                	jle    800cad <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c89:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c90:	00 
  800c91:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800c98:	00 
  800c99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca0:	00 
  800ca1:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800ca8:	e8 a7 00 00 00       	call   800d54 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cad:	83 c4 2c             	add    $0x2c,%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	be 00 00 00 00       	mov    $0x0,%esi
  800cc0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	89 cb                	mov    %ecx,%ebx
  800cf0:	89 cf                	mov    %ecx,%edi
  800cf2:	89 ce                	mov    %ecx,%esi
  800cf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 28                	jle    800d22 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfe:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d05:	00 
  800d06:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d15:	00 
  800d16:	c7 04 24 21 13 80 00 	movl   $0x801321,(%esp)
  800d1d:	e8 32 00 00 00       	call   800d54 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d22:	83 c4 2c             	add    $0x2c,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    
	...

00800d2c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d2c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d2d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d32:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d34:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  800d37:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  800d3b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  800d40:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  800d44:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  800d46:	83 c4 08             	add    $0x8,%esp
	popal
  800d49:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  800d4a:	83 c4 04             	add    $0x4,%esp
	popfl
  800d4d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  800d4e:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800d51:	c3                   	ret    
	...

00800d54 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d5c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d5f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d65:	e8 6d fd ff ff       	call   800ad7 <sys_getenvid>
  800d6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d6d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d78:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d80:	c7 04 24 30 13 80 00 	movl   $0x801330,(%esp)
  800d87:	e8 ec f3 ff ff       	call   800178 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d90:	8b 45 10             	mov    0x10(%ebp),%eax
  800d93:	89 04 24             	mov    %eax,(%esp)
  800d96:	e8 7c f3 ff ff       	call   800117 <vcprintf>
	cprintf("\n");
  800d9b:	c7 04 24 a2 10 80 00 	movl   $0x8010a2,(%esp)
  800da2:	e8 d1 f3 ff ff       	call   800178 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800da7:	cc                   	int3   
  800da8:	eb fd                	jmp    800da7 <_panic+0x53>
	...

00800dac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	53                   	push   %ebx
  800db0:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  800db3:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dba:	75 6f                	jne    800e2b <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  800dbc:	e8 16 fd ff ff       	call   800ad7 <sys_getenvid>
  800dc1:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800dc3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800dca:	00 
  800dcb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800dd2:	ee 
  800dd3:	89 04 24             	mov    %eax,(%esp)
  800dd6:	e8 3a fd ff ff       	call   800b15 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	79 1c                	jns    800dfb <set_pgfault_handler+0x4f>
  800ddf:	c7 44 24 08 54 13 80 	movl   $0x801354,0x8(%esp)
  800de6:	00 
  800de7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dee:	00 
  800def:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  800df6:	e8 59 ff ff ff       	call   800d54 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  800dfb:	c7 44 24 04 2c 0d 80 	movl   $0x800d2c,0x4(%esp)
  800e02:	00 
  800e03:	89 1c 24             	mov    %ebx,(%esp)
  800e06:	e8 57 fe ff ff       	call   800c62 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	79 1c                	jns    800e2b <set_pgfault_handler+0x7f>
  800e0f:	c7 44 24 08 7c 13 80 	movl   $0x80137c,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 b0 13 80 00 	movl   $0x8013b0,(%esp)
  800e26:	e8 29 ff ff ff       	call   800d54 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e33:	83 c4 14             	add    $0x14,%esp
  800e36:	5b                   	pop    %ebx
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	00 00                	add    %al,(%eax)
	...

00800e3c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e3c:	55                   	push   %ebp
  800e3d:	57                   	push   %edi
  800e3e:	56                   	push   %esi
  800e3f:	83 ec 10             	sub    $0x10,%esp
  800e42:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e46:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e4e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e52:	89 cd                	mov    %ecx,%ebp
  800e54:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	75 2c                	jne    800e88 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e5c:	39 f9                	cmp    %edi,%ecx
  800e5e:	77 68                	ja     800ec8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e60:	85 c9                	test   %ecx,%ecx
  800e62:	75 0b                	jne    800e6f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e64:	b8 01 00 00 00       	mov    $0x1,%eax
  800e69:	31 d2                	xor    %edx,%edx
  800e6b:	f7 f1                	div    %ecx
  800e6d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e6f:	31 d2                	xor    %edx,%edx
  800e71:	89 f8                	mov    %edi,%eax
  800e73:	f7 f1                	div    %ecx
  800e75:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e77:	89 f0                	mov    %esi,%eax
  800e79:	f7 f1                	div    %ecx
  800e7b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e7d:	89 f0                	mov    %esi,%eax
  800e7f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e88:	39 f8                	cmp    %edi,%eax
  800e8a:	77 2c                	ja     800eb8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e8c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e8f:	83 f6 1f             	xor    $0x1f,%esi
  800e92:	75 4c                	jne    800ee0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e94:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e96:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e9b:	72 0a                	jb     800ea7 <__udivdi3+0x6b>
  800e9d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ea1:	0f 87 ad 00 00 00    	ja     800f54 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ea7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eac:	89 f0                	mov    %esi,%eax
  800eae:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	5e                   	pop    %esi
  800eb4:	5f                   	pop    %edi
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    
  800eb7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800eb8:	31 ff                	xor    %edi,%edi
  800eba:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ebc:	89 f0                	mov    %esi,%eax
  800ebe:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    
  800ec7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec8:	89 fa                	mov    %edi,%edx
  800eca:	89 f0                	mov    %esi,%eax
  800ecc:	f7 f1                	div    %ecx
  800ece:	89 c6                	mov    %eax,%esi
  800ed0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ed2:	89 f0                	mov    %esi,%eax
  800ed4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    
  800edd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ee0:	89 f1                	mov    %esi,%ecx
  800ee2:	d3 e0                	shl    %cl,%eax
  800ee4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ee8:	b8 20 00 00 00       	mov    $0x20,%eax
  800eed:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800eef:	89 ea                	mov    %ebp,%edx
  800ef1:	88 c1                	mov    %al,%cl
  800ef3:	d3 ea                	shr    %cl,%edx
  800ef5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800ef9:	09 ca                	or     %ecx,%edx
  800efb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800eff:	89 f1                	mov    %esi,%ecx
  800f01:	d3 e5                	shl    %cl,%ebp
  800f03:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800f07:	89 fd                	mov    %edi,%ebp
  800f09:	88 c1                	mov    %al,%cl
  800f0b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800f0d:	89 fa                	mov    %edi,%edx
  800f0f:	89 f1                	mov    %esi,%ecx
  800f11:	d3 e2                	shl    %cl,%edx
  800f13:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f17:	88 c1                	mov    %al,%cl
  800f19:	d3 ef                	shr    %cl,%edi
  800f1b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f1d:	89 f8                	mov    %edi,%eax
  800f1f:	89 ea                	mov    %ebp,%edx
  800f21:	f7 74 24 08          	divl   0x8(%esp)
  800f25:	89 d1                	mov    %edx,%ecx
  800f27:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f29:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f2d:	39 d1                	cmp    %edx,%ecx
  800f2f:	72 17                	jb     800f48 <__udivdi3+0x10c>
  800f31:	74 09                	je     800f3c <__udivdi3+0x100>
  800f33:	89 fe                	mov    %edi,%esi
  800f35:	31 ff                	xor    %edi,%edi
  800f37:	e9 41 ff ff ff       	jmp    800e7d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f3c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f40:	89 f1                	mov    %esi,%ecx
  800f42:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f44:	39 c2                	cmp    %eax,%edx
  800f46:	73 eb                	jae    800f33 <__udivdi3+0xf7>
		{
		  q0--;
  800f48:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f4b:	31 ff                	xor    %edi,%edi
  800f4d:	e9 2b ff ff ff       	jmp    800e7d <__udivdi3+0x41>
  800f52:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f54:	31 f6                	xor    %esi,%esi
  800f56:	e9 22 ff ff ff       	jmp    800e7d <__udivdi3+0x41>
	...

00800f5c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f5c:	55                   	push   %ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	83 ec 20             	sub    $0x20,%esp
  800f62:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f66:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f6a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f6e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f72:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f76:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f7a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f7c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f7e:	85 ed                	test   %ebp,%ebp
  800f80:	75 16                	jne    800f98 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f82:	39 f1                	cmp    %esi,%ecx
  800f84:	0f 86 a6 00 00 00    	jbe    801030 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f8a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f8c:	89 d0                	mov    %edx,%eax
  800f8e:	31 d2                	xor    %edx,%edx
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f98:	39 f5                	cmp    %esi,%ebp
  800f9a:	0f 87 ac 00 00 00    	ja     80104c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fa0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800fa3:	83 f0 1f             	xor    $0x1f,%eax
  800fa6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800faa:	0f 84 a8 00 00 00    	je     801058 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fb0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fb4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fb6:	bf 20 00 00 00       	mov    $0x20,%edi
  800fbb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fbf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fc3:	89 f9                	mov    %edi,%ecx
  800fc5:	d3 e8                	shr    %cl,%eax
  800fc7:	09 e8                	or     %ebp,%eax
  800fc9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fcd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fd1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fd5:	d3 e0                	shl    %cl,%eax
  800fd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fdb:	89 f2                	mov    %esi,%edx
  800fdd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fdf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fe3:	d3 e0                	shl    %cl,%eax
  800fe5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fe9:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fed:	89 f9                	mov    %edi,%ecx
  800fef:	d3 e8                	shr    %cl,%eax
  800ff1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ff3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ff5:	89 f2                	mov    %esi,%edx
  800ff7:	f7 74 24 18          	divl   0x18(%esp)
  800ffb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ffd:	f7 64 24 0c          	mull   0xc(%esp)
  801001:	89 c5                	mov    %eax,%ebp
  801003:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801005:	39 d6                	cmp    %edx,%esi
  801007:	72 67                	jb     801070 <__umoddi3+0x114>
  801009:	74 75                	je     801080 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80100b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80100f:	29 e8                	sub    %ebp,%eax
  801011:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801013:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801017:	d3 e8                	shr    %cl,%eax
  801019:	89 f2                	mov    %esi,%edx
  80101b:	89 f9                	mov    %edi,%ecx
  80101d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80101f:	09 d0                	or     %edx,%eax
  801021:	89 f2                	mov    %esi,%edx
  801023:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801027:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801029:	83 c4 20             	add    $0x20,%esp
  80102c:	5e                   	pop    %esi
  80102d:	5f                   	pop    %edi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801030:	85 c9                	test   %ecx,%ecx
  801032:	75 0b                	jne    80103f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801034:	b8 01 00 00 00       	mov    $0x1,%eax
  801039:	31 d2                	xor    %edx,%edx
  80103b:	f7 f1                	div    %ecx
  80103d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80103f:	89 f0                	mov    %esi,%eax
  801041:	31 d2                	xor    %edx,%edx
  801043:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801045:	89 f8                	mov    %edi,%eax
  801047:	e9 3e ff ff ff       	jmp    800f8a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80104c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80104e:	83 c4 20             	add    $0x20,%esp
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    
  801055:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801058:	39 f5                	cmp    %esi,%ebp
  80105a:	72 04                	jb     801060 <__umoddi3+0x104>
  80105c:	39 f9                	cmp    %edi,%ecx
  80105e:	77 06                	ja     801066 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801060:	89 f2                	mov    %esi,%edx
  801062:	29 cf                	sub    %ecx,%edi
  801064:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801066:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801068:	83 c4 20             	add    $0x20,%esp
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    
  80106f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801070:	89 d1                	mov    %edx,%ecx
  801072:	89 c5                	mov    %eax,%ebp
  801074:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801078:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80107c:	eb 8d                	jmp    80100b <__umoddi3+0xaf>
  80107e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801080:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801084:	72 ea                	jb     801070 <__umoddi3+0x114>
  801086:	89 f1                	mov    %esi,%ecx
  801088:	eb 81                	jmp    80100b <__umoddi3+0xaf>
