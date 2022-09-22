
obj/user/yield.debug:     file format elf32-i386


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
  80003b:	a1 04 40 80 00       	mov    0x804004,%eax
  800040:	8b 00                	mov    (%eax),%eax
  800042:	8b 40 48             	mov    0x48(%eax),%eax
  800045:	89 44 24 04          	mov    %eax,0x4(%esp)
  800049:	c7 04 24 e0 1f 80 00 	movl   $0x801fe0,(%esp)
  800050:	e8 63 01 00 00       	call   8001b8 <cprintf>
	for (i = 0; i < 5; i++) {
  800055:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  80005a:	e8 d7 0a 00 00       	call   800b36 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005f:	a1 04 40 80 00       	mov    0x804004,%eax
  800064:	8b 00                	mov    (%eax),%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800066:	8b 40 48             	mov    0x48(%eax),%eax
  800069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80006d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800071:	c7 04 24 00 20 80 00 	movl   $0x802000,(%esp)
  800078:	e8 3b 01 00 00       	call   8001b8 <cprintf>
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
  800083:	a1 04 40 80 00       	mov    0x804004,%eax
  800088:	8b 00                	mov    (%eax),%eax
  80008a:	8b 40 48             	mov    0x48(%eax),%eax
  80008d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800091:	c7 04 24 2c 20 80 00 	movl   $0x80202c,(%esp)
  800098:	e8 1b 01 00 00       	call   8001b8 <cprintf>
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
  8000b2:	e8 60 0a 00 00       	call   800b17 <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000c3:	c1 e0 07             	shl    $0x7,%eax
  8000c6:	29 d0                	sub    %edx,%eax
  8000c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000d3:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d8:	85 f6                	test   %esi,%esi
  8000da:	7e 07                	jle    8000e3 <libmain+0x3f>
		binaryname = argv[0];
  8000dc:	8b 03                	mov    (%ebx),%eax
  8000de:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e7:	89 34 24             	mov    %esi,(%esp)
  8000ea:	e8 45 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ef:	e8 08 00 00 00       	call   8000fc <exit>
}
  8000f4:	83 c4 20             	add    $0x20,%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    
	...

008000fc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800102:	e8 a2 0e 00 00       	call   800fa9 <close_all>
	sys_env_destroy(0);
  800107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80010e:	e8 b2 09 00 00       	call   800ac5 <sys_env_destroy>
}
  800113:	c9                   	leave  
  800114:	c3                   	ret    
  800115:	00 00                	add    %al,(%eax)
	...

00800118 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 14             	sub    $0x14,%esp
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800122:	8b 03                	mov    (%ebx),%eax
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80012b:	40                   	inc    %eax
  80012c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 19                	jne    80014e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800135:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80013c:	00 
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	89 04 24             	mov    %eax,(%esp)
  800143:	e8 40 09 00 00       	call   800a88 <sys_cputs>
		b->idx = 0;
  800148:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80014e:	ff 43 04             	incl   0x4(%ebx)
}
  800151:	83 c4 14             	add    $0x14,%esp
  800154:	5b                   	pop    %ebx
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	8b 45 0c             	mov    0xc(%ebp),%eax
  800177:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800182:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	c7 04 24 18 01 80 00 	movl   $0x800118,(%esp)
  800193:	e8 82 01 00 00       	call   80031a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800198:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80019e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 d8 08 00 00       	call   800a88 <sys_cputs>

	return b.cnt;
}
  8001b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c8:	89 04 24             	mov    %eax,(%esp)
  8001cb:	e8 87 ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    
	...

008001d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	57                   	push   %edi
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	83 ec 3c             	sub    $0x3c,%esp
  8001dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001e0:	89 d7                	mov    %edx,%edi
  8001e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f4:	85 c0                	test   %eax,%eax
  8001f6:	75 08                	jne    800200 <printnum+0x2c>
  8001f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fe:	77 57                	ja     800257 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800200:	89 74 24 10          	mov    %esi,0x10(%esp)
  800204:	4b                   	dec    %ebx
  800205:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800209:	8b 45 10             	mov    0x10(%ebp),%eax
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800214:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800218:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021f:	00 
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	e8 52 1b 00 00       	call   801d84 <__udivdi3>
  800232:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800236:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80023a:	89 04 24             	mov    %eax,(%esp)
  80023d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800241:	89 fa                	mov    %edi,%edx
  800243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800246:	e8 89 ff ff ff       	call   8001d4 <printnum>
  80024b:	eb 0f                	jmp    80025c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800251:	89 34 24             	mov    %esi,(%esp)
  800254:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800257:	4b                   	dec    %ebx
  800258:	85 db                	test   %ebx,%ebx
  80025a:	7f f1                	jg     80024d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800260:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800264:	8b 45 10             	mov    0x10(%ebp),%eax
  800267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800272:	00 
  800273:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800280:	e8 1f 1c 00 00       	call   801ea4 <__umoddi3>
  800285:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800289:	0f be 80 55 20 80 00 	movsbl 0x802055(%eax),%eax
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800296:	83 c4 3c             	add    $0x3c,%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a1:	83 fa 01             	cmp    $0x1,%edx
  8002a4:	7e 0e                	jle    8002b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	8b 52 04             	mov    0x4(%edx),%edx
  8002b2:	eb 22                	jmp    8002d6 <getuint+0x38>
	else if (lflag)
  8002b4:	85 d2                	test   %edx,%edx
  8002b6:	74 10                	je     8002c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c6:	eb 0e                	jmp    8002d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002de:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e6:	73 08                	jae    8002f0 <sprintputch+0x18>
		*b->buf++ = ch;
  8002e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002eb:	88 0a                	mov    %cl,(%edx)
  8002ed:	42                   	inc    %edx
  8002ee:	89 10                	mov    %edx,(%eax)
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800302:	89 44 24 08          	mov    %eax,0x8(%esp)
  800306:	8b 45 0c             	mov    0xc(%ebp),%eax
  800309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030d:	8b 45 08             	mov    0x8(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 02 00 00 00       	call   80031a <vprintfmt>
	va_end(ap);
}
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 4c             	sub    $0x4c,%esp
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800326:	8b 75 10             	mov    0x10(%ebp),%esi
  800329:	eb 12                	jmp    80033d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032b:	85 c0                	test   %eax,%eax
  80032d:	0f 84 6b 03 00 00    	je     80069e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800333:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033d:	0f b6 06             	movzbl (%esi),%eax
  800340:	46                   	inc    %esi
  800341:	83 f8 25             	cmp    $0x25,%eax
  800344:	75 e5                	jne    80032b <vprintfmt+0x11>
  800346:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80034a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800351:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800356:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	eb 26                	jmp    80038a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800367:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80036b:	eb 1d                	jmp    80038a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800370:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800374:	eb 14                	jmp    80038a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800379:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800380:	eb 08                	jmp    80038a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800382:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800385:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	0f b6 06             	movzbl (%esi),%eax
  80038d:	8d 56 01             	lea    0x1(%esi),%edx
  800390:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800393:	8a 16                	mov    (%esi),%dl
  800395:	83 ea 23             	sub    $0x23,%edx
  800398:	80 fa 55             	cmp    $0x55,%dl
  80039b:	0f 87 e1 02 00 00    	ja     800682 <vprintfmt+0x368>
  8003a1:	0f b6 d2             	movzbl %dl,%edx
  8003a4:	ff 24 95 a0 21 80 00 	jmp    *0x8021a0(,%edx,4)
  8003ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ae:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003b6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ba:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003bd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 2a                	ja     8003ef <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb eb                	jmp    8003b3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d6:	eb 17                	jmp    8003ef <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003dc:	78 98                	js     800376 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e1:	eb a7                	jmp    80038a <vprintfmt+0x70>
  8003e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003ed:	eb 9b                	jmp    80038a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f3:	79 95                	jns    80038a <vprintfmt+0x70>
  8003f5:	eb 8b                	jmp    800382 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fb:	eb 8d                	jmp    80038a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 50 04             	lea    0x4(%eax),%edx
  800403:	89 55 14             	mov    %edx,0x14(%ebp)
  800406:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800415:	e9 23 ff ff ff       	jmp    80033d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 50 04             	lea    0x4(%eax),%edx
  800420:	89 55 14             	mov    %edx,0x14(%ebp)
  800423:	8b 00                	mov    (%eax),%eax
  800425:	85 c0                	test   %eax,%eax
  800427:	79 02                	jns    80042b <vprintfmt+0x111>
  800429:	f7 d8                	neg    %eax
  80042b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042d:	83 f8 0f             	cmp    $0xf,%eax
  800430:	7f 0b                	jg     80043d <vprintfmt+0x123>
  800432:	8b 04 85 00 23 80 00 	mov    0x802300(,%eax,4),%eax
  800439:	85 c0                	test   %eax,%eax
  80043b:	75 23                	jne    800460 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80043d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800441:	c7 44 24 08 6d 20 80 	movl   $0x80206d,0x8(%esp)
  800448:	00 
  800449:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	e8 9a fe ff ff       	call   8002f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 dd fe ff ff       	jmp    80033d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800464:	c7 44 24 08 31 24 80 	movl   $0x802431,0x8(%esp)
  80046b:	00 
  80046c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800470:	8b 55 08             	mov    0x8(%ebp),%edx
  800473:	89 14 24             	mov    %edx,(%esp)
  800476:	e8 77 fe ff ff       	call   8002f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80047e:	e9 ba fe ff ff       	jmp    80033d <vprintfmt+0x23>
  800483:	89 f9                	mov    %edi,%ecx
  800485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800488:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	8b 30                	mov    (%eax),%esi
  800496:	85 f6                	test   %esi,%esi
  800498:	75 05                	jne    80049f <vprintfmt+0x185>
				p = "(null)";
  80049a:	be 66 20 80 00       	mov    $0x802066,%esi
			if (width > 0 && padc != '-')
  80049f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a3:	0f 8e 84 00 00 00    	jle    80052d <vprintfmt+0x213>
  8004a9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004ad:	74 7e                	je     80052d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b3:	89 34 24             	mov    %esi,(%esp)
  8004b6:	e8 8b 02 00 00       	call   800746 <strnlen>
  8004bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004be:	29 c2                	sub    %eax,%edx
  8004c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004c3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004c7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004ca:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004cd:	89 de                	mov    %ebx,%esi
  8004cf:	89 d3                	mov    %edx,%ebx
  8004d1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d3:	eb 0b                	jmp    8004e0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d9:	89 3c 24             	mov    %edi,(%esp)
  8004dc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	4b                   	dec    %ebx
  8004e0:	85 db                	test   %ebx,%ebx
  8004e2:	7f f1                	jg     8004d5 <vprintfmt+0x1bb>
  8004e4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004e7:	89 f3                	mov    %esi,%ebx
  8004e9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	79 05                	jns    8004f8 <vprintfmt+0x1de>
  8004f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004fb:	29 c2                	sub    %eax,%edx
  8004fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800500:	eb 2b                	jmp    80052d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800502:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800506:	74 18                	je     800520 <vprintfmt+0x206>
  800508:	8d 50 e0             	lea    -0x20(%eax),%edx
  80050b:	83 fa 5e             	cmp    $0x5e,%edx
  80050e:	76 10                	jbe    800520 <vprintfmt+0x206>
					putch('?', putdat);
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051b:	ff 55 08             	call   *0x8(%ebp)
  80051e:	eb 0a                	jmp    80052a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	ff 4d e4             	decl   -0x1c(%ebp)
  80052d:	0f be 06             	movsbl (%esi),%eax
  800530:	46                   	inc    %esi
  800531:	85 c0                	test   %eax,%eax
  800533:	74 21                	je     800556 <vprintfmt+0x23c>
  800535:	85 ff                	test   %edi,%edi
  800537:	78 c9                	js     800502 <vprintfmt+0x1e8>
  800539:	4f                   	dec    %edi
  80053a:	79 c6                	jns    800502 <vprintfmt+0x1e8>
  80053c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053f:	89 de                	mov    %ebx,%esi
  800541:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800544:	eb 18                	jmp    80055e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800546:	89 74 24 04          	mov    %esi,0x4(%esp)
  80054a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800551:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	4b                   	dec    %ebx
  800554:	eb 08                	jmp    80055e <vprintfmt+0x244>
  800556:	8b 7d 08             	mov    0x8(%ebp),%edi
  800559:	89 de                	mov    %ebx,%esi
  80055b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80055e:	85 db                	test   %ebx,%ebx
  800560:	7f e4                	jg     800546 <vprintfmt+0x22c>
  800562:	89 7d 08             	mov    %edi,0x8(%ebp)
  800565:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80056a:	e9 ce fd ff ff       	jmp    80033d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 f9 01             	cmp    $0x1,%ecx
  800572:	7e 10                	jle    800584 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 30                	mov    (%eax),%esi
  80057f:	8b 78 04             	mov    0x4(%eax),%edi
  800582:	eb 26                	jmp    8005aa <vprintfmt+0x290>
	else if (lflag)
  800584:	85 c9                	test   %ecx,%ecx
  800586:	74 12                	je     80059a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 30                	mov    (%eax),%esi
  800593:	89 f7                	mov    %esi,%edi
  800595:	c1 ff 1f             	sar    $0x1f,%edi
  800598:	eb 10                	jmp    8005aa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 30                	mov    (%eax),%esi
  8005a5:	89 f7                	mov    %esi,%edi
  8005a7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005aa:	85 ff                	test   %edi,%edi
  8005ac:	78 0a                	js     8005b8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b3:	e9 8c 00 00 00       	jmp    800644 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005c6:	f7 de                	neg    %esi
  8005c8:	83 d7 00             	adc    $0x0,%edi
  8005cb:	f7 df                	neg    %edi
			}
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	eb 70                	jmp    800644 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d4:	89 ca                	mov    %ecx,%edx
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 c0 fc ff ff       	call   80029e <getuint>
  8005de:	89 c6                	mov    %eax,%esi
  8005e0:	89 d7                	mov    %edx,%edi
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005e7:	eb 5b                	jmp    800644 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005e9:	89 ca                	mov    %ecx,%edx
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 ab fc ff ff       	call   80029e <getuint>
  8005f3:	89 c6                	mov    %eax,%esi
  8005f5:	89 d7                	mov    %edx,%edi
			base = 8;
  8005f7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005fc:	eb 46                	jmp    800644 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800602:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800609:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80060c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800610:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800623:	8b 30                	mov    (%eax),%esi
  800625:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80062f:	eb 13                	jmp    800644 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800631:	89 ca                	mov    %ecx,%edx
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 63 fc ff ff       	call   80029e <getuint>
  80063b:	89 c6                	mov    %eax,%esi
  80063d:	89 d7                	mov    %edx,%edi
			base = 16;
  80063f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800644:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800648:	89 54 24 10          	mov    %edx,0x10(%esp)
  80064c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800653:	89 44 24 08          	mov    %eax,0x8(%esp)
  800657:	89 34 24             	mov    %esi,(%esp)
  80065a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065e:	89 da                	mov    %ebx,%edx
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	e8 6c fb ff ff       	call   8001d4 <printnum>
			break;
  800668:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066b:	e9 cd fc ff ff       	jmp    80033d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	89 04 24             	mov    %eax,(%esp)
  800677:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067d:	e9 bb fc ff ff       	jmp    80033d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800682:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800686:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80068d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800690:	eb 01                	jmp    800693 <vprintfmt+0x379>
  800692:	4e                   	dec    %esi
  800693:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800697:	75 f9                	jne    800692 <vprintfmt+0x378>
  800699:	e9 9f fc ff ff       	jmp    80033d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80069e:	83 c4 4c             	add    $0x4c,%esp
  8006a1:	5b                   	pop    %ebx
  8006a2:	5e                   	pop    %esi
  8006a3:	5f                   	pop    %edi
  8006a4:	5d                   	pop    %ebp
  8006a5:	c3                   	ret    

