
obj/user/faultreadkernel.debug:     file format elf32-i386


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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 a0 1f 80 00 	movl   $0x801fa0,(%esp)
  80004a:	e8 19 01 00 00       	call   800168 <cprintf>
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
  800062:	e8 60 0a 00 00       	call   800ac7 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800083:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	85 f6                	test   %esi,%esi
  80008a:	7e 07                	jle    800093 <libmain+0x3f>
		binaryname = argv[0];
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8000b2:	e8 a2 0e 00 00       	call   800f59 <close_all>
	sys_env_destroy(0);
  8000b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000be:	e8 b2 09 00 00       	call   800a75 <sys_env_destroy>
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    
  8000c5:	00 00                	add    %al,(%eax)
	...

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 14             	sub    $0x14,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 03                	mov    (%ebx),%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000db:	40                   	inc    %eax
  8000dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e3:	75 19                	jne    8000fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ec:	00 
  8000ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f0:	89 04 24             	mov    %eax,(%esp)
  8000f3:	e8 40 09 00 00       	call   800a38 <sys_cputs>
		b->idx = 0;
  8000f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fe:	ff 43 04             	incl   0x4(%ebx)
}
  800101:	83 c4 14             	add    $0x14,%esp
  800104:	5b                   	pop    %ebx
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	8b 45 0c             	mov    0xc(%ebp),%eax
  800127:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012b:	8b 45 08             	mov    0x8(%ebp),%eax
  80012e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013c:	c7 04 24 c8 00 80 00 	movl   $0x8000c8,(%esp)
  800143:	e8 82 01 00 00       	call   8002ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800148:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800152:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800158:	89 04 24             	mov    %eax,(%esp)
  80015b:	e8 d8 08 00 00       	call   800a38 <sys_cputs>

	return b.cnt;
}
  800160:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	89 44 24 04          	mov    %eax,0x4(%esp)
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	89 04 24             	mov    %eax,(%esp)
  80017b:	e8 87 ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  800180:	c9                   	leave  
  800181:	c3                   	ret    
	...

00800184 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 3c             	sub    $0x3c,%esp
  80018d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800190:	89 d7                	mov    %edx,%edi
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	75 08                	jne    8001b0 <printnum+0x2c>
  8001a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ae:	77 57                	ja     800207 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001b4:	4b                   	dec    %ebx
  8001b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cf:	00 
  8001d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dd:	e8 52 1b 00 00       	call   801d34 <__udivdi3>
  8001e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f1:	89 fa                	mov    %edi,%edx
  8001f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f6:	e8 89 ff ff ff       	call   800184 <printnum>
  8001fb:	eb 0f                	jmp    80020c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800201:	89 34 24             	mov    %esi,(%esp)
  800204:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800207:	4b                   	dec    %ebx
  800208:	85 db                	test   %ebx,%ebx
  80020a:	7f f1                	jg     8001fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800210:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800214:	8b 45 10             	mov    0x10(%ebp),%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800222:	00 
  800223:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	e8 1f 1c 00 00       	call   801e54 <__umoddi3>
  800235:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800239:	0f be 80 d1 1f 80 00 	movsbl 0x801fd1(%eax),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800246:	83 c4 3c             	add    $0x3c,%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800251:	83 fa 01             	cmp    $0x1,%edx
  800254:	7e 0e                	jle    800264 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800256:	8b 10                	mov    (%eax),%edx
  800258:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025b:	89 08                	mov    %ecx,(%eax)
  80025d:	8b 02                	mov    (%edx),%eax
  80025f:	8b 52 04             	mov    0x4(%edx),%edx
  800262:	eb 22                	jmp    800286 <getuint+0x38>
	else if (lflag)
  800264:	85 d2                	test   %edx,%edx
  800266:	74 10                	je     800278 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800268:	8b 10                	mov    (%eax),%edx
  80026a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 02                	mov    (%edx),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
  800276:	eb 0e                	jmp    800286 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800291:	8b 10                	mov    (%eax),%edx
  800293:	3b 50 04             	cmp    0x4(%eax),%edx
  800296:	73 08                	jae    8002a0 <sprintputch+0x18>
		*b->buf++ = ch;
  800298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029b:	88 0a                	mov    %cl,(%edx)
  80029d:	42                   	inc    %edx
  80029e:	89 10                	mov    %edx,(%eax)
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	e8 02 00 00 00       	call   8002ca <vprintfmt>
	va_end(ap);
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 4c             	sub    $0x4c,%esp
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d9:	eb 12                	jmp    8002ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	0f 84 6b 03 00 00    	je     80064e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ed:	0f b6 06             	movzbl (%esi),%eax
  8002f0:	46                   	inc    %esi
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e5                	jne    8002db <vprintfmt+0x11>
  8002f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8002fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800301:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800306:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80030d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800312:	eb 26                	jmp    80033a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800317:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80031b:	eb 1d                	jmp    80033a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800320:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800324:	eb 14                	jmp    80033a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800329:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800330:	eb 08                	jmp    80033a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800332:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800335:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 06             	movzbl (%esi),%eax
  80033d:	8d 56 01             	lea    0x1(%esi),%edx
  800340:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800343:	8a 16                	mov    (%esi),%dl
  800345:	83 ea 23             	sub    $0x23,%edx
  800348:	80 fa 55             	cmp    $0x55,%dl
  80034b:	0f 87 e1 02 00 00    	ja     800632 <vprintfmt+0x368>
  800351:	0f b6 d2             	movzbl %dl,%edx
  800354:	ff 24 95 20 21 80 00 	jmp    *0x802120(,%edx,4)
  80035b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80035e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800363:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800366:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80036a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80036d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800370:	83 fa 09             	cmp    $0x9,%edx
  800373:	77 2a                	ja     80039f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800375:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800376:	eb eb                	jmp    800363 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 50 04             	lea    0x4(%eax),%edx
  80037e:	89 55 14             	mov    %edx,0x14(%ebp)
  800381:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800386:	eb 17                	jmp    80039f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800388:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80038c:	78 98                	js     800326 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800391:	eb a7                	jmp    80033a <vprintfmt+0x70>
  800393:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800396:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80039d:	eb 9b                	jmp    80033a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80039f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a3:	79 95                	jns    80033a <vprintfmt+0x70>
  8003a5:	eb 8b                	jmp    800332 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ab:	eb 8d                	jmp    80033a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 50 04             	lea    0x4(%eax),%edx
  8003b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c5:	e9 23 ff ff ff       	jmp    8002ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	85 c0                	test   %eax,%eax
  8003d7:	79 02                	jns    8003db <vprintfmt+0x111>
  8003d9:	f7 d8                	neg    %eax
  8003db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dd:	83 f8 0f             	cmp    $0xf,%eax
  8003e0:	7f 0b                	jg     8003ed <vprintfmt+0x123>
  8003e2:	8b 04 85 80 22 80 00 	mov    0x802280(,%eax,4),%eax
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	75 23                	jne    800410 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f1:	c7 44 24 08 e9 1f 80 	movl   $0x801fe9,0x8(%esp)
  8003f8:	00 
  8003f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 9a fe ff ff       	call   8002a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040b:	e9 dd fe ff ff       	jmp    8002ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800410:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800414:	c7 44 24 08 b1 23 80 	movl   $0x8023b1,0x8(%esp)
  80041b:	00 
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	8b 55 08             	mov    0x8(%ebp),%edx
  800423:	89 14 24             	mov    %edx,(%esp)
  800426:	e8 77 fe ff ff       	call   8002a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042e:	e9 ba fe ff ff       	jmp    8002ed <vprintfmt+0x23>
  800433:	89 f9                	mov    %edi,%ecx
  800435:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800438:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8d 50 04             	lea    0x4(%eax),%edx
  800441:	89 55 14             	mov    %edx,0x14(%ebp)
  800444:	8b 30                	mov    (%eax),%esi
  800446:	85 f6                	test   %esi,%esi
  800448:	75 05                	jne    80044f <vprintfmt+0x185>
				p = "(null)";
  80044a:	be e2 1f 80 00       	mov    $0x801fe2,%esi
			if (width > 0 && padc != '-')
  80044f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800453:	0f 8e 84 00 00 00    	jle    8004dd <vprintfmt+0x213>
  800459:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80045d:	74 7e                	je     8004dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800463:	89 34 24             	mov    %esi,(%esp)
  800466:	e8 8b 02 00 00       	call   8006f6 <strnlen>
  80046b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80046e:	29 c2                	sub    %eax,%edx
  800470:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800473:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800477:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80047a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80047d:	89 de                	mov    %ebx,%esi
  80047f:	89 d3                	mov    %edx,%ebx
  800481:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	eb 0b                	jmp    800490 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800485:	89 74 24 04          	mov    %esi,0x4(%esp)
  800489:	89 3c 24             	mov    %edi,(%esp)
  80048c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	4b                   	dec    %ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	7f f1                	jg     800485 <vprintfmt+0x1bb>
  800494:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800497:	89 f3                	mov    %esi,%ebx
  800499:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80049c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	79 05                	jns    8004a8 <vprintfmt+0x1de>
  8004a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ab:	29 c2                	sub    %eax,%edx
  8004ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b0:	eb 2b                	jmp    8004dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004b6:	74 18                	je     8004d0 <vprintfmt+0x206>
  8004b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004bb:	83 fa 5e             	cmp    $0x5e,%edx
  8004be:	76 10                	jbe    8004d0 <vprintfmt+0x206>
					putch('?', putdat);
  8004c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004cb:	ff 55 08             	call   *0x8(%ebp)
  8004ce:	eb 0a                	jmp    8004da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	ff 4d e4             	decl   -0x1c(%ebp)
  8004dd:	0f be 06             	movsbl (%esi),%eax
  8004e0:	46                   	inc    %esi
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	74 21                	je     800506 <vprintfmt+0x23c>
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	78 c9                	js     8004b2 <vprintfmt+0x1e8>
  8004e9:	4f                   	dec    %edi
  8004ea:	79 c6                	jns    8004b2 <vprintfmt+0x1e8>
  8004ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ef:	89 de                	mov    %ebx,%esi
  8004f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004f4:	eb 18                	jmp    80050e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800501:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800503:	4b                   	dec    %ebx
  800504:	eb 08                	jmp    80050e <vprintfmt+0x244>
  800506:	8b 7d 08             	mov    0x8(%ebp),%edi
  800509:	89 de                	mov    %ebx,%esi
  80050b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80050e:	85 db                	test   %ebx,%ebx
  800510:	7f e4                	jg     8004f6 <vprintfmt+0x22c>
  800512:	89 7d 08             	mov    %edi,0x8(%ebp)
  800515:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	e9 ce fd ff ff       	jmp    8002ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051f:	83 f9 01             	cmp    $0x1,%ecx
  800522:	7e 10                	jle    800534 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 08             	lea    0x8(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	8b 30                	mov    (%eax),%esi
  80052f:	8b 78 04             	mov    0x4(%eax),%edi
  800532:	eb 26                	jmp    80055a <vprintfmt+0x290>
	else if (lflag)
  800534:	85 c9                	test   %ecx,%ecx
  800536:	74 12                	je     80054a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 30                	mov    (%eax),%esi
  800543:	89 f7                	mov    %esi,%edi
  800545:	c1 ff 1f             	sar    $0x1f,%edi
  800548:	eb 10                	jmp    80055a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 30                	mov    (%eax),%esi
  800555:	89 f7                	mov    %esi,%edi
  800557:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055a:	85 ff                	test   %edi,%edi
  80055c:	78 0a                	js     800568 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800563:	e9 8c 00 00 00       	jmp    8005f4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800568:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80056c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800573:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800576:	f7 de                	neg    %esi
  800578:	83 d7 00             	adc    $0x0,%edi
  80057b:	f7 df                	neg    %edi
			}
			base = 10;
  80057d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800582:	eb 70                	jmp    8005f4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800584:	89 ca                	mov    %ecx,%edx
  800586:	8d 45 14             	lea    0x14(%ebp),%eax
  800589:	e8 c0 fc ff ff       	call   80024e <getuint>
  80058e:	89 c6                	mov    %eax,%esi
  800590:	89 d7                	mov    %edx,%edi
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800597:	eb 5b                	jmp    8005f4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800599:	89 ca                	mov    %ecx,%edx
  80059b:	8d 45 14             	lea    0x14(%ebp),%eax
  80059e:	e8 ab fc ff ff       	call   80024e <getuint>
  8005a3:	89 c6                	mov    %eax,%esi
  8005a5:	89 d7                	mov    %edx,%edi
			base = 8;
  8005a7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005ac:	eb 46                	jmp    8005f4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005b9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d3:	8b 30                	mov    (%eax),%esi
  8005d5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005df:	eb 13                	jmp    8005f4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e1:	89 ca                	mov    %ecx,%edx
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	e8 63 fc ff ff       	call   80024e <getuint>
  8005eb:	89 c6                	mov    %eax,%esi
  8005ed:	89 d7                	mov    %edx,%edi
			base = 16;
  8005ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8005f8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800603:	89 44 24 08          	mov    %eax,0x8(%esp)
  800607:	89 34 24             	mov    %esi,(%esp)
  80060a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060e:	89 da                	mov    %ebx,%edx
  800610:	8b 45 08             	mov    0x8(%ebp),%eax
  800613:	e8 6c fb ff ff       	call   800184 <printnum>
			break;
  800618:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061b:	e9 cd fc ff ff       	jmp    8002ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062d:	e9 bb fc ff ff       	jmp    8002ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800632:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800636:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80063d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800640:	eb 01                	jmp    800643 <vprintfmt+0x379>
  800642:	4e                   	dec    %esi
  800643:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800647:	75 f9                	jne    800642 <vprintfmt+0x378>
  800649:	e9 9f fc ff ff       	jmp    8002ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80064e:	83 c4 4c             	add    $0x4c,%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	83 ec 28             	sub    $0x28,%esp
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800662:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800665:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800669:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800673:	85 c0                	test   %eax,%eax
  800675:	74 30                	je     8006a7 <vsnprintf+0x51>
  800677:	85 d2                	test   %edx,%edx
  800679:	7e 33                	jle    8006ae <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800682:	8b 45 10             	mov    0x10(%ebp),%eax
  800685:	89 44 24 08          	mov    %eax,0x8(%esp)
  800689:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80068c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800690:	c7 04 24 88 02 80 00 	movl   $0x800288,(%esp)
  800697:	e8 2e fc ff ff       	call   8002ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a5:	eb 0c                	jmp    8006b3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ac:	eb 05                	jmp    8006b3 <vsnprintf+0x5d>
  8006ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b3:	c9                   	leave  
  8006b4:	c3                   	ret    

