
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 a0 1f 80 00 	movl   $0x801fa0,(%esp)
  800041:	e8 32 01 00 00       	call   800178 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 40 80 00       	mov    0x804004,%eax
  80004b:	8b 00                	mov    (%eax),%eax
  80004d:	8b 40 48             	mov    0x48(%eax),%eax
  800050:	89 44 24 04          	mov    %eax,0x4(%esp)
  800054:	c7 04 24 ae 1f 80 00 	movl   $0x801fae,(%esp)
  80005b:	e8 18 01 00 00       	call   800178 <cprintf>
}
  800060:	c9                   	leave  
  800061:	c3                   	ret    
	...

00800064 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800064:	55                   	push   %ebp
  800065:	89 e5                	mov    %esp,%ebp
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 20             	sub    $0x20,%esp
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800072:	e8 60 0a 00 00       	call   800ad7 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800083:	c1 e0 07             	shl    $0x7,%eax
  800086:	29 d0                	sub    %edx,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800093:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800098:	85 f6                	test   %esi,%esi
  80009a:	7e 07                	jle    8000a3 <libmain+0x3f>
		binaryname = argv[0];
  80009c:	8b 03                	mov    (%ebx),%eax
  80009e:	a3 00 30 80 00       	mov    %eax,0x803000

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
	close_all();
  8000c2:	e8 a2 0e 00 00       	call   800f69 <close_all>
	sys_env_destroy(0);
  8000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ce:	e8 b2 09 00 00       	call   800a85 <sys_env_destroy>
}
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    
  8000d5:	00 00                	add    %al,(%eax)
	...

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
  8001ed:	e8 52 1b 00 00       	call   801d44 <__udivdi3>
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
  800240:	e8 1f 1c 00 00       	call   801e64 <__umoddi3>
  800245:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800249:	0f be 80 cf 1f 80 00 	movsbl 0x801fcf(%eax),%eax
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
  800364:	ff 24 95 20 21 80 00 	jmp    *0x802120(,%edx,4)
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
  8003ed:	83 f8 0f             	cmp    $0xf,%eax
  8003f0:	7f 0b                	jg     8003fd <vprintfmt+0x123>
  8003f2:	8b 04 85 80 22 80 00 	mov    0x802280(,%eax,4),%eax
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	75 23                	jne    800420 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8003fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800401:	c7 44 24 08 e7 1f 80 	movl   $0x801fe7,0x8(%esp)
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
  800424:	c7 44 24 08 b1 23 80 	movl   $0x8023b1,0x8(%esp)
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
  80045a:	be e0 1f 80 00       	mov    $0x801fe0,%esi
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
  800ab3:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800aba:	00 
  800abb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ac2:	00 
  800ac3:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800aca:	e8 c1 10 00 00       	call   801b90 <_panic>

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
  800b01:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800b45:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800b4c:	00 
  800b4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b54:	00 
  800b55:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800b5c:	e8 2f 10 00 00       	call   801b90 <_panic>

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
  800b98:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800b9f:	00 
  800ba0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba7:	00 
  800ba8:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800baf:	e8 dc 0f 00 00       	call   801b90 <_panic>

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
  800beb:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfa:	00 
  800bfb:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800c02:	e8 89 0f 00 00       	call   801b90 <_panic>

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
  800c3e:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800c45:	00 
  800c46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4d:	00 
  800c4e:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800c55:	e8 36 0f 00 00       	call   801b90 <_panic>

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

00800c62 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c83:	7e 28                	jle    800cad <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c89:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c90:	00 
  800c91:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800c98:	00 
  800c99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca0:	00 
  800ca1:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800ca8:	e8 e3 0e 00 00       	call   801b90 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cad:	83 c4 2c             	add    $0x2c,%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	89 df                	mov    %ebx,%edi
  800cd0:	89 de                	mov    %ebx,%esi
  800cd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 28                	jle    800d00 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800ceb:	00 
  800cec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf3:	00 
  800cf4:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800cfb:	e8 90 0e 00 00       	call   801b90 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d00:	83 c4 2c             	add    $0x2c,%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	be 00 00 00 00       	mov    $0x0,%esi
  800d13:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d39:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	89 cb                	mov    %ecx,%ebx
  800d43:	89 cf                	mov    %ecx,%edi
  800d45:	89 ce                	mov    %ecx,%esi
  800d47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 28                	jle    800d75 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d51:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d58:	00 
  800d59:	c7 44 24 08 df 22 80 	movl   $0x8022df,0x8(%esp)
  800d60:	00 
  800d61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d68:	00 
  800d69:	c7 04 24 fc 22 80 00 	movl   $0x8022fc,(%esp)
  800d70:	e8 1b 0e 00 00       	call   801b90 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d75:	83 c4 2c             	add    $0x2c,%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    
  800d7d:	00 00                	add    %al,(%eax)
	...

