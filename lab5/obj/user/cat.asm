
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 33 01 00 00       	call   800164 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800043:	eb 40                	jmp    800085 <cat+0x51>
		if ((r = write(1, buf, n)) != n)
  800045:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800049:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800050:	00 
  800051:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800058:	e8 74 12 00 00       	call   8012d1 <write>
  80005d:	39 d8                	cmp    %ebx,%eax
  80005f:	74 24                	je     800085 <cat+0x51>
			panic("write error copying %s: %e", s, r);
  800061:	89 44 24 10          	mov    %eax,0x10(%esp)
  800065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800069:	c7 44 24 08 e0 21 80 	movl   $0x8021e0,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 fb 21 80 00 	movl   $0x8021fb,(%esp)
  800080:	e8 53 01 00 00       	call   8001d8 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800085:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800094:	00 
  800095:	89 34 24             	mov    %esi,(%esp)
  800098:	e8 57 11 00 00       	call   8011f4 <read>
  80009d:	89 c3                	mov    %eax,%ebx
  80009f:	85 c0                	test   %eax,%eax
  8000a1:	7f a2                	jg     800045 <cat+0x11>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 24                	jns    8000cb <cat+0x97>
		panic("error reading %s: %e", s, n);
  8000a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000af:	c7 44 24 08 06 22 80 	movl   $0x802206,0x8(%esp)
  8000b6:	00 
  8000b7:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 fb 21 80 00 	movl   $0x8021fb,(%esp)
  8000c6:	e8 0d 01 00 00       	call   8001d8 <_panic>
}
  8000cb:	83 c4 2c             	add    $0x2c,%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int f, i;

	binaryname = "cat";
  8000df:	c7 05 00 30 80 00 1b 	movl   $0x80221b,0x803000
  8000e6:	22 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	75 62                	jne    800151 <umain+0x7e>
		cat(0, "<stdin>");
  8000ef:	c7 44 24 04 1f 22 80 	movl   $0x80221f,0x4(%esp)
  8000f6:	00 
  8000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fe:	e8 31 ff ff ff       	call   800034 <cat>
  800103:	eb 56                	jmp    80015b <umain+0x88>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80010c:	00 
  80010d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800110:	89 04 24             	mov    %eax,(%esp)
  800113:	e8 13 16 00 00       	call   80172b <open>
  800118:	89 c7                	mov    %eax,%edi
			if (f < 0)
  80011a:	85 c0                	test   %eax,%eax
  80011c:	79 19                	jns    800137 <umain+0x64>
				printf("can't open %s: %e\n", argv[i], f);
  80011e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800122:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	c7 04 24 27 22 80 00 	movl   $0x802227,(%esp)
  800130:	e8 ac 17 00 00       	call   8018e1 <printf>
  800135:	eb 17                	jmp    80014e <umain+0x7b>
			else {
				cat(f, argv[i]);
  800137:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	89 3c 24             	mov    %edi,(%esp)
  800141:	e8 ee fe ff ff       	call   800034 <cat>
				close(f);
  800146:	89 3c 24             	mov    %edi,(%esp)
  800149:	e8 42 0f 00 00       	call   801090 <close>

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80014e:	43                   	inc    %ebx
  80014f:	eb 05                	jmp    800156 <umain+0x83>
umain(int argc, char **argv)
{
	int f, i;

	binaryname = "cat";
	if (argc == 1)
  800151:	bb 01 00 00 00       	mov    $0x1,%ebx
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800156:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800159:	7c aa                	jl     800105 <umain+0x32>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80015b:	83 c4 1c             	add    $0x1c,%esp
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    
	...

00800164 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 20             	sub    $0x20,%esp
  80016c:	8b 75 08             	mov    0x8(%ebp),%esi
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800172:	e8 b8 0a 00 00       	call   800c2f <sys_getenvid>
  800177:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800183:	c1 e0 07             	shl    $0x7,%eax
  800186:	29 d0                	sub    %edx,%eax
  800188:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80018d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800190:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800193:	a3 20 60 80 00       	mov    %eax,0x806020
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800198:	85 f6                	test   %esi,%esi
  80019a:	7e 07                	jle    8001a3 <libmain+0x3f>
		binaryname = argv[0];
  80019c:	8b 03                	mov    (%ebx),%eax
  80019e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a7:	89 34 24             	mov    %esi,(%esp)
  8001aa:	e8 24 ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001af:	e8 08 00 00 00       	call   8001bc <exit>
}
  8001b4:	83 c4 20             	add    $0x20,%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    
	...

008001bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001c2:	e8 fa 0e 00 00       	call   8010c1 <close_all>
	sys_env_destroy(0);
  8001c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ce:	e8 0a 0a 00 00       	call   800bdd <sys_env_destroy>
}
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    
  8001d5:	00 00                	add    %al,(%eax)
	...

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001e0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001e9:	e8 41 0a 00 00       	call   800c2f <sys_getenvid>
  8001ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	c7 04 24 44 22 80 00 	movl   $0x802244,(%esp)
  80020b:	e8 c0 00 00 00       	call   8002d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800210:	89 74 24 04          	mov    %esi,0x4(%esp)
  800214:	8b 45 10             	mov    0x10(%ebp),%eax
  800217:	89 04 24             	mov    %eax,(%esp)
  80021a:	e8 50 00 00 00       	call   80026f <vcprintf>
	cprintf("\n");
  80021f:	c7 04 24 8a 26 80 00 	movl   $0x80268a,(%esp)
  800226:	e8 a5 00 00 00       	call   8002d0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80022b:	cc                   	int3   
  80022c:	eb fd                	jmp    80022b <_panic+0x53>
	...

00800230 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	53                   	push   %ebx
  800234:	83 ec 14             	sub    $0x14,%esp
  800237:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80023a:	8b 03                	mov    (%ebx),%eax
  80023c:	8b 55 08             	mov    0x8(%ebp),%edx
  80023f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800243:	40                   	inc    %eax
  800244:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800246:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024b:	75 19                	jne    800266 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80024d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800254:	00 
  800255:	8d 43 08             	lea    0x8(%ebx),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	e8 40 09 00 00       	call   800ba0 <sys_cputs>
		b->idx = 0;
  800260:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800266:	ff 43 04             	incl   0x4(%ebx)
}
  800269:	83 c4 14             	add    $0x14,%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800278:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027f:	00 00 00 
	b.cnt = 0;
  800282:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800289:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800293:	8b 45 08             	mov    0x8(%ebp),%eax
  800296:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a4:	c7 04 24 30 02 80 00 	movl   $0x800230,(%esp)
  8002ab:	e8 82 01 00 00       	call   800432 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ba:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	e8 d8 08 00 00       	call   800ba0 <sys_cputs>

	return b.cnt;
}
  8002c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	e8 87 ff ff ff       	call   80026f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    
	...

008002ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	57                   	push   %edi
  8002f0:	56                   	push   %esi
  8002f1:	53                   	push   %ebx
  8002f2:	83 ec 3c             	sub    $0x3c,%esp
  8002f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f8:	89 d7                	mov    %edx,%edi
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800306:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800309:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80030c:	85 c0                	test   %eax,%eax
  80030e:	75 08                	jne    800318 <printnum+0x2c>
  800310:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800313:	39 45 10             	cmp    %eax,0x10(%ebp)
  800316:	77 57                	ja     80036f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800318:	89 74 24 10          	mov    %esi,0x10(%esp)
  80031c:	4b                   	dec    %ebx
  80031d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800321:	8b 45 10             	mov    0x10(%ebp),%eax
  800324:	89 44 24 08          	mov    %eax,0x8(%esp)
  800328:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80032c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800330:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800337:	00 
  800338:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033b:	89 04 24             	mov    %eax,(%esp)
  80033e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800341:	89 44 24 04          	mov    %eax,0x4(%esp)
  800345:	e8 32 1c 00 00       	call   801f7c <__udivdi3>
  80034a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80034e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	89 54 24 04          	mov    %edx,0x4(%esp)
  800359:	89 fa                	mov    %edi,%edx
  80035b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035e:	e8 89 ff ff ff       	call   8002ec <printnum>
  800363:	eb 0f                	jmp    800374 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800365:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800369:	89 34 24             	mov    %esi,(%esp)
  80036c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036f:	4b                   	dec    %ebx
  800370:	85 db                	test   %ebx,%ebx
  800372:	7f f1                	jg     800365 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800374:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800378:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80037c:	8b 45 10             	mov    0x10(%ebp),%eax
  80037f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800383:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038a:	00 
  80038b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038e:	89 04 24             	mov    %eax,(%esp)
  800391:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800394:	89 44 24 04          	mov    %eax,0x4(%esp)
  800398:	e8 ff 1c 00 00       	call   80209c <__umoddi3>
  80039d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003a1:	0f be 80 67 22 80 00 	movsbl 0x802267(%eax),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003ae:	83 c4 3c             	add    $0x3c,%esp
  8003b1:	5b                   	pop    %ebx
  8003b2:	5e                   	pop    %esi
  8003b3:	5f                   	pop    %edi
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b9:	83 fa 01             	cmp    $0x1,%edx
  8003bc:	7e 0e                	jle    8003cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003be:	8b 10                	mov    (%eax),%edx
  8003c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c3:	89 08                	mov    %ecx,(%eax)
  8003c5:	8b 02                	mov    (%edx),%eax
  8003c7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ca:	eb 22                	jmp    8003ee <getuint+0x38>
	else if (lflag)
  8003cc:	85 d2                	test   %edx,%edx
  8003ce:	74 10                	je     8003e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003de:	eb 0e                	jmp    8003ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e0:	8b 10                	mov    (%eax),%edx
  8003e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e5:	89 08                	mov    %ecx,(%eax)
  8003e7:	8b 02                	mov    (%edx),%eax
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fe:	73 08                	jae    800408 <sprintputch+0x18>
		*b->buf++ = ch;
  800400:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800403:	88 0a                	mov    %cl,(%edx)
  800405:	42                   	inc    %edx
  800406:	89 10                	mov    %edx,(%eax)
}
  800408:	5d                   	pop    %ebp
  800409:	c3                   	ret    

0080040a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800410:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800413:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800417:	8b 45 10             	mov    0x10(%ebp),%eax
  80041a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800421:	89 44 24 04          	mov    %eax,0x4(%esp)
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	e8 02 00 00 00       	call   800432 <vprintfmt>
	va_end(ap);
}
  800430:	c9                   	leave  
  800431:	c3                   	ret    