008006b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	89 04 24             	mov    %eax,(%esp)
  8006d6:	e8 7b ff ff ff       	call   800656 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    
  8006dd:	00 00                	add    %al,(%eax)
	...

008006e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 01                	jmp    8006ee <strlen+0xe>
		n++;
  8006ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f2:	75 f9                	jne    8006ed <strlen+0xd>
		n++;
	return n;
}
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8006fc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	eb 01                	jmp    800707 <strnlen+0x11>
		n++;
  800706:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	39 d0                	cmp    %edx,%eax
  800709:	74 06                	je     800711 <strnlen+0x1b>
  80070b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070f:	75 f5                	jne    800706 <strnlen+0x10>
		n++;
	return n;
}
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	53                   	push   %ebx
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071d:	ba 00 00 00 00       	mov    $0x0,%edx
  800722:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800725:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800728:	42                   	inc    %edx
  800729:	84 c9                	test   %cl,%cl
  80072b:	75 f5                	jne    800722 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80072d:	5b                   	pop    %ebx
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073a:	89 1c 24             	mov    %ebx,(%esp)
  80073d:	e8 9e ff ff ff       	call   8006e0 <strlen>
	strcpy(dst + len, src);
  800742:	8b 55 0c             	mov    0xc(%ebp),%edx
  800745:	89 54 24 04          	mov    %edx,0x4(%esp)
  800749:	01 d8                	add    %ebx,%eax
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	e8 c0 ff ff ff       	call   800713 <strcpy>
	return dst;
}
  800753:	89 d8                	mov    %ebx,%eax
  800755:	83 c4 08             	add    $0x8,%esp
  800758:	5b                   	pop    %ebx
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
  800766:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800769:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076e:	eb 0c                	jmp    80077c <strncpy+0x21>
		*dst++ = *src;
  800770:	8a 1a                	mov    (%edx),%bl
  800772:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800775:	80 3a 01             	cmpb   $0x1,(%edx)
  800778:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077b:	41                   	inc    %ecx
  80077c:	39 f1                	cmp    %esi,%ecx
  80077e:	75 f0                	jne    800770 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	56                   	push   %esi
  800788:	53                   	push   %ebx
  800789:	8b 75 08             	mov    0x8(%ebp),%esi
  80078c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800792:	85 d2                	test   %edx,%edx
  800794:	75 0a                	jne    8007a0 <strlcpy+0x1c>
  800796:	89 f0                	mov    %esi,%eax
  800798:	eb 1a                	jmp    8007b4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079a:	88 18                	mov    %bl,(%eax)
  80079c:	40                   	inc    %eax
  80079d:	41                   	inc    %ecx
  80079e:	eb 02                	jmp    8007a2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007a2:	4a                   	dec    %edx
  8007a3:	74 0a                	je     8007af <strlcpy+0x2b>
  8007a5:	8a 19                	mov    (%ecx),%bl
  8007a7:	84 db                	test   %bl,%bl
  8007a9:	75 ef                	jne    80079a <strlcpy+0x16>
  8007ab:	89 c2                	mov    %eax,%edx
  8007ad:	eb 02                	jmp    8007b1 <strlcpy+0x2d>
  8007af:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007b1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007b4:	29 f0                	sub    %esi,%eax
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c3:	eb 02                	jmp    8007c7 <strcmp+0xd>
		p++, q++;
  8007c5:	41                   	inc    %ecx
  8007c6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c7:	8a 01                	mov    (%ecx),%al
  8007c9:	84 c0                	test   %al,%al
  8007cb:	74 04                	je     8007d1 <strcmp+0x17>
  8007cd:	3a 02                	cmp    (%edx),%al
  8007cf:	74 f4                	je     8007c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d1:	0f b6 c0             	movzbl %al,%eax
  8007d4:	0f b6 12             	movzbl (%edx),%edx
  8007d7:	29 d0                	sub    %edx,%eax
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8007e8:	eb 03                	jmp    8007ed <strncmp+0x12>
		n--, p++, q++;
  8007ea:	4a                   	dec    %edx
  8007eb:	40                   	inc    %eax
  8007ec:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 14                	je     800805 <strncmp+0x2a>
  8007f1:	8a 18                	mov    (%eax),%bl
  8007f3:	84 db                	test   %bl,%bl
  8007f5:	74 04                	je     8007fb <strncmp+0x20>
  8007f7:	3a 19                	cmp    (%ecx),%bl
  8007f9:	74 ef                	je     8007ea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fb:	0f b6 00             	movzbl (%eax),%eax
  8007fe:	0f b6 11             	movzbl (%ecx),%edx
  800801:	29 d0                	sub    %edx,%eax
  800803:	eb 05                	jmp    80080a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080a:	5b                   	pop    %ebx
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800816:	eb 05                	jmp    80081d <strchr+0x10>
		if (*s == c)
  800818:	38 ca                	cmp    %cl,%dl
  80081a:	74 0c                	je     800828 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081c:	40                   	inc    %eax
  80081d:	8a 10                	mov    (%eax),%dl
  80081f:	84 d2                	test   %dl,%dl
  800821:	75 f5                	jne    800818 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800833:	eb 05                	jmp    80083a <strfind+0x10>
		if (*s == c)
  800835:	38 ca                	cmp    %cl,%dl
  800837:	74 07                	je     800840 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800839:	40                   	inc    %eax
  80083a:	8a 10                	mov    (%eax),%dl
  80083c:	84 d2                	test   %dl,%dl
  80083e:	75 f5                	jne    800835 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	57                   	push   %edi
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800851:	85 c9                	test   %ecx,%ecx
  800853:	74 30                	je     800885 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800855:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085b:	75 25                	jne    800882 <memset+0x40>
  80085d:	f6 c1 03             	test   $0x3,%cl
  800860:	75 20                	jne    800882 <memset+0x40>
		c &= 0xFF;
  800862:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800865:	89 d3                	mov    %edx,%ebx
  800867:	c1 e3 08             	shl    $0x8,%ebx
  80086a:	89 d6                	mov    %edx,%esi
  80086c:	c1 e6 18             	shl    $0x18,%esi
  80086f:	89 d0                	mov    %edx,%eax
  800871:	c1 e0 10             	shl    $0x10,%eax
  800874:	09 f0                	or     %esi,%eax
  800876:	09 d0                	or     %edx,%eax
  800878:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80087a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80087d:	fc                   	cld    
  80087e:	f3 ab                	rep stos %eax,%es:(%edi)
  800880:	eb 03                	jmp    800885 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800882:	fc                   	cld    
  800883:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800885:	89 f8                	mov    %edi,%eax
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5f                   	pop    %edi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8b 75 0c             	mov    0xc(%ebp),%esi
  800897:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089a:	39 c6                	cmp    %eax,%esi
  80089c:	73 34                	jae    8008d2 <memmove+0x46>
  80089e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a1:	39 d0                	cmp    %edx,%eax
  8008a3:	73 2d                	jae    8008d2 <memmove+0x46>
		s += n;
		d += n;
  8008a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a8:	f6 c2 03             	test   $0x3,%dl
  8008ab:	75 1b                	jne    8008c8 <memmove+0x3c>
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 13                	jne    8008c8 <memmove+0x3c>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 0e                	jne    8008c8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ba:	83 ef 04             	sub    $0x4,%edi
  8008bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008c3:	fd                   	std    
  8008c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c6:	eb 07                	jmp    8008cf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c8:	4f                   	dec    %edi
  8008c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008cc:	fd                   	std    
  8008cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cf:	fc                   	cld    
  8008d0:	eb 20                	jmp    8008f2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d8:	75 13                	jne    8008ed <memmove+0x61>
  8008da:	a8 03                	test   $0x3,%al
  8008dc:	75 0f                	jne    8008ed <memmove+0x61>
  8008de:	f6 c1 03             	test   $0x3,%cl
  8008e1:	75 0a                	jne    8008ed <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008e6:	89 c7                	mov    %eax,%edi
  8008e8:	fc                   	cld    
  8008e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008eb:	eb 05                	jmp    8008f2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008ed:	89 c7                	mov    %eax,%edi
  8008ef:	fc                   	cld    
  8008f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f2:	5e                   	pop    %esi
  8008f3:	5f                   	pop    %edi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800903:	8b 45 0c             	mov    0xc(%ebp),%eax
  800906:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	e8 77 ff ff ff       	call   80088c <memmove>
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800920:	8b 75 0c             	mov    0xc(%ebp),%esi
  800923:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800926:	ba 00 00 00 00       	mov    $0x0,%edx
  80092b:	eb 16                	jmp    800943 <memcmp+0x2c>
		if (*s1 != *s2)
  80092d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800930:	42                   	inc    %edx
  800931:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800935:	38 c8                	cmp    %cl,%al
  800937:	74 0a                	je     800943 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800939:	0f b6 c0             	movzbl %al,%eax
  80093c:	0f b6 c9             	movzbl %cl,%ecx
  80093f:	29 c8                	sub    %ecx,%eax
  800941:	eb 09                	jmp    80094c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800943:	39 da                	cmp    %ebx,%edx
  800945:	75 e6                	jne    80092d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80095a:	89 c2                	mov    %eax,%edx
  80095c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80095f:	eb 05                	jmp    800966 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800961:	38 08                	cmp    %cl,(%eax)
  800963:	74 05                	je     80096a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800965:	40                   	inc    %eax
  800966:	39 d0                	cmp    %edx,%eax
  800968:	72 f7                	jb     800961 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	8b 55 08             	mov    0x8(%ebp),%edx
  800975:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800978:	eb 01                	jmp    80097b <strtol+0xf>
		s++;
  80097a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097b:	8a 02                	mov    (%edx),%al
  80097d:	3c 20                	cmp    $0x20,%al
  80097f:	74 f9                	je     80097a <strtol+0xe>
  800981:	3c 09                	cmp    $0x9,%al
  800983:	74 f5                	je     80097a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800985:	3c 2b                	cmp    $0x2b,%al
  800987:	75 08                	jne    800991 <strtol+0x25>
		s++;
  800989:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098a:	bf 00 00 00 00       	mov    $0x0,%edi
  80098f:	eb 13                	jmp    8009a4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800991:	3c 2d                	cmp    $0x2d,%al
  800993:	75 0a                	jne    80099f <strtol+0x33>
		s++, neg = 1;
  800995:	8d 52 01             	lea    0x1(%edx),%edx
  800998:	bf 01 00 00 00       	mov    $0x1,%edi
  80099d:	eb 05                	jmp    8009a4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a4:	85 db                	test   %ebx,%ebx
  8009a6:	74 05                	je     8009ad <strtol+0x41>
  8009a8:	83 fb 10             	cmp    $0x10,%ebx
  8009ab:	75 28                	jne    8009d5 <strtol+0x69>
  8009ad:	8a 02                	mov    (%edx),%al
  8009af:	3c 30                	cmp    $0x30,%al
  8009b1:	75 10                	jne    8009c3 <strtol+0x57>
  8009b3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009b7:	75 0a                	jne    8009c3 <strtol+0x57>
		s += 2, base = 16;
  8009b9:	83 c2 02             	add    $0x2,%edx
  8009bc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c1:	eb 12                	jmp    8009d5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009c3:	85 db                	test   %ebx,%ebx
  8009c5:	75 0e                	jne    8009d5 <strtol+0x69>
  8009c7:	3c 30                	cmp    $0x30,%al
  8009c9:	75 05                	jne    8009d0 <strtol+0x64>
		s++, base = 8;
  8009cb:	42                   	inc    %edx
  8009cc:	b3 08                	mov    $0x8,%bl
  8009ce:	eb 05                	jmp    8009d5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009d0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009da:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009dc:	8a 0a                	mov    (%edx),%cl
  8009de:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009e1:	80 fb 09             	cmp    $0x9,%bl
  8009e4:	77 08                	ja     8009ee <strtol+0x82>
			dig = *s - '0';
  8009e6:	0f be c9             	movsbl %cl,%ecx
  8009e9:	83 e9 30             	sub    $0x30,%ecx
  8009ec:	eb 1e                	jmp    800a0c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8009ee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x92>
			dig = *s - 'a' + 10;
  8009f6:	0f be c9             	movsbl %cl,%ecx
  8009f9:	83 e9 57             	sub    $0x57,%ecx
  8009fc:	eb 0e                	jmp    800a0c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8009fe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 12                	ja     800a18 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a06:	0f be c9             	movsbl %cl,%ecx
  800a09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a0c:	39 f1                	cmp    %esi,%ecx
  800a0e:	7d 0c                	jge    800a1c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a10:	42                   	inc    %edx
  800a11:	0f af c6             	imul   %esi,%eax
  800a14:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a16:	eb c4                	jmp    8009dc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a18:	89 c1                	mov    %eax,%ecx
  800a1a:	eb 02                	jmp    800a1e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a1c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a22:	74 05                	je     800a29 <strtol+0xbd>
		*endptr = (char *) s;
  800a24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a27:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a29:	85 ff                	test   %edi,%edi
  800a2b:	74 04                	je     800a31 <strtol+0xc5>
  800a2d:	89 c8                	mov    %ecx,%eax
  800a2f:	f7 d8                	neg    %eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    
	...