00800d80 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	05 00 00 00 30       	add    $0x30000000,%eax
  800d8b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	89 04 24             	mov    %eax,(%esp)
  800d9c:	e8 df ff ff ff       	call   800d80 <fd2num>
  800da1:	05 20 00 0d 00       	add    $0xd0020,%eax
  800da6:	c1 e0 0c             	shl    $0xc,%eax
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	53                   	push   %ebx
  800daf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800db2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800db7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800db9:	89 c2                	mov    %eax,%edx
  800dbb:	c1 ea 16             	shr    $0x16,%edx
  800dbe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc5:	f6 c2 01             	test   $0x1,%dl
  800dc8:	74 11                	je     800ddb <fd_alloc+0x30>
  800dca:	89 c2                	mov    %eax,%edx
  800dcc:	c1 ea 0c             	shr    $0xc,%edx
  800dcf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd6:	f6 c2 01             	test   $0x1,%dl
  800dd9:	75 09                	jne    800de4 <fd_alloc+0x39>
			*fd_store = fd;
  800ddb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
  800de2:	eb 17                	jmp    800dfb <fd_alloc+0x50>
  800de4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800de9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dee:	75 c7                	jne    800db7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800df0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800df6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e04:	83 f8 1f             	cmp    $0x1f,%eax
  800e07:	77 36                	ja     800e3f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e09:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e0e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	c1 ea 16             	shr    $0x16,%edx
  800e16:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1d:	f6 c2 01             	test   $0x1,%dl
  800e20:	74 24                	je     800e46 <fd_lookup+0x48>
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	c1 ea 0c             	shr    $0xc,%edx
  800e27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2e:	f6 c2 01             	test   $0x1,%dl
  800e31:	74 1a                	je     800e4d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e36:	89 02                	mov    %eax,(%edx)
	return 0;
  800e38:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3d:	eb 13                	jmp    800e52 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e44:	eb 0c                	jmp    800e52 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4b:	eb 05                	jmp    800e52 <fd_lookup+0x54>
  800e4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	53                   	push   %ebx
  800e58:	83 ec 14             	sub    $0x14,%esp
  800e5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800e61:	ba 00 00 00 00       	mov    $0x0,%edx
  800e66:	eb 0e                	jmp    800e76 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800e68:	39 08                	cmp    %ecx,(%eax)
  800e6a:	75 09                	jne    800e75 <dev_lookup+0x21>
			*dev = devtab[i];
  800e6c:	89 03                	mov    %eax,(%ebx)
			return 0;
  800e6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e73:	eb 35                	jmp    800eaa <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e75:	42                   	inc    %edx
  800e76:	8b 04 95 88 23 80 00 	mov    0x802388(,%edx,4),%eax
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	75 e7                	jne    800e68 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e81:	a1 04 40 80 00       	mov    0x804004,%eax
  800e86:	8b 00                	mov    (%eax),%eax
  800e88:	8b 40 48             	mov    0x48(%eax),%eax
  800e8b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e93:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  800e9a:	e8 d9 f2 ff ff       	call   800178 <cprintf>
	*dev = 0;
  800e9f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ea5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eaa:	83 c4 14             	add    $0x14,%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 30             	sub    $0x30,%esp
  800eb8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ebb:	8a 45 0c             	mov    0xc(%ebp),%al
  800ebe:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ec1:	89 34 24             	mov    %esi,(%esp)
  800ec4:	e8 b7 fe ff ff       	call   800d80 <fd2num>
  800ec9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ecc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed0:	89 04 24             	mov    %eax,(%esp)
  800ed3:	e8 26 ff ff ff       	call   800dfe <fd_lookup>
  800ed8:	89 c3                	mov    %eax,%ebx
  800eda:	85 c0                	test   %eax,%eax
  800edc:	78 05                	js     800ee3 <fd_close+0x33>
	    || fd != fd2)
  800ede:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ee1:	74 0d                	je     800ef0 <fd_close+0x40>
		return (must_exist ? r : 0);
  800ee3:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ee7:	75 46                	jne    800f2f <fd_close+0x7f>
  800ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eee:	eb 3f                	jmp    800f2f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ef0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef7:	8b 06                	mov    (%esi),%eax
  800ef9:	89 04 24             	mov    %eax,(%esp)
  800efc:	e8 53 ff ff ff       	call   800e54 <dev_lookup>
  800f01:	89 c3                	mov    %eax,%ebx
  800f03:	85 c0                	test   %eax,%eax
  800f05:	78 18                	js     800f1f <fd_close+0x6f>
		if (dev->dev_close)
  800f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f0a:	8b 40 10             	mov    0x10(%eax),%eax
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	74 09                	je     800f1a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f11:	89 34 24             	mov    %esi,(%esp)
  800f14:	ff d0                	call   *%eax
  800f16:	89 c3                	mov    %eax,%ebx
  800f18:	eb 05                	jmp    800f1f <fd_close+0x6f>
		else
			r = 0;
  800f1a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f2a:	e8 8d fc ff ff       	call   800bbc <sys_page_unmap>
	return r;
}
  800f2f:	89 d8                	mov    %ebx,%eax
  800f31:	83 c4 30             	add    $0x30,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f45:	8b 45 08             	mov    0x8(%ebp),%eax
  800f48:	89 04 24             	mov    %eax,(%esp)
  800f4b:	e8 ae fe ff ff       	call   800dfe <fd_lookup>
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 13                	js     800f67 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f54:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f5b:	00 
  800f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f5f:	89 04 24             	mov    %eax,(%esp)
  800f62:	e8 49 ff ff ff       	call   800eb0 <fd_close>
}
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <close_all>:

void
close_all(void)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f70:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f75:	89 1c 24             	mov    %ebx,(%esp)
  800f78:	e8 bb ff ff ff       	call   800f38 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f7d:	43                   	inc    %ebx
  800f7e:	83 fb 20             	cmp    $0x20,%ebx
  800f81:	75 f2                	jne    800f75 <close_all+0xc>
		close(i);
}
  800f83:	83 c4 14             	add    $0x14,%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	57                   	push   %edi
  800f8d:	56                   	push   %esi
  800f8e:	53                   	push   %ebx
  800f8f:	83 ec 4c             	sub    $0x4c,%esp
  800f92:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f95:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9f:	89 04 24             	mov    %eax,(%esp)
  800fa2:	e8 57 fe ff ff       	call   800dfe <fd_lookup>
  800fa7:	89 c3                	mov    %eax,%ebx
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	0f 88 e1 00 00 00    	js     801092 <dup+0x109>
		return r;
	close(newfdnum);
  800fb1:	89 3c 24             	mov    %edi,(%esp)
  800fb4:	e8 7f ff ff ff       	call   800f38 <close>

	newfd = INDEX2FD(newfdnum);
  800fb9:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fbf:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fc5:	89 04 24             	mov    %eax,(%esp)
  800fc8:	e8 c3 fd ff ff       	call   800d90 <fd2data>
  800fcd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fcf:	89 34 24             	mov    %esi,(%esp)
  800fd2:	e8 b9 fd ff ff       	call   800d90 <fd2data>
  800fd7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fda:	89 d8                	mov    %ebx,%eax
  800fdc:	c1 e8 16             	shr    $0x16,%eax
  800fdf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe6:	a8 01                	test   $0x1,%al
  800fe8:	74 46                	je     801030 <dup+0xa7>
  800fea:	89 d8                	mov    %ebx,%eax
  800fec:	c1 e8 0c             	shr    $0xc,%eax
  800fef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff6:	f6 c2 01             	test   $0x1,%dl
  800ff9:	74 35                	je     801030 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ffb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801002:	25 07 0e 00 00       	and    $0xe07,%eax
  801007:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80100e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801012:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801019:	00 
  80101a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80101e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801025:	e8 3f fb ff ff       	call   800b69 <sys_page_map>
  80102a:	89 c3                	mov    %eax,%ebx
  80102c:	85 c0                	test   %eax,%eax
  80102e:	78 3b                	js     80106b <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801030:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801033:	89 c2                	mov    %eax,%edx
  801035:	c1 ea 0c             	shr    $0xc,%edx
  801038:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80103f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801045:	89 54 24 10          	mov    %edx,0x10(%esp)
  801049:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80104d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801054:	00 
  801055:	89 44 24 04          	mov    %eax,0x4(%esp)
  801059:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801060:	e8 04 fb ff ff       	call   800b69 <sys_page_map>
  801065:	89 c3                	mov    %eax,%ebx
  801067:	85 c0                	test   %eax,%eax
  801069:	79 25                	jns    801090 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80106b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80106f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801076:	e8 41 fb ff ff       	call   800bbc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80107b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80107e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801082:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801089:	e8 2e fb ff ff       	call   800bbc <sys_page_unmap>
	return r;
  80108e:	eb 02                	jmp    801092 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801090:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801092:	89 d8                	mov    %ebx,%eax
  801094:	83 c4 4c             	add    $0x4c,%esp
  801097:	5b                   	pop    %ebx
  801098:	5e                   	pop    %esi
  801099:	5f                   	pop    %edi
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 24             	sub    $0x24,%esp
  8010a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ad:	89 1c 24             	mov    %ebx,(%esp)
  8010b0:	e8 49 fd ff ff       	call   800dfe <fd_lookup>
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	78 6f                	js     801128 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c3:	8b 00                	mov    (%eax),%eax
  8010c5:	89 04 24             	mov    %eax,(%esp)
  8010c8:	e8 87 fd ff ff       	call   800e54 <dev_lookup>
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	78 57                	js     801128 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d4:	8b 50 08             	mov    0x8(%eax),%edx
  8010d7:	83 e2 03             	and    $0x3,%edx
  8010da:	83 fa 01             	cmp    $0x1,%edx
  8010dd:	75 25                	jne    801104 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010df:	a1 04 40 80 00       	mov    0x804004,%eax
  8010e4:	8b 00                	mov    (%eax),%eax
  8010e6:	8b 40 48             	mov    0x48(%eax),%eax
  8010e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f1:	c7 04 24 4d 23 80 00 	movl   $0x80234d,(%esp)
  8010f8:	e8 7b f0 ff ff       	call   800178 <cprintf>
		return -E_INVAL;
  8010fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801102:	eb 24                	jmp    801128 <read+0x8c>
	}
	if (!dev->dev_read)
  801104:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801107:	8b 52 08             	mov    0x8(%edx),%edx
  80110a:	85 d2                	test   %edx,%edx
  80110c:	74 15                	je     801123 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80110e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801111:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801115:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801118:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80111c:	89 04 24             	mov    %eax,(%esp)
  80111f:	ff d2                	call   *%edx
  801121:	eb 05                	jmp    801128 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801123:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801128:	83 c4 24             	add    $0x24,%esp
  80112b:	5b                   	pop    %ebx
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 1c             	sub    $0x1c,%esp
  801137:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	eb 23                	jmp    801167 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801144:	89 f0                	mov    %esi,%eax
  801146:	29 d8                	sub    %ebx,%eax
  801148:	89 44 24 08          	mov    %eax,0x8(%esp)
  80114c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80114f:	01 d8                	add    %ebx,%eax
  801151:	89 44 24 04          	mov    %eax,0x4(%esp)
  801155:	89 3c 24             	mov    %edi,(%esp)
  801158:	e8 3f ff ff ff       	call   80109c <read>
		if (m < 0)
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 10                	js     801171 <readn+0x43>
			return m;
		if (m == 0)
  801161:	85 c0                	test   %eax,%eax
  801163:	74 0a                	je     80116f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801165:	01 c3                	add    %eax,%ebx
  801167:	39 f3                	cmp    %esi,%ebx
  801169:	72 d9                	jb     801144 <readn+0x16>
  80116b:	89 d8                	mov    %ebx,%eax
  80116d:	eb 02                	jmp    801171 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80116f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801171:	83 c4 1c             	add    $0x1c,%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5f                   	pop    %edi
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    