00800432 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	57                   	push   %edi
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	83 ec 4c             	sub    $0x4c,%esp
  80043b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80043e:	8b 75 10             	mov    0x10(%ebp),%esi
  800441:	eb 12                	jmp    800455 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800443:	85 c0                	test   %eax,%eax
  800445:	0f 84 6b 03 00 00    	je     8007b6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80044b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044f:	89 04 24             	mov    %eax,(%esp)
  800452:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800455:	0f b6 06             	movzbl (%esi),%eax
  800458:	46                   	inc    %esi
  800459:	83 f8 25             	cmp    $0x25,%eax
  80045c:	75 e5                	jne    800443 <vprintfmt+0x11>
  80045e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800462:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800469:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80046e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800475:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047a:	eb 26                	jmp    8004a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800483:	eb 1d                	jmp    8004a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800488:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80048c:	eb 14                	jmp    8004a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800491:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800498:	eb 08                	jmp    8004a2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80049a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80049d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	0f b6 06             	movzbl (%esi),%eax
  8004a5:	8d 56 01             	lea    0x1(%esi),%edx
  8004a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ab:	8a 16                	mov    (%esi),%dl
  8004ad:	83 ea 23             	sub    $0x23,%edx
  8004b0:	80 fa 55             	cmp    $0x55,%dl
  8004b3:	0f 87 e1 02 00 00    	ja     80079a <vprintfmt+0x368>
  8004b9:	0f b6 d2             	movzbl %dl,%edx
  8004bc:	ff 24 95 a0 23 80 00 	jmp    *0x8023a0(,%edx,4)
  8004c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004cb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ce:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004d2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d8:	83 fa 09             	cmp    $0x9,%edx
  8004db:	77 2a                	ja     800507 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004dd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004de:	eb eb                	jmp    8004cb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ee:	eb 17                	jmp    800507 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f4:	78 98                	js     80048e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f9:	eb a7                	jmp    8004a2 <vprintfmt+0x70>
  8004fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004fe:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800505:	eb 9b                	jmp    8004a2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800507:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050b:	79 95                	jns    8004a2 <vprintfmt+0x70>
  80050d:	eb 8b                	jmp    80049a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800513:	eb 8d                	jmp    8004a2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 04             	lea    0x4(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800522:	8b 00                	mov    (%eax),%eax
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052d:	e9 23 ff ff ff       	jmp    800455 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 50 04             	lea    0x4(%eax),%edx
  800538:	89 55 14             	mov    %edx,0x14(%ebp)
  80053b:	8b 00                	mov    (%eax),%eax
  80053d:	85 c0                	test   %eax,%eax
  80053f:	79 02                	jns    800543 <vprintfmt+0x111>
  800541:	f7 d8                	neg    %eax
  800543:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800545:	83 f8 0f             	cmp    $0xf,%eax
  800548:	7f 0b                	jg     800555 <vprintfmt+0x123>
  80054a:	8b 04 85 00 25 80 00 	mov    0x802500(,%eax,4),%eax
  800551:	85 c0                	test   %eax,%eax
  800553:	75 23                	jne    800578 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800555:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800559:	c7 44 24 08 7f 22 80 	movl   $0x80227f,0x8(%esp)
  800560:	00 
  800561:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800565:	8b 45 08             	mov    0x8(%ebp),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	e8 9a fe ff ff       	call   80040a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800573:	e9 dd fe ff ff       	jmp    800455 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800578:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057c:	c7 44 24 08 35 26 80 	movl   $0x802635,0x8(%esp)
  800583:	00 
  800584:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800588:	8b 55 08             	mov    0x8(%ebp),%edx
  80058b:	89 14 24             	mov    %edx,(%esp)
  80058e:	e8 77 fe ff ff       	call   80040a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800593:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800596:	e9 ba fe ff ff       	jmp    800455 <vprintfmt+0x23>
  80059b:	89 f9                	mov    %edi,%ecx
  80059d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 30                	mov    (%eax),%esi
  8005ae:	85 f6                	test   %esi,%esi
  8005b0:	75 05                	jne    8005b7 <vprintfmt+0x185>
				p = "(null)";
  8005b2:	be 78 22 80 00       	mov    $0x802278,%esi
			if (width > 0 && padc != '-')
  8005b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005bb:	0f 8e 84 00 00 00    	jle    800645 <vprintfmt+0x213>
  8005c1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005c5:	74 7e                	je     800645 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005cb:	89 34 24             	mov    %esi,(%esp)
  8005ce:	e8 8b 02 00 00       	call   80085e <strnlen>
  8005d3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005d6:	29 c2                	sub    %eax,%edx
  8005d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005db:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005df:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005e2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	89 d3                	mov    %edx,%ebx
  8005e9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005eb:	eb 0b                	jmp    8005f8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f1:	89 3c 24             	mov    %edi,(%esp)
  8005f4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f7:	4b                   	dec    %ebx
  8005f8:	85 db                	test   %ebx,%ebx
  8005fa:	7f f1                	jg     8005ed <vprintfmt+0x1bb>
  8005fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005ff:	89 f3                	mov    %esi,%ebx
  800601:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800604:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800607:	85 c0                	test   %eax,%eax
  800609:	79 05                	jns    800610 <vprintfmt+0x1de>
  80060b:	b8 00 00 00 00       	mov    $0x0,%eax
  800610:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800613:	29 c2                	sub    %eax,%edx
  800615:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800618:	eb 2b                	jmp    800645 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061e:	74 18                	je     800638 <vprintfmt+0x206>
  800620:	8d 50 e0             	lea    -0x20(%eax),%edx
  800623:	83 fa 5e             	cmp    $0x5e,%edx
  800626:	76 10                	jbe    800638 <vprintfmt+0x206>
					putch('?', putdat);
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	eb 0a                	jmp    800642 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063c:	89 04 24             	mov    %eax,(%esp)
  80063f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800642:	ff 4d e4             	decl   -0x1c(%ebp)
  800645:	0f be 06             	movsbl (%esi),%eax
  800648:	46                   	inc    %esi
  800649:	85 c0                	test   %eax,%eax
  80064b:	74 21                	je     80066e <vprintfmt+0x23c>
  80064d:	85 ff                	test   %edi,%edi
  80064f:	78 c9                	js     80061a <vprintfmt+0x1e8>
  800651:	4f                   	dec    %edi
  800652:	79 c6                	jns    80061a <vprintfmt+0x1e8>
  800654:	8b 7d 08             	mov    0x8(%ebp),%edi
  800657:	89 de                	mov    %ebx,%esi
  800659:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80065c:	eb 18                	jmp    800676 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800662:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800669:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066b:	4b                   	dec    %ebx
  80066c:	eb 08                	jmp    800676 <vprintfmt+0x244>
  80066e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800671:	89 de                	mov    %ebx,%esi
  800673:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800676:	85 db                	test   %ebx,%ebx
  800678:	7f e4                	jg     80065e <vprintfmt+0x22c>
  80067a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80067d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800682:	e9 ce fd ff ff       	jmp    800455 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800687:	83 f9 01             	cmp    $0x1,%ecx
  80068a:	7e 10                	jle    80069c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 08             	lea    0x8(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 30                	mov    (%eax),%esi
  800697:	8b 78 04             	mov    0x4(%eax),%edi
  80069a:	eb 26                	jmp    8006c2 <vprintfmt+0x290>
	else if (lflag)
  80069c:	85 c9                	test   %ecx,%ecx
  80069e:	74 12                	je     8006b2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 30                	mov    (%eax),%esi
  8006ab:	89 f7                	mov    %esi,%edi
  8006ad:	c1 ff 1f             	sar    $0x1f,%edi
  8006b0:	eb 10                	jmp    8006c2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 30                	mov    (%eax),%esi
  8006bd:	89 f7                	mov    %esi,%edi
  8006bf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c2:	85 ff                	test   %edi,%edi
  8006c4:	78 0a                	js     8006d0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cb:	e9 8c 00 00 00       	jmp    80075c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006de:	f7 de                	neg    %esi
  8006e0:	83 d7 00             	adc    $0x0,%edi
  8006e3:	f7 df                	neg    %edi
			}
			base = 10;
  8006e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ea:	eb 70                	jmp    80075c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ec:	89 ca                	mov    %ecx,%edx
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f1:	e8 c0 fc ff ff       	call   8003b6 <getuint>
  8006f6:	89 c6                	mov    %eax,%esi
  8006f8:	89 d7                	mov    %edx,%edi
			base = 10;
  8006fa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006ff:	eb 5b                	jmp    80075c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800701:	89 ca                	mov    %ecx,%edx
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 ab fc ff ff       	call   8003b6 <getuint>
  80070b:	89 c6                	mov    %eax,%esi
  80070d:	89 d7                	mov    %edx,%edi
			base = 8;
  80070f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800714:	eb 46                	jmp    80075c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800716:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800721:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8d 50 04             	lea    0x4(%eax),%edx
  800738:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80073b:	8b 30                	mov    (%eax),%esi
  80073d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800742:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800747:	eb 13                	jmp    80075c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800749:	89 ca                	mov    %ecx,%edx
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
  80074e:	e8 63 fc ff ff       	call   8003b6 <getuint>
  800753:	89 c6                	mov    %eax,%esi
  800755:	89 d7                	mov    %edx,%edi
			base = 16;
  800757:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800760:	89 54 24 10          	mov    %edx,0x10(%esp)
  800764:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800767:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80076b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076f:	89 34 24             	mov    %esi,(%esp)
  800772:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800776:	89 da                	mov    %ebx,%edx
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	e8 6c fb ff ff       	call   8002ec <printnum>
			break;
  800780:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800783:	e9 cd fc ff ff       	jmp    800455 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800788:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800792:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800795:	e9 bb fc ff ff       	jmp    800455 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80079a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80079e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a8:	eb 01                	jmp    8007ab <vprintfmt+0x379>
  8007aa:	4e                   	dec    %esi
  8007ab:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007af:	75 f9                	jne    8007aa <vprintfmt+0x378>
  8007b1:	e9 9f fc ff ff       	jmp    800455 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007b6:	83 c4 4c             	add    $0x4c,%esp
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5f                   	pop    %edi
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 28             	sub    $0x28,%esp
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	74 30                	je     80080f <vsnprintf+0x51>
  8007df:	85 d2                	test   %edx,%edx
  8007e1:	7e 33                	jle    800816 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f8:	c7 04 24 f0 03 80 00 	movl   $0x8003f0,(%esp)
  8007ff:	e8 2e fc ff ff       	call   800432 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800804:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800807:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080d:	eb 0c                	jmp    80081b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800814:	eb 05                	jmp    80081b <vsnprintf+0x5d>
  800816:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800826:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082a:	8b 45 10             	mov    0x10(%ebp),%eax
  80082d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800831:	8b 45 0c             	mov    0xc(%ebp),%eax
  800834:	89 44 24 04          	mov    %eax,0x4(%esp)
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	89 04 24             	mov    %eax,(%esp)
  80083e:	e8 7b ff ff ff       	call   8007be <vsnprintf>
	va_end(ap);

	return rc;
}
  800843:	c9                   	leave  
  800844:	c3                   	ret    
  800845:	00 00                	add    %al,(%eax)
	...