00800a38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a46:	8b 55 08             	mov    0x8(%ebp),%edx
  800a49:	89 c3                	mov    %eax,%ebx
  800a4b:	89 c7                	mov    %eax,%edi
  800a4d:	89 c6                	mov    %eax,%esi
  800a4f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5f                   	pop    %edi
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a61:	b8 01 00 00 00       	mov    $0x1,%eax
  800a66:	89 d1                	mov    %edx,%ecx
  800a68:	89 d3                	mov    %edx,%ebx
  800a6a:	89 d7                	mov    %edx,%edi
  800a6c:	89 d6                	mov    %edx,%esi
  800a6e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
  800a7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a83:	b8 03 00 00 00       	mov    $0x3,%eax
  800a88:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8b:	89 cb                	mov    %ecx,%ebx
  800a8d:	89 cf                	mov    %ecx,%edi
  800a8f:	89 ce                	mov    %ecx,%esi
  800a91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a93:	85 c0                	test   %eax,%eax
  800a95:	7e 28                	jle    800abf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a9b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aa2:	00 
  800aa3:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800aaa:	00 
  800aab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ab2:	00 
  800ab3:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800aba:	e8 c1 10 00 00       	call   801b80 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abf:	83 c4 2c             	add    $0x2c,%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad7:	89 d1                	mov    %edx,%ecx
  800ad9:	89 d3                	mov    %edx,%ebx
  800adb:	89 d7                	mov    %edx,%edi
  800add:	89 d6                	mov    %edx,%esi
  800adf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_yield>:

void
sys_yield(void)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aec:	ba 00 00 00 00       	mov    $0x0,%edx
  800af1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800af6:	89 d1                	mov    %edx,%ecx
  800af8:	89 d3                	mov    %edx,%ebx
  800afa:	89 d7                	mov    %edx,%edi
  800afc:	89 d6                	mov    %edx,%esi
  800afe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	be 00 00 00 00       	mov    $0x0,%esi
  800b13:	b8 04 00 00 00       	mov    $0x4,%eax
  800b18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	89 f7                	mov    %esi,%edi
  800b23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	7e 28                	jle    800b51 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b2d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b34:	00 
  800b35:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800b3c:	00 
  800b3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b44:	00 
  800b45:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800b4c:	e8 2f 10 00 00       	call   801b80 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b51:	83 c4 2c             	add    $0x2c,%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	b8 05 00 00 00       	mov    $0x5,%eax
  800b67:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	7e 28                	jle    800ba4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b80:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b87:	00 
  800b88:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800b8f:	00 
  800b90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b97:	00 
  800b98:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800b9f:	e8 dc 0f 00 00       	call   801b80 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba4:	83 c4 2c             	add    $0x2c,%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bba:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	89 df                	mov    %ebx,%edi
  800bc7:	89 de                	mov    %ebx,%esi
  800bc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	7e 28                	jle    800bf7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bda:	00 
  800bdb:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800be2:	00 
  800be3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bea:	00 
  800beb:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800bf2:	e8 89 0f 00 00       	call   801b80 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf7:	83 c4 2c             	add    $0x2c,%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 df                	mov    %ebx,%edi
  800c1a:	89 de                	mov    %ebx,%esi
  800c1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 28                	jle    800c4a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c26:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c2d:	00 
  800c2e:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800c35:	00 
  800c36:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3d:	00 
  800c3e:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800c45:	e8 36 0f 00 00       	call   801b80 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4a:	83 c4 2c             	add    $0x2c,%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	b8 09 00 00 00       	mov    $0x9,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 28                	jle    800c9d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c79:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c80:	00 
  800c81:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800c88:	00 
  800c89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c90:	00 
  800c91:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800c98:	e8 e3 0e 00 00       	call   801b80 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9d:	83 c4 2c             	add    $0x2c,%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	89 df                	mov    %ebx,%edi
  800cc0:	89 de                	mov    %ebx,%esi
  800cc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 28                	jle    800cf0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cd3:	00 
  800cd4:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800cdb:	00 
  800cdc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce3:	00 
  800ce4:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800ceb:	e8 90 0e 00 00       	call   801b80 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf0:	83 c4 2c             	add    $0x2c,%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	be 00 00 00 00       	mov    $0x0,%esi
  800d03:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d29:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	89 cb                	mov    %ecx,%ebx
  800d33:	89 cf                	mov    %ecx,%edi
  800d35:	89 ce                	mov    %ecx,%esi
  800d37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 28                	jle    800d65 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d41:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d48:	00 
  800d49:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800d50:	00 
  800d51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d58:	00 
  800d59:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800d60:	e8 1b 0e 00 00       	call   801b80 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d65:	83 c4 2c             	add    $0x2c,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    
  800d6d:	00 00                	add    %al,(%eax)
	...

