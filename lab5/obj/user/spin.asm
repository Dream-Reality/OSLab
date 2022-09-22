
obj/user/spin.debug:     file format elf32-i386


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
  80003b:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  800042:	e8 7d 01 00 00       	call   8001c4 <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 b8 0f 00 00       	call   801004 <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 58 26 80 00 	movl   $0x802658,(%esp)
  800059:	e8 66 01 00 00       	call   8001c4 <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 08 26 80 00 	movl   $0x802608,(%esp)
  800067:	e8 58 01 00 00       	call   8001c4 <cprintf>
	sys_yield();
  80006c:	e8 d1 0a 00 00       	call   800b42 <sys_yield>
	sys_yield();
  800071:	e8 cc 0a 00 00       	call   800b42 <sys_yield>
	sys_yield();
  800076:	e8 c7 0a 00 00       	call   800b42 <sys_yield>
	sys_yield();
  80007b:	e8 c2 0a 00 00       	call   800b42 <sys_yield>
	sys_yield();
  800080:	e8 bd 0a 00 00       	call   800b42 <sys_yield>
	sys_yield();
  800085:	e8 b8 0a 00 00       	call   800b42 <sys_yield>
	sys_yield();
  80008a:	e8 b3 0a 00 00       	call   800b42 <sys_yield>
	sys_yield();
  80008f:	e8 ae 0a 00 00       	call   800b42 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 30 26 80 00 	movl   $0x802630,(%esp)
  80009b:	e8 24 01 00 00       	call   8001c4 <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 29 0a 00 00       	call   800ad1 <sys_env_destroy>
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
  8000be:	e8 60 0a 00 00       	call   800b23 <sys_getenvid>
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000cf:	c1 e0 07             	shl    $0x7,%eax
  8000d2:	29 d0                	sub    %edx,%eax
  8000d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8000dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000df:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e4:	85 f6                	test   %esi,%esi
  8000e6:	7e 07                	jle    8000ef <libmain+0x3f>
		binaryname = argv[0];
  8000e8:	8b 03                	mov    (%ebx),%eax
  8000ea:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f3:	89 34 24             	mov    %esi,(%esp)
  8000f6:	e8 39 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000fb:	e8 08 00 00 00       	call   800108 <exit>
}
  800100:	83 c4 20             	add    $0x20,%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    
	...

00800108 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80010e:	e8 ea 13 00 00       	call   8014fd <close_all>
	sys_env_destroy(0);
  800113:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80011a:	e8 b2 09 00 00       	call   800ad1 <sys_env_destroy>
}
  80011f:	c9                   	leave  
  800120:	c3                   	ret    
  800121:	00 00                	add    %al,(%eax)
	...

00800124 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	53                   	push   %ebx
  800128:	83 ec 14             	sub    $0x14,%esp
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800137:	40                   	inc    %eax
  800138:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80013a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013f:	75 19                	jne    80015a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800141:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800148:	00 
  800149:	8d 43 08             	lea    0x8(%ebx),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 40 09 00 00       	call   800a94 <sys_cputs>
		b->idx = 0;
  800154:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80015a:	ff 43 04             	incl   0x4(%ebx)
}
  80015d:	83 c4 14             	add    $0x14,%esp
  800160:	5b                   	pop    %ebx
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	8b 45 0c             	mov    0xc(%ebp),%eax
  800183:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800187:	8b 45 08             	mov    0x8(%ebp),%eax
  80018a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 24 01 80 00 	movl   $0x800124,(%esp)
  80019f:	e8 82 01 00 00       	call   800326 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b4:	89 04 24             	mov    %eax,(%esp)
  8001b7:	e8 d8 08 00 00       	call   800a94 <sys_cputs>

	return b.cnt;
}
  8001bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 87 ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001dc:	c9                   	leave  
  8001dd:	c3                   	ret    
	...

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 3c             	sub    $0x3c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d7                	mov    %edx,%edi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800200:	85 c0                	test   %eax,%eax
  800202:	75 08                	jne    80020c <printnum+0x2c>
  800204:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800207:	39 45 10             	cmp    %eax,0x10(%ebp)
  80020a:	77 57                	ja     800263 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800210:	4b                   	dec    %ebx
  800211:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800215:	8b 45 10             	mov    0x10(%ebp),%eax
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800220:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800224:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022b:	00 
  80022c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022f:	89 04 24             	mov    %eax,(%esp)
  800232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800235:	89 44 24 04          	mov    %eax,0x4(%esp)
  800239:	e8 52 21 00 00       	call   802390 <__udivdi3>
  80023e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800242:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800246:	89 04 24             	mov    %eax,(%esp)
  800249:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024d:	89 fa                	mov    %edi,%edx
  80024f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800252:	e8 89 ff ff ff       	call   8001e0 <printnum>
  800257:	eb 0f                	jmp    800268 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800259:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025d:	89 34 24             	mov    %esi,(%esp)
  800260:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800263:	4b                   	dec    %ebx
  800264:	85 db                	test   %ebx,%ebx
  800266:	7f f1                	jg     800259 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800268:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800270:	8b 45 10             	mov    0x10(%ebp),%eax
  800273:	89 44 24 08          	mov    %eax,0x8(%esp)
  800277:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027e:	00 
  80027f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800282:	89 04 24             	mov    %eax,(%esp)
  800285:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	e8 1f 22 00 00       	call   8024b0 <__umoddi3>
  800291:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800295:	0f be 80 80 26 80 00 	movsbl 0x802680(%eax),%eax
  80029c:	89 04 24             	mov    %eax,(%esp)
  80029f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002a2:	83 c4 3c             	add    $0x3c,%esp
  8002a5:	5b                   	pop    %ebx
  8002a6:	5e                   	pop    %esi
  8002a7:	5f                   	pop    %edi
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ad:	83 fa 01             	cmp    $0x1,%edx
  8002b0:	7e 0e                	jle    8002c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b2:	8b 10                	mov    (%eax),%edx
  8002b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b7:	89 08                	mov    %ecx,(%eax)
  8002b9:	8b 02                	mov    (%edx),%eax
  8002bb:	8b 52 04             	mov    0x4(%edx),%edx
  8002be:	eb 22                	jmp    8002e2 <getuint+0x38>
	else if (lflag)
  8002c0:	85 d2                	test   %edx,%edx
  8002c2:	74 10                	je     8002d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 02                	mov    (%edx),%eax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d2:	eb 0e                	jmp    8002e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    

008002e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ea:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f2:	73 08                	jae    8002fc <sprintputch+0x18>
		*b->buf++ = ch;
  8002f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f7:	88 0a                	mov    %cl,(%edx)
  8002f9:	42                   	inc    %edx
  8002fa:	89 10                	mov    %edx,(%eax)
}
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    

008002fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800304:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800307:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80030b:	8b 45 10             	mov    0x10(%ebp),%eax
  80030e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800312:	8b 45 0c             	mov    0xc(%ebp),%eax
  800315:	89 44 24 04          	mov    %eax,0x4(%esp)
  800319:	8b 45 08             	mov    0x8(%ebp),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	e8 02 00 00 00       	call   800326 <vprintfmt>
	va_end(ap);
}
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	57                   	push   %edi
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
  80032c:	83 ec 4c             	sub    $0x4c,%esp
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 75 10             	mov    0x10(%ebp),%esi
  800335:	eb 12                	jmp    800349 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	0f 84 6b 03 00 00    	je     8006aa <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80033f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	0f b6 06             	movzbl (%esi),%eax
  80034c:	46                   	inc    %esi
  80034d:	83 f8 25             	cmp    $0x25,%eax
  800350:	75 e5                	jne    800337 <vprintfmt+0x11>
  800352:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800356:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80035d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800362:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800369:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036e:	eb 26                	jmp    800396 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800373:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800377:	eb 1d                	jmp    800396 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800380:	eb 14                	jmp    800396 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800382:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800385:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80038c:	eb 08                	jmp    800396 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800391:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	0f b6 06             	movzbl (%esi),%eax
  800399:	8d 56 01             	lea    0x1(%esi),%edx
  80039c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80039f:	8a 16                	mov    (%esi),%dl
  8003a1:	83 ea 23             	sub    $0x23,%edx
  8003a4:	80 fa 55             	cmp    $0x55,%dl
  8003a7:	0f 87 e1 02 00 00    	ja     80068e <vprintfmt+0x368>
  8003ad:	0f b6 d2             	movzbl %dl,%edx
  8003b0:	ff 24 95 c0 27 80 00 	jmp    *0x8027c0(,%edx,4)
  8003b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ba:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003c2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003c6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003cc:	83 fa 09             	cmp    $0x9,%edx
  8003cf:	77 2a                	ja     8003fb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d2:	eb eb                	jmp    8003bf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e2:	eb 17                	jmp    8003fb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e8:	78 98                	js     800382 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ed:	eb a7                	jmp    800396 <vprintfmt+0x70>
  8003ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f9:	eb 9b                	jmp    800396 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ff:	79 95                	jns    800396 <vprintfmt+0x70>
  800401:	eb 8b                	jmp    80038e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800403:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800407:	eb 8d                	jmp    800396 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 50 04             	lea    0x4(%eax),%edx
  80040f:	89 55 14             	mov    %edx,0x14(%ebp)
  800412:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800421:	e9 23 ff ff ff       	jmp    800349 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 50 04             	lea    0x4(%eax),%edx
  80042c:	89 55 14             	mov    %edx,0x14(%ebp)
  80042f:	8b 00                	mov    (%eax),%eax
  800431:	85 c0                	test   %eax,%eax
  800433:	79 02                	jns    800437 <vprintfmt+0x111>
  800435:	f7 d8                	neg    %eax
  800437:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800439:	83 f8 0f             	cmp    $0xf,%eax
  80043c:	7f 0b                	jg     800449 <vprintfmt+0x123>
  80043e:	8b 04 85 20 29 80 00 	mov    0x802920(,%eax,4),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 23                	jne    80046c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800449:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044d:	c7 44 24 08 98 26 80 	movl   $0x802698,0x8(%esp)
  800454:	00 
  800455:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800459:	8b 45 08             	mov    0x8(%ebp),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	e8 9a fe ff ff       	call   8002fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800467:	e9 dd fe ff ff       	jmp    800349 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80046c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800470:	c7 44 24 08 99 2a 80 	movl   $0x802a99,0x8(%esp)
  800477:	00 
  800478:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047c:	8b 55 08             	mov    0x8(%ebp),%edx
  80047f:	89 14 24             	mov    %edx,(%esp)
  800482:	e8 77 fe ff ff       	call   8002fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80048a:	e9 ba fe ff ff       	jmp    800349 <vprintfmt+0x23>
  80048f:	89 f9                	mov    %edi,%ecx
  800491:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800494:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 50 04             	lea    0x4(%eax),%edx
  80049d:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a0:	8b 30                	mov    (%eax),%esi
  8004a2:	85 f6                	test   %esi,%esi
  8004a4:	75 05                	jne    8004ab <vprintfmt+0x185>
				p = "(null)";
  8004a6:	be 91 26 80 00       	mov    $0x802691,%esi
			if (width > 0 && padc != '-')
  8004ab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004af:	0f 8e 84 00 00 00    	jle    800539 <vprintfmt+0x213>
  8004b5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004b9:	74 7e                	je     800539 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004bf:	89 34 24             	mov    %esi,(%esp)
  8004c2:	e8 8b 02 00 00       	call   800752 <strnlen>
  8004c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ca:	29 c2                	sub    %eax,%edx
  8004cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004cf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004d3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004d9:	89 de                	mov    %ebx,%esi
  8004db:	89 d3                	mov    %edx,%ebx
  8004dd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	eb 0b                	jmp    8004ec <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e5:	89 3c 24             	mov    %edi,(%esp)
  8004e8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	4b                   	dec    %ebx
  8004ec:	85 db                	test   %ebx,%ebx
  8004ee:	7f f1                	jg     8004e1 <vprintfmt+0x1bb>
  8004f0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004f3:	89 f3                	mov    %esi,%ebx
  8004f5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	79 05                	jns    800504 <vprintfmt+0x1de>
  8004ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800504:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800507:	29 c2                	sub    %eax,%edx
  800509:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80050c:	eb 2b                	jmp    800539 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800512:	74 18                	je     80052c <vprintfmt+0x206>
  800514:	8d 50 e0             	lea    -0x20(%eax),%edx
  800517:	83 fa 5e             	cmp    $0x5e,%edx
  80051a:	76 10                	jbe    80052c <vprintfmt+0x206>
					putch('?', putdat);
  80051c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800520:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800527:	ff 55 08             	call   *0x8(%ebp)
  80052a:	eb 0a                	jmp    800536 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80052c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800536:	ff 4d e4             	decl   -0x1c(%ebp)
  800539:	0f be 06             	movsbl (%esi),%eax
  80053c:	46                   	inc    %esi
  80053d:	85 c0                	test   %eax,%eax
  80053f:	74 21                	je     800562 <vprintfmt+0x23c>
  800541:	85 ff                	test   %edi,%edi
  800543:	78 c9                	js     80050e <vprintfmt+0x1e8>
  800545:	4f                   	dec    %edi
  800546:	79 c6                	jns    80050e <vprintfmt+0x1e8>
  800548:	8b 7d 08             	mov    0x8(%ebp),%edi
  80054b:	89 de                	mov    %ebx,%esi
  80054d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800550:	eb 18                	jmp    80056a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800552:	89 74 24 04          	mov    %esi,0x4(%esp)
  800556:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80055d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055f:	4b                   	dec    %ebx
  800560:	eb 08                	jmp    80056a <vprintfmt+0x244>
  800562:	8b 7d 08             	mov    0x8(%ebp),%edi
  800565:	89 de                	mov    %ebx,%esi
  800567:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80056a:	85 db                	test   %ebx,%ebx
  80056c:	7f e4                	jg     800552 <vprintfmt+0x22c>
  80056e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800571:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800576:	e9 ce fd ff ff       	jmp    800349 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80057b:	83 f9 01             	cmp    $0x1,%ecx
  80057e:	7e 10                	jle    800590 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 08             	lea    0x8(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 30                	mov    (%eax),%esi
  80058b:	8b 78 04             	mov    0x4(%eax),%edi
  80058e:	eb 26                	jmp    8005b6 <vprintfmt+0x290>
	else if (lflag)
  800590:	85 c9                	test   %ecx,%ecx
  800592:	74 12                	je     8005a6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 30                	mov    (%eax),%esi
  80059f:	89 f7                	mov    %esi,%edi
  8005a1:	c1 ff 1f             	sar    $0x1f,%edi
  8005a4:	eb 10                	jmp    8005b6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 30                	mov    (%eax),%esi
  8005b1:	89 f7                	mov    %esi,%edi
  8005b3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b6:	85 ff                	test   %edi,%edi
  8005b8:	78 0a                	js     8005c4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bf:	e9 8c 00 00 00       	jmp    800650 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d2:	f7 de                	neg    %esi
  8005d4:	83 d7 00             	adc    $0x0,%edi
  8005d7:	f7 df                	neg    %edi
			}
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005de:	eb 70                	jmp    800650 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e0:	89 ca                	mov    %ecx,%edx
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e5:	e8 c0 fc ff ff       	call   8002aa <getuint>
  8005ea:	89 c6                	mov    %eax,%esi
  8005ec:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005f3:	eb 5b                	jmp    800650 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8005f5:	89 ca                	mov    %ecx,%edx
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 ab fc ff ff       	call   8002aa <getuint>
  8005ff:	89 c6                	mov    %eax,%esi
  800601:	89 d7                	mov    %edx,%edi
			base = 8;
  800603:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800608:	eb 46                	jmp    800650 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80060a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800615:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800623:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062f:	8b 30                	mov    (%eax),%esi
  800631:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800636:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80063b:	eb 13                	jmp    800650 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063d:	89 ca                	mov    %ecx,%edx
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 63 fc ff ff       	call   8002aa <getuint>
  800647:	89 c6                	mov    %eax,%esi
  800649:	89 d7                	mov    %edx,%edi
			base = 16;
  80064b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800650:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800654:	89 54 24 10          	mov    %edx,0x10(%esp)
  800658:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800663:	89 34 24             	mov    %esi,(%esp)
  800666:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066a:	89 da                	mov    %ebx,%edx
  80066c:	8b 45 08             	mov    0x8(%ebp),%eax
  80066f:	e8 6c fb ff ff       	call   8001e0 <printnum>
			break;
  800674:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800677:	e9 cd fc ff ff       	jmp    800349 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	89 04 24             	mov    %eax,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800689:	e9 bb fc ff ff       	jmp    800349 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800692:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800699:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069c:	eb 01                	jmp    80069f <vprintfmt+0x379>
  80069e:	4e                   	dec    %esi
  80069f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006a3:	75 f9                	jne    80069e <vprintfmt+0x378>
  8006a5:	e9 9f fc ff ff       	jmp    800349 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006aa:	83 c4 4c             	add    $0x4c,%esp
  8006ad:	5b                   	pop    %ebx
  8006ae:	5e                   	pop    %esi
  8006af:	5f                   	pop    %edi
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 28             	sub    $0x28,%esp
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 30                	je     800703 <vsnprintf+0x51>
  8006d3:	85 d2                	test   %edx,%edx
  8006d5:	7e 33                	jle    80070a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006de:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	c7 04 24 e4 02 80 00 	movl   $0x8002e4,(%esp)
  8006f3:	e8 2e fc ff ff       	call   800326 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800701:	eb 0c                	jmp    80070f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800703:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800708:	eb 05                	jmp    80070f <vsnprintf+0x5d>
  80070a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    

