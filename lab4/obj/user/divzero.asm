
obj/user/divzero:     file format elf32-i386


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

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 e0 0f 80 00 	movl   $0x800fe0,(%esp)
  80005c:	e8 1f 01 00 00       	call   800180 <cprintf>
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    
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
  800072:	e8 68 0a 00 00       	call   800adf <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800083:	c1 e0 07             	shl    $0x7,%eax
  800086:	29 d0                	sub    %edx,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800093:	a3 08 20 80 00       	mov    %eax,0x802008
  800098:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  80009c:	c7 04 24 ee 0f 80 00 	movl   $0x800fee,(%esp)
  8000a3:	e8 d8 00 00 00       	call   800180 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a8:	85 f6                	test   %esi,%esi
  8000aa:	7e 07                	jle    8000b3 <libmain+0x4f>
		binaryname = argv[0];
  8000ac:	8b 03                	mov    (%ebx),%eax
  8000ae:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b7:	89 34 24             	mov    %esi,(%esp)
  8000ba:	e8 75 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bf:	e8 08 00 00 00       	call   8000cc <exit>
}
  8000c4:	83 c4 20             	add    $0x20,%esp
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d9:	e8 af 09 00 00       	call   800a8d <sys_env_destroy>
}
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 14             	sub    $0x14,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 03                	mov    (%ebx),%eax
  8000ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000f3:	40                   	inc    %eax
  8000f4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fb:	75 19                	jne    800116 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8000fd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800104:	00 
  800105:	8d 43 08             	lea    0x8(%ebx),%eax
  800108:	89 04 24             	mov    %eax,(%esp)
  80010b:	e8 40 09 00 00       	call   800a50 <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800116:	ff 43 04             	incl   0x4(%ebx)
}
  800119:	83 c4 14             	add    $0x14,%esp
  80011c:	5b                   	pop    %ebx
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800128:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012f:	00 00 00 
	b.cnt = 0;
  800132:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800139:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 45 08             	mov    0x8(%ebp),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800150:	89 44 24 04          	mov    %eax,0x4(%esp)
  800154:	c7 04 24 e0 00 80 00 	movl   $0x8000e0,(%esp)
  80015b:	e8 82 01 00 00       	call   8002e2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800160:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800170:	89 04 24             	mov    %eax,(%esp)
  800173:	e8 d8 08 00 00       	call   800a50 <sys_cputs>

	return b.cnt;
}
  800178:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800186:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	8b 45 08             	mov    0x8(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 87 ff ff ff       	call   80011f <vcprintf>
	va_end(ap);

	return cnt;
}
  800198:	c9                   	leave  
  800199:	c3                   	ret    
	...