00800848 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
  800853:	eb 01                	jmp    800856 <strlen+0xe>
		n++;
  800855:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80085a:	75 f9                	jne    800855 <strlen+0xd>
		n++;
	return n;
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800864:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
  80086c:	eb 01                	jmp    80086f <strnlen+0x11>
		n++;
  80086e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086f:	39 d0                	cmp    %edx,%eax
  800871:	74 06                	je     800879 <strnlen+0x1b>
  800873:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800877:	75 f5                	jne    80086e <strnlen+0x10>
		n++;
	return n;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800885:	ba 00 00 00 00       	mov    $0x0,%edx
  80088a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80088d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800890:	42                   	inc    %edx
  800891:	84 c9                	test   %cl,%cl
  800893:	75 f5                	jne    80088a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a2:	89 1c 24             	mov    %ebx,(%esp)
  8008a5:	e8 9e ff ff ff       	call   800848 <strlen>
	strcpy(dst + len, src);
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b1:	01 d8                	add    %ebx,%eax
  8008b3:	89 04 24             	mov    %eax,(%esp)
  8008b6:	e8 c0 ff ff ff       	call   80087b <strcpy>
	return dst;
}
  8008bb:	89 d8                	mov    %ebx,%eax
  8008bd:	83 c4 08             	add    $0x8,%esp
  8008c0:	5b                   	pop    %ebx
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d6:	eb 0c                	jmp    8008e4 <strncpy+0x21>
		*dst++ = *src;
  8008d8:	8a 1a                	mov    (%edx),%bl
  8008da:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008dd:	80 3a 01             	cmpb   $0x1,(%edx)
  8008e0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e3:	41                   	inc    %ecx
  8008e4:	39 f1                	cmp    %esi,%ecx
  8008e6:	75 f0                	jne    8008d8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
  8008f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008fa:	85 d2                	test   %edx,%edx
  8008fc:	75 0a                	jne    800908 <strlcpy+0x1c>
  8008fe:	89 f0                	mov    %esi,%eax
  800900:	eb 1a                	jmp    80091c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800902:	88 18                	mov    %bl,(%eax)
  800904:	40                   	inc    %eax
  800905:	41                   	inc    %ecx
  800906:	eb 02                	jmp    80090a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800908:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80090a:	4a                   	dec    %edx
  80090b:	74 0a                	je     800917 <strlcpy+0x2b>
  80090d:	8a 19                	mov    (%ecx),%bl
  80090f:	84 db                	test   %bl,%bl
  800911:	75 ef                	jne    800902 <strlcpy+0x16>
  800913:	89 c2                	mov    %eax,%edx
  800915:	eb 02                	jmp    800919 <strlcpy+0x2d>
  800917:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800919:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80091c:	29 f0                	sub    %esi,%eax
}
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092b:	eb 02                	jmp    80092f <strcmp+0xd>
		p++, q++;
  80092d:	41                   	inc    %ecx
  80092e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092f:	8a 01                	mov    (%ecx),%al
  800931:	84 c0                	test   %al,%al
  800933:	74 04                	je     800939 <strcmp+0x17>
  800935:	3a 02                	cmp    (%edx),%al
  800937:	74 f4                	je     80092d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800939:	0f b6 c0             	movzbl %al,%eax
  80093c:	0f b6 12             	movzbl (%edx),%edx
  80093f:	29 d0                	sub    %edx,%eax
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800950:	eb 03                	jmp    800955 <strncmp+0x12>
		n--, p++, q++;
  800952:	4a                   	dec    %edx
  800953:	40                   	inc    %eax
  800954:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800955:	85 d2                	test   %edx,%edx
  800957:	74 14                	je     80096d <strncmp+0x2a>
  800959:	8a 18                	mov    (%eax),%bl
  80095b:	84 db                	test   %bl,%bl
  80095d:	74 04                	je     800963 <strncmp+0x20>
  80095f:	3a 19                	cmp    (%ecx),%bl
  800961:	74 ef                	je     800952 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800963:	0f b6 00             	movzbl (%eax),%eax
  800966:	0f b6 11             	movzbl (%ecx),%edx
  800969:	29 d0                	sub    %edx,%eax
  80096b:	eb 05                	jmp    800972 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800972:	5b                   	pop    %ebx
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097e:	eb 05                	jmp    800985 <strchr+0x10>
		if (*s == c)
  800980:	38 ca                	cmp    %cl,%dl
  800982:	74 0c                	je     800990 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800984:	40                   	inc    %eax
  800985:	8a 10                	mov    (%eax),%dl
  800987:	84 d2                	test   %dl,%dl
  800989:	75 f5                	jne    800980 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80099b:	eb 05                	jmp    8009a2 <strfind+0x10>
		if (*s == c)
  80099d:	38 ca                	cmp    %cl,%dl
  80099f:	74 07                	je     8009a8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a1:	40                   	inc    %eax
  8009a2:	8a 10                	mov    (%eax),%dl
  8009a4:	84 d2                	test   %dl,%dl
  8009a6:	75 f5                	jne    80099d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	57                   	push   %edi
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b9:	85 c9                	test   %ecx,%ecx
  8009bb:	74 30                	je     8009ed <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c3:	75 25                	jne    8009ea <memset+0x40>
  8009c5:	f6 c1 03             	test   $0x3,%cl
  8009c8:	75 20                	jne    8009ea <memset+0x40>
		c &= 0xFF;
  8009ca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cd:	89 d3                	mov    %edx,%ebx
  8009cf:	c1 e3 08             	shl    $0x8,%ebx
  8009d2:	89 d6                	mov    %edx,%esi
  8009d4:	c1 e6 18             	shl    $0x18,%esi
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	c1 e0 10             	shl    $0x10,%eax
  8009dc:	09 f0                	or     %esi,%eax
  8009de:	09 d0                	or     %edx,%eax
  8009e0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e5:	fc                   	cld    
  8009e6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e8:	eb 03                	jmp    8009ed <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ea:	fc                   	cld    
  8009eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ed:	89 f8                	mov    %edi,%eax
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a02:	39 c6                	cmp    %eax,%esi
  800a04:	73 34                	jae    800a3a <memmove+0x46>
  800a06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a09:	39 d0                	cmp    %edx,%eax
  800a0b:	73 2d                	jae    800a3a <memmove+0x46>
		s += n;
		d += n;
  800a0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a10:	f6 c2 03             	test   $0x3,%dl
  800a13:	75 1b                	jne    800a30 <memmove+0x3c>
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 13                	jne    800a30 <memmove+0x3c>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 0e                	jne    800a30 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a22:	83 ef 04             	sub    $0x4,%edi
  800a25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a28:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2b:	fd                   	std    
  800a2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2e:	eb 07                	jmp    800a37 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a30:	4f                   	dec    %edi
  800a31:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a34:	fd                   	std    
  800a35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a37:	fc                   	cld    
  800a38:	eb 20                	jmp    800a5a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a40:	75 13                	jne    800a55 <memmove+0x61>
  800a42:	a8 03                	test   $0x3,%al
  800a44:	75 0f                	jne    800a55 <memmove+0x61>
  800a46:	f6 c1 03             	test   $0x3,%cl
  800a49:	75 0a                	jne    800a55 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4e:	89 c7                	mov    %eax,%edi
  800a50:	fc                   	cld    
  800a51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a53:	eb 05                	jmp    800a5a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	fc                   	cld    
  800a58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a64:	8b 45 10             	mov    0x10(%ebp),%eax
  800a67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	e8 77 ff ff ff       	call   8009f4 <memmove>
}
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a93:	eb 16                	jmp    800aab <memcmp+0x2c>
		if (*s1 != *s2)
  800a95:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a98:	42                   	inc    %edx
  800a99:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a9d:	38 c8                	cmp    %cl,%al
  800a9f:	74 0a                	je     800aab <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800aa1:	0f b6 c0             	movzbl %al,%eax
  800aa4:	0f b6 c9             	movzbl %cl,%ecx
  800aa7:	29 c8                	sub    %ecx,%eax
  800aa9:	eb 09                	jmp    800ab4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aab:	39 da                	cmp    %ebx,%edx
  800aad:	75 e6                	jne    800a95 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ac2:	89 c2                	mov    %eax,%edx
  800ac4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac7:	eb 05                	jmp    800ace <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac9:	38 08                	cmp    %cl,(%eax)
  800acb:	74 05                	je     800ad2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800acd:	40                   	inc    %eax
  800ace:	39 d0                	cmp    %edx,%eax
  800ad0:	72 f7                	jb     800ac9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
  800ada:	8b 55 08             	mov    0x8(%ebp),%edx
  800add:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae0:	eb 01                	jmp    800ae3 <strtol+0xf>
		s++;
  800ae2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae3:	8a 02                	mov    (%edx),%al
  800ae5:	3c 20                	cmp    $0x20,%al
  800ae7:	74 f9                	je     800ae2 <strtol+0xe>
  800ae9:	3c 09                	cmp    $0x9,%al
  800aeb:	74 f5                	je     800ae2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aed:	3c 2b                	cmp    $0x2b,%al
  800aef:	75 08                	jne    800af9 <strtol+0x25>
		s++;
  800af1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
  800af7:	eb 13                	jmp    800b0c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af9:	3c 2d                	cmp    $0x2d,%al
  800afb:	75 0a                	jne    800b07 <strtol+0x33>
		s++, neg = 1;
  800afd:	8d 52 01             	lea    0x1(%edx),%edx
  800b00:	bf 01 00 00 00       	mov    $0x1,%edi
  800b05:	eb 05                	jmp    800b0c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0c:	85 db                	test   %ebx,%ebx
  800b0e:	74 05                	je     800b15 <strtol+0x41>
  800b10:	83 fb 10             	cmp    $0x10,%ebx
  800b13:	75 28                	jne    800b3d <strtol+0x69>
  800b15:	8a 02                	mov    (%edx),%al
  800b17:	3c 30                	cmp    $0x30,%al
  800b19:	75 10                	jne    800b2b <strtol+0x57>
  800b1b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b1f:	75 0a                	jne    800b2b <strtol+0x57>
		s += 2, base = 16;
  800b21:	83 c2 02             	add    $0x2,%edx
  800b24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b29:	eb 12                	jmp    800b3d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b2b:	85 db                	test   %ebx,%ebx
  800b2d:	75 0e                	jne    800b3d <strtol+0x69>
  800b2f:	3c 30                	cmp    $0x30,%al
  800b31:	75 05                	jne    800b38 <strtol+0x64>
		s++, base = 8;
  800b33:	42                   	inc    %edx
  800b34:	b3 08                	mov    $0x8,%bl
  800b36:	eb 05                	jmp    800b3d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b38:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b42:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b44:	8a 0a                	mov    (%edx),%cl
  800b46:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b49:	80 fb 09             	cmp    $0x9,%bl
  800b4c:	77 08                	ja     800b56 <strtol+0x82>
			dig = *s - '0';
  800b4e:	0f be c9             	movsbl %cl,%ecx
  800b51:	83 e9 30             	sub    $0x30,%ecx
  800b54:	eb 1e                	jmp    800b74 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b56:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 08                	ja     800b66 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b5e:	0f be c9             	movsbl %cl,%ecx
  800b61:	83 e9 57             	sub    $0x57,%ecx
  800b64:	eb 0e                	jmp    800b74 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b66:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b69:	80 fb 19             	cmp    $0x19,%bl
  800b6c:	77 12                	ja     800b80 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b6e:	0f be c9             	movsbl %cl,%ecx
  800b71:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b74:	39 f1                	cmp    %esi,%ecx
  800b76:	7d 0c                	jge    800b84 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b78:	42                   	inc    %edx
  800b79:	0f af c6             	imul   %esi,%eax
  800b7c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b7e:	eb c4                	jmp    800b44 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b80:	89 c1                	mov    %eax,%ecx
  800b82:	eb 02                	jmp    800b86 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b84:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8a:	74 05                	je     800b91 <strtol+0xbd>
		*endptr = (char *) s;
  800b8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b8f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b91:	85 ff                	test   %edi,%edi
  800b93:	74 04                	je     800b99 <strtol+0xc5>
  800b95:	89 c8                	mov    %ecx,%eax
  800b97:	f7 d8                	neg    %eax
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    
	...

00800ba0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	89 c3                	mov    %eax,%ebx
  800bb3:	89 c7                	mov    %eax,%edi
  800bb5:	89 c6                	mov    %eax,%esi
  800bb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800beb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	89 cb                	mov    %ecx,%ebx
  800bf5:	89 cf                	mov    %ecx,%edi
  800bf7:	89 ce                	mov    %ecx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 28                	jle    800c27 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c03:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800c12:	00 
  800c13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1a:	00 
  800c1b:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800c22:	e8 b1 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c27:	83 c4 2c             	add    $0x2c,%esp
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c35:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3f:	89 d1                	mov    %edx,%ecx
  800c41:	89 d3                	mov    %edx,%ebx
  800c43:	89 d7                	mov    %edx,%edi
  800c45:	89 d6                	mov    %edx,%esi
  800c47:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_yield>:

void
sys_yield(void)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	ba 00 00 00 00       	mov    $0x0,%edx
  800c59:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c5e:	89 d1                	mov    %edx,%ecx
  800c60:	89 d3                	mov    %edx,%ebx
  800c62:	89 d7                	mov    %edx,%edi
  800c64:	89 d6                	mov    %edx,%esi
  800c66:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	be 00 00 00 00       	mov    $0x0,%esi
  800c7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 f7                	mov    %esi,%edi
  800c8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7e 28                	jle    800cb9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c95:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c9c:	00 
  800c9d:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800ca4:	00 
  800ca5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cac:	00 
  800cad:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800cb4:	e8 1f f5 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cb9:	83 c4 2c             	add    $0x2c,%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccf:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 28                	jle    800d0c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cef:	00 
  800cf0:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800cf7:	00 
  800cf8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cff:	00 
  800d00:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800d07:	e8 cc f4 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d0c:	83 c4 2c             	add    $0x2c,%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d22:	b8 06 00 00 00       	mov    $0x6,%eax
  800d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 df                	mov    %ebx,%edi
  800d2f:	89 de                	mov    %ebx,%esi
  800d31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	7e 28                	jle    800d5f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d42:	00 
  800d43:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d52:	00 
  800d53:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800d5a:	e8 79 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d5f:	83 c4 2c             	add    $0x2c,%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	89 df                	mov    %ebx,%edi
  800d82:	89 de                	mov    %ebx,%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 28                	jle    800db2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d95:	00 
  800d96:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800d9d:	00 
  800d9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da5:	00 
  800da6:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800dad:	e8 26 f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db2:	83 c4 2c             	add    $0x2c,%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 df                	mov    %ebx,%edi
  800dd5:	89 de                	mov    %ebx,%esi
  800dd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800e00:	e8 d3 f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7e 28                	jle    800e58 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e34:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800e43:	00 
  800e44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4b:	00 
  800e4c:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800e53:	e8 80 f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e58:	83 c4 2c             	add    $0x2c,%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	be 00 00 00 00       	mov    $0x0,%esi
  800e6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	57                   	push   %edi
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e96:	8b 55 08             	mov    0x8(%ebp),%edx
  800e99:	89 cb                	mov    %ecx,%ebx
  800e9b:	89 cf                	mov    %ecx,%edi
  800e9d:	89 ce                	mov    %ecx,%esi
  800e9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	7e 28                	jle    800ecd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 08 5f 25 80 	movl   $0x80255f,0x8(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec0:	00 
  800ec1:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800ec8:	e8 0b f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ecd:	83 c4 2c             	add    $0x2c,%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    
  800ed5:	00 00                	add    %al,(%eax)
	...

00800ed8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	05 00 00 00 30       	add    $0x30000000,%eax
  800ee3:	c1 e8 0c             	shr    $0xc,%eax
}
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef1:	89 04 24             	mov    %eax,(%esp)
  800ef4:	e8 df ff ff ff       	call   800ed8 <fd2num>
  800ef9:	05 20 00 0d 00       	add    $0xd0020,%eax
  800efe:	c1 e0 0c             	shl    $0xc,%eax
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	53                   	push   %ebx
  800f07:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f0a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f0f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f11:	89 c2                	mov    %eax,%edx
  800f13:	c1 ea 16             	shr    $0x16,%edx
  800f16:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1d:	f6 c2 01             	test   $0x1,%dl
  800f20:	74 11                	je     800f33 <fd_alloc+0x30>
  800f22:	89 c2                	mov    %eax,%edx
  800f24:	c1 ea 0c             	shr    $0xc,%edx
  800f27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2e:	f6 c2 01             	test   $0x1,%dl
  800f31:	75 09                	jne    800f3c <fd_alloc+0x39>
			*fd_store = fd;
  800f33:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3a:	eb 17                	jmp    800f53 <fd_alloc+0x50>
  800f3c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f41:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f46:	75 c7                	jne    800f0f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f48:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f4e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f53:	5b                   	pop    %ebx
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f5c:	83 f8 1f             	cmp    $0x1f,%eax
  800f5f:	77 36                	ja     800f97 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f61:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f66:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f69:	89 c2                	mov    %eax,%edx
  800f6b:	c1 ea 16             	shr    $0x16,%edx
  800f6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f75:	f6 c2 01             	test   $0x1,%dl
  800f78:	74 24                	je     800f9e <fd_lookup+0x48>
  800f7a:	89 c2                	mov    %eax,%edx
  800f7c:	c1 ea 0c             	shr    $0xc,%edx
  800f7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f86:	f6 c2 01             	test   $0x1,%dl
  800f89:	74 1a                	je     800fa5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8e:	89 02                	mov    %eax,(%edx)
	return 0;
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
  800f95:	eb 13                	jmp    800faa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f9c:	eb 0c                	jmp    800faa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fa3:	eb 05                	jmp    800faa <fd_lookup+0x54>
  800fa5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 14             	sub    $0x14,%esp
  800fb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbe:	eb 0e                	jmp    800fce <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fc0:	39 08                	cmp    %ecx,(%eax)
  800fc2:	75 09                	jne    800fcd <dev_lookup+0x21>
			*dev = devtab[i];
  800fc4:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	eb 35                	jmp    801002 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fcd:	42                   	inc    %edx
  800fce:	8b 04 95 0c 26 80 00 	mov    0x80260c(,%edx,4),%eax
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	75 e7                	jne    800fc0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd9:	a1 20 60 80 00       	mov    0x806020,%eax
  800fde:	8b 00                	mov    (%eax),%eax
  800fe0:	8b 40 48             	mov    0x48(%eax),%eax
  800fe3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800feb:	c7 04 24 8c 25 80 00 	movl   $0x80258c,(%esp)
  800ff2:	e8 d9 f2 ff ff       	call   8002d0 <cprintf>
	*dev = 0;
  800ff7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ffd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801002:	83 c4 14             	add    $0x14,%esp
  801005:	5b                   	pop    %ebx
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	83 ec 30             	sub    $0x30,%esp
  801010:	8b 75 08             	mov    0x8(%ebp),%esi
  801013:	8a 45 0c             	mov    0xc(%ebp),%al
  801016:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801019:	89 34 24             	mov    %esi,(%esp)
  80101c:	e8 b7 fe ff ff       	call   800ed8 <fd2num>
  801021:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801024:	89 54 24 04          	mov    %edx,0x4(%esp)
  801028:	89 04 24             	mov    %eax,(%esp)
  80102b:	e8 26 ff ff ff       	call   800f56 <fd_lookup>
  801030:	89 c3                	mov    %eax,%ebx
  801032:	85 c0                	test   %eax,%eax
  801034:	78 05                	js     80103b <fd_close+0x33>
	    || fd != fd2)
  801036:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801039:	74 0d                	je     801048 <fd_close+0x40>
		return (must_exist ? r : 0);
  80103b:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80103f:	75 46                	jne    801087 <fd_close+0x7f>
  801041:	bb 00 00 00 00       	mov    $0x0,%ebx
  801046:	eb 3f                	jmp    801087 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801048:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80104b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104f:	8b 06                	mov    (%esi),%eax
  801051:	89 04 24             	mov    %eax,(%esp)
  801054:	e8 53 ff ff ff       	call   800fac <dev_lookup>
  801059:	89 c3                	mov    %eax,%ebx
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 18                	js     801077 <fd_close+0x6f>
		if (dev->dev_close)
  80105f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801062:	8b 40 10             	mov    0x10(%eax),%eax
  801065:	85 c0                	test   %eax,%eax
  801067:	74 09                	je     801072 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801069:	89 34 24             	mov    %esi,(%esp)
  80106c:	ff d0                	call   *%eax
  80106e:	89 c3                	mov    %eax,%ebx
  801070:	eb 05                	jmp    801077 <fd_close+0x6f>
		else
			r = 0;
  801072:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801077:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801082:	e8 8d fc ff ff       	call   800d14 <sys_page_unmap>
	return r;
}
  801087:	89 d8                	mov    %ebx,%eax
  801089:	83 c4 30             	add    $0x30,%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801096:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109d:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a0:	89 04 24             	mov    %eax,(%esp)
  8010a3:	e8 ae fe ff ff       	call   800f56 <fd_lookup>
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	78 13                	js     8010bf <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8010ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b3:	00 
  8010b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b7:	89 04 24             	mov    %eax,(%esp)
  8010ba:	e8 49 ff ff ff       	call   801008 <fd_close>
}
  8010bf:	c9                   	leave  
  8010c0:	c3                   	ret    

008010c1 <close_all>:

void
close_all(void)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010cd:	89 1c 24             	mov    %ebx,(%esp)
  8010d0:	e8 bb ff ff ff       	call   801090 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010d5:	43                   	inc    %ebx
  8010d6:	83 fb 20             	cmp    $0x20,%ebx
  8010d9:	75 f2                	jne    8010cd <close_all+0xc>
		close(i);
}
  8010db:	83 c4 14             	add    $0x14,%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 4c             	sub    $0x4c,%esp
  8010ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f7:	89 04 24             	mov    %eax,(%esp)
  8010fa:	e8 57 fe ff ff       	call   800f56 <fd_lookup>
  8010ff:	89 c3                	mov    %eax,%ebx
  801101:	85 c0                	test   %eax,%eax
  801103:	0f 88 e1 00 00 00    	js     8011ea <dup+0x109>
		return r;
	close(newfdnum);
  801109:	89 3c 24             	mov    %edi,(%esp)
  80110c:	e8 7f ff ff ff       	call   801090 <close>

	newfd = INDEX2FD(newfdnum);
  801111:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801117:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80111a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111d:	89 04 24             	mov    %eax,(%esp)
  801120:	e8 c3 fd ff ff       	call   800ee8 <fd2data>
  801125:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801127:	89 34 24             	mov    %esi,(%esp)
  80112a:	e8 b9 fd ff ff       	call   800ee8 <fd2data>
  80112f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801132:	89 d8                	mov    %ebx,%eax
  801134:	c1 e8 16             	shr    $0x16,%eax
  801137:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113e:	a8 01                	test   $0x1,%al
  801140:	74 46                	je     801188 <dup+0xa7>
  801142:	89 d8                	mov    %ebx,%eax
  801144:	c1 e8 0c             	shr    $0xc,%eax
  801147:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80114e:	f6 c2 01             	test   $0x1,%dl
  801151:	74 35                	je     801188 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801153:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115a:	25 07 0e 00 00       	and    $0xe07,%eax
  80115f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801163:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801171:	00 
  801172:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80117d:	e8 3f fb ff ff       	call   800cc1 <sys_page_map>
  801182:	89 c3                	mov    %eax,%ebx
  801184:	85 c0                	test   %eax,%eax
  801186:	78 3b                	js     8011c3 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	c1 ea 0c             	shr    $0xc,%edx
  801190:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801197:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80119d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011ac:	00 
  8011ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b8:	e8 04 fb ff ff       	call   800cc1 <sys_page_map>
  8011bd:	89 c3                	mov    %eax,%ebx
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	79 25                	jns    8011e8 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ce:	e8 41 fb ff ff       	call   800d14 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e1:	e8 2e fb ff ff       	call   800d14 <sys_page_unmap>
	return r;
  8011e6:	eb 02                	jmp    8011ea <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011e8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011ea:	89 d8                	mov    %ebx,%eax
  8011ec:	83 c4 4c             	add    $0x4c,%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5f                   	pop    %edi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 24             	sub    $0x24,%esp
  8011fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801201:	89 44 24 04          	mov    %eax,0x4(%esp)
  801205:	89 1c 24             	mov    %ebx,(%esp)
  801208:	e8 49 fd ff ff       	call   800f56 <fd_lookup>
  80120d:	85 c0                	test   %eax,%eax
  80120f:	78 6f                	js     801280 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801211:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801214:	89 44 24 04          	mov    %eax,0x4(%esp)
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	8b 00                	mov    (%eax),%eax
  80121d:	89 04 24             	mov    %eax,(%esp)
  801220:	e8 87 fd ff ff       	call   800fac <dev_lookup>
  801225:	85 c0                	test   %eax,%eax
  801227:	78 57                	js     801280 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801229:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122c:	8b 50 08             	mov    0x8(%eax),%edx
  80122f:	83 e2 03             	and    $0x3,%edx
  801232:	83 fa 01             	cmp    $0x1,%edx
  801235:	75 25                	jne    80125c <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801237:	a1 20 60 80 00       	mov    0x806020,%eax
  80123c:	8b 00                	mov    (%eax),%eax
  80123e:	8b 40 48             	mov    0x48(%eax),%eax
  801241:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801245:	89 44 24 04          	mov    %eax,0x4(%esp)
  801249:	c7 04 24 d0 25 80 00 	movl   $0x8025d0,(%esp)
  801250:	e8 7b f0 ff ff       	call   8002d0 <cprintf>
		return -E_INVAL;
  801255:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125a:	eb 24                	jmp    801280 <read+0x8c>
	}
	if (!dev->dev_read)
  80125c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125f:	8b 52 08             	mov    0x8(%edx),%edx
  801262:	85 d2                	test   %edx,%edx
  801264:	74 15                	je     80127b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801266:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801269:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80126d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801270:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801274:	89 04 24             	mov    %eax,(%esp)
  801277:	ff d2                	call   *%edx
  801279:	eb 05                	jmp    801280 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80127b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801280:	83 c4 24             	add    $0x24,%esp
  801283:	5b                   	pop    %ebx
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	57                   	push   %edi
  80128a:	56                   	push   %esi
  80128b:	53                   	push   %ebx
  80128c:	83 ec 1c             	sub    $0x1c,%esp
  80128f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801292:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801295:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129a:	eb 23                	jmp    8012bf <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129c:	89 f0                	mov    %esi,%eax
  80129e:	29 d8                	sub    %ebx,%eax
  8012a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a7:	01 d8                	add    %ebx,%eax
  8012a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ad:	89 3c 24             	mov    %edi,(%esp)
  8012b0:	e8 3f ff ff ff       	call   8011f4 <read>
		if (m < 0)
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 10                	js     8012c9 <readn+0x43>
			return m;
		if (m == 0)
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	74 0a                	je     8012c7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012bd:	01 c3                	add    %eax,%ebx
  8012bf:	39 f3                	cmp    %esi,%ebx
  8012c1:	72 d9                	jb     80129c <readn+0x16>
  8012c3:	89 d8                	mov    %ebx,%eax
  8012c5:	eb 02                	jmp    8012c9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012c7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012c9:	83 c4 1c             	add    $0x1c,%esp
  8012cc:	5b                   	pop    %ebx
  8012cd:	5e                   	pop    %esi
  8012ce:	5f                   	pop    %edi
  8012cf:	5d                   	pop    %ebp
  8012d0:	c3                   	ret    