00801179 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	53                   	push   %ebx
  80117d:	83 ec 24             	sub    $0x24,%esp
  801180:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801183:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801186:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118a:	89 1c 24             	mov    %ebx,(%esp)
  80118d:	e8 6c fc ff ff       	call   800dfe <fd_lookup>
  801192:	85 c0                	test   %eax,%eax
  801194:	78 6a                	js     801200 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801196:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a0:	8b 00                	mov    (%eax),%eax
  8011a2:	89 04 24             	mov    %eax,(%esp)
  8011a5:	e8 aa fc ff ff       	call   800e54 <dev_lookup>
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 52                	js     801200 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b5:	75 25                	jne    8011dc <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011bc:	8b 00                	mov    (%eax),%eax
  8011be:	8b 40 48             	mov    0x48(%eax),%eax
  8011c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c9:	c7 04 24 69 23 80 00 	movl   $0x802369,(%esp)
  8011d0:	e8 a3 ef ff ff       	call   800178 <cprintf>
		return -E_INVAL;
  8011d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011da:	eb 24                	jmp    801200 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011df:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e2:	85 d2                	test   %edx,%edx
  8011e4:	74 15                	je     8011fb <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011f4:	89 04 24             	mov    %eax,(%esp)
  8011f7:	ff d2                	call   *%edx
  8011f9:	eb 05                	jmp    801200 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801200:	83 c4 24             	add    $0x24,%esp
  801203:	5b                   	pop    %ebx
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <seek>:

int
seek(int fdnum, off_t offset)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80120f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	89 04 24             	mov    %eax,(%esp)
  801219:	e8 e0 fb ff ff       	call   800dfe <fd_lookup>
  80121e:	85 c0                	test   %eax,%eax
  801220:	78 0e                	js     801230 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801222:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801225:	8b 55 0c             	mov    0xc(%ebp),%edx
  801228:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	53                   	push   %ebx
  801236:	83 ec 24             	sub    $0x24,%esp
  801239:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801243:	89 1c 24             	mov    %ebx,(%esp)
  801246:	e8 b3 fb ff ff       	call   800dfe <fd_lookup>
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 63                	js     8012b2 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801252:	89 44 24 04          	mov    %eax,0x4(%esp)
  801256:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801259:	8b 00                	mov    (%eax),%eax
  80125b:	89 04 24             	mov    %eax,(%esp)
  80125e:	e8 f1 fb ff ff       	call   800e54 <dev_lookup>
  801263:	85 c0                	test   %eax,%eax
  801265:	78 4b                	js     8012b2 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801267:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80126e:	75 25                	jne    801295 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801270:	a1 04 40 80 00       	mov    0x804004,%eax
  801275:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801277:	8b 40 48             	mov    0x48(%eax),%eax
  80127a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80127e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801282:	c7 04 24 2c 23 80 00 	movl   $0x80232c,(%esp)
  801289:	e8 ea ee ff ff       	call   800178 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801293:	eb 1d                	jmp    8012b2 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801295:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801298:	8b 52 18             	mov    0x18(%edx),%edx
  80129b:	85 d2                	test   %edx,%edx
  80129d:	74 0e                	je     8012ad <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80129f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012a6:	89 04 24             	mov    %eax,(%esp)
  8012a9:	ff d2                	call   *%edx
  8012ab:	eb 05                	jmp    8012b2 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012b2:	83 c4 24             	add    $0x24,%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 24             	sub    $0x24,%esp
  8012bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cc:	89 04 24             	mov    %eax,(%esp)
  8012cf:	e8 2a fb ff ff       	call   800dfe <fd_lookup>
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 52                	js     80132a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e2:	8b 00                	mov    (%eax),%eax
  8012e4:	89 04 24             	mov    %eax,(%esp)
  8012e7:	e8 68 fb ff ff       	call   800e54 <dev_lookup>
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 3a                	js     80132a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8012f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012f7:	74 2c                	je     801325 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012f9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012fc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801303:	00 00 00 
	stat->st_isdir = 0;
  801306:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80130d:	00 00 00 
	stat->st_dev = dev;
  801310:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801316:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80131a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80131d:	89 14 24             	mov    %edx,(%esp)
  801320:	ff 50 14             	call   *0x14(%eax)
  801323:	eb 05                	jmp    80132a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801325:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80132a:	83 c4 24             	add    $0x24,%esp
  80132d:	5b                   	pop    %ebx
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	56                   	push   %esi
  801334:	53                   	push   %ebx
  801335:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801338:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80133f:	00 
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	89 04 24             	mov    %eax,(%esp)
  801346:	e8 88 02 00 00       	call   8015d3 <open>
  80134b:	89 c3                	mov    %eax,%ebx
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 1b                	js     80136c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801351:	8b 45 0c             	mov    0xc(%ebp),%eax
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	89 1c 24             	mov    %ebx,(%esp)
  80135b:	e8 58 ff ff ff       	call   8012b8 <fstat>
  801360:	89 c6                	mov    %eax,%esi
	close(fd);
  801362:	89 1c 24             	mov    %ebx,(%esp)
  801365:	e8 ce fb ff ff       	call   800f38 <close>
	return r;
  80136a:	89 f3                	mov    %esi,%ebx
}
  80136c:	89 d8                	mov    %ebx,%eax
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    
  801375:	00 00                	add    %al,(%eax)
	...