0080019c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	57                   	push   %edi
  8001a0:	56                   	push   %esi
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 3c             	sub    $0x3c,%esp
  8001a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001a8:	89 d7                	mov    %edx,%edi
  8001aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	75 08                	jne    8001c8 <printnum+0x2c>
  8001c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c6:	77 57                	ja     80021f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001cc:	4b                   	dec    %ebx
  8001cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001dc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e7:	00 
  8001e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001eb:	89 04 24             	mov    %eax,(%esp)
  8001ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f5:	e8 92 0b 00 00       	call   800d8c <__udivdi3>
  8001fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001fe:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	89 54 24 04          	mov    %edx,0x4(%esp)
  800209:	89 fa                	mov    %edi,%edx
  80020b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020e:	e8 89 ff ff ff       	call   80019c <printnum>
  800213:	eb 0f                	jmp    800224 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800215:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800219:	89 34 24             	mov    %esi,(%esp)
  80021c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021f:	4b                   	dec    %ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f f1                	jg     800215 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800228:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80022c:	8b 45 10             	mov    0x10(%ebp),%eax
  80022f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800233:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023a:	00 
  80023b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023e:	89 04 24             	mov    %eax,(%esp)
  800241:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800244:	89 44 24 04          	mov    %eax,0x4(%esp)
  800248:	e8 5f 0c 00 00       	call   800eac <__umoddi3>
  80024d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800251:	0f be 80 fc 0f 80 00 	movsbl 0x800ffc(%eax),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80025e:	83 c4 3c             	add    $0x3c,%esp
  800261:	5b                   	pop    %ebx
  800262:	5e                   	pop    %esi
  800263:	5f                   	pop    %edi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800269:	83 fa 01             	cmp    $0x1,%edx
  80026c:	7e 0e                	jle    80027c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026e:	8b 10                	mov    (%eax),%edx
  800270:	8d 4a 08             	lea    0x8(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 02                	mov    (%edx),%eax
  800277:	8b 52 04             	mov    0x4(%edx),%edx
  80027a:	eb 22                	jmp    80029e <getuint+0x38>
	else if (lflag)
  80027c:	85 d2                	test   %edx,%edx
  80027e:	74 10                	je     800290 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 04             	lea    0x4(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
  80028e:	eb 0e                	jmp    80029e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ae:	73 08                	jae    8002b8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b3:	88 0a                	mov    %cl,(%edx)
  8002b5:	42                   	inc    %edx
  8002b6:	89 10                	mov    %edx,(%eax)
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	e8 02 00 00 00       	call   8002e2 <vprintfmt>
	va_end(ap);
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 4c             	sub    $0x4c,%esp
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8002f1:	eb 12                	jmp    800305 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	0f 84 6b 03 00 00    	je     800666 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	0f b6 06             	movzbl (%esi),%eax
  800308:	46                   	inc    %esi
  800309:	83 f8 25             	cmp    $0x25,%eax
  80030c:	75 e5                	jne    8002f3 <vprintfmt+0x11>
  80030e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800312:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800319:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80031e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800325:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032a:	eb 26                	jmp    800352 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800333:	eb 1d                	jmp    800352 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800338:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80033c:	eb 14                	jmp    800352 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800341:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800348:	eb 08                	jmp    800352 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80034a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80034d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	0f b6 06             	movzbl (%esi),%eax
  800355:	8d 56 01             	lea    0x1(%esi),%edx
  800358:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80035b:	8a 16                	mov    (%esi),%dl
  80035d:	83 ea 23             	sub    $0x23,%edx
  800360:	80 fa 55             	cmp    $0x55,%dl
  800363:	0f 87 e1 02 00 00    	ja     80064a <vprintfmt+0x368>
  800369:	0f b6 d2             	movzbl %dl,%edx
  80036c:	ff 24 95 c0 10 80 00 	jmp    *0x8010c0(,%edx,4)
  800373:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800376:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80037e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800382:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800385:	8d 50 d0             	lea    -0x30(%eax),%edx
  800388:	83 fa 09             	cmp    $0x9,%edx
  80038b:	77 2a                	ja     8003b7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb eb                	jmp    80037b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 50 04             	lea    0x4(%eax),%edx
  800396:	89 55 14             	mov    %edx,0x14(%ebp)
  800399:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039e:	eb 17                	jmp    8003b7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a4:	78 98                	js     80033e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003a9:	eb a7                	jmp    800352 <vprintfmt+0x70>
  8003ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ae:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003b5:	eb 9b                	jmp    800352 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003bb:	79 95                	jns    800352 <vprintfmt+0x70>
  8003bd:	eb 8b                	jmp    80034a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c3:	eb 8d                	jmp    800352 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 50 04             	lea    0x4(%eax),%edx
  8003cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d2:	8b 00                	mov    (%eax),%eax
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003dd:	e9 23 ff ff ff       	jmp    800305 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 50 04             	lea    0x4(%eax),%edx
  8003e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	79 02                	jns    8003f3 <vprintfmt+0x111>
  8003f1:	f7 d8                	neg    %eax
  8003f3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f5:	83 f8 08             	cmp    $0x8,%eax
  8003f8:	7f 0b                	jg     800405 <vprintfmt+0x123>
  8003fa:	8b 04 85 20 12 80 00 	mov    0x801220(,%eax,4),%eax
  800401:	85 c0                	test   %eax,%eax
  800403:	75 23                	jne    800428 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800405:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800409:	c7 44 24 08 14 10 80 	movl   $0x801014,0x8(%esp)
  800410:	00 
  800411:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 9a fe ff ff       	call   8002ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800423:	e9 dd fe ff ff       	jmp    800305 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800428:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042c:	c7 44 24 08 1d 10 80 	movl   $0x80101d,0x8(%esp)
  800433:	00 
  800434:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800438:	8b 55 08             	mov    0x8(%ebp),%edx
  80043b:	89 14 24             	mov    %edx,(%esp)
  80043e:	e8 77 fe ff ff       	call   8002ba <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800446:	e9 ba fe ff ff       	jmp    800305 <vprintfmt+0x23>
  80044b:	89 f9                	mov    %edi,%ecx
  80044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800450:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 50 04             	lea    0x4(%eax),%edx
  800459:	89 55 14             	mov    %edx,0x14(%ebp)
  80045c:	8b 30                	mov    (%eax),%esi
  80045e:	85 f6                	test   %esi,%esi
  800460:	75 05                	jne    800467 <vprintfmt+0x185>
				p = "(null)";
  800462:	be 0d 10 80 00       	mov    $0x80100d,%esi
			if (width > 0 && padc != '-')
  800467:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046b:	0f 8e 84 00 00 00    	jle    8004f5 <vprintfmt+0x213>
  800471:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800475:	74 7e                	je     8004f5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80047b:	89 34 24             	mov    %esi,(%esp)
  80047e:	e8 8b 02 00 00       	call   80070e <strnlen>
  800483:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800486:	29 c2                	sub    %eax,%edx
  800488:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80048b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80048f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800492:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800495:	89 de                	mov    %ebx,%esi
  800497:	89 d3                	mov    %edx,%ebx
  800499:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	eb 0b                	jmp    8004a8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80049d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a1:	89 3c 24             	mov    %edi,(%esp)
  8004a4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	4b                   	dec    %ebx
  8004a8:	85 db                	test   %ebx,%ebx
  8004aa:	7f f1                	jg     80049d <vprintfmt+0x1bb>
  8004ac:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004af:	89 f3                	mov    %esi,%ebx
  8004b1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	79 05                	jns    8004c0 <vprintfmt+0x1de>
  8004bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c3:	29 c2                	sub    %eax,%edx
  8004c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004c8:	eb 2b                	jmp    8004f5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ce:	74 18                	je     8004e8 <vprintfmt+0x206>
  8004d0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004d3:	83 fa 5e             	cmp    $0x5e,%edx
  8004d6:	76 10                	jbe    8004e8 <vprintfmt+0x206>
					putch('?', putdat);
  8004d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004e3:	ff 55 08             	call   *0x8(%ebp)
  8004e6:	eb 0a                	jmp    8004f2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ec:	89 04 24             	mov    %eax,(%esp)
  8004ef:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f2:	ff 4d e4             	decl   -0x1c(%ebp)
  8004f5:	0f be 06             	movsbl (%esi),%eax
  8004f8:	46                   	inc    %esi
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	74 21                	je     80051e <vprintfmt+0x23c>
  8004fd:	85 ff                	test   %edi,%edi
  8004ff:	78 c9                	js     8004ca <vprintfmt+0x1e8>
  800501:	4f                   	dec    %edi
  800502:	79 c6                	jns    8004ca <vprintfmt+0x1e8>
  800504:	8b 7d 08             	mov    0x8(%ebp),%edi
  800507:	89 de                	mov    %ebx,%esi
  800509:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80050c:	eb 18                	jmp    800526 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800512:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800519:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051b:	4b                   	dec    %ebx
  80051c:	eb 08                	jmp    800526 <vprintfmt+0x244>
  80051e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800521:	89 de                	mov    %ebx,%esi
  800523:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800526:	85 db                	test   %ebx,%ebx
  800528:	7f e4                	jg     80050e <vprintfmt+0x22c>
  80052a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80052d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800532:	e9 ce fd ff ff       	jmp    800305 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800537:	83 f9 01             	cmp    $0x1,%ecx
  80053a:	7e 10                	jle    80054c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 50 08             	lea    0x8(%eax),%edx
  800542:	89 55 14             	mov    %edx,0x14(%ebp)
  800545:	8b 30                	mov    (%eax),%esi
  800547:	8b 78 04             	mov    0x4(%eax),%edi
  80054a:	eb 26                	jmp    800572 <vprintfmt+0x290>
	else if (lflag)
  80054c:	85 c9                	test   %ecx,%ecx
  80054e:	74 12                	je     800562 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 50 04             	lea    0x4(%eax),%edx
  800556:	89 55 14             	mov    %edx,0x14(%ebp)
  800559:	8b 30                	mov    (%eax),%esi
  80055b:	89 f7                	mov    %esi,%edi
  80055d:	c1 ff 1f             	sar    $0x1f,%edi
  800560:	eb 10                	jmp    800572 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 04             	lea    0x4(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	8b 30                	mov    (%eax),%esi
  80056d:	89 f7                	mov    %esi,%edi
  80056f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800572:	85 ff                	test   %edi,%edi
  800574:	78 0a                	js     800580 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 8c 00 00 00       	jmp    80060c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800580:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800584:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80058b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80058e:	f7 de                	neg    %esi
  800590:	83 d7 00             	adc    $0x0,%edi
  800593:	f7 df                	neg    %edi
			}
			base = 10;
  800595:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059a:	eb 70                	jmp    80060c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059c:	89 ca                	mov    %ecx,%edx
  80059e:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a1:	e8 c0 fc ff ff       	call   800266 <getuint>
  8005a6:	89 c6                	mov    %eax,%esi
  8005a8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005af:	eb 5b                	jmp    80060c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005b1:	89 ca                	mov    %ecx,%edx
  8005b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b6:	e8 ab fc ff ff       	call   800266 <getuint>
  8005bb:	89 c6                	mov    %eax,%esi
  8005bd:	89 d7                	mov    %edx,%edi
			base = 8;
  8005bf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005c4:	eb 46                	jmp    80060c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ca:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005d1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005eb:	8b 30                	mov    (%eax),%esi
  8005ed:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f7:	eb 13                	jmp    80060c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f9:	89 ca                	mov    %ecx,%edx
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 63 fc ff ff       	call   800266 <getuint>
  800603:	89 c6                	mov    %eax,%esi
  800605:	89 d7                	mov    %edx,%edi
			base = 16;
  800607:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80060c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800610:	89 54 24 10          	mov    %edx,0x10(%esp)
  800614:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800617:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061f:	89 34 24             	mov    %esi,(%esp)
  800622:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800626:	89 da                	mov    %ebx,%edx
  800628:	8b 45 08             	mov    0x8(%ebp),%eax
  80062b:	e8 6c fb ff ff       	call   80019c <printnum>
			break;
  800630:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800633:	e9 cd fc ff ff       	jmp    800305 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063c:	89 04 24             	mov    %eax,(%esp)
  80063f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800645:	e9 bb fc ff ff       	jmp    800305 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800655:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800658:	eb 01                	jmp    80065b <vprintfmt+0x379>
  80065a:	4e                   	dec    %esi
  80065b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80065f:	75 f9                	jne    80065a <vprintfmt+0x378>
  800661:	e9 9f fc ff ff       	jmp    800305 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800666:	83 c4 4c             	add    $0x4c,%esp
  800669:	5b                   	pop    %ebx
  80066a:	5e                   	pop    %esi
  80066b:	5f                   	pop    %edi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 28             	sub    $0x28,%esp
  800674:	8b 45 08             	mov    0x8(%ebp),%eax
  800677:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800681:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068b:	85 c0                	test   %eax,%eax
  80068d:	74 30                	je     8006bf <vsnprintf+0x51>
  80068f:	85 d2                	test   %edx,%edx
  800691:	7e 33                	jle    8006c6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80069a:	8b 45 10             	mov    0x10(%ebp),%eax
  80069d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a8:	c7 04 24 a0 02 80 00 	movl   $0x8002a0,(%esp)
  8006af:	e8 2e fc ff ff       	call   8002e2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bd:	eb 0c                	jmp    8006cb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c4:	eb 05                	jmp    8006cb <vsnprintf+0x5d>
  8006c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006da:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	e8 7b ff ff ff       	call   80066e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    
  8006f5:	00 00                	add    %al,(%eax)
	...

008006f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	eb 01                	jmp    800706 <strlen+0xe>
		n++;
  800705:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070a:	75 f9                	jne    800705 <strlen+0xd>
		n++;
	return n;
}
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800717:	b8 00 00 00 00       	mov    $0x0,%eax
  80071c:	eb 01                	jmp    80071f <strnlen+0x11>
		n++;
  80071e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	39 d0                	cmp    %edx,%eax
  800721:	74 06                	je     800729 <strnlen+0x1b>
  800723:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800727:	75 f5                	jne    80071e <strnlen+0x10>
		n++;
	return n;
}
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	53                   	push   %ebx
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800735:	ba 00 00 00 00       	mov    $0x0,%edx
  80073a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80073d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800740:	42                   	inc    %edx
  800741:	84 c9                	test   %cl,%cl
  800743:	75 f5                	jne    80073a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800745:	5b                   	pop    %ebx
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	53                   	push   %ebx
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800752:	89 1c 24             	mov    %ebx,(%esp)
  800755:	e8 9e ff ff ff       	call   8006f8 <strlen>
	strcpy(dst + len, src);
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800761:	01 d8                	add    %ebx,%eax
  800763:	89 04 24             	mov    %eax,(%esp)
  800766:	e8 c0 ff ff ff       	call   80072b <strcpy>
	return dst;
}
  80076b:	89 d8                	mov    %ebx,%eax
  80076d:	83 c4 08             	add    $0x8,%esp
  800770:	5b                   	pop    %ebx
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	56                   	push   %esi
  800777:	53                   	push   %ebx
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800781:	b9 00 00 00 00       	mov    $0x0,%ecx
  800786:	eb 0c                	jmp    800794 <strncpy+0x21>
		*dst++ = *src;
  800788:	8a 1a                	mov    (%edx),%bl
  80078a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078d:	80 3a 01             	cmpb   $0x1,(%edx)
  800790:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800793:	41                   	inc    %ecx
  800794:	39 f1                	cmp    %esi,%ecx
  800796:	75 f0                	jne    800788 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800798:	5b                   	pop    %ebx
  800799:	5e                   	pop    %esi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	75 0a                	jne    8007b8 <strlcpy+0x1c>
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	eb 1a                	jmp    8007cc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b2:	88 18                	mov    %bl,(%eax)
  8007b4:	40                   	inc    %eax
  8007b5:	41                   	inc    %ecx
  8007b6:	eb 02                	jmp    8007ba <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007ba:	4a                   	dec    %edx
  8007bb:	74 0a                	je     8007c7 <strlcpy+0x2b>
  8007bd:	8a 19                	mov    (%ecx),%bl
  8007bf:	84 db                	test   %bl,%bl
  8007c1:	75 ef                	jne    8007b2 <strlcpy+0x16>
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	eb 02                	jmp    8007c9 <strlcpy+0x2d>
  8007c7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007c9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007cc:	29 f0                	sub    %esi,%eax
}
  8007ce:	5b                   	pop    %ebx
  8007cf:	5e                   	pop    %esi
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007db:	eb 02                	jmp    8007df <strcmp+0xd>
		p++, q++;
  8007dd:	41                   	inc    %ecx
  8007de:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007df:	8a 01                	mov    (%ecx),%al
  8007e1:	84 c0                	test   %al,%al
  8007e3:	74 04                	je     8007e9 <strcmp+0x17>
  8007e5:	3a 02                	cmp    (%edx),%al
  8007e7:	74 f4                	je     8007dd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e9:	0f b6 c0             	movzbl %al,%eax
  8007ec:	0f b6 12             	movzbl (%edx),%edx
  8007ef:	29 d0                	sub    %edx,%eax
}
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800800:	eb 03                	jmp    800805 <strncmp+0x12>
		n--, p++, q++;
  800802:	4a                   	dec    %edx
  800803:	40                   	inc    %eax
  800804:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800805:	85 d2                	test   %edx,%edx
  800807:	74 14                	je     80081d <strncmp+0x2a>
  800809:	8a 18                	mov    (%eax),%bl
  80080b:	84 db                	test   %bl,%bl
  80080d:	74 04                	je     800813 <strncmp+0x20>
  80080f:	3a 19                	cmp    (%ecx),%bl
  800811:	74 ef                	je     800802 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800813:	0f b6 00             	movzbl (%eax),%eax
  800816:	0f b6 11             	movzbl (%ecx),%edx
  800819:	29 d0                	sub    %edx,%eax
  80081b:	eb 05                	jmp    800822 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800822:	5b                   	pop    %ebx
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80082e:	eb 05                	jmp    800835 <strchr+0x10>
		if (*s == c)
  800830:	38 ca                	cmp    %cl,%dl
  800832:	74 0c                	je     800840 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800834:	40                   	inc    %eax
  800835:	8a 10                	mov    (%eax),%dl
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f5                	jne    800830 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80084b:	eb 05                	jmp    800852 <strfind+0x10>
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 07                	je     800858 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800851:	40                   	inc    %eax
  800852:	8a 10                	mov    (%eax),%dl
  800854:	84 d2                	test   %dl,%dl
  800856:	75 f5                	jne    80084d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	57                   	push   %edi
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	8b 7d 08             	mov    0x8(%ebp),%edi
  800863:	8b 45 0c             	mov    0xc(%ebp),%eax
  800866:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800869:	85 c9                	test   %ecx,%ecx
  80086b:	74 30                	je     80089d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800873:	75 25                	jne    80089a <memset+0x40>
  800875:	f6 c1 03             	test   $0x3,%cl
  800878:	75 20                	jne    80089a <memset+0x40>
		c &= 0xFF;
  80087a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087d:	89 d3                	mov    %edx,%ebx
  80087f:	c1 e3 08             	shl    $0x8,%ebx
  800882:	89 d6                	mov    %edx,%esi
  800884:	c1 e6 18             	shl    $0x18,%esi
  800887:	89 d0                	mov    %edx,%eax
  800889:	c1 e0 10             	shl    $0x10,%eax
  80088c:	09 f0                	or     %esi,%eax
  80088e:	09 d0                	or     %edx,%eax
  800890:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800892:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800895:	fc                   	cld    
  800896:	f3 ab                	rep stos %eax,%es:(%edi)
  800898:	eb 03                	jmp    80089d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089a:	fc                   	cld    
  80089b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089d:	89 f8                	mov    %edi,%eax
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5f                   	pop    %edi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b2:	39 c6                	cmp    %eax,%esi
  8008b4:	73 34                	jae    8008ea <memmove+0x46>
  8008b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b9:	39 d0                	cmp    %edx,%eax
  8008bb:	73 2d                	jae    8008ea <memmove+0x46>
		s += n;
		d += n;
  8008bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c0:	f6 c2 03             	test   $0x3,%dl
  8008c3:	75 1b                	jne    8008e0 <memmove+0x3c>
  8008c5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cb:	75 13                	jne    8008e0 <memmove+0x3c>
  8008cd:	f6 c1 03             	test   $0x3,%cl
  8008d0:	75 0e                	jne    8008e0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d2:	83 ef 04             	sub    $0x4,%edi
  8008d5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008db:	fd                   	std    
  8008dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008de:	eb 07                	jmp    8008e7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e0:	4f                   	dec    %edi
  8008e1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e4:	fd                   	std    
  8008e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e7:	fc                   	cld    
  8008e8:	eb 20                	jmp    80090a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f0:	75 13                	jne    800905 <memmove+0x61>
  8008f2:	a8 03                	test   $0x3,%al
  8008f4:	75 0f                	jne    800905 <memmove+0x61>
  8008f6:	f6 c1 03             	test   $0x3,%cl
  8008f9:	75 0a                	jne    800905 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008fe:	89 c7                	mov    %eax,%edi
  800900:	fc                   	cld    
  800901:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800903:	eb 05                	jmp    80090a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800905:	89 c7                	mov    %eax,%edi
  800907:	fc                   	cld    
  800908:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090a:	5e                   	pop    %esi
  80090b:	5f                   	pop    %edi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800914:	8b 45 10             	mov    0x10(%ebp),%eax
  800917:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	89 04 24             	mov    %eax,(%esp)
  800928:	e8 77 ff ff ff       	call   8008a4 <memmove>
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 7d 08             	mov    0x8(%ebp),%edi
  800938:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093e:	ba 00 00 00 00       	mov    $0x0,%edx
  800943:	eb 16                	jmp    80095b <memcmp+0x2c>
		if (*s1 != *s2)
  800945:	8a 04 17             	mov    (%edi,%edx,1),%al
  800948:	42                   	inc    %edx
  800949:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80094d:	38 c8                	cmp    %cl,%al
  80094f:	74 0a                	je     80095b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800951:	0f b6 c0             	movzbl %al,%eax
  800954:	0f b6 c9             	movzbl %cl,%ecx
  800957:	29 c8                	sub    %ecx,%eax
  800959:	eb 09                	jmp    800964 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095b:	39 da                	cmp    %ebx,%edx
  80095d:	75 e6                	jne    800945 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800972:	89 c2                	mov    %eax,%edx
  800974:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800977:	eb 05                	jmp    80097e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800979:	38 08                	cmp    %cl,(%eax)
  80097b:	74 05                	je     800982 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097d:	40                   	inc    %eax
  80097e:	39 d0                	cmp    %edx,%eax
  800980:	72 f7                	jb     800979 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 55 08             	mov    0x8(%ebp),%edx
  80098d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800990:	eb 01                	jmp    800993 <strtol+0xf>
		s++;
  800992:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800993:	8a 02                	mov    (%edx),%al
  800995:	3c 20                	cmp    $0x20,%al
  800997:	74 f9                	je     800992 <strtol+0xe>
  800999:	3c 09                	cmp    $0x9,%al
  80099b:	74 f5                	je     800992 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099d:	3c 2b                	cmp    $0x2b,%al
  80099f:	75 08                	jne    8009a9 <strtol+0x25>
		s++;
  8009a1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a7:	eb 13                	jmp    8009bc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a9:	3c 2d                	cmp    $0x2d,%al
  8009ab:	75 0a                	jne    8009b7 <strtol+0x33>
		s++, neg = 1;
  8009ad:	8d 52 01             	lea    0x1(%edx),%edx
  8009b0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009b5:	eb 05                	jmp    8009bc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bc:	85 db                	test   %ebx,%ebx
  8009be:	74 05                	je     8009c5 <strtol+0x41>
  8009c0:	83 fb 10             	cmp    $0x10,%ebx
  8009c3:	75 28                	jne    8009ed <strtol+0x69>
  8009c5:	8a 02                	mov    (%edx),%al
  8009c7:	3c 30                	cmp    $0x30,%al
  8009c9:	75 10                	jne    8009db <strtol+0x57>
  8009cb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009cf:	75 0a                	jne    8009db <strtol+0x57>
		s += 2, base = 16;
  8009d1:	83 c2 02             	add    $0x2,%edx
  8009d4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d9:	eb 12                	jmp    8009ed <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	75 0e                	jne    8009ed <strtol+0x69>
  8009df:	3c 30                	cmp    $0x30,%al
  8009e1:	75 05                	jne    8009e8 <strtol+0x64>
		s++, base = 8;
  8009e3:	42                   	inc    %edx
  8009e4:	b3 08                	mov    $0x8,%bl
  8009e6:	eb 05                	jmp    8009ed <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009e8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f4:	8a 0a                	mov    (%edx),%cl
  8009f6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009f9:	80 fb 09             	cmp    $0x9,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0x82>
			dig = *s - '0';
  8009fe:	0f be c9             	movsbl %cl,%ecx
  800a01:	83 e9 30             	sub    $0x30,%ecx
  800a04:	eb 1e                	jmp    800a24 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a06:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a09:	80 fb 19             	cmp    $0x19,%bl
  800a0c:	77 08                	ja     800a16 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a0e:	0f be c9             	movsbl %cl,%ecx
  800a11:	83 e9 57             	sub    $0x57,%ecx
  800a14:	eb 0e                	jmp    800a24 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a16:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a19:	80 fb 19             	cmp    $0x19,%bl
  800a1c:	77 12                	ja     800a30 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a1e:	0f be c9             	movsbl %cl,%ecx
  800a21:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a24:	39 f1                	cmp    %esi,%ecx
  800a26:	7d 0c                	jge    800a34 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a28:	42                   	inc    %edx
  800a29:	0f af c6             	imul   %esi,%eax
  800a2c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a2e:	eb c4                	jmp    8009f4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a30:	89 c1                	mov    %eax,%ecx
  800a32:	eb 02                	jmp    800a36 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a34:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3a:	74 05                	je     800a41 <strtol+0xbd>
		*endptr = (char *) s;
  800a3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a3f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a41:	85 ff                	test   %edi,%edi
  800a43:	74 04                	je     800a49 <strtol+0xc5>
  800a45:	89 c8                	mov    %ecx,%eax
  800a47:	f7 d8                	neg    %eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    
	...

