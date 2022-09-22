
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
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
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	c7 04 24 00 16 80 00 	movl   $0x801600,(%esp)
  800042:	e8 85 01 00 00       	call   8001cc <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 2b 0f 00 00       	call   800f77 <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 78 16 80 00 	movl   $0x801678,(%esp)
  800059:	e8 6e 01 00 00       	call   8001cc <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 28 16 80 00 	movl   $0x801628,(%esp)
  800067:	e8 60 01 00 00       	call   8001cc <cprintf>
	sys_yield();
  80006c:	e8 d9 0a 00 00       	call   800b4a <sys_yield>
	sys_yield();
  800071:	e8 d4 0a 00 00       	call   800b4a <sys_yield>
	sys_yield();
  800076:	e8 cf 0a 00 00       	call   800b4a <sys_yield>
	sys_yield();
  80007b:	e8 ca 0a 00 00       	call   800b4a <sys_yield>
	sys_yield();
  800080:	e8 c5 0a 00 00       	call   800b4a <sys_yield>
	sys_yield();
  800085:	e8 c0 0a 00 00       	call   800b4a <sys_yield>
	sys_yield();
  80008a:	e8 bb 0a 00 00       	call   800b4a <sys_yield>
	sys_yield();
  80008f:	e8 b6 0a 00 00       	call   800b4a <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 50 16 80 00 	movl   $0x801650,(%esp)
  80009b:	e8 2c 01 00 00       	call   8001cc <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 31 0a 00 00       	call   800ad9 <sys_env_destroy>
}
  8000a8:	83 c4 14             	add    $0x14,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
	...