00801378 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	56                   	push   %esi
  80137c:	53                   	push   %ebx
  80137d:	83 ec 10             	sub    $0x10,%esp
  801380:	89 c3                	mov    %eax,%ebx
  801382:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801384:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80138b:	75 11                	jne    80139e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80138d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801394:	e8 22 09 00 00       	call   801cbb <ipc_find_env>
  801399:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013a5:	00 
  8013a6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013ad:	00 
  8013ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013b2:	a1 00 40 80 00       	mov    0x804000,%eax
  8013b7:	89 04 24             	mov    %eax,(%esp)
  8013ba:	e8 96 08 00 00       	call   801c55 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  8013bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013c6:	00 
  8013c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013d2:	e8 11 08 00 00       	call   801be8 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801401:	e8 72 ff ff ff       	call   801378 <fsipc>
}
  801406:	c9                   	leave  
  801407:	c3                   	ret    

00801408 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
  801411:	8b 40 0c             	mov    0xc(%eax),%eax
  801414:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801419:	ba 00 00 00 00       	mov    $0x0,%edx
  80141e:	b8 06 00 00 00       	mov    $0x6,%eax
  801423:	e8 50 ff ff ff       	call   801378 <fsipc>
}
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	53                   	push   %ebx
  80142e:	83 ec 14             	sub    $0x14,%esp
  801431:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801434:	8b 45 08             	mov    0x8(%ebp),%eax
  801437:	8b 40 0c             	mov    0xc(%eax),%eax
  80143a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80143f:	ba 00 00 00 00       	mov    $0x0,%edx
  801444:	b8 05 00 00 00       	mov    $0x5,%eax
  801449:	e8 2a ff ff ff       	call   801378 <fsipc>
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 2b                	js     80147d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801452:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801459:	00 
  80145a:	89 1c 24             	mov    %ebx,(%esp)
  80145d:	e8 c1 f2 ff ff       	call   800723 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801462:	a1 80 50 80 00       	mov    0x805080,%eax
  801467:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80146d:	a1 84 50 80 00       	mov    0x805084,%eax
  801472:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801478:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147d:	83 c4 14             	add    $0x14,%esp
  801480:	5b                   	pop    %ebx
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	53                   	push   %ebx
  801487:	83 ec 14             	sub    $0x14,%esp
  80148a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	8b 40 0c             	mov    0xc(%eax),%eax
  801493:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8014a0:	76 05                	jbe    8014a7 <devfile_write+0x24>
  8014a2:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8014a7:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  8014ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b7:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8014be:	e8 43 f4 ff ff       	call   800906 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  8014c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c8:	b8 04 00 00 00       	mov    $0x4,%eax
  8014cd:	e8 a6 fe ff ff       	call   801378 <fsipc>
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 53                	js     801529 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  8014d6:	39 c3                	cmp    %eax,%ebx
  8014d8:	73 24                	jae    8014fe <devfile_write+0x7b>
  8014da:	c7 44 24 0c 98 23 80 	movl   $0x802398,0xc(%esp)
  8014e1:	00 
  8014e2:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  8014e9:	00 
  8014ea:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8014f1:	00 
  8014f2:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  8014f9:	e8 92 06 00 00       	call   801b90 <_panic>
	assert(r <= PGSIZE);
  8014fe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801503:	7e 24                	jle    801529 <devfile_write+0xa6>
  801505:	c7 44 24 0c bf 23 80 	movl   $0x8023bf,0xc(%esp)
  80150c:	00 
  80150d:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  801514:	00 
  801515:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  80151c:	00 
  80151d:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  801524:	e8 67 06 00 00       	call   801b90 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801529:	83 c4 14             	add    $0x14,%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5d                   	pop    %ebp
  80152e:	c3                   	ret    

0080152f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	56                   	push   %esi
  801533:	53                   	push   %ebx
  801534:	83 ec 10             	sub    $0x10,%esp
  801537:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	8b 40 0c             	mov    0xc(%eax),%eax
  801540:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801545:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80154b:	ba 00 00 00 00       	mov    $0x0,%edx
  801550:	b8 03 00 00 00       	mov    $0x3,%eax
  801555:	e8 1e fe ff ff       	call   801378 <fsipc>
  80155a:	89 c3                	mov    %eax,%ebx
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 6a                	js     8015ca <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801560:	39 c6                	cmp    %eax,%esi
  801562:	73 24                	jae    801588 <devfile_read+0x59>
  801564:	c7 44 24 0c 98 23 80 	movl   $0x802398,0xc(%esp)
  80156b:	00 
  80156c:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  801573:	00 
  801574:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80157b:	00 
  80157c:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  801583:	e8 08 06 00 00       	call   801b90 <_panic>
	assert(r <= PGSIZE);
  801588:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80158d:	7e 24                	jle    8015b3 <devfile_read+0x84>
  80158f:	c7 44 24 0c bf 23 80 	movl   $0x8023bf,0xc(%esp)
  801596:	00 
  801597:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  80159e:	00 
  80159f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8015a6:	00 
  8015a7:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  8015ae:	e8 dd 05 00 00       	call   801b90 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015be:	00 
  8015bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c2:	89 04 24             	mov    %eax,(%esp)
  8015c5:	e8 d2 f2 ff ff       	call   80089c <memmove>
	return r;
}
  8015ca:	89 d8                	mov    %ebx,%eax
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	5b                   	pop    %ebx
  8015d0:	5e                   	pop    %esi
  8015d1:	5d                   	pop    %ebp
  8015d2:	c3                   	ret    

008015d3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	56                   	push   %esi
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 20             	sub    $0x20,%esp
  8015db:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015de:	89 34 24             	mov    %esi,(%esp)
  8015e1:	e8 0a f1 ff ff       	call   8006f0 <strlen>
  8015e6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015eb:	7f 60                	jg     80164d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f0:	89 04 24             	mov    %eax,(%esp)
  8015f3:	e8 b3 f7 ff ff       	call   800dab <fd_alloc>
  8015f8:	89 c3                	mov    %eax,%ebx
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 54                	js     801652 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801602:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801609:	e8 15 f1 ff ff       	call   800723 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801611:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801616:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801619:	b8 01 00 00 00       	mov    $0x1,%eax
  80161e:	e8 55 fd ff ff       	call   801378 <fsipc>
  801623:	89 c3                	mov    %eax,%ebx
  801625:	85 c0                	test   %eax,%eax
  801627:	79 15                	jns    80163e <open+0x6b>
		fd_close(fd, 0);
  801629:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801630:	00 
  801631:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801634:	89 04 24             	mov    %eax,(%esp)
  801637:	e8 74 f8 ff ff       	call   800eb0 <fd_close>
		return r;
  80163c:	eb 14                	jmp    801652 <open+0x7f>
	}

	return fd2num(fd);
  80163e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801641:	89 04 24             	mov    %eax,(%esp)
  801644:	e8 37 f7 ff ff       	call   800d80 <fd2num>
  801649:	89 c3                	mov    %eax,%ebx
  80164b:	eb 05                	jmp    801652 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801652:	89 d8                	mov    %ebx,%eax
  801654:	83 c4 20             	add    $0x20,%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	5d                   	pop    %ebp
  80165a:	c3                   	ret    