00800711 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071e:	8b 45 10             	mov    0x10(%ebp),%eax
  800721:	89 44 24 08          	mov    %eax,0x8(%esp)
  800725:	8b 45 0c             	mov    0xc(%ebp),%eax
  800728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	89 04 24             	mov    %eax,(%esp)
  800732:	e8 7b ff ff ff       	call   8006b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800737:	c9                   	leave  
  800738:	c3                   	ret    
  800739:	00 00                	add    %al,(%eax)
	...

0080073c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	eb 01                	jmp    80074a <strlen+0xe>
		n++;
  800749:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074e:	75 f9                	jne    800749 <strlen+0xd>
		n++;
	return n;
}
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
  800760:	eb 01                	jmp    800763 <strnlen+0x11>
		n++;
  800762:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800763:	39 d0                	cmp    %edx,%eax
  800765:	74 06                	je     80076d <strnlen+0x1b>
  800767:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076b:	75 f5                	jne    800762 <strnlen+0x10>
		n++;
	return n;
}
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	53                   	push   %ebx
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800779:	ba 00 00 00 00       	mov    $0x0,%edx
  80077e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800781:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800784:	42                   	inc    %edx
  800785:	84 c9                	test   %cl,%cl
  800787:	75 f5                	jne    80077e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800789:	5b                   	pop    %ebx
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	83 ec 08             	sub    $0x8,%esp
  800793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800796:	89 1c 24             	mov    %ebx,(%esp)
  800799:	e8 9e ff ff ff       	call   80073c <strlen>
	strcpy(dst + len, src);
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a5:	01 d8                	add    %ebx,%eax
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	e8 c0 ff ff ff       	call   80076f <strcpy>
	return dst;
}
  8007af:	89 d8                	mov    %ebx,%eax
  8007b1:	83 c4 08             	add    $0x8,%esp
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	56                   	push   %esi
  8007bb:	53                   	push   %ebx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ca:	eb 0c                	jmp    8007d8 <strncpy+0x21>
		*dst++ = *src;
  8007cc:	8a 1a                	mov    (%edx),%bl
  8007ce:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d1:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d7:	41                   	inc    %ecx
  8007d8:	39 f1                	cmp    %esi,%ecx
  8007da:	75 f0                	jne    8007cc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	56                   	push   %esi
  8007e4:	53                   	push   %ebx
  8007e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007eb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	75 0a                	jne    8007fc <strlcpy+0x1c>
  8007f2:	89 f0                	mov    %esi,%eax
  8007f4:	eb 1a                	jmp    800810 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f6:	88 18                	mov    %bl,(%eax)
  8007f8:	40                   	inc    %eax
  8007f9:	41                   	inc    %ecx
  8007fa:	eb 02                	jmp    8007fe <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007fe:	4a                   	dec    %edx
  8007ff:	74 0a                	je     80080b <strlcpy+0x2b>
  800801:	8a 19                	mov    (%ecx),%bl
  800803:	84 db                	test   %bl,%bl
  800805:	75 ef                	jne    8007f6 <strlcpy+0x16>
  800807:	89 c2                	mov    %eax,%edx
  800809:	eb 02                	jmp    80080d <strlcpy+0x2d>
  80080b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80080d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800810:	29 f0                	sub    %esi,%eax
}
  800812:	5b                   	pop    %ebx
  800813:	5e                   	pop    %esi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081f:	eb 02                	jmp    800823 <strcmp+0xd>
		p++, q++;
  800821:	41                   	inc    %ecx
  800822:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800823:	8a 01                	mov    (%ecx),%al
  800825:	84 c0                	test   %al,%al
  800827:	74 04                	je     80082d <strcmp+0x17>
  800829:	3a 02                	cmp    (%edx),%al
  80082b:	74 f4                	je     800821 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082d:	0f b6 c0             	movzbl %al,%eax
  800830:	0f b6 12             	movzbl (%edx),%edx
  800833:	29 d0                	sub    %edx,%eax
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800841:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800844:	eb 03                	jmp    800849 <strncmp+0x12>
		n--, p++, q++;
  800846:	4a                   	dec    %edx
  800847:	40                   	inc    %eax
  800848:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800849:	85 d2                	test   %edx,%edx
  80084b:	74 14                	je     800861 <strncmp+0x2a>
  80084d:	8a 18                	mov    (%eax),%bl
  80084f:	84 db                	test   %bl,%bl
  800851:	74 04                	je     800857 <strncmp+0x20>
  800853:	3a 19                	cmp    (%ecx),%bl
  800855:	74 ef                	je     800846 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800857:	0f b6 00             	movzbl (%eax),%eax
  80085a:	0f b6 11             	movzbl (%ecx),%edx
  80085d:	29 d0                	sub    %edx,%eax
  80085f:	eb 05                	jmp    800866 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800866:	5b                   	pop    %ebx
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800872:	eb 05                	jmp    800879 <strchr+0x10>
		if (*s == c)
  800874:	38 ca                	cmp    %cl,%dl
  800876:	74 0c                	je     800884 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800878:	40                   	inc    %eax
  800879:	8a 10                	mov    (%eax),%dl
  80087b:	84 d2                	test   %dl,%dl
  80087d:	75 f5                	jne    800874 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088f:	eb 05                	jmp    800896 <strfind+0x10>
		if (*s == c)
  800891:	38 ca                	cmp    %cl,%dl
  800893:	74 07                	je     80089c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800895:	40                   	inc    %eax
  800896:	8a 10                	mov    (%eax),%dl
  800898:	84 d2                	test   %dl,%dl
  80089a:	75 f5                	jne    800891 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	57                   	push   %edi
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ad:	85 c9                	test   %ecx,%ecx
  8008af:	74 30                	je     8008e1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b7:	75 25                	jne    8008de <memset+0x40>
  8008b9:	f6 c1 03             	test   $0x3,%cl
  8008bc:	75 20                	jne    8008de <memset+0x40>
		c &= 0xFF;
  8008be:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c1:	89 d3                	mov    %edx,%ebx
  8008c3:	c1 e3 08             	shl    $0x8,%ebx
  8008c6:	89 d6                	mov    %edx,%esi
  8008c8:	c1 e6 18             	shl    $0x18,%esi
  8008cb:	89 d0                	mov    %edx,%eax
  8008cd:	c1 e0 10             	shl    $0x10,%eax
  8008d0:	09 f0                	or     %esi,%eax
  8008d2:	09 d0                	or     %edx,%eax
  8008d4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d9:	fc                   	cld    
  8008da:	f3 ab                	rep stos %eax,%es:(%edi)
  8008dc:	eb 03                	jmp    8008e1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008de:	fc                   	cld    
  8008df:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e1:	89 f8                	mov    %edi,%eax
  8008e3:	5b                   	pop    %ebx
  8008e4:	5e                   	pop    %esi
  8008e5:	5f                   	pop    %edi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f6:	39 c6                	cmp    %eax,%esi
  8008f8:	73 34                	jae    80092e <memmove+0x46>
  8008fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fd:	39 d0                	cmp    %edx,%eax
  8008ff:	73 2d                	jae    80092e <memmove+0x46>
		s += n;
		d += n;
  800901:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800904:	f6 c2 03             	test   $0x3,%dl
  800907:	75 1b                	jne    800924 <memmove+0x3c>
  800909:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090f:	75 13                	jne    800924 <memmove+0x3c>
  800911:	f6 c1 03             	test   $0x3,%cl
  800914:	75 0e                	jne    800924 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800916:	83 ef 04             	sub    $0x4,%edi
  800919:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80091f:	fd                   	std    
  800920:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800922:	eb 07                	jmp    80092b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800924:	4f                   	dec    %edi
  800925:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800928:	fd                   	std    
  800929:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092b:	fc                   	cld    
  80092c:	eb 20                	jmp    80094e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800934:	75 13                	jne    800949 <memmove+0x61>
  800936:	a8 03                	test   $0x3,%al
  800938:	75 0f                	jne    800949 <memmove+0x61>
  80093a:	f6 c1 03             	test   $0x3,%cl
  80093d:	75 0a                	jne    800949 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80093f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800942:	89 c7                	mov    %eax,%edi
  800944:	fc                   	cld    
  800945:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800947:	eb 05                	jmp    80094e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800949:	89 c7                	mov    %eax,%edi
  80094b:	fc                   	cld    
  80094c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094e:	5e                   	pop    %esi
  80094f:	5f                   	pop    %edi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800958:	8b 45 10             	mov    0x10(%ebp),%eax
  80095b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	89 44 24 04          	mov    %eax,0x4(%esp)
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	89 04 24             	mov    %eax,(%esp)
  80096c:	e8 77 ff ff ff       	call   8008e8 <memmove>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800982:	ba 00 00 00 00       	mov    $0x0,%edx
  800987:	eb 16                	jmp    80099f <memcmp+0x2c>
		if (*s1 != *s2)
  800989:	8a 04 17             	mov    (%edi,%edx,1),%al
  80098c:	42                   	inc    %edx
  80098d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800991:	38 c8                	cmp    %cl,%al
  800993:	74 0a                	je     80099f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800995:	0f b6 c0             	movzbl %al,%eax
  800998:	0f b6 c9             	movzbl %cl,%ecx
  80099b:	29 c8                	sub    %ecx,%eax
  80099d:	eb 09                	jmp    8009a8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099f:	39 da                	cmp    %ebx,%edx
  8009a1:	75 e6                	jne    800989 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b6:	89 c2                	mov    %eax,%edx
  8009b8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009bb:	eb 05                	jmp    8009c2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009bd:	38 08                	cmp    %cl,(%eax)
  8009bf:	74 05                	je     8009c6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c1:	40                   	inc    %eax
  8009c2:	39 d0                	cmp    %edx,%eax
  8009c4:	72 f7                	jb     8009bd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	53                   	push   %ebx
  8009ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d4:	eb 01                	jmp    8009d7 <strtol+0xf>
		s++;
  8009d6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d7:	8a 02                	mov    (%edx),%al
  8009d9:	3c 20                	cmp    $0x20,%al
  8009db:	74 f9                	je     8009d6 <strtol+0xe>
  8009dd:	3c 09                	cmp    $0x9,%al
  8009df:	74 f5                	je     8009d6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e1:	3c 2b                	cmp    $0x2b,%al
  8009e3:	75 08                	jne    8009ed <strtol+0x25>
		s++;
  8009e5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009eb:	eb 13                	jmp    800a00 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ed:	3c 2d                	cmp    $0x2d,%al
  8009ef:	75 0a                	jne    8009fb <strtol+0x33>
		s++, neg = 1;
  8009f1:	8d 52 01             	lea    0x1(%edx),%edx
  8009f4:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f9:	eb 05                	jmp    800a00 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a00:	85 db                	test   %ebx,%ebx
  800a02:	74 05                	je     800a09 <strtol+0x41>
  800a04:	83 fb 10             	cmp    $0x10,%ebx
  800a07:	75 28                	jne    800a31 <strtol+0x69>
  800a09:	8a 02                	mov    (%edx),%al
  800a0b:	3c 30                	cmp    $0x30,%al
  800a0d:	75 10                	jne    800a1f <strtol+0x57>
  800a0f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a13:	75 0a                	jne    800a1f <strtol+0x57>
		s += 2, base = 16;
  800a15:	83 c2 02             	add    $0x2,%edx
  800a18:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1d:	eb 12                	jmp    800a31 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a1f:	85 db                	test   %ebx,%ebx
  800a21:	75 0e                	jne    800a31 <strtol+0x69>
  800a23:	3c 30                	cmp    $0x30,%al
  800a25:	75 05                	jne    800a2c <strtol+0x64>
		s++, base = 8;
  800a27:	42                   	inc    %edx
  800a28:	b3 08                	mov    $0x8,%bl
  800a2a:	eb 05                	jmp    800a31 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
  800a36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a38:	8a 0a                	mov    (%edx),%cl
  800a3a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a3d:	80 fb 09             	cmp    $0x9,%bl
  800a40:	77 08                	ja     800a4a <strtol+0x82>
			dig = *s - '0';
  800a42:	0f be c9             	movsbl %cl,%ecx
  800a45:	83 e9 30             	sub    $0x30,%ecx
  800a48:	eb 1e                	jmp    800a68 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a4a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a4d:	80 fb 19             	cmp    $0x19,%bl
  800a50:	77 08                	ja     800a5a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a52:	0f be c9             	movsbl %cl,%ecx
  800a55:	83 e9 57             	sub    $0x57,%ecx
  800a58:	eb 0e                	jmp    800a68 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a5a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a5d:	80 fb 19             	cmp    $0x19,%bl
  800a60:	77 12                	ja     800a74 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a62:	0f be c9             	movsbl %cl,%ecx
  800a65:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a68:	39 f1                	cmp    %esi,%ecx
  800a6a:	7d 0c                	jge    800a78 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a6c:	42                   	inc    %edx
  800a6d:	0f af c6             	imul   %esi,%eax
  800a70:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a72:	eb c4                	jmp    800a38 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a74:	89 c1                	mov    %eax,%ecx
  800a76:	eb 02                	jmp    800a7a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a78:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7e:	74 05                	je     800a85 <strtol+0xbd>
		*endptr = (char *) s;
  800a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a83:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a85:	85 ff                	test   %edi,%edi
  800a87:	74 04                	je     800a8d <strtol+0xc5>
  800a89:	89 c8                	mov    %ecx,%eax
  800a8b:	f7 d8                	neg    %eax
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    
	...

