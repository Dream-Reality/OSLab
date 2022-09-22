
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 73 00 00 00       	call   8000a4 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 00                	mov    (%eax),%eax
  800042:	8b 40 48             	mov    0x48(%eax),%eax
  800045:	89 44 24 04          	mov    %eax,0x4(%esp)
  800049:	c7 04 24 20 10 80 00 	movl   $0x801020,(%esp)
  800050:	e8 6b 01 00 00       	call   8001c0 <cprintf>
	for (i = 0; i < 5; i++) {
  800055:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  80005a:	e8 df 0a 00 00       	call   800b3e <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005f:	a1 04 20 80 00       	mov    0x802004,%eax
  800064:	8b 00                	mov    (%eax),%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800066:	8b 40 48             	mov    0x48(%eax),%eax
  800069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80006d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800071:	c7 04 24 40 10 80 00 	movl   $0x801040,(%esp)
  800078:	e8 43 01 00 00       	call   8001c0 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  80007d:	43                   	inc    %ebx
  80007e:	83 fb 05             	cmp    $0x5,%ebx
  800081:	75 d7                	jne    80005a <umain+0x26>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800083:	a1 04 20 80 00       	mov    0x802004,%eax
  800088:	8b 00                	mov    (%eax),%eax
  80008a:	8b 40 48             	mov    0x48(%eax),%eax
  80008d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800091:	c7 04 24 6c 10 80 00 	movl   $0x80106c,(%esp)
  800098:	e8 23 01 00 00       	call   8001c0 <cprintf>
}
  80009d:	83 c4 14             	add    $0x14,%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	83 ec 20             	sub    $0x20,%esp
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8000b2:	e8 68 0a 00 00       	call   800b1f <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000c3:	c1 e0 07             	shl    $0x7,%eax
  8000c6:	29 d0                	sub    %edx,%eax
  8000c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000d3:	a3 04 20 80 00       	mov    %eax,0x802004
  8000d8:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  8000dc:	c7 04 24 8b 10 80 00 	movl   $0x80108b,(%esp)
  8000e3:	e8 d8 00 00 00       	call   8001c0 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e8:	85 f6                	test   %esi,%esi
  8000ea:	7e 07                	jle    8000f3 <libmain+0x4f>
		binaryname = argv[0];
  8000ec:	8b 03                	mov    (%ebx),%eax
  8000ee:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f7:	89 34 24             	mov    %esi,(%esp)
  8000fa:	e8 35 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ff:	e8 08 00 00 00       	call   80010c <exit>
}
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    
	...

0080010c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800119:	e8 af 09 00 00       	call   800acd <sys_env_destroy>
}
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 14             	sub    $0x14,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800133:	40                   	inc    %eax
  800134:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 19                	jne    800156 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80013d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800144:	00 
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	89 04 24             	mov    %eax,(%esp)
  80014b:	e8 40 09 00 00       	call   800a90 <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800156:	ff 43 04             	incl   0x4(%ebx)
}
  800159:	83 c4 14             	add    $0x14,%esp
  80015c:	5b                   	pop    %ebx
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800168:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016f:	00 00 00 
	b.cnt = 0;
  800172:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800179:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800183:	8b 45 08             	mov    0x8(%ebp),%eax
  800186:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 20 01 80 00 	movl   $0x800120,(%esp)
  80019b:	e8 82 01 00 00       	call   800322 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b0:	89 04 24             	mov    %eax,(%esp)
  8001b3:	e8 d8 08 00 00       	call   800a90 <sys_cputs>

	return b.cnt;
}
  8001b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 87 ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    
	...

