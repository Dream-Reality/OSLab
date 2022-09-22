
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	89 54 24 08          	mov    %edx,0x8(%esp)
  800047:	8b 00                	mov    (%eax),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 80 20 80 00 	movl   $0x802080,(%esp)
  800054:	e8 43 01 00 00       	call   80019c <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 9d 0a 00 00       	call   800afb <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 43 0a 00 00       	call   800aa9 <sys_env_destroy>
}
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80006e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800075:	e8 2a 0d 00 00       	call   800da4 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007a:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800081:	00 00 00 
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 20             	sub    $0x20,%esp
  800090:	8b 75 08             	mov    0x8(%ebp),%esi
  800093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800096:	e8 60 0a 00 00       	call   800afb <sys_getenvid>
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a7:	c1 e0 07             	shl    $0x7,%eax
  8000aa:	29 d0                	sub    %edx,%eax
  8000ac:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 f6                	test   %esi,%esi
  8000be:	7e 07                	jle    8000c7 <libmain+0x3f>
		binaryname = argv[0];
  8000c0:	8b 03                	mov    (%ebx),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cb:	89 34 24             	mov    %esi,(%esp)
  8000ce:	e8 95 ff ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8000d3:	e8 08 00 00 00       	call   8000e0 <exit>
}
  8000d8:	83 c4 20             	add    $0x20,%esp
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    
	...

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000e6:	e8 5a 0f 00 00       	call   801045 <close_all>
	sys_env_destroy(0);
  8000eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f2:	e8 b2 09 00 00       	call   800aa9 <sys_env_destroy>
}
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	53                   	push   %ebx
  800100:	83 ec 14             	sub    $0x14,%esp
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800106:	8b 03                	mov    (%ebx),%eax
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010f:	40                   	inc    %eax
  800110:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 19                	jne    800132 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800119:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800120:	00 
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	89 04 24             	mov    %eax,(%esp)
  800127:	e8 40 09 00 00       	call   800a6c <sys_cputs>
		b->idx = 0;
  80012c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800132:	ff 43 04             	incl   0x4(%ebx)
}
  800135:	83 c4 14             	add    $0x14,%esp
  800138:	5b                   	pop    %ebx
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015f:	8b 45 08             	mov    0x8(%ebp),%eax
  800162:	89 44 24 08          	mov    %eax,0x8(%esp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800170:	c7 04 24 fc 00 80 00 	movl   $0x8000fc,(%esp)
  800177:	e8 82 01 00 00       	call   8002fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800182:	89 44 24 04          	mov    %eax,0x4(%esp)
  800186:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 d8 08 00 00       	call   800a6c <sys_cputs>

	return b.cnt;
}
  800194:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ac:	89 04 24             	mov    %eax,(%esp)
  8001af:	e8 87 ff ff ff       	call   80013b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    
	...

008001b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 3c             	sub    $0x3c,%esp
  8001c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001c4:	89 d7                	mov    %edx,%edi
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d8:	85 c0                	test   %eax,%eax
  8001da:	75 08                	jne    8001e4 <printnum+0x2c>
  8001dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e2:	77 57                	ja     80023b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001e8:	4b                   	dec    %ebx
  8001e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001f8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800203:	00 
  800204:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80020d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800211:	e8 0a 1c 00 00       	call   801e20 <__udivdi3>
  800216:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80021a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	89 54 24 04          	mov    %edx,0x4(%esp)
  800225:	89 fa                	mov    %edi,%edx
  800227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022a:	e8 89 ff ff ff       	call   8001b8 <printnum>
  80022f:	eb 0f                	jmp    800240 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800231:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800235:	89 34 24             	mov    %esi,(%esp)
  800238:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023b:	4b                   	dec    %ebx
  80023c:	85 db                	test   %ebx,%ebx
  80023e:	7f f1                	jg     800231 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800240:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800244:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800248:	8b 45 10             	mov    0x10(%ebp),%eax
  80024b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800256:	00 
  800257:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	e8 d7 1c 00 00       	call   801f40 <__umoddi3>
  800269:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026d:	0f be 80 a6 20 80 00 	movsbl 0x8020a6(%eax),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027a:	83 c4 3c             	add    $0x3c,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800285:	83 fa 01             	cmp    $0x1,%edx
  800288:	7e 0e                	jle    800298 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 02                	mov    (%edx),%eax
  800293:	8b 52 04             	mov    0x4(%edx),%edx
  800296:	eb 22                	jmp    8002ba <getuint+0x38>
	else if (lflag)
  800298:	85 d2                	test   %edx,%edx
  80029a:	74 10                	je     8002ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002aa:	eb 0e                	jmp    8002ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ca:	73 08                	jae    8002d4 <sprintputch+0x18>
		*b->buf++ = ch;
  8002cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cf:	88 0a                	mov    %cl,(%edx)
  8002d1:	42                   	inc    %edx
  8002d2:	89 10                	mov    %edx,(%eax)
}
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	e8 02 00 00 00       	call   8002fe <vprintfmt>
	va_end(ap);
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	57                   	push   %edi
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	83 ec 4c             	sub    $0x4c,%esp
  800307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030a:	8b 75 10             	mov    0x10(%ebp),%esi
  80030d:	eb 12                	jmp    800321 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030f:	85 c0                	test   %eax,%eax
  800311:	0f 84 6b 03 00 00    	je     800682 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800317:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800321:	0f b6 06             	movzbl (%esi),%eax
  800324:	46                   	inc    %esi
  800325:	83 f8 25             	cmp    $0x25,%eax
  800328:	75 e5                	jne    80030f <vprintfmt+0x11>
  80032a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80032e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800335:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80033a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800341:	b9 00 00 00 00       	mov    $0x0,%ecx
  800346:	eb 26                	jmp    80036e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80034b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80034f:	eb 1d                	jmp    80036e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800354:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800358:	eb 14                	jmp    80036e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80035d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800364:	eb 08                	jmp    80036e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800366:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800369:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	0f b6 06             	movzbl (%esi),%eax
  800371:	8d 56 01             	lea    0x1(%esi),%edx
  800374:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800377:	8a 16                	mov    (%esi),%dl
  800379:	83 ea 23             	sub    $0x23,%edx
  80037c:	80 fa 55             	cmp    $0x55,%dl
  80037f:	0f 87 e1 02 00 00    	ja     800666 <vprintfmt+0x368>
  800385:	0f b6 d2             	movzbl %dl,%edx
  800388:	ff 24 95 e0 21 80 00 	jmp    *0x8021e0(,%edx,4)
  80038f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800392:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800397:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80039a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80039e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a4:	83 fa 09             	cmp    $0x9,%edx
  8003a7:	77 2a                	ja     8003d3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003aa:	eb eb                	jmp    800397 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8d 50 04             	lea    0x4(%eax),%edx
  8003b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ba:	eb 17                	jmp    8003d3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c0:	78 98                	js     80035a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003c5:	eb a7                	jmp    80036e <vprintfmt+0x70>
  8003c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003d1:	eb 9b                	jmp    80036e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d7:	79 95                	jns    80036e <vprintfmt+0x70>
  8003d9:	eb 8b                	jmp    800366 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003db:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003df:	eb 8d                	jmp    80036e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 50 04             	lea    0x4(%eax),%edx
  8003e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ee:	8b 00                	mov    (%eax),%eax
  8003f0:	89 04 24             	mov    %eax,(%esp)
  8003f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f9:	e9 23 ff ff ff       	jmp    800321 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 50 04             	lea    0x4(%eax),%edx
  800404:	89 55 14             	mov    %edx,0x14(%ebp)
  800407:	8b 00                	mov    (%eax),%eax
  800409:	85 c0                	test   %eax,%eax
  80040b:	79 02                	jns    80040f <vprintfmt+0x111>
  80040d:	f7 d8                	neg    %eax
  80040f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800411:	83 f8 0f             	cmp    $0xf,%eax
  800414:	7f 0b                	jg     800421 <vprintfmt+0x123>
  800416:	8b 04 85 40 23 80 00 	mov    0x802340(,%eax,4),%eax
  80041d:	85 c0                	test   %eax,%eax
  80041f:	75 23                	jne    800444 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800421:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800425:	c7 44 24 08 be 20 80 	movl   $0x8020be,0x8(%esp)
  80042c:	00 
  80042d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	e8 9a fe ff ff       	call   8002d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043f:	e9 dd fe ff ff       	jmp    800321 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800444:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800448:	c7 44 24 08 d9 24 80 	movl   $0x8024d9,0x8(%esp)
  80044f:	00 
  800450:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800454:	8b 55 08             	mov    0x8(%ebp),%edx
  800457:	89 14 24             	mov    %edx,(%esp)
  80045a:	e8 77 fe ff ff       	call   8002d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800462:	e9 ba fe ff ff       	jmp    800321 <vprintfmt+0x23>
  800467:	89 f9                	mov    %edi,%ecx
  800469:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 30                	mov    (%eax),%esi
  80047a:	85 f6                	test   %esi,%esi
  80047c:	75 05                	jne    800483 <vprintfmt+0x185>
				p = "(null)";
  80047e:	be b7 20 80 00       	mov    $0x8020b7,%esi
			if (width > 0 && padc != '-')
  800483:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800487:	0f 8e 84 00 00 00    	jle    800511 <vprintfmt+0x213>
  80048d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800491:	74 7e                	je     800511 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800497:	89 34 24             	mov    %esi,(%esp)
  80049a:	e8 8b 02 00 00       	call   80072a <strnlen>
  80049f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004a2:	29 c2                	sub    %eax,%edx
  8004a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004a7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004ab:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004ae:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004b1:	89 de                	mov    %ebx,%esi
  8004b3:	89 d3                	mov    %edx,%ebx
  8004b5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	eb 0b                	jmp    8004c4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004bd:	89 3c 24             	mov    %edi,(%esp)
  8004c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	4b                   	dec    %ebx
  8004c4:	85 db                	test   %ebx,%ebx
  8004c6:	7f f1                	jg     8004b9 <vprintfmt+0x1bb>
  8004c8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004cb:	89 f3                	mov    %esi,%ebx
  8004cd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	79 05                	jns    8004dc <vprintfmt+0x1de>
  8004d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004df:	29 c2                	sub    %eax,%edx
  8004e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004e4:	eb 2b                	jmp    800511 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ea:	74 18                	je     800504 <vprintfmt+0x206>
  8004ec:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ef:	83 fa 5e             	cmp    $0x5e,%edx
  8004f2:	76 10                	jbe    800504 <vprintfmt+0x206>
					putch('?', putdat);
  8004f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
  800502:	eb 0a                	jmp    80050e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	ff 4d e4             	decl   -0x1c(%ebp)
  800511:	0f be 06             	movsbl (%esi),%eax
  800514:	46                   	inc    %esi
  800515:	85 c0                	test   %eax,%eax
  800517:	74 21                	je     80053a <vprintfmt+0x23c>
  800519:	85 ff                	test   %edi,%edi
  80051b:	78 c9                	js     8004e6 <vprintfmt+0x1e8>
  80051d:	4f                   	dec    %edi
  80051e:	79 c6                	jns    8004e6 <vprintfmt+0x1e8>
  800520:	8b 7d 08             	mov    0x8(%ebp),%edi
  800523:	89 de                	mov    %ebx,%esi
  800525:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800528:	eb 18                	jmp    800542 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800535:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800537:	4b                   	dec    %ebx
  800538:	eb 08                	jmp    800542 <vprintfmt+0x244>
  80053a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053d:	89 de                	mov    %ebx,%esi
  80053f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800542:	85 db                	test   %ebx,%ebx
  800544:	7f e4                	jg     80052a <vprintfmt+0x22c>
  800546:	89 7d 08             	mov    %edi,0x8(%ebp)
  800549:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054e:	e9 ce fd ff ff       	jmp    800321 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800553:	83 f9 01             	cmp    $0x1,%ecx
  800556:	7e 10                	jle    800568 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 08             	lea    0x8(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 30                	mov    (%eax),%esi
  800563:	8b 78 04             	mov    0x4(%eax),%edi
  800566:	eb 26                	jmp    80058e <vprintfmt+0x290>
	else if (lflag)
  800568:	85 c9                	test   %ecx,%ecx
  80056a:	74 12                	je     80057e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 50 04             	lea    0x4(%eax),%edx
  800572:	89 55 14             	mov    %edx,0x14(%ebp)
  800575:	8b 30                	mov    (%eax),%esi
  800577:	89 f7                	mov    %esi,%edi
  800579:	c1 ff 1f             	sar    $0x1f,%edi
  80057c:	eb 10                	jmp    80058e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 30                	mov    (%eax),%esi
  800589:	89 f7                	mov    %esi,%edi
  80058b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058e:	85 ff                	test   %edi,%edi
  800590:	78 0a                	js     80059c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 8c 00 00 00       	jmp    800628 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005aa:	f7 de                	neg    %esi
  8005ac:	83 d7 00             	adc    $0x0,%edi
  8005af:	f7 df                	neg    %edi
			}
			base = 10;
  8005b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b6:	eb 70                	jmp    800628 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b8:	89 ca                	mov    %ecx,%edx
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 c0 fc ff ff       	call   800282 <getuint>
  8005c2:	89 c6                	mov    %eax,%esi
  8005c4:	89 d7                	mov    %edx,%edi
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005cb:	eb 5b                	jmp    800628 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005cd:	89 ca                	mov    %ecx,%edx
  8005cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d2:	e8 ab fc ff ff       	call   800282 <getuint>
  8005d7:	89 c6                	mov    %eax,%esi
  8005d9:	89 d7                	mov    %edx,%edi
			base = 8;
  8005db:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005e0:	eb 46                	jmp    800628 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005ed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800607:	8b 30                	mov    (%eax),%esi
  800609:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800613:	eb 13                	jmp    800628 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800615:	89 ca                	mov    %ecx,%edx
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 63 fc ff ff       	call   800282 <getuint>
  80061f:	89 c6                	mov    %eax,%esi
  800621:	89 d7                	mov    %edx,%edi
			base = 16;
  800623:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800628:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80062c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800633:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800637:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063b:	89 34 24             	mov    %esi,(%esp)
  80063e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800642:	89 da                	mov    %ebx,%edx
  800644:	8b 45 08             	mov    0x8(%ebp),%eax
  800647:	e8 6c fb ff ff       	call   8001b8 <printnum>
			break;
  80064c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064f:	e9 cd fc ff ff       	jmp    800321 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800658:	89 04 24             	mov    %eax,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800661:	e9 bb fc ff ff       	jmp    800321 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800666:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800671:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800674:	eb 01                	jmp    800677 <vprintfmt+0x379>
  800676:	4e                   	dec    %esi
  800677:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80067b:	75 f9                	jne    800676 <vprintfmt+0x378>
  80067d:	e9 9f fc ff ff       	jmp    800321 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800682:	83 c4 4c             	add    $0x4c,%esp
  800685:	5b                   	pop    %ebx
  800686:	5e                   	pop    %esi
  800687:	5f                   	pop    %edi
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 28             	sub    $0x28,%esp
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800699:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	74 30                	je     8006db <vsnprintf+0x51>
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	7e 33                	jle    8006e2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c4:	c7 04 24 bc 02 80 00 	movl   $0x8002bc,(%esp)
  8006cb:	e8 2e fc ff ff       	call   8002fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d9:	eb 0c                	jmp    8006e7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e0:	eb 05                	jmp    8006e7 <vsnprintf+0x5d>
  8006e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	e8 7b ff ff ff       	call   80068a <vsnprintf>
	va_end(ap);

	return rc;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    
  800711:	00 00                	add    %al,(%eax)
	...

