
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 30 0e 80 00 	movl   $0x800e30,(%esp)
  800041:	e8 1a 02 00 00       	call   800260 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 ab 0e 80 	movl   $0x800eab,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 c8 0e 80 00 	movl   $0x800ec8,(%esp)
  800070:	e8 f3 00 00 00       	call   800168 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	40                   	inc    %eax
  800076:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007b:	75 ce                	jne    80004b <umain+0x17>
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800082:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800089:	40                   	inc    %eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 f1                	jne    800082 <umain+0x4e>
  800091:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800096:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 50 0e 80 	movl   $0x800e50,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 c8 0e 80 00 	movl   $0x800ec8,(%esp)
  8000ba:	e8 a9 00 00 00       	call   800168 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000bf:	40                   	inc    %eax
  8000c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c5:	75 cf                	jne    800096 <umain+0x62>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000c7:	c7 04 24 78 0e 80 00 	movl   $0x800e78,(%esp)
  8000ce:	e8 8d 01 00 00       	call   800260 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 d7 0e 80 	movl   $0x800ed7,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 c8 0e 80 00 	movl   $0x800ec8,(%esp)
  8000f4:	e8 6f 00 00 00       	call   800168 <_panic>
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 10             	sub    $0x10,%esp
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80010a:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  800111:	00 00 00 
	thisenv = envs + ENVX(sys_getenvid());
  800114:	e8 a6 0a 00 00       	call   800bbf <sys_getenvid>
  800119:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800121:	c1 e0 05             	shl    $0x5,%eax
  800124:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800129:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012e:	85 f6                	test   %esi,%esi
  800130:	7e 07                	jle    800139 <libmain+0x3d>
		binaryname = argv[0];
  800132:	8b 03                	mov    (%ebx),%eax
  800134:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800139:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013d:	89 34 24             	mov    %esi,(%esp)
  800140:	e8 ef fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800145:	e8 0a 00 00 00       	call   800154 <exit>
}
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    
  800151:	00 00                	add    %al,(%eax)
	...

00800154 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800161:	e8 07 0a 00 00       	call   800b6d <sys_env_destroy>
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800170:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800173:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800179:	e8 41 0a 00 00       	call   800bbf <sys_getenvid>
  80017e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800181:	89 54 24 10          	mov    %edx,0x10(%esp)
  800185:	8b 55 08             	mov    0x8(%ebp),%edx
  800188:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80018c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 f8 0e 80 00 	movl   $0x800ef8,(%esp)
  80019b:	e8 c0 00 00 00       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 50 00 00 00       	call   8001ff <vcprintf>
	cprintf("\n");
  8001af:	c7 04 24 c6 0e 80 00 	movl   $0x800ec6,(%esp)
  8001b6:	e8 a5 00 00 00       	call   800260 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bb:	cc                   	int3   
  8001bc:	eb fd                	jmp    8001bb <_panic+0x53>
	...

008001c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 14             	sub    $0x14,%esp
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ca:	8b 03                	mov    (%ebx),%eax
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d3:	40                   	inc    %eax
  8001d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	75 19                	jne    8001f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e4:	00 
  8001e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 40 09 00 00       	call   800b30 <sys_cputs>
		b->idx = 0;
  8001f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f6:	ff 43 04             	incl   0x4(%ebx)
}
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800208:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020f:	00 00 00 
	b.cnt = 0;
  800212:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800219:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800223:	8b 45 08             	mov    0x8(%ebp),%eax
  800226:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800230:	89 44 24 04          	mov    %eax,0x4(%esp)
  800234:	c7 04 24 c0 01 80 00 	movl   $0x8001c0,(%esp)
  80023b:	e8 82 01 00 00       	call   8003c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800240:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	e8 d8 08 00 00       	call   800b30 <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	e8 87 ff ff ff       	call   8001ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    
	...