00800a94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa5:	89 c3                	mov    %eax,%ebx
  800aa7:	89 c7                	mov    %eax,%edi
  800aa9:	89 c6                	mov    %eax,%esi
  800aab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac2:	89 d1                	mov    %edx,%ecx
  800ac4:	89 d3                	mov    %edx,%ebx
  800ac6:	89 d7                	mov    %edx,%edi
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	89 cb                	mov    %ecx,%ebx
  800ae9:	89 cf                	mov    %ecx,%edi
  800aeb:	89 ce                	mov    %ecx,%esi
  800aed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aef:	85 c0                	test   %eax,%eax
  800af1:	7e 28                	jle    800b1b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800af7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800afe:	00 
  800aff:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800b06:	00 
  800b07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b0e:	00 
  800b0f:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800b16:	e8 09 16 00 00       	call   802124 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1b:	83 c4 2c             	add    $0x2c,%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b33:	89 d1                	mov    %edx,%ecx
  800b35:	89 d3                	mov    %edx,%ebx
  800b37:	89 d7                	mov    %edx,%edi
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <sys_yield>:

void
sys_yield(void)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b52:	89 d1                	mov    %edx,%ecx
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	89 d7                	mov    %edx,%edi
  800b58:	89 d6                	mov    %edx,%esi
  800b5a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b6a:	be 00 00 00 00       	mov    $0x0,%esi
  800b6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	89 f7                	mov    %esi,%edi
  800b7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b81:	85 c0                	test   %eax,%eax
  800b83:	7e 28                	jle    800bad <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b89:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b90:	00 
  800b91:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800b98:	00 
  800b99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba0:	00 
  800ba1:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800ba8:	e8 77 15 00 00       	call   802124 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bad:	83 c4 2c             	add    $0x2c,%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 28                	jle    800c00 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800be3:	00 
  800be4:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800beb:	00 
  800bec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf3:	00 
  800bf4:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800bfb:	e8 24 15 00 00       	call   802124 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c00:	83 c4 2c             	add    $0x2c,%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 28                	jle    800c53 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c36:	00 
  800c37:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c46:	00 
  800c47:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800c4e:	e8 d1 14 00 00       	call   802124 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c53:	83 c4 2c             	add    $0x2c,%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c69:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	89 df                	mov    %ebx,%edi
  800c76:	89 de                	mov    %ebx,%esi
  800c78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 28                	jle    800ca6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c82:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c89:	00 
  800c8a:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800c91:	00 
  800c92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c99:	00 
  800c9a:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800ca1:	e8 7e 14 00 00       	call   802124 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca6:	83 c4 2c             	add    $0x2c,%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	89 df                	mov    %ebx,%edi
  800cc9:	89 de                	mov    %ebx,%esi
  800ccb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 28                	jle    800cf9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cdc:	00 
  800cdd:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800ce4:	00 
  800ce5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cec:	00 
  800ced:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800cf4:	e8 2b 14 00 00       	call   802124 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf9:	83 c4 2c             	add    $0x2c,%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 df                	mov    %ebx,%edi
  800d1c:	89 de                	mov    %ebx,%esi
  800d1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 28                	jle    800d4c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d28:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d2f:	00 
  800d30:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800d37:	00 
  800d38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3f:	00 
  800d40:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800d47:	e8 d8 13 00 00       	call   802124 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d4c:	83 c4 2c             	add    $0x2c,%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	be 00 00 00 00       	mov    $0x0,%esi
  800d5f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8d:	89 cb                	mov    %ecx,%ebx
  800d8f:	89 cf                	mov    %ecx,%edi
  800d91:	89 ce                	mov    %ecx,%esi
  800d93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7e 28                	jle    800dc1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800da4:	00 
  800da5:	c7 44 24 08 7f 29 80 	movl   $0x80297f,0x8(%esp)
  800dac:	00 
  800dad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db4:	00 
  800db5:	c7 04 24 9c 29 80 00 	movl   $0x80299c,(%esp)
  800dbc:	e8 63 13 00 00       	call   802124 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc1:	83 c4 2c             	add    $0x2c,%esp
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    
  800dc9:	00 00                	add    %al,(%eax)
	...