00800714 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	eb 01                	jmp    800722 <strlen+0xe>
		n++;
  800721:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800726:	75 f9                	jne    800721 <strlen+0xd>
		n++;
	return n;
}
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800733:	b8 00 00 00 00       	mov    $0x0,%eax
  800738:	eb 01                	jmp    80073b <strnlen+0x11>
		n++;
  80073a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073b:	39 d0                	cmp    %edx,%eax
  80073d:	74 06                	je     800745 <strnlen+0x1b>
  80073f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800743:	75 f5                	jne    80073a <strnlen+0x10>
		n++;
	return n;
}
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	8b 45 08             	mov    0x8(%ebp),%eax
  80074e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800751:	ba 00 00 00 00       	mov    $0x0,%edx
  800756:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800759:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80075c:	42                   	inc    %edx
  80075d:	84 c9                	test   %cl,%cl
  80075f:	75 f5                	jne    800756 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800761:	5b                   	pop    %ebx
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	53                   	push   %ebx
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076e:	89 1c 24             	mov    %ebx,(%esp)
  800771:	e8 9e ff ff ff       	call   800714 <strlen>
	strcpy(dst + len, src);
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
  800779:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077d:	01 d8                	add    %ebx,%eax
  80077f:	89 04 24             	mov    %eax,(%esp)
  800782:	e8 c0 ff ff ff       	call   800747 <strcpy>
	return dst;
}
  800787:	89 d8                	mov    %ebx,%eax
  800789:	83 c4 08             	add    $0x8,%esp
  80078c:	5b                   	pop    %ebx
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a2:	eb 0c                	jmp    8007b0 <strncpy+0x21>
		*dst++ = *src;
  8007a4:	8a 1a                	mov    (%edx),%bl
  8007a6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a9:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007af:	41                   	inc    %ecx
  8007b0:	39 f1                	cmp    %esi,%ecx
  8007b2:	75 f0                	jne    8007a4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5e                   	pop    %esi
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c6:	85 d2                	test   %edx,%edx
  8007c8:	75 0a                	jne    8007d4 <strlcpy+0x1c>
  8007ca:	89 f0                	mov    %esi,%eax
  8007cc:	eb 1a                	jmp    8007e8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ce:	88 18                	mov    %bl,(%eax)
  8007d0:	40                   	inc    %eax
  8007d1:	41                   	inc    %ecx
  8007d2:	eb 02                	jmp    8007d6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007d6:	4a                   	dec    %edx
  8007d7:	74 0a                	je     8007e3 <strlcpy+0x2b>
  8007d9:	8a 19                	mov    (%ecx),%bl
  8007db:	84 db                	test   %bl,%bl
  8007dd:	75 ef                	jne    8007ce <strlcpy+0x16>
  8007df:	89 c2                	mov    %eax,%edx
  8007e1:	eb 02                	jmp    8007e5 <strlcpy+0x2d>
  8007e3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007e5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007e8:	29 f0                	sub    %esi,%eax
}
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f7:	eb 02                	jmp    8007fb <strcmp+0xd>
		p++, q++;
  8007f9:	41                   	inc    %ecx
  8007fa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007fb:	8a 01                	mov    (%ecx),%al
  8007fd:	84 c0                	test   %al,%al
  8007ff:	74 04                	je     800805 <strcmp+0x17>
  800801:	3a 02                	cmp    (%edx),%al
  800803:	74 f4                	je     8007f9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800805:	0f b6 c0             	movzbl %al,%eax
  800808:	0f b6 12             	movzbl (%edx),%edx
  80080b:	29 d0                	sub    %edx,%eax
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800819:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80081c:	eb 03                	jmp    800821 <strncmp+0x12>
		n--, p++, q++;
  80081e:	4a                   	dec    %edx
  80081f:	40                   	inc    %eax
  800820:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800821:	85 d2                	test   %edx,%edx
  800823:	74 14                	je     800839 <strncmp+0x2a>
  800825:	8a 18                	mov    (%eax),%bl
  800827:	84 db                	test   %bl,%bl
  800829:	74 04                	je     80082f <strncmp+0x20>
  80082b:	3a 19                	cmp    (%ecx),%bl
  80082d:	74 ef                	je     80081e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 00             	movzbl (%eax),%eax
  800832:	0f b6 11             	movzbl (%ecx),%edx
  800835:	29 d0                	sub    %edx,%eax
  800837:	eb 05                	jmp    80083e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80084a:	eb 05                	jmp    800851 <strchr+0x10>
		if (*s == c)
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	74 0c                	je     80085c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800850:	40                   	inc    %eax
  800851:	8a 10                	mov    (%eax),%dl
  800853:	84 d2                	test   %dl,%dl
  800855:	75 f5                	jne    80084c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800867:	eb 05                	jmp    80086e <strfind+0x10>
		if (*s == c)
  800869:	38 ca                	cmp    %cl,%dl
  80086b:	74 07                	je     800874 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80086d:	40                   	inc    %eax
  80086e:	8a 10                	mov    (%eax),%dl
  800870:	84 d2                	test   %dl,%dl
  800872:	75 f5                	jne    800869 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	57                   	push   %edi
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800882:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800885:	85 c9                	test   %ecx,%ecx
  800887:	74 30                	je     8008b9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800889:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088f:	75 25                	jne    8008b6 <memset+0x40>
  800891:	f6 c1 03             	test   $0x3,%cl
  800894:	75 20                	jne    8008b6 <memset+0x40>
		c &= 0xFF;
  800896:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800899:	89 d3                	mov    %edx,%ebx
  80089b:	c1 e3 08             	shl    $0x8,%ebx
  80089e:	89 d6                	mov    %edx,%esi
  8008a0:	c1 e6 18             	shl    $0x18,%esi
  8008a3:	89 d0                	mov    %edx,%eax
  8008a5:	c1 e0 10             	shl    $0x10,%eax
  8008a8:	09 f0                	or     %esi,%eax
  8008aa:	09 d0                	or     %edx,%eax
  8008ac:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ae:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b1:	fc                   	cld    
  8008b2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b4:	eb 03                	jmp    8008b9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b6:	fc                   	cld    
  8008b7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b9:	89 f8                	mov    %edi,%eax
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5f                   	pop    %edi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	57                   	push   %edi
  8008c4:	56                   	push   %esi
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ce:	39 c6                	cmp    %eax,%esi
  8008d0:	73 34                	jae    800906 <memmove+0x46>
  8008d2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d5:	39 d0                	cmp    %edx,%eax
  8008d7:	73 2d                	jae    800906 <memmove+0x46>
		s += n;
		d += n;
  8008d9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008dc:	f6 c2 03             	test   $0x3,%dl
  8008df:	75 1b                	jne    8008fc <memmove+0x3c>
  8008e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e7:	75 13                	jne    8008fc <memmove+0x3c>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 0e                	jne    8008fc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ee:	83 ef 04             	sub    $0x4,%edi
  8008f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f7:	fd                   	std    
  8008f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fa:	eb 07                	jmp    800903 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008fc:	4f                   	dec    %edi
  8008fd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800900:	fd                   	std    
  800901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800903:	fc                   	cld    
  800904:	eb 20                	jmp    800926 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800906:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090c:	75 13                	jne    800921 <memmove+0x61>
  80090e:	a8 03                	test   $0x3,%al
  800910:	75 0f                	jne    800921 <memmove+0x61>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 0a                	jne    800921 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800917:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80091a:	89 c7                	mov    %eax,%edi
  80091c:	fc                   	cld    
  80091d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091f:	eb 05                	jmp    800926 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800921:	89 c7                	mov    %eax,%edi
  800923:	fc                   	cld    
  800924:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800930:	8b 45 10             	mov    0x10(%ebp),%eax
  800933:	89 44 24 08          	mov    %eax,0x8(%esp)
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	89 04 24             	mov    %eax,(%esp)
  800944:	e8 77 ff ff ff       	call   8008c0 <memmove>
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 7d 08             	mov    0x8(%ebp),%edi
  800954:	8b 75 0c             	mov    0xc(%ebp),%esi
  800957:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	eb 16                	jmp    800977 <memcmp+0x2c>
		if (*s1 != *s2)
  800961:	8a 04 17             	mov    (%edi,%edx,1),%al
  800964:	42                   	inc    %edx
  800965:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800969:	38 c8                	cmp    %cl,%al
  80096b:	74 0a                	je     800977 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80096d:	0f b6 c0             	movzbl %al,%eax
  800970:	0f b6 c9             	movzbl %cl,%ecx
  800973:	29 c8                	sub    %ecx,%eax
  800975:	eb 09                	jmp    800980 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800977:	39 da                	cmp    %ebx,%edx
  800979:	75 e6                	jne    800961 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5f                   	pop    %edi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098e:	89 c2                	mov    %eax,%edx
  800990:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800993:	eb 05                	jmp    80099a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800995:	38 08                	cmp    %cl,(%eax)
  800997:	74 05                	je     80099e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800999:	40                   	inc    %eax
  80099a:	39 d0                	cmp    %edx,%eax
  80099c:	72 f7                	jb     800995 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ac:	eb 01                	jmp    8009af <strtol+0xf>
		s++;
  8009ae:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009af:	8a 02                	mov    (%edx),%al
  8009b1:	3c 20                	cmp    $0x20,%al
  8009b3:	74 f9                	je     8009ae <strtol+0xe>
  8009b5:	3c 09                	cmp    $0x9,%al
  8009b7:	74 f5                	je     8009ae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b9:	3c 2b                	cmp    $0x2b,%al
  8009bb:	75 08                	jne    8009c5 <strtol+0x25>
		s++;
  8009bd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009be:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c3:	eb 13                	jmp    8009d8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c5:	3c 2d                	cmp    $0x2d,%al
  8009c7:	75 0a                	jne    8009d3 <strtol+0x33>
		s++, neg = 1;
  8009c9:	8d 52 01             	lea    0x1(%edx),%edx
  8009cc:	bf 01 00 00 00       	mov    $0x1,%edi
  8009d1:	eb 05                	jmp    8009d8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d8:	85 db                	test   %ebx,%ebx
  8009da:	74 05                	je     8009e1 <strtol+0x41>
  8009dc:	83 fb 10             	cmp    $0x10,%ebx
  8009df:	75 28                	jne    800a09 <strtol+0x69>
  8009e1:	8a 02                	mov    (%edx),%al
  8009e3:	3c 30                	cmp    $0x30,%al
  8009e5:	75 10                	jne    8009f7 <strtol+0x57>
  8009e7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009eb:	75 0a                	jne    8009f7 <strtol+0x57>
		s += 2, base = 16;
  8009ed:	83 c2 02             	add    $0x2,%edx
  8009f0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f5:	eb 12                	jmp    800a09 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	75 0e                	jne    800a09 <strtol+0x69>
  8009fb:	3c 30                	cmp    $0x30,%al
  8009fd:	75 05                	jne    800a04 <strtol+0x64>
		s++, base = 8;
  8009ff:	42                   	inc    %edx
  800a00:	b3 08                	mov    $0x8,%bl
  800a02:	eb 05                	jmp    800a09 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a04:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a10:	8a 0a                	mov    (%edx),%cl
  800a12:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a15:	80 fb 09             	cmp    $0x9,%bl
  800a18:	77 08                	ja     800a22 <strtol+0x82>
			dig = *s - '0';
  800a1a:	0f be c9             	movsbl %cl,%ecx
  800a1d:	83 e9 30             	sub    $0x30,%ecx
  800a20:	eb 1e                	jmp    800a40 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a22:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a25:	80 fb 19             	cmp    $0x19,%bl
  800a28:	77 08                	ja     800a32 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a2a:	0f be c9             	movsbl %cl,%ecx
  800a2d:	83 e9 57             	sub    $0x57,%ecx
  800a30:	eb 0e                	jmp    800a40 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a32:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a35:	80 fb 19             	cmp    $0x19,%bl
  800a38:	77 12                	ja     800a4c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a3a:	0f be c9             	movsbl %cl,%ecx
  800a3d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a40:	39 f1                	cmp    %esi,%ecx
  800a42:	7d 0c                	jge    800a50 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a44:	42                   	inc    %edx
  800a45:	0f af c6             	imul   %esi,%eax
  800a48:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a4a:	eb c4                	jmp    800a10 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a4c:	89 c1                	mov    %eax,%ecx
  800a4e:	eb 02                	jmp    800a52 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a50:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a56:	74 05                	je     800a5d <strtol+0xbd>
		*endptr = (char *) s;
  800a58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a5d:	85 ff                	test   %edi,%edi
  800a5f:	74 04                	je     800a65 <strtol+0xc5>
  800a61:	89 c8                	mov    %ecx,%eax
  800a63:	f7 d8                	neg    %eax
}
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    
	...