0080165b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801661:	ba 00 00 00 00       	mov    $0x0,%edx
  801666:	b8 08 00 00 00       	mov    $0x8,%eax
  80166b:	e8 08 fd ff ff       	call   801378 <fsipc>
}
  801670:	c9                   	leave  
  801671:	c3                   	ret    
	...

00801674 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	83 ec 10             	sub    $0x10,%esp
  80167c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	89 04 24             	mov    %eax,(%esp)
  801685:	e8 06 f7 ff ff       	call   800d90 <fd2data>
  80168a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80168c:	c7 44 24 04 cb 23 80 	movl   $0x8023cb,0x4(%esp)
  801693:	00 
  801694:	89 34 24             	mov    %esi,(%esp)
  801697:	e8 87 f0 ff ff       	call   800723 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80169c:	8b 43 04             	mov    0x4(%ebx),%eax
  80169f:	2b 03                	sub    (%ebx),%eax
  8016a1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8016a7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8016ae:	00 00 00 
	stat->st_dev = &devpipe;
  8016b1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8016b8:	30 80 00 
	return 0;
}
  8016bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 14             	sub    $0x14,%esp
  8016ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016dc:	e8 db f4 ff ff       	call   800bbc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016e1:	89 1c 24             	mov    %ebx,(%esp)
  8016e4:	e8 a7 f6 ff ff       	call   800d90 <fd2data>
  8016e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f4:	e8 c3 f4 ff ff       	call   800bbc <sys_page_unmap>
}
  8016f9:	83 c4 14             	add    $0x14,%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	57                   	push   %edi
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
  801705:	83 ec 2c             	sub    $0x2c,%esp
  801708:	89 c7                	mov    %eax,%edi
  80170a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80170d:	a1 04 40 80 00       	mov    0x804004,%eax
  801712:	8b 00                	mov    (%eax),%eax
  801714:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801717:	89 3c 24             	mov    %edi,(%esp)
  80171a:	e8 e1 05 00 00       	call   801d00 <pageref>
  80171f:	89 c6                	mov    %eax,%esi
  801721:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801724:	89 04 24             	mov    %eax,(%esp)
  801727:	e8 d4 05 00 00       	call   801d00 <pageref>
  80172c:	39 c6                	cmp    %eax,%esi
  80172e:	0f 94 c0             	sete   %al
  801731:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801734:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80173a:	8b 12                	mov    (%edx),%edx
  80173c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80173f:	39 cb                	cmp    %ecx,%ebx
  801741:	75 08                	jne    80174b <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801743:	83 c4 2c             	add    $0x2c,%esp
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5f                   	pop    %edi
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80174b:	83 f8 01             	cmp    $0x1,%eax
  80174e:	75 bd                	jne    80170d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801750:	8b 42 58             	mov    0x58(%edx),%eax
  801753:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80175a:	00 
  80175b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801763:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  80176a:	e8 09 ea ff ff       	call   800178 <cprintf>
  80176f:	eb 9c                	jmp    80170d <_pipeisclosed+0xe>

00801771 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	57                   	push   %edi
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	83 ec 1c             	sub    $0x1c,%esp
  80177a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80177d:	89 34 24             	mov    %esi,(%esp)
  801780:	e8 0b f6 ff ff       	call   800d90 <fd2data>
  801785:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801787:	bf 00 00 00 00       	mov    $0x0,%edi
  80178c:	eb 3c                	jmp    8017ca <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80178e:	89 da                	mov    %ebx,%edx
  801790:	89 f0                	mov    %esi,%eax
  801792:	e8 68 ff ff ff       	call   8016ff <_pipeisclosed>
  801797:	85 c0                	test   %eax,%eax
  801799:	75 38                	jne    8017d3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80179b:	e8 56 f3 ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8017a3:	8b 13                	mov    (%ebx),%edx
  8017a5:	83 c2 20             	add    $0x20,%edx
  8017a8:	39 d0                	cmp    %edx,%eax
  8017aa:	73 e2                	jae    80178e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017af:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8017b2:	89 c2                	mov    %eax,%edx
  8017b4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8017ba:	79 05                	jns    8017c1 <devpipe_write+0x50>
  8017bc:	4a                   	dec    %edx
  8017bd:	83 ca e0             	or     $0xffffffe0,%edx
  8017c0:	42                   	inc    %edx
  8017c1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017c5:	40                   	inc    %eax
  8017c6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c9:	47                   	inc    %edi
  8017ca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017cd:	75 d1                	jne    8017a0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017cf:	89 f8                	mov    %edi,%eax
  8017d1:	eb 05                	jmp    8017d8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017d8:	83 c4 1c             	add    $0x1c,%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5e                   	pop    %esi
  8017dd:	5f                   	pop    %edi
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	57                   	push   %edi
  8017e4:	56                   	push   %esi
  8017e5:	53                   	push   %ebx
  8017e6:	83 ec 1c             	sub    $0x1c,%esp
  8017e9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017ec:	89 3c 24             	mov    %edi,(%esp)
  8017ef:	e8 9c f5 ff ff       	call   800d90 <fd2data>
  8017f4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f6:	be 00 00 00 00       	mov    $0x0,%esi
  8017fb:	eb 3a                	jmp    801837 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017fd:	85 f6                	test   %esi,%esi
  8017ff:	74 04                	je     801805 <devpipe_read+0x25>
				return i;
  801801:	89 f0                	mov    %esi,%eax
  801803:	eb 40                	jmp    801845 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801805:	89 da                	mov    %ebx,%edx
  801807:	89 f8                	mov    %edi,%eax
  801809:	e8 f1 fe ff ff       	call   8016ff <_pipeisclosed>
  80180e:	85 c0                	test   %eax,%eax
  801810:	75 2e                	jne    801840 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801812:	e8 df f2 ff ff       	call   800af6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801817:	8b 03                	mov    (%ebx),%eax
  801819:	3b 43 04             	cmp    0x4(%ebx),%eax
  80181c:	74 df                	je     8017fd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80181e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801823:	79 05                	jns    80182a <devpipe_read+0x4a>
  801825:	48                   	dec    %eax
  801826:	83 c8 e0             	or     $0xffffffe0,%eax
  801829:	40                   	inc    %eax
  80182a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80182e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801831:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801834:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801836:	46                   	inc    %esi
  801837:	3b 75 10             	cmp    0x10(%ebp),%esi
  80183a:	75 db                	jne    801817 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80183c:	89 f0                	mov    %esi,%eax
  80183e:	eb 05                	jmp    801845 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801840:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801845:	83 c4 1c             	add    $0x1c,%esp
  801848:	5b                   	pop    %ebx
  801849:	5e                   	pop    %esi
  80184a:	5f                   	pop    %edi
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    