008001dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
  8001e2:	83 ec 3c             	sub    $0x3c,%esp
  8001e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001e8:	89 d7                	mov    %edx,%edi
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	75 08                	jne    800208 <printnum+0x2c>
  800200:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800203:	39 45 10             	cmp    %eax,0x10(%ebp)
  800206:	77 57                	ja     80025f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800208:	89 74 24 10          	mov    %esi,0x10(%esp)
  80020c:	4b                   	dec    %ebx
  80020d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800211:	8b 45 10             	mov    0x10(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80021c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800220:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800227:	00 
  800228:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022b:	89 04 24             	mov    %eax,(%esp)
  80022e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	e8 92 0b 00 00       	call   800dcc <__udivdi3>
  80023a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80023e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	89 54 24 04          	mov    %edx,0x4(%esp)
  800249:	89 fa                	mov    %edi,%edx
  80024b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024e:	e8 89 ff ff ff       	call   8001dc <printnum>
  800253:	eb 0f                	jmp    800264 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800259:	89 34 24             	mov    %esi,(%esp)
  80025c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	4b                   	dec    %ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f f1                	jg     800255 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800268:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027a:	00 
  80027b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	e8 5f 0c 00 00       	call   800eec <__umoddi3>
  80028d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800291:	0f be 80 99 10 80 00 	movsbl 0x801099(%eax),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80029e:	83 c4 3c             	add    $0x3c,%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a9:	83 fa 01             	cmp    $0x1,%edx
  8002ac:	7e 0e                	jle    8002bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	eb 22                	jmp    8002de <getuint+0x38>
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 10                	je     8002d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 0e                	jmp    8002de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 08                	jae    8002f8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	88 0a                	mov    %cl,(%edx)
  8002f5:	42                   	inc    %edx
  8002f6:	89 10                	mov    %edx,(%eax)
}
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800300:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 10             	mov    0x10(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800311:	89 44 24 04          	mov    %eax,0x4(%esp)
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 02 00 00 00       	call   800322 <vprintfmt>
	va_end(ap);
}
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 4c             	sub    $0x4c,%esp
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032e:	8b 75 10             	mov    0x10(%ebp),%esi
  800331:	eb 12                	jmp    800345 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800333:	85 c0                	test   %eax,%eax
  800335:	0f 84 6b 03 00 00    	je     8006a6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80033b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800345:	0f b6 06             	movzbl (%esi),%eax
  800348:	46                   	inc    %esi
  800349:	83 f8 25             	cmp    $0x25,%eax
  80034c:	75 e5                	jne    800333 <vprintfmt+0x11>
  80034e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800352:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800359:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800365:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036a:	eb 26                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800373:	eb 1d                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800378:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80037c:	eb 14                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800381:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800388:	eb 08                	jmp    800392 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80038d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	0f b6 06             	movzbl (%esi),%eax
  800395:	8d 56 01             	lea    0x1(%esi),%edx
  800398:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80039b:	8a 16                	mov    (%esi),%dl
  80039d:	83 ea 23             	sub    $0x23,%edx
  8003a0:	80 fa 55             	cmp    $0x55,%dl
  8003a3:	0f 87 e1 02 00 00    	ja     80068a <vprintfmt+0x368>
  8003a9:	0f b6 d2             	movzbl %dl,%edx
  8003ac:	ff 24 95 60 11 80 00 	jmp    *0x801160(,%edx,4)
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003be:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003c2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c8:	83 fa 09             	cmp    $0x9,%edx
  8003cb:	77 2a                	ja     8003f7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ce:	eb eb                	jmp    8003bb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 50 04             	lea    0x4(%eax),%edx
  8003d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 17                	jmp    8003f7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e4:	78 98                	js     80037e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e9:	eb a7                	jmp    800392 <vprintfmt+0x70>
  8003eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f5:	eb 9b                	jmp    800392 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fb:	79 95                	jns    800392 <vprintfmt+0x70>
  8003fd:	eb 8b                	jmp    80038a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ff:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800403:	eb 8d                	jmp    800392 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 50 04             	lea    0x4(%eax),%edx
  80040b:	89 55 14             	mov    %edx,0x14(%ebp)
  80040e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041d:	e9 23 ff ff ff       	jmp    800345 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	85 c0                	test   %eax,%eax
  80042f:	79 02                	jns    800433 <vprintfmt+0x111>
  800431:	f7 d8                	neg    %eax
  800433:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 08             	cmp    $0x8,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x123>
  80043a:	8b 04 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%eax
  800441:	85 c0                	test   %eax,%eax
  800443:	75 23                	jne    800468 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800445:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800449:	c7 44 24 08 b1 10 80 	movl   $0x8010b1,0x8(%esp)
  800450:	00 
  800451:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 9a fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 dd fe ff ff       	jmp    800345 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046c:	c7 44 24 08 ba 10 80 	movl   $0x8010ba,0x8(%esp)
  800473:	00 
  800474:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800478:	8b 55 08             	mov    0x8(%ebp),%edx
  80047b:	89 14 24             	mov    %edx,(%esp)
  80047e:	e8 77 fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800486:	e9 ba fe ff ff       	jmp    800345 <vprintfmt+0x23>
  80048b:	89 f9                	mov    %edi,%ecx
  80048d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	8b 30                	mov    (%eax),%esi
  80049e:	85 f6                	test   %esi,%esi
  8004a0:	75 05                	jne    8004a7 <vprintfmt+0x185>
				p = "(null)";
  8004a2:	be aa 10 80 00       	mov    $0x8010aa,%esi
			if (width > 0 && padc != '-')
  8004a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ab:	0f 8e 84 00 00 00    	jle    800535 <vprintfmt+0x213>
  8004b1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004b5:	74 7e                	je     800535 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004bb:	89 34 24             	mov    %esi,(%esp)
  8004be:	e8 8b 02 00 00       	call   80074e <strnlen>
  8004c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c6:	29 c2                	sub    %eax,%edx
  8004c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004cb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004cf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004d5:	89 de                	mov    %ebx,%esi
  8004d7:	89 d3                	mov    %edx,%ebx
  8004d9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	eb 0b                	jmp    8004e8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e1:	89 3c 24             	mov    %edi,(%esp)
  8004e4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	4b                   	dec    %ebx
  8004e8:	85 db                	test   %ebx,%ebx
  8004ea:	7f f1                	jg     8004dd <vprintfmt+0x1bb>
  8004ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004ef:	89 f3                	mov    %esi,%ebx
  8004f1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	79 05                	jns    800500 <vprintfmt+0x1de>
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800503:	29 c2                	sub    %eax,%edx
  800505:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800508:	eb 2b                	jmp    800535 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050e:	74 18                	je     800528 <vprintfmt+0x206>
  800510:	8d 50 e0             	lea    -0x20(%eax),%edx
  800513:	83 fa 5e             	cmp    $0x5e,%edx
  800516:	76 10                	jbe    800528 <vprintfmt+0x206>
					putch('?', putdat);
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	eb 0a                	jmp    800532 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800528:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052c:	89 04 24             	mov    %eax,(%esp)
  80052f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	ff 4d e4             	decl   -0x1c(%ebp)
  800535:	0f be 06             	movsbl (%esi),%eax
  800538:	46                   	inc    %esi
  800539:	85 c0                	test   %eax,%eax
  80053b:	74 21                	je     80055e <vprintfmt+0x23c>
  80053d:	85 ff                	test   %edi,%edi
  80053f:	78 c9                	js     80050a <vprintfmt+0x1e8>
  800541:	4f                   	dec    %edi
  800542:	79 c6                	jns    80050a <vprintfmt+0x1e8>
  800544:	8b 7d 08             	mov    0x8(%ebp),%edi
  800547:	89 de                	mov    %ebx,%esi
  800549:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80054c:	eb 18                	jmp    800566 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800552:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800559:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055b:	4b                   	dec    %ebx
  80055c:	eb 08                	jmp    800566 <vprintfmt+0x244>
  80055e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800561:	89 de                	mov    %ebx,%esi
  800563:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800566:	85 db                	test   %ebx,%ebx
  800568:	7f e4                	jg     80054e <vprintfmt+0x22c>
  80056a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80056d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800572:	e9 ce fd ff ff       	jmp    800345 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800577:	83 f9 01             	cmp    $0x1,%ecx
  80057a:	7e 10                	jle    80058c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 08             	lea    0x8(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	8b 30                	mov    (%eax),%esi
  800587:	8b 78 04             	mov    0x4(%eax),%edi
  80058a:	eb 26                	jmp    8005b2 <vprintfmt+0x290>
	else if (lflag)
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	74 12                	je     8005a2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
  80059b:	89 f7                	mov    %esi,%edi
  80059d:	c1 ff 1f             	sar    $0x1f,%edi
  8005a0:	eb 10                	jmp    8005b2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 30                	mov    (%eax),%esi
  8005ad:	89 f7                	mov    %esi,%edi
  8005af:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	78 0a                	js     8005c0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bb:	e9 8c 00 00 00       	jmp    80064c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ce:	f7 de                	neg    %esi
  8005d0:	83 d7 00             	adc    $0x0,%edi
  8005d3:	f7 df                	neg    %edi
			}
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005da:	eb 70                	jmp    80064c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005dc:	89 ca                	mov    %ecx,%edx
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 c0 fc ff ff       	call   8002a6 <getuint>
  8005e6:	89 c6                	mov    %eax,%esi
  8005e8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ef:	eb 5b                	jmp    80064c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005f1:	89 ca                	mov    %ecx,%edx
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 ab fc ff ff       	call   8002a6 <getuint>
  8005fb:	89 c6                	mov    %eax,%esi
  8005fd:	89 d7                	mov    %edx,%edi
			base = 8;
  8005ff:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800604:	eb 46                	jmp    80064c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800606:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800611:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062b:	8b 30                	mov    (%eax),%esi
  80062d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800632:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800637:	eb 13                	jmp    80064c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 63 fc ff ff       	call   8002a6 <getuint>
  800643:	89 c6                	mov    %eax,%esi
  800645:	89 d7                	mov    %edx,%edi
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800650:	89 54 24 10          	mov    %edx,0x10(%esp)
  800654:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800657:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065f:	89 34 24             	mov    %esi,(%esp)
  800662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800666:	89 da                	mov    %ebx,%edx
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	e8 6c fb ff ff       	call   8001dc <printnum>
			break;
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800673:	e9 cd fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800685:	e9 bb fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800698:	eb 01                	jmp    80069b <vprintfmt+0x379>
  80069a:	4e                   	dec    %esi
  80069b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069f:	75 f9                	jne    80069a <vprintfmt+0x378>
  8006a1:	e9 9f fc ff ff       	jmp    800345 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006a6:	83 c4 4c             	add    $0x4c,%esp
  8006a9:	5b                   	pop    %ebx
  8006aa:	5e                   	pop    %esi
  8006ab:	5f                   	pop    %edi
  8006ac:	5d                   	pop    %ebp
  8006ad:	c3                   	ret    