00800d70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	05 00 00 00 30       	add    $0x30000000,%eax
  800d7b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	89 04 24             	mov    %eax,(%esp)
  800d8c:	e8 df ff ff ff       	call   800d70 <fd2num>
  800d91:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d96:	c1 e0 0c             	shl    $0xc,%eax
}
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    

00800d9b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	53                   	push   %ebx
  800d9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800da2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800da7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da9:	89 c2                	mov    %eax,%edx
  800dab:	c1 ea 16             	shr    $0x16,%edx
  800dae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db5:	f6 c2 01             	test   $0x1,%dl
  800db8:	74 11                	je     800dcb <fd_alloc+0x30>
  800dba:	89 c2                	mov    %eax,%edx
  800dbc:	c1 ea 0c             	shr    $0xc,%edx
  800dbf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc6:	f6 c2 01             	test   $0x1,%dl
  800dc9:	75 09                	jne    800dd4 <fd_alloc+0x39>
			*fd_store = fd;
  800dcb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd2:	eb 17                	jmp    800deb <fd_alloc+0x50>
  800dd4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dde:	75 c7                	jne    800da7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800de0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800de6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800deb:	5b                   	pop    %ebx
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df4:	83 f8 1f             	cmp    $0x1f,%eax
  800df7:	77 36                	ja     800e2f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df9:	05 00 00 0d 00       	add    $0xd0000,%eax
  800dfe:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e01:	89 c2                	mov    %eax,%edx
  800e03:	c1 ea 16             	shr    $0x16,%edx
  800e06:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0d:	f6 c2 01             	test   $0x1,%dl
  800e10:	74 24                	je     800e36 <fd_lookup+0x48>
  800e12:	89 c2                	mov    %eax,%edx
  800e14:	c1 ea 0c             	shr    $0xc,%edx
  800e17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1e:	f6 c2 01             	test   $0x1,%dl
  800e21:	74 1a                	je     800e3d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e26:	89 02                	mov    %eax,(%edx)
	return 0;
  800e28:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2d:	eb 13                	jmp    800e42 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e34:	eb 0c                	jmp    800e42 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3b:	eb 05                	jmp    800e42 <fd_lookup+0x54>
  800e3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	53                   	push   %ebx
  800e48:	83 ec 14             	sub    $0x14,%esp
  800e4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800e51:	ba 00 00 00 00       	mov    $0x0,%edx
  800e56:	eb 0e                	jmp    800e66 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800e58:	39 08                	cmp    %ecx,(%eax)
  800e5a:	75 09                	jne    800e65 <dev_lookup+0x21>
			*dev = devtab[i];
  800e5c:	89 03                	mov    %eax,(%ebx)
			return 0;
  800e5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e63:	eb 35                	jmp    800e9a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e65:	42                   	inc    %edx
  800e66:	8b 04 95 88 23 80 00 	mov    0x802388(,%edx,4),%eax
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	75 e7                	jne    800e58 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e71:	a1 04 40 80 00       	mov    0x804004,%eax
  800e76:	8b 00                	mov    (%eax),%eax
  800e78:	8b 40 48             	mov    0x48(%eax),%eax
  800e7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e83:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  800e8a:	e8 d9 f2 ff ff       	call   800168 <cprintf>
	*dev = 0;
  800e8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e9a:	83 c4 14             	add    $0x14,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 30             	sub    $0x30,%esp
  800ea8:	8b 75 08             	mov    0x8(%ebp),%esi
  800eab:	8a 45 0c             	mov    0xc(%ebp),%al
  800eae:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb1:	89 34 24             	mov    %esi,(%esp)
  800eb4:	e8 b7 fe ff ff       	call   800d70 <fd2num>
  800eb9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ebc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ec0:	89 04 24             	mov    %eax,(%esp)
  800ec3:	e8 26 ff ff ff       	call   800dee <fd_lookup>
  800ec8:	89 c3                	mov    %eax,%ebx
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	78 05                	js     800ed3 <fd_close+0x33>
	    || fd != fd2)
  800ece:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ed1:	74 0d                	je     800ee0 <fd_close+0x40>
		return (must_exist ? r : 0);
  800ed3:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ed7:	75 46                	jne    800f1f <fd_close+0x7f>
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	eb 3f                	jmp    800f1f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ee0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ee3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee7:	8b 06                	mov    (%esi),%eax
  800ee9:	89 04 24             	mov    %eax,(%esp)
  800eec:	e8 53 ff ff ff       	call   800e44 <dev_lookup>
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	78 18                	js     800f0f <fd_close+0x6f>
		if (dev->dev_close)
  800ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800efa:	8b 40 10             	mov    0x10(%eax),%eax
  800efd:	85 c0                	test   %eax,%eax
  800eff:	74 09                	je     800f0a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f01:	89 34 24             	mov    %esi,(%esp)
  800f04:	ff d0                	call   *%eax
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	eb 05                	jmp    800f0f <fd_close+0x6f>
		else
			r = 0;
  800f0a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f1a:	e8 8d fc ff ff       	call   800bac <sys_page_unmap>
	return r;
}
  800f1f:	89 d8                	mov    %ebx,%eax
  800f21:	83 c4 30             	add    $0x30,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	89 04 24             	mov    %eax,(%esp)
  800f3b:	e8 ae fe ff ff       	call   800dee <fd_lookup>
  800f40:	85 c0                	test   %eax,%eax
  800f42:	78 13                	js     800f57 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f44:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f4b:	00 
  800f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4f:	89 04 24             	mov    %eax,(%esp)
  800f52:	e8 49 ff ff ff       	call   800ea0 <fd_close>
}
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <close_all>:

void
close_all(void)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f60:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f65:	89 1c 24             	mov    %ebx,(%esp)
  800f68:	e8 bb ff ff ff       	call   800f28 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f6d:	43                   	inc    %ebx
  800f6e:	83 fb 20             	cmp    $0x20,%ebx
  800f71:	75 f2                	jne    800f65 <close_all+0xc>
		close(i);
}
  800f73:	83 c4 14             	add    $0x14,%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	57                   	push   %edi
  800f7d:	56                   	push   %esi
  800f7e:	53                   	push   %ebx
  800f7f:	83 ec 4c             	sub    $0x4c,%esp
  800f82:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f85:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8f:	89 04 24             	mov    %eax,(%esp)
  800f92:	e8 57 fe ff ff       	call   800dee <fd_lookup>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	0f 88 e1 00 00 00    	js     801082 <dup+0x109>
		return r;
	close(newfdnum);
  800fa1:	89 3c 24             	mov    %edi,(%esp)
  800fa4:	e8 7f ff ff ff       	call   800f28 <close>

	newfd = INDEX2FD(newfdnum);
  800fa9:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800faf:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb5:	89 04 24             	mov    %eax,(%esp)
  800fb8:	e8 c3 fd ff ff       	call   800d80 <fd2data>
  800fbd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fbf:	89 34 24             	mov    %esi,(%esp)
  800fc2:	e8 b9 fd ff ff       	call   800d80 <fd2data>
  800fc7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fca:	89 d8                	mov    %ebx,%eax
  800fcc:	c1 e8 16             	shr    $0x16,%eax
  800fcf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd6:	a8 01                	test   $0x1,%al
  800fd8:	74 46                	je     801020 <dup+0xa7>
  800fda:	89 d8                	mov    %ebx,%eax
  800fdc:	c1 e8 0c             	shr    $0xc,%eax
  800fdf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe6:	f6 c2 01             	test   $0x1,%dl
  800fe9:	74 35                	je     801020 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800feb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff2:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ffb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ffe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801002:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801009:	00 
  80100a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80100e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801015:	e8 3f fb ff ff       	call   800b59 <sys_page_map>
  80101a:	89 c3                	mov    %eax,%ebx
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 3b                	js     80105b <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801020:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801023:	89 c2                	mov    %eax,%edx
  801025:	c1 ea 0c             	shr    $0xc,%edx
  801028:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80102f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801035:	89 54 24 10          	mov    %edx,0x10(%esp)
  801039:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80103d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801044:	00 
  801045:	89 44 24 04          	mov    %eax,0x4(%esp)
  801049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801050:	e8 04 fb ff ff       	call   800b59 <sys_page_map>
  801055:	89 c3                	mov    %eax,%ebx
  801057:	85 c0                	test   %eax,%eax
  801059:	79 25                	jns    801080 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80105b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80105f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801066:	e8 41 fb ff ff       	call   800bac <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80106e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801072:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801079:	e8 2e fb ff ff       	call   800bac <sys_page_unmap>
	return r;
  80107e:	eb 02                	jmp    801082 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801080:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801082:	89 d8                	mov    %ebx,%eax
  801084:	83 c4 4c             	add    $0x4c,%esp
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	53                   	push   %ebx
  801090:	83 ec 24             	sub    $0x24,%esp
  801093:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801096:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109d:	89 1c 24             	mov    %ebx,(%esp)
  8010a0:	e8 49 fd ff ff       	call   800dee <fd_lookup>
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	78 6f                	js     801118 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b3:	8b 00                	mov    (%eax),%eax
  8010b5:	89 04 24             	mov    %eax,(%esp)
  8010b8:	e8 87 fd ff ff       	call   800e44 <dev_lookup>
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	78 57                	js     801118 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c4:	8b 50 08             	mov    0x8(%eax),%edx
  8010c7:	83 e2 03             	and    $0x3,%edx
  8010ca:	83 fa 01             	cmp    $0x1,%edx
  8010cd:	75 25                	jne    8010f4 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d4:	8b 00                	mov    (%eax),%eax
  8010d6:	8b 40 48             	mov    0x48(%eax),%eax
  8010d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e1:	c7 04 24 4d 23 80 00 	movl   $0x80234d,(%esp)
  8010e8:	e8 7b f0 ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  8010ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f2:	eb 24                	jmp    801118 <read+0x8c>
	}
	if (!dev->dev_read)
  8010f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010f7:	8b 52 08             	mov    0x8(%edx),%edx
  8010fa:	85 d2                	test   %edx,%edx
  8010fc:	74 15                	je     801113 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801101:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801105:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801108:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80110c:	89 04 24             	mov    %eax,(%esp)
  80110f:	ff d2                	call   *%edx
  801111:	eb 05                	jmp    801118 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801113:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801118:	83 c4 24             	add    $0x24,%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 1c             	sub    $0x1c,%esp
  801127:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80112d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801132:	eb 23                	jmp    801157 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801134:	89 f0                	mov    %esi,%eax
  801136:	29 d8                	sub    %ebx,%eax
  801138:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113f:	01 d8                	add    %ebx,%eax
  801141:	89 44 24 04          	mov    %eax,0x4(%esp)
  801145:	89 3c 24             	mov    %edi,(%esp)
  801148:	e8 3f ff ff ff       	call   80108c <read>
		if (m < 0)
  80114d:	85 c0                	test   %eax,%eax
  80114f:	78 10                	js     801161 <readn+0x43>
			return m;
		if (m == 0)
  801151:	85 c0                	test   %eax,%eax
  801153:	74 0a                	je     80115f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801155:	01 c3                	add    %eax,%ebx
  801157:	39 f3                	cmp    %esi,%ebx
  801159:	72 d9                	jb     801134 <readn+0x16>
  80115b:	89 d8                	mov    %ebx,%eax
  80115d:	eb 02                	jmp    801161 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80115f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801161:	83 c4 1c             	add    $0x1c,%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	53                   	push   %ebx
  80116d:	83 ec 24             	sub    $0x24,%esp
  801170:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801173:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117a:	89 1c 24             	mov    %ebx,(%esp)
  80117d:	e8 6c fc ff ff       	call   800dee <fd_lookup>
  801182:	85 c0                	test   %eax,%eax
  801184:	78 6a                	js     8011f0 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801186:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801190:	8b 00                	mov    (%eax),%eax
  801192:	89 04 24             	mov    %eax,(%esp)
  801195:	e8 aa fc ff ff       	call   800e44 <dev_lookup>
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 52                	js     8011f0 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80119e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a5:	75 25                	jne    8011cc <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ac:	8b 00                	mov    (%eax),%eax
  8011ae:	8b 40 48             	mov    0x48(%eax),%eax
  8011b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b9:	c7 04 24 69 23 80 00 	movl   $0x802369,(%esp)
  8011c0:	e8 a3 ef ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  8011c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ca:	eb 24                	jmp    8011f0 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8011d2:	85 d2                	test   %edx,%edx
  8011d4:	74 15                	je     8011eb <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011e4:	89 04 24             	mov    %eax,(%esp)
  8011e7:	ff d2                	call   *%edx
  8011e9:	eb 05                	jmp    8011f0 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8011f0:	83 c4 24             	add    $0x24,%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801203:	8b 45 08             	mov    0x8(%ebp),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	e8 e0 fb ff ff       	call   800dee <fd_lookup>
  80120e:	85 c0                	test   %eax,%eax
  801210:	78 0e                	js     801220 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801212:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801215:	8b 55 0c             	mov    0xc(%ebp),%edx
  801218:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80121b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	53                   	push   %ebx
  801226:	83 ec 24             	sub    $0x24,%esp
  801229:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801233:	89 1c 24             	mov    %ebx,(%esp)
  801236:	e8 b3 fb ff ff       	call   800dee <fd_lookup>
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 63                	js     8012a2 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801242:	89 44 24 04          	mov    %eax,0x4(%esp)
  801246:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801249:	8b 00                	mov    (%eax),%eax
  80124b:	89 04 24             	mov    %eax,(%esp)
  80124e:	e8 f1 fb ff ff       	call   800e44 <dev_lookup>
  801253:	85 c0                	test   %eax,%eax
  801255:	78 4b                	js     8012a2 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801257:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80125e:	75 25                	jne    801285 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801260:	a1 04 40 80 00       	mov    0x804004,%eax
  801265:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801267:	8b 40 48             	mov    0x48(%eax),%eax
  80126a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80126e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801272:	c7 04 24 2c 23 80 00 	movl   $0x80232c,(%esp)
  801279:	e8 ea ee ff ff       	call   800168 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801283:	eb 1d                	jmp    8012a2 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801285:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801288:	8b 52 18             	mov    0x18(%edx),%edx
  80128b:	85 d2                	test   %edx,%edx
  80128d:	74 0e                	je     80129d <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801296:	89 04 24             	mov    %eax,(%esp)
  801299:	ff d2                	call   *%edx
  80129b:	eb 05                	jmp    8012a2 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80129d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012a2:	83 c4 24             	add    $0x24,%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 24             	sub    $0x24,%esp
  8012af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	89 04 24             	mov    %eax,(%esp)
  8012bf:	e8 2a fb ff ff       	call   800dee <fd_lookup>
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 52                	js     80131a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	8b 00                	mov    (%eax),%eax
  8012d4:	89 04 24             	mov    %eax,(%esp)
  8012d7:	e8 68 fb ff ff       	call   800e44 <dev_lookup>
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 3a                	js     80131a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8012e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012e7:	74 2c                	je     801315 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012f3:	00 00 00 
	stat->st_isdir = 0;
  8012f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012fd:	00 00 00 
	stat->st_dev = dev;
  801300:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801306:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80130a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80130d:	89 14 24             	mov    %edx,(%esp)
  801310:	ff 50 14             	call   *0x14(%eax)
  801313:	eb 05                	jmp    80131a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801315:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80131a:	83 c4 24             	add    $0x24,%esp
  80131d:	5b                   	pop    %ebx
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801328:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80132f:	00 
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	89 04 24             	mov    %eax,(%esp)
  801336:	e8 88 02 00 00       	call   8015c3 <open>
  80133b:	89 c3                	mov    %eax,%ebx
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 1b                	js     80135c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801341:	8b 45 0c             	mov    0xc(%ebp),%eax
  801344:	89 44 24 04          	mov    %eax,0x4(%esp)
  801348:	89 1c 24             	mov    %ebx,(%esp)
  80134b:	e8 58 ff ff ff       	call   8012a8 <fstat>
  801350:	89 c6                	mov    %eax,%esi
	close(fd);
  801352:	89 1c 24             	mov    %ebx,(%esp)
  801355:	e8 ce fb ff ff       	call   800f28 <close>
	return r;
  80135a:	89 f3                	mov    %esi,%ebx
}
  80135c:	89 d8                	mov    %ebx,%eax
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    
  801365:	00 00                	add    %al,(%eax)
	...

00801368 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	56                   	push   %esi
  80136c:	53                   	push   %ebx
  80136d:	83 ec 10             	sub    $0x10,%esp
  801370:	89 c3                	mov    %eax,%ebx
  801372:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801374:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80137b:	75 11                	jne    80138e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80137d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801384:	e8 22 09 00 00       	call   801cab <ipc_find_env>
  801389:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80138e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801395:	00 
  801396:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80139d:	00 
  80139e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013a2:	a1 00 40 80 00       	mov    0x804000,%eax
  8013a7:	89 04 24             	mov    %eax,(%esp)
  8013aa:	e8 96 08 00 00       	call   801c45 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  8013af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013b6:	00 
  8013b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c2:	e8 11 08 00 00       	call   801bd8 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	5b                   	pop    %ebx
  8013cb:	5e                   	pop    %esi
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f1:	e8 72 ff ff ff       	call   801368 <fsipc>
}
  8013f6:	c9                   	leave  
  8013f7:	c3                   	ret    

008013f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801401:	8b 40 0c             	mov    0xc(%eax),%eax
  801404:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801409:	ba 00 00 00 00       	mov    $0x0,%edx
  80140e:	b8 06 00 00 00       	mov    $0x6,%eax
  801413:	e8 50 ff ff ff       	call   801368 <fsipc>
}
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	53                   	push   %ebx
  80141e:	83 ec 14             	sub    $0x14,%esp
  801421:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	8b 40 0c             	mov    0xc(%eax),%eax
  80142a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80142f:	ba 00 00 00 00       	mov    $0x0,%edx
  801434:	b8 05 00 00 00       	mov    $0x5,%eax
  801439:	e8 2a ff ff ff       	call   801368 <fsipc>
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 2b                	js     80146d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801442:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801449:	00 
  80144a:	89 1c 24             	mov    %ebx,(%esp)
  80144d:	e8 c1 f2 ff ff       	call   800713 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801452:	a1 80 50 80 00       	mov    0x805080,%eax
  801457:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80145d:	a1 84 50 80 00       	mov    0x805084,%eax
  801462:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801468:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146d:	83 c4 14             	add    $0x14,%esp
  801470:	5b                   	pop    %ebx
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	53                   	push   %ebx
  801477:	83 ec 14             	sub    $0x14,%esp
  80147a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80147d:	8b 45 08             	mov    0x8(%ebp),%eax
  801480:	8b 40 0c             	mov    0xc(%eax),%eax
  801483:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801488:	89 d8                	mov    %ebx,%eax
  80148a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801490:	76 05                	jbe    801497 <devfile_write+0x24>
  801492:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801497:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  80149c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a7:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8014ae:	e8 43 f4 ff ff       	call   8008f6 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  8014b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8014bd:	e8 a6 fe ff ff       	call   801368 <fsipc>
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 53                	js     801519 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  8014c6:	39 c3                	cmp    %eax,%ebx
  8014c8:	73 24                	jae    8014ee <devfile_write+0x7b>
  8014ca:	c7 44 24 0c 98 23 80 	movl   $0x802398,0xc(%esp)
  8014d1:	00 
  8014d2:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  8014d9:	00 
  8014da:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8014e1:	00 
  8014e2:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  8014e9:	e8 92 06 00 00       	call   801b80 <_panic>
	assert(r <= PGSIZE);
  8014ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f3:	7e 24                	jle    801519 <devfile_write+0xa6>
  8014f5:	c7 44 24 0c bf 23 80 	movl   $0x8023bf,0xc(%esp)
  8014fc:	00 
  8014fd:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  801504:	00 
  801505:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  80150c:	00 
  80150d:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  801514:	e8 67 06 00 00       	call   801b80 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801519:	83 c4 14             	add    $0x14,%esp
  80151c:	5b                   	pop    %ebx
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    