00800dcc <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 3c             	sub    $0x3c,%esp
  800dd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800dd8:	89 d6                	mov    %edx,%esi
  800dda:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800ddd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800de7:	e8 37 fd ff ff       	call   800b23 <sys_getenvid>
  800dec:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800dee:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800df5:	74 31                	je     800e28 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800df7:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800dfe:	00 
  800dff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e03:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e06:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e0e:	89 3c 24             	mov    %edi,(%esp)
  800e11:	e8 9f fd ff ff       	call   800bb5 <sys_page_map>
  800e16:	85 c0                	test   %eax,%eax
  800e18:	0f 8e ae 00 00 00    	jle    800ecc <duppage+0x100>
  800e1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e23:	e9 a4 00 00 00       	jmp    800ecc <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800e28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e2b:	25 02 08 00 00       	and    $0x802,%eax
  800e30:	83 f8 01             	cmp    $0x1,%eax
  800e33:	19 db                	sbb    %ebx,%ebx
  800e35:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800e3b:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800e41:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e45:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e49:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e50:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e54:	89 3c 24             	mov    %edi,(%esp)
  800e57:	e8 59 fd ff ff       	call   800bb5 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	79 1c                	jns    800e7c <duppage+0xb0>
  800e60:	c7 44 24 08 aa 29 80 	movl   $0x8029aa,0x8(%esp)
  800e67:	00 
  800e68:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800e6f:	00 
  800e70:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800e77:	e8 a8 12 00 00       	call   802124 <_panic>
	if ((perm|~pte)&PTE_COW){
  800e7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e7f:	f7 d0                	not    %eax
  800e81:	09 d8                	or     %ebx,%eax
  800e83:	f6 c4 08             	test   $0x8,%ah
  800e86:	74 38                	je     800ec0 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800e88:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e8c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e90:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e98:	89 3c 24             	mov    %edi,(%esp)
  800e9b:	e8 15 fd ff ff       	call   800bb5 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	79 23                	jns    800ec7 <duppage+0xfb>
  800ea4:	c7 44 24 08 aa 29 80 	movl   $0x8029aa,0x8(%esp)
  800eab:	00 
  800eac:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800eb3:	00 
  800eb4:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800ebb:	e8 64 12 00 00       	call   802124 <_panic>
	}
	return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	eb 05                	jmp    800ecc <duppage+0x100>
  800ec7:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  800ecc:	83 c4 3c             	add    $0x3c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 20             	sub    $0x20,%esp
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800edf:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800ee1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ee5:	75 1c                	jne    800f03 <pgfault+0x2f>
		panic("pgfault: error!\n");
  800ee7:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  800eee:	00 
  800eef:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800ef6:	00 
  800ef7:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800efe:	e8 21 12 00 00       	call   802124 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	c1 e8 0c             	shr    $0xc,%eax
  800f08:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f0f:	f6 c4 08             	test   $0x8,%ah
  800f12:	75 1c                	jne    800f30 <pgfault+0x5c>
		panic("pgfault: error!\n");
  800f14:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800f23:	00 
  800f24:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800f2b:	e8 f4 11 00 00       	call   802124 <_panic>
	envid_t envid = sys_getenvid();
  800f30:	e8 ee fb ff ff       	call   800b23 <sys_getenvid>
  800f35:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800f37:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f46:	00 
  800f47:	89 04 24             	mov    %eax,(%esp)
  800f4a:	e8 12 fc ff ff       	call   800b61 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 1c                	jns    800f6f <pgfault+0x9b>
  800f53:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  800f5a:	00 
  800f5b:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f62:	00 
  800f63:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800f6a:	e8 b5 11 00 00       	call   802124 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800f6f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  800f75:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f7c:	00 
  800f7d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f81:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f88:	e8 c5 f9 ff ff       	call   800952 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  800f8d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f94:	00 
  800f95:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f9d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fa4:	00 
  800fa5:	89 1c 24             	mov    %ebx,(%esp)
  800fa8:	e8 08 fc ff ff       	call   800bb5 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  800fad:	85 c0                	test   %eax,%eax
  800faf:	79 1c                	jns    800fcd <pgfault+0xf9>
  800fb1:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800fc8:	e8 57 11 00 00       	call   802124 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  800fcd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fd4:	00 
  800fd5:	89 1c 24             	mov    %ebx,(%esp)
  800fd8:	e8 2b fc ff ff       	call   800c08 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	79 1c                	jns    800ffd <pgfault+0x129>
  800fe1:	c7 44 24 08 c6 29 80 	movl   $0x8029c6,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  800ff8:	e8 27 11 00 00       	call   802124 <_panic>
	return;
	panic("pgfault not implemented");
}
  800ffd:	83 c4 20             	add    $0x20,%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80100d:	c7 04 24 d4 0e 80 00 	movl   $0x800ed4,(%esp)
  801014:	e8 63 11 00 00       	call   80217c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801019:	bf 07 00 00 00       	mov    $0x7,%edi
  80101e:	89 f8                	mov    %edi,%eax
  801020:	cd 30                	int    $0x30
  801022:	89 c7                	mov    %eax,%edi
  801024:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  801026:	85 c0                	test   %eax,%eax
  801028:	79 1c                	jns    801046 <fork+0x42>
		panic("fork : error!\n");
  80102a:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  801031:	00 
  801032:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  801039:	00 
  80103a:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  801041:	e8 de 10 00 00       	call   802124 <_panic>
	if (envid==0){
  801046:	85 c0                	test   %eax,%eax
  801048:	75 28                	jne    801072 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  80104a:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801050:	e8 ce fa ff ff       	call   800b23 <sys_getenvid>
  801055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80105a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801061:	c1 e0 07             	shl    $0x7,%eax
  801064:	29 d0                	sub    %edx,%eax
  801066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80106b:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  80106d:	e9 f2 00 00 00       	jmp    801164 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  801072:	e8 ac fa ff ff       	call   800b23 <sys_getenvid>
  801077:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80107a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  80107f:	89 d8                	mov    %ebx,%eax
  801081:	c1 e8 16             	shr    $0x16,%eax
  801084:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80108b:	a8 01                	test   $0x1,%al
  80108d:	74 17                	je     8010a6 <fork+0xa2>
  80108f:	89 da                	mov    %ebx,%edx
  801091:	c1 ea 0c             	shr    $0xc,%edx
  801094:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80109b:	a8 01                	test   $0x1,%al
  80109d:	74 07                	je     8010a6 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  80109f:	89 f0                	mov    %esi,%eax
  8010a1:	e8 26 fd ff ff       	call   800dcc <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8010a6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010ac:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010b2:	75 cb                	jne    80107f <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  8010b4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010c3:	ee 
  8010c4:	89 3c 24             	mov    %edi,(%esp)
  8010c7:	e8 95 fa ff ff       	call   800b61 <sys_page_alloc>
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 1c                	jns    8010ec <fork+0xe8>
  8010d0:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  8010e7:	e8 38 10 00 00       	call   802124 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  8010ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010fb:	c1 e0 07             	shl    $0x7,%eax
  8010fe:	29 d0                	sub    %edx,%eax
  801100:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801105:	8b 40 64             	mov    0x64(%eax),%eax
  801108:	89 44 24 04          	mov    %eax,0x4(%esp)
  80110c:	89 3c 24             	mov    %edi,(%esp)
  80110f:	e8 ed fb ff ff       	call   800d01 <sys_env_set_pgfault_upcall>
  801114:	85 c0                	test   %eax,%eax
  801116:	79 1c                	jns    801134 <fork+0x130>
  801118:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  80111f:	00 
  801120:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801127:	00 
  801128:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  80112f:	e8 f0 0f 00 00       	call   802124 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  801134:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80113b:	00 
  80113c:	89 3c 24             	mov    %edi,(%esp)
  80113f:	e8 17 fb ff ff       	call   800c5b <sys_env_set_status>
  801144:	85 c0                	test   %eax,%eax
  801146:	79 1c                	jns    801164 <fork+0x160>
  801148:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  80114f:	00 
  801150:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801157:	00 
  801158:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  80115f:	e8 c0 0f 00 00       	call   802124 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801164:	89 f8                	mov    %edi,%eax
  801166:	83 c4 2c             	add    $0x2c,%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sfork>:

// Challenge!
int
sfork(void)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  801177:	c7 04 24 d4 0e 80 00 	movl   $0x800ed4,(%esp)
  80117e:	e8 f9 0f 00 00       	call   80217c <set_pgfault_handler>
  801183:	ba 07 00 00 00       	mov    $0x7,%edx
  801188:	89 d0                	mov    %edx,%eax
  80118a:	cd 30                	int    $0x30
  80118c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80118f:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801191:	89 44 24 04          	mov    %eax,0x4(%esp)
  801195:	c7 04 24 d7 29 80 00 	movl   $0x8029d7,(%esp)
  80119c:	e8 23 f0 ff ff       	call   8001c4 <cprintf>
	if (envid<0)
  8011a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011a5:	79 1c                	jns    8011c3 <sfork+0x55>
		panic("sfork : error!\n");
  8011a7:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  8011ae:	00 
  8011af:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  8011b6:	00 
  8011b7:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  8011be:	e8 61 0f 00 00       	call   802124 <_panic>
	if (envid==0){
  8011c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011c7:	75 28                	jne    8011f1 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  8011c9:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8011cf:	e8 4f f9 ff ff       	call   800b23 <sys_getenvid>
  8011d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011e0:	c1 e0 07             	shl    $0x7,%eax
  8011e3:	29 d0                	sub    %edx,%eax
  8011e5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ea:	89 03                	mov    %eax,(%ebx)
		return envid;
  8011ec:	e9 18 01 00 00       	jmp    801309 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  8011f1:	e8 2d f9 ff ff       	call   800b23 <sys_getenvid>
  8011f6:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8011f8:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8011fd:	89 d8                	mov    %ebx,%eax
  8011ff:	c1 e8 16             	shr    $0x16,%eax
  801202:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801209:	a8 01                	test   $0x1,%al
  80120b:	74 2c                	je     801239 <sfork+0xcb>
  80120d:	89 d8                	mov    %ebx,%eax
  80120f:	c1 e8 0c             	shr    $0xc,%eax
  801212:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801219:	a8 01                	test   $0x1,%al
  80121b:	74 1c                	je     801239 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  80121d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801224:	00 
  801225:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801229:	89 74 24 08          	mov    %esi,0x8(%esp)
  80122d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801231:	89 3c 24             	mov    %edi,(%esp)
  801234:	e8 7c f9 ff ff       	call   800bb5 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801239:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80123f:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801245:	75 b6                	jne    8011fd <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  801247:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  80124c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80124f:	e8 78 fb ff ff       	call   800dcc <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801254:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80125b:	00 
  80125c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801263:	ee 
  801264:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801267:	89 04 24             	mov    %eax,(%esp)
  80126a:	e8 f2 f8 ff ff       	call   800b61 <sys_page_alloc>
  80126f:	85 c0                	test   %eax,%eax
  801271:	79 1c                	jns    80128f <sfork+0x121>
  801273:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  80127a:	00 
  80127b:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  801282:	00 
  801283:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  80128a:	e8 95 0e 00 00       	call   802124 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  80128f:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801295:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  80129c:	c1 e7 07             	shl    $0x7,%edi
  80129f:	29 d7                	sub    %edx,%edi
  8012a1:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  8012a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ae:	89 04 24             	mov    %eax,(%esp)
  8012b1:	e8 4b fa ff ff       	call   800d01 <sys_env_set_pgfault_upcall>
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	79 1c                	jns    8012d6 <sfork+0x168>
  8012ba:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  8012c1:	00 
  8012c2:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  8012c9:	00 
  8012ca:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  8012d1:	e8 4e 0e 00 00       	call   802124 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  8012d6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012dd:	00 
  8012de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e1:	89 04 24             	mov    %eax,(%esp)
  8012e4:	e8 72 f9 ff ff       	call   800c5b <sys_env_set_status>
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	79 1c                	jns    801309 <sfork+0x19b>
  8012ed:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  8012f4:	00 
  8012f5:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8012fc:	00 
  8012fd:	c7 04 24 bb 29 80 00 	movl   $0x8029bb,(%esp)
  801304:	e8 1b 0e 00 00       	call   802124 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  801309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80130c:	83 c4 3c             	add    $0x3c,%esp
  80130f:	5b                   	pop    %ebx
  801310:	5e                   	pop    %esi
  801311:	5f                   	pop    %edi
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    

00801314 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801317:	8b 45 08             	mov    0x8(%ebp),%eax
  80131a:	05 00 00 00 30       	add    $0x30000000,%eax
  80131f:	c1 e8 0c             	shr    $0xc,%eax
}
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80132a:	8b 45 08             	mov    0x8(%ebp),%eax
  80132d:	89 04 24             	mov    %eax,(%esp)
  801330:	e8 df ff ff ff       	call   801314 <fd2num>
  801335:	05 20 00 0d 00       	add    $0xd0020,%eax
  80133a:	c1 e0 0c             	shl    $0xc,%eax
}
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	53                   	push   %ebx
  801343:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801346:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80134b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	c1 ea 16             	shr    $0x16,%edx
  801352:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801359:	f6 c2 01             	test   $0x1,%dl
  80135c:	74 11                	je     80136f <fd_alloc+0x30>
  80135e:	89 c2                	mov    %eax,%edx
  801360:	c1 ea 0c             	shr    $0xc,%edx
  801363:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136a:	f6 c2 01             	test   $0x1,%dl
  80136d:	75 09                	jne    801378 <fd_alloc+0x39>
			*fd_store = fd;
  80136f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801371:	b8 00 00 00 00       	mov    $0x0,%eax
  801376:	eb 17                	jmp    80138f <fd_alloc+0x50>
  801378:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80137d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801382:	75 c7                	jne    80134b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801384:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80138a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80138f:	5b                   	pop    %ebx
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801398:	83 f8 1f             	cmp    $0x1f,%eax
  80139b:	77 36                	ja     8013d3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139d:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013a2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	c1 ea 16             	shr    $0x16,%edx
  8013aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b1:	f6 c2 01             	test   $0x1,%dl
  8013b4:	74 24                	je     8013da <fd_lookup+0x48>
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	c1 ea 0c             	shr    $0xc,%edx
  8013bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c2:	f6 c2 01             	test   $0x1,%dl
  8013c5:	74 1a                	je     8013e1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ca:	89 02                	mov    %eax,(%edx)
	return 0;
  8013cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d1:	eb 13                	jmp    8013e6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d8:	eb 0c                	jmp    8013e6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013df:	eb 05                	jmp    8013e6 <fd_lookup+0x54>
  8013e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 14             	sub    $0x14,%esp
  8013ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fa:	eb 0e                	jmp    80140a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8013fc:	39 08                	cmp    %ecx,(%eax)
  8013fe:	75 09                	jne    801409 <dev_lookup+0x21>
			*dev = devtab[i];
  801400:	89 03                	mov    %eax,(%ebx)
			return 0;
  801402:	b8 00 00 00 00       	mov    $0x0,%eax
  801407:	eb 35                	jmp    80143e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801409:	42                   	inc    %edx
  80140a:	8b 04 95 70 2a 80 00 	mov    0x802a70(,%edx,4),%eax
  801411:	85 c0                	test   %eax,%eax
  801413:	75 e7                	jne    8013fc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801415:	a1 04 40 80 00       	mov    0x804004,%eax
  80141a:	8b 00                	mov    (%eax),%eax
  80141c:	8b 40 48             	mov    0x48(%eax),%eax
  80141f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801423:	89 44 24 04          	mov    %eax,0x4(%esp)
  801427:	c7 04 24 f4 29 80 00 	movl   $0x8029f4,(%esp)
  80142e:	e8 91 ed ff ff       	call   8001c4 <cprintf>
	*dev = 0;
  801433:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801439:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80143e:	83 c4 14             	add    $0x14,%esp
  801441:	5b                   	pop    %ebx
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	83 ec 30             	sub    $0x30,%esp
  80144c:	8b 75 08             	mov    0x8(%ebp),%esi
  80144f:	8a 45 0c             	mov    0xc(%ebp),%al
  801452:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801455:	89 34 24             	mov    %esi,(%esp)
  801458:	e8 b7 fe ff ff       	call   801314 <fd2num>
  80145d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801460:	89 54 24 04          	mov    %edx,0x4(%esp)
  801464:	89 04 24             	mov    %eax,(%esp)
  801467:	e8 26 ff ff ff       	call   801392 <fd_lookup>
  80146c:	89 c3                	mov    %eax,%ebx
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 05                	js     801477 <fd_close+0x33>
	    || fd != fd2)
  801472:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801475:	74 0d                	je     801484 <fd_close+0x40>
		return (must_exist ? r : 0);
  801477:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80147b:	75 46                	jne    8014c3 <fd_close+0x7f>
  80147d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801482:	eb 3f                	jmp    8014c3 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801484:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801487:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148b:	8b 06                	mov    (%esi),%eax
  80148d:	89 04 24             	mov    %eax,(%esp)
  801490:	e8 53 ff ff ff       	call   8013e8 <dev_lookup>
  801495:	89 c3                	mov    %eax,%ebx
  801497:	85 c0                	test   %eax,%eax
  801499:	78 18                	js     8014b3 <fd_close+0x6f>
		if (dev->dev_close)
  80149b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149e:	8b 40 10             	mov    0x10(%eax),%eax
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	74 09                	je     8014ae <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014a5:	89 34 24             	mov    %esi,(%esp)
  8014a8:	ff d0                	call   *%eax
  8014aa:	89 c3                	mov    %eax,%ebx
  8014ac:	eb 05                	jmp    8014b3 <fd_close+0x6f>
		else
			r = 0;
  8014ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014be:	e8 45 f7 ff ff       	call   800c08 <sys_page_unmap>
	return r;
}
  8014c3:	89 d8                	mov    %ebx,%eax
  8014c5:	83 c4 30             	add    $0x30,%esp
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dc:	89 04 24             	mov    %eax,(%esp)
  8014df:	e8 ae fe ff ff       	call   801392 <fd_lookup>
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 13                	js     8014fb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014ef:	00 
  8014f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f3:	89 04 24             	mov    %eax,(%esp)
  8014f6:	e8 49 ff ff ff       	call   801444 <fd_close>
}
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <close_all>:

void
close_all(void)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	53                   	push   %ebx
  801501:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801504:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801509:	89 1c 24             	mov    %ebx,(%esp)
  80150c:	e8 bb ff ff ff       	call   8014cc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801511:	43                   	inc    %ebx
  801512:	83 fb 20             	cmp    $0x20,%ebx
  801515:	75 f2                	jne    801509 <close_all+0xc>
		close(i);
}
  801517:	83 c4 14             	add    $0x14,%esp
  80151a:	5b                   	pop    %ebx
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 4c             	sub    $0x4c,%esp
  801526:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801529:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80152c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801530:	8b 45 08             	mov    0x8(%ebp),%eax
  801533:	89 04 24             	mov    %eax,(%esp)
  801536:	e8 57 fe ff ff       	call   801392 <fd_lookup>
  80153b:	89 c3                	mov    %eax,%ebx
  80153d:	85 c0                	test   %eax,%eax
  80153f:	0f 88 e1 00 00 00    	js     801626 <dup+0x109>
		return r;
	close(newfdnum);
  801545:	89 3c 24             	mov    %edi,(%esp)
  801548:	e8 7f ff ff ff       	call   8014cc <close>

	newfd = INDEX2FD(newfdnum);
  80154d:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801553:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801556:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801559:	89 04 24             	mov    %eax,(%esp)
  80155c:	e8 c3 fd ff ff       	call   801324 <fd2data>
  801561:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801563:	89 34 24             	mov    %esi,(%esp)
  801566:	e8 b9 fd ff ff       	call   801324 <fd2data>
  80156b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80156e:	89 d8                	mov    %ebx,%eax
  801570:	c1 e8 16             	shr    $0x16,%eax
  801573:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80157a:	a8 01                	test   $0x1,%al
  80157c:	74 46                	je     8015c4 <dup+0xa7>
  80157e:	89 d8                	mov    %ebx,%eax
  801580:	c1 e8 0c             	shr    $0xc,%eax
  801583:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80158a:	f6 c2 01             	test   $0x1,%dl
  80158d:	74 35                	je     8015c4 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80158f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801596:	25 07 0e 00 00       	and    $0xe07,%eax
  80159b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80159f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015ad:	00 
  8015ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b9:	e8 f7 f5 ff ff       	call   800bb5 <sys_page_map>
  8015be:	89 c3                	mov    %eax,%ebx
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 3b                	js     8015ff <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	c1 ea 0c             	shr    $0xc,%edx
  8015cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015d3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015dd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015e8:	00 
  8015e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f4:	e8 bc f5 ff ff       	call   800bb5 <sys_page_map>
  8015f9:	89 c3                	mov    %eax,%ebx
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	79 25                	jns    801624 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801603:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160a:	e8 f9 f5 ff ff       	call   800c08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80160f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801612:	89 44 24 04          	mov    %eax,0x4(%esp)
  801616:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80161d:	e8 e6 f5 ff ff       	call   800c08 <sys_page_unmap>
	return r;
  801622:	eb 02                	jmp    801626 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801624:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801626:	89 d8                	mov    %ebx,%eax
  801628:	83 c4 4c             	add    $0x4c,%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5f                   	pop    %edi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 24             	sub    $0x24,%esp
  801637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801641:	89 1c 24             	mov    %ebx,(%esp)
  801644:	e8 49 fd ff ff       	call   801392 <fd_lookup>
  801649:	85 c0                	test   %eax,%eax
  80164b:	78 6f                	js     8016bc <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801650:	89 44 24 04          	mov    %eax,0x4(%esp)
  801654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801657:	8b 00                	mov    (%eax),%eax
  801659:	89 04 24             	mov    %eax,(%esp)
  80165c:	e8 87 fd ff ff       	call   8013e8 <dev_lookup>
  801661:	85 c0                	test   %eax,%eax
  801663:	78 57                	js     8016bc <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	8b 50 08             	mov    0x8(%eax),%edx
  80166b:	83 e2 03             	and    $0x3,%edx
  80166e:	83 fa 01             	cmp    $0x1,%edx
  801671:	75 25                	jne    801698 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801673:	a1 04 40 80 00       	mov    0x804004,%eax
  801678:	8b 00                	mov    (%eax),%eax
  80167a:	8b 40 48             	mov    0x48(%eax),%eax
  80167d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801681:	89 44 24 04          	mov    %eax,0x4(%esp)
  801685:	c7 04 24 35 2a 80 00 	movl   $0x802a35,(%esp)
  80168c:	e8 33 eb ff ff       	call   8001c4 <cprintf>
		return -E_INVAL;
  801691:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801696:	eb 24                	jmp    8016bc <read+0x8c>
	}
	if (!dev->dev_read)
  801698:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169b:	8b 52 08             	mov    0x8(%edx),%edx
  80169e:	85 d2                	test   %edx,%edx
  8016a0:	74 15                	je     8016b7 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016a5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	ff d2                	call   *%edx
  8016b5:	eb 05                	jmp    8016bc <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016bc:	83 c4 24             	add    $0x24,%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5d                   	pop    %ebp
  8016c1:	c3                   	ret    

008016c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	57                   	push   %edi
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 1c             	sub    $0x1c,%esp
  8016cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d6:	eb 23                	jmp    8016fb <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016d8:	89 f0                	mov    %esi,%eax
  8016da:	29 d8                	sub    %ebx,%eax
  8016dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e3:	01 d8                	add    %ebx,%eax
  8016e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e9:	89 3c 24             	mov    %edi,(%esp)
  8016ec:	e8 3f ff ff ff       	call   801630 <read>
		if (m < 0)
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 10                	js     801705 <readn+0x43>
			return m;
		if (m == 0)
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	74 0a                	je     801703 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f9:	01 c3                	add    %eax,%ebx
  8016fb:	39 f3                	cmp    %esi,%ebx
  8016fd:	72 d9                	jb     8016d8 <readn+0x16>
  8016ff:	89 d8                	mov    %ebx,%eax
  801701:	eb 02                	jmp    801705 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801703:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801705:	83 c4 1c             	add    $0x1c,%esp
  801708:	5b                   	pop    %ebx
  801709:	5e                   	pop    %esi
  80170a:	5f                   	pop    %edi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    

0080170d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	53                   	push   %ebx
  801711:	83 ec 24             	sub    $0x24,%esp
  801714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171e:	89 1c 24             	mov    %ebx,(%esp)
  801721:	e8 6c fc ff ff       	call   801392 <fd_lookup>
  801726:	85 c0                	test   %eax,%eax
  801728:	78 6a                	js     801794 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801734:	8b 00                	mov    (%eax),%eax
  801736:	89 04 24             	mov    %eax,(%esp)
  801739:	e8 aa fc ff ff       	call   8013e8 <dev_lookup>
  80173e:	85 c0                	test   %eax,%eax
  801740:	78 52                	js     801794 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801749:	75 25                	jne    801770 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80174b:	a1 04 40 80 00       	mov    0x804004,%eax
  801750:	8b 00                	mov    (%eax),%eax
  801752:	8b 40 48             	mov    0x48(%eax),%eax
  801755:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175d:	c7 04 24 51 2a 80 00 	movl   $0x802a51,(%esp)
  801764:	e8 5b ea ff ff       	call   8001c4 <cprintf>
		return -E_INVAL;
  801769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80176e:	eb 24                	jmp    801794 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801773:	8b 52 0c             	mov    0xc(%edx),%edx
  801776:	85 d2                	test   %edx,%edx
  801778:	74 15                	je     80178f <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80177a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80177d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801784:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801788:	89 04 24             	mov    %eax,(%esp)
  80178b:	ff d2                	call   *%edx
  80178d:	eb 05                	jmp    801794 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80178f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801794:	83 c4 24             	add    $0x24,%esp
  801797:	5b                   	pop    %ebx
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <seek>:

int
seek(int fdnum, off_t offset)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	89 04 24             	mov    %eax,(%esp)
  8017ad:	e8 e0 fb ff ff       	call   801392 <fd_lookup>
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 0e                	js     8017c4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	53                   	push   %ebx
  8017ca:	83 ec 24             	sub    $0x24,%esp
  8017cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	89 1c 24             	mov    %ebx,(%esp)
  8017da:	e8 b3 fb ff ff       	call   801392 <fd_lookup>
  8017df:	85 c0                	test   %eax,%eax
  8017e1:	78 63                	js     801846 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ed:	8b 00                	mov    (%eax),%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	e8 f1 fb ff ff       	call   8013e8 <dev_lookup>
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 4b                	js     801846 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801802:	75 25                	jne    801829 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801804:	a1 04 40 80 00       	mov    0x804004,%eax
  801809:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80180b:	8b 40 48             	mov    0x48(%eax),%eax
  80180e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801812:	89 44 24 04          	mov    %eax,0x4(%esp)
  801816:	c7 04 24 14 2a 80 00 	movl   $0x802a14,(%esp)
  80181d:	e8 a2 e9 ff ff       	call   8001c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801827:	eb 1d                	jmp    801846 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801829:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182c:	8b 52 18             	mov    0x18(%edx),%edx
  80182f:	85 d2                	test   %edx,%edx
  801831:	74 0e                	je     801841 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801836:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80183a:	89 04 24             	mov    %eax,(%esp)
  80183d:	ff d2                	call   *%edx
  80183f:	eb 05                	jmp    801846 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801841:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801846:	83 c4 24             	add    $0x24,%esp
  801849:	5b                   	pop    %ebx
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	53                   	push   %ebx
  801850:	83 ec 24             	sub    $0x24,%esp
  801853:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801856:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185d:	8b 45 08             	mov    0x8(%ebp),%eax
  801860:	89 04 24             	mov    %eax,(%esp)
  801863:	e8 2a fb ff ff       	call   801392 <fd_lookup>
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 52                	js     8018be <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80186c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801873:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801876:	8b 00                	mov    (%eax),%eax
  801878:	89 04 24             	mov    %eax,(%esp)
  80187b:	e8 68 fb ff ff       	call   8013e8 <dev_lookup>
  801880:	85 c0                	test   %eax,%eax
  801882:	78 3a                	js     8018be <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801884:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801887:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80188b:	74 2c                	je     8018b9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80188d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801890:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801897:	00 00 00 
	stat->st_isdir = 0;
  80189a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a1:	00 00 00 
	stat->st_dev = dev;
  8018a4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018b1:	89 14 24             	mov    %edx,(%esp)
  8018b4:	ff 50 14             	call   *0x14(%eax)
  8018b7:	eb 05                	jmp    8018be <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018be:	83 c4 24             	add    $0x24,%esp
  8018c1:	5b                   	pop    %ebx
  8018c2:	5d                   	pop    %ebp
  8018c3:	c3                   	ret    

008018c4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018d3:	00 
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 88 02 00 00       	call   801b67 <open>
  8018df:	89 c3                	mov    %eax,%ebx
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 1b                	js     801900 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ec:	89 1c 24             	mov    %ebx,(%esp)
  8018ef:	e8 58 ff ff ff       	call   80184c <fstat>
  8018f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8018f6:	89 1c 24             	mov    %ebx,(%esp)
  8018f9:	e8 ce fb ff ff       	call   8014cc <close>
	return r;
  8018fe:	89 f3                	mov    %esi,%ebx
}
  801900:	89 d8                	mov    %ebx,%eax
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	5b                   	pop    %ebx
  801906:	5e                   	pop    %esi
  801907:	5d                   	pop    %ebp
  801908:	c3                   	ret    
  801909:	00 00                	add    %al,(%eax)
	...

0080190c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	83 ec 10             	sub    $0x10,%esp
  801914:	89 c3                	mov    %eax,%ebx
  801916:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801918:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80191f:	75 11                	jne    801932 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801921:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801928:	e8 da 09 00 00       	call   802307 <ipc_find_env>
  80192d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801932:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801939:	00 
  80193a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801941:	00 
  801942:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801946:	a1 00 40 80 00       	mov    0x804000,%eax
  80194b:	89 04 24             	mov    %eax,(%esp)
  80194e:	e8 4e 09 00 00       	call   8022a1 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801953:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80195a:	00 
  80195b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80195f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801966:	e8 c9 08 00 00       	call   802234 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5e                   	pop    %esi
  801970:	5d                   	pop    %ebp
  801971:	c3                   	ret    