00800a6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	89 c3                	mov    %eax,%ebx
  800a7f:	89 c7                	mov    %eax,%edi
  800a81:	89 c6                	mov    %eax,%esi
  800a83:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a90:	ba 00 00 00 00       	mov    $0x0,%edx
  800a95:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9a:	89 d1                	mov    %edx,%ecx
  800a9c:	89 d3                	mov    %edx,%ebx
  800a9e:	89 d7                	mov    %edx,%edi
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab7:	b8 03 00 00 00       	mov    $0x3,%eax
  800abc:	8b 55 08             	mov    0x8(%ebp),%edx
  800abf:	89 cb                	mov    %ecx,%ebx
  800ac1:	89 cf                	mov    %ecx,%edi
  800ac3:	89 ce                	mov    %ecx,%esi
  800ac5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac7:	85 c0                	test   %eax,%eax
  800ac9:	7e 28                	jle    800af3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800acb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800acf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ad6:	00 
  800ad7:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800ade:	00 
  800adf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ae6:	00 
  800ae7:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800aee:	e8 79 11 00 00       	call   801c6c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af3:	83 c4 2c             	add    $0x2c,%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_yield>:

void
sys_yield(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	be 00 00 00 00       	mov    $0x0,%esi
  800b47:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	89 f7                	mov    %esi,%edi
  800b57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 28                	jle    800b85 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b61:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b68:	00 
  800b69:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800b70:	00 
  800b71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b78:	00 
  800b79:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800b80:	e8 e7 10 00 00       	call   801c6c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b85:	83 c4 2c             	add    $0x2c,%esp
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bac:	85 c0                	test   %eax,%eax
  800bae:	7e 28                	jle    800bd8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bbb:	00 
  800bbc:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800bc3:	00 
  800bc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bcb:	00 
  800bcc:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800bd3:	e8 94 10 00 00       	call   801c6c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd8:	83 c4 2c             	add    $0x2c,%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bee:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	89 df                	mov    %ebx,%edi
  800bfb:	89 de                	mov    %ebx,%esi
  800bfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 28                	jle    800c2b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c07:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800c16:	00 
  800c17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1e:	00 
  800c1f:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800c26:	e8 41 10 00 00       	call   801c6c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2b:	83 c4 2c             	add    $0x2c,%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 08 00 00 00       	mov    $0x8,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 28                	jle    800c7e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c61:	00 
  800c62:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800c69:	00 
  800c6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c71:	00 
  800c72:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800c79:	e8 ee 0f 00 00       	call   801c6c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7e:	83 c4 2c             	add    $0x2c,%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c94:	b8 09 00 00 00       	mov    $0x9,%eax
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 df                	mov    %ebx,%edi
  800ca1:	89 de                	mov    %ebx,%esi
  800ca3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 28                	jle    800cd1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cad:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cb4:	00 
  800cb5:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc4:	00 
  800cc5:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800ccc:	e8 9b 0f 00 00       	call   801c6c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd1:	83 c4 2c             	add    $0x2c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 28                	jle    800d24 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d00:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d07:	00 
  800d08:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800d0f:	00 
  800d10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d17:	00 
  800d18:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800d1f:	e8 48 0f 00 00       	call   801c6c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d24:	83 c4 2c             	add    $0x2c,%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	be 00 00 00 00       	mov    $0x0,%esi
  800d37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	8b 55 08             	mov    0x8(%ebp),%edx
  800d48:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 cb                	mov    %ecx,%ebx
  800d67:	89 cf                	mov    %ecx,%edi
  800d69:	89 ce                	mov    %ecx,%esi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 9f 23 80 	movl   $0x80239f,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 bc 23 80 00 	movl   $0x8023bc,(%esp)
  800d94:	e8 d3 0e 00 00       	call   801c6c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    
  800da1:	00 00                	add    %al,(%eax)
	...

00800da4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	53                   	push   %ebx
  800da8:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dab:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800db2:	75 6f                	jne    800e23 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  800db4:	e8 42 fd ff ff       	call   800afb <sys_getenvid>
  800db9:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800dbb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800dca:	ee 
  800dcb:	89 04 24             	mov    %eax,(%esp)
  800dce:	e8 66 fd ff ff       	call   800b39 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	79 1c                	jns    800df3 <set_pgfault_handler+0x4f>
  800dd7:	c7 44 24 08 cc 23 80 	movl   $0x8023cc,0x8(%esp)
  800dde:	00 
  800ddf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de6:	00 
  800de7:	c7 04 24 25 24 80 00 	movl   $0x802425,(%esp)
  800dee:	e8 79 0e 00 00       	call   801c6c <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  800df3:	c7 44 24 04 34 0e 80 	movl   $0x800e34,0x4(%esp)
  800dfa:	00 
  800dfb:	89 1c 24             	mov    %ebx,(%esp)
  800dfe:	e8 d6 fe ff ff       	call   800cd9 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  800e03:	85 c0                	test   %eax,%eax
  800e05:	79 1c                	jns    800e23 <set_pgfault_handler+0x7f>
  800e07:	c7 44 24 08 f4 23 80 	movl   $0x8023f4,0x8(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800e16:	00 
  800e17:	c7 04 24 25 24 80 00 	movl   $0x802425,(%esp)
  800e1e:	e8 49 0e 00 00       	call   801c6c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
  800e26:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e2b:	83 c4 14             	add    $0x14,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    
  800e31:	00 00                	add    %al,(%eax)
	...

00800e34 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e34:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e35:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e3a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e3c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  800e3f:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  800e43:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  800e48:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  800e4c:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  800e4e:	83 c4 08             	add    $0x8,%esp
	popal
  800e51:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  800e52:	83 c4 04             	add    $0x4,%esp
	popfl
  800e55:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  800e56:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800e59:	c3                   	ret    
	...

00800e5c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	05 00 00 00 30       	add    $0x30000000,%eax
  800e67:	c1 e8 0c             	shr    $0xc,%eax
}
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	89 04 24             	mov    %eax,(%esp)
  800e78:	e8 df ff ff ff       	call   800e5c <fd2num>
  800e7d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e82:	c1 e0 0c             	shl    $0xc,%eax
}
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    