008012d1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 24             	sub    $0x24,%esp
  8012d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e2:	89 1c 24             	mov    %ebx,(%esp)
  8012e5:	e8 6c fc ff ff       	call   800f56 <fd_lookup>
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 6a                	js     801358 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	8b 00                	mov    (%eax),%eax
  8012fa:	89 04 24             	mov    %eax,(%esp)
  8012fd:	e8 aa fc ff ff       	call   800fac <dev_lookup>
  801302:	85 c0                	test   %eax,%eax
  801304:	78 52                	js     801358 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130d:	75 25                	jne    801334 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80130f:	a1 20 60 80 00       	mov    0x806020,%eax
  801314:	8b 00                	mov    (%eax),%eax
  801316:	8b 40 48             	mov    0x48(%eax),%eax
  801319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801321:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  801328:	e8 a3 ef ff ff       	call   8002d0 <cprintf>
		return -E_INVAL;
  80132d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801332:	eb 24                	jmp    801358 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801334:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801337:	8b 52 0c             	mov    0xc(%edx),%edx
  80133a:	85 d2                	test   %edx,%edx
  80133c:	74 15                	je     801353 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80133e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801341:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801345:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801348:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80134c:	89 04 24             	mov    %eax,(%esp)
  80134f:	ff d2                	call   *%edx
  801351:	eb 05                	jmp    801358 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801353:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801358:	83 c4 24             	add    $0x24,%esp
  80135b:	5b                   	pop    %ebx
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <seek>:

int
seek(int fdnum, off_t offset)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801364:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801367:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136b:	8b 45 08             	mov    0x8(%ebp),%eax
  80136e:	89 04 24             	mov    %eax,(%esp)
  801371:	e8 e0 fb ff ff       	call   800f56 <fd_lookup>
  801376:	85 c0                	test   %eax,%eax
  801378:	78 0e                	js     801388 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80137a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80137d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801380:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801383:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801388:	c9                   	leave  
  801389:	c3                   	ret    

0080138a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	53                   	push   %ebx
  80138e:	83 ec 24             	sub    $0x24,%esp
  801391:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801394:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139b:	89 1c 24             	mov    %ebx,(%esp)
  80139e:	e8 b3 fb ff ff       	call   800f56 <fd_lookup>
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 63                	js     80140a <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b1:	8b 00                	mov    (%eax),%eax
  8013b3:	89 04 24             	mov    %eax,(%esp)
  8013b6:	e8 f1 fb ff ff       	call   800fac <dev_lookup>
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 4b                	js     80140a <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013c6:	75 25                	jne    8013ed <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013c8:	a1 20 60 80 00       	mov    0x806020,%eax
  8013cd:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013cf:	8b 40 48             	mov    0x48(%eax),%eax
  8013d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013da:	c7 04 24 ac 25 80 00 	movl   $0x8025ac,(%esp)
  8013e1:	e8 ea ee ff ff       	call   8002d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013eb:	eb 1d                	jmp    80140a <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8013ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f0:	8b 52 18             	mov    0x18(%edx),%edx
  8013f3:	85 d2                	test   %edx,%edx
  8013f5:	74 0e                	je     801405 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013fa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013fe:	89 04 24             	mov    %eax,(%esp)
  801401:	ff d2                	call   *%edx
  801403:	eb 05                	jmp    80140a <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801405:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80140a:	83 c4 24             	add    $0x24,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	53                   	push   %ebx
  801414:	83 ec 24             	sub    $0x24,%esp
  801417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	89 04 24             	mov    %eax,(%esp)
  801427:	e8 2a fb ff ff       	call   800f56 <fd_lookup>
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 52                	js     801482 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801433:	89 44 24 04          	mov    %eax,0x4(%esp)
  801437:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143a:	8b 00                	mov    (%eax),%eax
  80143c:	89 04 24             	mov    %eax,(%esp)
  80143f:	e8 68 fb ff ff       	call   800fac <dev_lookup>
  801444:	85 c0                	test   %eax,%eax
  801446:	78 3a                	js     801482 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801448:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80144f:	74 2c                	je     80147d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801451:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801454:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80145b:	00 00 00 
	stat->st_isdir = 0;
  80145e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801465:	00 00 00 
	stat->st_dev = dev;
  801468:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80146e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801472:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801475:	89 14 24             	mov    %edx,(%esp)
  801478:	ff 50 14             	call   *0x14(%eax)
  80147b:	eb 05                	jmp    801482 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80147d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801482:	83 c4 24             	add    $0x24,%esp
  801485:	5b                   	pop    %ebx
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	56                   	push   %esi
  80148c:	53                   	push   %ebx
  80148d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801490:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801497:	00 
  801498:	8b 45 08             	mov    0x8(%ebp),%eax
  80149b:	89 04 24             	mov    %eax,(%esp)
  80149e:	e8 88 02 00 00       	call   80172b <open>
  8014a3:	89 c3                	mov    %eax,%ebx
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 1b                	js     8014c4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8014a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b0:	89 1c 24             	mov    %ebx,(%esp)
  8014b3:	e8 58 ff ff ff       	call   801410 <fstat>
  8014b8:	89 c6                	mov    %eax,%esi
	close(fd);
  8014ba:	89 1c 24             	mov    %ebx,(%esp)
  8014bd:	e8 ce fb ff ff       	call   801090 <close>
	return r;
  8014c2:	89 f3                	mov    %esi,%ebx
}
  8014c4:	89 d8                	mov    %ebx,%eax
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5e                   	pop    %esi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    
  8014cd:	00 00                	add    %al,(%eax)
	...

008014d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 10             	sub    $0x10,%esp
  8014d8:	89 c3                	mov    %eax,%ebx
  8014da:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014dc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014e3:	75 11                	jne    8014f6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014ec:	e8 02 0a 00 00       	call   801ef3 <ipc_find_env>
  8014f1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014f6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014fd:	00 
  8014fe:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801505:	00 
  801506:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80150a:	a1 00 40 80 00       	mov    0x804000,%eax
  80150f:	89 04 24             	mov    %eax,(%esp)
  801512:	e8 76 09 00 00       	call   801e8d <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801517:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80151e:	00 
  80151f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801523:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80152a:	e8 f1 08 00 00       	call   801e20 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	5b                   	pop    %ebx
  801533:	5e                   	pop    %esi
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    