0080027c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 3c             	sub    $0x3c,%esp
  800285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800288:	89 d7                	mov    %edx,%edi
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800299:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029c:	85 c0                	test   %eax,%eax
  80029e:	75 08                	jne    8002a8 <printnum+0x2c>
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a6:	77 57                	ja     8002ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ac:	4b                   	dec    %ebx
  8002ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c7:	00 
  8002c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d5:	e8 06 09 00 00       	call   800be0 <__udivdi3>
  8002da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e9:	89 fa                	mov    %edi,%edx
  8002eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ee:	e8 89 ff ff ff       	call   80027c <printnum>
  8002f3:	eb 0f                	jmp    800304 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ff:	4b                   	dec    %ebx
  800300:	85 db                	test   %ebx,%ebx
  800302:	7f f1                	jg     8002f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800304:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800308:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800313:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031a:	00 
  80031b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031e:	89 04 24             	mov    %eax,(%esp)
  800321:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800324:	89 44 24 04          	mov    %eax,0x4(%esp)
  800328:	e8 d3 09 00 00       	call   800d00 <__umoddi3>
  80032d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800331:	0f be 80 1c 0f 80 00 	movsbl 0x800f1c(%eax),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033e:	83 c4 3c             	add    $0x3c,%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7e 0e                	jle    80035c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 08             	lea    0x8(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	8b 52 04             	mov    0x4(%edx),%edx
  80035a:	eb 22                	jmp    80037e <getuint+0x38>
	else if (lflag)
  80035c:	85 d2                	test   %edx,%edx
  80035e:	74 10                	je     800370 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	eb 0e                	jmp    80037e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800386:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	3b 50 04             	cmp    0x4(%eax),%edx
  80038e:	73 08                	jae    800398 <sprintputch+0x18>
		*b->buf++ = ch;
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	88 0a                	mov    %cl,(%edx)
  800395:	42                   	inc    %edx
  800396:	89 10                	mov    %edx,(%eax)
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	e8 02 00 00 00       	call   8003c2 <vprintfmt>
	va_end(ap);
}
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    