008006ae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	83 ec 28             	sub    $0x28,%esp
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 30                	je     8006ff <vsnprintf+0x51>
  8006cf:	85 d2                	test   %edx,%edx
  8006d1:	7e 33                	jle    800706 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006da:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	c7 04 24 e0 02 80 00 	movl   $0x8002e0,(%esp)
  8006ef:	e8 2e fc ff ff       	call   800322 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	eb 0c                	jmp    80070b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800704:	eb 05                	jmp    80070b <vsnprintf+0x5d>
  800706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    

0080070d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800716:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
  800724:	89 44 24 04          	mov    %eax,0x4(%esp)
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	89 04 24             	mov    %eax,(%esp)
  80072e:	e8 7b ff ff ff       	call   8006ae <vsnprintf>
	va_end(ap);

	return rc;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    
  800735:	00 00                	add    %al,(%eax)
	...

00800738 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	eb 01                	jmp    800746 <strlen+0xe>
		n++;
  800745:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074a:	75 f9                	jne    800745 <strlen+0xd>
		n++;
	return n;
}
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
  80075c:	eb 01                	jmp    80075f <strnlen+0x11>
		n++;
  80075e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	39 d0                	cmp    %edx,%eax
  800761:	74 06                	je     800769 <strnlen+0x1b>
  800763:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800767:	75 f5                	jne    80075e <strnlen+0x10>
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800775:	ba 00 00 00 00       	mov    $0x0,%edx
  80077a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80077d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800780:	42                   	inc    %edx
  800781:	84 c9                	test   %cl,%cl
  800783:	75 f5                	jne    80077a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800785:	5b                   	pop    %ebx
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800792:	89 1c 24             	mov    %ebx,(%esp)
  800795:	e8 9e ff ff ff       	call   800738 <strlen>
	strcpy(dst + len, src);
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a1:	01 d8                	add    %ebx,%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	e8 c0 ff ff ff       	call   80076b <strcpy>
	return dst;
}
  8007ab:	89 d8                	mov    %ebx,%eax
  8007ad:	83 c4 08             	add    $0x8,%esp
  8007b0:	5b                   	pop    %ebx
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	56                   	push   %esi
  8007b7:	53                   	push   %ebx
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007be:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c6:	eb 0c                	jmp    8007d4 <strncpy+0x21>
		*dst++ = *src;
  8007c8:	8a 1a                	mov    (%edx),%bl
  8007ca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d3:	41                   	inc    %ecx
  8007d4:	39 f1                	cmp    %esi,%ecx
  8007d6:	75 f0                	jne    8007c8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	75 0a                	jne    8007f8 <strlcpy+0x1c>
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	eb 1a                	jmp    80080c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f2:	88 18                	mov    %bl,(%eax)
  8007f4:	40                   	inc    %eax
  8007f5:	41                   	inc    %ecx
  8007f6:	eb 02                	jmp    8007fa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007fa:	4a                   	dec    %edx
  8007fb:	74 0a                	je     800807 <strlcpy+0x2b>
  8007fd:	8a 19                	mov    (%ecx),%bl
  8007ff:	84 db                	test   %bl,%bl
  800801:	75 ef                	jne    8007f2 <strlcpy+0x16>
  800803:	89 c2                	mov    %eax,%edx
  800805:	eb 02                	jmp    800809 <strlcpy+0x2d>
  800807:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800809:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80080c:	29 f0                	sub    %esi,%eax
}
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081b:	eb 02                	jmp    80081f <strcmp+0xd>
		p++, q++;
  80081d:	41                   	inc    %ecx
  80081e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081f:	8a 01                	mov    (%ecx),%al
  800821:	84 c0                	test   %al,%al
  800823:	74 04                	je     800829 <strcmp+0x17>
  800825:	3a 02                	cmp    (%edx),%al
  800827:	74 f4                	je     80081d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800829:	0f b6 c0             	movzbl %al,%eax
  80082c:	0f b6 12             	movzbl (%edx),%edx
  80082f:	29 d0                	sub    %edx,%eax
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800840:	eb 03                	jmp    800845 <strncmp+0x12>
		n--, p++, q++;
  800842:	4a                   	dec    %edx
  800843:	40                   	inc    %eax
  800844:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800845:	85 d2                	test   %edx,%edx
  800847:	74 14                	je     80085d <strncmp+0x2a>
  800849:	8a 18                	mov    (%eax),%bl
  80084b:	84 db                	test   %bl,%bl
  80084d:	74 04                	je     800853 <strncmp+0x20>
  80084f:	3a 19                	cmp    (%ecx),%bl
  800851:	74 ef                	je     800842 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 00             	movzbl (%eax),%eax
  800856:	0f b6 11             	movzbl (%ecx),%edx
  800859:	29 d0                	sub    %edx,%eax
  80085b:	eb 05                	jmp    800862 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800862:	5b                   	pop    %ebx
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80086e:	eb 05                	jmp    800875 <strchr+0x10>
		if (*s == c)
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 0c                	je     800880 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800874:	40                   	inc    %eax
  800875:	8a 10                	mov    (%eax),%dl
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f5                	jne    800870 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088b:	eb 05                	jmp    800892 <strfind+0x10>
		if (*s == c)
  80088d:	38 ca                	cmp    %cl,%dl
  80088f:	74 07                	je     800898 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800891:	40                   	inc    %eax
  800892:	8a 10                	mov    (%eax),%dl
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f5                	jne    80088d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	74 30                	je     8008dd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 25                	jne    8008da <memset+0x40>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 20                	jne    8008da <memset+0x40>
		c &= 0xFF;
  8008ba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bd:	89 d3                	mov    %edx,%ebx
  8008bf:	c1 e3 08             	shl    $0x8,%ebx
  8008c2:	89 d6                	mov    %edx,%esi
  8008c4:	c1 e6 18             	shl    $0x18,%esi
  8008c7:	89 d0                	mov    %edx,%eax
  8008c9:	c1 e0 10             	shl    $0x10,%eax
  8008cc:	09 f0                	or     %esi,%eax
  8008ce:	09 d0                	or     %edx,%eax
  8008d0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d5:	fc                   	cld    
  8008d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d8:	eb 03                	jmp    8008dd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008da:	fc                   	cld    
  8008db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008dd:	89 f8                	mov    %edi,%eax
  8008df:	5b                   	pop    %ebx
  8008e0:	5e                   	pop    %esi
  8008e1:	5f                   	pop    %edi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f2:	39 c6                	cmp    %eax,%esi
  8008f4:	73 34                	jae    80092a <memmove+0x46>
  8008f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f9:	39 d0                	cmp    %edx,%eax
  8008fb:	73 2d                	jae    80092a <memmove+0x46>
		s += n;
		d += n;
  8008fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800900:	f6 c2 03             	test   $0x3,%dl
  800903:	75 1b                	jne    800920 <memmove+0x3c>
  800905:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090b:	75 13                	jne    800920 <memmove+0x3c>
  80090d:	f6 c1 03             	test   $0x3,%cl
  800910:	75 0e                	jne    800920 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800912:	83 ef 04             	sub    $0x4,%edi
  800915:	8d 72 fc             	lea    -0x4(%edx),%esi
  800918:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80091b:	fd                   	std    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 07                	jmp    800927 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	4f                   	dec    %edi
  800921:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800924:	fd                   	std    
  800925:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800927:	fc                   	cld    
  800928:	eb 20                	jmp    80094a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800930:	75 13                	jne    800945 <memmove+0x61>
  800932:	a8 03                	test   $0x3,%al
  800934:	75 0f                	jne    800945 <memmove+0x61>
  800936:	f6 c1 03             	test   $0x3,%cl
  800939:	75 0a                	jne    800945 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80093b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80093e:	89 c7                	mov    %eax,%edi
  800940:	fc                   	cld    
  800941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800943:	eb 05                	jmp    80094a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800954:	8b 45 10             	mov    0x10(%ebp),%eax
  800957:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	e8 77 ff ff ff       	call   8008e4 <memmove>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 7d 08             	mov    0x8(%ebp),%edi
  800978:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	ba 00 00 00 00       	mov    $0x0,%edx
  800983:	eb 16                	jmp    80099b <memcmp+0x2c>
		if (*s1 != *s2)
  800985:	8a 04 17             	mov    (%edi,%edx,1),%al
  800988:	42                   	inc    %edx
  800989:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80098d:	38 c8                	cmp    %cl,%al
  80098f:	74 0a                	je     80099b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 c9             	movzbl %cl,%ecx
  800997:	29 c8                	sub    %ecx,%eax
  800999:	eb 09                	jmp    8009a4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099b:	39 da                	cmp    %ebx,%edx
  80099d:	75 e6                	jne    800985 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5f                   	pop    %edi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b2:	89 c2                	mov    %eax,%edx
  8009b4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b7:	eb 05                	jmp    8009be <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b9:	38 08                	cmp    %cl,(%eax)
  8009bb:	74 05                	je     8009c2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bd:	40                   	inc    %eax
  8009be:	39 d0                	cmp    %edx,%eax
  8009c0:	72 f7                	jb     8009b9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d0:	eb 01                	jmp    8009d3 <strtol+0xf>
		s++;
  8009d2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d3:	8a 02                	mov    (%edx),%al
  8009d5:	3c 20                	cmp    $0x20,%al
  8009d7:	74 f9                	je     8009d2 <strtol+0xe>
  8009d9:	3c 09                	cmp    $0x9,%al
  8009db:	74 f5                	je     8009d2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009dd:	3c 2b                	cmp    $0x2b,%al
  8009df:	75 08                	jne    8009e9 <strtol+0x25>
		s++;
  8009e1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e7:	eb 13                	jmp    8009fc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e9:	3c 2d                	cmp    $0x2d,%al
  8009eb:	75 0a                	jne    8009f7 <strtol+0x33>
		s++, neg = 1;
  8009ed:	8d 52 01             	lea    0x1(%edx),%edx
  8009f0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f5:	eb 05                	jmp    8009fc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fc:	85 db                	test   %ebx,%ebx
  8009fe:	74 05                	je     800a05 <strtol+0x41>
  800a00:	83 fb 10             	cmp    $0x10,%ebx
  800a03:	75 28                	jne    800a2d <strtol+0x69>
  800a05:	8a 02                	mov    (%edx),%al
  800a07:	3c 30                	cmp    $0x30,%al
  800a09:	75 10                	jne    800a1b <strtol+0x57>
  800a0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a0f:	75 0a                	jne    800a1b <strtol+0x57>
		s += 2, base = 16;
  800a11:	83 c2 02             	add    $0x2,%edx
  800a14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a19:	eb 12                	jmp    800a2d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a1b:	85 db                	test   %ebx,%ebx
  800a1d:	75 0e                	jne    800a2d <strtol+0x69>
  800a1f:	3c 30                	cmp    $0x30,%al
  800a21:	75 05                	jne    800a28 <strtol+0x64>
		s++, base = 8;
  800a23:	42                   	inc    %edx
  800a24:	b3 08                	mov    $0x8,%bl
  800a26:	eb 05                	jmp    800a2d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a28:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a34:	8a 0a                	mov    (%edx),%cl
  800a36:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a39:	80 fb 09             	cmp    $0x9,%bl
  800a3c:	77 08                	ja     800a46 <strtol+0x82>
			dig = *s - '0';
  800a3e:	0f be c9             	movsbl %cl,%ecx
  800a41:	83 e9 30             	sub    $0x30,%ecx
  800a44:	eb 1e                	jmp    800a64 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a46:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 08                	ja     800a56 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a4e:	0f be c9             	movsbl %cl,%ecx
  800a51:	83 e9 57             	sub    $0x57,%ecx
  800a54:	eb 0e                	jmp    800a64 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a56:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 12                	ja     800a70 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a5e:	0f be c9             	movsbl %cl,%ecx
  800a61:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a64:	39 f1                	cmp    %esi,%ecx
  800a66:	7d 0c                	jge    800a74 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a68:	42                   	inc    %edx
  800a69:	0f af c6             	imul   %esi,%eax
  800a6c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a6e:	eb c4                	jmp    800a34 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a70:	89 c1                	mov    %eax,%ecx
  800a72:	eb 02                	jmp    800a76 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a74:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7a:	74 05                	je     800a81 <strtol+0xbd>
		*endptr = (char *) s;
  800a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a81:	85 ff                	test   %edi,%edi
  800a83:	74 04                	je     800a89 <strtol+0xc5>
  800a85:	89 c8                	mov    %ecx,%eax
  800a87:	f7 d8                	neg    %eax
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    
	...