00801972 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801978:	8b 45 08             	mov    0x8(%ebp),%eax
  80197b:	8b 40 0c             	mov    0xc(%eax),%eax
  80197e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801983:	8b 45 0c             	mov    0xc(%ebp),%eax
  801986:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80198b:	ba 00 00 00 00       	mov    $0x0,%edx
  801990:	b8 02 00 00 00       	mov    $0x2,%eax
  801995:	e8 72 ff ff ff       	call   80190c <fsipc>
}
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8019b7:	e8 50 ff ff ff       	call   80190c <fsipc>
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	53                   	push   %ebx
  8019c2:	83 ec 14             	sub    $0x14,%esp
  8019c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ce:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8019dd:	e8 2a ff ff ff       	call   80190c <fsipc>
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 2b                	js     801a11 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019e6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019ed:	00 
  8019ee:	89 1c 24             	mov    %ebx,(%esp)
  8019f1:	e8 79 ed ff ff       	call   80076f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8019fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a01:	a1 84 50 80 00       	mov    0x805084,%eax
  801a06:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a11:	83 c4 14             	add    $0x14,%esp
  801a14:	5b                   	pop    %ebx
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    

00801a17 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	53                   	push   %ebx
  801a1b:	83 ec 14             	sub    $0x14,%esp
  801a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	8b 40 0c             	mov    0xc(%eax),%eax
  801a27:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801a2c:	89 d8                	mov    %ebx,%eax
  801a2e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801a34:	76 05                	jbe    801a3b <devfile_write+0x24>
  801a36:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801a3b:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801a40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801a52:	e8 fb ee ff ff       	call   800952 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801a57:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5c:	b8 04 00 00 00       	mov    $0x4,%eax
  801a61:	e8 a6 fe ff ff       	call   80190c <fsipc>
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 53                	js     801abd <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801a6a:	39 c3                	cmp    %eax,%ebx
  801a6c:	73 24                	jae    801a92 <devfile_write+0x7b>
  801a6e:	c7 44 24 0c 80 2a 80 	movl   $0x802a80,0xc(%esp)
  801a75:	00 
  801a76:	c7 44 24 08 87 2a 80 	movl   $0x802a87,0x8(%esp)
  801a7d:	00 
  801a7e:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801a85:	00 
  801a86:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  801a8d:	e8 92 06 00 00       	call   802124 <_panic>
	assert(r <= PGSIZE);
  801a92:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a97:	7e 24                	jle    801abd <devfile_write+0xa6>
  801a99:	c7 44 24 0c a7 2a 80 	movl   $0x802aa7,0xc(%esp)
  801aa0:	00 
  801aa1:	c7 44 24 08 87 2a 80 	movl   $0x802a87,0x8(%esp)
  801aa8:	00 
  801aa9:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801ab0:	00 
  801ab1:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  801ab8:	e8 67 06 00 00       	call   802124 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801abd:	83 c4 14             	add    $0x14,%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 10             	sub    $0x10,%esp
  801acb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ad9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801adf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae4:	b8 03 00 00 00       	mov    $0x3,%eax
  801ae9:	e8 1e fe ff ff       	call   80190c <fsipc>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 6a                	js     801b5e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801af4:	39 c6                	cmp    %eax,%esi
  801af6:	73 24                	jae    801b1c <devfile_read+0x59>
  801af8:	c7 44 24 0c 80 2a 80 	movl   $0x802a80,0xc(%esp)
  801aff:	00 
  801b00:	c7 44 24 08 87 2a 80 	movl   $0x802a87,0x8(%esp)
  801b07:	00 
  801b08:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801b0f:	00 
  801b10:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  801b17:	e8 08 06 00 00       	call   802124 <_panic>
	assert(r <= PGSIZE);
  801b1c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b21:	7e 24                	jle    801b47 <devfile_read+0x84>
  801b23:	c7 44 24 0c a7 2a 80 	movl   $0x802aa7,0xc(%esp)
  801b2a:	00 
  801b2b:	c7 44 24 08 87 2a 80 	movl   $0x802a87,0x8(%esp)
  801b32:	00 
  801b33:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801b3a:	00 
  801b3b:	c7 04 24 9c 2a 80 00 	movl   $0x802a9c,(%esp)
  801b42:	e8 dd 05 00 00       	call   802124 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b4b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b52:	00 
  801b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b56:	89 04 24             	mov    %eax,(%esp)
  801b59:	e8 8a ed ff ff       	call   8008e8 <memmove>
	return r;
}
  801b5e:	89 d8                	mov    %ebx,%eax
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	5b                   	pop    %ebx
  801b64:	5e                   	pop    %esi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	56                   	push   %esi
  801b6b:	53                   	push   %ebx
  801b6c:	83 ec 20             	sub    $0x20,%esp
  801b6f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b72:	89 34 24             	mov    %esi,(%esp)
  801b75:	e8 c2 eb ff ff       	call   80073c <strlen>
  801b7a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b7f:	7f 60                	jg     801be1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b84:	89 04 24             	mov    %eax,(%esp)
  801b87:	e8 b3 f7 ff ff       	call   80133f <fd_alloc>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 54                	js     801be6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b96:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b9d:	e8 cd eb ff ff       	call   80076f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801baa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bad:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb2:	e8 55 fd ff ff       	call   80190c <fsipc>
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	79 15                	jns    801bd2 <open+0x6b>
		fd_close(fd, 0);
  801bbd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bc4:	00 
  801bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc8:	89 04 24             	mov    %eax,(%esp)
  801bcb:	e8 74 f8 ff ff       	call   801444 <fd_close>
		return r;
  801bd0:	eb 14                	jmp    801be6 <open+0x7f>
	}

	return fd2num(fd);
  801bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd5:	89 04 24             	mov    %eax,(%esp)
  801bd8:	e8 37 f7 ff ff       	call   801314 <fd2num>
  801bdd:	89 c3                	mov    %eax,%ebx
  801bdf:	eb 05                	jmp    801be6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801be1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801be6:	89 d8                	mov    %ebx,%eax
  801be8:	83 c4 20             	add    $0x20,%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfa:	b8 08 00 00 00       	mov    $0x8,%eax
  801bff:	e8 08 fd ff ff       	call   80190c <fsipc>
}
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    
	...

00801c08 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 10             	sub    $0x10,%esp
  801c10:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c13:	8b 45 08             	mov    0x8(%ebp),%eax
  801c16:	89 04 24             	mov    %eax,(%esp)
  801c19:	e8 06 f7 ff ff       	call   801324 <fd2data>
  801c1e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c20:	c7 44 24 04 b3 2a 80 	movl   $0x802ab3,0x4(%esp)
  801c27:	00 
  801c28:	89 34 24             	mov    %esi,(%esp)
  801c2b:	e8 3f eb ff ff       	call   80076f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c30:	8b 43 04             	mov    0x4(%ebx),%eax
  801c33:	2b 03                	sub    (%ebx),%eax
  801c35:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c3b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c42:	00 00 00 
	stat->st_dev = &devpipe;
  801c45:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c4c:	30 80 00 
	return 0;
}
  801c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	53                   	push   %ebx
  801c5f:	83 ec 14             	sub    $0x14,%esp
  801c62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c65:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c70:	e8 93 ef ff ff       	call   800c08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c75:	89 1c 24             	mov    %ebx,(%esp)
  801c78:	e8 a7 f6 ff ff       	call   801324 <fd2data>
  801c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c88:	e8 7b ef ff ff       	call   800c08 <sys_page_unmap>
}
  801c8d:	83 c4 14             	add    $0x14,%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	57                   	push   %edi
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	83 ec 2c             	sub    $0x2c,%esp
  801c9c:	89 c7                	mov    %eax,%edi
  801c9e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ca1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ca6:	8b 00                	mov    (%eax),%eax
  801ca8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cab:	89 3c 24             	mov    %edi,(%esp)
  801cae:	e8 99 06 00 00       	call   80234c <pageref>
  801cb3:	89 c6                	mov    %eax,%esi
  801cb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cb8:	89 04 24             	mov    %eax,(%esp)
  801cbb:	e8 8c 06 00 00       	call   80234c <pageref>
  801cc0:	39 c6                	cmp    %eax,%esi
  801cc2:	0f 94 c0             	sete   %al
  801cc5:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cc8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cce:	8b 12                	mov    (%edx),%edx
  801cd0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cd3:	39 cb                	cmp    %ecx,%ebx
  801cd5:	75 08                	jne    801cdf <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801cd7:	83 c4 2c             	add    $0x2c,%esp
  801cda:	5b                   	pop    %ebx
  801cdb:	5e                   	pop    %esi
  801cdc:	5f                   	pop    %edi
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801cdf:	83 f8 01             	cmp    $0x1,%eax
  801ce2:	75 bd                	jne    801ca1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ce4:	8b 42 58             	mov    0x58(%edx),%eax
  801ce7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801cee:	00 
  801cef:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf7:	c7 04 24 ba 2a 80 00 	movl   $0x802aba,(%esp)
  801cfe:	e8 c1 e4 ff ff       	call   8001c4 <cprintf>
  801d03:	eb 9c                	jmp    801ca1 <_pipeisclosed+0xe>

00801d05 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	57                   	push   %edi
  801d09:	56                   	push   %esi
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 1c             	sub    $0x1c,%esp
  801d0e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d11:	89 34 24             	mov    %esi,(%esp)
  801d14:	e8 0b f6 ff ff       	call   801324 <fd2data>
  801d19:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d1b:	bf 00 00 00 00       	mov    $0x0,%edi
  801d20:	eb 3c                	jmp    801d5e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d22:	89 da                	mov    %ebx,%edx
  801d24:	89 f0                	mov    %esi,%eax
  801d26:	e8 68 ff ff ff       	call   801c93 <_pipeisclosed>
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	75 38                	jne    801d67 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d2f:	e8 0e ee ff ff       	call   800b42 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d34:	8b 43 04             	mov    0x4(%ebx),%eax
  801d37:	8b 13                	mov    (%ebx),%edx
  801d39:	83 c2 20             	add    $0x20,%edx
  801d3c:	39 d0                	cmp    %edx,%eax
  801d3e:	73 e2                	jae    801d22 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d40:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d43:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d46:	89 c2                	mov    %eax,%edx
  801d48:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d4e:	79 05                	jns    801d55 <devpipe_write+0x50>
  801d50:	4a                   	dec    %edx
  801d51:	83 ca e0             	or     $0xffffffe0,%edx
  801d54:	42                   	inc    %edx
  801d55:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d59:	40                   	inc    %eax
  801d5a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5d:	47                   	inc    %edi
  801d5e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d61:	75 d1                	jne    801d34 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d63:	89 f8                	mov    %edi,%eax
  801d65:	eb 05                	jmp    801d6c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d67:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d6c:	83 c4 1c             	add    $0x1c,%esp
  801d6f:	5b                   	pop    %ebx
  801d70:	5e                   	pop    %esi
  801d71:	5f                   	pop    %edi
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    

00801d74 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	57                   	push   %edi
  801d78:	56                   	push   %esi
  801d79:	53                   	push   %ebx
  801d7a:	83 ec 1c             	sub    $0x1c,%esp
  801d7d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d80:	89 3c 24             	mov    %edi,(%esp)
  801d83:	e8 9c f5 ff ff       	call   801324 <fd2data>
  801d88:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d8a:	be 00 00 00 00       	mov    $0x0,%esi
  801d8f:	eb 3a                	jmp    801dcb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d91:	85 f6                	test   %esi,%esi
  801d93:	74 04                	je     801d99 <devpipe_read+0x25>
				return i;
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	eb 40                	jmp    801dd9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d99:	89 da                	mov    %ebx,%edx
  801d9b:	89 f8                	mov    %edi,%eax
  801d9d:	e8 f1 fe ff ff       	call   801c93 <_pipeisclosed>
  801da2:	85 c0                	test   %eax,%eax
  801da4:	75 2e                	jne    801dd4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801da6:	e8 97 ed ff ff       	call   800b42 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dab:	8b 03                	mov    (%ebx),%eax
  801dad:	3b 43 04             	cmp    0x4(%ebx),%eax
  801db0:	74 df                	je     801d91 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801db2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801db7:	79 05                	jns    801dbe <devpipe_read+0x4a>
  801db9:	48                   	dec    %eax
  801dba:	83 c8 e0             	or     $0xffffffe0,%eax
  801dbd:	40                   	inc    %eax
  801dbe:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801dc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dc8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dca:	46                   	inc    %esi
  801dcb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dce:	75 db                	jne    801dab <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dd0:	89 f0                	mov    %esi,%eax
  801dd2:	eb 05                	jmp    801dd9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dd4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dd9:	83 c4 1c             	add    $0x1c,%esp
  801ddc:	5b                   	pop    %ebx
  801ddd:	5e                   	pop    %esi
  801dde:	5f                   	pop    %edi
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    