0080184d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	57                   	push   %edi
  801851:	56                   	push   %esi
  801852:	53                   	push   %ebx
  801853:	83 ec 3c             	sub    $0x3c,%esp
  801856:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801859:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80185c:	89 04 24             	mov    %eax,(%esp)
  80185f:	e8 47 f5 ff ff       	call   800dab <fd_alloc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	85 c0                	test   %eax,%eax
  801868:	0f 88 45 01 00 00    	js     8019b3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80186e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801875:	00 
  801876:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801879:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801884:	e8 8c f2 ff ff       	call   800b15 <sys_page_alloc>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	85 c0                	test   %eax,%eax
  80188d:	0f 88 20 01 00 00    	js     8019b3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801893:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801896:	89 04 24             	mov    %eax,(%esp)
  801899:	e8 0d f5 ff ff       	call   800dab <fd_alloc>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	0f 88 f8 00 00 00    	js     8019a0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018af:	00 
  8018b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018be:	e8 52 f2 ff ff       	call   800b15 <sys_page_alloc>
  8018c3:	89 c3                	mov    %eax,%ebx
  8018c5:	85 c0                	test   %eax,%eax
  8018c7:	0f 88 d3 00 00 00    	js     8019a0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018d0:	89 04 24             	mov    %eax,(%esp)
  8018d3:	e8 b8 f4 ff ff       	call   800d90 <fd2data>
  8018d8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018da:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018e1:	00 
  8018e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ed:	e8 23 f2 ff ff       	call   800b15 <sys_page_alloc>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	0f 88 91 00 00 00    	js     80198d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ff:	89 04 24             	mov    %eax,(%esp)
  801902:	e8 89 f4 ff ff       	call   800d90 <fd2data>
  801907:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80190e:	00 
  80190f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801913:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80191a:	00 
  80191b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80191f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801926:	e8 3e f2 ff ff       	call   800b69 <sys_page_map>
  80192b:	89 c3                	mov    %eax,%ebx
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 4c                	js     80197d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801931:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801937:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80193c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80193f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801946:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80194f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801951:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801954:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80195b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80195e:	89 04 24             	mov    %eax,(%esp)
  801961:	e8 1a f4 ff ff       	call   800d80 <fd2num>
  801966:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801968:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80196b:	89 04 24             	mov    %eax,(%esp)
  80196e:	e8 0d f4 ff ff       	call   800d80 <fd2num>
  801973:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801976:	bb 00 00 00 00       	mov    $0x0,%ebx
  80197b:	eb 36                	jmp    8019b3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80197d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801981:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801988:	e8 2f f2 ff ff       	call   800bbc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80198d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801990:	89 44 24 04          	mov    %eax,0x4(%esp)
  801994:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199b:	e8 1c f2 ff ff       	call   800bbc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8019a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ae:	e8 09 f2 ff ff       	call   800bbc <sys_page_unmap>
    err:
	return r;
}
  8019b3:	89 d8                	mov    %ebx,%eax
  8019b5:	83 c4 3c             	add    $0x3c,%esp
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5f                   	pop    %edi
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    

008019bd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cd:	89 04 24             	mov    %eax,(%esp)
  8019d0:	e8 29 f4 ff ff       	call   800dfe <fd_lookup>
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 15                	js     8019ee <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019dc:	89 04 24             	mov    %eax,(%esp)
  8019df:	e8 ac f3 ff ff       	call   800d90 <fd2data>
	return _pipeisclosed(fd, p);
  8019e4:	89 c2                	mov    %eax,%edx
  8019e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e9:	e8 11 fd ff ff       	call   8016ff <_pipeisclosed>
}
  8019ee:	c9                   	leave  
  8019ef:	c3                   	ret    

008019f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801a00:	c7 44 24 04 ea 23 80 	movl   $0x8023ea,0x4(%esp)
  801a07:	00 
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	89 04 24             	mov    %eax,(%esp)
  801a0e:	e8 10 ed ff ff       	call   800723 <strcpy>
	return 0;
}
  801a13:	b8 00 00 00 00       	mov    $0x0,%eax
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	57                   	push   %edi
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
  801a20:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a26:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a31:	eb 30                	jmp    801a63 <devcons_write+0x49>
		m = n - tot;
  801a33:	8b 75 10             	mov    0x10(%ebp),%esi
  801a36:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801a38:	83 fe 7f             	cmp    $0x7f,%esi
  801a3b:	76 05                	jbe    801a42 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801a3d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a42:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a46:	03 45 0c             	add    0xc(%ebp),%eax
  801a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4d:	89 3c 24             	mov    %edi,(%esp)
  801a50:	e8 47 ee ff ff       	call   80089c <memmove>
		sys_cputs(buf, m);
  801a55:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a59:	89 3c 24             	mov    %edi,(%esp)
  801a5c:	e8 e7 ef ff ff       	call   800a48 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a61:	01 f3                	add    %esi,%ebx
  801a63:	89 d8                	mov    %ebx,%eax
  801a65:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a68:	72 c9                	jb     801a33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a6a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801a70:	5b                   	pop    %ebx
  801a71:	5e                   	pop    %esi
  801a72:	5f                   	pop    %edi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a7f:	75 07                	jne    801a88 <devcons_read+0x13>
  801a81:	eb 25                	jmp    801aa8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a83:	e8 6e f0 ff ff       	call   800af6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a88:	e8 d9 ef ff ff       	call   800a66 <sys_cgetc>
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	74 f2                	je     801a83 <devcons_read+0xe>
  801a91:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 1d                	js     801ab4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a97:	83 f8 04             	cmp    $0x4,%eax
  801a9a:	74 13                	je     801aaf <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9f:	88 10                	mov    %dl,(%eax)
	return 1;
  801aa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa6:	eb 0c                	jmp    801ab4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  801aad:	eb 05                	jmp    801ab4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ac2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ac9:	00 
  801aca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801acd:	89 04 24             	mov    %eax,(%esp)
  801ad0:	e8 73 ef ff ff       	call   800a48 <sys_cputs>
}
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <getchar>:

int
getchar(void)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801add:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ae4:	00 
  801ae5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af3:	e8 a4 f5 ff ff       	call   80109c <read>
	if (r < 0)
  801af8:	85 c0                	test   %eax,%eax
  801afa:	78 0f                	js     801b0b <getchar+0x34>
		return r;
	if (r < 1)
  801afc:	85 c0                	test   %eax,%eax
  801afe:	7e 06                	jle    801b06 <getchar+0x2f>
		return -E_EOF;
	return c;
  801b00:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b04:	eb 05                	jmp    801b0b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b06:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    

00801b0d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1d:	89 04 24             	mov    %eax,(%esp)
  801b20:	e8 d9 f2 ff ff       	call   800dfe <fd_lookup>
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 11                	js     801b3a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b32:	39 10                	cmp    %edx,(%eax)
  801b34:	0f 94 c0             	sete   %al
  801b37:	0f b6 c0             	movzbl %al,%eax
}
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <opencons>:

int
opencons(void)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b45:	89 04 24             	mov    %eax,(%esp)
  801b48:	e8 5e f2 ff ff       	call   800dab <fd_alloc>
  801b4d:	85 c0                	test   %eax,%eax
  801b4f:	78 3c                	js     801b8d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b51:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b58:	00 
  801b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b67:	e8 a9 ef ff ff       	call   800b15 <sys_page_alloc>
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	78 1d                	js     801b8d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b70:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b79:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b85:	89 04 24             	mov    %eax,(%esp)
  801b88:	e8 f3 f1 ff ff       	call   800d80 <fd2num>
}
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    
	...