008006a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	83 ec 28             	sub    $0x28,%esp
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	74 30                	je     8006f7 <vsnprintf+0x51>
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	7e 33                	jle    8006fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e0:	c7 04 24 d8 02 80 00 	movl   $0x8002d8,(%esp)
  8006e7:	e8 2e fc ff ff       	call   80031a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	eb 0c                	jmp    800703 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fc:	eb 05                	jmp    800703 <vsnprintf+0x5d>
  8006fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    

00800705 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800712:	8b 45 10             	mov    0x10(%ebp),%eax
  800715:	89 44 24 08          	mov    %eax,0x8(%esp)
  800719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 7b ff ff ff       	call   8006a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    
  80072d:	00 00                	add    %al,(%eax)
	...

00800730 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	eb 01                	jmp    80073e <strlen+0xe>
		n++;
  80073d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800742:	75 f9                	jne    80073d <strlen+0xd>
		n++;
	return n;
}
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	eb 01                	jmp    800757 <strnlen+0x11>
		n++;
  800756:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	39 d0                	cmp    %edx,%eax
  800759:	74 06                	je     800761 <strnlen+0x1b>
  80075b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075f:	75 f5                	jne    800756 <strnlen+0x10>
		n++;
	return n;
}
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
  800772:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800775:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800778:	42                   	inc    %edx
  800779:	84 c9                	test   %cl,%cl
  80077b:	75 f5                	jne    800772 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80077d:	5b                   	pop    %ebx
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	89 1c 24             	mov    %ebx,(%esp)
  80078d:	e8 9e ff ff ff       	call   800730 <strlen>
	strcpy(dst + len, src);
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	01 d8                	add    %ebx,%eax
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	e8 c0 ff ff ff       	call   800763 <strcpy>
	return dst;
}
  8007a3:	89 d8                	mov    %ebx,%eax
  8007a5:	83 c4 08             	add    $0x8,%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007be:	eb 0c                	jmp    8007cc <strncpy+0x21>
		*dst++ = *src;
  8007c0:	8a 1a                	mov    (%edx),%bl
  8007c2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cb:	41                   	inc    %ecx
  8007cc:	39 f1                	cmp    %esi,%ecx
  8007ce:	75 f0                	jne    8007c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	56                   	push   %esi
  8007d8:	53                   	push   %ebx
  8007d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	75 0a                	jne    8007f0 <strlcpy+0x1c>
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	eb 1a                	jmp    800804 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ea:	88 18                	mov    %bl,(%eax)
  8007ec:	40                   	inc    %eax
  8007ed:	41                   	inc    %ecx
  8007ee:	eb 02                	jmp    8007f2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007f2:	4a                   	dec    %edx
  8007f3:	74 0a                	je     8007ff <strlcpy+0x2b>
  8007f5:	8a 19                	mov    (%ecx),%bl
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	75 ef                	jne    8007ea <strlcpy+0x16>
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	eb 02                	jmp    800801 <strlcpy+0x2d>
  8007ff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800801:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800804:	29 f0                	sub    %esi,%eax
}
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800813:	eb 02                	jmp    800817 <strcmp+0xd>
		p++, q++;
  800815:	41                   	inc    %ecx
  800816:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800817:	8a 01                	mov    (%ecx),%al
  800819:	84 c0                	test   %al,%al
  80081b:	74 04                	je     800821 <strcmp+0x17>
  80081d:	3a 02                	cmp    (%edx),%al
  80081f:	74 f4                	je     800815 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800821:	0f b6 c0             	movzbl %al,%eax
  800824:	0f b6 12             	movzbl (%edx),%edx
  800827:	29 d0                	sub    %edx,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800838:	eb 03                	jmp    80083d <strncmp+0x12>
		n--, p++, q++;
  80083a:	4a                   	dec    %edx
  80083b:	40                   	inc    %eax
  80083c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083d:	85 d2                	test   %edx,%edx
  80083f:	74 14                	je     800855 <strncmp+0x2a>
  800841:	8a 18                	mov    (%eax),%bl
  800843:	84 db                	test   %bl,%bl
  800845:	74 04                	je     80084b <strncmp+0x20>
  800847:	3a 19                	cmp    (%ecx),%bl
  800849:	74 ef                	je     80083a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 00             	movzbl (%eax),%eax
  80084e:	0f b6 11             	movzbl (%ecx),%edx
  800851:	29 d0                	sub    %edx,%eax
  800853:	eb 05                	jmp    80085a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085a:	5b                   	pop    %ebx
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800866:	eb 05                	jmp    80086d <strchr+0x10>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 0c                	je     800878 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086c:	40                   	inc    %eax
  80086d:	8a 10                	mov    (%eax),%dl
  80086f:	84 d2                	test   %dl,%dl
  800871:	75 f5                	jne    800868 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800883:	eb 05                	jmp    80088a <strfind+0x10>
		if (*s == c)
  800885:	38 ca                	cmp    %cl,%dl
  800887:	74 07                	je     800890 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800889:	40                   	inc    %eax
  80088a:	8a 10                	mov    (%eax),%dl
  80088c:	84 d2                	test   %dl,%dl
  80088e:	75 f5                	jne    800885 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a1:	85 c9                	test   %ecx,%ecx
  8008a3:	74 30                	je     8008d5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ab:	75 25                	jne    8008d2 <memset+0x40>
  8008ad:	f6 c1 03             	test   $0x3,%cl
  8008b0:	75 20                	jne    8008d2 <memset+0x40>
		c &= 0xFF;
  8008b2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b5:	89 d3                	mov    %edx,%ebx
  8008b7:	c1 e3 08             	shl    $0x8,%ebx
  8008ba:	89 d6                	mov    %edx,%esi
  8008bc:	c1 e6 18             	shl    $0x18,%esi
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	c1 e0 10             	shl    $0x10,%eax
  8008c4:	09 f0                	or     %esi,%eax
  8008c6:	09 d0                	or     %edx,%eax
  8008c8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008cd:	fc                   	cld    
  8008ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d0:	eb 03                	jmp    8008d5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d2:	fc                   	cld    
  8008d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d5:	89 f8                	mov    %edi,%eax
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5f                   	pop    %edi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ea:	39 c6                	cmp    %eax,%esi
  8008ec:	73 34                	jae    800922 <memmove+0x46>
  8008ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f1:	39 d0                	cmp    %edx,%eax
  8008f3:	73 2d                	jae    800922 <memmove+0x46>
		s += n;
		d += n;
  8008f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f8:	f6 c2 03             	test   $0x3,%dl
  8008fb:	75 1b                	jne    800918 <memmove+0x3c>
  8008fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800903:	75 13                	jne    800918 <memmove+0x3c>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 0e                	jne    800918 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80090a:	83 ef 04             	sub    $0x4,%edi
  80090d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800910:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800913:	fd                   	std    
  800914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800916:	eb 07                	jmp    80091f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800918:	4f                   	dec    %edi
  800919:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091c:	fd                   	std    
  80091d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091f:	fc                   	cld    
  800920:	eb 20                	jmp    800942 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800928:	75 13                	jne    80093d <memmove+0x61>
  80092a:	a8 03                	test   $0x3,%al
  80092c:	75 0f                	jne    80093d <memmove+0x61>
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	75 0a                	jne    80093d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800933:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093b:	eb 05                	jmp    800942 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80093d:	89 c7                	mov    %eax,%edi
  80093f:	fc                   	cld    
  800940:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800942:	5e                   	pop    %esi
  800943:	5f                   	pop    %edi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80094c:	8b 45 10             	mov    0x10(%ebp),%eax
  80094f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	e8 77 ff ff ff       	call   8008dc <memmove>
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	ba 00 00 00 00       	mov    $0x0,%edx
  80097b:	eb 16                	jmp    800993 <memcmp+0x2c>
		if (*s1 != *s2)
  80097d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800980:	42                   	inc    %edx
  800981:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800985:	38 c8                	cmp    %cl,%al
  800987:	74 0a                	je     800993 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800989:	0f b6 c0             	movzbl %al,%eax
  80098c:	0f b6 c9             	movzbl %cl,%ecx
  80098f:	29 c8                	sub    %ecx,%eax
  800991:	eb 09                	jmp    80099c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	39 da                	cmp    %ebx,%edx
  800995:	75 e6                	jne    80097d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009aa:	89 c2                	mov    %eax,%edx
  8009ac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009af:	eb 05                	jmp    8009b6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	38 08                	cmp    %cl,(%eax)
  8009b3:	74 05                	je     8009ba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b5:	40                   	inc    %eax
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	72 f7                	jb     8009b1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c8:	eb 01                	jmp    8009cb <strtol+0xf>
		s++;
  8009ca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cb:	8a 02                	mov    (%edx),%al
  8009cd:	3c 20                	cmp    $0x20,%al
  8009cf:	74 f9                	je     8009ca <strtol+0xe>
  8009d1:	3c 09                	cmp    $0x9,%al
  8009d3:	74 f5                	je     8009ca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d5:	3c 2b                	cmp    $0x2b,%al
  8009d7:	75 08                	jne    8009e1 <strtol+0x25>
		s++;
  8009d9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009da:	bf 00 00 00 00       	mov    $0x0,%edi
  8009df:	eb 13                	jmp    8009f4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e1:	3c 2d                	cmp    $0x2d,%al
  8009e3:	75 0a                	jne    8009ef <strtol+0x33>
		s++, neg = 1;
  8009e5:	8d 52 01             	lea    0x1(%edx),%edx
  8009e8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ed:	eb 05                	jmp    8009f4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f4:	85 db                	test   %ebx,%ebx
  8009f6:	74 05                	je     8009fd <strtol+0x41>
  8009f8:	83 fb 10             	cmp    $0x10,%ebx
  8009fb:	75 28                	jne    800a25 <strtol+0x69>
  8009fd:	8a 02                	mov    (%edx),%al
  8009ff:	3c 30                	cmp    $0x30,%al
  800a01:	75 10                	jne    800a13 <strtol+0x57>
  800a03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a07:	75 0a                	jne    800a13 <strtol+0x57>
		s += 2, base = 16;
  800a09:	83 c2 02             	add    $0x2,%edx
  800a0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a11:	eb 12                	jmp    800a25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a13:	85 db                	test   %ebx,%ebx
  800a15:	75 0e                	jne    800a25 <strtol+0x69>
  800a17:	3c 30                	cmp    $0x30,%al
  800a19:	75 05                	jne    800a20 <strtol+0x64>
		s++, base = 8;
  800a1b:	42                   	inc    %edx
  800a1c:	b3 08                	mov    $0x8,%bl
  800a1e:	eb 05                	jmp    800a25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2c:	8a 0a                	mov    (%edx),%cl
  800a2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a31:	80 fb 09             	cmp    $0x9,%bl
  800a34:	77 08                	ja     800a3e <strtol+0x82>
			dig = *s - '0';
  800a36:	0f be c9             	movsbl %cl,%ecx
  800a39:	83 e9 30             	sub    $0x30,%ecx
  800a3c:	eb 1e                	jmp    800a5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 08                	ja     800a4e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a46:	0f be c9             	movsbl %cl,%ecx
  800a49:	83 e9 57             	sub    $0x57,%ecx
  800a4c:	eb 0e                	jmp    800a5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a51:	80 fb 19             	cmp    $0x19,%bl
  800a54:	77 12                	ja     800a68 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a56:	0f be c9             	movsbl %cl,%ecx
  800a59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a5c:	39 f1                	cmp    %esi,%ecx
  800a5e:	7d 0c                	jge    800a6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a60:	42                   	inc    %edx
  800a61:	0f af c6             	imul   %esi,%eax
  800a64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a66:	eb c4                	jmp    800a2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a68:	89 c1                	mov    %eax,%ecx
  800a6a:	eb 02                	jmp    800a6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a72:	74 05                	je     800a79 <strtol+0xbd>
		*endptr = (char *) s;
  800a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	74 04                	je     800a81 <strtol+0xc5>
  800a7d:	89 c8                	mov    %ecx,%eax
  800a7f:	f7 d8                	neg    %eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    
	...