0080151f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	56                   	push   %esi
  801523:	53                   	push   %ebx
  801524:	83 ec 10             	sub    $0x10,%esp
  801527:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152a:	8b 45 08             	mov    0x8(%ebp),%eax
  80152d:	8b 40 0c             	mov    0xc(%eax),%eax
  801530:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801535:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 03 00 00 00       	mov    $0x3,%eax
  801545:	e8 1e fe ff ff       	call   801368 <fsipc>
  80154a:	89 c3                	mov    %eax,%ebx
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 6a                	js     8015ba <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801550:	39 c6                	cmp    %eax,%esi
  801552:	73 24                	jae    801578 <devfile_read+0x59>
  801554:	c7 44 24 0c 98 23 80 	movl   $0x802398,0xc(%esp)
  80155b:	00 
  80155c:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  801563:	00 
  801564:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80156b:	00 
  80156c:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  801573:	e8 08 06 00 00       	call   801b80 <_panic>
	assert(r <= PGSIZE);
  801578:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80157d:	7e 24                	jle    8015a3 <devfile_read+0x84>
  80157f:	c7 44 24 0c bf 23 80 	movl   $0x8023bf,0xc(%esp)
  801586:	00 
  801587:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  80158e:	00 
  80158f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801596:	00 
  801597:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  80159e:	e8 dd 05 00 00       	call   801b80 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015a7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015ae:	00 
  8015af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b2:	89 04 24             	mov    %eax,(%esp)
  8015b5:	e8 d2 f2 ff ff       	call   80088c <memmove>
	return r;
}
  8015ba:	89 d8                	mov    %ebx,%eax
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	5b                   	pop    %ebx
  8015c0:	5e                   	pop    %esi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 20             	sub    $0x20,%esp
  8015cb:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ce:	89 34 24             	mov    %esi,(%esp)
  8015d1:	e8 0a f1 ff ff       	call   8006e0 <strlen>
  8015d6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015db:	7f 60                	jg     80163d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e0:	89 04 24             	mov    %eax,(%esp)
  8015e3:	e8 b3 f7 ff ff       	call   800d9b <fd_alloc>
  8015e8:	89 c3                	mov    %eax,%ebx
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 54                	js     801642 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f2:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8015f9:	e8 15 f1 ff ff       	call   800713 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801601:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801606:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801609:	b8 01 00 00 00       	mov    $0x1,%eax
  80160e:	e8 55 fd ff ff       	call   801368 <fsipc>
  801613:	89 c3                	mov    %eax,%ebx
  801615:	85 c0                	test   %eax,%eax
  801617:	79 15                	jns    80162e <open+0x6b>
		fd_close(fd, 0);
  801619:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801620:	00 
  801621:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801624:	89 04 24             	mov    %eax,(%esp)
  801627:	e8 74 f8 ff ff       	call   800ea0 <fd_close>
		return r;
  80162c:	eb 14                	jmp    801642 <open+0x7f>
	}

	return fd2num(fd);
  80162e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801631:	89 04 24             	mov    %eax,(%esp)
  801634:	e8 37 f7 ff ff       	call   800d70 <fd2num>
  801639:	89 c3                	mov    %eax,%ebx
  80163b:	eb 05                	jmp    801642 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80163d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801642:	89 d8                	mov    %ebx,%eax
  801644:	83 c4 20             	add    $0x20,%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801651:	ba 00 00 00 00       	mov    $0x0,%edx
  801656:	b8 08 00 00 00       	mov    $0x8,%eax
  80165b:	e8 08 fd ff ff       	call   801368 <fsipc>
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    
	...

00801664 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	56                   	push   %esi
  801668:	53                   	push   %ebx
  801669:	83 ec 10             	sub    $0x10,%esp
  80166c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80166f:	8b 45 08             	mov    0x8(%ebp),%eax
  801672:	89 04 24             	mov    %eax,(%esp)
  801675:	e8 06 f7 ff ff       	call   800d80 <fd2data>
  80167a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80167c:	c7 44 24 04 cb 23 80 	movl   $0x8023cb,0x4(%esp)
  801683:	00 
  801684:	89 34 24             	mov    %esi,(%esp)
  801687:	e8 87 f0 ff ff       	call   800713 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80168c:	8b 43 04             	mov    0x4(%ebx),%eax
  80168f:	2b 03                	sub    (%ebx),%eax
  801691:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801697:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80169e:	00 00 00 
	stat->st_dev = &devpipe;
  8016a1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8016a8:	30 80 00 
	return 0;
}
  8016ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	5b                   	pop    %ebx
  8016b4:	5e                   	pop    %esi
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 14             	sub    $0x14,%esp
  8016be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016cc:	e8 db f4 ff ff       	call   800bac <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016d1:	89 1c 24             	mov    %ebx,(%esp)
  8016d4:	e8 a7 f6 ff ff       	call   800d80 <fd2data>
  8016d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e4:	e8 c3 f4 ff ff       	call   800bac <sys_page_unmap>
}
  8016e9:	83 c4 14             	add    $0x14,%esp
  8016ec:	5b                   	pop    %ebx
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	57                   	push   %edi
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 2c             	sub    $0x2c,%esp
  8016f8:	89 c7                	mov    %eax,%edi
  8016fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801702:	8b 00                	mov    (%eax),%eax
  801704:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801707:	89 3c 24             	mov    %edi,(%esp)
  80170a:	e8 e1 05 00 00       	call   801cf0 <pageref>
  80170f:	89 c6                	mov    %eax,%esi
  801711:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801714:	89 04 24             	mov    %eax,(%esp)
  801717:	e8 d4 05 00 00       	call   801cf0 <pageref>
  80171c:	39 c6                	cmp    %eax,%esi
  80171e:	0f 94 c0             	sete   %al
  801721:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801724:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80172a:	8b 12                	mov    (%edx),%edx
  80172c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80172f:	39 cb                	cmp    %ecx,%ebx
  801731:	75 08                	jne    80173b <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801733:	83 c4 2c             	add    $0x2c,%esp
  801736:	5b                   	pop    %ebx
  801737:	5e                   	pop    %esi
  801738:	5f                   	pop    %edi
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80173b:	83 f8 01             	cmp    $0x1,%eax
  80173e:	75 bd                	jne    8016fd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801740:	8b 42 58             	mov    0x58(%edx),%eax
  801743:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80174a:	00 
  80174b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80174f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801753:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  80175a:	e8 09 ea ff ff       	call   800168 <cprintf>
  80175f:	eb 9c                	jmp    8016fd <_pipeisclosed+0xe>

00801761 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	57                   	push   %edi
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
  801767:	83 ec 1c             	sub    $0x1c,%esp
  80176a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80176d:	89 34 24             	mov    %esi,(%esp)
  801770:	e8 0b f6 ff ff       	call   800d80 <fd2data>
  801775:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801777:	bf 00 00 00 00       	mov    $0x0,%edi
  80177c:	eb 3c                	jmp    8017ba <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80177e:	89 da                	mov    %ebx,%edx
  801780:	89 f0                	mov    %esi,%eax
  801782:	e8 68 ff ff ff       	call   8016ef <_pipeisclosed>
  801787:	85 c0                	test   %eax,%eax
  801789:	75 38                	jne    8017c3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80178b:	e8 56 f3 ff ff       	call   800ae6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801790:	8b 43 04             	mov    0x4(%ebx),%eax
  801793:	8b 13                	mov    (%ebx),%edx
  801795:	83 c2 20             	add    $0x20,%edx
  801798:	39 d0                	cmp    %edx,%eax
  80179a:	73 e2                	jae    80177e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80179c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8017a2:	89 c2                	mov    %eax,%edx
  8017a4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8017aa:	79 05                	jns    8017b1 <devpipe_write+0x50>
  8017ac:	4a                   	dec    %edx
  8017ad:	83 ca e0             	or     $0xffffffe0,%edx
  8017b0:	42                   	inc    %edx
  8017b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017b5:	40                   	inc    %eax
  8017b6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b9:	47                   	inc    %edi
  8017ba:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017bd:	75 d1                	jne    801790 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017bf:	89 f8                	mov    %edi,%eax
  8017c1:	eb 05                	jmp    8017c8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017c8:	83 c4 1c             	add    $0x1c,%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5e                   	pop    %esi
  8017cd:	5f                   	pop    %edi
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	57                   	push   %edi
  8017d4:	56                   	push   %esi
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 1c             	sub    $0x1c,%esp
  8017d9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017dc:	89 3c 24             	mov    %edi,(%esp)
  8017df:	e8 9c f5 ff ff       	call   800d80 <fd2data>
  8017e4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e6:	be 00 00 00 00       	mov    $0x0,%esi
  8017eb:	eb 3a                	jmp    801827 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017ed:	85 f6                	test   %esi,%esi
  8017ef:	74 04                	je     8017f5 <devpipe_read+0x25>
				return i;
  8017f1:	89 f0                	mov    %esi,%eax
  8017f3:	eb 40                	jmp    801835 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017f5:	89 da                	mov    %ebx,%edx
  8017f7:	89 f8                	mov    %edi,%eax
  8017f9:	e8 f1 fe ff ff       	call   8016ef <_pipeisclosed>
  8017fe:	85 c0                	test   %eax,%eax
  801800:	75 2e                	jne    801830 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801802:	e8 df f2 ff ff       	call   800ae6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801807:	8b 03                	mov    (%ebx),%eax
  801809:	3b 43 04             	cmp    0x4(%ebx),%eax
  80180c:	74 df                	je     8017ed <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80180e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801813:	79 05                	jns    80181a <devpipe_read+0x4a>
  801815:	48                   	dec    %eax
  801816:	83 c8 e0             	or     $0xffffffe0,%eax
  801819:	40                   	inc    %eax
  80181a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80181e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801821:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801824:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801826:	46                   	inc    %esi
  801827:	3b 75 10             	cmp    0x10(%ebp),%esi
  80182a:	75 db                	jne    801807 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80182c:	89 f0                	mov    %esi,%eax
  80182e:	eb 05                	jmp    801835 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801830:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801835:	83 c4 1c             	add    $0x1c,%esp
  801838:	5b                   	pop    %ebx
  801839:	5e                   	pop    %esi
  80183a:	5f                   	pop    %edi
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    