00801536 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80153c:	8b 45 08             	mov    0x8(%ebp),%eax
  80153f:	8b 40 0c             	mov    0xc(%eax),%eax
  801542:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801547:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154a:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 02 00 00 00       	mov    $0x2,%eax
  801559:	e8 72 ff ff ff       	call   8014d0 <fsipc>
}
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801566:	8b 45 08             	mov    0x8(%ebp),%eax
  801569:	8b 40 0c             	mov    0xc(%eax),%eax
  80156c:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801571:	ba 00 00 00 00       	mov    $0x0,%edx
  801576:	b8 06 00 00 00       	mov    $0x6,%eax
  80157b:	e8 50 ff ff ff       	call   8014d0 <fsipc>
}
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	53                   	push   %ebx
  801586:	83 ec 14             	sub    $0x14,%esp
  801589:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80158c:	8b 45 08             	mov    0x8(%ebp),%eax
  80158f:	8b 40 0c             	mov    0xc(%eax),%eax
  801592:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801597:	ba 00 00 00 00       	mov    $0x0,%edx
  80159c:	b8 05 00 00 00       	mov    $0x5,%eax
  8015a1:	e8 2a ff ff ff       	call   8014d0 <fsipc>
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 2b                	js     8015d5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015aa:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8015b1:	00 
  8015b2:	89 1c 24             	mov    %ebx,(%esp)
  8015b5:	e8 c1 f2 ff ff       	call   80087b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015ba:	a1 80 70 80 00       	mov    0x807080,%eax
  8015bf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015c5:	a1 84 70 80 00       	mov    0x807084,%eax
  8015ca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d5:	83 c4 14             	add    $0x14,%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	83 ec 14             	sub    $0x14,%esp
  8015e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8015eb:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  8015f0:	89 d8                	mov    %ebx,%eax
  8015f2:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8015f8:	76 05                	jbe    8015ff <devfile_write+0x24>
  8015fa:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  8015ff:	a3 04 70 80 00       	mov    %eax,0x807004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801604:	89 44 24 08          	mov    %eax,0x8(%esp)
  801608:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160f:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  801616:	e8 43 f4 ff ff       	call   800a5e <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  80161b:	ba 00 00 00 00       	mov    $0x0,%edx
  801620:	b8 04 00 00 00       	mov    $0x4,%eax
  801625:	e8 a6 fe ff ff       	call   8014d0 <fsipc>
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 53                	js     801681 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  80162e:	39 c3                	cmp    %eax,%ebx
  801630:	73 24                	jae    801656 <devfile_write+0x7b>
  801632:	c7 44 24 0c 1c 26 80 	movl   $0x80261c,0xc(%esp)
  801639:	00 
  80163a:	c7 44 24 08 23 26 80 	movl   $0x802623,0x8(%esp)
  801641:	00 
  801642:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801649:	00 
  80164a:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  801651:	e8 82 eb ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  801656:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80165b:	7e 24                	jle    801681 <devfile_write+0xa6>
  80165d:	c7 44 24 0c 43 26 80 	movl   $0x802643,0xc(%esp)
  801664:	00 
  801665:	c7 44 24 08 23 26 80 	movl   $0x802623,0x8(%esp)
  80166c:	00 
  80166d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801674:	00 
  801675:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  80167c:	e8 57 eb ff ff       	call   8001d8 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801681:	83 c4 14             	add    $0x14,%esp
  801684:	5b                   	pop    %ebx
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	56                   	push   %esi
  80168b:	53                   	push   %ebx
  80168c:	83 ec 10             	sub    $0x10,%esp
  80168f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801692:	8b 45 08             	mov    0x8(%ebp),%eax
  801695:	8b 40 0c             	mov    0xc(%eax),%eax
  801698:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80169d:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	b8 03 00 00 00       	mov    $0x3,%eax
  8016ad:	e8 1e fe ff ff       	call   8014d0 <fsipc>
  8016b2:	89 c3                	mov    %eax,%ebx
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 6a                	js     801722 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016b8:	39 c6                	cmp    %eax,%esi
  8016ba:	73 24                	jae    8016e0 <devfile_read+0x59>
  8016bc:	c7 44 24 0c 1c 26 80 	movl   $0x80261c,0xc(%esp)
  8016c3:	00 
  8016c4:	c7 44 24 08 23 26 80 	movl   $0x802623,0x8(%esp)
  8016cb:	00 
  8016cc:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  8016d3:	00 
  8016d4:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  8016db:	e8 f8 ea ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  8016e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016e5:	7e 24                	jle    80170b <devfile_read+0x84>
  8016e7:	c7 44 24 0c 43 26 80 	movl   $0x802643,0xc(%esp)
  8016ee:	00 
  8016ef:	c7 44 24 08 23 26 80 	movl   $0x802623,0x8(%esp)
  8016f6:	00 
  8016f7:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  8016fe:	00 
  8016ff:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  801706:	e8 cd ea ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80170b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80170f:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801716:	00 
  801717:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171a:	89 04 24             	mov    %eax,(%esp)
  80171d:	e8 d2 f2 ff ff       	call   8009f4 <memmove>
	return r;
}
  801722:	89 d8                	mov    %ebx,%eax
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	5b                   	pop    %ebx
  801728:	5e                   	pop    %esi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
  801730:	83 ec 20             	sub    $0x20,%esp
  801733:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801736:	89 34 24             	mov    %esi,(%esp)
  801739:	e8 0a f1 ff ff       	call   800848 <strlen>
  80173e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801743:	7f 60                	jg     8017a5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801745:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801748:	89 04 24             	mov    %eax,(%esp)
  80174b:	e8 b3 f7 ff ff       	call   800f03 <fd_alloc>
  801750:	89 c3                	mov    %eax,%ebx
  801752:	85 c0                	test   %eax,%eax
  801754:	78 54                	js     8017aa <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801756:	89 74 24 04          	mov    %esi,0x4(%esp)
  80175a:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801761:	e8 15 f1 ff ff       	call   80087b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801766:	8b 45 0c             	mov    0xc(%ebp),%eax
  801769:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80176e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801771:	b8 01 00 00 00       	mov    $0x1,%eax
  801776:	e8 55 fd ff ff       	call   8014d0 <fsipc>
  80177b:	89 c3                	mov    %eax,%ebx
  80177d:	85 c0                	test   %eax,%eax
  80177f:	79 15                	jns    801796 <open+0x6b>
		fd_close(fd, 0);
  801781:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801788:	00 
  801789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178c:	89 04 24             	mov    %eax,(%esp)
  80178f:	e8 74 f8 ff ff       	call   801008 <fd_close>
		return r;
  801794:	eb 14                	jmp    8017aa <open+0x7f>
	}

	return fd2num(fd);
  801796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801799:	89 04 24             	mov    %eax,(%esp)
  80179c:	e8 37 f7 ff ff       	call   800ed8 <fd2num>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	eb 05                	jmp    8017aa <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017a5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017aa:	89 d8                	mov    %ebx,%eax
  8017ac:	83 c4 20             	add    $0x20,%esp
  8017af:	5b                   	pop    %ebx
  8017b0:	5e                   	pop    %esi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017be:	b8 08 00 00 00       	mov    $0x8,%eax
  8017c3:	e8 08 fd ff ff       	call   8014d0 <fsipc>
}
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    
	...

008017cc <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 14             	sub    $0x14,%esp
  8017d3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8017d5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017d9:	7e 32                	jle    80180d <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017db:	8b 40 04             	mov    0x4(%eax),%eax
  8017de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e2:	8d 43 10             	lea    0x10(%ebx),%eax
  8017e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e9:	8b 03                	mov    (%ebx),%eax
  8017eb:	89 04 24             	mov    %eax,(%esp)
  8017ee:	e8 de fa ff ff       	call   8012d1 <write>
		if (result > 0)
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	7e 03                	jle    8017fa <writebuf+0x2e>
			b->result += result;
  8017f7:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017fa:	39 43 04             	cmp    %eax,0x4(%ebx)
  8017fd:	74 0e                	je     80180d <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  8017ff:	89 c2                	mov    %eax,%edx
  801801:	85 c0                	test   %eax,%eax
  801803:	7e 05                	jle    80180a <writebuf+0x3e>
  801805:	ba 00 00 00 00       	mov    $0x0,%edx
  80180a:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  80180d:	83 c4 14             	add    $0x14,%esp
  801810:	5b                   	pop    %ebx
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <putch>:

static void
putch(int ch, void *thunk)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	53                   	push   %ebx
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80181d:	8b 43 04             	mov    0x4(%ebx),%eax
  801820:	8b 55 08             	mov    0x8(%ebp),%edx
  801823:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801827:	40                   	inc    %eax
  801828:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80182b:	3d 00 01 00 00       	cmp    $0x100,%eax
  801830:	75 0e                	jne    801840 <putch+0x2d>
		writebuf(b);
  801832:	89 d8                	mov    %ebx,%eax
  801834:	e8 93 ff ff ff       	call   8017cc <writebuf>
		b->idx = 0;
  801839:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801840:	83 c4 04             	add    $0x4,%esp
  801843:	5b                   	pop    %ebx
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801858:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80185f:	00 00 00 
	b.result = 0;
  801862:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801869:	00 00 00 
	b.error = 1;
  80186c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801873:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801876:	8b 45 10             	mov    0x10(%ebp),%eax
  801879:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80187d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801880:	89 44 24 08          	mov    %eax,0x8(%esp)
  801884:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80188a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188e:	c7 04 24 13 18 80 00 	movl   $0x801813,(%esp)
  801895:	e8 98 eb ff ff       	call   800432 <vprintfmt>
	if (b.idx > 0)
  80189a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018a1:	7e 0b                	jle    8018ae <vfprintf+0x68>
		writebuf(&b);
  8018a3:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018a9:	e8 1e ff ff ff       	call   8017cc <writebuf>

	return (b.result ? b.result : b.error);
  8018ae:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	75 06                	jne    8018be <vfprintf+0x78>
  8018b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018c6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8018c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 67 ff ff ff       	call   801846 <vfprintf>
	va_end(ap);

	return cnt;
}
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    

008018e1 <printf>:

int
printf(const char *fmt, ...)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018e7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018fc:	e8 45 ff ff ff       	call   801846 <vfprintf>
	va_end(ap);

	return cnt;
}
  801901:	c9                   	leave  
  801902:	c3                   	ret    
	...

00801904 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	83 ec 10             	sub    $0x10,%esp
  80190c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80190f:	8b 45 08             	mov    0x8(%ebp),%eax
  801912:	89 04 24             	mov    %eax,(%esp)
  801915:	e8 ce f5 ff ff       	call   800ee8 <fd2data>
  80191a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80191c:	c7 44 24 04 4f 26 80 	movl   $0x80264f,0x4(%esp)
  801923:	00 
  801924:	89 34 24             	mov    %esi,(%esp)
  801927:	e8 4f ef ff ff       	call   80087b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80192c:	8b 43 04             	mov    0x4(%ebx),%eax
  80192f:	2b 03                	sub    (%ebx),%eax
  801931:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801937:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80193e:	00 00 00 
	stat->st_dev = &devpipe;
  801941:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801948:	30 80 00 
	return 0;
}
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	5b                   	pop    %ebx
  801954:	5e                   	pop    %esi
  801955:	5d                   	pop    %ebp
  801956:	c3                   	ret    

00801957 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	53                   	push   %ebx
  80195b:	83 ec 14             	sub    $0x14,%esp
  80195e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801965:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196c:	e8 a3 f3 ff ff       	call   800d14 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801971:	89 1c 24             	mov    %ebx,(%esp)
  801974:	e8 6f f5 ff ff       	call   800ee8 <fd2data>
  801979:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801984:	e8 8b f3 ff ff       	call   800d14 <sys_page_unmap>
}
  801989:	83 c4 14             	add    $0x14,%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	57                   	push   %edi
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	83 ec 2c             	sub    $0x2c,%esp
  801998:	89 c7                	mov    %eax,%edi
  80199a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80199d:	a1 20 60 80 00       	mov    0x806020,%eax
  8019a2:	8b 00                	mov    (%eax),%eax
  8019a4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019a7:	89 3c 24             	mov    %edi,(%esp)
  8019aa:	e8 89 05 00 00       	call   801f38 <pageref>
  8019af:	89 c6                	mov    %eax,%esi
  8019b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019b4:	89 04 24             	mov    %eax,(%esp)
  8019b7:	e8 7c 05 00 00       	call   801f38 <pageref>
  8019bc:	39 c6                	cmp    %eax,%esi
  8019be:	0f 94 c0             	sete   %al
  8019c1:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019c4:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8019ca:	8b 12                	mov    (%edx),%edx
  8019cc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019cf:	39 cb                	cmp    %ecx,%ebx
  8019d1:	75 08                	jne    8019db <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019d3:	83 c4 2c             	add    $0x2c,%esp
  8019d6:	5b                   	pop    %ebx
  8019d7:	5e                   	pop    %esi
  8019d8:	5f                   	pop    %edi
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019db:	83 f8 01             	cmp    $0x1,%eax
  8019de:	75 bd                	jne    80199d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019e0:	8b 42 58             	mov    0x58(%edx),%eax
  8019e3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8019ea:	00 
  8019eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019f3:	c7 04 24 56 26 80 00 	movl   $0x802656,(%esp)
  8019fa:	e8 d1 e8 ff ff       	call   8002d0 <cprintf>
  8019ff:	eb 9c                	jmp    80199d <_pipeisclosed+0xe>