00800a90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	89 c6                	mov    %eax,%esi
  800aa7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <sys_cgetc>:

int
sys_cgetc(void)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab9:	b8 01 00 00 00       	mov    $0x1,%eax
  800abe:	89 d1                	mov    %edx,%ecx
  800ac0:	89 d3                	mov    %edx,%ebx
  800ac2:	89 d7                	mov    %edx,%edi
  800ac4:	89 d6                	mov    %edx,%esi
  800ac6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	89 cb                	mov    %ecx,%ebx
  800ae5:	89 cf                	mov    %ecx,%edi
  800ae7:	89 ce                	mov    %ecx,%esi
  800ae9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	7e 28                	jle    800b17 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800af3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800afa:	00 
  800afb:	c7 44 24 08 e4 12 80 	movl   $0x8012e4,0x8(%esp)
  800b02:	00 
  800b03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b0a:	00 
  800b0b:	c7 04 24 01 13 80 00 	movl   $0x801301,(%esp)
  800b12:	e8 5d 02 00 00       	call   800d74 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b17:	83 c4 2c             	add    $0x2c,%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_yield>:

void
sys_yield(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	be 00 00 00 00       	mov    $0x0,%esi
  800b6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	89 f7                	mov    %esi,%edi
  800b7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 28                	jle    800ba9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b85:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 08 e4 12 80 	movl   $0x8012e4,0x8(%esp)
  800b94:	00 
  800b95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9c:	00 
  800b9d:	c7 04 24 01 13 80 00 	movl   $0x801301,(%esp)
  800ba4:	e8 cb 01 00 00       	call   800d74 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba9:	83 c4 2c             	add    $0x2c,%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 28                	jle    800bfc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bdf:	00 
  800be0:	c7 44 24 08 e4 12 80 	movl   $0x8012e4,0x8(%esp)
  800be7:	00 
  800be8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bef:	00 
  800bf0:	c7 04 24 01 13 80 00 	movl   $0x801301,(%esp)
  800bf7:	e8 78 01 00 00       	call   800d74 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfc:	83 c4 2c             	add    $0x2c,%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 06 00 00 00       	mov    $0x6,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 28                	jle    800c4f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 e4 12 80 	movl   $0x8012e4,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 01 13 80 00 	movl   $0x801301,(%esp)
  800c4a:	e8 25 01 00 00       	call   800d74 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4f:	83 c4 2c             	add    $0x2c,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 28                	jle    800ca2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c85:	00 
  800c86:	c7 44 24 08 e4 12 80 	movl   $0x8012e4,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 01 13 80 00 	movl   $0x801301,(%esp)
  800c9d:	e8 d2 00 00 00       	call   800d74 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca2:	83 c4 2c             	add    $0x2c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 e4 12 80 	movl   $0x8012e4,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 01 13 80 00 	movl   $0x801301,(%esp)
  800cf0:	e8 7f 00 00 00       	call   800d74 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	be 00 00 00 00       	mov    $0x0,%esi
  800d08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 cb                	mov    %ecx,%ebx
  800d38:	89 cf                	mov    %ecx,%edi
  800d3a:	89 ce                	mov    %ecx,%esi
  800d3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	7e 28                	jle    800d6a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d46:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d4d:	00 
  800d4e:	c7 44 24 08 e4 12 80 	movl   $0x8012e4,0x8(%esp)
  800d55:	00 
  800d56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5d:	00 
  800d5e:	c7 04 24 01 13 80 00 	movl   $0x801301,(%esp)
  800d65:	e8 0a 00 00 00       	call   800d74 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6a:	83 c4 2c             	add    $0x2c,%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    
	...

00800d74 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d7c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d7f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d85:	e8 95 fd ff ff       	call   800b1f <sys_getenvid>
  800d8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d98:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da0:	c7 04 24 10 13 80 00 	movl   $0x801310,(%esp)
  800da7:	e8 14 f4 ff ff       	call   8001c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dac:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db0:	8b 45 10             	mov    0x10(%ebp),%eax
  800db3:	89 04 24             	mov    %eax,(%esp)
  800db6:	e8 a4 f3 ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  800dbb:	c7 04 24 8d 10 80 00 	movl   $0x80108d,(%esp)
  800dc2:	e8 f9 f3 ff ff       	call   8001c0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dc7:	cc                   	int3   
  800dc8:	eb fd                	jmp    800dc7 <_panic+0x53>
	...

00800dcc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800dcc:	55                   	push   %ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	83 ec 10             	sub    $0x10,%esp
  800dd2:	8b 74 24 20          	mov    0x20(%esp),%esi
  800dd6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dda:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dde:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800de2:	89 cd                	mov    %ecx,%ebp
  800de4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800de8:	85 c0                	test   %eax,%eax
  800dea:	75 2c                	jne    800e18 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800dec:	39 f9                	cmp    %edi,%ecx
  800dee:	77 68                	ja     800e58 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800df0:	85 c9                	test   %ecx,%ecx
  800df2:	75 0b                	jne    800dff <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800df4:	b8 01 00 00 00       	mov    $0x1,%eax
  800df9:	31 d2                	xor    %edx,%edx
  800dfb:	f7 f1                	div    %ecx
  800dfd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800dff:	31 d2                	xor    %edx,%edx
  800e01:	89 f8                	mov    %edi,%eax
  800e03:	f7 f1                	div    %ecx
  800e05:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e07:	89 f0                	mov    %esi,%eax
  800e09:	f7 f1                	div    %ecx
  800e0b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e11:	83 c4 10             	add    $0x10,%esp
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e18:	39 f8                	cmp    %edi,%eax
  800e1a:	77 2c                	ja     800e48 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e1c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e1f:	83 f6 1f             	xor    $0x1f,%esi
  800e22:	75 4c                	jne    800e70 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e24:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e26:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e2b:	72 0a                	jb     800e37 <__udivdi3+0x6b>
  800e2d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e31:	0f 87 ad 00 00 00    	ja     800ee4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e37:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e3c:	89 f0                	mov    %esi,%eax
  800e3e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    
  800e47:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e48:	31 ff                	xor    %edi,%edi
  800e4a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e4c:	89 f0                	mov    %esi,%eax
  800e4e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    
  800e57:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	89 f0                	mov    %esi,%eax
  800e5c:	f7 f1                	div    %ecx
  800e5e:	89 c6                	mov    %eax,%esi
  800e60:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e62:	89 f0                	mov    %esi,%eax
  800e64:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    
  800e6d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e70:	89 f1                	mov    %esi,%ecx
  800e72:	d3 e0                	shl    %cl,%eax
  800e74:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e78:	b8 20 00 00 00       	mov    $0x20,%eax
  800e7d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e7f:	89 ea                	mov    %ebp,%edx
  800e81:	88 c1                	mov    %al,%cl
  800e83:	d3 ea                	shr    %cl,%edx
  800e85:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e89:	09 ca                	or     %ecx,%edx
  800e8b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e8f:	89 f1                	mov    %esi,%ecx
  800e91:	d3 e5                	shl    %cl,%ebp
  800e93:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e97:	89 fd                	mov    %edi,%ebp
  800e99:	88 c1                	mov    %al,%cl
  800e9b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e9d:	89 fa                	mov    %edi,%edx
  800e9f:	89 f1                	mov    %esi,%ecx
  800ea1:	d3 e2                	shl    %cl,%edx
  800ea3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ea7:	88 c1                	mov    %al,%cl
  800ea9:	d3 ef                	shr    %cl,%edi
  800eab:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ead:	89 f8                	mov    %edi,%eax
  800eaf:	89 ea                	mov    %ebp,%edx
  800eb1:	f7 74 24 08          	divl   0x8(%esp)
  800eb5:	89 d1                	mov    %edx,%ecx
  800eb7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800eb9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ebd:	39 d1                	cmp    %edx,%ecx
  800ebf:	72 17                	jb     800ed8 <__udivdi3+0x10c>
  800ec1:	74 09                	je     800ecc <__udivdi3+0x100>
  800ec3:	89 fe                	mov    %edi,%esi
  800ec5:	31 ff                	xor    %edi,%edi
  800ec7:	e9 41 ff ff ff       	jmp    800e0d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ecc:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ed0:	89 f1                	mov    %esi,%ecx
  800ed2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ed4:	39 c2                	cmp    %eax,%edx
  800ed6:	73 eb                	jae    800ec3 <__udivdi3+0xf7>
		{
		  q0--;
  800ed8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800edb:	31 ff                	xor    %edi,%edi
  800edd:	e9 2b ff ff ff       	jmp    800e0d <__udivdi3+0x41>
  800ee2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ee4:	31 f6                	xor    %esi,%esi
  800ee6:	e9 22 ff ff ff       	jmp    800e0d <__udivdi3+0x41>
	...

00800eec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800eec:	55                   	push   %ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	83 ec 20             	sub    $0x20,%esp
  800ef2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ef6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800efa:	89 44 24 14          	mov    %eax,0x14(%esp)
  800efe:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f02:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f06:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f0a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f0c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f0e:	85 ed                	test   %ebp,%ebp
  800f10:	75 16                	jne    800f28 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f12:	39 f1                	cmp    %esi,%ecx
  800f14:	0f 86 a6 00 00 00    	jbe    800fc0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f1a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f1c:	89 d0                	mov    %edx,%eax
  800f1e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f20:	83 c4 20             	add    $0x20,%esp
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    
  800f27:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f28:	39 f5                	cmp    %esi,%ebp
  800f2a:	0f 87 ac 00 00 00    	ja     800fdc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f30:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f33:	83 f0 1f             	xor    $0x1f,%eax
  800f36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3a:	0f 84 a8 00 00 00    	je     800fe8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f40:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f44:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f46:	bf 20 00 00 00       	mov    $0x20,%edi
  800f4b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f4f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	d3 e8                	shr    %cl,%eax
  800f57:	09 e8                	or     %ebp,%eax
  800f59:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800f5d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f61:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f65:	d3 e0                	shl    %cl,%eax
  800f67:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f6b:	89 f2                	mov    %esi,%edx
  800f6d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f6f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f73:	d3 e0                	shl    %cl,%eax
  800f75:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f79:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f7d:	89 f9                	mov    %edi,%ecx
  800f7f:	d3 e8                	shr    %cl,%eax
  800f81:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f83:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f85:	89 f2                	mov    %esi,%edx
  800f87:	f7 74 24 18          	divl   0x18(%esp)
  800f8b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f8d:	f7 64 24 0c          	mull   0xc(%esp)
  800f91:	89 c5                	mov    %eax,%ebp
  800f93:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f95:	39 d6                	cmp    %edx,%esi
  800f97:	72 67                	jb     801000 <__umoddi3+0x114>
  800f99:	74 75                	je     801010 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f9b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f9f:	29 e8                	sub    %ebp,%eax
  800fa1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fa3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fa7:	d3 e8                	shr    %cl,%eax
  800fa9:	89 f2                	mov    %esi,%edx
  800fab:	89 f9                	mov    %edi,%ecx
  800fad:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800faf:	09 d0                	or     %edx,%eax
  800fb1:	89 f2                	mov    %esi,%edx
  800fb3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fb7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fb9:	83 c4 20             	add    $0x20,%esp
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fc0:	85 c9                	test   %ecx,%ecx
  800fc2:	75 0b                	jne    800fcf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fc4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc9:	31 d2                	xor    %edx,%edx
  800fcb:	f7 f1                	div    %ecx
  800fcd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fcf:	89 f0                	mov    %esi,%eax
  800fd1:	31 d2                	xor    %edx,%edx
  800fd3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fd5:	89 f8                	mov    %edi,%eax
  800fd7:	e9 3e ff ff ff       	jmp    800f1a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fdc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fde:	83 c4 20             	add    $0x20,%esp
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    
  800fe5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fe8:	39 f5                	cmp    %esi,%ebp
  800fea:	72 04                	jb     800ff0 <__umoddi3+0x104>
  800fec:	39 f9                	cmp    %edi,%ecx
  800fee:	77 06                	ja     800ff6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ff0:	89 f2                	mov    %esi,%edx
  800ff2:	29 cf                	sub    %ecx,%edi
  800ff4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ff6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ff8:	83 c4 20             	add    $0x20,%esp
  800ffb:	5e                   	pop    %esi
  800ffc:	5f                   	pop    %edi
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    
  800fff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801000:	89 d1                	mov    %edx,%ecx
  801002:	89 c5                	mov    %eax,%ebp
  801004:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801008:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80100c:	eb 8d                	jmp    800f9b <__umoddi3+0xaf>
  80100e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801010:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801014:	72 ea                	jb     801000 <__umoddi3+0x114>
  801016:	89 f1                	mov    %esi,%ecx
  801018:	eb 81                	jmp    800f9b <__umoddi3+0xaf>