00800e87 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	53                   	push   %ebx
  800e8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e8e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e93:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e95:	89 c2                	mov    %eax,%edx
  800e97:	c1 ea 16             	shr    $0x16,%edx
  800e9a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea1:	f6 c2 01             	test   $0x1,%dl
  800ea4:	74 11                	je     800eb7 <fd_alloc+0x30>
  800ea6:	89 c2                	mov    %eax,%edx
  800ea8:	c1 ea 0c             	shr    $0xc,%edx
  800eab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb2:	f6 c2 01             	test   $0x1,%dl
  800eb5:	75 09                	jne    800ec0 <fd_alloc+0x39>
			*fd_store = fd;
  800eb7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebe:	eb 17                	jmp    800ed7 <fd_alloc+0x50>
  800ec0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ec5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eca:	75 c7                	jne    800e93 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ecc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800ed2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ed7:	5b                   	pop    %ebx
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    

00800eda <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee0:	83 f8 1f             	cmp    $0x1f,%eax
  800ee3:	77 36                	ja     800f1b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ee5:	05 00 00 0d 00       	add    $0xd0000,%eax
  800eea:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eed:	89 c2                	mov    %eax,%edx
  800eef:	c1 ea 16             	shr    $0x16,%edx
  800ef2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef9:	f6 c2 01             	test   $0x1,%dl
  800efc:	74 24                	je     800f22 <fd_lookup+0x48>
  800efe:	89 c2                	mov    %eax,%edx
  800f00:	c1 ea 0c             	shr    $0xc,%edx
  800f03:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0a:	f6 c2 01             	test   $0x1,%dl
  800f0d:	74 1a                	je     800f29 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f12:	89 02                	mov    %eax,(%edx)
	return 0;
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
  800f19:	eb 13                	jmp    800f2e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f20:	eb 0c                	jmp    800f2e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f27:	eb 05                	jmp    800f2e <fd_lookup+0x54>
  800f29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	53                   	push   %ebx
  800f34:	83 ec 14             	sub    $0x14,%esp
  800f37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800f3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f42:	eb 0e                	jmp    800f52 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800f44:	39 08                	cmp    %ecx,(%eax)
  800f46:	75 09                	jne    800f51 <dev_lookup+0x21>
			*dev = devtab[i];
  800f48:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4f:	eb 35                	jmp    800f86 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f51:	42                   	inc    %edx
  800f52:	8b 04 95 b0 24 80 00 	mov    0x8024b0(,%edx,4),%eax
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	75 e7                	jne    800f44 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f5d:	a1 04 40 80 00       	mov    0x804004,%eax
  800f62:	8b 00                	mov    (%eax),%eax
  800f64:	8b 40 48             	mov    0x48(%eax),%eax
  800f67:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6f:	c7 04 24 34 24 80 00 	movl   $0x802434,(%esp)
  800f76:	e8 21 f2 ff ff       	call   80019c <cprintf>
	*dev = 0;
  800f7b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f86:	83 c4 14             	add    $0x14,%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 30             	sub    $0x30,%esp
  800f94:	8b 75 08             	mov    0x8(%ebp),%esi
  800f97:	8a 45 0c             	mov    0xc(%ebp),%al
  800f9a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f9d:	89 34 24             	mov    %esi,(%esp)
  800fa0:	e8 b7 fe ff ff       	call   800e5c <fd2num>
  800fa5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fa8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fac:	89 04 24             	mov    %eax,(%esp)
  800faf:	e8 26 ff ff ff       	call   800eda <fd_lookup>
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	78 05                	js     800fbf <fd_close+0x33>
	    || fd != fd2)
  800fba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fbd:	74 0d                	je     800fcc <fd_close+0x40>
		return (must_exist ? r : 0);
  800fbf:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fc3:	75 46                	jne    80100b <fd_close+0x7f>
  800fc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fca:	eb 3f                	jmp    80100b <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fcc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd3:	8b 06                	mov    (%esi),%eax
  800fd5:	89 04 24             	mov    %eax,(%esp)
  800fd8:	e8 53 ff ff ff       	call   800f30 <dev_lookup>
  800fdd:	89 c3                	mov    %eax,%ebx
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	78 18                	js     800ffb <fd_close+0x6f>
		if (dev->dev_close)
  800fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe6:	8b 40 10             	mov    0x10(%eax),%eax
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	74 09                	je     800ff6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fed:	89 34 24             	mov    %esi,(%esp)
  800ff0:	ff d0                	call   *%eax
  800ff2:	89 c3                	mov    %eax,%ebx
  800ff4:	eb 05                	jmp    800ffb <fd_close+0x6f>
		else
			r = 0;
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ffb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801006:	e8 d5 fb ff ff       	call   800be0 <sys_page_unmap>
	return r;
}
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	83 c4 30             	add    $0x30,%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80101a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	89 04 24             	mov    %eax,(%esp)
  801027:	e8 ae fe ff ff       	call   800eda <fd_lookup>
  80102c:	85 c0                	test   %eax,%eax
  80102e:	78 13                	js     801043 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801030:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801037:	00 
  801038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103b:	89 04 24             	mov    %eax,(%esp)
  80103e:	e8 49 ff ff ff       	call   800f8c <fd_close>
}
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <close_all>:

void
close_all(void)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	53                   	push   %ebx
  801049:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80104c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801051:	89 1c 24             	mov    %ebx,(%esp)
  801054:	e8 bb ff ff ff       	call   801014 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801059:	43                   	inc    %ebx
  80105a:	83 fb 20             	cmp    $0x20,%ebx
  80105d:	75 f2                	jne    801051 <close_all+0xc>
		close(i);
}
  80105f:	83 c4 14             	add    $0x14,%esp
  801062:	5b                   	pop    %ebx
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	57                   	push   %edi
  801069:	56                   	push   %esi
  80106a:	53                   	push   %ebx
  80106b:	83 ec 4c             	sub    $0x4c,%esp
  80106e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801071:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801074:	89 44 24 04          	mov    %eax,0x4(%esp)
  801078:	8b 45 08             	mov    0x8(%ebp),%eax
  80107b:	89 04 24             	mov    %eax,(%esp)
  80107e:	e8 57 fe ff ff       	call   800eda <fd_lookup>
  801083:	89 c3                	mov    %eax,%ebx
  801085:	85 c0                	test   %eax,%eax
  801087:	0f 88 e1 00 00 00    	js     80116e <dup+0x109>
		return r;
	close(newfdnum);
  80108d:	89 3c 24             	mov    %edi,(%esp)
  801090:	e8 7f ff ff ff       	call   801014 <close>

	newfd = INDEX2FD(newfdnum);
  801095:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80109b:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80109e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a1:	89 04 24             	mov    %eax,(%esp)
  8010a4:	e8 c3 fd ff ff       	call   800e6c <fd2data>
  8010a9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010ab:	89 34 24             	mov    %esi,(%esp)
  8010ae:	e8 b9 fd ff ff       	call   800e6c <fd2data>
  8010b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010b6:	89 d8                	mov    %ebx,%eax
  8010b8:	c1 e8 16             	shr    $0x16,%eax
  8010bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c2:	a8 01                	test   $0x1,%al
  8010c4:	74 46                	je     80110c <dup+0xa7>
  8010c6:	89 d8                	mov    %ebx,%eax
  8010c8:	c1 e8 0c             	shr    $0xc,%eax
  8010cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d2:	f6 c2 01             	test   $0x1,%dl
  8010d5:	74 35                	je     80110c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010de:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010f5:	00 
  8010f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801101:	e8 87 fa ff ff       	call   800b8d <sys_page_map>
  801106:	89 c3                	mov    %eax,%ebx
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 3b                	js     801147 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80110c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110f:	89 c2                	mov    %eax,%edx
  801111:	c1 ea 0c             	shr    $0xc,%edx
  801114:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801121:	89 54 24 10          	mov    %edx,0x10(%esp)
  801125:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801129:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801130:	00 
  801131:	89 44 24 04          	mov    %eax,0x4(%esp)
  801135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80113c:	e8 4c fa ff ff       	call   800b8d <sys_page_map>
  801141:	89 c3                	mov    %eax,%ebx
  801143:	85 c0                	test   %eax,%eax
  801145:	79 25                	jns    80116c <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801147:	89 74 24 04          	mov    %esi,0x4(%esp)
  80114b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801152:	e8 89 fa ff ff       	call   800be0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801157:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80115a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801165:	e8 76 fa ff ff       	call   800be0 <sys_page_unmap>
	return r;
  80116a:	eb 02                	jmp    80116e <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80116c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80116e:	89 d8                	mov    %ebx,%eax
  801170:	83 c4 4c             	add    $0x4c,%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	53                   	push   %ebx
  80117c:	83 ec 24             	sub    $0x24,%esp
  80117f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801182:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801185:	89 44 24 04          	mov    %eax,0x4(%esp)
  801189:	89 1c 24             	mov    %ebx,(%esp)
  80118c:	e8 49 fd ff ff       	call   800eda <fd_lookup>
  801191:	85 c0                	test   %eax,%eax
  801193:	78 6f                	js     801204 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119f:	8b 00                	mov    (%eax),%eax
  8011a1:	89 04 24             	mov    %eax,(%esp)
  8011a4:	e8 87 fd ff ff       	call   800f30 <dev_lookup>
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	78 57                	js     801204 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b0:	8b 50 08             	mov    0x8(%eax),%edx
  8011b3:	83 e2 03             	and    $0x3,%edx
  8011b6:	83 fa 01             	cmp    $0x1,%edx
  8011b9:	75 25                	jne    8011e0 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c0:	8b 00                	mov    (%eax),%eax
  8011c2:	8b 40 48             	mov    0x48(%eax),%eax
  8011c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cd:	c7 04 24 75 24 80 00 	movl   $0x802475,(%esp)
  8011d4:	e8 c3 ef ff ff       	call   80019c <cprintf>
		return -E_INVAL;
  8011d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011de:	eb 24                	jmp    801204 <read+0x8c>
	}
	if (!dev->dev_read)
  8011e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e3:	8b 52 08             	mov    0x8(%edx),%edx
  8011e6:	85 d2                	test   %edx,%edx
  8011e8:	74 15                	je     8011ff <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011f8:	89 04 24             	mov    %eax,(%esp)
  8011fb:	ff d2                	call   *%edx
  8011fd:	eb 05                	jmp    801204 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801204:	83 c4 24             	add    $0x24,%esp
  801207:	5b                   	pop    %ebx
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	57                   	push   %edi
  80120e:	56                   	push   %esi
  80120f:	53                   	push   %ebx
  801210:	83 ec 1c             	sub    $0x1c,%esp
  801213:	8b 7d 08             	mov    0x8(%ebp),%edi
  801216:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121e:	eb 23                	jmp    801243 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801220:	89 f0                	mov    %esi,%eax
  801222:	29 d8                	sub    %ebx,%eax
  801224:	89 44 24 08          	mov    %eax,0x8(%esp)
  801228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122b:	01 d8                	add    %ebx,%eax
  80122d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801231:	89 3c 24             	mov    %edi,(%esp)
  801234:	e8 3f ff ff ff       	call   801178 <read>
		if (m < 0)
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 10                	js     80124d <readn+0x43>
			return m;
		if (m == 0)
  80123d:	85 c0                	test   %eax,%eax
  80123f:	74 0a                	je     80124b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801241:	01 c3                	add    %eax,%ebx
  801243:	39 f3                	cmp    %esi,%ebx
  801245:	72 d9                	jb     801220 <readn+0x16>
  801247:	89 d8                	mov    %ebx,%eax
  801249:	eb 02                	jmp    80124d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80124b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80124d:	83 c4 1c             	add    $0x1c,%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	53                   	push   %ebx
  801259:	83 ec 24             	sub    $0x24,%esp
  80125c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	89 1c 24             	mov    %ebx,(%esp)
  801269:	e8 6c fc ff ff       	call   800eda <fd_lookup>
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 6a                	js     8012dc <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801272:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801275:	89 44 24 04          	mov    %eax,0x4(%esp)
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	8b 00                	mov    (%eax),%eax
  80127e:	89 04 24             	mov    %eax,(%esp)
  801281:	e8 aa fc ff ff       	call   800f30 <dev_lookup>
  801286:	85 c0                	test   %eax,%eax
  801288:	78 52                	js     8012dc <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801291:	75 25                	jne    8012b8 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801293:	a1 04 40 80 00       	mov    0x804004,%eax
  801298:	8b 00                	mov    (%eax),%eax
  80129a:	8b 40 48             	mov    0x48(%eax),%eax
  80129d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a5:	c7 04 24 91 24 80 00 	movl   $0x802491,(%esp)
  8012ac:	e8 eb ee ff ff       	call   80019c <cprintf>
		return -E_INVAL;
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b6:	eb 24                	jmp    8012dc <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bb:	8b 52 0c             	mov    0xc(%edx),%edx
  8012be:	85 d2                	test   %edx,%edx
  8012c0:	74 15                	je     8012d7 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	ff d2                	call   *%edx
  8012d5:	eb 05                	jmp    8012dc <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012dc:	83 c4 24             	add    $0x24,%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 e0 fb ff ff       	call   800eda <fd_lookup>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 0e                	js     80130c <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801301:	8b 55 0c             	mov    0xc(%ebp),%edx
  801304:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801307:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    

0080130e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	53                   	push   %ebx
  801312:	83 ec 24             	sub    $0x24,%esp
  801315:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801318:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131f:	89 1c 24             	mov    %ebx,(%esp)
  801322:	e8 b3 fb ff ff       	call   800eda <fd_lookup>
  801327:	85 c0                	test   %eax,%eax
  801329:	78 63                	js     80138e <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801332:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801335:	8b 00                	mov    (%eax),%eax
  801337:	89 04 24             	mov    %eax,(%esp)
  80133a:	e8 f1 fb ff ff       	call   800f30 <dev_lookup>
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 4b                	js     80138e <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801346:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80134a:	75 25                	jne    801371 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80134c:	a1 04 40 80 00       	mov    0x804004,%eax
  801351:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801353:	8b 40 48             	mov    0x48(%eax),%eax
  801356:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80135a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135e:	c7 04 24 54 24 80 00 	movl   $0x802454,(%esp)
  801365:	e8 32 ee ff ff       	call   80019c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80136a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136f:	eb 1d                	jmp    80138e <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801371:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801374:	8b 52 18             	mov    0x18(%edx),%edx
  801377:	85 d2                	test   %edx,%edx
  801379:	74 0e                	je     801389 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80137b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801382:	89 04 24             	mov    %eax,(%esp)
  801385:	ff d2                	call   *%edx
  801387:	eb 05                	jmp    80138e <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801389:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80138e:	83 c4 24             	add    $0x24,%esp
  801391:	5b                   	pop    %ebx
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	53                   	push   %ebx
  801398:	83 ec 24             	sub    $0x24,%esp
  80139b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a8:	89 04 24             	mov    %eax,(%esp)
  8013ab:	e8 2a fb ff ff       	call   800eda <fd_lookup>
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 52                	js     801406 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013be:	8b 00                	mov    (%eax),%eax
  8013c0:	89 04 24             	mov    %eax,(%esp)
  8013c3:	e8 68 fb ff ff       	call   800f30 <dev_lookup>
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 3a                	js     801406 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013d3:	74 2c                	je     801401 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013df:	00 00 00 
	stat->st_isdir = 0;
  8013e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e9:	00 00 00 
	stat->st_dev = dev;
  8013ec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013f9:	89 14 24             	mov    %edx,(%esp)
  8013fc:	ff 50 14             	call   *0x14(%eax)
  8013ff:	eb 05                	jmp    801406 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801401:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801406:	83 c4 24             	add    $0x24,%esp
  801409:	5b                   	pop    %ebx
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801414:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80141b:	00 
  80141c:	8b 45 08             	mov    0x8(%ebp),%eax
  80141f:	89 04 24             	mov    %eax,(%esp)
  801422:	e8 88 02 00 00       	call   8016af <open>
  801427:	89 c3                	mov    %eax,%ebx
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 1b                	js     801448 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80142d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801430:	89 44 24 04          	mov    %eax,0x4(%esp)
  801434:	89 1c 24             	mov    %ebx,(%esp)
  801437:	e8 58 ff ff ff       	call   801394 <fstat>
  80143c:	89 c6                	mov    %eax,%esi
	close(fd);
  80143e:	89 1c 24             	mov    %ebx,(%esp)
  801441:	e8 ce fb ff ff       	call   801014 <close>
	return r;
  801446:	89 f3                	mov    %esi,%ebx
}
  801448:	89 d8                	mov    %ebx,%eax
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	5b                   	pop    %ebx
  80144e:	5e                   	pop    %esi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    
  801451:	00 00                	add    %al,(%eax)
	...

00801454 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	56                   	push   %esi
  801458:	53                   	push   %ebx
  801459:	83 ec 10             	sub    $0x10,%esp
  80145c:	89 c3                	mov    %eax,%ebx
  80145e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801460:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801467:	75 11                	jne    80147a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801469:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801470:	e8 22 09 00 00       	call   801d97 <ipc_find_env>
  801475:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80147a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801481:	00 
  801482:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801489:	00 
  80148a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80148e:	a1 00 40 80 00       	mov    0x804000,%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 96 08 00 00       	call   801d31 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  80149b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014a2:	00 
  8014a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ae:	e8 11 08 00 00       	call   801cc4 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    

008014ba <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ce:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d8:	b8 02 00 00 00       	mov    $0x2,%eax
  8014dd:	e8 72 ff ff ff       	call   801454 <fsipc>
}
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ff:	e8 50 ff ff ff       	call   801454 <fsipc>
}
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	53                   	push   %ebx
  80150a:	83 ec 14             	sub    $0x14,%esp
  80150d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801510:	8b 45 08             	mov    0x8(%ebp),%eax
  801513:	8b 40 0c             	mov    0xc(%eax),%eax
  801516:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80151b:	ba 00 00 00 00       	mov    $0x0,%edx
  801520:	b8 05 00 00 00       	mov    $0x5,%eax
  801525:	e8 2a ff ff ff       	call   801454 <fsipc>
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 2b                	js     801559 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80152e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801535:	00 
  801536:	89 1c 24             	mov    %ebx,(%esp)
  801539:	e8 09 f2 ff ff       	call   800747 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80153e:	a1 80 50 80 00       	mov    0x805080,%eax
  801543:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801549:	a1 84 50 80 00       	mov    0x805084,%eax
  80154e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801554:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801559:	83 c4 14             	add    $0x14,%esp
  80155c:	5b                   	pop    %ebx
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    