00801a01 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	57                   	push   %edi
  801a05:	56                   	push   %esi
  801a06:	53                   	push   %ebx
  801a07:	83 ec 1c             	sub    $0x1c,%esp
  801a0a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a0d:	89 34 24             	mov    %esi,(%esp)
  801a10:	e8 d3 f4 ff ff       	call   800ee8 <fd2data>
  801a15:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a17:	bf 00 00 00 00       	mov    $0x0,%edi
  801a1c:	eb 3c                	jmp    801a5a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a1e:	89 da                	mov    %ebx,%edx
  801a20:	89 f0                	mov    %esi,%eax
  801a22:	e8 68 ff ff ff       	call   80198f <_pipeisclosed>
  801a27:	85 c0                	test   %eax,%eax
  801a29:	75 38                	jne    801a63 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a2b:	e8 1e f2 ff ff       	call   800c4e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a30:	8b 43 04             	mov    0x4(%ebx),%eax
  801a33:	8b 13                	mov    (%ebx),%edx
  801a35:	83 c2 20             	add    $0x20,%edx
  801a38:	39 d0                	cmp    %edx,%eax
  801a3a:	73 e2                	jae    801a1e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a3f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801a42:	89 c2                	mov    %eax,%edx
  801a44:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a4a:	79 05                	jns    801a51 <devpipe_write+0x50>
  801a4c:	4a                   	dec    %edx
  801a4d:	83 ca e0             	or     $0xffffffe0,%edx
  801a50:	42                   	inc    %edx
  801a51:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a55:	40                   	inc    %eax
  801a56:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a59:	47                   	inc    %edi
  801a5a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a5d:	75 d1                	jne    801a30 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a5f:	89 f8                	mov    %edi,%eax
  801a61:	eb 05                	jmp    801a68 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a63:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a68:	83 c4 1c             	add    $0x1c,%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5f                   	pop    %edi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	57                   	push   %edi
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	83 ec 1c             	sub    $0x1c,%esp
  801a79:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a7c:	89 3c 24             	mov    %edi,(%esp)
  801a7f:	e8 64 f4 ff ff       	call   800ee8 <fd2data>
  801a84:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a86:	be 00 00 00 00       	mov    $0x0,%esi
  801a8b:	eb 3a                	jmp    801ac7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a8d:	85 f6                	test   %esi,%esi
  801a8f:	74 04                	je     801a95 <devpipe_read+0x25>
				return i;
  801a91:	89 f0                	mov    %esi,%eax
  801a93:	eb 40                	jmp    801ad5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a95:	89 da                	mov    %ebx,%edx
  801a97:	89 f8                	mov    %edi,%eax
  801a99:	e8 f1 fe ff ff       	call   80198f <_pipeisclosed>
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	75 2e                	jne    801ad0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aa2:	e8 a7 f1 ff ff       	call   800c4e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aa7:	8b 03                	mov    (%ebx),%eax
  801aa9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aac:	74 df                	je     801a8d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aae:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ab3:	79 05                	jns    801aba <devpipe_read+0x4a>
  801ab5:	48                   	dec    %eax
  801ab6:	83 c8 e0             	or     $0xffffffe0,%eax
  801ab9:	40                   	inc    %eax
  801aba:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ac4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac6:	46                   	inc    %esi
  801ac7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aca:	75 db                	jne    801aa7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801acc:	89 f0                	mov    %esi,%eax
  801ace:	eb 05                	jmp    801ad5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ad5:	83 c4 1c             	add    $0x1c,%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5f                   	pop    %edi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	57                   	push   %edi
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 3c             	sub    $0x3c,%esp
  801ae6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ae9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801aec:	89 04 24             	mov    %eax,(%esp)
  801aef:	e8 0f f4 ff ff       	call   800f03 <fd_alloc>
  801af4:	89 c3                	mov    %eax,%ebx
  801af6:	85 c0                	test   %eax,%eax
  801af8:	0f 88 45 01 00 00    	js     801c43 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801afe:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b05:	00 
  801b06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b14:	e8 54 f1 ff ff       	call   800c6d <sys_page_alloc>
  801b19:	89 c3                	mov    %eax,%ebx
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 88 20 01 00 00    	js     801c43 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b23:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b26:	89 04 24             	mov    %eax,(%esp)
  801b29:	e8 d5 f3 ff ff       	call   800f03 <fd_alloc>
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	85 c0                	test   %eax,%eax
  801b32:	0f 88 f8 00 00 00    	js     801c30 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b38:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b3f:	00 
  801b40:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b4e:	e8 1a f1 ff ff       	call   800c6d <sys_page_alloc>
  801b53:	89 c3                	mov    %eax,%ebx
  801b55:	85 c0                	test   %eax,%eax
  801b57:	0f 88 d3 00 00 00    	js     801c30 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b60:	89 04 24             	mov    %eax,(%esp)
  801b63:	e8 80 f3 ff ff       	call   800ee8 <fd2data>
  801b68:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b6a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b71:	00 
  801b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b7d:	e8 eb f0 ff ff       	call   800c6d <sys_page_alloc>
  801b82:	89 c3                	mov    %eax,%ebx
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 91 00 00 00    	js     801c1d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b8f:	89 04 24             	mov    %eax,(%esp)
  801b92:	e8 51 f3 ff ff       	call   800ee8 <fd2data>
  801b97:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b9e:	00 
  801b9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ba3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801baa:	00 
  801bab:	89 74 24 04          	mov    %esi,0x4(%esp)
  801baf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb6:	e8 06 f1 ff ff       	call   800cc1 <sys_page_map>
  801bbb:	89 c3                	mov    %eax,%ebx
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	78 4c                	js     801c0d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bc1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bca:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bcf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bd6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bdf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801be1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801be4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801beb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bee:	89 04 24             	mov    %eax,(%esp)
  801bf1:	e8 e2 f2 ff ff       	call   800ed8 <fd2num>
  801bf6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801bf8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bfb:	89 04 24             	mov    %eax,(%esp)
  801bfe:	e8 d5 f2 ff ff       	call   800ed8 <fd2num>
  801c03:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c06:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c0b:	eb 36                	jmp    801c43 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801c0d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c18:	e8 f7 f0 ff ff       	call   800d14 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801c1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2b:	e8 e4 f0 ff ff       	call   800d14 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801c30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c3e:	e8 d1 f0 ff ff       	call   800d14 <sys_page_unmap>
    err:
	return r;
}
  801c43:	89 d8                	mov    %ebx,%eax
  801c45:	83 c4 3c             	add    $0x3c,%esp
  801c48:	5b                   	pop    %ebx
  801c49:	5e                   	pop    %esi
  801c4a:	5f                   	pop    %edi
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	89 04 24             	mov    %eax,(%esp)
  801c60:	e8 f1 f2 ff ff       	call   800f56 <fd_lookup>
  801c65:	85 c0                	test   %eax,%eax
  801c67:	78 15                	js     801c7e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6c:	89 04 24             	mov    %eax,(%esp)
  801c6f:	e8 74 f2 ff ff       	call   800ee8 <fd2data>
	return _pipeisclosed(fd, p);
  801c74:	89 c2                	mov    %eax,%edx
  801c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c79:	e8 11 fd ff ff       	call   80198f <_pipeisclosed>
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c83:	b8 00 00 00 00       	mov    $0x0,%eax
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c90:	c7 44 24 04 6e 26 80 	movl   $0x80266e,0x4(%esp)
  801c97:	00 
  801c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9b:	89 04 24             	mov    %eax,(%esp)
  801c9e:	e8 d8 eb ff ff       	call   80087b <strcpy>
	return 0;
}
  801ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	57                   	push   %edi
  801cae:	56                   	push   %esi
  801caf:	53                   	push   %ebx
  801cb0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cbb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cc1:	eb 30                	jmp    801cf3 <devcons_write+0x49>
		m = n - tot;
  801cc3:	8b 75 10             	mov    0x10(%ebp),%esi
  801cc6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801cc8:	83 fe 7f             	cmp    $0x7f,%esi
  801ccb:	76 05                	jbe    801cd2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801ccd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cd2:	89 74 24 08          	mov    %esi,0x8(%esp)
  801cd6:	03 45 0c             	add    0xc(%ebp),%eax
  801cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cdd:	89 3c 24             	mov    %edi,(%esp)
  801ce0:	e8 0f ed ff ff       	call   8009f4 <memmove>
		sys_cputs(buf, m);
  801ce5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ce9:	89 3c 24             	mov    %edi,(%esp)
  801cec:	e8 af ee ff ff       	call   800ba0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf1:	01 f3                	add    %esi,%ebx
  801cf3:	89 d8                	mov    %ebx,%eax
  801cf5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cf8:	72 c9                	jb     801cc3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cfa:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d0f:	75 07                	jne    801d18 <devcons_read+0x13>
  801d11:	eb 25                	jmp    801d38 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d13:	e8 36 ef ff ff       	call   800c4e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d18:	e8 a1 ee ff ff       	call   800bbe <sys_cgetc>
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	74 f2                	je     801d13 <devcons_read+0xe>
  801d21:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d23:	85 c0                	test   %eax,%eax
  801d25:	78 1d                	js     801d44 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d27:	83 f8 04             	cmp    $0x4,%eax
  801d2a:	74 13                	je     801d3f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2f:	88 10                	mov    %dl,(%eax)
	return 1;
  801d31:	b8 01 00 00 00       	mov    $0x1,%eax
  801d36:	eb 0c                	jmp    801d44 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3d:	eb 05                	jmp    801d44 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d3f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d52:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d59:	00 
  801d5a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d5d:	89 04 24             	mov    %eax,(%esp)
  801d60:	e8 3b ee ff ff       	call   800ba0 <sys_cputs>
}
  801d65:	c9                   	leave  
  801d66:	c3                   	ret    

00801d67 <getchar>:

int
getchar(void)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d6d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d74:	00 
  801d75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d83:	e8 6c f4 ff ff       	call   8011f4 <read>
	if (r < 0)
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 0f                	js     801d9b <getchar+0x34>
		return r;
	if (r < 1)
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	7e 06                	jle    801d96 <getchar+0x2f>
		return -E_EOF;
	return c;
  801d90:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d94:	eb 05                	jmp    801d9b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d96:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801daa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dad:	89 04 24             	mov    %eax,(%esp)
  801db0:	e8 a1 f1 ff ff       	call   800f56 <fd_lookup>
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 11                	js     801dca <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dc2:	39 10                	cmp    %edx,(%eax)
  801dc4:	0f 94 c0             	sete   %al
  801dc7:	0f b6 c0             	movzbl %al,%eax
}
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <opencons>:

int
opencons(void)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd5:	89 04 24             	mov    %eax,(%esp)
  801dd8:	e8 26 f1 ff ff       	call   800f03 <fd_alloc>
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 3c                	js     801e1d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801de8:	00 
  801de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df7:	e8 71 ee ff ff       	call   800c6d <sys_page_alloc>
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 1d                	js     801e1d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e00:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e09:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e15:	89 04 24             	mov    %eax,(%esp)
  801e18:	e8 bb f0 ff ff       	call   800ed8 <fd2num>
}
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    
	...

00801e20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	56                   	push   %esi
  801e24:	53                   	push   %ebx
  801e25:	83 ec 10             	sub    $0x10,%esp
  801e28:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801e31:	85 c0                	test   %eax,%eax
  801e33:	75 05                	jne    801e3a <ipc_recv+0x1a>
  801e35:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801e3a:	89 04 24             	mov    %eax,(%esp)
  801e3d:	e8 41 f0 ff ff       	call   800e83 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801e42:	85 c0                	test   %eax,%eax
  801e44:	79 16                	jns    801e5c <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801e46:	85 db                	test   %ebx,%ebx
  801e48:	74 06                	je     801e50 <ipc_recv+0x30>
  801e4a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801e50:	85 f6                	test   %esi,%esi
  801e52:	74 32                	je     801e86 <ipc_recv+0x66>
  801e54:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801e5a:	eb 2a                	jmp    801e86 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e5c:	85 db                	test   %ebx,%ebx
  801e5e:	74 0c                	je     801e6c <ipc_recv+0x4c>
  801e60:	a1 20 60 80 00       	mov    0x806020,%eax
  801e65:	8b 00                	mov    (%eax),%eax
  801e67:	8b 40 74             	mov    0x74(%eax),%eax
  801e6a:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e6c:	85 f6                	test   %esi,%esi
  801e6e:	74 0c                	je     801e7c <ipc_recv+0x5c>
  801e70:	a1 20 60 80 00       	mov    0x806020,%eax
  801e75:	8b 00                	mov    (%eax),%eax
  801e77:	8b 40 78             	mov    0x78(%eax),%eax
  801e7a:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801e7c:	a1 20 60 80 00       	mov    0x806020,%eax
  801e81:	8b 00                	mov    (%eax),%eax
  801e83:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	5b                   	pop    %ebx
  801e8a:	5e                   	pop    %esi
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    