00800a88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
  800a99:	89 c3                	mov    %eax,%ebx
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	89 c6                	mov    %eax,%esi
  800a9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab6:	89 d1                	mov    %edx,%ecx
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	89 d7                	mov    %edx,%edi
  800abc:	89 d6                	mov    %edx,%esi
  800abe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	89 cb                	mov    %ecx,%ebx
  800add:	89 cf                	mov    %ecx,%edi
  800adf:	89 ce                	mov    %ecx,%esi
  800ae1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	7e 28                	jle    800b0f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aeb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800af2:	00 
  800af3:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800afa:	00 
  800afb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b02:	00 
  800b03:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800b0a:	e8 c1 10 00 00       	call   801bd0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0f:	83 c4 2c             	add    $0x2c,%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 02 00 00 00       	mov    $0x2,%eax
  800b27:	89 d1                	mov    %edx,%ecx
  800b29:	89 d3                	mov    %edx,%ebx
  800b2b:	89 d7                	mov    %edx,%edi
  800b2d:	89 d6                	mov    %edx,%esi
  800b2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_yield>:

void
sys_yield(void)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b46:	89 d1                	mov    %edx,%ecx
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	89 d7                	mov    %edx,%edi
  800b4c:	89 d6                	mov    %edx,%esi
  800b4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	be 00 00 00 00       	mov    $0x0,%esi
  800b63:	b8 04 00 00 00       	mov    $0x4,%eax
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 f7                	mov    %esi,%edi
  800b73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	7e 28                	jle    800ba1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b7d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b84:	00 
  800b85:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b94:	00 
  800b95:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800b9c:	e8 2f 10 00 00       	call   801bd0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba1:	83 c4 2c             	add    $0x2c,%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 28                	jle    800bf4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bd7:	00 
  800bd8:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800bdf:	00 
  800be0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be7:	00 
  800be8:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800bef:	e8 dc 0f 00 00       	call   801bd0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf4:	83 c4 2c             	add    $0x2c,%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	89 df                	mov    %ebx,%edi
  800c17:	89 de                	mov    %ebx,%esi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 28                	jle    800c47 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800c32:	00 
  800c33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3a:	00 
  800c3b:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800c42:	e8 89 0f 00 00       	call   801bd0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c47:	83 c4 2c             	add    $0x2c,%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 df                	mov    %ebx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 28                	jle    800c9a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c76:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c7d:	00 
  800c7e:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800c85:	00 
  800c86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8d:	00 
  800c8e:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800c95:	e8 36 0f 00 00       	call   801bd0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9a:	83 c4 2c             	add    $0x2c,%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 28                	jle    800ced <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce0:	00 
  800ce1:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800ce8:	e8 e3 0e 00 00       	call   801bd0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ced:	83 c4 2c             	add    $0x2c,%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	89 df                	mov    %ebx,%edi
  800d10:	89 de                	mov    %ebx,%esi
  800d12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7e 28                	jle    800d40 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d23:	00 
  800d24:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d33:	00 
  800d34:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800d3b:	e8 90 0e 00 00       	call   801bd0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d40:	83 c4 2c             	add    $0x2c,%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 5f 23 80 	movl   $0x80235f,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 7c 23 80 00 	movl   $0x80237c,(%esp)
  800db0:	e8 1b 0e 00 00       	call   801bd0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db5:	83 c4 2c             	add    $0x2c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    
  800dbd:	00 00                	add    %al,(%eax)
	...

00800dc0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc6:	05 00 00 00 30       	add    $0x30000000,%eax
  800dcb:	c1 e8 0c             	shr    $0xc,%eax
}
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd9:	89 04 24             	mov    %eax,(%esp)
  800ddc:	e8 df ff ff ff       	call   800dc0 <fd2num>
  800de1:	05 20 00 0d 00       	add    $0xd0020,%eax
  800de6:	c1 e0 0c             	shl    $0xc,%eax
}
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    