0080155f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	53                   	push   %ebx
  801563:	83 ec 14             	sub    $0x14,%esp
  801566:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801569:	8b 45 08             	mov    0x8(%ebp),%eax
  80156c:	8b 40 0c             	mov    0xc(%eax),%eax
  80156f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801574:	89 d8                	mov    %ebx,%eax
  801576:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  80157c:	76 05                	jbe    801583 <devfile_write+0x24>
  80157e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801583:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801588:	89 44 24 08          	mov    %eax,0x8(%esp)
  80158c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801593:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80159a:	e8 8b f3 ff ff       	call   80092a <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  80159f:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8015a9:	e8 a6 fe ff ff       	call   801454 <fsipc>
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 53                	js     801605 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  8015b2:	39 c3                	cmp    %eax,%ebx
  8015b4:	73 24                	jae    8015da <devfile_write+0x7b>
  8015b6:	c7 44 24 0c c0 24 80 	movl   $0x8024c0,0xc(%esp)
  8015bd:	00 
  8015be:	c7 44 24 08 c7 24 80 	movl   $0x8024c7,0x8(%esp)
  8015c5:	00 
  8015c6:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8015cd:	00 
  8015ce:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  8015d5:	e8 92 06 00 00       	call   801c6c <_panic>
	assert(r <= PGSIZE);
  8015da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015df:	7e 24                	jle    801605 <devfile_write+0xa6>
  8015e1:	c7 44 24 0c e7 24 80 	movl   $0x8024e7,0xc(%esp)
  8015e8:	00 
  8015e9:	c7 44 24 08 c7 24 80 	movl   $0x8024c7,0x8(%esp)
  8015f0:	00 
  8015f1:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  8015f8:	00 
  8015f9:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  801600:	e8 67 06 00 00       	call   801c6c <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801605:	83 c4 14             	add    $0x14,%esp
  801608:	5b                   	pop    %ebx
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	56                   	push   %esi
  80160f:	53                   	push   %ebx
  801610:	83 ec 10             	sub    $0x10,%esp
  801613:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801616:	8b 45 08             	mov    0x8(%ebp),%eax
  801619:	8b 40 0c             	mov    0xc(%eax),%eax
  80161c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801621:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801627:	ba 00 00 00 00       	mov    $0x0,%edx
  80162c:	b8 03 00 00 00       	mov    $0x3,%eax
  801631:	e8 1e fe ff ff       	call   801454 <fsipc>
  801636:	89 c3                	mov    %eax,%ebx
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 6a                	js     8016a6 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  80163c:	39 c6                	cmp    %eax,%esi
  80163e:	73 24                	jae    801664 <devfile_read+0x59>
  801640:	c7 44 24 0c c0 24 80 	movl   $0x8024c0,0xc(%esp)
  801647:	00 
  801648:	c7 44 24 08 c7 24 80 	movl   $0x8024c7,0x8(%esp)
  80164f:	00 
  801650:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801657:	00 
  801658:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  80165f:	e8 08 06 00 00       	call   801c6c <_panic>
	assert(r <= PGSIZE);
  801664:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801669:	7e 24                	jle    80168f <devfile_read+0x84>
  80166b:	c7 44 24 0c e7 24 80 	movl   $0x8024e7,0xc(%esp)
  801672:	00 
  801673:	c7 44 24 08 c7 24 80 	movl   $0x8024c7,0x8(%esp)
  80167a:	00 
  80167b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801682:	00 
  801683:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  80168a:	e8 dd 05 00 00       	call   801c6c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80168f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801693:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80169a:	00 
  80169b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169e:	89 04 24             	mov    %eax,(%esp)
  8016a1:	e8 1a f2 ff ff       	call   8008c0 <memmove>
	return r;
}
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 20             	sub    $0x20,%esp
  8016b7:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016ba:	89 34 24             	mov    %esi,(%esp)
  8016bd:	e8 52 f0 ff ff       	call   800714 <strlen>
  8016c2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016c7:	7f 60                	jg     801729 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cc:	89 04 24             	mov    %eax,(%esp)
  8016cf:	e8 b3 f7 ff ff       	call   800e87 <fd_alloc>
  8016d4:	89 c3                	mov    %eax,%ebx
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 54                	js     80172e <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016de:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016e5:	e8 5d f0 ff ff       	call   800747 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ed:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8016fa:	e8 55 fd ff ff       	call   801454 <fsipc>
  8016ff:	89 c3                	mov    %eax,%ebx
  801701:	85 c0                	test   %eax,%eax
  801703:	79 15                	jns    80171a <open+0x6b>
		fd_close(fd, 0);
  801705:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80170c:	00 
  80170d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801710:	89 04 24             	mov    %eax,(%esp)
  801713:	e8 74 f8 ff ff       	call   800f8c <fd_close>
		return r;
  801718:	eb 14                	jmp    80172e <open+0x7f>
	}

	return fd2num(fd);
  80171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171d:	89 04 24             	mov    %eax,(%esp)
  801720:	e8 37 f7 ff ff       	call   800e5c <fd2num>
  801725:	89 c3                	mov    %eax,%ebx
  801727:	eb 05                	jmp    80172e <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801729:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80172e:	89 d8                	mov    %ebx,%eax
  801730:	83 c4 20             	add    $0x20,%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80173d:	ba 00 00 00 00       	mov    $0x0,%edx
  801742:	b8 08 00 00 00       	mov    $0x8,%eax
  801747:	e8 08 fd ff ff       	call   801454 <fsipc>
}
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    
	...

00801750 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	56                   	push   %esi
  801754:	53                   	push   %ebx
  801755:	83 ec 10             	sub    $0x10,%esp
  801758:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	89 04 24             	mov    %eax,(%esp)
  801761:	e8 06 f7 ff ff       	call   800e6c <fd2data>
  801766:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801768:	c7 44 24 04 f3 24 80 	movl   $0x8024f3,0x4(%esp)
  80176f:	00 
  801770:	89 34 24             	mov    %esi,(%esp)
  801773:	e8 cf ef ff ff       	call   800747 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801778:	8b 43 04             	mov    0x4(%ebx),%eax
  80177b:	2b 03                	sub    (%ebx),%eax
  80177d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801783:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80178a:	00 00 00 
	stat->st_dev = &devpipe;
  80178d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801794:	30 80 00 
	return 0;
}
  801797:	b8 00 00 00 00       	mov    $0x0,%eax
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 14             	sub    $0x14,%esp
  8017aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b8:	e8 23 f4 ff ff       	call   800be0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017bd:	89 1c 24             	mov    %ebx,(%esp)
  8017c0:	e8 a7 f6 ff ff       	call   800e6c <fd2data>
  8017c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d0:	e8 0b f4 ff ff       	call   800be0 <sys_page_unmap>
}
  8017d5:	83 c4 14             	add    $0x14,%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	57                   	push   %edi
  8017df:	56                   	push   %esi
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 2c             	sub    $0x2c,%esp
  8017e4:	89 c7                	mov    %eax,%edi
  8017e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ee:	8b 00                	mov    (%eax),%eax
  8017f0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017f3:	89 3c 24             	mov    %edi,(%esp)
  8017f6:	e8 e1 05 00 00       	call   801ddc <pageref>
  8017fb:	89 c6                	mov    %eax,%esi
  8017fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801800:	89 04 24             	mov    %eax,(%esp)
  801803:	e8 d4 05 00 00       	call   801ddc <pageref>
  801808:	39 c6                	cmp    %eax,%esi
  80180a:	0f 94 c0             	sete   %al
  80180d:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801810:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801816:	8b 12                	mov    (%edx),%edx
  801818:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80181b:	39 cb                	cmp    %ecx,%ebx
  80181d:	75 08                	jne    801827 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80181f:	83 c4 2c             	add    $0x2c,%esp
  801822:	5b                   	pop    %ebx
  801823:	5e                   	pop    %esi
  801824:	5f                   	pop    %edi
  801825:	5d                   	pop    %ebp
  801826:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801827:	83 f8 01             	cmp    $0x1,%eax
  80182a:	75 bd                	jne    8017e9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80182c:	8b 42 58             	mov    0x58(%edx),%eax
  80182f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801836:	00 
  801837:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80183f:	c7 04 24 fa 24 80 00 	movl   $0x8024fa,(%esp)
  801846:	e8 51 e9 ff ff       	call   80019c <cprintf>
  80184b:	eb 9c                	jmp    8017e9 <_pipeisclosed+0xe>

0080184d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	57                   	push   %edi
  801851:	56                   	push   %esi
  801852:	53                   	push   %ebx
  801853:	83 ec 1c             	sub    $0x1c,%esp
  801856:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801859:	89 34 24             	mov    %esi,(%esp)
  80185c:	e8 0b f6 ff ff       	call   800e6c <fd2data>
  801861:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801863:	bf 00 00 00 00       	mov    $0x0,%edi
  801868:	eb 3c                	jmp    8018a6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80186a:	89 da                	mov    %ebx,%edx
  80186c:	89 f0                	mov    %esi,%eax
  80186e:	e8 68 ff ff ff       	call   8017db <_pipeisclosed>
  801873:	85 c0                	test   %eax,%eax
  801875:	75 38                	jne    8018af <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801877:	e8 9e f2 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80187c:	8b 43 04             	mov    0x4(%ebx),%eax
  80187f:	8b 13                	mov    (%ebx),%edx
  801881:	83 c2 20             	add    $0x20,%edx
  801884:	39 d0                	cmp    %edx,%eax
  801886:	73 e2                	jae    80186a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80188b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80188e:	89 c2                	mov    %eax,%edx
  801890:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801896:	79 05                	jns    80189d <devpipe_write+0x50>
  801898:	4a                   	dec    %edx
  801899:	83 ca e0             	or     $0xffffffe0,%edx
  80189c:	42                   	inc    %edx
  80189d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018a1:	40                   	inc    %eax
  8018a2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018a5:	47                   	inc    %edi
  8018a6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018a9:	75 d1                	jne    80187c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018ab:	89 f8                	mov    %edi,%eax
  8018ad:	eb 05                	jmp    8018b4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018af:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018b4:	83 c4 1c             	add    $0x1c,%esp
  8018b7:	5b                   	pop    %ebx
  8018b8:	5e                   	pop    %esi
  8018b9:	5f                   	pop    %edi
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	57                   	push   %edi
  8018c0:	56                   	push   %esi
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 1c             	sub    $0x1c,%esp
  8018c5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018c8:	89 3c 24             	mov    %edi,(%esp)
  8018cb:	e8 9c f5 ff ff       	call   800e6c <fd2data>
  8018d0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018d2:	be 00 00 00 00       	mov    $0x0,%esi
  8018d7:	eb 3a                	jmp    801913 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018d9:	85 f6                	test   %esi,%esi
  8018db:	74 04                	je     8018e1 <devpipe_read+0x25>
				return i;
  8018dd:	89 f0                	mov    %esi,%eax
  8018df:	eb 40                	jmp    801921 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018e1:	89 da                	mov    %ebx,%edx
  8018e3:	89 f8                	mov    %edi,%eax
  8018e5:	e8 f1 fe ff ff       	call   8017db <_pipeisclosed>
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	75 2e                	jne    80191c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018ee:	e8 27 f2 ff ff       	call   800b1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018f3:	8b 03                	mov    (%ebx),%eax
  8018f5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018f8:	74 df                	je     8018d9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018fa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018ff:	79 05                	jns    801906 <devpipe_read+0x4a>
  801901:	48                   	dec    %eax
  801902:	83 c8 e0             	or     $0xffffffe0,%eax
  801905:	40                   	inc    %eax
  801906:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80190a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801910:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801912:	46                   	inc    %esi
  801913:	3b 75 10             	cmp    0x10(%ebp),%esi
  801916:	75 db                	jne    8018f3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801918:	89 f0                	mov    %esi,%eax
  80191a:	eb 05                	jmp    801921 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801921:	83 c4 1c             	add    $0x1c,%esp
  801924:	5b                   	pop    %ebx
  801925:	5e                   	pop    %esi
  801926:	5f                   	pop    %edi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	57                   	push   %edi
  80192d:	56                   	push   %esi
  80192e:	53                   	push   %ebx
  80192f:	83 ec 3c             	sub    $0x3c,%esp
  801932:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801935:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801938:	89 04 24             	mov    %eax,(%esp)
  80193b:	e8 47 f5 ff ff       	call   800e87 <fd_alloc>
  801940:	89 c3                	mov    %eax,%ebx
  801942:	85 c0                	test   %eax,%eax
  801944:	0f 88 45 01 00 00    	js     801a8f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80194a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801951:	00 
  801952:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801955:	89 44 24 04          	mov    %eax,0x4(%esp)
  801959:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801960:	e8 d4 f1 ff ff       	call   800b39 <sys_page_alloc>
  801965:	89 c3                	mov    %eax,%ebx
  801967:	85 c0                	test   %eax,%eax
  801969:	0f 88 20 01 00 00    	js     801a8f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80196f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801972:	89 04 24             	mov    %eax,(%esp)
  801975:	e8 0d f5 ff ff       	call   800e87 <fd_alloc>
  80197a:	89 c3                	mov    %eax,%ebx
  80197c:	85 c0                	test   %eax,%eax
  80197e:	0f 88 f8 00 00 00    	js     801a7c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801984:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80198b:	00 
  80198c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80198f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801993:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80199a:	e8 9a f1 ff ff       	call   800b39 <sys_page_alloc>
  80199f:	89 c3                	mov    %eax,%ebx
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	0f 88 d3 00 00 00    	js     801a7c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ac:	89 04 24             	mov    %eax,(%esp)
  8019af:	e8 b8 f4 ff ff       	call   800e6c <fd2data>
  8019b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019bd:	00 
  8019be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c9:	e8 6b f1 ff ff       	call   800b39 <sys_page_alloc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	0f 88 91 00 00 00    	js     801a69 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019db:	89 04 24             	mov    %eax,(%esp)
  8019de:	e8 89 f4 ff ff       	call   800e6c <fd2data>
  8019e3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8019ea:	00 
  8019eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f6:	00 
  8019f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a02:	e8 86 f1 ff ff       	call   800b8d <sys_page_map>
  801a07:	89 c3                	mov    %eax,%ebx
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	78 4c                	js     801a59 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a16:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a1b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a2b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a30:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a3a:	89 04 24             	mov    %eax,(%esp)
  801a3d:	e8 1a f4 ff ff       	call   800e5c <fd2num>
  801a42:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a44:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a47:	89 04 24             	mov    %eax,(%esp)
  801a4a:	e8 0d f4 ff ff       	call   800e5c <fd2num>
  801a4f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a52:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a57:	eb 36                	jmp    801a8f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801a59:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a64:	e8 77 f1 ff ff       	call   800be0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801a69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a77:	e8 64 f1 ff ff       	call   800be0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801a7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a8a:	e8 51 f1 ff ff       	call   800be0 <sys_page_unmap>
    err:
	return r;
}
  801a8f:	89 d8                	mov    %ebx,%eax
  801a91:	83 c4 3c             	add    $0x3c,%esp
  801a94:	5b                   	pop    %ebx
  801a95:	5e                   	pop    %esi
  801a96:	5f                   	pop    %edi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	89 04 24             	mov    %eax,(%esp)
  801aac:	e8 29 f4 ff ff       	call   800eda <fd_lookup>
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 15                	js     801aca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab8:	89 04 24             	mov    %eax,(%esp)
  801abb:	e8 ac f3 ff ff       	call   800e6c <fd2data>
	return _pipeisclosed(fd, p);
  801ac0:	89 c2                	mov    %eax,%edx
  801ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac5:	e8 11 fd ff ff       	call   8017db <_pipeisclosed>
}
  801aca:	c9                   	leave  
  801acb:	c3                   	ret    