00801e8d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	57                   	push   %edi
  801e91:	56                   	push   %esi
  801e92:	53                   	push   %ebx
  801e93:	83 ec 1c             	sub    $0x1c,%esp
  801e96:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e99:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e9c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801e9f:	85 db                	test   %ebx,%ebx
  801ea1:	75 05                	jne    801ea8 <ipc_send+0x1b>
  801ea3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801ea8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801eac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	89 04 24             	mov    %eax,(%esp)
  801eba:	e8 a1 ef ff ff       	call   800e60 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801ebf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec2:	75 07                	jne    801ecb <ipc_send+0x3e>
  801ec4:	e8 85 ed ff ff       	call   800c4e <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801ec9:	eb dd                	jmp    801ea8 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	79 1c                	jns    801eeb <ipc_send+0x5e>
  801ecf:	c7 44 24 08 7a 26 80 	movl   $0x80267a,0x8(%esp)
  801ed6:	00 
  801ed7:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801ede:	00 
  801edf:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  801ee6:	e8 ed e2 ff ff       	call   8001d8 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801eeb:	83 c4 1c             	add    $0x1c,%esp
  801eee:	5b                   	pop    %ebx
  801eef:	5e                   	pop    %esi
  801ef0:	5f                   	pop    %edi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    

00801ef3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	53                   	push   %ebx
  801ef7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801efa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eff:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f06:	89 c2                	mov    %eax,%edx
  801f08:	c1 e2 07             	shl    $0x7,%edx
  801f0b:	29 ca                	sub    %ecx,%edx
  801f0d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f13:	8b 52 50             	mov    0x50(%edx),%edx
  801f16:	39 da                	cmp    %ebx,%edx
  801f18:	75 0f                	jne    801f29 <ipc_find_env+0x36>
			return envs[i].env_id;
  801f1a:	c1 e0 07             	shl    $0x7,%eax
  801f1d:	29 c8                	sub    %ecx,%eax
  801f1f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f24:	8b 40 40             	mov    0x40(%eax),%eax
  801f27:	eb 0c                	jmp    801f35 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f29:	40                   	inc    %eax
  801f2a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f2f:	75 ce                	jne    801eff <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f31:	66 b8 00 00          	mov    $0x0,%ax
}
  801f35:	5b                   	pop    %ebx
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801f3e:	89 c2                	mov    %eax,%edx
  801f40:	c1 ea 16             	shr    $0x16,%edx
  801f43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f4a:	f6 c2 01             	test   $0x1,%dl
  801f4d:	74 1e                	je     801f6d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f4f:	c1 e8 0c             	shr    $0xc,%eax
  801f52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f59:	a8 01                	test   $0x1,%al
  801f5b:	74 17                	je     801f74 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f5d:	c1 e8 0c             	shr    $0xc,%eax
  801f60:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f67:	ef 
  801f68:	0f b7 c0             	movzwl %ax,%eax
  801f6b:	eb 0c                	jmp    801f79 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f72:	eb 05                	jmp    801f79 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f74:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    
	...

00801f7c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f7c:	55                   	push   %ebp
  801f7d:	57                   	push   %edi
  801f7e:	56                   	push   %esi
  801f7f:	83 ec 10             	sub    $0x10,%esp
  801f82:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f86:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f8e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801f92:	89 cd                	mov    %ecx,%ebp
  801f94:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f98:	85 c0                	test   %eax,%eax
  801f9a:	75 2c                	jne    801fc8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f9c:	39 f9                	cmp    %edi,%ecx
  801f9e:	77 68                	ja     802008 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fa0:	85 c9                	test   %ecx,%ecx
  801fa2:	75 0b                	jne    801faf <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fa4:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa9:	31 d2                	xor    %edx,%edx
  801fab:	f7 f1                	div    %ecx
  801fad:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801faf:	31 d2                	xor    %edx,%edx
  801fb1:	89 f8                	mov    %edi,%eax
  801fb3:	f7 f1                	div    %ecx
  801fb5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fb7:	89 f0                	mov    %esi,%eax
  801fb9:	f7 f1                	div    %ecx
  801fbb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fbd:	89 f0                	mov    %esi,%eax
  801fbf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fc8:	39 f8                	cmp    %edi,%eax
  801fca:	77 2c                	ja     801ff8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fcc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801fcf:	83 f6 1f             	xor    $0x1f,%esi
  801fd2:	75 4c                	jne    802020 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fd4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fd6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fdb:	72 0a                	jb     801fe7 <__udivdi3+0x6b>
  801fdd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801fe1:	0f 87 ad 00 00 00    	ja     802094 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fe7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fec:	89 f0                	mov    %esi,%eax
  801fee:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	5e                   	pop    %esi
  801ff4:	5f                   	pop    %edi
  801ff5:	5d                   	pop    %ebp
  801ff6:	c3                   	ret    
  801ff7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ffc:	89 f0                	mov    %esi,%eax
  801ffe:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	5e                   	pop    %esi
  802004:	5f                   	pop    %edi
  802005:	5d                   	pop    %ebp
  802006:	c3                   	ret    
  802007:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802008:	89 fa                	mov    %edi,%edx
  80200a:	89 f0                	mov    %esi,%eax
  80200c:	f7 f1                	div    %ecx
  80200e:	89 c6                	mov    %eax,%esi
  802010:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802012:	89 f0                	mov    %esi,%eax
  802014:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	5e                   	pop    %esi
  80201a:	5f                   	pop    %edi
  80201b:	5d                   	pop    %ebp
  80201c:	c3                   	ret    
  80201d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802020:	89 f1                	mov    %esi,%ecx
  802022:	d3 e0                	shl    %cl,%eax
  802024:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802028:	b8 20 00 00 00       	mov    $0x20,%eax
  80202d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80202f:	89 ea                	mov    %ebp,%edx
  802031:	88 c1                	mov    %al,%cl
  802033:	d3 ea                	shr    %cl,%edx
  802035:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802039:	09 ca                	or     %ecx,%edx
  80203b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80203f:	89 f1                	mov    %esi,%ecx
  802041:	d3 e5                	shl    %cl,%ebp
  802043:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802047:	89 fd                	mov    %edi,%ebp
  802049:	88 c1                	mov    %al,%cl
  80204b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80204d:	89 fa                	mov    %edi,%edx
  80204f:	89 f1                	mov    %esi,%ecx
  802051:	d3 e2                	shl    %cl,%edx
  802053:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802057:	88 c1                	mov    %al,%cl
  802059:	d3 ef                	shr    %cl,%edi
  80205b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80205d:	89 f8                	mov    %edi,%eax
  80205f:	89 ea                	mov    %ebp,%edx
  802061:	f7 74 24 08          	divl   0x8(%esp)
  802065:	89 d1                	mov    %edx,%ecx
  802067:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802069:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80206d:	39 d1                	cmp    %edx,%ecx
  80206f:	72 17                	jb     802088 <__udivdi3+0x10c>
  802071:	74 09                	je     80207c <__udivdi3+0x100>
  802073:	89 fe                	mov    %edi,%esi
  802075:	31 ff                	xor    %edi,%edi
  802077:	e9 41 ff ff ff       	jmp    801fbd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80207c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802080:	89 f1                	mov    %esi,%ecx
  802082:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802084:	39 c2                	cmp    %eax,%edx
  802086:	73 eb                	jae    802073 <__udivdi3+0xf7>
		{
		  q0--;
  802088:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80208b:	31 ff                	xor    %edi,%edi
  80208d:	e9 2b ff ff ff       	jmp    801fbd <__udivdi3+0x41>
  802092:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802094:	31 f6                	xor    %esi,%esi
  802096:	e9 22 ff ff ff       	jmp    801fbd <__udivdi3+0x41>
	...

0080209c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80209c:	55                   	push   %ebp
  80209d:	57                   	push   %edi
  80209e:	56                   	push   %esi
  80209f:	83 ec 20             	sub    $0x20,%esp
  8020a2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8020a6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020aa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8020ae:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8020b2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020b6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020ba:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8020bc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020be:	85 ed                	test   %ebp,%ebp
  8020c0:	75 16                	jne    8020d8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8020c2:	39 f1                	cmp    %esi,%ecx
  8020c4:	0f 86 a6 00 00 00    	jbe    802170 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020ca:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020cc:	89 d0                	mov    %edx,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020d0:	83 c4 20             	add    $0x20,%esp
  8020d3:	5e                   	pop    %esi
  8020d4:	5f                   	pop    %edi
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    
  8020d7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020d8:	39 f5                	cmp    %esi,%ebp
  8020da:	0f 87 ac 00 00 00    	ja     80218c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020e0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8020e3:	83 f0 1f             	xor    $0x1f,%eax
  8020e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020ea:	0f 84 a8 00 00 00    	je     802198 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020f0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020f4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020f6:	bf 20 00 00 00       	mov    $0x20,%edi
  8020fb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020ff:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802103:	89 f9                	mov    %edi,%ecx
  802105:	d3 e8                	shr    %cl,%eax
  802107:	09 e8                	or     %ebp,%eax
  802109:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80210d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802111:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802115:	d3 e0                	shl    %cl,%eax
  802117:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80211b:	89 f2                	mov    %esi,%edx
  80211d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80211f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802123:	d3 e0                	shl    %cl,%eax
  802125:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802129:	8b 44 24 14          	mov    0x14(%esp),%eax
  80212d:	89 f9                	mov    %edi,%ecx
  80212f:	d3 e8                	shr    %cl,%eax
  802131:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802133:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802135:	89 f2                	mov    %esi,%edx
  802137:	f7 74 24 18          	divl   0x18(%esp)
  80213b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80213d:	f7 64 24 0c          	mull   0xc(%esp)
  802141:	89 c5                	mov    %eax,%ebp
  802143:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802145:	39 d6                	cmp    %edx,%esi
  802147:	72 67                	jb     8021b0 <__umoddi3+0x114>
  802149:	74 75                	je     8021c0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80214b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80214f:	29 e8                	sub    %ebp,%eax
  802151:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802153:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 f2                	mov    %esi,%edx
  80215b:	89 f9                	mov    %edi,%ecx
  80215d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80215f:	09 d0                	or     %edx,%eax
  802161:	89 f2                	mov    %esi,%edx
  802163:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802167:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802169:	83 c4 20             	add    $0x20,%esp
  80216c:	5e                   	pop    %esi
  80216d:	5f                   	pop    %edi
  80216e:	5d                   	pop    %ebp
  80216f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802170:	85 c9                	test   %ecx,%ecx
  802172:	75 0b                	jne    80217f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802174:	b8 01 00 00 00       	mov    $0x1,%eax
  802179:	31 d2                	xor    %edx,%edx
  80217b:	f7 f1                	div    %ecx
  80217d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80217f:	89 f0                	mov    %esi,%eax
  802181:	31 d2                	xor    %edx,%edx
  802183:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802185:	89 f8                	mov    %edi,%eax
  802187:	e9 3e ff ff ff       	jmp    8020ca <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80218c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80218e:	83 c4 20             	add    $0x20,%esp
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802198:	39 f5                	cmp    %esi,%ebp
  80219a:	72 04                	jb     8021a0 <__umoddi3+0x104>
  80219c:	39 f9                	cmp    %edi,%ecx
  80219e:	77 06                	ja     8021a6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	29 cf                	sub    %ecx,%edi
  8021a4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021a6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021a8:	83 c4 20             	add    $0x20,%esp
  8021ab:	5e                   	pop    %esi
  8021ac:	5f                   	pop    %edi
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    
  8021af:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021b0:	89 d1                	mov    %edx,%ecx
  8021b2:	89 c5                	mov    %eax,%ebp
  8021b4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8021b8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8021bc:	eb 8d                	jmp    80214b <__umoddi3+0xaf>
  8021be:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021c0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8021c4:	72 ea                	jb     8021b0 <__umoddi3+0x114>
  8021c6:	89 f1                	mov    %esi,%ecx
  8021c8:	eb 81                	jmp    80214b <__umoddi3+0xaf>