00801de1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	57                   	push   %edi
  801de5:	56                   	push   %esi
  801de6:	53                   	push   %ebx
  801de7:	83 ec 3c             	sub    $0x3c,%esp
  801dea:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ded:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801df0:	89 04 24             	mov    %eax,(%esp)
  801df3:	e8 47 f5 ff ff       	call   80133f <fd_alloc>
  801df8:	89 c3                	mov    %eax,%ebx
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	0f 88 45 01 00 00    	js     801f47 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e09:	00 
  801e0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e18:	e8 44 ed ff ff       	call   800b61 <sys_page_alloc>
  801e1d:	89 c3                	mov    %eax,%ebx
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	0f 88 20 01 00 00    	js     801f47 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e27:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e2a:	89 04 24             	mov    %eax,(%esp)
  801e2d:	e8 0d f5 ff ff       	call   80133f <fd_alloc>
  801e32:	89 c3                	mov    %eax,%ebx
  801e34:	85 c0                	test   %eax,%eax
  801e36:	0f 88 f8 00 00 00    	js     801f34 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e43:	00 
  801e44:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e52:	e8 0a ed ff ff       	call   800b61 <sys_page_alloc>
  801e57:	89 c3                	mov    %eax,%ebx
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	0f 88 d3 00 00 00    	js     801f34 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e64:	89 04 24             	mov    %eax,(%esp)
  801e67:	e8 b8 f4 ff ff       	call   801324 <fd2data>
  801e6c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e75:	00 
  801e76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e81:	e8 db ec ff ff       	call   800b61 <sys_page_alloc>
  801e86:	89 c3                	mov    %eax,%ebx
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	0f 88 91 00 00 00    	js     801f21 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e93:	89 04 24             	mov    %eax,(%esp)
  801e96:	e8 89 f4 ff ff       	call   801324 <fd2data>
  801e9b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ea2:	00 
  801ea3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ea7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801eae:	00 
  801eaf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eba:	e8 f6 ec ff ff       	call   800bb5 <sys_page_map>
  801ebf:	89 c3                	mov    %eax,%ebx
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	78 4c                	js     801f11 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ec5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ecb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ece:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ed0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ed3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eda:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ee0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ee3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ee5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ee8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ef2:	89 04 24             	mov    %eax,(%esp)
  801ef5:	e8 1a f4 ff ff       	call   801314 <fd2num>
  801efa:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801efc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eff:	89 04 24             	mov    %eax,(%esp)
  801f02:	e8 0d f4 ff ff       	call   801314 <fd2num>
  801f07:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f0f:	eb 36                	jmp    801f47 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f11:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f1c:	e8 e7 ec ff ff       	call   800c08 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f21:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f2f:	e8 d4 ec ff ff       	call   800c08 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f42:	e8 c1 ec ff ff       	call   800c08 <sys_page_unmap>
    err:
	return r;
}
  801f47:	89 d8                	mov    %ebx,%eax
  801f49:	83 c4 3c             	add    $0x3c,%esp
  801f4c:	5b                   	pop    %ebx
  801f4d:	5e                   	pop    %esi
  801f4e:	5f                   	pop    %edi
  801f4f:	5d                   	pop    %ebp
  801f50:	c3                   	ret    

00801f51 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f61:	89 04 24             	mov    %eax,(%esp)
  801f64:	e8 29 f4 ff ff       	call   801392 <fd_lookup>
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	78 15                	js     801f82 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f70:	89 04 24             	mov    %eax,(%esp)
  801f73:	e8 ac f3 ff ff       	call   801324 <fd2data>
	return _pipeisclosed(fd, p);
  801f78:	89 c2                	mov    %eax,%edx
  801f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7d:	e8 11 fd ff ff       	call   801c93 <_pipeisclosed>
}
  801f82:	c9                   	leave  
  801f83:	c3                   	ret    

00801f84 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f87:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    

00801f8e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f8e:	55                   	push   %ebp
  801f8f:	89 e5                	mov    %esp,%ebp
  801f91:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f94:	c7 44 24 04 d2 2a 80 	movl   $0x802ad2,0x4(%esp)
  801f9b:	00 
  801f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9f:	89 04 24             	mov    %eax,(%esp)
  801fa2:	e8 c8 e7 ff ff       	call   80076f <strcpy>
	return 0;
}
  801fa7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fac:	c9                   	leave  
  801fad:	c3                   	ret    

00801fae <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fba:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fbf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc5:	eb 30                	jmp    801ff7 <devcons_write+0x49>
		m = n - tot;
  801fc7:	8b 75 10             	mov    0x10(%ebp),%esi
  801fca:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801fcc:	83 fe 7f             	cmp    $0x7f,%esi
  801fcf:	76 05                	jbe    801fd6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801fd1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fd6:	89 74 24 08          	mov    %esi,0x8(%esp)
  801fda:	03 45 0c             	add    0xc(%ebp),%eax
  801fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe1:	89 3c 24             	mov    %edi,(%esp)
  801fe4:	e8 ff e8 ff ff       	call   8008e8 <memmove>
		sys_cputs(buf, m);
  801fe9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fed:	89 3c 24             	mov    %edi,(%esp)
  801ff0:	e8 9f ea ff ff       	call   800a94 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ff5:	01 f3                	add    %esi,%ebx
  801ff7:	89 d8                	mov    %ebx,%eax
  801ff9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ffc:	72 c9                	jb     801fc7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ffe:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802004:	5b                   	pop    %ebx
  802005:	5e                   	pop    %esi
  802006:	5f                   	pop    %edi
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    

00802009 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80200f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802013:	75 07                	jne    80201c <devcons_read+0x13>
  802015:	eb 25                	jmp    80203c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802017:	e8 26 eb ff ff       	call   800b42 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80201c:	e8 91 ea ff ff       	call   800ab2 <sys_cgetc>
  802021:	85 c0                	test   %eax,%eax
  802023:	74 f2                	je     802017 <devcons_read+0xe>
  802025:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802027:	85 c0                	test   %eax,%eax
  802029:	78 1d                	js     802048 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80202b:	83 f8 04             	cmp    $0x4,%eax
  80202e:	74 13                	je     802043 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802030:	8b 45 0c             	mov    0xc(%ebp),%eax
  802033:	88 10                	mov    %dl,(%eax)
	return 1;
  802035:	b8 01 00 00 00       	mov    $0x1,%eax
  80203a:	eb 0c                	jmp    802048 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80203c:	b8 00 00 00 00       	mov    $0x0,%eax
  802041:	eb 05                	jmp    802048 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802043:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802050:	8b 45 08             	mov    0x8(%ebp),%eax
  802053:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802056:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80205d:	00 
  80205e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802061:	89 04 24             	mov    %eax,(%esp)
  802064:	e8 2b ea ff ff       	call   800a94 <sys_cputs>
}
  802069:	c9                   	leave  
  80206a:	c3                   	ret    

0080206b <getchar>:

int
getchar(void)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802071:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802078:	00 
  802079:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80207c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802080:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802087:	e8 a4 f5 ff ff       	call   801630 <read>
	if (r < 0)
  80208c:	85 c0                	test   %eax,%eax
  80208e:	78 0f                	js     80209f <getchar+0x34>
		return r;
	if (r < 1)
  802090:	85 c0                	test   %eax,%eax
  802092:	7e 06                	jle    80209a <getchar+0x2f>
		return -E_EOF;
	return c;
  802094:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802098:	eb 05                	jmp    80209f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80209a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80209f:	c9                   	leave  
  8020a0:	c3                   	ret    

008020a1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020a1:	55                   	push   %ebp
  8020a2:	89 e5                	mov    %esp,%ebp
  8020a4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 d9 f2 ff ff       	call   801392 <fd_lookup>
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	78 11                	js     8020ce <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8020bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c6:	39 10                	cmp    %edx,(%eax)
  8020c8:	0f 94 c0             	sete   %al
  8020cb:	0f b6 c0             	movzbl %al,%eax
}
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    

008020d0 <opencons>:

int
opencons(void)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d9:	89 04 24             	mov    %eax,(%esp)
  8020dc:	e8 5e f2 ff ff       	call   80133f <fd_alloc>
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 3c                	js     802121 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020ec:	00 
  8020ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020fb:	e8 61 ea ff ff       	call   800b61 <sys_page_alloc>
  802100:	85 c0                	test   %eax,%eax
  802102:	78 1d                	js     802121 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802104:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80210a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80210f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802112:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802119:	89 04 24             	mov    %eax,(%esp)
  80211c:	e8 f3 f1 ff ff       	call   801314 <fd2num>
}
  802121:	c9                   	leave  
  802122:	c3                   	ret    
	...

00802124 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	56                   	push   %esi
  802128:	53                   	push   %ebx
  802129:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80212c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80212f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802135:	e8 e9 e9 ff ff       	call   800b23 <sys_getenvid>
  80213a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80213d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802141:	8b 55 08             	mov    0x8(%ebp),%edx
  802144:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802148:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80214c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802150:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  802157:	e8 68 e0 ff ff       	call   8001c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80215c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802160:	8b 45 10             	mov    0x10(%ebp),%eax
  802163:	89 04 24             	mov    %eax,(%esp)
  802166:	e8 f8 df ff ff       	call   800163 <vcprintf>
	cprintf("\n");
  80216b:	c7 04 24 f0 29 80 00 	movl   $0x8029f0,(%esp)
  802172:	e8 4d e0 ff ff       	call   8001c4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802177:	cc                   	int3   
  802178:	eb fd                	jmp    802177 <_panic+0x53>
	...

0080217c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	53                   	push   %ebx
  802180:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802183:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80218a:	75 6f                	jne    8021fb <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  80218c:	e8 92 e9 ff ff       	call   800b23 <sys_getenvid>
  802191:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  802193:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80219a:	00 
  80219b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021a2:	ee 
  8021a3:	89 04 24             	mov    %eax,(%esp)
  8021a6:	e8 b6 e9 ff ff       	call   800b61 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	79 1c                	jns    8021cb <set_pgfault_handler+0x4f>
  8021af:	c7 44 24 08 04 2b 80 	movl   $0x802b04,0x8(%esp)
  8021b6:	00 
  8021b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8021be:	00 
  8021bf:	c7 04 24 60 2b 80 00 	movl   $0x802b60,(%esp)
  8021c6:	e8 59 ff ff ff       	call   802124 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8021cb:	c7 44 24 04 0c 22 80 	movl   $0x80220c,0x4(%esp)
  8021d2:	00 
  8021d3:	89 1c 24             	mov    %ebx,(%esp)
  8021d6:	e8 26 eb ff ff       	call   800d01 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	79 1c                	jns    8021fb <set_pgfault_handler+0x7f>
  8021df:	c7 44 24 08 2c 2b 80 	movl   $0x802b2c,0x8(%esp)
  8021e6:	00 
  8021e7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8021ee:	00 
  8021ef:	c7 04 24 60 2b 80 00 	movl   $0x802b60,(%esp)
  8021f6:	e8 29 ff ff ff       	call   802124 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fe:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802203:	83 c4 14             	add    $0x14,%esp
  802206:	5b                   	pop    %ebx
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	00 00                	add    %al,(%eax)
	...

0080220c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80220c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80220d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802212:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802214:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  802217:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  80221b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  802220:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  802224:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  802226:	83 c4 08             	add    $0x8,%esp
	popal
  802229:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  80222a:	83 c4 04             	add    $0x4,%esp
	popfl
  80222d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  80222e:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802231:	c3                   	ret    
	...

00802234 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802234:	55                   	push   %ebp
  802235:	89 e5                	mov    %esp,%ebp
  802237:	56                   	push   %esi
  802238:	53                   	push   %ebx
  802239:	83 ec 10             	sub    $0x10,%esp
  80223c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80223f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802242:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802245:	85 c0                	test   %eax,%eax
  802247:	75 05                	jne    80224e <ipc_recv+0x1a>
  802249:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  80224e:	89 04 24             	mov    %eax,(%esp)
  802251:	e8 21 eb ff ff       	call   800d77 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  802256:	85 c0                	test   %eax,%eax
  802258:	79 16                	jns    802270 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  80225a:	85 db                	test   %ebx,%ebx
  80225c:	74 06                	je     802264 <ipc_recv+0x30>
  80225e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  802264:	85 f6                	test   %esi,%esi
  802266:	74 32                	je     80229a <ipc_recv+0x66>
  802268:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80226e:	eb 2a                	jmp    80229a <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802270:	85 db                	test   %ebx,%ebx
  802272:	74 0c                	je     802280 <ipc_recv+0x4c>
  802274:	a1 04 40 80 00       	mov    0x804004,%eax
  802279:	8b 00                	mov    (%eax),%eax
  80227b:	8b 40 74             	mov    0x74(%eax),%eax
  80227e:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802280:	85 f6                	test   %esi,%esi
  802282:	74 0c                	je     802290 <ipc_recv+0x5c>
  802284:	a1 04 40 80 00       	mov    0x804004,%eax
  802289:	8b 00                	mov    (%eax),%eax
  80228b:	8b 40 78             	mov    0x78(%eax),%eax
  80228e:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  802290:	a1 04 40 80 00       	mov    0x804004,%eax
  802295:	8b 00                	mov    (%eax),%eax
  802297:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5d                   	pop    %ebp
  8022a0:	c3                   	ret    