00801acc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801adc:	c7 44 24 04 12 25 80 	movl   $0x802512,0x4(%esp)
  801ae3:	00 
  801ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae7:	89 04 24             	mov    %eax,(%esp)
  801aea:	e8 58 ec ff ff       	call   800747 <strcpy>
	return 0;
}
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	57                   	push   %edi
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b02:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b07:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b0d:	eb 30                	jmp    801b3f <devcons_write+0x49>
		m = n - tot;
  801b0f:	8b 75 10             	mov    0x10(%ebp),%esi
  801b12:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801b14:	83 fe 7f             	cmp    $0x7f,%esi
  801b17:	76 05                	jbe    801b1e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801b19:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b1e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b22:	03 45 0c             	add    0xc(%ebp),%eax
  801b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b29:	89 3c 24             	mov    %edi,(%esp)
  801b2c:	e8 8f ed ff ff       	call   8008c0 <memmove>
		sys_cputs(buf, m);
  801b31:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b35:	89 3c 24             	mov    %edi,(%esp)
  801b38:	e8 2f ef ff ff       	call   800a6c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b3d:	01 f3                	add    %esi,%ebx
  801b3f:	89 d8                	mov    %ebx,%eax
  801b41:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b44:	72 c9                	jb     801b0f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b46:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5f                   	pop    %edi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b5b:	75 07                	jne    801b64 <devcons_read+0x13>
  801b5d:	eb 25                	jmp    801b84 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b5f:	e8 b6 ef ff ff       	call   800b1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b64:	e8 21 ef ff ff       	call   800a8a <sys_cgetc>
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	74 f2                	je     801b5f <devcons_read+0xe>
  801b6d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 1d                	js     801b90 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b73:	83 f8 04             	cmp    $0x4,%eax
  801b76:	74 13                	je     801b8b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7b:	88 10                	mov    %dl,(%eax)
	return 1;
  801b7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b82:	eb 0c                	jmp    801b90 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	eb 05                	jmp    801b90 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b8b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ba5:	00 
  801ba6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ba9:	89 04 24             	mov    %eax,(%esp)
  801bac:	e8 bb ee ff ff       	call   800a6c <sys_cputs>
}
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <getchar>:

int
getchar(void)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bb9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801bc0:	00 
  801bc1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bcf:	e8 a4 f5 ff ff       	call   801178 <read>
	if (r < 0)
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 0f                	js     801be7 <getchar+0x34>
		return r;
	if (r < 1)
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	7e 06                	jle    801be2 <getchar+0x2f>
		return -E_EOF;
	return c;
  801bdc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801be0:	eb 05                	jmp    801be7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801be2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801be7:	c9                   	leave  
  801be8:	c3                   	ret    

00801be9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	89 04 24             	mov    %eax,(%esp)
  801bfc:	e8 d9 f2 ff ff       	call   800eda <fd_lookup>
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 11                	js     801c16 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c08:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c0e:	39 10                	cmp    %edx,(%eax)
  801c10:	0f 94 c0             	sete   %al
  801c13:	0f b6 c0             	movzbl %al,%eax
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <opencons>:

int
opencons(void)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c21:	89 04 24             	mov    %eax,(%esp)
  801c24:	e8 5e f2 ff ff       	call   800e87 <fd_alloc>
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	78 3c                	js     801c69 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c2d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c34:	00 
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c43:	e8 f1 ee ff ff       	call   800b39 <sys_page_alloc>
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	78 1d                	js     801c69 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c4c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c55:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c61:	89 04 24             	mov    %eax,(%esp)
  801c64:	e8 f3 f1 ff ff       	call   800e5c <fd2num>
}
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    
	...

00801c6c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	56                   	push   %esi
  801c70:	53                   	push   %ebx
  801c71:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c74:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c77:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801c7d:	e8 79 ee ff ff       	call   800afb <sys_getenvid>
  801c82:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c85:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c89:	8b 55 08             	mov    0x8(%ebp),%edx
  801c8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c90:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c98:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  801c9f:	e8 f8 e4 ff ff       	call   80019c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ca4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca8:	8b 45 10             	mov    0x10(%ebp),%eax
  801cab:	89 04 24             	mov    %eax,(%esp)
  801cae:	e8 88 e4 ff ff       	call   80013b <vcprintf>
	cprintf("\n");
  801cb3:	c7 04 24 54 25 80 00 	movl   $0x802554,(%esp)
  801cba:	e8 dd e4 ff ff       	call   80019c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cbf:	cc                   	int3   
  801cc0:	eb fd                	jmp    801cbf <_panic+0x53>
	...

00801cc4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 10             	sub    $0x10,%esp
  801ccc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	75 05                	jne    801cde <ipc_recv+0x1a>
  801cd9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801cde:	89 04 24             	mov    %eax,(%esp)
  801ce1:	e8 69 f0 ff ff       	call   800d4f <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	79 16                	jns    801d00 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801cea:	85 db                	test   %ebx,%ebx
  801cec:	74 06                	je     801cf4 <ipc_recv+0x30>
  801cee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801cf4:	85 f6                	test   %esi,%esi
  801cf6:	74 32                	je     801d2a <ipc_recv+0x66>
  801cf8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801cfe:	eb 2a                	jmp    801d2a <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801d00:	85 db                	test   %ebx,%ebx
  801d02:	74 0c                	je     801d10 <ipc_recv+0x4c>
  801d04:	a1 04 40 80 00       	mov    0x804004,%eax
  801d09:	8b 00                	mov    (%eax),%eax
  801d0b:	8b 40 74             	mov    0x74(%eax),%eax
  801d0e:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801d10:	85 f6                	test   %esi,%esi
  801d12:	74 0c                	je     801d20 <ipc_recv+0x5c>
  801d14:	a1 04 40 80 00       	mov    0x804004,%eax
  801d19:	8b 00                	mov    (%eax),%eax
  801d1b:	8b 40 78             	mov    0x78(%eax),%eax
  801d1e:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801d20:	a1 04 40 80 00       	mov    0x804004,%eax
  801d25:	8b 00                	mov    (%eax),%eax
  801d27:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5d                   	pop    %ebp
  801d30:	c3                   	ret    