00800deb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	53                   	push   %ebx
  800def:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800df2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800df7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df9:	89 c2                	mov    %eax,%edx
  800dfb:	c1 ea 16             	shr    $0x16,%edx
  800dfe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e05:	f6 c2 01             	test   $0x1,%dl
  800e08:	74 11                	je     800e1b <fd_alloc+0x30>
  800e0a:	89 c2                	mov    %eax,%edx
  800e0c:	c1 ea 0c             	shr    $0xc,%edx
  800e0f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e16:	f6 c2 01             	test   $0x1,%dl
  800e19:	75 09                	jne    800e24 <fd_alloc+0x39>
			*fd_store = fd;
  800e1b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e22:	eb 17                	jmp    800e3b <fd_alloc+0x50>
  800e24:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e29:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e2e:	75 c7                	jne    800df7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e30:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e36:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e3b:	5b                   	pop    %ebx
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e44:	83 f8 1f             	cmp    $0x1f,%eax
  800e47:	77 36                	ja     800e7f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e49:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e4e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e51:	89 c2                	mov    %eax,%edx
  800e53:	c1 ea 16             	shr    $0x16,%edx
  800e56:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e5d:	f6 c2 01             	test   $0x1,%dl
  800e60:	74 24                	je     800e86 <fd_lookup+0x48>
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	c1 ea 0c             	shr    $0xc,%edx
  800e67:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6e:	f6 c2 01             	test   $0x1,%dl
  800e71:	74 1a                	je     800e8d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e76:	89 02                	mov    %eax,(%edx)
	return 0;
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7d:	eb 13                	jmp    800e92 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e84:	eb 0c                	jmp    800e92 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8b:	eb 05                	jmp    800e92 <fd_lookup+0x54>
  800e8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	53                   	push   %ebx
  800e98:	83 ec 14             	sub    $0x14,%esp
  800e9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea6:	eb 0e                	jmp    800eb6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800ea8:	39 08                	cmp    %ecx,(%eax)
  800eaa:	75 09                	jne    800eb5 <dev_lookup+0x21>
			*dev = devtab[i];
  800eac:	89 03                	mov    %eax,(%ebx)
			return 0;
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb3:	eb 35                	jmp    800eea <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eb5:	42                   	inc    %edx
  800eb6:	8b 04 95 08 24 80 00 	mov    0x802408(,%edx,4),%eax
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	75 e7                	jne    800ea8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec1:	a1 04 40 80 00       	mov    0x804004,%eax
  800ec6:	8b 00                	mov    (%eax),%eax
  800ec8:	8b 40 48             	mov    0x48(%eax),%eax
  800ecb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ecf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed3:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  800eda:	e8 d9 f2 ff ff       	call   8001b8 <cprintf>
	*dev = 0;
  800edf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eea:	83 c4 14             	add    $0x14,%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 30             	sub    $0x30,%esp
  800ef8:	8b 75 08             	mov    0x8(%ebp),%esi
  800efb:	8a 45 0c             	mov    0xc(%ebp),%al
  800efe:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f01:	89 34 24             	mov    %esi,(%esp)
  800f04:	e8 b7 fe ff ff       	call   800dc0 <fd2num>
  800f09:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f0c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f10:	89 04 24             	mov    %eax,(%esp)
  800f13:	e8 26 ff ff ff       	call   800e3e <fd_lookup>
  800f18:	89 c3                	mov    %eax,%ebx
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	78 05                	js     800f23 <fd_close+0x33>
	    || fd != fd2)
  800f1e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f21:	74 0d                	je     800f30 <fd_close+0x40>
		return (must_exist ? r : 0);
  800f23:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f27:	75 46                	jne    800f6f <fd_close+0x7f>
  800f29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2e:	eb 3f                	jmp    800f6f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f30:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f37:	8b 06                	mov    (%esi),%eax
  800f39:	89 04 24             	mov    %eax,(%esp)
  800f3c:	e8 53 ff ff ff       	call   800e94 <dev_lookup>
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	85 c0                	test   %eax,%eax
  800f45:	78 18                	js     800f5f <fd_close+0x6f>
		if (dev->dev_close)
  800f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4a:	8b 40 10             	mov    0x10(%eax),%eax
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	74 09                	je     800f5a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f51:	89 34 24             	mov    %esi,(%esp)
  800f54:	ff d0                	call   *%eax
  800f56:	89 c3                	mov    %eax,%ebx
  800f58:	eb 05                	jmp    800f5f <fd_close+0x6f>
		else
			r = 0;
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6a:	e8 8d fc ff ff       	call   800bfc <sys_page_unmap>
	return r;
}
  800f6f:	89 d8                	mov    %ebx,%eax
  800f71:	83 c4 30             	add    $0x30,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f85:	8b 45 08             	mov    0x8(%ebp),%eax
  800f88:	89 04 24             	mov    %eax,(%esp)
  800f8b:	e8 ae fe ff ff       	call   800e3e <fd_lookup>
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 13                	js     800fa7 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800f94:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f9b:	00 
  800f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9f:	89 04 24             	mov    %eax,(%esp)
  800fa2:	e8 49 ff ff ff       	call   800ef0 <fd_close>
}
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    

00800fa9 <close_all>:

void
close_all(void)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	53                   	push   %ebx
  800fad:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fb5:	89 1c 24             	mov    %ebx,(%esp)
  800fb8:	e8 bb ff ff ff       	call   800f78 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fbd:	43                   	inc    %ebx
  800fbe:	83 fb 20             	cmp    $0x20,%ebx
  800fc1:	75 f2                	jne    800fb5 <close_all+0xc>
		close(i);
}
  800fc3:	83 c4 14             	add    $0x14,%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 4c             	sub    $0x4c,%esp
  800fd2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	89 04 24             	mov    %eax,(%esp)
  800fe2:	e8 57 fe ff ff       	call   800e3e <fd_lookup>
  800fe7:	89 c3                	mov    %eax,%ebx
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	0f 88 e1 00 00 00    	js     8010d2 <dup+0x109>
		return r;
	close(newfdnum);
  800ff1:	89 3c 24             	mov    %edi,(%esp)
  800ff4:	e8 7f ff ff ff       	call   800f78 <close>

	newfd = INDEX2FD(newfdnum);
  800ff9:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fff:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801002:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801005:	89 04 24             	mov    %eax,(%esp)
  801008:	e8 c3 fd ff ff       	call   800dd0 <fd2data>
  80100d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80100f:	89 34 24             	mov    %esi,(%esp)
  801012:	e8 b9 fd ff ff       	call   800dd0 <fd2data>
  801017:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80101a:	89 d8                	mov    %ebx,%eax
  80101c:	c1 e8 16             	shr    $0x16,%eax
  80101f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801026:	a8 01                	test   $0x1,%al
  801028:	74 46                	je     801070 <dup+0xa7>
  80102a:	89 d8                	mov    %ebx,%eax
  80102c:	c1 e8 0c             	shr    $0xc,%eax
  80102f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801036:	f6 c2 01             	test   $0x1,%dl
  801039:	74 35                	je     801070 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80103b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801042:	25 07 0e 00 00       	and    $0xe07,%eax
  801047:	89 44 24 10          	mov    %eax,0x10(%esp)
  80104b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80104e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801059:	00 
  80105a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80105e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801065:	e8 3f fb ff ff       	call   800ba9 <sys_page_map>
  80106a:	89 c3                	mov    %eax,%ebx
  80106c:	85 c0                	test   %eax,%eax
  80106e:	78 3b                	js     8010ab <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801070:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801073:	89 c2                	mov    %eax,%edx
  801075:	c1 ea 0c             	shr    $0xc,%edx
  801078:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80107f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801085:	89 54 24 10          	mov    %edx,0x10(%esp)
  801089:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80108d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801094:	00 
  801095:	89 44 24 04          	mov    %eax,0x4(%esp)
  801099:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a0:	e8 04 fb ff ff       	call   800ba9 <sys_page_map>
  8010a5:	89 c3                	mov    %eax,%ebx
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	79 25                	jns    8010d0 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b6:	e8 41 fb ff ff       	call   800bfc <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c9:	e8 2e fb ff ff       	call   800bfc <sys_page_unmap>
	return r;
  8010ce:	eb 02                	jmp    8010d2 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010d0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010d2:	89 d8                	mov    %ebx,%eax
  8010d4:	83 c4 4c             	add    $0x4c,%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	53                   	push   %ebx
  8010e0:	83 ec 24             	sub    $0x24,%esp
  8010e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ed:	89 1c 24             	mov    %ebx,(%esp)
  8010f0:	e8 49 fd ff ff       	call   800e3e <fd_lookup>
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	78 6f                	js     801168 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801100:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801103:	8b 00                	mov    (%eax),%eax
  801105:	89 04 24             	mov    %eax,(%esp)
  801108:	e8 87 fd ff ff       	call   800e94 <dev_lookup>
  80110d:	85 c0                	test   %eax,%eax
  80110f:	78 57                	js     801168 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801111:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801114:	8b 50 08             	mov    0x8(%eax),%edx
  801117:	83 e2 03             	and    $0x3,%edx
  80111a:	83 fa 01             	cmp    $0x1,%edx
  80111d:	75 25                	jne    801144 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80111f:	a1 04 40 80 00       	mov    0x804004,%eax
  801124:	8b 00                	mov    (%eax),%eax
  801126:	8b 40 48             	mov    0x48(%eax),%eax
  801129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80112d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801131:	c7 04 24 cd 23 80 00 	movl   $0x8023cd,(%esp)
  801138:	e8 7b f0 ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  80113d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801142:	eb 24                	jmp    801168 <read+0x8c>
	}
	if (!dev->dev_read)
  801144:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801147:	8b 52 08             	mov    0x8(%edx),%edx
  80114a:	85 d2                	test   %edx,%edx
  80114c:	74 15                	je     801163 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80114e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801151:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801155:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801158:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80115c:	89 04 24             	mov    %eax,(%esp)
  80115f:	ff d2                	call   *%edx
  801161:	eb 05                	jmp    801168 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801163:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801168:	83 c4 24             	add    $0x24,%esp
  80116b:	5b                   	pop    %ebx
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 1c             	sub    $0x1c,%esp
  801177:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801182:	eb 23                	jmp    8011a7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801184:	89 f0                	mov    %esi,%eax
  801186:	29 d8                	sub    %ebx,%eax
  801188:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118f:	01 d8                	add    %ebx,%eax
  801191:	89 44 24 04          	mov    %eax,0x4(%esp)
  801195:	89 3c 24             	mov    %edi,(%esp)
  801198:	e8 3f ff ff ff       	call   8010dc <read>
		if (m < 0)
  80119d:	85 c0                	test   %eax,%eax
  80119f:	78 10                	js     8011b1 <readn+0x43>
			return m;
		if (m == 0)
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	74 0a                	je     8011af <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a5:	01 c3                	add    %eax,%ebx
  8011a7:	39 f3                	cmp    %esi,%ebx
  8011a9:	72 d9                	jb     801184 <readn+0x16>
  8011ab:	89 d8                	mov    %ebx,%eax
  8011ad:	eb 02                	jmp    8011b1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011af:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011b1:	83 c4 1c             	add    $0x1c,%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 24             	sub    $0x24,%esp
  8011c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ca:	89 1c 24             	mov    %ebx,(%esp)
  8011cd:	e8 6c fc ff ff       	call   800e3e <fd_lookup>
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 6a                	js     801240 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e0:	8b 00                	mov    (%eax),%eax
  8011e2:	89 04 24             	mov    %eax,(%esp)
  8011e5:	e8 aa fc ff ff       	call   800e94 <dev_lookup>
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 52                	js     801240 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f5:	75 25                	jne    80121c <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fc:	8b 00                	mov    (%eax),%eax
  8011fe:	8b 40 48             	mov    0x48(%eax),%eax
  801201:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801205:	89 44 24 04          	mov    %eax,0x4(%esp)
  801209:	c7 04 24 e9 23 80 00 	movl   $0x8023e9,(%esp)
  801210:	e8 a3 ef ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  801215:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121a:	eb 24                	jmp    801240 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80121c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121f:	8b 52 0c             	mov    0xc(%edx),%edx
  801222:	85 d2                	test   %edx,%edx
  801224:	74 15                	je     80123b <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801226:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801229:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80122d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801230:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801234:	89 04 24             	mov    %eax,(%esp)
  801237:	ff d2                	call   *%edx
  801239:	eb 05                	jmp    801240 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80123b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801240:	83 c4 24             	add    $0x24,%esp
  801243:	5b                   	pop    %ebx
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <seek>:

int
seek(int fdnum, off_t offset)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	89 04 24             	mov    %eax,(%esp)
  801259:	e8 e0 fb ff ff       	call   800e3e <fd_lookup>
  80125e:	85 c0                	test   %eax,%eax
  801260:	78 0e                	js     801270 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801262:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801265:	8b 55 0c             	mov    0xc(%ebp),%edx
  801268:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	53                   	push   %ebx
  801276:	83 ec 24             	sub    $0x24,%esp
  801279:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801283:	89 1c 24             	mov    %ebx,(%esp)
  801286:	e8 b3 fb ff ff       	call   800e3e <fd_lookup>
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 63                	js     8012f2 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801292:	89 44 24 04          	mov    %eax,0x4(%esp)
  801296:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801299:	8b 00                	mov    (%eax),%eax
  80129b:	89 04 24             	mov    %eax,(%esp)
  80129e:	e8 f1 fb ff ff       	call   800e94 <dev_lookup>
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 4b                	js     8012f2 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012aa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ae:	75 25                	jne    8012d5 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8012b5:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c2:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  8012c9:	e8 ea ee ff ff       	call   8001b8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d3:	eb 1d                	jmp    8012f2 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8012d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d8:	8b 52 18             	mov    0x18(%edx),%edx
  8012db:	85 d2                	test   %edx,%edx
  8012dd:	74 0e                	je     8012ed <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	ff d2                	call   *%edx
  8012eb:	eb 05                	jmp    8012f2 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f2:	83 c4 24             	add    $0x24,%esp
  8012f5:	5b                   	pop    %ebx
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 24             	sub    $0x24,%esp
  8012ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801302:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801305:	89 44 24 04          	mov    %eax,0x4(%esp)
  801309:	8b 45 08             	mov    0x8(%ebp),%eax
  80130c:	89 04 24             	mov    %eax,(%esp)
  80130f:	e8 2a fb ff ff       	call   800e3e <fd_lookup>
  801314:	85 c0                	test   %eax,%eax
  801316:	78 52                	js     80136a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801322:	8b 00                	mov    (%eax),%eax
  801324:	89 04 24             	mov    %eax,(%esp)
  801327:	e8 68 fb ff ff       	call   800e94 <dev_lookup>
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 3a                	js     80136a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801330:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801333:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801337:	74 2c                	je     801365 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801339:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80133c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801343:	00 00 00 
	stat->st_isdir = 0;
  801346:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80134d:	00 00 00 
	stat->st_dev = dev;
  801350:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801356:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80135a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80135d:	89 14 24             	mov    %edx,(%esp)
  801360:	ff 50 14             	call   *0x14(%eax)
  801363:	eb 05                	jmp    80136a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801365:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80136a:	83 c4 24             	add    $0x24,%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801378:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80137f:	00 
  801380:	8b 45 08             	mov    0x8(%ebp),%eax
  801383:	89 04 24             	mov    %eax,(%esp)
  801386:	e8 88 02 00 00       	call   801613 <open>
  80138b:	89 c3                	mov    %eax,%ebx
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 1b                	js     8013ac <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801391:	8b 45 0c             	mov    0xc(%ebp),%eax
  801394:	89 44 24 04          	mov    %eax,0x4(%esp)
  801398:	89 1c 24             	mov    %ebx,(%esp)
  80139b:	e8 58 ff ff ff       	call   8012f8 <fstat>
  8013a0:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a2:	89 1c 24             	mov    %ebx,(%esp)
  8013a5:	e8 ce fb ff ff       	call   800f78 <close>
	return r;
  8013aa:	89 f3                	mov    %esi,%ebx
}
  8013ac:	89 d8                	mov    %ebx,%eax
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	5b                   	pop    %ebx
  8013b2:	5e                   	pop    %esi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    
  8013b5:	00 00                	add    %al,(%eax)
	...

008013b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	56                   	push   %esi
  8013bc:	53                   	push   %ebx
  8013bd:	83 ec 10             	sub    $0x10,%esp
  8013c0:	89 c3                	mov    %eax,%ebx
  8013c2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013c4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013cb:	75 11                	jne    8013de <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8013d4:	e8 22 09 00 00       	call   801cfb <ipc_find_env>
  8013d9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013de:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8013e5:	00 
  8013e6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8013ed:	00 
  8013ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013f2:	a1 00 40 80 00       	mov    0x804000,%eax
  8013f7:	89 04 24             	mov    %eax,(%esp)
  8013fa:	e8 96 08 00 00       	call   801c95 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  8013ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801406:	00 
  801407:	89 74 24 04          	mov    %esi,0x4(%esp)
  80140b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801412:	e8 11 08 00 00       	call   801c28 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	5b                   	pop    %ebx
  80141b:	5e                   	pop    %esi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	8b 40 0c             	mov    0xc(%eax),%eax
  80142a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80142f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801432:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801437:	ba 00 00 00 00       	mov    $0x0,%edx
  80143c:	b8 02 00 00 00       	mov    $0x2,%eax
  801441:	e8 72 ff ff ff       	call   8013b8 <fsipc>
}
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	8b 40 0c             	mov    0xc(%eax),%eax
  801454:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801459:	ba 00 00 00 00       	mov    $0x0,%edx
  80145e:	b8 06 00 00 00       	mov    $0x6,%eax
  801463:	e8 50 ff ff ff       	call   8013b8 <fsipc>
}
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	53                   	push   %ebx
  80146e:	83 ec 14             	sub    $0x14,%esp
  801471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801474:	8b 45 08             	mov    0x8(%ebp),%eax
  801477:	8b 40 0c             	mov    0xc(%eax),%eax
  80147a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80147f:	ba 00 00 00 00       	mov    $0x0,%edx
  801484:	b8 05 00 00 00       	mov    $0x5,%eax
  801489:	e8 2a ff ff ff       	call   8013b8 <fsipc>
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 2b                	js     8014bd <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801492:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801499:	00 
  80149a:	89 1c 24             	mov    %ebx,(%esp)
  80149d:	e8 c1 f2 ff ff       	call   800763 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014a7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ad:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bd:	83 c4 14             	add    $0x14,%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    

008014c3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 14             	sub    $0x14,%esp
  8014ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  8014d8:	89 d8                	mov    %ebx,%eax
  8014da:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8014e0:	76 05                	jbe    8014e7 <devfile_write+0x24>
  8014e2:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8014e7:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  8014ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f7:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8014fe:	e8 43 f4 ff ff       	call   800946 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801503:	ba 00 00 00 00       	mov    $0x0,%edx
  801508:	b8 04 00 00 00       	mov    $0x4,%eax
  80150d:	e8 a6 fe ff ff       	call   8013b8 <fsipc>
  801512:	85 c0                	test   %eax,%eax
  801514:	78 53                	js     801569 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801516:	39 c3                	cmp    %eax,%ebx
  801518:	73 24                	jae    80153e <devfile_write+0x7b>
  80151a:	c7 44 24 0c 18 24 80 	movl   $0x802418,0xc(%esp)
  801521:	00 
  801522:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  801529:	00 
  80152a:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801531:	00 
  801532:	c7 04 24 34 24 80 00 	movl   $0x802434,(%esp)
  801539:	e8 92 06 00 00       	call   801bd0 <_panic>
	assert(r <= PGSIZE);
  80153e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801543:	7e 24                	jle    801569 <devfile_write+0xa6>
  801545:	c7 44 24 0c 3f 24 80 	movl   $0x80243f,0xc(%esp)
  80154c:	00 
  80154d:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  801554:	00 
  801555:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  80155c:	00 
  80155d:	c7 04 24 34 24 80 00 	movl   $0x802434,(%esp)
  801564:	e8 67 06 00 00       	call   801bd0 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801569:	83 c4 14             	add    $0x14,%esp
  80156c:	5b                   	pop    %ebx
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    