008000b0 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 20             	sub    $0x20,%esp
  8000b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8000be:	e8 68 0a 00 00       	call   800b2b <sys_getenvid>
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000cf:	c1 e0 07             	shl    $0x7,%eax
  8000d2:	29 d0                	sub    %edx,%eax
  8000d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000df:	a3 04 20 80 00       	mov    %eax,0x802004
  8000e4:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  8000e8:	c7 04 24 43 19 80 00 	movl   $0x801943,(%esp)
  8000ef:	e8 d8 00 00 00       	call   8001cc <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f4:	85 f6                	test   %esi,%esi
  8000f6:	7e 07                	jle    8000ff <libmain+0x4f>
		binaryname = argv[0];
  8000f8:	8b 03                	mov    (%ebx),%eax
  8000fa:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800103:	89 34 24             	mov    %esi,(%esp)
  800106:	e8 29 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80010b:	e8 08 00 00 00       	call   800118 <exit>
}
  800110:	83 c4 20             	add    $0x20,%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    
	...

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800125:	e8 af 09 00 00       	call   800ad9 <sys_env_destroy>
}
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	53                   	push   %ebx
  800130:	83 ec 14             	sub    $0x14,%esp
  800133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800136:	8b 03                	mov    (%ebx),%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013f:	40                   	inc    %eax
  800140:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800142:	3d ff 00 00 00       	cmp    $0xff,%eax
  800147:	75 19                	jne    800162 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800149:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800150:	00 
  800151:	8d 43 08             	lea    0x8(%ebx),%eax
  800154:	89 04 24             	mov    %eax,(%esp)
  800157:	e8 40 09 00 00       	call   800a9c <sys_cputs>
		b->idx = 0;
  80015c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800162:	ff 43 04             	incl   0x4(%ebx)
}
  800165:	83 c4 14             	add    $0x14,%esp
  800168:	5b                   	pop    %ebx
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800174:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017b:	00 00 00 
	b.cnt = 0;
  80017e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800185:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018f:	8b 45 08             	mov    0x8(%ebp),%eax
  800192:	89 44 24 08          	mov    %eax,0x8(%esp)
  800196:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a0:	c7 04 24 2c 01 80 00 	movl   $0x80012c,(%esp)
  8001a7:	e8 82 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bc:	89 04 24             	mov    %eax,(%esp)
  8001bf:	e8 d8 08 00 00       	call   800a9c <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dc:	89 04 24             	mov    %eax,(%esp)
  8001df:	e8 87 ff ff ff       	call   80016b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    
	...

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 3c             	sub    $0x3c,%esp
  8001f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f4:	89 d7                	mov    %edx,%edi
  8001f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800202:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800205:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800208:	85 c0                	test   %eax,%eax
  80020a:	75 08                	jne    800214 <printnum+0x2c>
  80020c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80020f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800212:	77 57                	ja     80026b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800214:	89 74 24 10          	mov    %esi,0x10(%esp)
  800218:	4b                   	dec    %ebx
  800219:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80021d:	8b 45 10             	mov    0x10(%ebp),%eax
  800220:	89 44 24 08          	mov    %eax,0x8(%esp)
  800224:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800228:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80022c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800233:	00 
  800234:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800237:	89 04 24             	mov    %eax,(%esp)
  80023a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	e8 52 11 00 00       	call   801398 <__udivdi3>
  800246:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	89 54 24 04          	mov    %edx,0x4(%esp)
  800255:	89 fa                	mov    %edi,%edx
  800257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025a:	e8 89 ff ff ff       	call   8001e8 <printnum>
  80025f:	eb 0f                	jmp    800270 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800265:	89 34 24             	mov    %esi,(%esp)
  800268:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026b:	4b                   	dec    %ebx
  80026c:	85 db                	test   %ebx,%ebx
  80026e:	7f f1                	jg     800261 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800270:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800274:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800278:	8b 45 10             	mov    0x10(%ebp),%eax
  80027b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800286:	00 
  800287:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800290:	89 44 24 04          	mov    %eax,0x4(%esp)
  800294:	e8 1f 12 00 00       	call   8014b8 <__umoddi3>
  800299:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029d:	0f be 80 a0 16 80 00 	movsbl 0x8016a0(%eax),%eax
  8002a4:	89 04 24             	mov    %eax,(%esp)
  8002a7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002aa:	83 c4 3c             	add    $0x3c,%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b5:	83 fa 01             	cmp    $0x1,%edx
  8002b8:	7e 0e                	jle    8002c8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bf:	89 08                	mov    %ecx,(%eax)
  8002c1:	8b 02                	mov    (%edx),%eax
  8002c3:	8b 52 04             	mov    0x4(%edx),%edx
  8002c6:	eb 22                	jmp    8002ea <getuint+0x38>
	else if (lflag)
  8002c8:	85 d2                	test   %edx,%edx
  8002ca:	74 10                	je     8002dc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002da:	eb 0e                	jmp    8002ea <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 08                	jae    800304 <sprintputch+0x18>
		*b->buf++ = ch;
  8002fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ff:	88 0a                	mov    %cl,(%edx)
  800301:	42                   	inc    %edx
  800302:	89 10                	mov    %edx,(%eax)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800313:	8b 45 10             	mov    0x10(%ebp),%eax
  800316:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	e8 02 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 4c             	sub    $0x4c,%esp
  800337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033a:	8b 75 10             	mov    0x10(%ebp),%esi
  80033d:	eb 12                	jmp    800351 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033f:	85 c0                	test   %eax,%eax
  800341:	0f 84 6b 03 00 00    	je     8006b2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800347:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80034b:	89 04 24             	mov    %eax,(%esp)
  80034e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800351:	0f b6 06             	movzbl (%esi),%eax
  800354:	46                   	inc    %esi
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e5                	jne    80033f <vprintfmt+0x11>
  80035a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80035e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800365:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80036a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800371:	b9 00 00 00 00       	mov    $0x0,%ecx
  800376:	eb 26                	jmp    80039e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80037f:	eb 1d                	jmp    80039e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800384:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800388:	eb 14                	jmp    80039e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80038d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800394:	eb 08                	jmp    80039e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800396:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800399:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	0f b6 06             	movzbl (%esi),%eax
  8003a1:	8d 56 01             	lea    0x1(%esi),%edx
  8003a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003a7:	8a 16                	mov    (%esi),%dl
  8003a9:	83 ea 23             	sub    $0x23,%edx
  8003ac:	80 fa 55             	cmp    $0x55,%dl
  8003af:	0f 87 e1 02 00 00    	ja     800696 <vprintfmt+0x368>
  8003b5:	0f b6 d2             	movzbl %dl,%edx
  8003b8:	ff 24 95 60 17 80 00 	jmp    *0x801760(,%edx,4)
  8003bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003c2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003ca:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ce:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d4:	83 fa 09             	cmp    $0x9,%edx
  8003d7:	77 2a                	ja     800403 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003da:	eb eb                	jmp    8003c7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 50 04             	lea    0x4(%eax),%edx
  8003e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ea:	eb 17                	jmp    800403 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f0:	78 98                	js     80038a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003f5:	eb a7                	jmp    80039e <vprintfmt+0x70>
  8003f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800401:	eb 9b                	jmp    80039e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800403:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800407:	79 95                	jns    80039e <vprintfmt+0x70>
  800409:	eb 8b                	jmp    800396 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040f:	eb 8d                	jmp    80039e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041e:	8b 00                	mov    (%eax),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800429:	e9 23 ff ff ff       	jmp    800351 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	85 c0                	test   %eax,%eax
  80043b:	79 02                	jns    80043f <vprintfmt+0x111>
  80043d:	f7 d8                	neg    %eax
  80043f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800441:	83 f8 08             	cmp    $0x8,%eax
  800444:	7f 0b                	jg     800451 <vprintfmt+0x123>
  800446:	8b 04 85 c0 18 80 00 	mov    0x8018c0(,%eax,4),%eax
  80044d:	85 c0                	test   %eax,%eax
  80044f:	75 23                	jne    800474 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800451:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800455:	c7 44 24 08 b8 16 80 	movl   $0x8016b8,0x8(%esp)
  80045c:	00 
  80045d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800461:	8b 45 08             	mov    0x8(%ebp),%eax
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	e8 9a fe ff ff       	call   800306 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046f:	e9 dd fe ff ff       	jmp    800351 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800474:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800478:	c7 44 24 08 c1 16 80 	movl   $0x8016c1,0x8(%esp)
  80047f:	00 
  800480:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800484:	8b 55 08             	mov    0x8(%ebp),%edx
  800487:	89 14 24             	mov    %edx,(%esp)
  80048a:	e8 77 fe ff ff       	call   800306 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800492:	e9 ba fe ff ff       	jmp    800351 <vprintfmt+0x23>
  800497:	89 f9                	mov    %edi,%ecx
  800499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 50 04             	lea    0x4(%eax),%edx
  8004a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a8:	8b 30                	mov    (%eax),%esi
  8004aa:	85 f6                	test   %esi,%esi
  8004ac:	75 05                	jne    8004b3 <vprintfmt+0x185>
				p = "(null)";
  8004ae:	be b1 16 80 00       	mov    $0x8016b1,%esi
			if (width > 0 && padc != '-')
  8004b3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b7:	0f 8e 84 00 00 00    	jle    800541 <vprintfmt+0x213>
  8004bd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004c1:	74 7e                	je     800541 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c7:	89 34 24             	mov    %esi,(%esp)
  8004ca:	e8 8b 02 00 00       	call   80075a <strnlen>
  8004cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004d2:	29 c2                	sub    %eax,%edx
  8004d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004d7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004db:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004de:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004e1:	89 de                	mov    %ebx,%esi
  8004e3:	89 d3                	mov    %edx,%ebx
  8004e5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	eb 0b                	jmp    8004f4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ed:	89 3c 24             	mov    %edi,(%esp)
  8004f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	4b                   	dec    %ebx
  8004f4:	85 db                	test   %ebx,%ebx
  8004f6:	7f f1                	jg     8004e9 <vprintfmt+0x1bb>
  8004f8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004fb:	89 f3                	mov    %esi,%ebx
  8004fd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800500:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800503:	85 c0                	test   %eax,%eax
  800505:	79 05                	jns    80050c <vprintfmt+0x1de>
  800507:	b8 00 00 00 00       	mov    $0x0,%eax
  80050c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050f:	29 c2                	sub    %eax,%edx
  800511:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800514:	eb 2b                	jmp    800541 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800516:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80051a:	74 18                	je     800534 <vprintfmt+0x206>
  80051c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80051f:	83 fa 5e             	cmp    $0x5e,%edx
  800522:	76 10                	jbe    800534 <vprintfmt+0x206>
					putch('?', putdat);
  800524:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800528:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80052f:	ff 55 08             	call   *0x8(%ebp)
  800532:	eb 0a                	jmp    80053e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800534:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053e:	ff 4d e4             	decl   -0x1c(%ebp)
  800541:	0f be 06             	movsbl (%esi),%eax
  800544:	46                   	inc    %esi
  800545:	85 c0                	test   %eax,%eax
  800547:	74 21                	je     80056a <vprintfmt+0x23c>
  800549:	85 ff                	test   %edi,%edi
  80054b:	78 c9                	js     800516 <vprintfmt+0x1e8>
  80054d:	4f                   	dec    %edi
  80054e:	79 c6                	jns    800516 <vprintfmt+0x1e8>
  800550:	8b 7d 08             	mov    0x8(%ebp),%edi
  800553:	89 de                	mov    %ebx,%esi
  800555:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800558:	eb 18                	jmp    800572 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80055e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800565:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800567:	4b                   	dec    %ebx
  800568:	eb 08                	jmp    800572 <vprintfmt+0x244>
  80056a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80056d:	89 de                	mov    %ebx,%esi
  80056f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800572:	85 db                	test   %ebx,%ebx
  800574:	7f e4                	jg     80055a <vprintfmt+0x22c>
  800576:	89 7d 08             	mov    %edi,0x8(%ebp)
  800579:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80057e:	e9 ce fd ff ff       	jmp    800351 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800583:	83 f9 01             	cmp    $0x1,%ecx
  800586:	7e 10                	jle    800598 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 08             	lea    0x8(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 30                	mov    (%eax),%esi
  800593:	8b 78 04             	mov    0x4(%eax),%edi
  800596:	eb 26                	jmp    8005be <vprintfmt+0x290>
	else if (lflag)
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	74 12                	je     8005ae <vprintfmt+0x280>
		return va_arg(*ap, long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 30                	mov    (%eax),%esi
  8005a7:	89 f7                	mov    %esi,%edi
  8005a9:	c1 ff 1f             	sar    $0x1f,%edi
  8005ac:	eb 10                	jmp    8005be <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 30                	mov    (%eax),%esi
  8005b9:	89 f7                	mov    %esi,%edi
  8005bb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005be:	85 ff                	test   %edi,%edi
  8005c0:	78 0a                	js     8005cc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c7:	e9 8c 00 00 00       	jmp    800658 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005da:	f7 de                	neg    %esi
  8005dc:	83 d7 00             	adc    $0x0,%edi
  8005df:	f7 df                	neg    %edi
			}
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e6:	eb 70                	jmp    800658 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e8:	89 ca                	mov    %ecx,%edx
  8005ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ed:	e8 c0 fc ff ff       	call   8002b2 <getuint>
  8005f2:	89 c6                	mov    %eax,%esi
  8005f4:	89 d7                	mov    %edx,%edi
			base = 10;
  8005f6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005fb:	eb 5b                	jmp    800658 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005fd:	89 ca                	mov    %ecx,%edx
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 ab fc ff ff       	call   8002b2 <getuint>
  800607:	89 c6                	mov    %eax,%esi
  800609:	89 d7                	mov    %edx,%edi
			base = 8;
  80060b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800610:	eb 46                	jmp    800658 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800612:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800616:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80061d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800637:	8b 30                	mov    (%eax),%esi
  800639:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80063e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800643:	eb 13                	jmp    800658 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800645:	89 ca                	mov    %ecx,%edx
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 63 fc ff ff       	call   8002b2 <getuint>
  80064f:	89 c6                	mov    %eax,%esi
  800651:	89 d7                	mov    %edx,%edi
			base = 16;
  800653:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800658:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80065c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800660:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800663:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800667:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066b:	89 34 24             	mov    %esi,(%esp)
  80066e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800672:	89 da                	mov    %ebx,%edx
  800674:	8b 45 08             	mov    0x8(%ebp),%eax
  800677:	e8 6c fb ff ff       	call   8001e8 <printnum>
			break;
  80067c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067f:	e9 cd fc ff ff       	jmp    800351 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800688:	89 04 24             	mov    %eax,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800691:	e9 bb fc ff ff       	jmp    800351 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800696:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a4:	eb 01                	jmp    8006a7 <vprintfmt+0x379>
  8006a6:	4e                   	dec    %esi
  8006a7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ab:	75 f9                	jne    8006a6 <vprintfmt+0x378>
  8006ad:	e9 9f fc ff ff       	jmp    800351 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006b2:	83 c4 4c             	add    $0x4c,%esp
  8006b5:	5b                   	pop    %ebx
  8006b6:	5e                   	pop    %esi
  8006b7:	5f                   	pop    %edi
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 28             	sub    $0x28,%esp
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	74 30                	je     80070b <vsnprintf+0x51>
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	7e 33                	jle    800712 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f4:	c7 04 24 ec 02 80 00 	movl   $0x8002ec,(%esp)
  8006fb:	e8 2e fc ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800700:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800703:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800709:	eb 0c                	jmp    800717 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800710:	eb 05                	jmp    800717 <vsnprintf+0x5d>
  800712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800717:	c9                   	leave  
  800718:	c3                   	ret    

00800719 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800722:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800726:	8b 45 10             	mov    0x10(%ebp),%eax
  800729:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800730:	89 44 24 04          	mov    %eax,0x4(%esp)
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	89 04 24             	mov    %eax,(%esp)
  80073a:	e8 7b ff ff ff       	call   8006ba <vsnprintf>
	va_end(ap);

	return rc;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    
  800741:	00 00                	add    %al,(%eax)
	...

00800744 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
  80074f:	eb 01                	jmp    800752 <strlen+0xe>
		n++;
  800751:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800756:	75 f9                	jne    800751 <strlen+0xd>
		n++;
	return n;
}
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800760:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	eb 01                	jmp    80076b <strnlen+0x11>
		n++;
  80076a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	39 d0                	cmp    %edx,%eax
  80076d:	74 06                	je     800775 <strnlen+0x1b>
  80076f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800773:	75 f5                	jne    80076a <strnlen+0x10>
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	ba 00 00 00 00       	mov    $0x0,%edx
  800786:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800789:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80078c:	42                   	inc    %edx
  80078d:	84 c9                	test   %cl,%cl
  80078f:	75 f5                	jne    800786 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800791:	5b                   	pop    %ebx
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079e:	89 1c 24             	mov    %ebx,(%esp)
  8007a1:	e8 9e ff ff ff       	call   800744 <strlen>
	strcpy(dst + len, src);
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ad:	01 d8                	add    %ebx,%eax
  8007af:	89 04 24             	mov    %eax,(%esp)
  8007b2:	e8 c0 ff ff ff       	call   800777 <strcpy>
	return dst;
}
  8007b7:	89 d8                	mov    %ebx,%eax
  8007b9:	83 c4 08             	add    $0x8,%esp
  8007bc:	5b                   	pop    %ebx
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	56                   	push   %esi
  8007c3:	53                   	push   %ebx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d2:	eb 0c                	jmp    8007e0 <strncpy+0x21>
		*dst++ = *src;
  8007d4:	8a 1a                	mov    (%edx),%bl
  8007d6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d9:	80 3a 01             	cmpb   $0x1,(%edx)
  8007dc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007df:	41                   	inc    %ecx
  8007e0:	39 f1                	cmp    %esi,%ecx
  8007e2:	75 f0                	jne    8007d4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	75 0a                	jne    800804 <strlcpy+0x1c>
  8007fa:	89 f0                	mov    %esi,%eax
  8007fc:	eb 1a                	jmp    800818 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fe:	88 18                	mov    %bl,(%eax)
  800800:	40                   	inc    %eax
  800801:	41                   	inc    %ecx
  800802:	eb 02                	jmp    800806 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800804:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800806:	4a                   	dec    %edx
  800807:	74 0a                	je     800813 <strlcpy+0x2b>
  800809:	8a 19                	mov    (%ecx),%bl
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ef                	jne    8007fe <strlcpy+0x16>
  80080f:	89 c2                	mov    %eax,%edx
  800811:	eb 02                	jmp    800815 <strlcpy+0x2d>
  800813:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800815:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800818:	29 f0                	sub    %esi,%eax
}
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800827:	eb 02                	jmp    80082b <strcmp+0xd>
		p++, q++;
  800829:	41                   	inc    %ecx
  80082a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082b:	8a 01                	mov    (%ecx),%al
  80082d:	84 c0                	test   %al,%al
  80082f:	74 04                	je     800835 <strcmp+0x17>
  800831:	3a 02                	cmp    (%edx),%al
  800833:	74 f4                	je     800829 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800835:	0f b6 c0             	movzbl %al,%eax
  800838:	0f b6 12             	movzbl (%edx),%edx
  80083b:	29 d0                	sub    %edx,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800849:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80084c:	eb 03                	jmp    800851 <strncmp+0x12>
		n--, p++, q++;
  80084e:	4a                   	dec    %edx
  80084f:	40                   	inc    %eax
  800850:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800851:	85 d2                	test   %edx,%edx
  800853:	74 14                	je     800869 <strncmp+0x2a>
  800855:	8a 18                	mov    (%eax),%bl
  800857:	84 db                	test   %bl,%bl
  800859:	74 04                	je     80085f <strncmp+0x20>
  80085b:	3a 19                	cmp    (%ecx),%bl
  80085d:	74 ef                	je     80084e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085f:	0f b6 00             	movzbl (%eax),%eax
  800862:	0f b6 11             	movzbl (%ecx),%edx
  800865:	29 d0                	sub    %edx,%eax
  800867:	eb 05                	jmp    80086e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800869:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80086e:	5b                   	pop    %ebx
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087a:	eb 05                	jmp    800881 <strchr+0x10>
		if (*s == c)
  80087c:	38 ca                	cmp    %cl,%dl
  80087e:	74 0c                	je     80088c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800880:	40                   	inc    %eax
  800881:	8a 10                	mov    (%eax),%dl
  800883:	84 d2                	test   %dl,%dl
  800885:	75 f5                	jne    80087c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
  800894:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800897:	eb 05                	jmp    80089e <strfind+0x10>
		if (*s == c)
  800899:	38 ca                	cmp    %cl,%dl
  80089b:	74 07                	je     8008a4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80089d:	40                   	inc    %eax
  80089e:	8a 10                	mov    (%eax),%dl
  8008a0:	84 d2                	test   %dl,%dl
  8008a2:	75 f5                	jne    800899 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	57                   	push   %edi
  8008aa:	56                   	push   %esi
  8008ab:	53                   	push   %ebx
  8008ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b5:	85 c9                	test   %ecx,%ecx
  8008b7:	74 30                	je     8008e9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bf:	75 25                	jne    8008e6 <memset+0x40>
  8008c1:	f6 c1 03             	test   $0x3,%cl
  8008c4:	75 20                	jne    8008e6 <memset+0x40>
		c &= 0xFF;
  8008c6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c9:	89 d3                	mov    %edx,%ebx
  8008cb:	c1 e3 08             	shl    $0x8,%ebx
  8008ce:	89 d6                	mov    %edx,%esi
  8008d0:	c1 e6 18             	shl    $0x18,%esi
  8008d3:	89 d0                	mov    %edx,%eax
  8008d5:	c1 e0 10             	shl    $0x10,%eax
  8008d8:	09 f0                	or     %esi,%eax
  8008da:	09 d0                	or     %edx,%eax
  8008dc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008de:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008e1:	fc                   	cld    
  8008e2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e4:	eb 03                	jmp    8008e9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e6:	fc                   	cld    
  8008e7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e9:	89 f8                	mov    %edi,%eax
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5f                   	pop    %edi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	57                   	push   %edi
  8008f4:	56                   	push   %esi
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fe:	39 c6                	cmp    %eax,%esi
  800900:	73 34                	jae    800936 <memmove+0x46>
  800902:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800905:	39 d0                	cmp    %edx,%eax
  800907:	73 2d                	jae    800936 <memmove+0x46>
		s += n;
		d += n;
  800909:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090c:	f6 c2 03             	test   $0x3,%dl
  80090f:	75 1b                	jne    80092c <memmove+0x3c>
  800911:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800917:	75 13                	jne    80092c <memmove+0x3c>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 0e                	jne    80092c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80091e:	83 ef 04             	sub    $0x4,%edi
  800921:	8d 72 fc             	lea    -0x4(%edx),%esi
  800924:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800927:	fd                   	std    
  800928:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092a:	eb 07                	jmp    800933 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092c:	4f                   	dec    %edi
  80092d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800930:	fd                   	std    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800933:	fc                   	cld    
  800934:	eb 20                	jmp    800956 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093c:	75 13                	jne    800951 <memmove+0x61>
  80093e:	a8 03                	test   $0x3,%al
  800940:	75 0f                	jne    800951 <memmove+0x61>
  800942:	f6 c1 03             	test   $0x3,%cl
  800945:	75 0a                	jne    800951 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800947:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	fc                   	cld    
  80094d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094f:	eb 05                	jmp    800956 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800951:	89 c7                	mov    %eax,%edi
  800953:	fc                   	cld    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800960:	8b 45 10             	mov    0x10(%ebp),%eax
  800963:	89 44 24 08          	mov    %eax,0x8(%esp)
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	89 04 24             	mov    %eax,(%esp)
  800974:	e8 77 ff ff ff       	call   8008f0 <memmove>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 75 0c             	mov    0xc(%ebp),%esi
  800987:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098a:	ba 00 00 00 00       	mov    $0x0,%edx
  80098f:	eb 16                	jmp    8009a7 <memcmp+0x2c>
		if (*s1 != *s2)
  800991:	8a 04 17             	mov    (%edi,%edx,1),%al
  800994:	42                   	inc    %edx
  800995:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800999:	38 c8                	cmp    %cl,%al
  80099b:	74 0a                	je     8009a7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80099d:	0f b6 c0             	movzbl %al,%eax
  8009a0:	0f b6 c9             	movzbl %cl,%ecx
  8009a3:	29 c8                	sub    %ecx,%eax
  8009a5:	eb 09                	jmp    8009b0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a7:	39 da                	cmp    %ebx,%edx
  8009a9:	75 e6                	jne    800991 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5f                   	pop    %edi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009be:	89 c2                	mov    %eax,%edx
  8009c0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c3:	eb 05                	jmp    8009ca <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c5:	38 08                	cmp    %cl,(%eax)
  8009c7:	74 05                	je     8009ce <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c9:	40                   	inc    %eax
  8009ca:	39 d0                	cmp    %edx,%eax
  8009cc:	72 f7                	jb     8009c5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dc:	eb 01                	jmp    8009df <strtol+0xf>
		s++;
  8009de:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009df:	8a 02                	mov    (%edx),%al
  8009e1:	3c 20                	cmp    $0x20,%al
  8009e3:	74 f9                	je     8009de <strtol+0xe>
  8009e5:	3c 09                	cmp    $0x9,%al
  8009e7:	74 f5                	je     8009de <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e9:	3c 2b                	cmp    $0x2b,%al
  8009eb:	75 08                	jne    8009f5 <strtol+0x25>
		s++;
  8009ed:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ee:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f3:	eb 13                	jmp    800a08 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f5:	3c 2d                	cmp    $0x2d,%al
  8009f7:	75 0a                	jne    800a03 <strtol+0x33>
		s++, neg = 1;
  8009f9:	8d 52 01             	lea    0x1(%edx),%edx
  8009fc:	bf 01 00 00 00       	mov    $0x1,%edi
  800a01:	eb 05                	jmp    800a08 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a08:	85 db                	test   %ebx,%ebx
  800a0a:	74 05                	je     800a11 <strtol+0x41>
  800a0c:	83 fb 10             	cmp    $0x10,%ebx
  800a0f:	75 28                	jne    800a39 <strtol+0x69>
  800a11:	8a 02                	mov    (%edx),%al
  800a13:	3c 30                	cmp    $0x30,%al
  800a15:	75 10                	jne    800a27 <strtol+0x57>
  800a17:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a1b:	75 0a                	jne    800a27 <strtol+0x57>
		s += 2, base = 16;
  800a1d:	83 c2 02             	add    $0x2,%edx
  800a20:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a25:	eb 12                	jmp    800a39 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a27:	85 db                	test   %ebx,%ebx
  800a29:	75 0e                	jne    800a39 <strtol+0x69>
  800a2b:	3c 30                	cmp    $0x30,%al
  800a2d:	75 05                	jne    800a34 <strtol+0x64>
		s++, base = 8;
  800a2f:	42                   	inc    %edx
  800a30:	b3 08                	mov    $0x8,%bl
  800a32:	eb 05                	jmp    800a39 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a34:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a40:	8a 0a                	mov    (%edx),%cl
  800a42:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a45:	80 fb 09             	cmp    $0x9,%bl
  800a48:	77 08                	ja     800a52 <strtol+0x82>
			dig = *s - '0';
  800a4a:	0f be c9             	movsbl %cl,%ecx
  800a4d:	83 e9 30             	sub    $0x30,%ecx
  800a50:	eb 1e                	jmp    800a70 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a52:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a55:	80 fb 19             	cmp    $0x19,%bl
  800a58:	77 08                	ja     800a62 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a5a:	0f be c9             	movsbl %cl,%ecx
  800a5d:	83 e9 57             	sub    $0x57,%ecx
  800a60:	eb 0e                	jmp    800a70 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a62:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a65:	80 fb 19             	cmp    $0x19,%bl
  800a68:	77 12                	ja     800a7c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a6a:	0f be c9             	movsbl %cl,%ecx
  800a6d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a70:	39 f1                	cmp    %esi,%ecx
  800a72:	7d 0c                	jge    800a80 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a74:	42                   	inc    %edx
  800a75:	0f af c6             	imul   %esi,%eax
  800a78:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a7a:	eb c4                	jmp    800a40 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a7c:	89 c1                	mov    %eax,%ecx
  800a7e:	eb 02                	jmp    800a82 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a80:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a86:	74 05                	je     800a8d <strtol+0xbd>
		*endptr = (char *) s;
  800a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a8b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a8d:	85 ff                	test   %edi,%edi
  800a8f:	74 04                	je     800a95 <strtol+0xc5>
  800a91:	89 c8                	mov    %ecx,%eax
  800a93:	f7 d8                	neg    %eax
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    
	...