00800a50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a61:	89 c3                	mov    %eax,%ebx
  800a63:	89 c7                	mov    %eax,%edi
  800a65:	89 c6                	mov    %eax,%esi
  800a67:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a74:	ba 00 00 00 00       	mov    $0x0,%edx
  800a79:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7e:	89 d1                	mov    %edx,%ecx
  800a80:	89 d3                	mov    %edx,%ebx
  800a82:	89 d7                	mov    %edx,%edi
  800a84:	89 d6                	mov    %edx,%esi
  800a86:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa3:	89 cb                	mov    %ecx,%ebx
  800aa5:	89 cf                	mov    %ecx,%edi
  800aa7:	89 ce                	mov    %ecx,%esi
  800aa9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aab:	85 c0                	test   %eax,%eax
  800aad:	7e 28                	jle    800ad7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aaf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ab3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800aba:	00 
  800abb:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800ac2:	00 
  800ac3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aca:	00 
  800acb:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800ad2:	e8 5d 02 00 00       	call   800d34 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad7:	83 c4 2c             	add    $0x2c,%esp
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aea:	b8 02 00 00 00       	mov    $0x2,%eax
  800aef:	89 d1                	mov    %edx,%ecx
  800af1:	89 d3                	mov    %edx,%ebx
  800af3:	89 d7                	mov    %edx,%edi
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_yield>:

void
sys_yield(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	be 00 00 00 00       	mov    $0x0,%esi
  800b2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	89 f7                	mov    %esi,%edi
  800b3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7e 28                	jle    800b69 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b45:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b4c:	00 
  800b4d:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800b54:	00 
  800b55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b5c:	00 
  800b5d:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800b64:	e8 cb 01 00 00       	call   800d34 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b69:	83 c4 2c             	add    $0x2c,%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	b8 05 00 00 00       	mov    $0x5,%eax
  800b7f:	8b 75 18             	mov    0x18(%ebp),%esi
  800b82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b90:	85 c0                	test   %eax,%eax
  800b92:	7e 28                	jle    800bbc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b98:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800b9f:	00 
  800ba0:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800ba7:	00 
  800ba8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800baf:	00 
  800bb0:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800bb7:	e8 78 01 00 00       	call   800d34 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bbc:	83 c4 2c             	add    $0x2c,%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	89 df                	mov    %ebx,%edi
  800bdf:	89 de                	mov    %ebx,%esi
  800be1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 28                	jle    800c0f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800beb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800bfa:	00 
  800bfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c02:	00 
  800c03:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800c0a:	e8 25 01 00 00       	call   800d34 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0f:	83 c4 2c             	add    $0x2c,%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c25:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	89 df                	mov    %ebx,%edi
  800c32:	89 de                	mov    %ebx,%esi
  800c34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 28                	jle    800c62 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c45:	00 
  800c46:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800c4d:	00 
  800c4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c55:	00 
  800c56:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800c5d:	e8 d2 00 00 00       	call   800d34 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c62:	83 c4 2c             	add    $0x2c,%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c78:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	89 df                	mov    %ebx,%edi
  800c85:	89 de                	mov    %ebx,%esi
  800c87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 28                	jle    800cb5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c91:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c98:	00 
  800c99:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca8:	00 
  800ca9:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800cb0:	e8 7f 00 00 00       	call   800d34 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb5:	83 c4 2c             	add    $0x2c,%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	be 00 00 00 00       	mov    $0x0,%esi
  800cc8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ccd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cee:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 cb                	mov    %ecx,%ebx
  800cf8:	89 cf                	mov    %ecx,%edi
  800cfa:	89 ce                	mov    %ecx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 28                	jle    800d2a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d06:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800d15:	00 
  800d16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1d:	00 
  800d1e:	c7 04 24 61 12 80 00 	movl   $0x801261,(%esp)
  800d25:	e8 0a 00 00 00       	call   800d34 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2a:	83 c4 2c             	add    $0x2c,%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
	...

00800d34 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d3c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d3f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d45:	e8 95 fd ff ff       	call   800adf <sys_getenvid>
  800d4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d58:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d60:	c7 04 24 70 12 80 00 	movl   $0x801270,(%esp)
  800d67:	e8 14 f4 ff ff       	call   800180 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d70:	8b 45 10             	mov    0x10(%ebp),%eax
  800d73:	89 04 24             	mov    %eax,(%esp)
  800d76:	e8 a4 f3 ff ff       	call   80011f <vcprintf>
	cprintf("\n");
  800d7b:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  800d82:	e8 f9 f3 ff ff       	call   800180 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d87:	cc                   	int3   
  800d88:	eb fd                	jmp    800d87 <_panic+0x53>
	...

00800d8c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d8c:	55                   	push   %ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	83 ec 10             	sub    $0x10,%esp
  800d92:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d96:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d9e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800da2:	89 cd                	mov    %ecx,%ebp
  800da4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	75 2c                	jne    800dd8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800dac:	39 f9                	cmp    %edi,%ecx
  800dae:	77 68                	ja     800e18 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800db0:	85 c9                	test   %ecx,%ecx
  800db2:	75 0b                	jne    800dbf <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800db4:	b8 01 00 00 00       	mov    $0x1,%eax
  800db9:	31 d2                	xor    %edx,%edx
  800dbb:	f7 f1                	div    %ecx
  800dbd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800dbf:	31 d2                	xor    %edx,%edx
  800dc1:	89 f8                	mov    %edi,%eax
  800dc3:	f7 f1                	div    %ecx
  800dc5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dc7:	89 f0                	mov    %esi,%eax
  800dc9:	f7 f1                	div    %ecx
  800dcb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dd1:	83 c4 10             	add    $0x10,%esp
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dd8:	39 f8                	cmp    %edi,%eax
  800dda:	77 2c                	ja     800e08 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ddc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800ddf:	83 f6 1f             	xor    $0x1f,%esi
  800de2:	75 4c                	jne    800e30 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800de4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800de6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800deb:	72 0a                	jb     800df7 <__udivdi3+0x6b>
  800ded:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800df1:	0f 87 ad 00 00 00    	ja     800ea4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800df7:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e08:	31 ff                	xor    %edi,%edi
  800e0a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e0c:	89 f0                	mov    %esi,%eax
  800e0e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    
  800e17:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e18:	89 fa                	mov    %edi,%edx
  800e1a:	89 f0                	mov    %esi,%eax
  800e1c:	f7 f1                	div    %ecx
  800e1e:	89 c6                	mov    %eax,%esi
  800e20:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e22:	89 f0                	mov    %esi,%eax
  800e24:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e30:	89 f1                	mov    %esi,%ecx
  800e32:	d3 e0                	shl    %cl,%eax
  800e34:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e38:	b8 20 00 00 00       	mov    $0x20,%eax
  800e3d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e3f:	89 ea                	mov    %ebp,%edx
  800e41:	88 c1                	mov    %al,%cl
  800e43:	d3 ea                	shr    %cl,%edx
  800e45:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e49:	09 ca                	or     %ecx,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e4f:	89 f1                	mov    %esi,%ecx
  800e51:	d3 e5                	shl    %cl,%ebp
  800e53:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e57:	89 fd                	mov    %edi,%ebp
  800e59:	88 c1                	mov    %al,%cl
  800e5b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e5d:	89 fa                	mov    %edi,%edx
  800e5f:	89 f1                	mov    %esi,%ecx
  800e61:	d3 e2                	shl    %cl,%edx
  800e63:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e67:	88 c1                	mov    %al,%cl
  800e69:	d3 ef                	shr    %cl,%edi
  800e6b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e6d:	89 f8                	mov    %edi,%eax
  800e6f:	89 ea                	mov    %ebp,%edx
  800e71:	f7 74 24 08          	divl   0x8(%esp)
  800e75:	89 d1                	mov    %edx,%ecx
  800e77:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e79:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e7d:	39 d1                	cmp    %edx,%ecx
  800e7f:	72 17                	jb     800e98 <__udivdi3+0x10c>
  800e81:	74 09                	je     800e8c <__udivdi3+0x100>
  800e83:	89 fe                	mov    %edi,%esi
  800e85:	31 ff                	xor    %edi,%edi
  800e87:	e9 41 ff ff ff       	jmp    800dcd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e8c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e90:	89 f1                	mov    %esi,%ecx
  800e92:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e94:	39 c2                	cmp    %eax,%edx
  800e96:	73 eb                	jae    800e83 <__udivdi3+0xf7>
		{
		  q0--;
  800e98:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e9b:	31 ff                	xor    %edi,%edi
  800e9d:	e9 2b ff ff ff       	jmp    800dcd <__udivdi3+0x41>
  800ea2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ea4:	31 f6                	xor    %esi,%esi
  800ea6:	e9 22 ff ff ff       	jmp    800dcd <__udivdi3+0x41>
	...

00800eac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800eac:	55                   	push   %ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	83 ec 20             	sub    $0x20,%esp
  800eb2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800eb6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800eba:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ebe:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800ec2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ec6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800eca:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800ecc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ece:	85 ed                	test   %ebp,%ebp
  800ed0:	75 16                	jne    800ee8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800ed2:	39 f1                	cmp    %esi,%ecx
  800ed4:	0f 86 a6 00 00 00    	jbe    800f80 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eda:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800edc:	89 d0                	mov    %edx,%eax
  800ede:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ee0:	83 c4 20             	add    $0x20,%esp
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    
  800ee7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ee8:	39 f5                	cmp    %esi,%ebp
  800eea:	0f 87 ac 00 00 00    	ja     800f9c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ef0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800ef3:	83 f0 1f             	xor    $0x1f,%eax
  800ef6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efa:	0f 84 a8 00 00 00    	je     800fa8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f00:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f04:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f06:	bf 20 00 00 00       	mov    $0x20,%edi
  800f0b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f0f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	d3 e8                	shr    %cl,%eax
  800f17:	09 e8                	or     %ebp,%eax
  800f19:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f1d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f21:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f25:	d3 e0                	shl    %cl,%eax
  800f27:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f2b:	89 f2                	mov    %esi,%edx
  800f2d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f2f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f33:	d3 e0                	shl    %cl,%eax
  800f35:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f39:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f3d:	89 f9                	mov    %edi,%ecx
  800f3f:	d3 e8                	shr    %cl,%eax
  800f41:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f43:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f45:	89 f2                	mov    %esi,%edx
  800f47:	f7 74 24 18          	divl   0x18(%esp)
  800f4b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f4d:	f7 64 24 0c          	mull   0xc(%esp)
  800f51:	89 c5                	mov    %eax,%ebp
  800f53:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f55:	39 d6                	cmp    %edx,%esi
  800f57:	72 67                	jb     800fc0 <__umoddi3+0x114>
  800f59:	74 75                	je     800fd0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f5b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f5f:	29 e8                	sub    %ebp,%eax
  800f61:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f63:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f67:	d3 e8                	shr    %cl,%eax
  800f69:	89 f2                	mov    %esi,%edx
  800f6b:	89 f9                	mov    %edi,%ecx
  800f6d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f6f:	09 d0                	or     %edx,%eax
  800f71:	89 f2                	mov    %esi,%edx
  800f73:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f77:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f79:	83 c4 20             	add    $0x20,%esp
  800f7c:	5e                   	pop    %esi
  800f7d:	5f                   	pop    %edi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f80:	85 c9                	test   %ecx,%ecx
  800f82:	75 0b                	jne    800f8f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f84:	b8 01 00 00 00       	mov    $0x1,%eax
  800f89:	31 d2                	xor    %edx,%edx
  800f8b:	f7 f1                	div    %ecx
  800f8d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f8f:	89 f0                	mov    %esi,%eax
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f95:	89 f8                	mov    %edi,%eax
  800f97:	e9 3e ff ff ff       	jmp    800eda <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f9c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f9e:	83 c4 20             	add    $0x20,%esp
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
  800fa5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fa8:	39 f5                	cmp    %esi,%ebp
  800faa:	72 04                	jb     800fb0 <__umoddi3+0x104>
  800fac:	39 f9                	cmp    %edi,%ecx
  800fae:	77 06                	ja     800fb6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	29 cf                	sub    %ecx,%edi
  800fb4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fb6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fb8:	83 c4 20             	add    $0x20,%esp
  800fbb:	5e                   	pop    %esi
  800fbc:	5f                   	pop    %edi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    
  800fbf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fc0:	89 d1                	mov    %edx,%ecx
  800fc2:	89 c5                	mov    %eax,%ebp
  800fc4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fc8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fcc:	eb 8d                	jmp    800f5b <__umoddi3+0xaf>
  800fce:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fd0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fd4:	72 ea                	jb     800fc0 <__umoddi3+0x114>
  800fd6:	89 f1                	mov    %esi,%ecx
  800fd8:	eb 81                	jmp    800f5b <__umoddi3+0xaf>