0080183d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	57                   	push   %edi
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
  801843:	83 ec 3c             	sub    $0x3c,%esp
  801846:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801849:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80184c:	89 04 24             	mov    %eax,(%esp)
  80184f:	e8 47 f5 ff ff       	call   800d9b <fd_alloc>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	85 c0                	test   %eax,%eax
  801858:	0f 88 45 01 00 00    	js     8019a3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801865:	00 
  801866:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801869:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801874:	e8 8c f2 ff ff       	call   800b05 <sys_page_alloc>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	85 c0                	test   %eax,%eax
  80187d:	0f 88 20 01 00 00    	js     8019a3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801883:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801886:	89 04 24             	mov    %eax,(%esp)
  801889:	e8 0d f5 ff ff       	call   800d9b <fd_alloc>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	85 c0                	test   %eax,%eax
  801892:	0f 88 f8 00 00 00    	js     801990 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801898:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80189f:	00 
  8018a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ae:	e8 52 f2 ff ff       	call   800b05 <sys_page_alloc>
  8018b3:	89 c3                	mov    %eax,%ebx
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	0f 88 d3 00 00 00    	js     801990 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018c0:	89 04 24             	mov    %eax,(%esp)
  8018c3:	e8 b8 f4 ff ff       	call   800d80 <fd2data>
  8018c8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018d1:	00 
  8018d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018dd:	e8 23 f2 ff ff       	call   800b05 <sys_page_alloc>
  8018e2:	89 c3                	mov    %eax,%ebx
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	0f 88 91 00 00 00    	js     80197d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ef:	89 04 24             	mov    %eax,(%esp)
  8018f2:	e8 89 f4 ff ff       	call   800d80 <fd2data>
  8018f7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8018fe:	00 
  8018ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801903:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80190a:	00 
  80190b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80190f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801916:	e8 3e f2 ff ff       	call   800b59 <sys_page_map>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 4c                	js     80196d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801921:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801927:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80192a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80192c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80192f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801936:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80193c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80193f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801941:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801944:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80194b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	e8 1a f4 ff ff       	call   800d70 <fd2num>
  801956:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801958:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80195b:	89 04 24             	mov    %eax,(%esp)
  80195e:	e8 0d f4 ff ff       	call   800d70 <fd2num>
  801963:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801966:	bb 00 00 00 00       	mov    $0x0,%ebx
  80196b:	eb 36                	jmp    8019a3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80196d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801971:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801978:	e8 2f f2 ff ff       	call   800bac <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80197d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801980:	89 44 24 04          	mov    %eax,0x4(%esp)
  801984:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80198b:	e8 1c f2 ff ff       	call   800bac <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801990:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801993:	89 44 24 04          	mov    %eax,0x4(%esp)
  801997:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199e:	e8 09 f2 ff ff       	call   800bac <sys_page_unmap>
    err:
	return r;
}
  8019a3:	89 d8                	mov    %ebx,%eax
  8019a5:	83 c4 3c             	add    $0x3c,%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5e                   	pop    %esi
  8019aa:	5f                   	pop    %edi
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	89 04 24             	mov    %eax,(%esp)
  8019c0:	e8 29 f4 ff ff       	call   800dee <fd_lookup>
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 15                	js     8019de <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cc:	89 04 24             	mov    %eax,(%esp)
  8019cf:	e8 ac f3 ff ff       	call   800d80 <fd2data>
	return _pipeisclosed(fd, p);
  8019d4:	89 c2                	mov    %eax,%edx
  8019d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d9:	e8 11 fd ff ff       	call   8016ef <_pipeisclosed>
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e8:	5d                   	pop    %ebp
  8019e9:	c3                   	ret    

008019ea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8019f0:	c7 44 24 04 ea 23 80 	movl   $0x8023ea,0x4(%esp)
  8019f7:	00 
  8019f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fb:	89 04 24             	mov    %eax,(%esp)
  8019fe:	e8 10 ed ff ff       	call   800713 <strcpy>
	return 0;
}
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	57                   	push   %edi
  801a0e:	56                   	push   %esi
  801a0f:	53                   	push   %ebx
  801a10:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a16:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a21:	eb 30                	jmp    801a53 <devcons_write+0x49>
		m = n - tot;
  801a23:	8b 75 10             	mov    0x10(%ebp),%esi
  801a26:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801a28:	83 fe 7f             	cmp    $0x7f,%esi
  801a2b:	76 05                	jbe    801a32 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801a2d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a32:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a36:	03 45 0c             	add    0xc(%ebp),%eax
  801a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3d:	89 3c 24             	mov    %edi,(%esp)
  801a40:	e8 47 ee ff ff       	call   80088c <memmove>
		sys_cputs(buf, m);
  801a45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a49:	89 3c 24             	mov    %edi,(%esp)
  801a4c:	e8 e7 ef ff ff       	call   800a38 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a51:	01 f3                	add    %esi,%ebx
  801a53:	89 d8                	mov    %ebx,%eax
  801a55:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a58:	72 c9                	jb     801a23 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a5a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5f                   	pop    %edi
  801a63:	5d                   	pop    %ebp
  801a64:	c3                   	ret    

00801a65 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a6f:	75 07                	jne    801a78 <devcons_read+0x13>
  801a71:	eb 25                	jmp    801a98 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a73:	e8 6e f0 ff ff       	call   800ae6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a78:	e8 d9 ef ff ff       	call   800a56 <sys_cgetc>
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	74 f2                	je     801a73 <devcons_read+0xe>
  801a81:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 1d                	js     801aa4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a87:	83 f8 04             	cmp    $0x4,%eax
  801a8a:	74 13                	je     801a9f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8f:	88 10                	mov    %dl,(%eax)
	return 1;
  801a91:	b8 01 00 00 00       	mov    $0x1,%eax
  801a96:	eb 0c                	jmp    801aa4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a98:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9d:	eb 05                	jmp    801aa4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a9f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ab2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ab9:	00 
  801aba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801abd:	89 04 24             	mov    %eax,(%esp)
  801ac0:	e8 73 ef ff ff       	call   800a38 <sys_cputs>
}
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <getchar>:

int
getchar(void)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801acd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ad4:	00 
  801ad5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae3:	e8 a4 f5 ff ff       	call   80108c <read>
	if (r < 0)
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	78 0f                	js     801afb <getchar+0x34>
		return r;
	if (r < 1)
  801aec:	85 c0                	test   %eax,%eax
  801aee:	7e 06                	jle    801af6 <getchar+0x2f>
		return -E_EOF;
	return c;
  801af0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801af4:	eb 05                	jmp    801afb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801af6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801afb:	c9                   	leave  
  801afc:	c3                   	ret    

00801afd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0d:	89 04 24             	mov    %eax,(%esp)
  801b10:	e8 d9 f2 ff ff       	call   800dee <fd_lookup>
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 11                	js     801b2a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b22:	39 10                	cmp    %edx,(%eax)
  801b24:	0f 94 c0             	sete   %al
  801b27:	0f b6 c0             	movzbl %al,%eax
}
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <opencons>:

int
opencons(void)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b35:	89 04 24             	mov    %eax,(%esp)
  801b38:	e8 5e f2 ff ff       	call   800d9b <fd_alloc>
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	78 3c                	js     801b7d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b41:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b48:	00 
  801b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b57:	e8 a9 ef ff ff       	call   800b05 <sys_page_alloc>
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 1d                	js     801b7d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b60:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b69:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b75:	89 04 24             	mov    %eax,(%esp)
  801b78:	e8 f3 f1 ff ff       	call   800d70 <fd2num>
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    
	...

00801b80 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b88:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b8b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b91:	e8 31 ef ff ff       	call   800ac7 <sys_getenvid>
  801b96:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b99:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b9d:	8b 55 08             	mov    0x8(%ebp),%edx
  801ba0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ba4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bac:	c7 04 24 f8 23 80 00 	movl   $0x8023f8,(%esp)
  801bb3:	e8 b0 e5 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bb8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bbc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bbf:	89 04 24             	mov    %eax,(%esp)
  801bc2:	e8 40 e5 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  801bc7:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  801bce:	e8 95 e5 ff ff       	call   800168 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801bd3:	cc                   	int3   
  801bd4:	eb fd                	jmp    801bd3 <_panic+0x53>
	...

00801bd8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 10             	sub    $0x10,%esp
  801be0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801be9:	85 c0                	test   %eax,%eax
  801beb:	75 05                	jne    801bf2 <ipc_recv+0x1a>
  801bed:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801bf2:	89 04 24             	mov    %eax,(%esp)
  801bf5:	e8 21 f1 ff ff       	call   800d1b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	79 16                	jns    801c14 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801bfe:	85 db                	test   %ebx,%ebx
  801c00:	74 06                	je     801c08 <ipc_recv+0x30>
  801c02:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801c08:	85 f6                	test   %esi,%esi
  801c0a:	74 32                	je     801c3e <ipc_recv+0x66>
  801c0c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c12:	eb 2a                	jmp    801c3e <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c14:	85 db                	test   %ebx,%ebx
  801c16:	74 0c                	je     801c24 <ipc_recv+0x4c>
  801c18:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1d:	8b 00                	mov    (%eax),%eax
  801c1f:	8b 40 74             	mov    0x74(%eax),%eax
  801c22:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c24:	85 f6                	test   %esi,%esi
  801c26:	74 0c                	je     801c34 <ipc_recv+0x5c>
  801c28:	a1 04 40 80 00       	mov    0x804004,%eax
  801c2d:	8b 00                	mov    (%eax),%eax
  801c2f:	8b 40 78             	mov    0x78(%eax),%eax
  801c32:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c34:	a1 04 40 80 00       	mov    0x804004,%eax
  801c39:	8b 00                	mov    (%eax),%eax
  801c3b:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	57                   	push   %edi
  801c49:	56                   	push   %esi
  801c4a:	53                   	push   %ebx
  801c4b:	83 ec 1c             	sub    $0x1c,%esp
  801c4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c54:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c57:	85 db                	test   %ebx,%ebx
  801c59:	75 05                	jne    801c60 <ipc_send+0x1b>
  801c5b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801c60:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	89 04 24             	mov    %eax,(%esp)
  801c72:	e8 81 f0 ff ff       	call   800cf8 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801c77:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c7a:	75 07                	jne    801c83 <ipc_send+0x3e>
  801c7c:	e8 65 ee ff ff       	call   800ae6 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801c81:	eb dd                	jmp    801c60 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801c83:	85 c0                	test   %eax,%eax
  801c85:	79 1c                	jns    801ca3 <ipc_send+0x5e>
  801c87:	c7 44 24 08 1c 24 80 	movl   $0x80241c,0x8(%esp)
  801c8e:	00 
  801c8f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c96:	00 
  801c97:	c7 04 24 2e 24 80 00 	movl   $0x80242e,(%esp)
  801c9e:	e8 dd fe ff ff       	call   801b80 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801ca3:	83 c4 1c             	add    $0x1c,%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5e                   	pop    %esi
  801ca8:	5f                   	pop    %edi
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	53                   	push   %ebx
  801caf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cb7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cbe:	89 c2                	mov    %eax,%edx
  801cc0:	c1 e2 07             	shl    $0x7,%edx
  801cc3:	29 ca                	sub    %ecx,%edx
  801cc5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ccb:	8b 52 50             	mov    0x50(%edx),%edx
  801cce:	39 da                	cmp    %ebx,%edx
  801cd0:	75 0f                	jne    801ce1 <ipc_find_env+0x36>
			return envs[i].env_id;
  801cd2:	c1 e0 07             	shl    $0x7,%eax
  801cd5:	29 c8                	sub    %ecx,%eax
  801cd7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cdc:	8b 40 40             	mov    0x40(%eax),%eax
  801cdf:	eb 0c                	jmp    801ced <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ce1:	40                   	inc    %eax
  801ce2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ce7:	75 ce                	jne    801cb7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ce9:	66 b8 00 00          	mov    $0x0,%ax
}
  801ced:	5b                   	pop    %ebx
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801cf6:	89 c2                	mov    %eax,%edx
  801cf8:	c1 ea 16             	shr    $0x16,%edx
  801cfb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d02:	f6 c2 01             	test   $0x1,%dl
  801d05:	74 1e                	je     801d25 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d07:	c1 e8 0c             	shr    $0xc,%eax
  801d0a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d11:	a8 01                	test   $0x1,%al
  801d13:	74 17                	je     801d2c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d15:	c1 e8 0c             	shr    $0xc,%eax
  801d18:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d1f:	ef 
  801d20:	0f b7 c0             	movzwl %ax,%eax
  801d23:	eb 0c                	jmp    801d31 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2a:	eb 05                	jmp    801d31 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    
	...