00800a9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800aad:	89 c3                	mov    %eax,%ebx
  800aaf:	89 c7                	mov    %eax,%edi
  800ab1:	89 c6                	mov    %eax,%esi
  800ab3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cgetc>:

int
sys_cgetc(void)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aca:	89 d1                	mov    %edx,%ecx
  800acc:	89 d3                	mov    %edx,%ebx
  800ace:	89 d7                	mov    %edx,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae7:	b8 03 00 00 00       	mov    $0x3,%eax
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	89 cb                	mov    %ecx,%ebx
  800af1:	89 cf                	mov    %ecx,%edi
  800af3:	89 ce                	mov    %ecx,%esi
  800af5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af7:	85 c0                	test   %eax,%eax
  800af9:	7e 28                	jle    800b23 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aff:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b06:	00 
  800b07:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800b0e:	00 
  800b0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b16:	00 
  800b17:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800b1e:	e8 65 07 00 00       	call   801288 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b23:	83 c4 2c             	add    $0x2c,%esp
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b31:	ba 00 00 00 00       	mov    $0x0,%edx
  800b36:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3b:	89 d1                	mov    %edx,%ecx
  800b3d:	89 d3                	mov    %edx,%ebx
  800b3f:	89 d7                	mov    %edx,%edi
  800b41:	89 d6                	mov    %edx,%esi
  800b43:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_yield>:

void
sys_yield(void)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b72:	be 00 00 00 00       	mov    $0x0,%esi
  800b77:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b82:	8b 55 08             	mov    0x8(%ebp),%edx
  800b85:	89 f7                	mov    %esi,%edi
  800b87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b89:	85 c0                	test   %eax,%eax
  800b8b:	7e 28                	jle    800bb5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b91:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b98:	00 
  800b99:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800ba0:	00 
  800ba1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba8:	00 
  800ba9:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800bb0:	e8 d3 06 00 00       	call   801288 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb5:	83 c4 2c             	add    $0x2c,%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 28                	jle    800c08 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800beb:	00 
  800bec:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800bf3:	00 
  800bf4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfb:	00 
  800bfc:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800c03:	e8 80 06 00 00       	call   801288 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c08:	83 c4 2c             	add    $0x2c,%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 df                	mov    %ebx,%edi
  800c2b:	89 de                	mov    %ebx,%esi
  800c2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 28                	jle    800c5b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c37:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800c46:	00 
  800c47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4e:	00 
  800c4f:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800c56:	e8 2d 06 00 00       	call   801288 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5b:	83 c4 2c             	add    $0x2c,%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c71:	b8 08 00 00 00       	mov    $0x8,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	89 df                	mov    %ebx,%edi
  800c7e:	89 de                	mov    %ebx,%esi
  800c80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 28                	jle    800cae <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c91:	00 
  800c92:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800c99:	00 
  800c9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca1:	00 
  800ca2:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800ca9:	e8 da 05 00 00       	call   801288 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cae:	83 c4 2c             	add    $0x2c,%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	89 df                	mov    %ebx,%edi
  800cd1:	89 de                	mov    %ebx,%esi
  800cd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 28                	jle    800d01 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ce4:	00 
  800ce5:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800cec:	00 
  800ced:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf4:	00 
  800cf5:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800cfc:	e8 87 05 00 00       	call   801288 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d01:	83 c4 2c             	add    $0x2c,%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	be 00 00 00 00       	mov    $0x0,%esi
  800d14:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 cb                	mov    %ecx,%ebx
  800d44:	89 cf                	mov    %ecx,%edi
  800d46:	89 ce                	mov    %ecx,%esi
  800d48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 28                	jle    800d76 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d52:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d59:	00 
  800d5a:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800d61:	00 
  800d62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d69:	00 
  800d6a:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800d71:	e8 12 05 00 00       	call   801288 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d76:	83 c4 2c             	add    $0x2c,%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
	...