008022a1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022a1:	55                   	push   %ebp
  8022a2:	89 e5                	mov    %esp,%ebp
  8022a4:	57                   	push   %edi
  8022a5:	56                   	push   %esi
  8022a6:	53                   	push   %ebx
  8022a7:	83 ec 1c             	sub    $0x1c,%esp
  8022aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022b0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8022b3:	85 db                	test   %ebx,%ebx
  8022b5:	75 05                	jne    8022bc <ipc_send+0x1b>
  8022b7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8022bc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8022c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cb:	89 04 24             	mov    %eax,(%esp)
  8022ce:	e8 81 ea ff ff       	call   800d54 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8022d3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022d6:	75 07                	jne    8022df <ipc_send+0x3e>
  8022d8:	e8 65 e8 ff ff       	call   800b42 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8022dd:	eb dd                	jmp    8022bc <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	79 1c                	jns    8022ff <ipc_send+0x5e>
  8022e3:	c7 44 24 08 6e 2b 80 	movl   $0x802b6e,0x8(%esp)
  8022ea:	00 
  8022eb:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8022f2:	00 
  8022f3:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  8022fa:	e8 25 fe ff ff       	call   802124 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  8022ff:	83 c4 1c             	add    $0x1c,%esp
  802302:	5b                   	pop    %ebx
  802303:	5e                   	pop    %esi
  802304:	5f                   	pop    %edi
  802305:	5d                   	pop    %ebp
  802306:	c3                   	ret    

00802307 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	53                   	push   %ebx
  80230b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80230e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802313:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80231a:	89 c2                	mov    %eax,%edx
  80231c:	c1 e2 07             	shl    $0x7,%edx
  80231f:	29 ca                	sub    %ecx,%edx
  802321:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802327:	8b 52 50             	mov    0x50(%edx),%edx
  80232a:	39 da                	cmp    %ebx,%edx
  80232c:	75 0f                	jne    80233d <ipc_find_env+0x36>
			return envs[i].env_id;
  80232e:	c1 e0 07             	shl    $0x7,%eax
  802331:	29 c8                	sub    %ecx,%eax
  802333:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802338:	8b 40 40             	mov    0x40(%eax),%eax
  80233b:	eb 0c                	jmp    802349 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80233d:	40                   	inc    %eax
  80233e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802343:	75 ce                	jne    802313 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802345:	66 b8 00 00          	mov    $0x0,%ax
}
  802349:	5b                   	pop    %ebx
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    

0080234c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  802352:	89 c2                	mov    %eax,%edx
  802354:	c1 ea 16             	shr    $0x16,%edx
  802357:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80235e:	f6 c2 01             	test   $0x1,%dl
  802361:	74 1e                	je     802381 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802363:	c1 e8 0c             	shr    $0xc,%eax
  802366:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80236d:	a8 01                	test   $0x1,%al
  80236f:	74 17                	je     802388 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802371:	c1 e8 0c             	shr    $0xc,%eax
  802374:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80237b:	ef 
  80237c:	0f b7 c0             	movzwl %ax,%eax
  80237f:	eb 0c                	jmp    80238d <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802381:	b8 00 00 00 00       	mov    $0x0,%eax
  802386:	eb 05                	jmp    80238d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802388:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80238d:	5d                   	pop    %ebp
  80238e:	c3                   	ret    
	...

00802390 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802390:	55                   	push   %ebp
  802391:	57                   	push   %edi
  802392:	56                   	push   %esi
  802393:	83 ec 10             	sub    $0x10,%esp
  802396:	8b 74 24 20          	mov    0x20(%esp),%esi
  80239a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80239e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8023a6:	89 cd                	mov    %ecx,%ebp
  8023a8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023ac:	85 c0                	test   %eax,%eax
  8023ae:	75 2c                	jne    8023dc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8023b0:	39 f9                	cmp    %edi,%ecx
  8023b2:	77 68                	ja     80241c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023b4:	85 c9                	test   %ecx,%ecx
  8023b6:	75 0b                	jne    8023c3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bd:	31 d2                	xor    %edx,%edx
  8023bf:	f7 f1                	div    %ecx
  8023c1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8023c3:	31 d2                	xor    %edx,%edx
  8023c5:	89 f8                	mov    %edi,%eax
  8023c7:	f7 f1                	div    %ecx
  8023c9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023cb:	89 f0                	mov    %esi,%eax
  8023cd:	f7 f1                	div    %ecx
  8023cf:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023d1:	89 f0                	mov    %esi,%eax
  8023d3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023d5:	83 c4 10             	add    $0x10,%esp
  8023d8:	5e                   	pop    %esi
  8023d9:	5f                   	pop    %edi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023dc:	39 f8                	cmp    %edi,%eax
  8023de:	77 2c                	ja     80240c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023e0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8023e3:	83 f6 1f             	xor    $0x1f,%esi
  8023e6:	75 4c                	jne    802434 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023e8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023ea:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023ef:	72 0a                	jb     8023fb <__udivdi3+0x6b>
  8023f1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8023f5:	0f 87 ad 00 00 00    	ja     8024a8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023fb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802400:	89 f0                	mov    %esi,%eax
  802402:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802404:	83 c4 10             	add    $0x10,%esp
  802407:	5e                   	pop    %esi
  802408:	5f                   	pop    %edi
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    
  80240b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80240c:	31 ff                	xor    %edi,%edi
  80240e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802410:	89 f0                	mov    %esi,%eax
  802412:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802414:	83 c4 10             	add    $0x10,%esp
  802417:	5e                   	pop    %esi
  802418:	5f                   	pop    %edi
  802419:	5d                   	pop    %ebp
  80241a:	c3                   	ret    
  80241b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80241c:	89 fa                	mov    %edi,%edx
  80241e:	89 f0                	mov    %esi,%eax
  802420:	f7 f1                	div    %ecx
  802422:	89 c6                	mov    %eax,%esi
  802424:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802426:	89 f0                	mov    %esi,%eax
  802428:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80242a:	83 c4 10             	add    $0x10,%esp
  80242d:	5e                   	pop    %esi
  80242e:	5f                   	pop    %edi
  80242f:	5d                   	pop    %ebp
  802430:	c3                   	ret    
  802431:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802434:	89 f1                	mov    %esi,%ecx
  802436:	d3 e0                	shl    %cl,%eax
  802438:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80243c:	b8 20 00 00 00       	mov    $0x20,%eax
  802441:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802443:	89 ea                	mov    %ebp,%edx
  802445:	88 c1                	mov    %al,%cl
  802447:	d3 ea                	shr    %cl,%edx
  802449:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80244d:	09 ca                	or     %ecx,%edx
  80244f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802453:	89 f1                	mov    %esi,%ecx
  802455:	d3 e5                	shl    %cl,%ebp
  802457:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80245b:	89 fd                	mov    %edi,%ebp
  80245d:	88 c1                	mov    %al,%cl
  80245f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802461:	89 fa                	mov    %edi,%edx
  802463:	89 f1                	mov    %esi,%ecx
  802465:	d3 e2                	shl    %cl,%edx
  802467:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80246b:	88 c1                	mov    %al,%cl
  80246d:	d3 ef                	shr    %cl,%edi
  80246f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802471:	89 f8                	mov    %edi,%eax
  802473:	89 ea                	mov    %ebp,%edx
  802475:	f7 74 24 08          	divl   0x8(%esp)
  802479:	89 d1                	mov    %edx,%ecx
  80247b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80247d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802481:	39 d1                	cmp    %edx,%ecx
  802483:	72 17                	jb     80249c <__udivdi3+0x10c>
  802485:	74 09                	je     802490 <__udivdi3+0x100>
  802487:	89 fe                	mov    %edi,%esi
  802489:	31 ff                	xor    %edi,%edi
  80248b:	e9 41 ff ff ff       	jmp    8023d1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802490:	8b 54 24 04          	mov    0x4(%esp),%edx
  802494:	89 f1                	mov    %esi,%ecx
  802496:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802498:	39 c2                	cmp    %eax,%edx
  80249a:	73 eb                	jae    802487 <__udivdi3+0xf7>
		{
		  q0--;
  80249c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80249f:	31 ff                	xor    %edi,%edi
  8024a1:	e9 2b ff ff ff       	jmp    8023d1 <__udivdi3+0x41>
  8024a6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024a8:	31 f6                	xor    %esi,%esi
  8024aa:	e9 22 ff ff ff       	jmp    8023d1 <__udivdi3+0x41>
	...

008024b0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	83 ec 20             	sub    $0x20,%esp
  8024b6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024ba:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024be:	89 44 24 14          	mov    %eax,0x14(%esp)
  8024c2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8024c6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024ca:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8024ce:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8024d0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024d2:	85 ed                	test   %ebp,%ebp
  8024d4:	75 16                	jne    8024ec <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8024d6:	39 f1                	cmp    %esi,%ecx
  8024d8:	0f 86 a6 00 00 00    	jbe    802584 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024de:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8024e0:	89 d0                	mov    %edx,%eax
  8024e2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024e4:	83 c4 20             	add    $0x20,%esp
  8024e7:	5e                   	pop    %esi
  8024e8:	5f                   	pop    %edi
  8024e9:	5d                   	pop    %ebp
  8024ea:	c3                   	ret    
  8024eb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024ec:	39 f5                	cmp    %esi,%ebp
  8024ee:	0f 87 ac 00 00 00    	ja     8025a0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024f4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8024f7:	83 f0 1f             	xor    $0x1f,%eax
  8024fa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8024fe:	0f 84 a8 00 00 00    	je     8025ac <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802504:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802508:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80250a:	bf 20 00 00 00       	mov    $0x20,%edi
  80250f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802513:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802517:	89 f9                	mov    %edi,%ecx
  802519:	d3 e8                	shr    %cl,%eax
  80251b:	09 e8                	or     %ebp,%eax
  80251d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802521:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802525:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802529:	d3 e0                	shl    %cl,%eax
  80252b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80252f:	89 f2                	mov    %esi,%edx
  802531:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802533:	8b 44 24 14          	mov    0x14(%esp),%eax
  802537:	d3 e0                	shl    %cl,%eax
  802539:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80253d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802541:	89 f9                	mov    %edi,%ecx
  802543:	d3 e8                	shr    %cl,%eax
  802545:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802547:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802549:	89 f2                	mov    %esi,%edx
  80254b:	f7 74 24 18          	divl   0x18(%esp)
  80254f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802551:	f7 64 24 0c          	mull   0xc(%esp)
  802555:	89 c5                	mov    %eax,%ebp
  802557:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802559:	39 d6                	cmp    %edx,%esi
  80255b:	72 67                	jb     8025c4 <__umoddi3+0x114>
  80255d:	74 75                	je     8025d4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80255f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802563:	29 e8                	sub    %ebp,%eax
  802565:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802567:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80256b:	d3 e8                	shr    %cl,%eax
  80256d:	89 f2                	mov    %esi,%edx
  80256f:	89 f9                	mov    %edi,%ecx
  802571:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802573:	09 d0                	or     %edx,%eax
  802575:	89 f2                	mov    %esi,%edx
  802577:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80257b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80257d:	83 c4 20             	add    $0x20,%esp
  802580:	5e                   	pop    %esi
  802581:	5f                   	pop    %edi
  802582:	5d                   	pop    %ebp
  802583:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802584:	85 c9                	test   %ecx,%ecx
  802586:	75 0b                	jne    802593 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802588:	b8 01 00 00 00       	mov    $0x1,%eax
  80258d:	31 d2                	xor    %edx,%edx
  80258f:	f7 f1                	div    %ecx
  802591:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802593:	89 f0                	mov    %esi,%eax
  802595:	31 d2                	xor    %edx,%edx
  802597:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802599:	89 f8                	mov    %edi,%eax
  80259b:	e9 3e ff ff ff       	jmp    8024de <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025a0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025a2:	83 c4 20             	add    $0x20,%esp
  8025a5:	5e                   	pop    %esi
  8025a6:	5f                   	pop    %edi
  8025a7:	5d                   	pop    %ebp
  8025a8:	c3                   	ret    
  8025a9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025ac:	39 f5                	cmp    %esi,%ebp
  8025ae:	72 04                	jb     8025b4 <__umoddi3+0x104>
  8025b0:	39 f9                	cmp    %edi,%ecx
  8025b2:	77 06                	ja     8025ba <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025b4:	89 f2                	mov    %esi,%edx
  8025b6:	29 cf                	sub    %ecx,%edi
  8025b8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8025ba:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025bc:	83 c4 20             	add    $0x20,%esp
  8025bf:	5e                   	pop    %esi
  8025c0:	5f                   	pop    %edi
  8025c1:	5d                   	pop    %ebp
  8025c2:	c3                   	ret    
  8025c3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025c4:	89 d1                	mov    %edx,%ecx
  8025c6:	89 c5                	mov    %eax,%ebp
  8025c8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8025cc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8025d0:	eb 8d                	jmp    80255f <__umoddi3+0xaf>
  8025d2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025d4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8025d8:	72 ea                	jb     8025c4 <__umoddi3+0x114>
  8025da:	89 f1                	mov    %esi,%ecx
  8025dc:	eb 81                	jmp    80255f <__umoddi3+0xaf>