00801d31 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	57                   	push   %edi
  801d35:	56                   	push   %esi
  801d36:	53                   	push   %ebx
  801d37:	83 ec 1c             	sub    $0x1c,%esp
  801d3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d40:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801d43:	85 db                	test   %ebx,%ebx
  801d45:	75 05                	jne    801d4c <ipc_send+0x1b>
  801d47:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801d4c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d54:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	89 04 24             	mov    %eax,(%esp)
  801d5e:	e8 c9 ef ff ff       	call   800d2c <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801d63:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d66:	75 07                	jne    801d6f <ipc_send+0x3e>
  801d68:	e8 ad ed ff ff       	call   800b1a <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801d6d:	eb dd                	jmp    801d4c <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	79 1c                	jns    801d8f <ipc_send+0x5e>
  801d73:	c7 44 24 08 44 25 80 	movl   $0x802544,0x8(%esp)
  801d7a:	00 
  801d7b:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801d82:	00 
  801d83:	c7 04 24 56 25 80 00 	movl   $0x802556,(%esp)
  801d8a:	e8 dd fe ff ff       	call   801c6c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801d8f:	83 c4 1c             	add    $0x1c,%esp
  801d92:	5b                   	pop    %ebx
  801d93:	5e                   	pop    %esi
  801d94:	5f                   	pop    %edi
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	53                   	push   %ebx
  801d9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801da3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801daa:	89 c2                	mov    %eax,%edx
  801dac:	c1 e2 07             	shl    $0x7,%edx
  801daf:	29 ca                	sub    %ecx,%edx
  801db1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801db7:	8b 52 50             	mov    0x50(%edx),%edx
  801dba:	39 da                	cmp    %ebx,%edx
  801dbc:	75 0f                	jne    801dcd <ipc_find_env+0x36>
			return envs[i].env_id;
  801dbe:	c1 e0 07             	shl    $0x7,%eax
  801dc1:	29 c8                	sub    %ecx,%eax
  801dc3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801dc8:	8b 40 40             	mov    0x40(%eax),%eax
  801dcb:	eb 0c                	jmp    801dd9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801dcd:	40                   	inc    %eax
  801dce:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dd3:	75 ce                	jne    801da3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dd5:	66 b8 00 00          	mov    $0x0,%ax
}
  801dd9:	5b                   	pop    %ebx
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801de2:	89 c2                	mov    %eax,%edx
  801de4:	c1 ea 16             	shr    $0x16,%edx
  801de7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801dee:	f6 c2 01             	test   $0x1,%dl
  801df1:	74 1e                	je     801e11 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801df3:	c1 e8 0c             	shr    $0xc,%eax
  801df6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801dfd:	a8 01                	test   $0x1,%al
  801dff:	74 17                	je     801e18 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e01:	c1 e8 0c             	shr    $0xc,%eax
  801e04:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e0b:	ef 
  801e0c:	0f b7 c0             	movzwl %ax,%eax
  801e0f:	eb 0c                	jmp    801e1d <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e11:	b8 00 00 00 00       	mov    $0x0,%eax
  801e16:	eb 05                	jmp    801e1d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    
	...

00801e20 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801e20:	55                   	push   %ebp
  801e21:	57                   	push   %edi
  801e22:	56                   	push   %esi
  801e23:	83 ec 10             	sub    $0x10,%esp
  801e26:	8b 74 24 20          	mov    0x20(%esp),%esi
  801e2a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e32:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801e36:	89 cd                	mov    %ecx,%ebp
  801e38:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	75 2c                	jne    801e6c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801e40:	39 f9                	cmp    %edi,%ecx
  801e42:	77 68                	ja     801eac <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e44:	85 c9                	test   %ecx,%ecx
  801e46:	75 0b                	jne    801e53 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e48:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4d:	31 d2                	xor    %edx,%edx
  801e4f:	f7 f1                	div    %ecx
  801e51:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	89 f8                	mov    %edi,%eax
  801e57:	f7 f1                	div    %ecx
  801e59:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e5b:	89 f0                	mov    %esi,%eax
  801e5d:	f7 f1                	div    %ecx
  801e5f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e61:	89 f0                	mov    %esi,%eax
  801e63:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e6c:	39 f8                	cmp    %edi,%eax
  801e6e:	77 2c                	ja     801e9c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e70:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801e73:	83 f6 1f             	xor    $0x1f,%esi
  801e76:	75 4c                	jne    801ec4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e78:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e7a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e7f:	72 0a                	jb     801e8b <__udivdi3+0x6b>
  801e81:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e85:	0f 87 ad 00 00 00    	ja     801f38 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e8b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e90:	89 f0                	mov    %esi,%eax
  801e92:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	5e                   	pop    %esi
  801e98:	5f                   	pop    %edi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    
  801e9b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e9c:	31 ff                	xor    %edi,%edi
  801e9e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ea0:	89 f0                	mov    %esi,%eax
  801ea2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	5e                   	pop    %esi
  801ea8:	5f                   	pop    %edi
  801ea9:	5d                   	pop    %ebp
  801eaa:	c3                   	ret    
  801eab:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801eac:	89 fa                	mov    %edi,%edx
  801eae:	89 f0                	mov    %esi,%eax
  801eb0:	f7 f1                	div    %ecx
  801eb2:	89 c6                	mov    %eax,%esi
  801eb4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801eb6:	89 f0                	mov    %esi,%eax
  801eb8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	5e                   	pop    %esi
  801ebe:	5f                   	pop    %edi
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    
  801ec1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ec4:	89 f1                	mov    %esi,%ecx
  801ec6:	d3 e0                	shl    %cl,%eax
  801ec8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ecc:	b8 20 00 00 00       	mov    $0x20,%eax
  801ed1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801ed3:	89 ea                	mov    %ebp,%edx
  801ed5:	88 c1                	mov    %al,%cl
  801ed7:	d3 ea                	shr    %cl,%edx
  801ed9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801edd:	09 ca                	or     %ecx,%edx
  801edf:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801ee3:	89 f1                	mov    %esi,%ecx
  801ee5:	d3 e5                	shl    %cl,%ebp
  801ee7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801eeb:	89 fd                	mov    %edi,%ebp
  801eed:	88 c1                	mov    %al,%cl
  801eef:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801ef1:	89 fa                	mov    %edi,%edx
  801ef3:	89 f1                	mov    %esi,%ecx
  801ef5:	d3 e2                	shl    %cl,%edx
  801ef7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801efb:	88 c1                	mov    %al,%cl
  801efd:	d3 ef                	shr    %cl,%edi
  801eff:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f01:	89 f8                	mov    %edi,%eax
  801f03:	89 ea                	mov    %ebp,%edx
  801f05:	f7 74 24 08          	divl   0x8(%esp)
  801f09:	89 d1                	mov    %edx,%ecx
  801f0b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801f0d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f11:	39 d1                	cmp    %edx,%ecx
  801f13:	72 17                	jb     801f2c <__udivdi3+0x10c>
  801f15:	74 09                	je     801f20 <__udivdi3+0x100>
  801f17:	89 fe                	mov    %edi,%esi
  801f19:	31 ff                	xor    %edi,%edi
  801f1b:	e9 41 ff ff ff       	jmp    801e61 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801f20:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f24:	89 f1                	mov    %esi,%ecx
  801f26:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f28:	39 c2                	cmp    %eax,%edx
  801f2a:	73 eb                	jae    801f17 <__udivdi3+0xf7>
		{
		  q0--;
  801f2c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f2f:	31 ff                	xor    %edi,%edi
  801f31:	e9 2b ff ff ff       	jmp    801e61 <__udivdi3+0x41>
  801f36:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f38:	31 f6                	xor    %esi,%esi
  801f3a:	e9 22 ff ff ff       	jmp    801e61 <__udivdi3+0x41>
	...

00801f40 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	83 ec 20             	sub    $0x20,%esp
  801f46:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f4a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f4e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801f52:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801f56:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f5a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f5e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801f60:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f62:	85 ed                	test   %ebp,%ebp
  801f64:	75 16                	jne    801f7c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801f66:	39 f1                	cmp    %esi,%ecx
  801f68:	0f 86 a6 00 00 00    	jbe    802014 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f6e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f70:	89 d0                	mov    %edx,%eax
  801f72:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f74:	83 c4 20             	add    $0x20,%esp
  801f77:	5e                   	pop    %esi
  801f78:	5f                   	pop    %edi
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    
  801f7b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f7c:	39 f5                	cmp    %esi,%ebp
  801f7e:	0f 87 ac 00 00 00    	ja     802030 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f84:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801f87:	83 f0 1f             	xor    $0x1f,%eax
  801f8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f8e:	0f 84 a8 00 00 00    	je     80203c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f94:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f98:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f9a:	bf 20 00 00 00       	mov    $0x20,%edi
  801f9f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801fa3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fa7:	89 f9                	mov    %edi,%ecx
  801fa9:	d3 e8                	shr    %cl,%eax
  801fab:	09 e8                	or     %ebp,%eax
  801fad:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801fb1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fb5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fb9:	d3 e0                	shl    %cl,%eax
  801fbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fbf:	89 f2                	mov    %esi,%edx
  801fc1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801fc3:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fc7:	d3 e0                	shl    %cl,%eax
  801fc9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fcd:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fd1:	89 f9                	mov    %edi,%ecx
  801fd3:	d3 e8                	shr    %cl,%eax
  801fd5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801fd7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801fd9:	89 f2                	mov    %esi,%edx
  801fdb:	f7 74 24 18          	divl   0x18(%esp)
  801fdf:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801fe1:	f7 64 24 0c          	mull   0xc(%esp)
  801fe5:	89 c5                	mov    %eax,%ebp
  801fe7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fe9:	39 d6                	cmp    %edx,%esi
  801feb:	72 67                	jb     802054 <__umoddi3+0x114>
  801fed:	74 75                	je     802064 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801fef:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801ff3:	29 e8                	sub    %ebp,%eax
  801ff5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ff7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ffb:	d3 e8                	shr    %cl,%eax
  801ffd:	89 f2                	mov    %esi,%edx
  801fff:	89 f9                	mov    %edi,%ecx
  802001:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802003:	09 d0                	or     %edx,%eax
  802005:	89 f2                	mov    %esi,%edx
  802007:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80200b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80200d:	83 c4 20             	add    $0x20,%esp
  802010:	5e                   	pop    %esi
  802011:	5f                   	pop    %edi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802014:	85 c9                	test   %ecx,%ecx
  802016:	75 0b                	jne    802023 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802018:	b8 01 00 00 00       	mov    $0x1,%eax
  80201d:	31 d2                	xor    %edx,%edx
  80201f:	f7 f1                	div    %ecx
  802021:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802023:	89 f0                	mov    %esi,%eax
  802025:	31 d2                	xor    %edx,%edx
  802027:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802029:	89 f8                	mov    %edi,%eax
  80202b:	e9 3e ff ff ff       	jmp    801f6e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802030:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802032:	83 c4 20             	add    $0x20,%esp
  802035:	5e                   	pop    %esi
  802036:	5f                   	pop    %edi
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    
  802039:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80203c:	39 f5                	cmp    %esi,%ebp
  80203e:	72 04                	jb     802044 <__umoddi3+0x104>
  802040:	39 f9                	cmp    %edi,%ecx
  802042:	77 06                	ja     80204a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802044:	89 f2                	mov    %esi,%edx
  802046:	29 cf                	sub    %ecx,%edi
  802048:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80204a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80204c:	83 c4 20             	add    $0x20,%esp
  80204f:	5e                   	pop    %esi
  802050:	5f                   	pop    %edi
  802051:	5d                   	pop    %ebp
  802052:	c3                   	ret    
  802053:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802054:	89 d1                	mov    %edx,%ecx
  802056:	89 c5                	mov    %eax,%ebp
  802058:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80205c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802060:	eb 8d                	jmp    801fef <__umoddi3+0xaf>
  802062:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802064:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802068:	72 ea                	jb     802054 <__umoddi3+0x114>
  80206a:	89 f1                	mov    %esi,%ecx
  80206c:	eb 81                	jmp    801fef <__umoddi3+0xaf>