0080156f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	56                   	push   %esi
  801573:	53                   	push   %ebx
  801574:	83 ec 10             	sub    $0x10,%esp
  801577:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80157a:	8b 45 08             	mov    0x8(%ebp),%eax
  80157d:	8b 40 0c             	mov    0xc(%eax),%eax
  801580:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801585:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80158b:	ba 00 00 00 00       	mov    $0x0,%edx
  801590:	b8 03 00 00 00       	mov    $0x3,%eax
  801595:	e8 1e fe ff ff       	call   8013b8 <fsipc>
  80159a:	89 c3                	mov    %eax,%ebx
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 6a                	js     80160a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8015a0:	39 c6                	cmp    %eax,%esi
  8015a2:	73 24                	jae    8015c8 <devfile_read+0x59>
  8015a4:	c7 44 24 0c 18 24 80 	movl   $0x802418,0xc(%esp)
  8015ab:	00 
  8015ac:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  8015b3:	00 
  8015b4:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8015bb:	00 
  8015bc:	c7 04 24 34 24 80 00 	movl   $0x802434,(%esp)
  8015c3:	e8 08 06 00 00       	call   801bd0 <_panic>
	assert(r <= PGSIZE);
  8015c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015cd:	7e 24                	jle    8015f3 <devfile_read+0x84>
  8015cf:	c7 44 24 0c 3f 24 80 	movl   $0x80243f,0xc(%esp)
  8015d6:	00 
  8015d7:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  8015de:	00 
  8015df:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8015e6:	00 
  8015e7:	c7 04 24 34 24 80 00 	movl   $0x802434,(%esp)
  8015ee:	e8 dd 05 00 00       	call   801bd0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015f7:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015fe:	00 
  8015ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801602:	89 04 24             	mov    %eax,(%esp)
  801605:	e8 d2 f2 ff ff       	call   8008dc <memmove>
	return r;
}
  80160a:	89 d8                	mov    %ebx,%eax
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801613:	55                   	push   %ebp
  801614:	89 e5                	mov    %esp,%ebp
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 20             	sub    $0x20,%esp
  80161b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80161e:	89 34 24             	mov    %esi,(%esp)
  801621:	e8 0a f1 ff ff       	call   800730 <strlen>
  801626:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80162b:	7f 60                	jg     80168d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80162d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801630:	89 04 24             	mov    %eax,(%esp)
  801633:	e8 b3 f7 ff ff       	call   800deb <fd_alloc>
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 54                	js     801692 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80163e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801642:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801649:	e8 15 f1 ff ff       	call   800763 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80164e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801651:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801656:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801659:	b8 01 00 00 00       	mov    $0x1,%eax
  80165e:	e8 55 fd ff ff       	call   8013b8 <fsipc>
  801663:	89 c3                	mov    %eax,%ebx
  801665:	85 c0                	test   %eax,%eax
  801667:	79 15                	jns    80167e <open+0x6b>
		fd_close(fd, 0);
  801669:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801670:	00 
  801671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801674:	89 04 24             	mov    %eax,(%esp)
  801677:	e8 74 f8 ff ff       	call   800ef0 <fd_close>
		return r;
  80167c:	eb 14                	jmp    801692 <open+0x7f>
	}

	return fd2num(fd);
  80167e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801681:	89 04 24             	mov    %eax,(%esp)
  801684:	e8 37 f7 ff ff       	call   800dc0 <fd2num>
  801689:	89 c3                	mov    %eax,%ebx
  80168b:	eb 05                	jmp    801692 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80168d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801692:	89 d8                	mov    %ebx,%eax
  801694:	83 c4 20             	add    $0x20,%esp
  801697:	5b                   	pop    %ebx
  801698:	5e                   	pop    %esi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8016ab:	e8 08 fd ff ff       	call   8013b8 <fsipc>
}
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    
	...

008016b4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 10             	sub    $0x10,%esp
  8016bc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c2:	89 04 24             	mov    %eax,(%esp)
  8016c5:	e8 06 f7 ff ff       	call   800dd0 <fd2data>
  8016ca:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8016cc:	c7 44 24 04 4b 24 80 	movl   $0x80244b,0x4(%esp)
  8016d3:	00 
  8016d4:	89 34 24             	mov    %esi,(%esp)
  8016d7:	e8 87 f0 ff ff       	call   800763 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016dc:	8b 43 04             	mov    0x4(%ebx),%eax
  8016df:	2b 03                	sub    (%ebx),%eax
  8016e1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8016e7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8016ee:	00 00 00 
	stat->st_dev = &devpipe;
  8016f1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8016f8:	30 80 00 
	return 0;
}
  8016fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	53                   	push   %ebx
  80170b:	83 ec 14             	sub    $0x14,%esp
  80170e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801715:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171c:	e8 db f4 ff ff       	call   800bfc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801721:	89 1c 24             	mov    %ebx,(%esp)
  801724:	e8 a7 f6 ff ff       	call   800dd0 <fd2data>
  801729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801734:	e8 c3 f4 ff ff       	call   800bfc <sys_page_unmap>
}
  801739:	83 c4 14             	add    $0x14,%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5d                   	pop    %ebp
  80173e:	c3                   	ret    

0080173f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	57                   	push   %edi
  801743:	56                   	push   %esi
  801744:	53                   	push   %ebx
  801745:	83 ec 2c             	sub    $0x2c,%esp
  801748:	89 c7                	mov    %eax,%edi
  80174a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80174d:	a1 04 40 80 00       	mov    0x804004,%eax
  801752:	8b 00                	mov    (%eax),%eax
  801754:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801757:	89 3c 24             	mov    %edi,(%esp)
  80175a:	e8 e1 05 00 00       	call   801d40 <pageref>
  80175f:	89 c6                	mov    %eax,%esi
  801761:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801764:	89 04 24             	mov    %eax,(%esp)
  801767:	e8 d4 05 00 00       	call   801d40 <pageref>
  80176c:	39 c6                	cmp    %eax,%esi
  80176e:	0f 94 c0             	sete   %al
  801771:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801774:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80177a:	8b 12                	mov    (%edx),%edx
  80177c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80177f:	39 cb                	cmp    %ecx,%ebx
  801781:	75 08                	jne    80178b <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801783:	83 c4 2c             	add    $0x2c,%esp
  801786:	5b                   	pop    %ebx
  801787:	5e                   	pop    %esi
  801788:	5f                   	pop    %edi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80178b:	83 f8 01             	cmp    $0x1,%eax
  80178e:	75 bd                	jne    80174d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801790:	8b 42 58             	mov    0x58(%edx),%eax
  801793:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80179a:	00 
  80179b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80179f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017a3:	c7 04 24 52 24 80 00 	movl   $0x802452,(%esp)
  8017aa:	e8 09 ea ff ff       	call   8001b8 <cprintf>
  8017af:	eb 9c                	jmp    80174d <_pipeisclosed+0xe>

008017b1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	57                   	push   %edi
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 1c             	sub    $0x1c,%esp
  8017ba:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017bd:	89 34 24             	mov    %esi,(%esp)
  8017c0:	e8 0b f6 ff ff       	call   800dd0 <fd2data>
  8017c5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8017cc:	eb 3c                	jmp    80180a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017ce:	89 da                	mov    %ebx,%edx
  8017d0:	89 f0                	mov    %esi,%eax
  8017d2:	e8 68 ff ff ff       	call   80173f <_pipeisclosed>
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	75 38                	jne    801813 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017db:	e8 56 f3 ff ff       	call   800b36 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017e0:	8b 43 04             	mov    0x4(%ebx),%eax
  8017e3:	8b 13                	mov    (%ebx),%edx
  8017e5:	83 c2 20             	add    $0x20,%edx
  8017e8:	39 d0                	cmp    %edx,%eax
  8017ea:	73 e2                	jae    8017ce <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ef:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8017f2:	89 c2                	mov    %eax,%edx
  8017f4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8017fa:	79 05                	jns    801801 <devpipe_write+0x50>
  8017fc:	4a                   	dec    %edx
  8017fd:	83 ca e0             	or     $0xffffffe0,%edx
  801800:	42                   	inc    %edx
  801801:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801805:	40                   	inc    %eax
  801806:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801809:	47                   	inc    %edi
  80180a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80180d:	75 d1                	jne    8017e0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80180f:	89 f8                	mov    %edi,%eax
  801811:	eb 05                	jmp    801818 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801813:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801818:	83 c4 1c             	add    $0x1c,%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5e                   	pop    %esi
  80181d:	5f                   	pop    %edi
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	57                   	push   %edi
  801824:	56                   	push   %esi
  801825:	53                   	push   %ebx
  801826:	83 ec 1c             	sub    $0x1c,%esp
  801829:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80182c:	89 3c 24             	mov    %edi,(%esp)
  80182f:	e8 9c f5 ff ff       	call   800dd0 <fd2data>
  801834:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801836:	be 00 00 00 00       	mov    $0x0,%esi
  80183b:	eb 3a                	jmp    801877 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80183d:	85 f6                	test   %esi,%esi
  80183f:	74 04                	je     801845 <devpipe_read+0x25>
				return i;
  801841:	89 f0                	mov    %esi,%eax
  801843:	eb 40                	jmp    801885 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801845:	89 da                	mov    %ebx,%edx
  801847:	89 f8                	mov    %edi,%eax
  801849:	e8 f1 fe ff ff       	call   80173f <_pipeisclosed>
  80184e:	85 c0                	test   %eax,%eax
  801850:	75 2e                	jne    801880 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801852:	e8 df f2 ff ff       	call   800b36 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801857:	8b 03                	mov    (%ebx),%eax
  801859:	3b 43 04             	cmp    0x4(%ebx),%eax
  80185c:	74 df                	je     80183d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80185e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801863:	79 05                	jns    80186a <devpipe_read+0x4a>
  801865:	48                   	dec    %eax
  801866:	83 c8 e0             	or     $0xffffffe0,%eax
  801869:	40                   	inc    %eax
  80186a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80186e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801871:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801874:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801876:	46                   	inc    %esi
  801877:	3b 75 10             	cmp    0x10(%ebp),%esi
  80187a:	75 db                	jne    801857 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80187c:	89 f0                	mov    %esi,%eax
  80187e:	eb 05                	jmp    801885 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801880:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801885:	83 c4 1c             	add    $0x1c,%esp
  801888:	5b                   	pop    %ebx
  801889:	5e                   	pop    %esi
  80188a:	5f                   	pop    %edi
  80188b:	5d                   	pop    %ebp
  80188c:	c3                   	ret    