00800d80 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 3c             	sub    $0x3c,%esp
  800d89:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800d8c:	89 d6                	mov    %edx,%esi
  800d8e:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800d91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d98:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800d9b:	e8 8b fd ff ff       	call   800b2b <sys_getenvid>
  800da0:	89 c7                	mov    %eax,%edi
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800da2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800da5:	25 02 08 00 00       	and    $0x802,%eax
  800daa:	83 f8 01             	cmp    $0x1,%eax
  800dad:	19 db                	sbb    %ebx,%ebx
  800daf:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800db5:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800dbb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800dbf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dc6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dce:	89 3c 24             	mov    %edi,(%esp)
  800dd1:	e8 e7 fd ff ff       	call   800bbd <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	79 1c                	jns    800df6 <duppage+0x76>
  800dda:	c7 44 24 08 0f 19 80 	movl   $0x80190f,0x8(%esp)
  800de1:	00 
  800de2:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  800de9:	00 
  800dea:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800df1:	e8 92 04 00 00       	call   801288 <_panic>
	if ((perm|~pte)&PTE_COW){
  800df6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800df9:	f7 d0                	not    %eax
  800dfb:	09 d8                	or     %ebx,%eax
  800dfd:	f6 c4 08             	test   $0x8,%ah
  800e00:	74 38                	je     800e3a <duppage+0xba>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800e02:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e06:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e0a:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e12:	89 3c 24             	mov    %edi,(%esp)
  800e15:	e8 a3 fd ff ff       	call   800bbd <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	79 1c                	jns    800e3a <duppage+0xba>
  800e1e:	c7 44 24 08 0f 19 80 	movl   $0x80190f,0x8(%esp)
  800e25:	00 
  800e26:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  800e2d:	00 
  800e2e:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800e35:	e8 4e 04 00 00       	call   801288 <_panic>
	}
	return 0;
	panic("duppage not implemented");
	return 0;
}
  800e3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3f:	83 c4 3c             	add    $0x3c,%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 20             	sub    $0x20,%esp
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e52:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800e54:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e58:	75 1c                	jne    800e76 <pgfault+0x2f>
		panic("pgfault: error!\n");
  800e5a:	c7 44 24 08 2b 19 80 	movl   $0x80192b,0x8(%esp)
  800e61:	00 
  800e62:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800e69:	00 
  800e6a:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800e71:	e8 12 04 00 00       	call   801288 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800e76:	89 f0                	mov    %esi,%eax
  800e78:	c1 e8 0c             	shr    $0xc,%eax
  800e7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e82:	f6 c4 08             	test   $0x8,%ah
  800e85:	75 1c                	jne    800ea3 <pgfault+0x5c>
		panic("pgfault: error!\n");
  800e87:	c7 44 24 08 2b 19 80 	movl   $0x80192b,0x8(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800e96:	00 
  800e97:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800e9e:	e8 e5 03 00 00       	call   801288 <_panic>
	envid_t envid = sys_getenvid();
  800ea3:	e8 83 fc ff ff       	call   800b2b <sys_getenvid>
  800ea8:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800eaa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800eb9:	00 
  800eba:	89 04 24             	mov    %eax,(%esp)
  800ebd:	e8 a7 fc ff ff       	call   800b69 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	79 1c                	jns    800ee2 <pgfault+0x9b>
  800ec6:	c7 44 24 08 2b 19 80 	movl   $0x80192b,0x8(%esp)
  800ecd:	00 
  800ece:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800ed5:	00 
  800ed6:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800edd:	e8 a6 03 00 00       	call   801288 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800ee2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  800ee8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800eef:	00 
  800ef0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800efb:	e8 5a fa ff ff       	call   80095a <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  800f00:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f07:	00 
  800f08:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f0c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f10:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f17:	00 
  800f18:	89 1c 24             	mov    %ebx,(%esp)
  800f1b:	e8 9d fc ff ff       	call   800bbd <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  800f20:	85 c0                	test   %eax,%eax
  800f22:	79 1c                	jns    800f40 <pgfault+0xf9>
  800f24:	c7 44 24 08 2b 19 80 	movl   $0x80192b,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800f3b:	e8 48 03 00 00       	call   801288 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  800f40:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f47:	00 
  800f48:	89 1c 24             	mov    %ebx,(%esp)
  800f4b:	e8 c0 fc ff ff       	call   800c10 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  800f50:	85 c0                	test   %eax,%eax
  800f52:	79 1c                	jns    800f70 <pgfault+0x129>
  800f54:	c7 44 24 08 2b 19 80 	movl   $0x80192b,0x8(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800f63:	00 
  800f64:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800f6b:	e8 18 03 00 00       	call   801288 <_panic>
	return;
	panic("pgfault not implemented");
}
  800f70:	83 c4 20             	add    $0x20,%esp
  800f73:	5b                   	pop    %ebx
  800f74:	5e                   	pop    %esi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f80:	c7 04 24 47 0e 80 00 	movl   $0x800e47,(%esp)
  800f87:	e8 54 03 00 00       	call   8012e0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f8c:	bf 07 00 00 00       	mov    $0x7,%edi
  800f91:	89 f8                	mov    %edi,%eax
  800f93:	cd 30                	int    $0x30
  800f95:	89 c7                	mov    %eax,%edi
  800f97:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	79 1c                	jns    800fb9 <fork+0x42>
		panic("fork : error!\n");
  800f9d:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800fac:	00 
  800fad:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  800fb4:	e8 cf 02 00 00       	call   801288 <_panic>
	if (envid==0){
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	75 28                	jne    800fe5 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  800fbd:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800fc3:	e8 63 fb ff ff       	call   800b2b <sys_getenvid>
  800fc8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fcd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fd4:	c1 e0 07             	shl    $0x7,%eax
  800fd7:	29 d0                	sub    %edx,%eax
  800fd9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fde:	89 03                	mov    %eax,(%ebx)
		return envid;
  800fe0:	e9 f2 00 00 00       	jmp    8010d7 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  800fe5:	e8 41 fb ff ff       	call   800b2b <sys_getenvid>
  800fea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  800fed:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  800ff2:	89 d8                	mov    %ebx,%eax
  800ff4:	c1 e8 16             	shr    $0x16,%eax
  800ff7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffe:	a8 01                	test   $0x1,%al
  801000:	74 17                	je     801019 <fork+0xa2>
  801002:	89 da                	mov    %ebx,%edx
  801004:	c1 ea 0c             	shr    $0xc,%edx
  801007:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80100e:	a8 01                	test   $0x1,%al
  801010:	74 07                	je     801019 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801012:	89 f0                	mov    %esi,%eax
  801014:	e8 67 fd ff ff       	call   800d80 <duppage>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801019:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801025:	75 cb                	jne    800ff2 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801027:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80102e:	00 
  80102f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801036:	ee 
  801037:	89 3c 24             	mov    %edi,(%esp)
  80103a:	e8 2a fb ff ff       	call   800b69 <sys_page_alloc>
  80103f:	85 c0                	test   %eax,%eax
  801041:	79 1c                	jns    80105f <fork+0xe8>
  801043:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  80104a:	00 
  80104b:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  801052:	00 
  801053:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  80105a:	e8 29 02 00 00       	call   801288 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  80105f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801062:	25 ff 03 00 00       	and    $0x3ff,%eax
  801067:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80106e:	c1 e0 07             	shl    $0x7,%eax
  801071:	29 d0                	sub    %edx,%eax
  801073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801078:	8b 40 64             	mov    0x64(%eax),%eax
  80107b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107f:	89 3c 24             	mov    %edi,(%esp)
  801082:	e8 2f fc ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
  801087:	85 c0                	test   %eax,%eax
  801089:	79 1c                	jns    8010a7 <fork+0x130>
  80108b:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  801092:	00 
  801093:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  80109a:	00 
  80109b:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  8010a2:	e8 e1 01 00 00       	call   801288 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8010a7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8010ae:	00 
  8010af:	89 3c 24             	mov    %edi,(%esp)
  8010b2:	e8 ac fb ff ff       	call   800c63 <sys_env_set_status>
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	79 1c                	jns    8010d7 <fork+0x160>
  8010bb:	c7 44 24 08 48 19 80 	movl   $0x801948,0x8(%esp)
  8010c2:	00 
  8010c3:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  8010ca:	00 
  8010cb:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  8010d2:	e8 b1 01 00 00       	call   801288 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  8010d7:	89 f8                	mov    %edi,%eax
  8010d9:	83 c4 2c             	add    $0x2c,%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8010ea:	c7 04 24 47 0e 80 00 	movl   $0x800e47,(%esp)
  8010f1:	e8 ea 01 00 00       	call   8012e0 <set_pgfault_handler>
  8010f6:	ba 07 00 00 00       	mov    $0x7,%edx
  8010fb:	89 d0                	mov    %edx,%eax
  8010fd:	cd 30                	int    $0x30
  8010ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801102:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801104:	89 44 24 04          	mov    %eax,0x4(%esp)
  801108:	c7 04 24 3c 19 80 00 	movl   $0x80193c,(%esp)
  80110f:	e8 b8 f0 ff ff       	call   8001cc <cprintf>
	if (envid<0)
  801114:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801118:	79 1c                	jns    801136 <sfork+0x55>
		panic("sfork : error!\n");
  80111a:	c7 44 24 08 47 19 80 	movl   $0x801947,0x8(%esp)
  801121:	00 
  801122:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801129:	00 
  80112a:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  801131:	e8 52 01 00 00       	call   801288 <_panic>
	if (envid==0){
  801136:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80113a:	75 28                	jne    801164 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  80113c:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  801142:	e8 e4 f9 ff ff       	call   800b2b <sys_getenvid>
  801147:	25 ff 03 00 00       	and    $0x3ff,%eax
  80114c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801153:	c1 e0 07             	shl    $0x7,%eax
  801156:	29 d0                	sub    %edx,%eax
  801158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115d:	89 03                	mov    %eax,(%ebx)
		return envid;
  80115f:	e9 18 01 00 00       	jmp    80127c <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801164:	e8 c2 f9 ff ff       	call   800b2b <sys_getenvid>
  801169:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80116b:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801170:	89 d8                	mov    %ebx,%eax
  801172:	c1 e8 16             	shr    $0x16,%eax
  801175:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80117c:	a8 01                	test   $0x1,%al
  80117e:	74 2c                	je     8011ac <sfork+0xcb>
  801180:	89 d8                	mov    %ebx,%eax
  801182:	c1 e8 0c             	shr    $0xc,%eax
  801185:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118c:	a8 01                	test   $0x1,%al
  80118e:	74 1c                	je     8011ac <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  801190:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801197:	00 
  801198:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80119c:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a4:	89 3c 24             	mov    %edi,(%esp)
  8011a7:	e8 11 fa ff ff       	call   800bbd <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8011ac:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011b2:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8011b8:	75 b6                	jne    801170 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  8011ba:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  8011bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c2:	e8 b9 fb ff ff       	call   800d80 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  8011c7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011ce:	00 
  8011cf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011d6:	ee 
  8011d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011da:	89 04 24             	mov    %eax,(%esp)
  8011dd:	e8 87 f9 ff ff       	call   800b69 <sys_page_alloc>
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	79 1c                	jns    801202 <sfork+0x121>
  8011e6:	c7 44 24 08 47 19 80 	movl   $0x801947,0x8(%esp)
  8011ed:	00 
  8011ee:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8011f5:	00 
  8011f6:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  8011fd:	e8 86 00 00 00       	call   801288 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  801202:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801208:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  80120f:	c1 e7 07             	shl    $0x7,%edi
  801212:	29 d7                	sub    %edx,%edi
  801214:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80121a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801221:	89 04 24             	mov    %eax,(%esp)
  801224:	e8 8d fa ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
  801229:	85 c0                	test   %eax,%eax
  80122b:	79 1c                	jns    801249 <sfork+0x168>
  80122d:	c7 44 24 08 47 19 80 	movl   $0x801947,0x8(%esp)
  801234:	00 
  801235:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  80123c:	00 
  80123d:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  801244:	e8 3f 00 00 00       	call   801288 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  801249:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801250:	00 
  801251:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801254:	89 04 24             	mov    %eax,(%esp)
  801257:	e8 07 fa ff ff       	call   800c63 <sys_env_set_status>
  80125c:	85 c0                	test   %eax,%eax
  80125e:	79 1c                	jns    80127c <sfork+0x19b>
  801260:	c7 44 24 08 47 19 80 	movl   $0x801947,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  80126f:	00 
  801270:	c7 04 24 20 19 80 00 	movl   $0x801920,(%esp)
  801277:	e8 0c 00 00 00       	call   801288 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  80127c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127f:	83 c4 3c             	add    $0x3c,%esp
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    
	...

00801288 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801290:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801293:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801299:	e8 8d f8 ff ff       	call   800b2b <sys_getenvid>
  80129e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b4:	c7 04 24 58 19 80 00 	movl   $0x801958,(%esp)
  8012bb:	e8 0c ef ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c7:	89 04 24             	mov    %eax,(%esp)
  8012ca:	e8 9c ee ff ff       	call   80016b <vcprintf>
	cprintf("\n");
  8012cf:	c7 04 24 55 19 80 00 	movl   $0x801955,(%esp)
  8012d6:	e8 f1 ee ff ff       	call   8001cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012db:	cc                   	int3   
  8012dc:	eb fd                	jmp    8012db <_panic+0x53>
	...

008012e0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012e7:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8012ee:	75 6f                	jne    80135f <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8012f0:	e8 36 f8 ff ff       	call   800b2b <sys_getenvid>
  8012f5:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8012f7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012fe:	00 
  8012ff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801306:	ee 
  801307:	89 04 24             	mov    %eax,(%esp)
  80130a:	e8 5a f8 ff ff       	call   800b69 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  80130f:	85 c0                	test   %eax,%eax
  801311:	79 1c                	jns    80132f <set_pgfault_handler+0x4f>
  801313:	c7 44 24 08 7c 19 80 	movl   $0x80197c,0x8(%esp)
  80131a:	00 
  80131b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801322:	00 
  801323:	c7 04 24 d8 19 80 00 	movl   $0x8019d8,(%esp)
  80132a:	e8 59 ff ff ff       	call   801288 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80132f:	c7 44 24 04 70 13 80 	movl   $0x801370,0x4(%esp)
  801336:	00 
  801337:	89 1c 24             	mov    %ebx,(%esp)
  80133a:	e8 77 f9 ff ff       	call   800cb6 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  80133f:	85 c0                	test   %eax,%eax
  801341:	79 1c                	jns    80135f <set_pgfault_handler+0x7f>
  801343:	c7 44 24 08 a4 19 80 	movl   $0x8019a4,0x8(%esp)
  80134a:	00 
  80134b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801352:	00 
  801353:	c7 04 24 d8 19 80 00 	movl   $0x8019d8,(%esp)
  80135a:	e8 29 ff ff ff       	call   801288 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80135f:	8b 45 08             	mov    0x8(%ebp),%eax
  801362:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801367:	83 c4 14             	add    $0x14,%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    
  80136d:	00 00                	add    %al,(%eax)
	...

00801370 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801370:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801371:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801376:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801378:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  80137b:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  80137f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  801384:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  801388:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  80138a:	83 c4 08             	add    $0x8,%esp
	popal
  80138d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  80138e:	83 c4 04             	add    $0x4,%esp
	popfl
  801391:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  801392:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801395:	c3                   	ret    
	...

00801398 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801398:	55                   	push   %ebp
  801399:	57                   	push   %edi
  80139a:	56                   	push   %esi
  80139b:	83 ec 10             	sub    $0x10,%esp
  80139e:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013a2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8013a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013aa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8013ae:	89 cd                	mov    %ecx,%ebp
  8013b0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	75 2c                	jne    8013e4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8013b8:	39 f9                	cmp    %edi,%ecx
  8013ba:	77 68                	ja     801424 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8013bc:	85 c9                	test   %ecx,%ecx
  8013be:	75 0b                	jne    8013cb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8013c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c5:	31 d2                	xor    %edx,%edx
  8013c7:	f7 f1                	div    %ecx
  8013c9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	89 f8                	mov    %edi,%eax
  8013cf:	f7 f1                	div    %ecx
  8013d1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013d3:	89 f0                	mov    %esi,%eax
  8013d5:	f7 f1                	div    %ecx
  8013d7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013d9:	89 f0                	mov    %esi,%eax
  8013db:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	5e                   	pop    %esi
  8013e1:	5f                   	pop    %edi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8013e4:	39 f8                	cmp    %edi,%eax
  8013e6:	77 2c                	ja     801414 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8013e8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8013eb:	83 f6 1f             	xor    $0x1f,%esi
  8013ee:	75 4c                	jne    80143c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8013f0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8013f2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8013f7:	72 0a                	jb     801403 <__udivdi3+0x6b>
  8013f9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8013fd:	0f 87 ad 00 00 00    	ja     8014b0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801403:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801408:	89 f0                	mov    %esi,%eax
  80140a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    
  801413:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801414:	31 ff                	xor    %edi,%edi
  801416:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801418:	89 f0                	mov    %esi,%eax
  80141a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	5e                   	pop    %esi
  801420:	5f                   	pop    %edi
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    
  801423:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801424:	89 fa                	mov    %edi,%edx
  801426:	89 f0                	mov    %esi,%eax
  801428:	f7 f1                	div    %ecx
  80142a:	89 c6                	mov    %eax,%esi
  80142c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80142e:	89 f0                	mov    %esi,%eax
  801430:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	5e                   	pop    %esi
  801436:	5f                   	pop    %edi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    
  801439:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80143c:	89 f1                	mov    %esi,%ecx
  80143e:	d3 e0                	shl    %cl,%eax
  801440:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801444:	b8 20 00 00 00       	mov    $0x20,%eax
  801449:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80144b:	89 ea                	mov    %ebp,%edx
  80144d:	88 c1                	mov    %al,%cl
  80144f:	d3 ea                	shr    %cl,%edx
  801451:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801455:	09 ca                	or     %ecx,%edx
  801457:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80145b:	89 f1                	mov    %esi,%ecx
  80145d:	d3 e5                	shl    %cl,%ebp
  80145f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801463:	89 fd                	mov    %edi,%ebp
  801465:	88 c1                	mov    %al,%cl
  801467:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801469:	89 fa                	mov    %edi,%edx
  80146b:	89 f1                	mov    %esi,%ecx
  80146d:	d3 e2                	shl    %cl,%edx
  80146f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801473:	88 c1                	mov    %al,%cl
  801475:	d3 ef                	shr    %cl,%edi
  801477:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801479:	89 f8                	mov    %edi,%eax
  80147b:	89 ea                	mov    %ebp,%edx
  80147d:	f7 74 24 08          	divl   0x8(%esp)
  801481:	89 d1                	mov    %edx,%ecx
  801483:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801485:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801489:	39 d1                	cmp    %edx,%ecx
  80148b:	72 17                	jb     8014a4 <__udivdi3+0x10c>
  80148d:	74 09                	je     801498 <__udivdi3+0x100>
  80148f:	89 fe                	mov    %edi,%esi
  801491:	31 ff                	xor    %edi,%edi
  801493:	e9 41 ff ff ff       	jmp    8013d9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801498:	8b 54 24 04          	mov    0x4(%esp),%edx
  80149c:	89 f1                	mov    %esi,%ecx
  80149e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014a0:	39 c2                	cmp    %eax,%edx
  8014a2:	73 eb                	jae    80148f <__udivdi3+0xf7>
		{
		  q0--;
  8014a4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8014a7:	31 ff                	xor    %edi,%edi
  8014a9:	e9 2b ff ff ff       	jmp    8013d9 <__udivdi3+0x41>
  8014ae:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014b0:	31 f6                	xor    %esi,%esi
  8014b2:	e9 22 ff ff ff       	jmp    8013d9 <__udivdi3+0x41>
	...

008014b8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8014b8:	55                   	push   %ebp
  8014b9:	57                   	push   %edi
  8014ba:	56                   	push   %esi
  8014bb:	83 ec 20             	sub    $0x20,%esp
  8014be:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014c2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8014c6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8014ca:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8014ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014d2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8014d6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8014d8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8014da:	85 ed                	test   %ebp,%ebp
  8014dc:	75 16                	jne    8014f4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8014de:	39 f1                	cmp    %esi,%ecx
  8014e0:	0f 86 a6 00 00 00    	jbe    80158c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014e6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8014e8:	89 d0                	mov    %edx,%eax
  8014ea:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8014ec:	83 c4 20             	add    $0x20,%esp
  8014ef:	5e                   	pop    %esi
  8014f0:	5f                   	pop    %edi
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    
  8014f3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8014f4:	39 f5                	cmp    %esi,%ebp
  8014f6:	0f 87 ac 00 00 00    	ja     8015a8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8014fc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8014ff:	83 f0 1f             	xor    $0x1f,%eax
  801502:	89 44 24 10          	mov    %eax,0x10(%esp)
  801506:	0f 84 a8 00 00 00    	je     8015b4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80150c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801510:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801512:	bf 20 00 00 00       	mov    $0x20,%edi
  801517:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80151b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80151f:	89 f9                	mov    %edi,%ecx
  801521:	d3 e8                	shr    %cl,%eax
  801523:	09 e8                	or     %ebp,%eax
  801525:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801529:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80152d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801531:	d3 e0                	shl    %cl,%eax
  801533:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801537:	89 f2                	mov    %esi,%edx
  801539:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80153b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80153f:	d3 e0                	shl    %cl,%eax
  801541:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801545:	8b 44 24 14          	mov    0x14(%esp),%eax
  801549:	89 f9                	mov    %edi,%ecx
  80154b:	d3 e8                	shr    %cl,%eax
  80154d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80154f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801551:	89 f2                	mov    %esi,%edx
  801553:	f7 74 24 18          	divl   0x18(%esp)
  801557:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801559:	f7 64 24 0c          	mull   0xc(%esp)
  80155d:	89 c5                	mov    %eax,%ebp
  80155f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801561:	39 d6                	cmp    %edx,%esi
  801563:	72 67                	jb     8015cc <__umoddi3+0x114>
  801565:	74 75                	je     8015dc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801567:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80156b:	29 e8                	sub    %ebp,%eax
  80156d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80156f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801573:	d3 e8                	shr    %cl,%eax
  801575:	89 f2                	mov    %esi,%edx
  801577:	89 f9                	mov    %edi,%ecx
  801579:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80157b:	09 d0                	or     %edx,%eax
  80157d:	89 f2                	mov    %esi,%edx
  80157f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801583:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801585:	83 c4 20             	add    $0x20,%esp
  801588:	5e                   	pop    %esi
  801589:	5f                   	pop    %edi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80158c:	85 c9                	test   %ecx,%ecx
  80158e:	75 0b                	jne    80159b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801590:	b8 01 00 00 00       	mov    $0x1,%eax
  801595:	31 d2                	xor    %edx,%edx
  801597:	f7 f1                	div    %ecx
  801599:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80159b:	89 f0                	mov    %esi,%eax
  80159d:	31 d2                	xor    %edx,%edx
  80159f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8015a1:	89 f8                	mov    %edi,%eax
  8015a3:	e9 3e ff ff ff       	jmp    8014e6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8015a8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015aa:	83 c4 20             	add    $0x20,%esp
  8015ad:	5e                   	pop    %esi
  8015ae:	5f                   	pop    %edi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    
  8015b1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015b4:	39 f5                	cmp    %esi,%ebp
  8015b6:	72 04                	jb     8015bc <__umoddi3+0x104>
  8015b8:	39 f9                	cmp    %edi,%ecx
  8015ba:	77 06                	ja     8015c2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8015bc:	89 f2                	mov    %esi,%edx
  8015be:	29 cf                	sub    %ecx,%edi
  8015c0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8015c2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015c4:	83 c4 20             	add    $0x20,%esp
  8015c7:	5e                   	pop    %esi
  8015c8:	5f                   	pop    %edi
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    
  8015cb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8015cc:	89 d1                	mov    %edx,%ecx
  8015ce:	89 c5                	mov    %eax,%ebp
  8015d0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8015d4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8015d8:	eb 8d                	jmp    801567 <__umoddi3+0xaf>
  8015da:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015dc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8015e0:	72 ea                	jb     8015cc <__umoddi3+0x114>
  8015e2:	89 f1                	mov    %esi,%ecx
  8015e4:	eb 81                	jmp    801567 <__umoddi3+0xaf>