00801b90 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	56                   	push   %esi
  801b94:	53                   	push   %ebx
  801b95:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b98:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b9b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801ba1:	e8 31 ef ff ff       	call   800ad7 <sys_getenvid>
  801ba6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ba9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801bad:	8b 55 08             	mov    0x8(%ebp),%edx
  801bb0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801bb4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbc:	c7 04 24 f8 23 80 00 	movl   $0x8023f8,(%esp)
  801bc3:	e8 b0 e5 ff ff       	call   800178 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801bc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bcf:	89 04 24             	mov    %eax,(%esp)
  801bd2:	e8 40 e5 ff ff       	call   800117 <vcprintf>
	cprintf("\n");
  801bd7:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  801bde:	e8 95 e5 ff ff       	call   800178 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801be3:	cc                   	int3   
  801be4:	eb fd                	jmp    801be3 <_panic+0x53>
	...

00801be8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	83 ec 10             	sub    $0x10,%esp
  801bf0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	75 05                	jne    801c02 <ipc_recv+0x1a>
  801bfd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801c02:	89 04 24             	mov    %eax,(%esp)
  801c05:	e8 21 f1 ff ff       	call   800d2b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	79 16                	jns    801c24 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801c0e:	85 db                	test   %ebx,%ebx
  801c10:	74 06                	je     801c18 <ipc_recv+0x30>
  801c12:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801c18:	85 f6                	test   %esi,%esi
  801c1a:	74 32                	je     801c4e <ipc_recv+0x66>
  801c1c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c22:	eb 2a                	jmp    801c4e <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c24:	85 db                	test   %ebx,%ebx
  801c26:	74 0c                	je     801c34 <ipc_recv+0x4c>
  801c28:	a1 04 40 80 00       	mov    0x804004,%eax
  801c2d:	8b 00                	mov    (%eax),%eax
  801c2f:	8b 40 74             	mov    0x74(%eax),%eax
  801c32:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c34:	85 f6                	test   %esi,%esi
  801c36:	74 0c                	je     801c44 <ipc_recv+0x5c>
  801c38:	a1 04 40 80 00       	mov    0x804004,%eax
  801c3d:	8b 00                	mov    (%eax),%eax
  801c3f:	8b 40 78             	mov    0x78(%eax),%eax
  801c42:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c44:	a1 04 40 80 00       	mov    0x804004,%eax
  801c49:	8b 00                	mov    (%eax),%eax
  801c4b:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	57                   	push   %edi
  801c59:	56                   	push   %esi
  801c5a:	53                   	push   %ebx
  801c5b:	83 ec 1c             	sub    $0x1c,%esp
  801c5e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c64:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c67:	85 db                	test   %ebx,%ebx
  801c69:	75 05                	jne    801c70 <ipc_send+0x1b>
  801c6b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801c70:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c74:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7f:	89 04 24             	mov    %eax,(%esp)
  801c82:	e8 81 f0 ff ff       	call   800d08 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801c87:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c8a:	75 07                	jne    801c93 <ipc_send+0x3e>
  801c8c:	e8 65 ee ff ff       	call   800af6 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801c91:	eb dd                	jmp    801c70 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801c93:	85 c0                	test   %eax,%eax
  801c95:	79 1c                	jns    801cb3 <ipc_send+0x5e>
  801c97:	c7 44 24 08 1c 24 80 	movl   $0x80241c,0x8(%esp)
  801c9e:	00 
  801c9f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801ca6:	00 
  801ca7:	c7 04 24 2e 24 80 00 	movl   $0x80242e,(%esp)
  801cae:	e8 dd fe ff ff       	call   801b90 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801cb3:	83 c4 1c             	add    $0x1c,%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5f                   	pop    %edi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	53                   	push   %ebx
  801cbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801cc2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cc7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cce:	89 c2                	mov    %eax,%edx
  801cd0:	c1 e2 07             	shl    $0x7,%edx
  801cd3:	29 ca                	sub    %ecx,%edx
  801cd5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cdb:	8b 52 50             	mov    0x50(%edx),%edx
  801cde:	39 da                	cmp    %ebx,%edx
  801ce0:	75 0f                	jne    801cf1 <ipc_find_env+0x36>
			return envs[i].env_id;
  801ce2:	c1 e0 07             	shl    $0x7,%eax
  801ce5:	29 c8                	sub    %ecx,%eax
  801ce7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cec:	8b 40 40             	mov    0x40(%eax),%eax
  801cef:	eb 0c                	jmp    801cfd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cf1:	40                   	inc    %eax
  801cf2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cf7:	75 ce                	jne    801cc7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cf9:	66 b8 00 00          	mov    $0x0,%ax
}
  801cfd:	5b                   	pop    %ebx
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    

00801d00 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801d06:	89 c2                	mov    %eax,%edx
  801d08:	c1 ea 16             	shr    $0x16,%edx
  801d0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d12:	f6 c2 01             	test   $0x1,%dl
  801d15:	74 1e                	je     801d35 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d17:	c1 e8 0c             	shr    $0xc,%eax
  801d1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d21:	a8 01                	test   $0x1,%al
  801d23:	74 17                	je     801d3c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d25:	c1 e8 0c             	shr    $0xc,%eax
  801d28:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d2f:	ef 
  801d30:	0f b7 c0             	movzwl %ax,%eax
  801d33:	eb 0c                	jmp    801d41 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3a:	eb 05                	jmp    801d41 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    
	...