0080188d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	57                   	push   %edi
  801891:	56                   	push   %esi
  801892:	53                   	push   %ebx
  801893:	83 ec 3c             	sub    $0x3c,%esp
  801896:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801899:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80189c:	89 04 24             	mov    %eax,(%esp)
  80189f:	e8 47 f5 ff ff       	call   800deb <fd_alloc>
  8018a4:	89 c3                	mov    %eax,%ebx
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	0f 88 45 01 00 00    	js     8019f3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ae:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018b5:	00 
  8018b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018c4:	e8 8c f2 ff ff       	call   800b55 <sys_page_alloc>
  8018c9:	89 c3                	mov    %eax,%ebx
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	0f 88 20 01 00 00    	js     8019f3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	e8 0d f5 ff ff       	call   800deb <fd_alloc>
  8018de:	89 c3                	mov    %eax,%ebx
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	0f 88 f8 00 00 00    	js     8019e0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8018ef:	00 
  8018f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fe:	e8 52 f2 ff ff       	call   800b55 <sys_page_alloc>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	85 c0                	test   %eax,%eax
  801907:	0f 88 d3 00 00 00    	js     8019e0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80190d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801910:	89 04 24             	mov    %eax,(%esp)
  801913:	e8 b8 f4 ff ff       	call   800dd0 <fd2data>
  801918:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801921:	00 
  801922:	89 44 24 04          	mov    %eax,0x4(%esp)
  801926:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80192d:	e8 23 f2 ff ff       	call   800b55 <sys_page_alloc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	85 c0                	test   %eax,%eax
  801936:	0f 88 91 00 00 00    	js     8019cd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80193c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80193f:	89 04 24             	mov    %eax,(%esp)
  801942:	e8 89 f4 ff ff       	call   800dd0 <fd2data>
  801947:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80194e:	00 
  80194f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801953:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80195a:	00 
  80195b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80195f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801966:	e8 3e f2 ff ff       	call   800ba9 <sys_page_map>
  80196b:	89 c3                	mov    %eax,%ebx
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 4c                	js     8019bd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801971:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801977:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80197a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80197c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80197f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801986:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80198c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80198f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801991:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801994:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80199b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80199e:	89 04 24             	mov    %eax,(%esp)
  8019a1:	e8 1a f4 ff ff       	call   800dc0 <fd2num>
  8019a6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8019a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019ab:	89 04 24             	mov    %eax,(%esp)
  8019ae:	e8 0d f4 ff ff       	call   800dc0 <fd2num>
  8019b3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8019b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019bb:	eb 36                	jmp    8019f3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8019bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c8:	e8 2f f2 ff ff       	call   800bfc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8019cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019db:	e8 1c f2 ff ff       	call   800bfc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8019e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ee:	e8 09 f2 ff ff       	call   800bfc <sys_page_unmap>
    err:
	return r;
}
  8019f3:	89 d8                	mov    %ebx,%eax
  8019f5:	83 c4 3c             	add    $0x3c,%esp
  8019f8:	5b                   	pop    %ebx
  8019f9:	5e                   	pop    %esi
  8019fa:	5f                   	pop    %edi
  8019fb:	5d                   	pop    %ebp
  8019fc:	c3                   	ret    

008019fd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	89 04 24             	mov    %eax,(%esp)
  801a10:	e8 29 f4 ff ff       	call   800e3e <fd_lookup>
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 15                	js     801a2e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1c:	89 04 24             	mov    %eax,(%esp)
  801a1f:	e8 ac f3 ff ff       	call   800dd0 <fd2data>
	return _pipeisclosed(fd, p);
  801a24:	89 c2                	mov    %eax,%edx
  801a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a29:	e8 11 fd ff ff       	call   80173f <_pipeisclosed>
}
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a33:	b8 00 00 00 00       	mov    $0x0,%eax
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    

00801a3a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801a40:	c7 44 24 04 6a 24 80 	movl   $0x80246a,0x4(%esp)
  801a47:	00 
  801a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4b:	89 04 24             	mov    %eax,(%esp)
  801a4e:	e8 10 ed ff ff       	call   800763 <strcpy>
	return 0;
}
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
  801a58:	c9                   	leave  
  801a59:	c3                   	ret    

00801a5a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	57                   	push   %edi
  801a5e:	56                   	push   %esi
  801a5f:	53                   	push   %ebx
  801a60:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a66:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a6b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a71:	eb 30                	jmp    801aa3 <devcons_write+0x49>
		m = n - tot;
  801a73:	8b 75 10             	mov    0x10(%ebp),%esi
  801a76:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801a78:	83 fe 7f             	cmp    $0x7f,%esi
  801a7b:	76 05                	jbe    801a82 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801a7d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a82:	89 74 24 08          	mov    %esi,0x8(%esp)
  801a86:	03 45 0c             	add    0xc(%ebp),%eax
  801a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8d:	89 3c 24             	mov    %edi,(%esp)
  801a90:	e8 47 ee ff ff       	call   8008dc <memmove>
		sys_cputs(buf, m);
  801a95:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a99:	89 3c 24             	mov    %edi,(%esp)
  801a9c:	e8 e7 ef ff ff       	call   800a88 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aa1:	01 f3                	add    %esi,%ebx
  801aa3:	89 d8                	mov    %ebx,%eax
  801aa5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aa8:	72 c9                	jb     801a73 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801aaa:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5f                   	pop    %edi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801abb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801abf:	75 07                	jne    801ac8 <devcons_read+0x13>
  801ac1:	eb 25                	jmp    801ae8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ac3:	e8 6e f0 ff ff       	call   800b36 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ac8:	e8 d9 ef ff ff       	call   800aa6 <sys_cgetc>
  801acd:	85 c0                	test   %eax,%eax
  801acf:	74 f2                	je     801ac3 <devcons_read+0xe>
  801ad1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 1d                	js     801af4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ad7:	83 f8 04             	cmp    $0x4,%eax
  801ada:	74 13                	je     801aef <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adf:	88 10                	mov    %dl,(%eax)
	return 1;
  801ae1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ae6:	eb 0c                	jmp    801af4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  801aed:	eb 05                	jmp    801af4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801afc:	8b 45 08             	mov    0x8(%ebp),%eax
  801aff:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b02:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b09:	00 
  801b0a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b0d:	89 04 24             	mov    %eax,(%esp)
  801b10:	e8 73 ef ff ff       	call   800a88 <sys_cputs>
}
  801b15:	c9                   	leave  
  801b16:	c3                   	ret    

00801b17 <getchar>:

int
getchar(void)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b1d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801b24:	00 
  801b25:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b33:	e8 a4 f5 ff ff       	call   8010dc <read>
	if (r < 0)
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	78 0f                	js     801b4b <getchar+0x34>
		return r;
	if (r < 1)
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	7e 06                	jle    801b46 <getchar+0x2f>
		return -E_EOF;
	return c;
  801b40:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b44:	eb 05                	jmp    801b4b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b46:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b4b:	c9                   	leave  
  801b4c:	c3                   	ret    

00801b4d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	89 04 24             	mov    %eax,(%esp)
  801b60:	e8 d9 f2 ff ff       	call   800e3e <fd_lookup>
  801b65:	85 c0                	test   %eax,%eax
  801b67:	78 11                	js     801b7a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b72:	39 10                	cmp    %edx,(%eax)
  801b74:	0f 94 c0             	sete   %al
  801b77:	0f b6 c0             	movzbl %al,%eax
}
  801b7a:	c9                   	leave  
  801b7b:	c3                   	ret    

00801b7c <opencons>:

int
opencons(void)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b85:	89 04 24             	mov    %eax,(%esp)
  801b88:	e8 5e f2 ff ff       	call   800deb <fd_alloc>
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	78 3c                	js     801bcd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b91:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b98:	00 
  801b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba7:	e8 a9 ef ff ff       	call   800b55 <sys_page_alloc>
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 1d                	js     801bcd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bb0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bc5:	89 04 24             	mov    %eax,(%esp)
  801bc8:	e8 f3 f1 ff ff       	call   800dc0 <fd2num>
}
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    
	...

00801bd0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801bd8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801bdb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801be1:	e8 31 ef ff ff       	call   800b17 <sys_getenvid>
  801be6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801be9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801bed:	8b 55 08             	mov    0x8(%ebp),%edx
  801bf0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801bf4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfc:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  801c03:	e8 b0 e5 ff ff       	call   8001b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c08:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c0c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0f:	89 04 24             	mov    %eax,(%esp)
  801c12:	e8 40 e5 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801c17:	c7 04 24 ac 24 80 00 	movl   $0x8024ac,(%esp)
  801c1e:	e8 95 e5 ff ff       	call   8001b8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c23:	cc                   	int3   
  801c24:	eb fd                	jmp    801c23 <_panic+0x53>
	...

00801c28 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	83 ec 10             	sub    $0x10,%esp
  801c30:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c36:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c39:	85 c0                	test   %eax,%eax
  801c3b:	75 05                	jne    801c42 <ipc_recv+0x1a>
  801c3d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801c42:	89 04 24             	mov    %eax,(%esp)
  801c45:	e8 21 f1 ff ff       	call   800d6b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	79 16                	jns    801c64 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801c4e:	85 db                	test   %ebx,%ebx
  801c50:	74 06                	je     801c58 <ipc_recv+0x30>
  801c52:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801c58:	85 f6                	test   %esi,%esi
  801c5a:	74 32                	je     801c8e <ipc_recv+0x66>
  801c5c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c62:	eb 2a                	jmp    801c8e <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c64:	85 db                	test   %ebx,%ebx
  801c66:	74 0c                	je     801c74 <ipc_recv+0x4c>
  801c68:	a1 04 40 80 00       	mov    0x804004,%eax
  801c6d:	8b 00                	mov    (%eax),%eax
  801c6f:	8b 40 74             	mov    0x74(%eax),%eax
  801c72:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c74:	85 f6                	test   %esi,%esi
  801c76:	74 0c                	je     801c84 <ipc_recv+0x5c>
  801c78:	a1 04 40 80 00       	mov    0x804004,%eax
  801c7d:	8b 00                	mov    (%eax),%eax
  801c7f:	8b 40 78             	mov    0x78(%eax),%eax
  801c82:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c84:	a1 04 40 80 00       	mov    0x804004,%eax
  801c89:	8b 00                	mov    (%eax),%eax
  801c8b:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c8e:	83 c4 10             	add    $0x10,%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	57                   	push   %edi
  801c99:	56                   	push   %esi
  801c9a:	53                   	push   %ebx
  801c9b:	83 ec 1c             	sub    $0x1c,%esp
  801c9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ca4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801ca7:	85 db                	test   %ebx,%ebx
  801ca9:	75 05                	jne    801cb0 <ipc_send+0x1b>
  801cab:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801cb0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801cb4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cb8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 81 f0 ff ff       	call   800d48 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801cc7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cca:	75 07                	jne    801cd3 <ipc_send+0x3e>
  801ccc:	e8 65 ee ff ff       	call   800b36 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801cd1:	eb dd                	jmp    801cb0 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	79 1c                	jns    801cf3 <ipc_send+0x5e>
  801cd7:	c7 44 24 08 9c 24 80 	movl   $0x80249c,0x8(%esp)
  801cde:	00 
  801cdf:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801ce6:	00 
  801ce7:	c7 04 24 ae 24 80 00 	movl   $0x8024ae,(%esp)
  801cee:	e8 dd fe ff ff       	call   801bd0 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801cf3:	83 c4 1c             	add    $0x1c,%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5f                   	pop    %edi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	53                   	push   %ebx
  801cff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d02:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d07:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d0e:	89 c2                	mov    %eax,%edx
  801d10:	c1 e2 07             	shl    $0x7,%edx
  801d13:	29 ca                	sub    %ecx,%edx
  801d15:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d1b:	8b 52 50             	mov    0x50(%edx),%edx
  801d1e:	39 da                	cmp    %ebx,%edx
  801d20:	75 0f                	jne    801d31 <ipc_find_env+0x36>
			return envs[i].env_id;
  801d22:	c1 e0 07             	shl    $0x7,%eax
  801d25:	29 c8                	sub    %ecx,%eax
  801d27:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d2c:	8b 40 40             	mov    0x40(%eax),%eax
  801d2f:	eb 0c                	jmp    801d3d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d31:	40                   	inc    %eax
  801d32:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d37:	75 ce                	jne    801d07 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d39:	66 b8 00 00          	mov    $0x0,%ax
}
  801d3d:	5b                   	pop    %ebx
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801d46:	89 c2                	mov    %eax,%edx
  801d48:	c1 ea 16             	shr    $0x16,%edx
  801d4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d52:	f6 c2 01             	test   $0x1,%dl
  801d55:	74 1e                	je     801d75 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d57:	c1 e8 0c             	shr    $0xc,%eax
  801d5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d61:	a8 01                	test   $0x1,%al
  801d63:	74 17                	je     801d7c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d65:	c1 e8 0c             	shr    $0xc,%eax
  801d68:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d6f:	ef 
  801d70:	0f b7 c0             	movzwl %ax,%eax
  801d73:	eb 0c                	jmp    801d81 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d75:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7a:	eb 05                	jmp    801d81 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d7c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
	...