00801d34 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d34:	55                   	push   %ebp
  801d35:	57                   	push   %edi
  801d36:	56                   	push   %esi
  801d37:	83 ec 10             	sub    $0x10,%esp
  801d3a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d3e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d42:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d46:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d4a:	89 cd                	mov    %ecx,%ebp
  801d4c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d50:	85 c0                	test   %eax,%eax
  801d52:	75 2c                	jne    801d80 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d54:	39 f9                	cmp    %edi,%ecx
  801d56:	77 68                	ja     801dc0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d58:	85 c9                	test   %ecx,%ecx
  801d5a:	75 0b                	jne    801d67 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d61:	31 d2                	xor    %edx,%edx
  801d63:	f7 f1                	div    %ecx
  801d65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d67:	31 d2                	xor    %edx,%edx
  801d69:	89 f8                	mov    %edi,%eax
  801d6b:	f7 f1                	div    %ecx
  801d6d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d6f:	89 f0                	mov    %esi,%eax
  801d71:	f7 f1                	div    %ecx
  801d73:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d75:	89 f0                	mov    %esi,%eax
  801d77:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	5e                   	pop    %esi
  801d7d:	5f                   	pop    %edi
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d80:	39 f8                	cmp    %edi,%eax
  801d82:	77 2c                	ja     801db0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d84:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801d87:	83 f6 1f             	xor    $0x1f,%esi
  801d8a:	75 4c                	jne    801dd8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d8c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d8e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d93:	72 0a                	jb     801d9f <__udivdi3+0x6b>
  801d95:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d99:	0f 87 ad 00 00 00    	ja     801e4c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d9f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801da4:	89 f0                	mov    %esi,%eax
  801da6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    
  801daf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801db0:	31 ff                	xor    %edi,%edi
  801db2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801db4:	89 f0                	mov    %esi,%eax
  801db6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    
  801dbf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dc0:	89 fa                	mov    %edi,%edx
  801dc2:	89 f0                	mov    %esi,%eax
  801dc4:	f7 f1                	div    %ecx
  801dc6:	89 c6                	mov    %eax,%esi
  801dc8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dca:	89 f0                	mov    %esi,%eax
  801dcc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dd8:	89 f1                	mov    %esi,%ecx
  801dda:	d3 e0                	shl    %cl,%eax
  801ddc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801de0:	b8 20 00 00 00       	mov    $0x20,%eax
  801de5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801de7:	89 ea                	mov    %ebp,%edx
  801de9:	88 c1                	mov    %al,%cl
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801df1:	09 ca                	or     %ecx,%edx
  801df3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801df7:	89 f1                	mov    %esi,%ecx
  801df9:	d3 e5                	shl    %cl,%ebp
  801dfb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801dff:	89 fd                	mov    %edi,%ebp
  801e01:	88 c1                	mov    %al,%cl
  801e03:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801e05:	89 fa                	mov    %edi,%edx
  801e07:	89 f1                	mov    %esi,%ecx
  801e09:	d3 e2                	shl    %cl,%edx
  801e0b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e0f:	88 c1                	mov    %al,%cl
  801e11:	d3 ef                	shr    %cl,%edi
  801e13:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e15:	89 f8                	mov    %edi,%eax
  801e17:	89 ea                	mov    %ebp,%edx
  801e19:	f7 74 24 08          	divl   0x8(%esp)
  801e1d:	89 d1                	mov    %edx,%ecx
  801e1f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e21:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e25:	39 d1                	cmp    %edx,%ecx
  801e27:	72 17                	jb     801e40 <__udivdi3+0x10c>
  801e29:	74 09                	je     801e34 <__udivdi3+0x100>
  801e2b:	89 fe                	mov    %edi,%esi
  801e2d:	31 ff                	xor    %edi,%edi
  801e2f:	e9 41 ff ff ff       	jmp    801d75 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e34:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e38:	89 f1                	mov    %esi,%ecx
  801e3a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e3c:	39 c2                	cmp    %eax,%edx
  801e3e:	73 eb                	jae    801e2b <__udivdi3+0xf7>
		{
		  q0--;
  801e40:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e43:	31 ff                	xor    %edi,%edi
  801e45:	e9 2b ff ff ff       	jmp    801d75 <__udivdi3+0x41>
  801e4a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e4c:	31 f6                	xor    %esi,%esi
  801e4e:	e9 22 ff ff ff       	jmp    801d75 <__udivdi3+0x41>
	...

00801e54 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e54:	55                   	push   %ebp
  801e55:	57                   	push   %edi
  801e56:	56                   	push   %esi
  801e57:	83 ec 20             	sub    $0x20,%esp
  801e5a:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e5e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e62:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e66:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e6a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e6e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e72:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801e74:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e76:	85 ed                	test   %ebp,%ebp
  801e78:	75 16                	jne    801e90 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801e7a:	39 f1                	cmp    %esi,%ecx
  801e7c:	0f 86 a6 00 00 00    	jbe    801f28 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e82:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e84:	89 d0                	mov    %edx,%eax
  801e86:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e88:	83 c4 20             	add    $0x20,%esp
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    
  801e8f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e90:	39 f5                	cmp    %esi,%ebp
  801e92:	0f 87 ac 00 00 00    	ja     801f44 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e98:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801e9b:	83 f0 1f             	xor    $0x1f,%eax
  801e9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ea2:	0f 84 a8 00 00 00    	je     801f50 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ea8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eac:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801eae:	bf 20 00 00 00       	mov    $0x20,%edi
  801eb3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801eb7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ebb:	89 f9                	mov    %edi,%ecx
  801ebd:	d3 e8                	shr    %cl,%eax
  801ebf:	09 e8                	or     %ebp,%eax
  801ec1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801ec5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ec9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ecd:	d3 e0                	shl    %cl,%eax
  801ecf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ed3:	89 f2                	mov    %esi,%edx
  801ed5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ed7:	8b 44 24 14          	mov    0x14(%esp),%eax
  801edb:	d3 e0                	shl    %cl,%eax
  801edd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ee1:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ee5:	89 f9                	mov    %edi,%ecx
  801ee7:	d3 e8                	shr    %cl,%eax
  801ee9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801eeb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801eed:	89 f2                	mov    %esi,%edx
  801eef:	f7 74 24 18          	divl   0x18(%esp)
  801ef3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ef5:	f7 64 24 0c          	mull   0xc(%esp)
  801ef9:	89 c5                	mov    %eax,%ebp
  801efb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801efd:	39 d6                	cmp    %edx,%esi
  801eff:	72 67                	jb     801f68 <__umoddi3+0x114>
  801f01:	74 75                	je     801f78 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f03:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f07:	29 e8                	sub    %ebp,%eax
  801f09:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f0b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f0f:	d3 e8                	shr    %cl,%eax
  801f11:	89 f2                	mov    %esi,%edx
  801f13:	89 f9                	mov    %edi,%ecx
  801f15:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f17:	09 d0                	or     %edx,%eax
  801f19:	89 f2                	mov    %esi,%edx
  801f1b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f1f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f21:	83 c4 20             	add    $0x20,%esp
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f28:	85 c9                	test   %ecx,%ecx
  801f2a:	75 0b                	jne    801f37 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f31:	31 d2                	xor    %edx,%edx
  801f33:	f7 f1                	div    %ecx
  801f35:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f37:	89 f0                	mov    %esi,%eax
  801f39:	31 d2                	xor    %edx,%edx
  801f3b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f3d:	89 f8                	mov    %edi,%eax
  801f3f:	e9 3e ff ff ff       	jmp    801e82 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f44:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f46:	83 c4 20             	add    $0x20,%esp
  801f49:	5e                   	pop    %esi
  801f4a:	5f                   	pop    %edi
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    
  801f4d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f50:	39 f5                	cmp    %esi,%ebp
  801f52:	72 04                	jb     801f58 <__umoddi3+0x104>
  801f54:	39 f9                	cmp    %edi,%ecx
  801f56:	77 06                	ja     801f5e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f58:	89 f2                	mov    %esi,%edx
  801f5a:	29 cf                	sub    %ecx,%edi
  801f5c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f5e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f60:	83 c4 20             	add    $0x20,%esp
  801f63:	5e                   	pop    %esi
  801f64:	5f                   	pop    %edi
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    
  801f67:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f68:	89 d1                	mov    %edx,%ecx
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f70:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f74:	eb 8d                	jmp    801f03 <__umoddi3+0xaf>
  801f76:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f78:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f7c:	72 ea                	jb     801f68 <__umoddi3+0x114>
  801f7e:	89 f1                	mov    %esi,%ecx
  801f80:	eb 81                	jmp    801f03 <__umoddi3+0xaf>