00801d44 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d44:	55                   	push   %ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	83 ec 10             	sub    $0x10,%esp
  801d4a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d4e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d52:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d56:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d5a:	89 cd                	mov    %ecx,%ebp
  801d5c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d60:	85 c0                	test   %eax,%eax
  801d62:	75 2c                	jne    801d90 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d64:	39 f9                	cmp    %edi,%ecx
  801d66:	77 68                	ja     801dd0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d68:	85 c9                	test   %ecx,%ecx
  801d6a:	75 0b                	jne    801d77 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d71:	31 d2                	xor    %edx,%edx
  801d73:	f7 f1                	div    %ecx
  801d75:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d77:	31 d2                	xor    %edx,%edx
  801d79:	89 f8                	mov    %edi,%eax
  801d7b:	f7 f1                	div    %ecx
  801d7d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d7f:	89 f0                	mov    %esi,%eax
  801d81:	f7 f1                	div    %ecx
  801d83:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d85:	89 f0                	mov    %esi,%eax
  801d87:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	5e                   	pop    %esi
  801d8d:	5f                   	pop    %edi
  801d8e:	5d                   	pop    %ebp
  801d8f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d90:	39 f8                	cmp    %edi,%eax
  801d92:	77 2c                	ja     801dc0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d94:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801d97:	83 f6 1f             	xor    $0x1f,%esi
  801d9a:	75 4c                	jne    801de8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d9c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d9e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801da3:	72 0a                	jb     801daf <__udivdi3+0x6b>
  801da5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801da9:	0f 87 ad 00 00 00    	ja     801e5c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801daf:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dc0:	31 ff                	xor    %edi,%edi
  801dc2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dc4:	89 f0                	mov    %esi,%eax
  801dc6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	5e                   	pop    %esi
  801dcc:	5f                   	pop    %edi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    
  801dcf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dd0:	89 fa                	mov    %edi,%edx
  801dd2:	89 f0                	mov    %esi,%eax
  801dd4:	f7 f1                	div    %ecx
  801dd6:	89 c6                	mov    %eax,%esi
  801dd8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dda:	89 f0                	mov    %esi,%eax
  801ddc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	5e                   	pop    %esi
  801de2:	5f                   	pop    %edi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
  801de5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801de8:	89 f1                	mov    %esi,%ecx
  801dea:	d3 e0                	shl    %cl,%eax
  801dec:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801df0:	b8 20 00 00 00       	mov    $0x20,%eax
  801df5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801df7:	89 ea                	mov    %ebp,%edx
  801df9:	88 c1                	mov    %al,%cl
  801dfb:	d3 ea                	shr    %cl,%edx
  801dfd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e01:	09 ca                	or     %ecx,%edx
  801e03:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801e07:	89 f1                	mov    %esi,%ecx
  801e09:	d3 e5                	shl    %cl,%ebp
  801e0b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801e0f:	89 fd                	mov    %edi,%ebp
  801e11:	88 c1                	mov    %al,%cl
  801e13:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801e15:	89 fa                	mov    %edi,%edx
  801e17:	89 f1                	mov    %esi,%ecx
  801e19:	d3 e2                	shl    %cl,%edx
  801e1b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e1f:	88 c1                	mov    %al,%cl
  801e21:	d3 ef                	shr    %cl,%edi
  801e23:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e25:	89 f8                	mov    %edi,%eax
  801e27:	89 ea                	mov    %ebp,%edx
  801e29:	f7 74 24 08          	divl   0x8(%esp)
  801e2d:	89 d1                	mov    %edx,%ecx
  801e2f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e31:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e35:	39 d1                	cmp    %edx,%ecx
  801e37:	72 17                	jb     801e50 <__udivdi3+0x10c>
  801e39:	74 09                	je     801e44 <__udivdi3+0x100>
  801e3b:	89 fe                	mov    %edi,%esi
  801e3d:	31 ff                	xor    %edi,%edi
  801e3f:	e9 41 ff ff ff       	jmp    801d85 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e44:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e48:	89 f1                	mov    %esi,%ecx
  801e4a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e4c:	39 c2                	cmp    %eax,%edx
  801e4e:	73 eb                	jae    801e3b <__udivdi3+0xf7>
		{
		  q0--;
  801e50:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e53:	31 ff                	xor    %edi,%edi
  801e55:	e9 2b ff ff ff       	jmp    801d85 <__udivdi3+0x41>
  801e5a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e5c:	31 f6                	xor    %esi,%esi
  801e5e:	e9 22 ff ff ff       	jmp    801d85 <__udivdi3+0x41>
	...

00801e64 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e64:	55                   	push   %ebp
  801e65:	57                   	push   %edi
  801e66:	56                   	push   %esi
  801e67:	83 ec 20             	sub    $0x20,%esp
  801e6a:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e6e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e72:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e76:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e7a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e7e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e82:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801e84:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e86:	85 ed                	test   %ebp,%ebp
  801e88:	75 16                	jne    801ea0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801e8a:	39 f1                	cmp    %esi,%ecx
  801e8c:	0f 86 a6 00 00 00    	jbe    801f38 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e92:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e94:	89 d0                	mov    %edx,%eax
  801e96:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e98:	83 c4 20             	add    $0x20,%esp
  801e9b:	5e                   	pop    %esi
  801e9c:	5f                   	pop    %edi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    
  801e9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ea0:	39 f5                	cmp    %esi,%ebp
  801ea2:	0f 87 ac 00 00 00    	ja     801f54 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ea8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801eab:	83 f0 1f             	xor    $0x1f,%eax
  801eae:	89 44 24 10          	mov    %eax,0x10(%esp)
  801eb2:	0f 84 a8 00 00 00    	je     801f60 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801eb8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ebc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ebe:	bf 20 00 00 00       	mov    $0x20,%edi
  801ec3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ec7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ecb:	89 f9                	mov    %edi,%ecx
  801ecd:	d3 e8                	shr    %cl,%eax
  801ecf:	09 e8                	or     %ebp,%eax
  801ed1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801ed5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ed9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801edd:	d3 e0                	shl    %cl,%eax
  801edf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ee3:	89 f2                	mov    %esi,%edx
  801ee5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ee7:	8b 44 24 14          	mov    0x14(%esp),%eax
  801eeb:	d3 e0                	shl    %cl,%eax
  801eed:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ef1:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ef5:	89 f9                	mov    %edi,%ecx
  801ef7:	d3 e8                	shr    %cl,%eax
  801ef9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801efb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801efd:	89 f2                	mov    %esi,%edx
  801eff:	f7 74 24 18          	divl   0x18(%esp)
  801f03:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f05:	f7 64 24 0c          	mull   0xc(%esp)
  801f09:	89 c5                	mov    %eax,%ebp
  801f0b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f0d:	39 d6                	cmp    %edx,%esi
  801f0f:	72 67                	jb     801f78 <__umoddi3+0x114>
  801f11:	74 75                	je     801f88 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f13:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f17:	29 e8                	sub    %ebp,%eax
  801f19:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f1b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f1f:	d3 e8                	shr    %cl,%eax
  801f21:	89 f2                	mov    %esi,%edx
  801f23:	89 f9                	mov    %edi,%ecx
  801f25:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f27:	09 d0                	or     %edx,%eax
  801f29:	89 f2                	mov    %esi,%edx
  801f2b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f2f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f31:	83 c4 20             	add    $0x20,%esp
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f38:	85 c9                	test   %ecx,%ecx
  801f3a:	75 0b                	jne    801f47 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f41:	31 d2                	xor    %edx,%edx
  801f43:	f7 f1                	div    %ecx
  801f45:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f47:	89 f0                	mov    %esi,%eax
  801f49:	31 d2                	xor    %edx,%edx
  801f4b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f4d:	89 f8                	mov    %edi,%eax
  801f4f:	e9 3e ff ff ff       	jmp    801e92 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f54:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f56:	83 c4 20             	add    $0x20,%esp
  801f59:	5e                   	pop    %esi
  801f5a:	5f                   	pop    %edi
  801f5b:	5d                   	pop    %ebp
  801f5c:	c3                   	ret    
  801f5d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f60:	39 f5                	cmp    %esi,%ebp
  801f62:	72 04                	jb     801f68 <__umoddi3+0x104>
  801f64:	39 f9                	cmp    %edi,%ecx
  801f66:	77 06                	ja     801f6e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f68:	89 f2                	mov    %esi,%edx
  801f6a:	29 cf                	sub    %ecx,%edi
  801f6c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f6e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f70:	83 c4 20             	add    $0x20,%esp
  801f73:	5e                   	pop    %esi
  801f74:	5f                   	pop    %edi
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    
  801f77:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f78:	89 d1                	mov    %edx,%ecx
  801f7a:	89 c5                	mov    %eax,%ebp
  801f7c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f80:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f84:	eb 8d                	jmp    801f13 <__umoddi3+0xaf>
  801f86:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f88:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f8c:	72 ea                	jb     801f78 <__umoddi3+0x114>
  801f8e:	89 f1                	mov    %esi,%ecx
  801f90:	eb 81                	jmp    801f13 <__umoddi3+0xaf>