00801d84 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d84:	55                   	push   %ebp
  801d85:	57                   	push   %edi
  801d86:	56                   	push   %esi
  801d87:	83 ec 10             	sub    $0x10,%esp
  801d8a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d8e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d96:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d9a:	89 cd                	mov    %ecx,%ebp
  801d9c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801da0:	85 c0                	test   %eax,%eax
  801da2:	75 2c                	jne    801dd0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801da4:	39 f9                	cmp    %edi,%ecx
  801da6:	77 68                	ja     801e10 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801da8:	85 c9                	test   %ecx,%ecx
  801daa:	75 0b                	jne    801db7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dac:	b8 01 00 00 00       	mov    $0x1,%eax
  801db1:	31 d2                	xor    %edx,%edx
  801db3:	f7 f1                	div    %ecx
  801db5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801db7:	31 d2                	xor    %edx,%edx
  801db9:	89 f8                	mov    %edi,%eax
  801dbb:	f7 f1                	div    %ecx
  801dbd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dbf:	89 f0                	mov    %esi,%eax
  801dc1:	f7 f1                	div    %ecx
  801dc3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dc5:	89 f0                	mov    %esi,%eax
  801dc7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	5e                   	pop    %esi
  801dcd:	5f                   	pop    %edi
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dd0:	39 f8                	cmp    %edi,%eax
  801dd2:	77 2c                	ja     801e00 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801dd4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801dd7:	83 f6 1f             	xor    $0x1f,%esi
  801dda:	75 4c                	jne    801e28 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ddc:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801dde:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801de3:	72 0a                	jb     801def <__udivdi3+0x6b>
  801de5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801de9:	0f 87 ad 00 00 00    	ja     801e9c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801def:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801df4:	89 f0                	mov    %esi,%eax
  801df6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	5e                   	pop    %esi
  801dfc:	5f                   	pop    %edi
  801dfd:	5d                   	pop    %ebp
  801dfe:	c3                   	ret    
  801dff:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e00:	31 ff                	xor    %edi,%edi
  801e02:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e04:	89 f0                	mov    %esi,%eax
  801e06:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	5e                   	pop    %esi
  801e0c:	5f                   	pop    %edi
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    
  801e0f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e10:	89 fa                	mov    %edi,%edx
  801e12:	89 f0                	mov    %esi,%eax
  801e14:	f7 f1                	div    %ecx
  801e16:	89 c6                	mov    %eax,%esi
  801e18:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e1a:	89 f0                	mov    %esi,%eax
  801e1c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e1e:	83 c4 10             	add    $0x10,%esp
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    
  801e25:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e28:	89 f1                	mov    %esi,%ecx
  801e2a:	d3 e0                	shl    %cl,%eax
  801e2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e30:	b8 20 00 00 00       	mov    $0x20,%eax
  801e35:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e37:	89 ea                	mov    %ebp,%edx
  801e39:	88 c1                	mov    %al,%cl
  801e3b:	d3 ea                	shr    %cl,%edx
  801e3d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e41:	09 ca                	or     %ecx,%edx
  801e43:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801e47:	89 f1                	mov    %esi,%ecx
  801e49:	d3 e5                	shl    %cl,%ebp
  801e4b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801e4f:	89 fd                	mov    %edi,%ebp
  801e51:	88 c1                	mov    %al,%cl
  801e53:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801e55:	89 fa                	mov    %edi,%edx
  801e57:	89 f1                	mov    %esi,%ecx
  801e59:	d3 e2                	shl    %cl,%edx
  801e5b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e5f:	88 c1                	mov    %al,%cl
  801e61:	d3 ef                	shr    %cl,%edi
  801e63:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e65:	89 f8                	mov    %edi,%eax
  801e67:	89 ea                	mov    %ebp,%edx
  801e69:	f7 74 24 08          	divl   0x8(%esp)
  801e6d:	89 d1                	mov    %edx,%ecx
  801e6f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e71:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e75:	39 d1                	cmp    %edx,%ecx
  801e77:	72 17                	jb     801e90 <__udivdi3+0x10c>
  801e79:	74 09                	je     801e84 <__udivdi3+0x100>
  801e7b:	89 fe                	mov    %edi,%esi
  801e7d:	31 ff                	xor    %edi,%edi
  801e7f:	e9 41 ff ff ff       	jmp    801dc5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e84:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e88:	89 f1                	mov    %esi,%ecx
  801e8a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e8c:	39 c2                	cmp    %eax,%edx
  801e8e:	73 eb                	jae    801e7b <__udivdi3+0xf7>
		{
		  q0--;
  801e90:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e93:	31 ff                	xor    %edi,%edi
  801e95:	e9 2b ff ff ff       	jmp    801dc5 <__udivdi3+0x41>
  801e9a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e9c:	31 f6                	xor    %esi,%esi
  801e9e:	e9 22 ff ff ff       	jmp    801dc5 <__udivdi3+0x41>
	...

00801ea4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ea4:	55                   	push   %ebp
  801ea5:	57                   	push   %edi
  801ea6:	56                   	push   %esi
  801ea7:	83 ec 20             	sub    $0x20,%esp
  801eaa:	8b 44 24 30          	mov    0x30(%esp),%eax
  801eae:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801eb2:	89 44 24 14          	mov    %eax,0x14(%esp)
  801eb6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801eba:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ebe:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801ec2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801ec4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ec6:	85 ed                	test   %ebp,%ebp
  801ec8:	75 16                	jne    801ee0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801eca:	39 f1                	cmp    %esi,%ecx
  801ecc:	0f 86 a6 00 00 00    	jbe    801f78 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ed2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ed4:	89 d0                	mov    %edx,%eax
  801ed6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ed8:	83 c4 20             	add    $0x20,%esp
  801edb:	5e                   	pop    %esi
  801edc:	5f                   	pop    %edi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    
  801edf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ee0:	39 f5                	cmp    %esi,%ebp
  801ee2:	0f 87 ac 00 00 00    	ja     801f94 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ee8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801eeb:	83 f0 1f             	xor    $0x1f,%eax
  801eee:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ef2:	0f 84 a8 00 00 00    	je     801fa0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ef8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801efc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801efe:	bf 20 00 00 00       	mov    $0x20,%edi
  801f03:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f07:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f0b:	89 f9                	mov    %edi,%ecx
  801f0d:	d3 e8                	shr    %cl,%eax
  801f0f:	09 e8                	or     %ebp,%eax
  801f11:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801f15:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f19:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f1d:	d3 e0                	shl    %cl,%eax
  801f1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f23:	89 f2                	mov    %esi,%edx
  801f25:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f27:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f2b:	d3 e0                	shl    %cl,%eax
  801f2d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f31:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f35:	89 f9                	mov    %edi,%ecx
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f3b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f3d:	89 f2                	mov    %esi,%edx
  801f3f:	f7 74 24 18          	divl   0x18(%esp)
  801f43:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f45:	f7 64 24 0c          	mull   0xc(%esp)
  801f49:	89 c5                	mov    %eax,%ebp
  801f4b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f4d:	39 d6                	cmp    %edx,%esi
  801f4f:	72 67                	jb     801fb8 <__umoddi3+0x114>
  801f51:	74 75                	je     801fc8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f53:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f57:	29 e8                	sub    %ebp,%eax
  801f59:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f5b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f5f:	d3 e8                	shr    %cl,%eax
  801f61:	89 f2                	mov    %esi,%edx
  801f63:	89 f9                	mov    %edi,%ecx
  801f65:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f67:	09 d0                	or     %edx,%eax
  801f69:	89 f2                	mov    %esi,%edx
  801f6b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f6f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f71:	83 c4 20             	add    $0x20,%esp
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f78:	85 c9                	test   %ecx,%ecx
  801f7a:	75 0b                	jne    801f87 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f81:	31 d2                	xor    %edx,%edx
  801f83:	f7 f1                	div    %ecx
  801f85:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f87:	89 f0                	mov    %esi,%eax
  801f89:	31 d2                	xor    %edx,%edx
  801f8b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f8d:	89 f8                	mov    %edi,%eax
  801f8f:	e9 3e ff ff ff       	jmp    801ed2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f94:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f96:	83 c4 20             	add    $0x20,%esp
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    
  801f9d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fa0:	39 f5                	cmp    %esi,%ebp
  801fa2:	72 04                	jb     801fa8 <__umoddi3+0x104>
  801fa4:	39 f9                	cmp    %edi,%ecx
  801fa6:	77 06                	ja     801fae <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fa8:	89 f2                	mov    %esi,%edx
  801faa:	29 cf                	sub    %ecx,%edi
  801fac:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801fae:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fb0:	83 c4 20             	add    $0x20,%esp
  801fb3:	5e                   	pop    %esi
  801fb4:	5f                   	pop    %edi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    
  801fb7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801fb8:	89 d1                	mov    %edx,%ecx
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801fc0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801fc4:	eb 8d                	jmp    801f53 <__umoddi3+0xaf>
  801fc6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fc8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801fcc:	72 ea                	jb     801fb8 <__umoddi3+0x114>
  801fce:	89 f1                	mov    %esi,%ecx
  801fd0:	eb 81                	jmp    801f53 <__umoddi3+0xaf>