008003c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	57                   	push   %edi
  8003c6:	56                   	push   %esi
  8003c7:	53                   	push   %ebx
  8003c8:	83 ec 4c             	sub    $0x4c,%esp
  8003cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d1:	eb 12                	jmp    8003e5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	0f 84 6b 03 00 00    	je     800746 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e5:	0f b6 06             	movzbl (%esi),%eax
  8003e8:	46                   	inc    %esi
  8003e9:	83 f8 25             	cmp    $0x25,%eax
  8003ec:	75 e5                	jne    8003d3 <vprintfmt+0x11>
  8003ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800405:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040a:	eb 26                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800413:	eb 1d                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800418:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80041c:	eb 14                	jmp    800432 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800421:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800428:	eb 08                	jmp    800432 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80042d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	0f b6 06             	movzbl (%esi),%eax
  800435:	8d 56 01             	lea    0x1(%esi),%edx
  800438:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043b:	8a 16                	mov    (%esi),%dl
  80043d:	83 ea 23             	sub    $0x23,%edx
  800440:	80 fa 55             	cmp    $0x55,%dl
  800443:	0f 87 e1 02 00 00    	ja     80072a <vprintfmt+0x368>
  800449:	0f b6 d2             	movzbl %dl,%edx
  80044c:	ff 24 95 ac 0f 80 00 	jmp    *0x800fac(,%edx,4)
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800456:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80045e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800462:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800465:	8d 50 d0             	lea    -0x30(%eax),%edx
  800468:	83 fa 09             	cmp    $0x9,%edx
  80046b:	77 2a                	ja     800497 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046e:	eb eb                	jmp    80045b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047e:	eb 17                	jmp    800497 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800480:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800484:	78 98                	js     80041e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800489:	eb a7                	jmp    800432 <vprintfmt+0x70>
  80048b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800495:	eb 9b                	jmp    800432 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049b:	79 95                	jns    800432 <vprintfmt+0x70>
  80049d:	eb 8b                	jmp    80042a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a3:	eb 8d                	jmp    800432 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004bd:	e9 23 ff ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	79 02                	jns    8004d3 <vprintfmt+0x111>
  8004d1:	f7 d8                	neg    %eax
  8004d3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d5:	83 f8 06             	cmp    $0x6,%eax
  8004d8:	7f 0b                	jg     8004e5 <vprintfmt+0x123>
  8004da:	8b 04 85 04 11 80 00 	mov    0x801104(,%eax,4),%eax
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	75 23                	jne    800508 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e9:	c7 44 24 08 34 0f 80 	movl   $0x800f34,0x8(%esp)
  8004f0:	00 
  8004f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	e8 9a fe ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800503:	e9 dd fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800508:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050c:	c7 44 24 08 3d 0f 80 	movl   $0x800f3d,0x8(%esp)
  800513:	00 
  800514:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800518:	8b 55 08             	mov    0x8(%ebp),%edx
  80051b:	89 14 24             	mov    %edx,(%esp)
  80051e:	e8 77 fe ff ff       	call   80039a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800526:	e9 ba fe ff ff       	jmp    8003e5 <vprintfmt+0x23>
  80052b:	89 f9                	mov    %edi,%ecx
  80052d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800530:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 30                	mov    (%eax),%esi
  80053e:	85 f6                	test   %esi,%esi
  800540:	75 05                	jne    800547 <vprintfmt+0x185>
				p = "(null)";
  800542:	be 2d 0f 80 00       	mov    $0x800f2d,%esi
			if (width > 0 && padc != '-')
  800547:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054b:	0f 8e 84 00 00 00    	jle    8005d5 <vprintfmt+0x213>
  800551:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800555:	74 7e                	je     8005d5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055b:	89 34 24             	mov    %esi,(%esp)
  80055e:	e8 8b 02 00 00       	call   8007ee <strnlen>
  800563:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800566:	29 c2                	sub    %eax,%edx
  800568:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80056b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80056f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800572:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800575:	89 de                	mov    %ebx,%esi
  800577:	89 d3                	mov    %edx,%ebx
  800579:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	eb 0b                	jmp    800588 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80057d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800581:	89 3c 24             	mov    %edi,(%esp)
  800584:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800587:	4b                   	dec    %ebx
  800588:	85 db                	test   %ebx,%ebx
  80058a:	7f f1                	jg     80057d <vprintfmt+0x1bb>
  80058c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80058f:	89 f3                	mov    %esi,%ebx
  800591:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800597:	85 c0                	test   %eax,%eax
  800599:	79 05                	jns    8005a0 <vprintfmt+0x1de>
  80059b:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a3:	29 c2                	sub    %eax,%edx
  8005a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a8:	eb 2b                	jmp    8005d5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ae:	74 18                	je     8005c8 <vprintfmt+0x206>
  8005b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b3:	83 fa 5e             	cmp    $0x5e,%edx
  8005b6:	76 10                	jbe    8005c8 <vprintfmt+0x206>
					putch('?', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
  8005c6:	eb 0a                	jmp    8005d2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	89 04 24             	mov    %eax,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d5:	0f be 06             	movsbl (%esi),%eax
  8005d8:	46                   	inc    %esi
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	74 21                	je     8005fe <vprintfmt+0x23c>
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	78 c9                	js     8005aa <vprintfmt+0x1e8>
  8005e1:	4f                   	dec    %edi
  8005e2:	79 c6                	jns    8005aa <vprintfmt+0x1e8>
  8005e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e7:	89 de                	mov    %ebx,%esi
  8005e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ec:	eb 18                	jmp    800606 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fb:	4b                   	dec    %ebx
  8005fc:	eb 08                	jmp    800606 <vprintfmt+0x244>
  8005fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800601:	89 de                	mov    %ebx,%esi
  800603:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800606:	85 db                	test   %ebx,%ebx
  800608:	7f e4                	jg     8005ee <vprintfmt+0x22c>
  80060a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80060d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800612:	e9 ce fd ff ff       	jmp    8003e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800617:	83 f9 01             	cmp    $0x1,%ecx
  80061a:	7e 10                	jle    80062c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 08             	lea    0x8(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 30                	mov    (%eax),%esi
  800627:	8b 78 04             	mov    0x4(%eax),%edi
  80062a:	eb 26                	jmp    800652 <vprintfmt+0x290>
	else if (lflag)
  80062c:	85 c9                	test   %ecx,%ecx
  80062e:	74 12                	je     800642 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 04             	lea    0x4(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	8b 30                	mov    (%eax),%esi
  80063b:	89 f7                	mov    %esi,%edi
  80063d:	c1 ff 1f             	sar    $0x1f,%edi
  800640:	eb 10                	jmp    800652 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	8b 30                	mov    (%eax),%esi
  80064d:	89 f7                	mov    %esi,%edi
  80064f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800652:	85 ff                	test   %edi,%edi
  800654:	78 0a                	js     800660 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 8c 00 00 00       	jmp    8006ec <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800664:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066e:	f7 de                	neg    %esi
  800670:	83 d7 00             	adc    $0x0,%edi
  800673:	f7 df                	neg    %edi
			}
			base = 10;
  800675:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067a:	eb 70                	jmp    8006ec <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067c:	89 ca                	mov    %ecx,%edx
  80067e:	8d 45 14             	lea    0x14(%ebp),%eax
  800681:	e8 c0 fc ff ff       	call   800346 <getuint>
  800686:	89 c6                	mov    %eax,%esi
  800688:	89 d7                	mov    %edx,%edi
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80068f:	eb 5b                	jmp    8006ec <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800691:	89 ca                	mov    %ecx,%edx
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 ab fc ff ff       	call   800346 <getuint>
  80069b:	89 c6                	mov    %eax,%esi
  80069d:	89 d7                	mov    %edx,%edi
			base = 8;
  80069f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006a4:	eb 46                	jmp    8006ec <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 04             	lea    0x4(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cb:	8b 30                	mov    (%eax),%esi
  8006cd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d7:	eb 13                	jmp    8006ec <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d9:	89 ca                	mov    %ecx,%edx
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
  8006de:	e8 63 fc ff ff       	call   800346 <getuint>
  8006e3:	89 c6                	mov    %eax,%esi
  8006e5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ec:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ff:	89 34 24             	mov    %esi,(%esp)
  800702:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800706:	89 da                	mov    %ebx,%edx
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	e8 6c fb ff ff       	call   80027c <printnum>
			break;
  800710:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800713:	e9 cd fc ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800718:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800722:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800725:	e9 bb fc ff ff       	jmp    8003e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	eb 01                	jmp    80073b <vprintfmt+0x379>
  80073a:	4e                   	dec    %esi
  80073b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80073f:	75 f9                	jne    80073a <vprintfmt+0x378>
  800741:	e9 9f fc ff ff       	jmp    8003e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800746:	83 c4 4c             	add    $0x4c,%esp
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	5f                   	pop    %edi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	83 ec 28             	sub    $0x28,%esp
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800761:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800764:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076b:	85 c0                	test   %eax,%eax
  80076d:	74 30                	je     80079f <vsnprintf+0x51>
  80076f:	85 d2                	test   %edx,%edx
  800771:	7e 33                	jle    8007a6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077a:	8b 45 10             	mov    0x10(%ebp),%eax
  80077d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800781:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	c7 04 24 80 03 80 00 	movl   $0x800380,(%esp)
  80078f:	e8 2e fc ff ff       	call   8003c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800797:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079d:	eb 0c                	jmp    8007ab <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a4:	eb 05                	jmp    8007ab <vsnprintf+0x5d>
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	89 04 24             	mov    %eax,(%esp)
  8007ce:	e8 7b ff ff ff       	call   80074e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    
  8007d5:	00 00                	add    %al,(%eax)
	...

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 01                	jmp    8007e6 <strlen+0xe>
		n++;
  8007e5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ea:	75 f9                	jne    8007e5 <strlen+0xd>
		n++;
	return n;
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	eb 01                	jmp    8007ff <strnlen+0x11>
		n++;
  8007fe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ff:	39 d0                	cmp    %edx,%eax
  800801:	74 06                	je     800809 <strnlen+0x1b>
  800803:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800807:	75 f5                	jne    8007fe <strnlen+0x10>
		n++;
	return n;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800815:	ba 00 00 00 00       	mov    $0x0,%edx
  80081a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80081d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800820:	42                   	inc    %edx
  800821:	84 c9                	test   %cl,%cl
  800823:	75 f5                	jne    80081a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800825:	5b                   	pop    %ebx
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800832:	89 1c 24             	mov    %ebx,(%esp)
  800835:	e8 9e ff ff ff       	call   8007d8 <strlen>
	strcpy(dst + len, src);
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800841:	01 d8                	add    %ebx,%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 c0 ff ff ff       	call   80080b <strcpy>
	return dst;
}
  80084b:	89 d8                	mov    %ebx,%eax
  80084d:	83 c4 08             	add    $0x8,%esp
  800850:	5b                   	pop    %ebx
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	b9 00 00 00 00       	mov    $0x0,%ecx
  800866:	eb 0c                	jmp    800874 <strncpy+0x21>
		*dst++ = *src;
  800868:	8a 1a                	mov    (%edx),%bl
  80086a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086d:	80 3a 01             	cmpb   $0x1,(%edx)
  800870:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800873:	41                   	inc    %ecx
  800874:	39 f1                	cmp    %esi,%ecx
  800876:	75 f0                	jne    800868 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800887:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088a:	85 d2                	test   %edx,%edx
  80088c:	75 0a                	jne    800898 <strlcpy+0x1c>
  80088e:	89 f0                	mov    %esi,%eax
  800890:	eb 1a                	jmp    8008ac <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800892:	88 18                	mov    %bl,(%eax)
  800894:	40                   	inc    %eax
  800895:	41                   	inc    %ecx
  800896:	eb 02                	jmp    80089a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800898:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80089a:	4a                   	dec    %edx
  80089b:	74 0a                	je     8008a7 <strlcpy+0x2b>
  80089d:	8a 19                	mov    (%ecx),%bl
  80089f:	84 db                	test   %bl,%bl
  8008a1:	75 ef                	jne    800892 <strlcpy+0x16>
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	eb 02                	jmp    8008a9 <strlcpy+0x2d>
  8008a7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008ac:	29 f0                	sub    %esi,%eax
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bb:	eb 02                	jmp    8008bf <strcmp+0xd>
		p++, q++;
  8008bd:	41                   	inc    %ecx
  8008be:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bf:	8a 01                	mov    (%ecx),%al
  8008c1:	84 c0                	test   %al,%al
  8008c3:	74 04                	je     8008c9 <strcmp+0x17>
  8008c5:	3a 02                	cmp    (%edx),%al
  8008c7:	74 f4                	je     8008bd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 c0             	movzbl %al,%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e0:	eb 03                	jmp    8008e5 <strncmp+0x12>
		n--, p++, q++;
  8008e2:	4a                   	dec    %edx
  8008e3:	40                   	inc    %eax
  8008e4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e5:	85 d2                	test   %edx,%edx
  8008e7:	74 14                	je     8008fd <strncmp+0x2a>
  8008e9:	8a 18                	mov    (%eax),%bl
  8008eb:	84 db                	test   %bl,%bl
  8008ed:	74 04                	je     8008f3 <strncmp+0x20>
  8008ef:	3a 19                	cmp    (%ecx),%bl
  8008f1:	74 ef                	je     8008e2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f3:	0f b6 00             	movzbl (%eax),%eax
  8008f6:	0f b6 11             	movzbl (%ecx),%edx
  8008f9:	29 d0                	sub    %edx,%eax
  8008fb:	eb 05                	jmp    800902 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090e:	eb 05                	jmp    800915 <strchr+0x10>
		if (*s == c)
  800910:	38 ca                	cmp    %cl,%dl
  800912:	74 0c                	je     800920 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800914:	40                   	inc    %eax
  800915:	8a 10                	mov    (%eax),%dl
  800917:	84 d2                	test   %dl,%dl
  800919:	75 f5                	jne    800910 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092b:	eb 05                	jmp    800932 <strfind+0x10>
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 07                	je     800938 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800931:	40                   	inc    %eax
  800932:	8a 10                	mov    (%eax),%dl
  800934:	84 d2                	test   %dl,%dl
  800936:	75 f5                	jne    80092d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800949:	85 c9                	test   %ecx,%ecx
  80094b:	74 30                	je     80097d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800953:	75 25                	jne    80097a <memset+0x40>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 20                	jne    80097a <memset+0x40>
		c &= 0xFF;
  80095a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095d:	89 d3                	mov    %edx,%ebx
  80095f:	c1 e3 08             	shl    $0x8,%ebx
  800962:	89 d6                	mov    %edx,%esi
  800964:	c1 e6 18             	shl    $0x18,%esi
  800967:	89 d0                	mov    %edx,%eax
  800969:	c1 e0 10             	shl    $0x10,%eax
  80096c:	09 f0                	or     %esi,%eax
  80096e:	09 d0                	or     %edx,%eax
  800970:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800972:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 03                	jmp    80097d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 34                	jae    8009ca <memmove+0x46>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2d                	jae    8009ca <memmove+0x46>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	f6 c2 03             	test   $0x3,%dl
  8009a3:	75 1b                	jne    8009c0 <memmove+0x3c>
  8009a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ab:	75 13                	jne    8009c0 <memmove+0x3c>
  8009ad:	f6 c1 03             	test   $0x3,%cl
  8009b0:	75 0e                	jne    8009c0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b2:	83 ef 04             	sub    $0x4,%edi
  8009b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009bb:	fd                   	std    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 07                	jmp    8009c7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c0:	4f                   	dec    %edi
  8009c1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c4:	fd                   	std    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c7:	fc                   	cld    
  8009c8:	eb 20                	jmp    8009ea <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d0:	75 13                	jne    8009e5 <memmove+0x61>
  8009d2:	a8 03                	test   $0x3,%al
  8009d4:	75 0f                	jne    8009e5 <memmove+0x61>
  8009d6:	f6 c1 03             	test   $0x3,%cl
  8009d9:	75 0a                	jne    8009e5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009db:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009de:	89 c7                	mov    %eax,%edi
  8009e0:	fc                   	cld    
  8009e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e3:	eb 05                	jmp    8009ea <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 77 ff ff ff       	call   800984 <memmove>
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a23:	eb 16                	jmp    800a3b <memcmp+0x2c>
		if (*s1 != *s2)
  800a25:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a28:	42                   	inc    %edx
  800a29:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a2d:	38 c8                	cmp    %cl,%al
  800a2f:	74 0a                	je     800a3b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a31:	0f b6 c0             	movzbl %al,%eax
  800a34:	0f b6 c9             	movzbl %cl,%ecx
  800a37:	29 c8                	sub    %ecx,%eax
  800a39:	eb 09                	jmp    800a44 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3b:	39 da                	cmp    %ebx,%edx
  800a3d:	75 e6                	jne    800a25 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a57:	eb 05                	jmp    800a5e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a59:	38 08                	cmp    %cl,(%eax)
  800a5b:	74 05                	je     800a62 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5d:	40                   	inc    %eax
  800a5e:	39 d0                	cmp    %edx,%eax
  800a60:	72 f7                	jb     800a59 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a70:	eb 01                	jmp    800a73 <strtol+0xf>
		s++;
  800a72:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a73:	8a 02                	mov    (%edx),%al
  800a75:	3c 20                	cmp    $0x20,%al
  800a77:	74 f9                	je     800a72 <strtol+0xe>
  800a79:	3c 09                	cmp    $0x9,%al
  800a7b:	74 f5                	je     800a72 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7d:	3c 2b                	cmp    $0x2b,%al
  800a7f:	75 08                	jne    800a89 <strtol+0x25>
		s++;
  800a81:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
  800a87:	eb 13                	jmp    800a9c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a89:	3c 2d                	cmp    $0x2d,%al
  800a8b:	75 0a                	jne    800a97 <strtol+0x33>
		s++, neg = 1;
  800a8d:	8d 52 01             	lea    0x1(%edx),%edx
  800a90:	bf 01 00 00 00       	mov    $0x1,%edi
  800a95:	eb 05                	jmp    800a9c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	74 05                	je     800aa5 <strtol+0x41>
  800aa0:	83 fb 10             	cmp    $0x10,%ebx
  800aa3:	75 28                	jne    800acd <strtol+0x69>
  800aa5:	8a 02                	mov    (%edx),%al
  800aa7:	3c 30                	cmp    $0x30,%al
  800aa9:	75 10                	jne    800abb <strtol+0x57>
  800aab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aaf:	75 0a                	jne    800abb <strtol+0x57>
		s += 2, base = 16;
  800ab1:	83 c2 02             	add    $0x2,%edx
  800ab4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab9:	eb 12                	jmp    800acd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	75 0e                	jne    800acd <strtol+0x69>
  800abf:	3c 30                	cmp    $0x30,%al
  800ac1:	75 05                	jne    800ac8 <strtol+0x64>
		s++, base = 8;
  800ac3:	42                   	inc    %edx
  800ac4:	b3 08                	mov    $0x8,%bl
  800ac6:	eb 05                	jmp    800acd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad4:	8a 0a                	mov    (%edx),%cl
  800ad6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x82>
			dig = *s - '0';
  800ade:	0f be c9             	movsbl %cl,%ecx
  800ae1:	83 e9 30             	sub    $0x30,%ecx
  800ae4:	eb 1e                	jmp    800b04 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 57             	sub    $0x57,%ecx
  800af4:	eb 0e                	jmp    800b04 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 12                	ja     800b10 <strtol+0xac>
			dig = *s - 'A' + 10;
  800afe:	0f be c9             	movsbl %cl,%ecx
  800b01:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b04:	39 f1                	cmp    %esi,%ecx
  800b06:	7d 0c                	jge    800b14 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b08:	42                   	inc    %edx
  800b09:	0f af c6             	imul   %esi,%eax
  800b0c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b0e:	eb c4                	jmp    800ad4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b10:	89 c1                	mov    %eax,%ecx
  800b12:	eb 02                	jmp    800b16 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b14:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1a:	74 05                	je     800b21 <strtol+0xbd>
		*endptr = (char *) s;
  800b1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b21:	85 ff                	test   %edi,%edi
  800b23:	74 04                	je     800b29 <strtol+0xc5>
  800b25:	89 c8                	mov    %ecx,%eax
  800b27:	f7 d8                	neg    %eax
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    
	...

00800b30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	89 c7                	mov    %eax,%edi
  800b45:	89 c6                	mov    %eax,%esi
  800b47:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b80:	8b 55 08             	mov    0x8(%ebp),%edx
  800b83:	89 cb                	mov    %ecx,%ebx
  800b85:	89 cf                	mov    %ecx,%edi
  800b87:	89 ce                	mov    %ecx,%esi
  800b89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7e 28                	jle    800bb7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b93:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9a:	00 
  800b9b:	c7 44 24 08 20 11 80 	movl   $0x801120,0x8(%esp)
  800ba2:	00 
  800ba3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800baa:	00 
  800bab:	c7 04 24 3d 11 80 00 	movl   $0x80113d,(%esp)
  800bb2:	e8 b1 f5 ff ff       	call   800168 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb7:	83 c4 2c             	add    $0x2c,%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    
	...

00800be0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800be0:	55                   	push   %ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	83 ec 10             	sub    $0x10,%esp
  800be6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800bea:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800bee:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800bf6:	89 cd                	mov    %ecx,%ebp
  800bf8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	75 2c                	jne    800c2c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800c00:	39 f9                	cmp    %edi,%ecx
  800c02:	77 68                	ja     800c6c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800c04:	85 c9                	test   %ecx,%ecx
  800c06:	75 0b                	jne    800c13 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800c08:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0d:	31 d2                	xor    %edx,%edx
  800c0f:	f7 f1                	div    %ecx
  800c11:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800c13:	31 d2                	xor    %edx,%edx
  800c15:	89 f8                	mov    %edi,%eax
  800c17:	f7 f1                	div    %ecx
  800c19:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c1b:	89 f0                	mov    %esi,%eax
  800c1d:	f7 f1                	div    %ecx
  800c1f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c21:	89 f0                	mov    %esi,%eax
  800c23:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c2c:	39 f8                	cmp    %edi,%eax
  800c2e:	77 2c                	ja     800c5c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c30:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800c33:	83 f6 1f             	xor    $0x1f,%esi
  800c36:	75 4c                	jne    800c84 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c38:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c3a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c3f:	72 0a                	jb     800c4b <__udivdi3+0x6b>
  800c41:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800c45:	0f 87 ad 00 00 00    	ja     800cf8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800c4b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c50:	89 f0                	mov    %esi,%eax
  800c52:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c54:	83 c4 10             	add    $0x10,%esp
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    
  800c5b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c5c:	31 ff                	xor    %edi,%edi
  800c5e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c60:	89 f0                	mov    %esi,%eax
  800c62:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c64:	83 c4 10             	add    $0x10,%esp
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    
  800c6b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c6c:	89 fa                	mov    %edi,%edx
  800c6e:	89 f0                	mov    %esi,%eax
  800c70:	f7 f1                	div    %ecx
  800c72:	89 c6                	mov    %eax,%esi
  800c74:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c7a:	83 c4 10             	add    $0x10,%esp
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    
  800c81:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c84:	89 f1                	mov    %esi,%ecx
  800c86:	d3 e0                	shl    %cl,%eax
  800c88:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800c91:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c93:	89 ea                	mov    %ebp,%edx
  800c95:	88 c1                	mov    %al,%cl
  800c97:	d3 ea                	shr    %cl,%edx
  800c99:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800c9d:	09 ca                	or     %ecx,%edx
  800c9f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800ca3:	89 f1                	mov    %esi,%ecx
  800ca5:	d3 e5                	shl    %cl,%ebp
  800ca7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800cab:	89 fd                	mov    %edi,%ebp
  800cad:	88 c1                	mov    %al,%cl
  800caf:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800cb1:	89 fa                	mov    %edi,%edx
  800cb3:	89 f1                	mov    %esi,%ecx
  800cb5:	d3 e2                	shl    %cl,%edx
  800cb7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cbb:	88 c1                	mov    %al,%cl
  800cbd:	d3 ef                	shr    %cl,%edi
  800cbf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800cc1:	89 f8                	mov    %edi,%eax
  800cc3:	89 ea                	mov    %ebp,%edx
  800cc5:	f7 74 24 08          	divl   0x8(%esp)
  800cc9:	89 d1                	mov    %edx,%ecx
  800ccb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800ccd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800cd1:	39 d1                	cmp    %edx,%ecx
  800cd3:	72 17                	jb     800cec <__udivdi3+0x10c>
  800cd5:	74 09                	je     800ce0 <__udivdi3+0x100>
  800cd7:	89 fe                	mov    %edi,%esi
  800cd9:	31 ff                	xor    %edi,%edi
  800cdb:	e9 41 ff ff ff       	jmp    800c21 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ce0:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ce4:	89 f1                	mov    %esi,%ecx
  800ce6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ce8:	39 c2                	cmp    %eax,%edx
  800cea:	73 eb                	jae    800cd7 <__udivdi3+0xf7>
		{
		  q0--;
  800cec:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800cef:	31 ff                	xor    %edi,%edi
  800cf1:	e9 2b ff ff ff       	jmp    800c21 <__udivdi3+0x41>
  800cf6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800cf8:	31 f6                	xor    %esi,%esi
  800cfa:	e9 22 ff ff ff       	jmp    800c21 <__udivdi3+0x41>
	...

00800d00 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	83 ec 20             	sub    $0x20,%esp
  800d06:	8b 44 24 30          	mov    0x30(%esp),%eax
  800d0a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d0e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800d12:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800d16:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800d1a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800d1e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800d20:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d22:	85 ed                	test   %ebp,%ebp
  800d24:	75 16                	jne    800d3c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800d26:	39 f1                	cmp    %esi,%ecx
  800d28:	0f 86 a6 00 00 00    	jbe    800dd4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d2e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800d30:	89 d0                	mov    %edx,%eax
  800d32:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d34:	83 c4 20             	add    $0x20,%esp
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    
  800d3b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d3c:	39 f5                	cmp    %esi,%ebp
  800d3e:	0f 87 ac 00 00 00    	ja     800df0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d44:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800d47:	83 f0 1f             	xor    $0x1f,%eax
  800d4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4e:	0f 84 a8 00 00 00    	je     800dfc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d54:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d58:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d5a:	bf 20 00 00 00       	mov    $0x20,%edi
  800d5f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d63:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d67:	89 f9                	mov    %edi,%ecx
  800d69:	d3 e8                	shr    %cl,%eax
  800d6b:	09 e8                	or     %ebp,%eax
  800d6d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800d71:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d75:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d79:	d3 e0                	shl    %cl,%eax
  800d7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d7f:	89 f2                	mov    %esi,%edx
  800d81:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d83:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d87:	d3 e0                	shl    %cl,%eax
  800d89:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d8d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e8                	shr    %cl,%eax
  800d95:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d97:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d99:	89 f2                	mov    %esi,%edx
  800d9b:	f7 74 24 18          	divl   0x18(%esp)
  800d9f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800da1:	f7 64 24 0c          	mull   0xc(%esp)
  800da5:	89 c5                	mov    %eax,%ebp
  800da7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800da9:	39 d6                	cmp    %edx,%esi
  800dab:	72 67                	jb     800e14 <__umoddi3+0x114>
  800dad:	74 75                	je     800e24 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800daf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800db3:	29 e8                	sub    %ebp,%eax
  800db5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800db7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	89 f2                	mov    %esi,%edx
  800dbf:	89 f9                	mov    %edi,%ecx
  800dc1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800dc3:	09 d0                	or     %edx,%eax
  800dc5:	89 f2                	mov    %esi,%edx
  800dc7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800dcb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dcd:	83 c4 20             	add    $0x20,%esp
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dd4:	85 c9                	test   %ecx,%ecx
  800dd6:	75 0b                	jne    800de3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dd8:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddd:	31 d2                	xor    %edx,%edx
  800ddf:	f7 f1                	div    %ecx
  800de1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800de3:	89 f0                	mov    %esi,%eax
  800de5:	31 d2                	xor    %edx,%edx
  800de7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800de9:	89 f8                	mov    %edi,%eax
  800deb:	e9 3e ff ff ff       	jmp    800d2e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800df0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800df2:	83 c4 20             	add    $0x20,%esp
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
  800df9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dfc:	39 f5                	cmp    %esi,%ebp
  800dfe:	72 04                	jb     800e04 <__umoddi3+0x104>
  800e00:	39 f9                	cmp    %edi,%ecx
  800e02:	77 06                	ja     800e0a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e04:	89 f2                	mov    %esi,%edx
  800e06:	29 cf                	sub    %ecx,%edi
  800e08:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800e0a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e0c:	83 c4 20             	add    $0x20,%esp
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
  800e13:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e14:	89 d1                	mov    %edx,%ecx
  800e16:	89 c5                	mov    %eax,%ebp
  800e18:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800e1c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800e20:	eb 8d                	jmp    800daf <__umoddi3+0xaf>
  800e22:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e24:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800e28:	72 ea                	jb     800e14 <__umoddi3+0x114>
  800e2a:	89 f1                	mov    %esi,%ecx
  800e2c:	eb 81                	jmp    800daf <__umoddi3+0xaf>
