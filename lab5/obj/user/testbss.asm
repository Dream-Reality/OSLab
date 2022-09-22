
obj/user/testbss.debug:     file format elf32-i386


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
  80003a:	c7 04 24 40 20 80 00 	movl   $0x802040,(%esp)
  800041:	e8 22 02 00 00       	call   800268 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 bb 20 80 	movl   $0x8020bb,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 d8 20 80 00 	movl   $0x8020d8,(%esp)
  800070:	e8 fb 00 00 00       	call   800170 <_panic>
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
  800082:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

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
  800096:	39 04 85 20 40 80 00 	cmp    %eax,0x804020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 60 20 80 	movl   $0x802060,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 d8 20 80 00 	movl   $0x8020d8,(%esp)
  8000ba:	e8 b1 00 00 00       	call   800170 <_panic>
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
  8000c7:	c7 04 24 88 20 80 00 	movl   $0x802088,(%esp)
  8000ce:	e8 95 01 00 00       	call   800268 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 e7 20 80 	movl   $0x8020e7,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 d8 20 80 00 	movl   $0x8020d8,(%esp)
  8000f4:	e8 77 00 00 00       	call   800170 <_panic>
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 20             	sub    $0x20,%esp
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80010a:	e8 b8 0a 00 00       	call   800bc7 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011b:	c1 e0 07             	shl    $0x7,%eax
  80011e:	29 d0                	sub    %edx,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800128:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80012b:	a3 20 40 c0 00       	mov    %eax,0xc04020
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800130:	85 f6                	test   %esi,%esi
  800132:	7e 07                	jle    80013b <libmain+0x3f>
		binaryname = argv[0];
  800134:	8b 03                	mov    (%ebx),%eax
  800136:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013f:	89 34 24             	mov    %esi,(%esp)
  800142:	e8 ed fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800147:	e8 08 00 00 00       	call   800154 <exit>
}
  80014c:	83 c4 20             	add    $0x20,%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    
	...

00800154 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80015a:	e8 fa 0e 00 00       	call   801059 <close_all>
	sys_env_destroy(0);
  80015f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800166:	e8 0a 0a 00 00       	call   800b75 <sys_env_destroy>
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    
  80016d:	00 00                	add    %al,(%eax)
	...

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800178:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800181:	e8 41 0a 00 00       	call   800bc7 <sys_getenvid>
  800186:	8b 55 0c             	mov    0xc(%ebp),%edx
  800189:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018d:	8b 55 08             	mov    0x8(%ebp),%edx
  800190:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800194:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 08 21 80 00 	movl   $0x802108,(%esp)
  8001a3:	e8 c0 00 00 00       	call   800268 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 50 00 00 00       	call   800207 <vcprintf>
	cprintf("\n");
  8001b7:	c7 04 24 d6 20 80 00 	movl   $0x8020d6,(%esp)
  8001be:	e8 a5 00 00 00       	call   800268 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c3:	cc                   	int3   
  8001c4:	eb fd                	jmp    8001c3 <_panic+0x53>
	...

008001c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  8001cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d2:	8b 03                	mov    (%ebx),%eax
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001db:	40                   	inc    %eax
  8001dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e3:	75 19                	jne    8001fe <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001e5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ec:	00 
  8001ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 40 09 00 00       	call   800b38 <sys_cputs>
		b->idx = 0;
  8001f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001fe:	ff 43 04             	incl   0x4(%ebx)
}
  800201:	83 c4 14             	add    $0x14,%esp
  800204:	5b                   	pop    %ebx
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800210:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800217:	00 00 00 
	b.cnt = 0;
  80021a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800221:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023c:	c7 04 24 c8 01 80 00 	movl   $0x8001c8,(%esp)
  800243:	e8 82 01 00 00       	call   8003ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800248:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800252:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	e8 d8 08 00 00       	call   800b38 <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 87 ff ff ff       	call   800207 <vcprintf>
	va_end(ap);

	return cnt;
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    
	...

00800284 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 3c             	sub    $0x3c,%esp
  80028d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800290:	89 d7                	mov    %edx,%edi
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a4:	85 c0                	test   %eax,%eax
  8002a6:	75 08                	jne    8002b0 <printnum+0x2c>
  8002a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 57                	ja     800307 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002b4:	4b                   	dec    %ebx
  8002b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cf:	00 
  8002d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	e8 fa 1a 00 00       	call   801ddc <__udivdi3>
  8002e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ea:	89 04 24             	mov    %eax,(%esp)
  8002ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f1:	89 fa                	mov    %edi,%edx
  8002f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f6:	e8 89 ff ff ff       	call   800284 <printnum>
  8002fb:	eb 0f                	jmp    80030c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800301:	89 34 24             	mov    %esi,(%esp)
  800304:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800307:	4b                   	dec    %ebx
  800308:	85 db                	test   %ebx,%ebx
  80030a:	7f f1                	jg     8002fd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800314:	8b 45 10             	mov    0x10(%ebp),%eax
  800317:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800322:	00 
  800323:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800330:	e8 c7 1b 00 00       	call   801efc <__umoddi3>
  800335:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800339:	0f be 80 2b 21 80 00 	movsbl 0x80212b(%eax),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800346:	83 c4 3c             	add    $0x3c,%esp
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800351:	83 fa 01             	cmp    $0x1,%edx
  800354:	7e 0e                	jle    800364 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800356:	8b 10                	mov    (%eax),%edx
  800358:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035b:	89 08                	mov    %ecx,(%eax)
  80035d:	8b 02                	mov    (%edx),%eax
  80035f:	8b 52 04             	mov    0x4(%edx),%edx
  800362:	eb 22                	jmp    800386 <getuint+0x38>
	else if (lflag)
  800364:	85 d2                	test   %edx,%edx
  800366:	74 10                	je     800378 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	eb 0e                	jmp    800386 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 02                	mov    (%edx),%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800391:	8b 10                	mov    (%eax),%edx
  800393:	3b 50 04             	cmp    0x4(%eax),%edx
  800396:	73 08                	jae    8003a0 <sprintputch+0x18>
		*b->buf++ = ch;
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	88 0a                	mov    %cl,(%edx)
  80039d:	42                   	inc    %edx
  80039e:	89 10                	mov    %edx,(%eax)
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003af:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 02 00 00 00       	call   8003ca <vprintfmt>
	va_end(ap);
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	57                   	push   %edi
  8003ce:	56                   	push   %esi
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 4c             	sub    $0x4c,%esp
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d9:	eb 12                	jmp    8003ed <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	0f 84 6b 03 00 00    	je     80074e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ed:	0f b6 06             	movzbl (%esi),%eax
  8003f0:	46                   	inc    %esi
  8003f1:	83 f8 25             	cmp    $0x25,%eax
  8003f4:	75 e5                	jne    8003db <vprintfmt+0x11>
  8003f6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800401:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800406:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800412:	eb 26                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800417:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80041b:	eb 1d                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800424:	eb 14                	jmp    80043a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800429:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800430:	eb 08                	jmp    80043a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800432:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800435:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	0f b6 06             	movzbl (%esi),%eax
  80043d:	8d 56 01             	lea    0x1(%esi),%edx
  800440:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800443:	8a 16                	mov    (%esi),%dl
  800445:	83 ea 23             	sub    $0x23,%edx
  800448:	80 fa 55             	cmp    $0x55,%dl
  80044b:	0f 87 e1 02 00 00    	ja     800732 <vprintfmt+0x368>
  800451:	0f b6 d2             	movzbl %dl,%edx
  800454:	ff 24 95 60 22 80 00 	jmp    *0x802260(,%edx,4)
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800463:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800466:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80046a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80046d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800470:	83 fa 09             	cmp    $0x9,%edx
  800473:	77 2a                	ja     80049f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800475:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800476:	eb eb                	jmp    800463 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800486:	eb 17                	jmp    80049f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800488:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048c:	78 98                	js     800426 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800491:	eb a7                	jmp    80043a <vprintfmt+0x70>
  800493:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800496:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80049d:	eb 9b                	jmp    80043a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80049f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a3:	79 95                	jns    80043a <vprintfmt+0x70>
  8004a5:	eb 8b                	jmp    800432 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ab:	eb 8d                	jmp    80043a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c5:	e9 23 ff ff ff       	jmp    8003ed <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 50 04             	lea    0x4(%eax),%edx
  8004d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	79 02                	jns    8004db <vprintfmt+0x111>
  8004d9:	f7 d8                	neg    %eax
  8004db:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004dd:	83 f8 0f             	cmp    $0xf,%eax
  8004e0:	7f 0b                	jg     8004ed <vprintfmt+0x123>
  8004e2:	8b 04 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	75 23                	jne    800510 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f1:	c7 44 24 08 43 21 80 	movl   $0x802143,0x8(%esp)
  8004f8:	00 
  8004f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	e8 9a fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80050b:	e9 dd fe ff ff       	jmp    8003ed <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800510:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800514:	c7 44 24 08 f5 24 80 	movl   $0x8024f5,0x8(%esp)
  80051b:	00 
  80051c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800520:	8b 55 08             	mov    0x8(%ebp),%edx
  800523:	89 14 24             	mov    %edx,(%esp)
  800526:	e8 77 fe ff ff       	call   8003a2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80052e:	e9 ba fe ff ff       	jmp    8003ed <vprintfmt+0x23>
  800533:	89 f9                	mov    %edi,%ecx
  800535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800538:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 30                	mov    (%eax),%esi
  800546:	85 f6                	test   %esi,%esi
  800548:	75 05                	jne    80054f <vprintfmt+0x185>
				p = "(null)";
  80054a:	be 3c 21 80 00       	mov    $0x80213c,%esi
			if (width > 0 && padc != '-')
  80054f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800553:	0f 8e 84 00 00 00    	jle    8005dd <vprintfmt+0x213>
  800559:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80055d:	74 7e                	je     8005dd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800563:	89 34 24             	mov    %esi,(%esp)
  800566:	e8 8b 02 00 00       	call   8007f6 <strnlen>
  80056b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056e:	29 c2                	sub    %eax,%edx
  800570:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800573:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800577:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80057a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80057d:	89 de                	mov    %ebx,%esi
  80057f:	89 d3                	mov    %edx,%ebx
  800581:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	eb 0b                	jmp    800590 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800585:	89 74 24 04          	mov    %esi,0x4(%esp)
  800589:	89 3c 24             	mov    %edi,(%esp)
  80058c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	4b                   	dec    %ebx
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f f1                	jg     800585 <vprintfmt+0x1bb>
  800594:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800597:	89 f3                	mov    %esi,%ebx
  800599:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80059c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	79 05                	jns    8005a8 <vprintfmt+0x1de>
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ab:	29 c2                	sub    %eax,%edx
  8005ad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b0:	eb 2b                	jmp    8005dd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b6:	74 18                	je     8005d0 <vprintfmt+0x206>
  8005b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005bb:	83 fa 5e             	cmp    $0x5e,%edx
  8005be:	76 10                	jbe    8005d0 <vprintfmt+0x206>
					putch('?', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
  8005ce:	eb 0a                	jmp    8005da <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	ff 4d e4             	decl   -0x1c(%ebp)
  8005dd:	0f be 06             	movsbl (%esi),%eax
  8005e0:	46                   	inc    %esi
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	74 21                	je     800606 <vprintfmt+0x23c>
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	78 c9                	js     8005b2 <vprintfmt+0x1e8>
  8005e9:	4f                   	dec    %edi
  8005ea:	79 c6                	jns    8005b2 <vprintfmt+0x1e8>
  8005ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ef:	89 de                	mov    %ebx,%esi
  8005f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f4:	eb 18                	jmp    80060e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fa:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800601:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800603:	4b                   	dec    %ebx
  800604:	eb 08                	jmp    80060e <vprintfmt+0x244>
  800606:	8b 7d 08             	mov    0x8(%ebp),%edi
  800609:	89 de                	mov    %ebx,%esi
  80060b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80060e:	85 db                	test   %ebx,%ebx
  800610:	7f e4                	jg     8005f6 <vprintfmt+0x22c>
  800612:	89 7d 08             	mov    %edi,0x8(%ebp)
  800615:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061a:	e9 ce fd ff ff       	jmp    8003ed <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7e 10                	jle    800634 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 08             	lea    0x8(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 30                	mov    (%eax),%esi
  80062f:	8b 78 04             	mov    0x4(%eax),%edi
  800632:	eb 26                	jmp    80065a <vprintfmt+0x290>
	else if (lflag)
  800634:	85 c9                	test   %ecx,%ecx
  800636:	74 12                	je     80064a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 30                	mov    (%eax),%esi
  800643:	89 f7                	mov    %esi,%edi
  800645:	c1 ff 1f             	sar    $0x1f,%edi
  800648:	eb 10                	jmp    80065a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)
  800653:	8b 30                	mov    (%eax),%esi
  800655:	89 f7                	mov    %esi,%edi
  800657:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80065a:	85 ff                	test   %edi,%edi
  80065c:	78 0a                	js     800668 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800663:	e9 8c 00 00 00       	jmp    8006f4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800668:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800676:	f7 de                	neg    %esi
  800678:	83 d7 00             	adc    $0x0,%edi
  80067b:	f7 df                	neg    %edi
			}
			base = 10;
  80067d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800682:	eb 70                	jmp    8006f4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800684:	89 ca                	mov    %ecx,%edx
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 c0 fc ff ff       	call   80034e <getuint>
  80068e:	89 c6                	mov    %eax,%esi
  800690:	89 d7                	mov    %edx,%edi
			base = 10;
  800692:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800697:	eb 5b                	jmp    8006f4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 ab fc ff ff       	call   80034e <getuint>
  8006a3:	89 c6                	mov    %eax,%esi
  8006a5:	89 d7                	mov    %edx,%edi
			base = 8;
  8006a7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006ac:	eb 46                	jmp    8006f4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006b9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d3:	8b 30                	mov    (%eax),%esi
  8006d5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006df:	eb 13                	jmp    8006f4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 63 fc ff ff       	call   80034e <getuint>
  8006eb:	89 c6                	mov    %eax,%esi
  8006ed:	89 d7                	mov    %edx,%edi
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006f8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800703:	89 44 24 08          	mov    %eax,0x8(%esp)
  800707:	89 34 24             	mov    %esi,(%esp)
  80070a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070e:	89 da                	mov    %ebx,%edx
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	e8 6c fb ff ff       	call   800284 <printnum>
			break;
  800718:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80071b:	e9 cd fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072d:	e9 bb fc ff ff       	jmp    8003ed <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800736:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800740:	eb 01                	jmp    800743 <vprintfmt+0x379>
  800742:	4e                   	dec    %esi
  800743:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800747:	75 f9                	jne    800742 <vprintfmt+0x378>
  800749:	e9 9f fc ff ff       	jmp    8003ed <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80074e:	83 c4 4c             	add    $0x4c,%esp
  800751:	5b                   	pop    %ebx
  800752:	5e                   	pop    %esi
  800753:	5f                   	pop    %edi
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	83 ec 28             	sub    $0x28,%esp
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800762:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800765:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800769:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800773:	85 c0                	test   %eax,%eax
  800775:	74 30                	je     8007a7 <vsnprintf+0x51>
  800777:	85 d2                	test   %edx,%edx
  800779:	7e 33                	jle    8007ae <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800782:	8b 45 10             	mov    0x10(%ebp),%eax
  800785:	89 44 24 08          	mov    %eax,0x8(%esp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800790:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  800797:	e8 2e fc ff ff       	call   8003ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a5:	eb 0c                	jmp    8007b3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ac:	eb 05                	jmp    8007b3 <vsnprintf+0x5d>
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	89 04 24             	mov    %eax,(%esp)
  8007d6:	e8 7b ff ff ff       	call   800756 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 01                	jmp    8007ee <strlen+0xe>
		n++;
  8007ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f2:	75 f9                	jne    8007ed <strlen+0xd>
		n++;
	return n;
}
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800804:	eb 01                	jmp    800807 <strnlen+0x11>
		n++;
  800806:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	39 d0                	cmp    %edx,%eax
  800809:	74 06                	je     800811 <strnlen+0x1b>
  80080b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080f:	75 f5                	jne    800806 <strnlen+0x10>
		n++;
	return n;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 45 08             	mov    0x8(%ebp),%eax
  80081a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
  800822:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800825:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800828:	42                   	inc    %edx
  800829:	84 c9                	test   %cl,%cl
  80082b:	75 f5                	jne    800822 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80082d:	5b                   	pop    %ebx
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	89 1c 24             	mov    %ebx,(%esp)
  80083d:	e8 9e ff ff ff       	call   8007e0 <strlen>
	strcpy(dst + len, src);
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
  800845:	89 54 24 04          	mov    %edx,0x4(%esp)
  800849:	01 d8                	add    %ebx,%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 c0 ff ff ff       	call   800813 <strcpy>
	return dst;
}
  800853:	89 d8                	mov    %ebx,%eax
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
  800866:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086e:	eb 0c                	jmp    80087c <strncpy+0x21>
		*dst++ = *src;
  800870:	8a 1a                	mov    (%edx),%bl
  800872:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800875:	80 3a 01             	cmpb   $0x1,(%edx)
  800878:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087b:	41                   	inc    %ecx
  80087c:	39 f1                	cmp    %esi,%ecx
  80087e:	75 f0                	jne    800870 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 d2                	test   %edx,%edx
  800894:	75 0a                	jne    8008a0 <strlcpy+0x1c>
  800896:	89 f0                	mov    %esi,%eax
  800898:	eb 1a                	jmp    8008b4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089a:	88 18                	mov    %bl,(%eax)
  80089c:	40                   	inc    %eax
  80089d:	41                   	inc    %ecx
  80089e:	eb 02                	jmp    8008a2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008a2:	4a                   	dec    %edx
  8008a3:	74 0a                	je     8008af <strlcpy+0x2b>
  8008a5:	8a 19                	mov    (%ecx),%bl
  8008a7:	84 db                	test   %bl,%bl
  8008a9:	75 ef                	jne    80089a <strlcpy+0x16>
  8008ab:	89 c2                	mov    %eax,%edx
  8008ad:	eb 02                	jmp    8008b1 <strlcpy+0x2d>
  8008af:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b4:	29 f0                	sub    %esi,%eax
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5e                   	pop    %esi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c3:	eb 02                	jmp    8008c7 <strcmp+0xd>
		p++, q++;
  8008c5:	41                   	inc    %ecx
  8008c6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c7:	8a 01                	mov    (%ecx),%al
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 04                	je     8008d1 <strcmp+0x17>
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	74 f4                	je     8008c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 c0             	movzbl %al,%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008e8:	eb 03                	jmp    8008ed <strncmp+0x12>
		n--, p++, q++;
  8008ea:	4a                   	dec    %edx
  8008eb:	40                   	inc    %eax
  8008ec:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ed:	85 d2                	test   %edx,%edx
  8008ef:	74 14                	je     800905 <strncmp+0x2a>
  8008f1:	8a 18                	mov    (%eax),%bl
  8008f3:	84 db                	test   %bl,%bl
  8008f5:	74 04                	je     8008fb <strncmp+0x20>
  8008f7:	3a 19                	cmp    (%ecx),%bl
  8008f9:	74 ef                	je     8008ea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 00             	movzbl (%eax),%eax
  8008fe:	0f b6 11             	movzbl (%ecx),%edx
  800901:	29 d0                	sub    %edx,%eax
  800903:	eb 05                	jmp    80090a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090a:	5b                   	pop    %ebx
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800916:	eb 05                	jmp    80091d <strchr+0x10>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 0c                	je     800928 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091c:	40                   	inc    %eax
  80091d:	8a 10                	mov    (%eax),%dl
  80091f:	84 d2                	test   %dl,%dl
  800921:	75 f5                	jne    800918 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800933:	eb 05                	jmp    80093a <strfind+0x10>
		if (*s == c)
  800935:	38 ca                	cmp    %cl,%dl
  800937:	74 07                	je     800940 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800939:	40                   	inc    %eax
  80093a:	8a 10                	mov    (%eax),%dl
  80093c:	84 d2                	test   %dl,%dl
  80093e:	75 f5                	jne    800935 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800951:	85 c9                	test   %ecx,%ecx
  800953:	74 30                	je     800985 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800955:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095b:	75 25                	jne    800982 <memset+0x40>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 20                	jne    800982 <memset+0x40>
		c &= 0xFF;
  800962:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800965:	89 d3                	mov    %edx,%ebx
  800967:	c1 e3 08             	shl    $0x8,%ebx
  80096a:	89 d6                	mov    %edx,%esi
  80096c:	c1 e6 18             	shl    $0x18,%esi
  80096f:	89 d0                	mov    %edx,%eax
  800971:	c1 e0 10             	shl    $0x10,%eax
  800974:	09 f0                	or     %esi,%eax
  800976:	09 d0                	or     %edx,%eax
  800978:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80097a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80097d:	fc                   	cld    
  80097e:	f3 ab                	rep stos %eax,%es:(%edi)
  800980:	eb 03                	jmp    800985 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800982:	fc                   	cld    
  800983:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800985:	89 f8                	mov    %edi,%eax
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 75 0c             	mov    0xc(%ebp),%esi
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099a:	39 c6                	cmp    %eax,%esi
  80099c:	73 34                	jae    8009d2 <memmove+0x46>
  80099e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a1:	39 d0                	cmp    %edx,%eax
  8009a3:	73 2d                	jae    8009d2 <memmove+0x46>
		s += n;
		d += n;
  8009a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	f6 c2 03             	test   $0x3,%dl
  8009ab:	75 1b                	jne    8009c8 <memmove+0x3c>
  8009ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b3:	75 13                	jne    8009c8 <memmove+0x3c>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0e                	jne    8009c8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ba:	83 ef 04             	sub    $0x4,%edi
  8009bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c3:	fd                   	std    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 07                	jmp    8009cf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c8:	4f                   	dec    %edi
  8009c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cc:	fd                   	std    
  8009cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cf:	fc                   	cld    
  8009d0:	eb 20                	jmp    8009f2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d8:	75 13                	jne    8009ed <memmove+0x61>
  8009da:	a8 03                	test   $0x3,%al
  8009dc:	75 0f                	jne    8009ed <memmove+0x61>
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 0a                	jne    8009ed <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb 05                	jmp    8009f2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	89 04 24             	mov    %eax,(%esp)
  800a10:	e8 77 ff ff ff       	call   80098c <memmove>
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	eb 16                	jmp    800a43 <memcmp+0x2c>
		if (*s1 != *s2)
  800a2d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a30:	42                   	inc    %edx
  800a31:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a35:	38 c8                	cmp    %cl,%al
  800a37:	74 0a                	je     800a43 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a39:	0f b6 c0             	movzbl %al,%eax
  800a3c:	0f b6 c9             	movzbl %cl,%ecx
  800a3f:	29 c8                	sub    %ecx,%eax
  800a41:	eb 09                	jmp    800a4c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a43:	39 da                	cmp    %ebx,%edx
  800a45:	75 e6                	jne    800a2d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5a:	89 c2                	mov    %eax,%edx
  800a5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5f:	eb 05                	jmp    800a66 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a61:	38 08                	cmp    %cl,(%eax)
  800a63:	74 05                	je     800a6a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a65:	40                   	inc    %eax
  800a66:	39 d0                	cmp    %edx,%eax
  800a68:	72 f7                	jb     800a61 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a78:	eb 01                	jmp    800a7b <strtol+0xf>
		s++;
  800a7a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7b:	8a 02                	mov    (%edx),%al
  800a7d:	3c 20                	cmp    $0x20,%al
  800a7f:	74 f9                	je     800a7a <strtol+0xe>
  800a81:	3c 09                	cmp    $0x9,%al
  800a83:	74 f5                	je     800a7a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a85:	3c 2b                	cmp    $0x2b,%al
  800a87:	75 08                	jne    800a91 <strtol+0x25>
		s++;
  800a89:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8f:	eb 13                	jmp    800aa4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a91:	3c 2d                	cmp    $0x2d,%al
  800a93:	75 0a                	jne    800a9f <strtol+0x33>
		s++, neg = 1;
  800a95:	8d 52 01             	lea    0x1(%edx),%edx
  800a98:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9d:	eb 05                	jmp    800aa4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	74 05                	je     800aad <strtol+0x41>
  800aa8:	83 fb 10             	cmp    $0x10,%ebx
  800aab:	75 28                	jne    800ad5 <strtol+0x69>
  800aad:	8a 02                	mov    (%edx),%al
  800aaf:	3c 30                	cmp    $0x30,%al
  800ab1:	75 10                	jne    800ac3 <strtol+0x57>
  800ab3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab7:	75 0a                	jne    800ac3 <strtol+0x57>
		s += 2, base = 16;
  800ab9:	83 c2 02             	add    $0x2,%edx
  800abc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac1:	eb 12                	jmp    800ad5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac3:	85 db                	test   %ebx,%ebx
  800ac5:	75 0e                	jne    800ad5 <strtol+0x69>
  800ac7:	3c 30                	cmp    $0x30,%al
  800ac9:	75 05                	jne    800ad0 <strtol+0x64>
		s++, base = 8;
  800acb:	42                   	inc    %edx
  800acc:	b3 08                	mov    $0x8,%bl
  800ace:	eb 05                	jmp    800ad5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
  800ada:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adc:	8a 0a                	mov    (%edx),%cl
  800ade:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae1:	80 fb 09             	cmp    $0x9,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x82>
			dig = *s - '0';
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 30             	sub    $0x30,%ecx
  800aec:	eb 1e                	jmp    800b0c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 08                	ja     800afe <strtol+0x92>
			dig = *s - 'a' + 10;
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 57             	sub    $0x57,%ecx
  800afc:	eb 0e                	jmp    800b0c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800afe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 12                	ja     800b18 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b06:	0f be c9             	movsbl %cl,%ecx
  800b09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b0c:	39 f1                	cmp    %esi,%ecx
  800b0e:	7d 0c                	jge    800b1c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b10:	42                   	inc    %edx
  800b11:	0f af c6             	imul   %esi,%eax
  800b14:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb c4                	jmp    800adc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	89 c1                	mov    %eax,%ecx
  800b1a:	eb 02                	jmp    800b1e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b22:	74 05                	je     800b29 <strtol+0xbd>
		*endptr = (char *) s;
  800b24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b27:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b29:	85 ff                	test   %edi,%edi
  800b2b:	74 04                	je     800b31 <strtol+0xc5>
  800b2d:	89 c8                	mov    %ecx,%eax
  800b2f:	f7 d8                	neg    %eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
	...

00800b38 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 c3                	mov    %eax,%ebx
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	89 c6                	mov    %eax,%esi
  800b4f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	89 d1                	mov    %edx,%ecx
  800b68:	89 d3                	mov    %edx,%ebx
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 d6                	mov    %edx,%esi
  800b6e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	b8 03 00 00 00       	mov    $0x3,%eax
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	89 cb                	mov    %ecx,%ebx
  800b8d:	89 cf                	mov    %ecx,%edi
  800b8f:	89 ce                	mov    %ecx,%esi
  800b91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7e 28                	jle    800bbf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ba2:	00 
  800ba3:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800baa:	00 
  800bab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb2:	00 
  800bb3:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800bba:	e8 b1 f5 ff ff       	call   800170 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbf:	83 c4 2c             	add    $0x2c,%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd7:	89 d1                	mov    %edx,%ecx
  800bd9:	89 d3                	mov    %edx,%ebx
  800bdb:	89 d7                	mov    %edx,%edi
  800bdd:	89 d6                	mov    %edx,%esi
  800bdf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_yield>:

void
sys_yield(void)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf6:	89 d1                	mov    %edx,%ecx
  800bf8:	89 d3                	mov    %edx,%ebx
  800bfa:	89 d7                	mov    %edx,%edi
  800bfc:	89 d6                	mov    %edx,%esi
  800bfe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0e:	be 00 00 00 00       	mov    $0x0,%esi
  800c13:	b8 04 00 00 00       	mov    $0x4,%eax
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 f7                	mov    %esi,%edi
  800c23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 28                	jle    800c51 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c34:	00 
  800c35:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800c3c:	00 
  800c3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c44:	00 
  800c45:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800c4c:	e8 1f f5 ff ff       	call   800170 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c51:	83 c4 2c             	add    $0x2c,%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	b8 05 00 00 00       	mov    $0x5,%eax
  800c67:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	7e 28                	jle    800ca4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c80:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c87:	00 
  800c88:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800c8f:	00 
  800c90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c97:	00 
  800c98:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800c9f:	e8 cc f4 ff ff       	call   800170 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca4:	83 c4 2c             	add    $0x2c,%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	89 df                	mov    %ebx,%edi
  800cc7:	89 de                	mov    %ebx,%esi
  800cc9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 28                	jle    800cf7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cda:	00 
  800cdb:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cea:	00 
  800ceb:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800cf2:	e8 79 f4 ff ff       	call   800170 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf7:	83 c4 2c             	add    $0x2c,%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	89 df                	mov    %ebx,%edi
  800d1a:	89 de                	mov    %ebx,%esi
  800d1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7e 28                	jle    800d4a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d26:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d2d:	00 
  800d2e:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800d35:	00 
  800d36:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3d:	00 
  800d3e:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800d45:	e8 26 f4 ff ff       	call   800170 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4a:	83 c4 2c             	add    $0x2c,%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d60:	b8 09 00 00 00       	mov    $0x9,%eax
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	89 df                	mov    %ebx,%edi
  800d6d:	89 de                	mov    %ebx,%esi
  800d6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7e 28                	jle    800d9d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d75:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d79:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d80:	00 
  800d81:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800d88:	00 
  800d89:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d90:	00 
  800d91:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800d98:	e8 d3 f3 ff ff       	call   800170 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d9d:	83 c4 2c             	add    $0x2c,%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	7e 28                	jle    800df0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800ddb:	00 
  800ddc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de3:	00 
  800de4:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800deb:	e8 80 f3 ff ff       	call   800170 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df0:	83 c4 2c             	add    $0x2c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    

00800df8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	be 00 00 00 00       	mov    $0x0,%esi
  800e03:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	8b 55 08             	mov    0x8(%ebp),%edx
  800e14:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e29:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e31:	89 cb                	mov    %ecx,%ebx
  800e33:	89 cf                	mov    %ecx,%edi
  800e35:	89 ce                	mov    %ecx,%esi
  800e37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	7e 28                	jle    800e65 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e41:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e48:	00 
  800e49:	c7 44 24 08 1f 24 80 	movl   $0x80241f,0x8(%esp)
  800e50:	00 
  800e51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e58:	00 
  800e59:	c7 04 24 3c 24 80 00 	movl   $0x80243c,(%esp)
  800e60:	e8 0b f3 ff ff       	call   800170 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e65:	83 c4 2c             	add    $0x2c,%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    
  800e6d:	00 00                	add    %al,(%eax)
	...

00800e70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	05 00 00 00 30       	add    $0x30000000,%eax
  800e7b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	89 04 24             	mov    %eax,(%esp)
  800e8c:	e8 df ff ff ff       	call   800e70 <fd2num>
  800e91:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e96:	c1 e0 0c             	shl    $0xc,%eax
}
  800e99:	c9                   	leave  
  800e9a:	c3                   	ret    

00800e9b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	53                   	push   %ebx
  800e9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ea2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ea7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	c1 ea 16             	shr    $0x16,%edx
  800eae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb5:	f6 c2 01             	test   $0x1,%dl
  800eb8:	74 11                	je     800ecb <fd_alloc+0x30>
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	c1 ea 0c             	shr    $0xc,%edx
  800ebf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec6:	f6 c2 01             	test   $0x1,%dl
  800ec9:	75 09                	jne    800ed4 <fd_alloc+0x39>
			*fd_store = fd;
  800ecb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed2:	eb 17                	jmp    800eeb <fd_alloc+0x50>
  800ed4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ed9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ede:	75 c7                	jne    800ea7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ee0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800ee6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eeb:	5b                   	pop    %ebx
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ef4:	83 f8 1f             	cmp    $0x1f,%eax
  800ef7:	77 36                	ja     800f2f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ef9:	05 00 00 0d 00       	add    $0xd0000,%eax
  800efe:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f01:	89 c2                	mov    %eax,%edx
  800f03:	c1 ea 16             	shr    $0x16,%edx
  800f06:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0d:	f6 c2 01             	test   $0x1,%dl
  800f10:	74 24                	je     800f36 <fd_lookup+0x48>
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	c1 ea 0c             	shr    $0xc,%edx
  800f17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1e:	f6 c2 01             	test   $0x1,%dl
  800f21:	74 1a                	je     800f3d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f26:	89 02                	mov    %eax,(%edx)
	return 0;
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2d:	eb 13                	jmp    800f42 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f34:	eb 0c                	jmp    800f42 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3b:	eb 05                	jmp    800f42 <fd_lookup+0x54>
  800f3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	53                   	push   %ebx
  800f48:	83 ec 14             	sub    $0x14,%esp
  800f4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800f51:	ba 00 00 00 00       	mov    $0x0,%edx
  800f56:	eb 0e                	jmp    800f66 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800f58:	39 08                	cmp    %ecx,(%eax)
  800f5a:	75 09                	jne    800f65 <dev_lookup+0x21>
			*dev = devtab[i];
  800f5c:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f63:	eb 35                	jmp    800f9a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f65:	42                   	inc    %edx
  800f66:	8b 04 95 cc 24 80 00 	mov    0x8024cc(,%edx,4),%eax
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	75 e7                	jne    800f58 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f71:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800f76:	8b 00                	mov    (%eax),%eax
  800f78:	8b 40 48             	mov    0x48(%eax),%eax
  800f7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f83:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
  800f8a:	e8 d9 f2 ff ff       	call   800268 <cprintf>
	*dev = 0;
  800f8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f9a:	83 c4 14             	add    $0x14,%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 30             	sub    $0x30,%esp
  800fa8:	8b 75 08             	mov    0x8(%ebp),%esi
  800fab:	8a 45 0c             	mov    0xc(%ebp),%al
  800fae:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb1:	89 34 24             	mov    %esi,(%esp)
  800fb4:	e8 b7 fe ff ff       	call   800e70 <fd2num>
  800fb9:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fbc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc0:	89 04 24             	mov    %eax,(%esp)
  800fc3:	e8 26 ff ff ff       	call   800eee <fd_lookup>
  800fc8:	89 c3                	mov    %eax,%ebx
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	78 05                	js     800fd3 <fd_close+0x33>
	    || fd != fd2)
  800fce:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd1:	74 0d                	je     800fe0 <fd_close+0x40>
		return (must_exist ? r : 0);
  800fd3:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fd7:	75 46                	jne    80101f <fd_close+0x7f>
  800fd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fde:	eb 3f                	jmp    80101f <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe7:	8b 06                	mov    (%esi),%eax
  800fe9:	89 04 24             	mov    %eax,(%esp)
  800fec:	e8 53 ff ff ff       	call   800f44 <dev_lookup>
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 18                	js     80100f <fd_close+0x6f>
		if (dev->dev_close)
  800ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffa:	8b 40 10             	mov    0x10(%eax),%eax
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	74 09                	je     80100a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801001:	89 34 24             	mov    %esi,(%esp)
  801004:	ff d0                	call   *%eax
  801006:	89 c3                	mov    %eax,%ebx
  801008:	eb 05                	jmp    80100f <fd_close+0x6f>
		else
			r = 0;
  80100a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80100f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801013:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101a:	e8 8d fc ff ff       	call   800cac <sys_page_unmap>
	return r;
}
  80101f:	89 d8                	mov    %ebx,%eax
  801021:	83 c4 30             	add    $0x30,%esp
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80102e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801031:	89 44 24 04          	mov    %eax,0x4(%esp)
  801035:	8b 45 08             	mov    0x8(%ebp),%eax
  801038:	89 04 24             	mov    %eax,(%esp)
  80103b:	e8 ae fe ff ff       	call   800eee <fd_lookup>
  801040:	85 c0                	test   %eax,%eax
  801042:	78 13                	js     801057 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801044:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80104b:	00 
  80104c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104f:	89 04 24             	mov    %eax,(%esp)
  801052:	e8 49 ff ff ff       	call   800fa0 <fd_close>
}
  801057:	c9                   	leave  
  801058:	c3                   	ret    

00801059 <close_all>:

void
close_all(void)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	53                   	push   %ebx
  80105d:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801060:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801065:	89 1c 24             	mov    %ebx,(%esp)
  801068:	e8 bb ff ff ff       	call   801028 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80106d:	43                   	inc    %ebx
  80106e:	83 fb 20             	cmp    $0x20,%ebx
  801071:	75 f2                	jne    801065 <close_all+0xc>
		close(i);
}
  801073:	83 c4 14             	add    $0x14,%esp
  801076:	5b                   	pop    %ebx
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 4c             	sub    $0x4c,%esp
  801082:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801085:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	89 04 24             	mov    %eax,(%esp)
  801092:	e8 57 fe ff ff       	call   800eee <fd_lookup>
  801097:	89 c3                	mov    %eax,%ebx
  801099:	85 c0                	test   %eax,%eax
  80109b:	0f 88 e1 00 00 00    	js     801182 <dup+0x109>
		return r;
	close(newfdnum);
  8010a1:	89 3c 24             	mov    %edi,(%esp)
  8010a4:	e8 7f ff ff ff       	call   801028 <close>

	newfd = INDEX2FD(newfdnum);
  8010a9:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010af:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b5:	89 04 24             	mov    %eax,(%esp)
  8010b8:	e8 c3 fd ff ff       	call   800e80 <fd2data>
  8010bd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010bf:	89 34 24             	mov    %esi,(%esp)
  8010c2:	e8 b9 fd ff ff       	call   800e80 <fd2data>
  8010c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ca:	89 d8                	mov    %ebx,%eax
  8010cc:	c1 e8 16             	shr    $0x16,%eax
  8010cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d6:	a8 01                	test   $0x1,%al
  8010d8:	74 46                	je     801120 <dup+0xa7>
  8010da:	89 d8                	mov    %ebx,%eax
  8010dc:	c1 e8 0c             	shr    $0xc,%eax
  8010df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e6:	f6 c2 01             	test   $0x1,%dl
  8010e9:	74 35                	je     801120 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801102:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801109:	00 
  80110a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80110e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801115:	e8 3f fb ff ff       	call   800c59 <sys_page_map>
  80111a:	89 c3                	mov    %eax,%ebx
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 3b                	js     80115b <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801120:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801123:	89 c2                	mov    %eax,%edx
  801125:	c1 ea 0c             	shr    $0xc,%edx
  801128:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801135:	89 54 24 10          	mov    %edx,0x10(%esp)
  801139:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80113d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801144:	00 
  801145:	89 44 24 04          	mov    %eax,0x4(%esp)
  801149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801150:	e8 04 fb ff ff       	call   800c59 <sys_page_map>
  801155:	89 c3                	mov    %eax,%ebx
  801157:	85 c0                	test   %eax,%eax
  801159:	79 25                	jns    801180 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80115b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80115f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801166:	e8 41 fb ff ff       	call   800cac <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80116e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801172:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801179:	e8 2e fb ff ff       	call   800cac <sys_page_unmap>
	return r;
  80117e:	eb 02                	jmp    801182 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801180:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801182:	89 d8                	mov    %ebx,%eax
  801184:	83 c4 4c             	add    $0x4c,%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	53                   	push   %ebx
  801190:	83 ec 24             	sub    $0x24,%esp
  801193:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801196:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119d:	89 1c 24             	mov    %ebx,(%esp)
  8011a0:	e8 49 fd ff ff       	call   800eee <fd_lookup>
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 6f                	js     801218 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b3:	8b 00                	mov    (%eax),%eax
  8011b5:	89 04 24             	mov    %eax,(%esp)
  8011b8:	e8 87 fd ff ff       	call   800f44 <dev_lookup>
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 57                	js     801218 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	8b 50 08             	mov    0x8(%eax),%edx
  8011c7:	83 e2 03             	and    $0x3,%edx
  8011ca:	83 fa 01             	cmp    $0x1,%edx
  8011cd:	75 25                	jne    8011f4 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cf:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011d4:	8b 00                	mov    (%eax),%eax
  8011d6:	8b 40 48             	mov    0x48(%eax),%eax
  8011d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e1:	c7 04 24 90 24 80 00 	movl   $0x802490,(%esp)
  8011e8:	e8 7b f0 ff ff       	call   800268 <cprintf>
		return -E_INVAL;
  8011ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f2:	eb 24                	jmp    801218 <read+0x8c>
	}
	if (!dev->dev_read)
  8011f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f7:	8b 52 08             	mov    0x8(%edx),%edx
  8011fa:	85 d2                	test   %edx,%edx
  8011fc:	74 15                	je     801213 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801201:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801205:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801208:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80120c:	89 04 24             	mov    %eax,(%esp)
  80120f:	ff d2                	call   *%edx
  801211:	eb 05                	jmp    801218 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801213:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801218:	83 c4 24             	add    $0x24,%esp
  80121b:	5b                   	pop    %ebx
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 1c             	sub    $0x1c,%esp
  801227:	8b 7d 08             	mov    0x8(%ebp),%edi
  80122a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801232:	eb 23                	jmp    801257 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801234:	89 f0                	mov    %esi,%eax
  801236:	29 d8                	sub    %ebx,%eax
  801238:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123f:	01 d8                	add    %ebx,%eax
  801241:	89 44 24 04          	mov    %eax,0x4(%esp)
  801245:	89 3c 24             	mov    %edi,(%esp)
  801248:	e8 3f ff ff ff       	call   80118c <read>
		if (m < 0)
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 10                	js     801261 <readn+0x43>
			return m;
		if (m == 0)
  801251:	85 c0                	test   %eax,%eax
  801253:	74 0a                	je     80125f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801255:	01 c3                	add    %eax,%ebx
  801257:	39 f3                	cmp    %esi,%ebx
  801259:	72 d9                	jb     801234 <readn+0x16>
  80125b:	89 d8                	mov    %ebx,%eax
  80125d:	eb 02                	jmp    801261 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80125f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801261:	83 c4 1c             	add    $0x1c,%esp
  801264:	5b                   	pop    %ebx
  801265:	5e                   	pop    %esi
  801266:	5f                   	pop    %edi
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	53                   	push   %ebx
  80126d:	83 ec 24             	sub    $0x24,%esp
  801270:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801273:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801276:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127a:	89 1c 24             	mov    %ebx,(%esp)
  80127d:	e8 6c fc ff ff       	call   800eee <fd_lookup>
  801282:	85 c0                	test   %eax,%eax
  801284:	78 6a                	js     8012f0 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801286:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801289:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801290:	8b 00                	mov    (%eax),%eax
  801292:	89 04 24             	mov    %eax,(%esp)
  801295:	e8 aa fc ff ff       	call   800f44 <dev_lookup>
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 52                	js     8012f0 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a5:	75 25                	jne    8012cc <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a7:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8012ac:	8b 00                	mov    (%eax),%eax
  8012ae:	8b 40 48             	mov    0x48(%eax),%eax
  8012b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b9:	c7 04 24 ac 24 80 00 	movl   $0x8024ac,(%esp)
  8012c0:	e8 a3 ef ff ff       	call   800268 <cprintf>
		return -E_INVAL;
  8012c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ca:	eb 24                	jmp    8012f0 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8012d2:	85 d2                	test   %edx,%edx
  8012d4:	74 15                	je     8012eb <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012e4:	89 04 24             	mov    %eax,(%esp)
  8012e7:	ff d2                	call   *%edx
  8012e9:	eb 05                	jmp    8012f0 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012f0:	83 c4 24             	add    $0x24,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801303:	8b 45 08             	mov    0x8(%ebp),%eax
  801306:	89 04 24             	mov    %eax,(%esp)
  801309:	e8 e0 fb ff ff       	call   800eee <fd_lookup>
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 0e                	js     801320 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801312:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801315:	8b 55 0c             	mov    0xc(%ebp),%edx
  801318:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	53                   	push   %ebx
  801326:	83 ec 24             	sub    $0x24,%esp
  801329:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801333:	89 1c 24             	mov    %ebx,(%esp)
  801336:	e8 b3 fb ff ff       	call   800eee <fd_lookup>
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 63                	js     8013a2 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
  801346:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801349:	8b 00                	mov    (%eax),%eax
  80134b:	89 04 24             	mov    %eax,(%esp)
  80134e:	e8 f1 fb ff ff       	call   800f44 <dev_lookup>
  801353:	85 c0                	test   %eax,%eax
  801355:	78 4b                	js     8013a2 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801357:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80135e:	75 25                	jne    801385 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801360:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801365:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801367:	8b 40 48             	mov    0x48(%eax),%eax
  80136a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80136e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801372:	c7 04 24 6c 24 80 00 	movl   $0x80246c,(%esp)
  801379:	e8 ea ee ff ff       	call   800268 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80137e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801383:	eb 1d                	jmp    8013a2 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801385:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801388:	8b 52 18             	mov    0x18(%edx),%edx
  80138b:	85 d2                	test   %edx,%edx
  80138d:	74 0e                	je     80139d <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80138f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801392:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801396:	89 04 24             	mov    %eax,(%esp)
  801399:	ff d2                	call   *%edx
  80139b:	eb 05                	jmp    8013a2 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80139d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013a2:	83 c4 24             	add    $0x24,%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 24             	sub    $0x24,%esp
  8013af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bc:	89 04 24             	mov    %eax,(%esp)
  8013bf:	e8 2a fb ff ff       	call   800eee <fd_lookup>
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	78 52                	js     80141a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d2:	8b 00                	mov    (%eax),%eax
  8013d4:	89 04 24             	mov    %eax,(%esp)
  8013d7:	e8 68 fb ff ff       	call   800f44 <dev_lookup>
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	78 3a                	js     80141a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8013e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e7:	74 2c                	je     801415 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013f3:	00 00 00 
	stat->st_isdir = 0;
  8013f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013fd:	00 00 00 
	stat->st_dev = dev;
  801400:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801406:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80140a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80140d:	89 14 24             	mov    %edx,(%esp)
  801410:	ff 50 14             	call   *0x14(%eax)
  801413:	eb 05                	jmp    80141a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801415:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80141a:	83 c4 24             	add    $0x24,%esp
  80141d:	5b                   	pop    %ebx
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	56                   	push   %esi
  801424:	53                   	push   %ebx
  801425:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801428:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80142f:	00 
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	89 04 24             	mov    %eax,(%esp)
  801436:	e8 88 02 00 00       	call   8016c3 <open>
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 1b                	js     80145c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801441:	8b 45 0c             	mov    0xc(%ebp),%eax
  801444:	89 44 24 04          	mov    %eax,0x4(%esp)
  801448:	89 1c 24             	mov    %ebx,(%esp)
  80144b:	e8 58 ff ff ff       	call   8013a8 <fstat>
  801450:	89 c6                	mov    %eax,%esi
	close(fd);
  801452:	89 1c 24             	mov    %ebx,(%esp)
  801455:	e8 ce fb ff ff       	call   801028 <close>
	return r;
  80145a:	89 f3                	mov    %esi,%ebx
}
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	5b                   	pop    %ebx
  801462:	5e                   	pop    %esi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    
  801465:	00 00                	add    %al,(%eax)
	...

00801468 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	56                   	push   %esi
  80146c:	53                   	push   %ebx
  80146d:	83 ec 10             	sub    $0x10,%esp
  801470:	89 c3                	mov    %eax,%ebx
  801472:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801474:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80147b:	75 11                	jne    80148e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80147d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801484:	e8 ca 08 00 00       	call   801d53 <ipc_find_env>
  801489:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80148e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801495:	00 
  801496:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  80149d:	00 
  80149e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014a2:	a1 00 40 80 00       	mov    0x804000,%eax
  8014a7:	89 04 24             	mov    %eax,(%esp)
  8014aa:	e8 3e 08 00 00       	call   801ced <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  8014af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b6:	00 
  8014b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c2:	e8 b9 07 00 00       	call   801c80 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	5b                   	pop    %ebx
  8014cb:	5e                   	pop    %esi
  8014cc:	5d                   	pop    %ebp
  8014cd:	c3                   	ret    

008014ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8014da:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8014df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e2:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8014f1:	e8 72 ff ff ff       	call   801468 <fsipc>
}
  8014f6:	c9                   	leave  
  8014f7:	c3                   	ret    

008014f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801501:	8b 40 0c             	mov    0xc(%eax),%eax
  801504:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801509:	ba 00 00 00 00       	mov    $0x0,%edx
  80150e:	b8 06 00 00 00       	mov    $0x6,%eax
  801513:	e8 50 ff ff ff       	call   801468 <fsipc>
}
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	53                   	push   %ebx
  80151e:	83 ec 14             	sub    $0x14,%esp
  801521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801524:	8b 45 08             	mov    0x8(%ebp),%eax
  801527:	8b 40 0c             	mov    0xc(%eax),%eax
  80152a:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80152f:	ba 00 00 00 00       	mov    $0x0,%edx
  801534:	b8 05 00 00 00       	mov    $0x5,%eax
  801539:	e8 2a ff ff ff       	call   801468 <fsipc>
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 2b                	js     80156d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801542:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801549:	00 
  80154a:	89 1c 24             	mov    %ebx,(%esp)
  80154d:	e8 c1 f2 ff ff       	call   800813 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801552:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801557:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80155d:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801562:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801568:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80156d:	83 c4 14             	add    $0x14,%esp
  801570:	5b                   	pop    %ebx
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 14             	sub    $0x14,%esp
  80157a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80157d:	8b 45 08             	mov    0x8(%ebp),%eax
  801580:	8b 40 0c             	mov    0xc(%eax),%eax
  801583:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801588:	89 d8                	mov    %ebx,%eax
  80158a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801590:	76 05                	jbe    801597 <devfile_write+0x24>
  801592:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801597:	a3 04 50 c0 00       	mov    %eax,0xc05004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  80159c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a7:	c7 04 24 08 50 c0 00 	movl   $0xc05008,(%esp)
  8015ae:	e8 43 f4 ff ff       	call   8009f6 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  8015b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8015bd:	e8 a6 fe ff ff       	call   801468 <fsipc>
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 53                	js     801619 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  8015c6:	39 c3                	cmp    %eax,%ebx
  8015c8:	73 24                	jae    8015ee <devfile_write+0x7b>
  8015ca:	c7 44 24 0c dc 24 80 	movl   $0x8024dc,0xc(%esp)
  8015d1:	00 
  8015d2:	c7 44 24 08 e3 24 80 	movl   $0x8024e3,0x8(%esp)
  8015d9:	00 
  8015da:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8015e1:	00 
  8015e2:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  8015e9:	e8 82 eb ff ff       	call   800170 <_panic>
	assert(r <= PGSIZE);
  8015ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015f3:	7e 24                	jle    801619 <devfile_write+0xa6>
  8015f5:	c7 44 24 0c 03 25 80 	movl   $0x802503,0xc(%esp)
  8015fc:	00 
  8015fd:	c7 44 24 08 e3 24 80 	movl   $0x8024e3,0x8(%esp)
  801604:	00 
  801605:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  80160c:	00 
  80160d:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  801614:	e8 57 eb ff ff       	call   800170 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801619:	83 c4 14             	add    $0x14,%esp
  80161c:	5b                   	pop    %ebx
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	83 ec 10             	sub    $0x10,%esp
  801627:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80162a:	8b 45 08             	mov    0x8(%ebp),%eax
  80162d:	8b 40 0c             	mov    0xc(%eax),%eax
  801630:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  801635:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80163b:	ba 00 00 00 00       	mov    $0x0,%edx
  801640:	b8 03 00 00 00       	mov    $0x3,%eax
  801645:	e8 1e fe ff ff       	call   801468 <fsipc>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 6a                	js     8016ba <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801650:	39 c6                	cmp    %eax,%esi
  801652:	73 24                	jae    801678 <devfile_read+0x59>
  801654:	c7 44 24 0c dc 24 80 	movl   $0x8024dc,0xc(%esp)
  80165b:	00 
  80165c:	c7 44 24 08 e3 24 80 	movl   $0x8024e3,0x8(%esp)
  801663:	00 
  801664:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  80166b:	00 
  80166c:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  801673:	e8 f8 ea ff ff       	call   800170 <_panic>
	assert(r <= PGSIZE);
  801678:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80167d:	7e 24                	jle    8016a3 <devfile_read+0x84>
  80167f:	c7 44 24 0c 03 25 80 	movl   $0x802503,0xc(%esp)
  801686:	00 
  801687:	c7 44 24 08 e3 24 80 	movl   $0x8024e3,0x8(%esp)
  80168e:	00 
  80168f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801696:	00 
  801697:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  80169e:	e8 cd ea ff ff       	call   800170 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8016a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016a7:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  8016ae:	00 
  8016af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b2:	89 04 24             	mov    %eax,(%esp)
  8016b5:	e8 d2 f2 ff ff       	call   80098c <memmove>
	return r;
}
  8016ba:	89 d8                	mov    %ebx,%eax
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	5b                   	pop    %ebx
  8016c0:	5e                   	pop    %esi
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 20             	sub    $0x20,%esp
  8016cb:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016ce:	89 34 24             	mov    %esi,(%esp)
  8016d1:	e8 0a f1 ff ff       	call   8007e0 <strlen>
  8016d6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016db:	7f 60                	jg     80173d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e0:	89 04 24             	mov    %eax,(%esp)
  8016e3:	e8 b3 f7 ff ff       	call   800e9b <fd_alloc>
  8016e8:	89 c3                	mov    %eax,%ebx
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 54                	js     801742 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016f2:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  8016f9:	e8 15 f1 ff ff       	call   800813 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801701:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801706:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801709:	b8 01 00 00 00       	mov    $0x1,%eax
  80170e:	e8 55 fd ff ff       	call   801468 <fsipc>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	85 c0                	test   %eax,%eax
  801717:	79 15                	jns    80172e <open+0x6b>
		fd_close(fd, 0);
  801719:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801720:	00 
  801721:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801724:	89 04 24             	mov    %eax,(%esp)
  801727:	e8 74 f8 ff ff       	call   800fa0 <fd_close>
		return r;
  80172c:	eb 14                	jmp    801742 <open+0x7f>
	}

	return fd2num(fd);
  80172e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801731:	89 04 24             	mov    %eax,(%esp)
  801734:	e8 37 f7 ff ff       	call   800e70 <fd2num>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	eb 05                	jmp    801742 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80173d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801742:	89 d8                	mov    %ebx,%eax
  801744:	83 c4 20             	add    $0x20,%esp
  801747:	5b                   	pop    %ebx
  801748:	5e                   	pop    %esi
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801751:	ba 00 00 00 00       	mov    $0x0,%edx
  801756:	b8 08 00 00 00       	mov    $0x8,%eax
  80175b:	e8 08 fd ff ff       	call   801468 <fsipc>
}
  801760:	c9                   	leave  
  801761:	c3                   	ret    
	...

00801764 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	83 ec 10             	sub    $0x10,%esp
  80176c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80176f:	8b 45 08             	mov    0x8(%ebp),%eax
  801772:	89 04 24             	mov    %eax,(%esp)
  801775:	e8 06 f7 ff ff       	call   800e80 <fd2data>
  80177a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80177c:	c7 44 24 04 0f 25 80 	movl   $0x80250f,0x4(%esp)
  801783:	00 
  801784:	89 34 24             	mov    %esi,(%esp)
  801787:	e8 87 f0 ff ff       	call   800813 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80178c:	8b 43 04             	mov    0x4(%ebx),%eax
  80178f:	2b 03                	sub    (%ebx),%eax
  801791:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801797:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80179e:	00 00 00 
	stat->st_dev = &devpipe;
  8017a1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8017a8:	30 80 00 
	return 0;
}
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 14             	sub    $0x14,%esp
  8017be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017cc:	e8 db f4 ff ff       	call   800cac <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017d1:	89 1c 24             	mov    %ebx,(%esp)
  8017d4:	e8 a7 f6 ff ff       	call   800e80 <fd2data>
  8017d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e4:	e8 c3 f4 ff ff       	call   800cac <sys_page_unmap>
}
  8017e9:	83 c4 14             	add    $0x14,%esp
  8017ec:	5b                   	pop    %ebx
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	57                   	push   %edi
  8017f3:	56                   	push   %esi
  8017f4:	53                   	push   %ebx
  8017f5:	83 ec 2c             	sub    $0x2c,%esp
  8017f8:	89 c7                	mov    %eax,%edi
  8017fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017fd:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801802:	8b 00                	mov    (%eax),%eax
  801804:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801807:	89 3c 24             	mov    %edi,(%esp)
  80180a:	e8 89 05 00 00       	call   801d98 <pageref>
  80180f:	89 c6                	mov    %eax,%esi
  801811:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801814:	89 04 24             	mov    %eax,(%esp)
  801817:	e8 7c 05 00 00       	call   801d98 <pageref>
  80181c:	39 c6                	cmp    %eax,%esi
  80181e:	0f 94 c0             	sete   %al
  801821:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801824:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  80182a:	8b 12                	mov    (%edx),%edx
  80182c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80182f:	39 cb                	cmp    %ecx,%ebx
  801831:	75 08                	jne    80183b <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801833:	83 c4 2c             	add    $0x2c,%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5f                   	pop    %edi
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80183b:	83 f8 01             	cmp    $0x1,%eax
  80183e:	75 bd                	jne    8017fd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801840:	8b 42 58             	mov    0x58(%edx),%eax
  801843:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80184a:	00 
  80184b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80184f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801853:	c7 04 24 16 25 80 00 	movl   $0x802516,(%esp)
  80185a:	e8 09 ea ff ff       	call   800268 <cprintf>
  80185f:	eb 9c                	jmp    8017fd <_pipeisclosed+0xe>

00801861 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	57                   	push   %edi
  801865:	56                   	push   %esi
  801866:	53                   	push   %ebx
  801867:	83 ec 1c             	sub    $0x1c,%esp
  80186a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80186d:	89 34 24             	mov    %esi,(%esp)
  801870:	e8 0b f6 ff ff       	call   800e80 <fd2data>
  801875:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801877:	bf 00 00 00 00       	mov    $0x0,%edi
  80187c:	eb 3c                	jmp    8018ba <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80187e:	89 da                	mov    %ebx,%edx
  801880:	89 f0                	mov    %esi,%eax
  801882:	e8 68 ff ff ff       	call   8017ef <_pipeisclosed>
  801887:	85 c0                	test   %eax,%eax
  801889:	75 38                	jne    8018c3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80188b:	e8 56 f3 ff ff       	call   800be6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801890:	8b 43 04             	mov    0x4(%ebx),%eax
  801893:	8b 13                	mov    (%ebx),%edx
  801895:	83 c2 20             	add    $0x20,%edx
  801898:	39 d0                	cmp    %edx,%eax
  80189a:	73 e2                	jae    80187e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80189c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8018a2:	89 c2                	mov    %eax,%edx
  8018a4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8018aa:	79 05                	jns    8018b1 <devpipe_write+0x50>
  8018ac:	4a                   	dec    %edx
  8018ad:	83 ca e0             	or     $0xffffffe0,%edx
  8018b0:	42                   	inc    %edx
  8018b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018b5:	40                   	inc    %eax
  8018b6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018b9:	47                   	inc    %edi
  8018ba:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018bd:	75 d1                	jne    801890 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018bf:	89 f8                	mov    %edi,%eax
  8018c1:	eb 05                	jmp    8018c8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018c3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018c8:	83 c4 1c             	add    $0x1c,%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5f                   	pop    %edi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	57                   	push   %edi
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 1c             	sub    $0x1c,%esp
  8018d9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018dc:	89 3c 24             	mov    %edi,(%esp)
  8018df:	e8 9c f5 ff ff       	call   800e80 <fd2data>
  8018e4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e6:	be 00 00 00 00       	mov    $0x0,%esi
  8018eb:	eb 3a                	jmp    801927 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018ed:	85 f6                	test   %esi,%esi
  8018ef:	74 04                	je     8018f5 <devpipe_read+0x25>
				return i;
  8018f1:	89 f0                	mov    %esi,%eax
  8018f3:	eb 40                	jmp    801935 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018f5:	89 da                	mov    %ebx,%edx
  8018f7:	89 f8                	mov    %edi,%eax
  8018f9:	e8 f1 fe ff ff       	call   8017ef <_pipeisclosed>
  8018fe:	85 c0                	test   %eax,%eax
  801900:	75 2e                	jne    801930 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801902:	e8 df f2 ff ff       	call   800be6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801907:	8b 03                	mov    (%ebx),%eax
  801909:	3b 43 04             	cmp    0x4(%ebx),%eax
  80190c:	74 df                	je     8018ed <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80190e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801913:	79 05                	jns    80191a <devpipe_read+0x4a>
  801915:	48                   	dec    %eax
  801916:	83 c8 e0             	or     $0xffffffe0,%eax
  801919:	40                   	inc    %eax
  80191a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80191e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801921:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801924:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801926:	46                   	inc    %esi
  801927:	3b 75 10             	cmp    0x10(%ebp),%esi
  80192a:	75 db                	jne    801907 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80192c:	89 f0                	mov    %esi,%eax
  80192e:	eb 05                	jmp    801935 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801930:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801935:	83 c4 1c             	add    $0x1c,%esp
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5f                   	pop    %edi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    

0080193d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	57                   	push   %edi
  801941:	56                   	push   %esi
  801942:	53                   	push   %ebx
  801943:	83 ec 3c             	sub    $0x3c,%esp
  801946:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801949:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80194c:	89 04 24             	mov    %eax,(%esp)
  80194f:	e8 47 f5 ff ff       	call   800e9b <fd_alloc>
  801954:	89 c3                	mov    %eax,%ebx
  801956:	85 c0                	test   %eax,%eax
  801958:	0f 88 45 01 00 00    	js     801aa3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80195e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801965:	00 
  801966:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801974:	e8 8c f2 ff ff       	call   800c05 <sys_page_alloc>
  801979:	89 c3                	mov    %eax,%ebx
  80197b:	85 c0                	test   %eax,%eax
  80197d:	0f 88 20 01 00 00    	js     801aa3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801983:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801986:	89 04 24             	mov    %eax,(%esp)
  801989:	e8 0d f5 ff ff       	call   800e9b <fd_alloc>
  80198e:	89 c3                	mov    %eax,%ebx
  801990:	85 c0                	test   %eax,%eax
  801992:	0f 88 f8 00 00 00    	js     801a90 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801998:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80199f:	00 
  8019a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ae:	e8 52 f2 ff ff       	call   800c05 <sys_page_alloc>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	0f 88 d3 00 00 00    	js     801a90 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c0:	89 04 24             	mov    %eax,(%esp)
  8019c3:	e8 b8 f4 ff ff       	call   800e80 <fd2data>
  8019c8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019ca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019d1:	00 
  8019d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019dd:	e8 23 f2 ff ff       	call   800c05 <sys_page_alloc>
  8019e2:	89 c3                	mov    %eax,%ebx
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	0f 88 91 00 00 00    	js     801a7d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019ef:	89 04 24             	mov    %eax,(%esp)
  8019f2:	e8 89 f4 ff ff       	call   800e80 <fd2data>
  8019f7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8019fe:	00 
  8019ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a0a:	00 
  801a0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a16:	e8 3e f2 ff ff       	call   800c59 <sys_page_map>
  801a1b:	89 c3                	mov    %eax,%ebx
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 4c                	js     801a6d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a21:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a2a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a2f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a36:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a3f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a41:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a44:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a4e:	89 04 24             	mov    %eax,(%esp)
  801a51:	e8 1a f4 ff ff       	call   800e70 <fd2num>
  801a56:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a5b:	89 04 24             	mov    %eax,(%esp)
  801a5e:	e8 0d f4 ff ff       	call   800e70 <fd2num>
  801a63:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a66:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a6b:	eb 36                	jmp    801aa3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801a6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a78:	e8 2f f2 ff ff       	call   800cac <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801a7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a8b:	e8 1c f2 ff ff       	call   800cac <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801a90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a9e:	e8 09 f2 ff ff       	call   800cac <sys_page_unmap>
    err:
	return r;
}
  801aa3:	89 d8                	mov    %ebx,%eax
  801aa5:	83 c4 3c             	add    $0x3c,%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5f                   	pop    %edi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ab3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aba:	8b 45 08             	mov    0x8(%ebp),%eax
  801abd:	89 04 24             	mov    %eax,(%esp)
  801ac0:	e8 29 f4 ff ff       	call   800eee <fd_lookup>
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 15                	js     801ade <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 ac f3 ff ff       	call   800e80 <fd2data>
	return _pipeisclosed(fd, p);
  801ad4:	89 c2                	mov    %eax,%edx
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	e8 11 fd ff ff       	call   8017ef <_pipeisclosed>
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801af0:	c7 44 24 04 2e 25 80 	movl   $0x80252e,0x4(%esp)
  801af7:	00 
  801af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afb:	89 04 24             	mov    %eax,(%esp)
  801afe:	e8 10 ed ff ff       	call   800813 <strcpy>
	return 0;
}
  801b03:	b8 00 00 00 00       	mov    $0x0,%eax
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	57                   	push   %edi
  801b0e:	56                   	push   %esi
  801b0f:	53                   	push   %ebx
  801b10:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b16:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b1b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b21:	eb 30                	jmp    801b53 <devcons_write+0x49>
		m = n - tot;
  801b23:	8b 75 10             	mov    0x10(%ebp),%esi
  801b26:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801b28:	83 fe 7f             	cmp    $0x7f,%esi
  801b2b:	76 05                	jbe    801b32 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801b2d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b32:	89 74 24 08          	mov    %esi,0x8(%esp)
  801b36:	03 45 0c             	add    0xc(%ebp),%eax
  801b39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3d:	89 3c 24             	mov    %edi,(%esp)
  801b40:	e8 47 ee ff ff       	call   80098c <memmove>
		sys_cputs(buf, m);
  801b45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b49:	89 3c 24             	mov    %edi,(%esp)
  801b4c:	e8 e7 ef ff ff       	call   800b38 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b51:	01 f3                	add    %esi,%ebx
  801b53:	89 d8                	mov    %ebx,%eax
  801b55:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b58:	72 c9                	jb     801b23 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b5a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5f                   	pop    %edi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b6f:	75 07                	jne    801b78 <devcons_read+0x13>
  801b71:	eb 25                	jmp    801b98 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b73:	e8 6e f0 ff ff       	call   800be6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b78:	e8 d9 ef ff ff       	call   800b56 <sys_cgetc>
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	74 f2                	je     801b73 <devcons_read+0xe>
  801b81:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 1d                	js     801ba4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b87:	83 f8 04             	cmp    $0x4,%eax
  801b8a:	74 13                	je     801b9f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8f:	88 10                	mov    %dl,(%eax)
	return 1;
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	eb 0c                	jmp    801ba4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b98:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9d:	eb 05                	jmp    801ba4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b9f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801bac:	8b 45 08             	mov    0x8(%ebp),%eax
  801baf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bb2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bb9:	00 
  801bba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bbd:	89 04 24             	mov    %eax,(%esp)
  801bc0:	e8 73 ef ff ff       	call   800b38 <sys_cputs>
}
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <getchar>:

int
getchar(void)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bcd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801bd4:	00 
  801bd5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be3:	e8 a4 f5 ff ff       	call   80118c <read>
	if (r < 0)
  801be8:	85 c0                	test   %eax,%eax
  801bea:	78 0f                	js     801bfb <getchar+0x34>
		return r;
	if (r < 1)
  801bec:	85 c0                	test   %eax,%eax
  801bee:	7e 06                	jle    801bf6 <getchar+0x2f>
		return -E_EOF;
	return c;
  801bf0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bf4:	eb 05                	jmp    801bfb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bf6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    

00801bfd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0d:	89 04 24             	mov    %eax,(%esp)
  801c10:	e8 d9 f2 ff ff       	call   800eee <fd_lookup>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	78 11                	js     801c2a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c22:	39 10                	cmp    %edx,(%eax)
  801c24:	0f 94 c0             	sete   %al
  801c27:	0f b6 c0             	movzbl %al,%eax
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <opencons>:

int
opencons(void)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 5e f2 ff ff       	call   800e9b <fd_alloc>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 3c                	js     801c7d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c41:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c48:	00 
  801c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c57:	e8 a9 ef ff ff       	call   800c05 <sys_page_alloc>
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	78 1d                	js     801c7d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c60:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c69:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c75:	89 04 24             	mov    %eax,(%esp)
  801c78:	e8 f3 f1 ff ff       	call   800e70 <fd2num>
}
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    
	...

00801c80 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	56                   	push   %esi
  801c84:	53                   	push   %ebx
  801c85:	83 ec 10             	sub    $0x10,%esp
  801c88:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c91:	85 c0                	test   %eax,%eax
  801c93:	75 05                	jne    801c9a <ipc_recv+0x1a>
  801c95:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801c9a:	89 04 24             	mov    %eax,(%esp)
  801c9d:	e8 79 f1 ff ff       	call   800e1b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	79 16                	jns    801cbc <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801ca6:	85 db                	test   %ebx,%ebx
  801ca8:	74 06                	je     801cb0 <ipc_recv+0x30>
  801caa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801cb0:	85 f6                	test   %esi,%esi
  801cb2:	74 32                	je     801ce6 <ipc_recv+0x66>
  801cb4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801cba:	eb 2a                	jmp    801ce6 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801cbc:	85 db                	test   %ebx,%ebx
  801cbe:	74 0c                	je     801ccc <ipc_recv+0x4c>
  801cc0:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801cc5:	8b 00                	mov    (%eax),%eax
  801cc7:	8b 40 74             	mov    0x74(%eax),%eax
  801cca:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ccc:	85 f6                	test   %esi,%esi
  801cce:	74 0c                	je     801cdc <ipc_recv+0x5c>
  801cd0:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801cd5:	8b 00                	mov    (%eax),%eax
  801cd7:	8b 40 78             	mov    0x78(%eax),%eax
  801cda:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801cdc:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801ce1:	8b 00                	mov    (%eax),%eax
  801ce3:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801ce6:	83 c4 10             	add    $0x10,%esp
  801ce9:	5b                   	pop    %ebx
  801cea:	5e                   	pop    %esi
  801ceb:	5d                   	pop    %ebp
  801cec:	c3                   	ret    

00801ced <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	57                   	push   %edi
  801cf1:	56                   	push   %esi
  801cf2:	53                   	push   %ebx
  801cf3:	83 ec 1c             	sub    $0x1c,%esp
  801cf6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cfc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801cff:	85 db                	test   %ebx,%ebx
  801d01:	75 05                	jne    801d08 <ipc_send+0x1b>
  801d03:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801d08:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d0c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d10:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	89 04 24             	mov    %eax,(%esp)
  801d1a:	e8 d9 f0 ff ff       	call   800df8 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801d1f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d22:	75 07                	jne    801d2b <ipc_send+0x3e>
  801d24:	e8 bd ee ff ff       	call   800be6 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801d29:	eb dd                	jmp    801d08 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	79 1c                	jns    801d4b <ipc_send+0x5e>
  801d2f:	c7 44 24 08 3a 25 80 	movl   $0x80253a,0x8(%esp)
  801d36:	00 
  801d37:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801d3e:	00 
  801d3f:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  801d46:	e8 25 e4 ff ff       	call   800170 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801d4b:	83 c4 1c             	add    $0x1c,%esp
  801d4e:	5b                   	pop    %ebx
  801d4f:	5e                   	pop    %esi
  801d50:	5f                   	pop    %edi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	53                   	push   %ebx
  801d57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d5a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d5f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d66:	89 c2                	mov    %eax,%edx
  801d68:	c1 e2 07             	shl    $0x7,%edx
  801d6b:	29 ca                	sub    %ecx,%edx
  801d6d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d73:	8b 52 50             	mov    0x50(%edx),%edx
  801d76:	39 da                	cmp    %ebx,%edx
  801d78:	75 0f                	jne    801d89 <ipc_find_env+0x36>
			return envs[i].env_id;
  801d7a:	c1 e0 07             	shl    $0x7,%eax
  801d7d:	29 c8                	sub    %ecx,%eax
  801d7f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d84:	8b 40 40             	mov    0x40(%eax),%eax
  801d87:	eb 0c                	jmp    801d95 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d89:	40                   	inc    %eax
  801d8a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d8f:	75 ce                	jne    801d5f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d91:	66 b8 00 00          	mov    $0x0,%ax
}
  801d95:	5b                   	pop    %ebx
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801d9e:	89 c2                	mov    %eax,%edx
  801da0:	c1 ea 16             	shr    $0x16,%edx
  801da3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801daa:	f6 c2 01             	test   $0x1,%dl
  801dad:	74 1e                	je     801dcd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801daf:	c1 e8 0c             	shr    $0xc,%eax
  801db2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801db9:	a8 01                	test   $0x1,%al
  801dbb:	74 17                	je     801dd4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dbd:	c1 e8 0c             	shr    $0xc,%eax
  801dc0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801dc7:	ef 
  801dc8:	0f b7 c0             	movzwl %ax,%eax
  801dcb:	eb 0c                	jmp    801dd9 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd2:	eb 05                	jmp    801dd9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801dd4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    
	...

00801ddc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801ddc:	55                   	push   %ebp
  801ddd:	57                   	push   %edi
  801dde:	56                   	push   %esi
  801ddf:	83 ec 10             	sub    $0x10,%esp
  801de2:	8b 74 24 20          	mov    0x20(%esp),%esi
  801de6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801dea:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dee:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801df2:	89 cd                	mov    %ecx,%ebp
  801df4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	75 2c                	jne    801e28 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801dfc:	39 f9                	cmp    %edi,%ecx
  801dfe:	77 68                	ja     801e68 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e00:	85 c9                	test   %ecx,%ecx
  801e02:	75 0b                	jne    801e0f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e04:	b8 01 00 00 00       	mov    $0x1,%eax
  801e09:	31 d2                	xor    %edx,%edx
  801e0b:	f7 f1                	div    %ecx
  801e0d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e0f:	31 d2                	xor    %edx,%edx
  801e11:	89 f8                	mov    %edi,%eax
  801e13:	f7 f1                	div    %ecx
  801e15:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e17:	89 f0                	mov    %esi,%eax
  801e19:	f7 f1                	div    %ecx
  801e1b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e1d:	89 f0                	mov    %esi,%eax
  801e1f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	5e                   	pop    %esi
  801e25:	5f                   	pop    %edi
  801e26:	5d                   	pop    %ebp
  801e27:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e28:	39 f8                	cmp    %edi,%eax
  801e2a:	77 2c                	ja     801e58 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e2c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801e2f:	83 f6 1f             	xor    $0x1f,%esi
  801e32:	75 4c                	jne    801e80 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e34:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e36:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e3b:	72 0a                	jb     801e47 <__udivdi3+0x6b>
  801e3d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e41:	0f 87 ad 00 00 00    	ja     801ef4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e47:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e4c:	89 f0                	mov    %esi,%eax
  801e4e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	5e                   	pop    %esi
  801e54:	5f                   	pop    %edi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    
  801e57:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e58:	31 ff                	xor    %edi,%edi
  801e5a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e5c:	89 f0                	mov    %esi,%eax
  801e5e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	5e                   	pop    %esi
  801e64:	5f                   	pop    %edi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    
  801e67:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e68:	89 fa                	mov    %edi,%edx
  801e6a:	89 f0                	mov    %esi,%eax
  801e6c:	f7 f1                	div    %ecx
  801e6e:	89 c6                	mov    %eax,%esi
  801e70:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e72:	89 f0                	mov    %esi,%eax
  801e74:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e76:	83 c4 10             	add    $0x10,%esp
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e80:	89 f1                	mov    %esi,%ecx
  801e82:	d3 e0                	shl    %cl,%eax
  801e84:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e88:	b8 20 00 00 00       	mov    $0x20,%eax
  801e8d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e8f:	89 ea                	mov    %ebp,%edx
  801e91:	88 c1                	mov    %al,%cl
  801e93:	d3 ea                	shr    %cl,%edx
  801e95:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e99:	09 ca                	or     %ecx,%edx
  801e9b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801e9f:	89 f1                	mov    %esi,%ecx
  801ea1:	d3 e5                	shl    %cl,%ebp
  801ea3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801ea7:	89 fd                	mov    %edi,%ebp
  801ea9:	88 c1                	mov    %al,%cl
  801eab:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801ead:	89 fa                	mov    %edi,%edx
  801eaf:	89 f1                	mov    %esi,%ecx
  801eb1:	d3 e2                	shl    %cl,%edx
  801eb3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801eb7:	88 c1                	mov    %al,%cl
  801eb9:	d3 ef                	shr    %cl,%edi
  801ebb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ebd:	89 f8                	mov    %edi,%eax
  801ebf:	89 ea                	mov    %ebp,%edx
  801ec1:	f7 74 24 08          	divl   0x8(%esp)
  801ec5:	89 d1                	mov    %edx,%ecx
  801ec7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801ec9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ecd:	39 d1                	cmp    %edx,%ecx
  801ecf:	72 17                	jb     801ee8 <__udivdi3+0x10c>
  801ed1:	74 09                	je     801edc <__udivdi3+0x100>
  801ed3:	89 fe                	mov    %edi,%esi
  801ed5:	31 ff                	xor    %edi,%edi
  801ed7:	e9 41 ff ff ff       	jmp    801e1d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801edc:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ee0:	89 f1                	mov    %esi,%ecx
  801ee2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ee4:	39 c2                	cmp    %eax,%edx
  801ee6:	73 eb                	jae    801ed3 <__udivdi3+0xf7>
		{
		  q0--;
  801ee8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801eeb:	31 ff                	xor    %edi,%edi
  801eed:	e9 2b ff ff ff       	jmp    801e1d <__udivdi3+0x41>
  801ef2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ef4:	31 f6                	xor    %esi,%esi
  801ef6:	e9 22 ff ff ff       	jmp    801e1d <__udivdi3+0x41>
	...

00801efc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801efc:	55                   	push   %ebp
  801efd:	57                   	push   %edi
  801efe:	56                   	push   %esi
  801eff:	83 ec 20             	sub    $0x20,%esp
  801f02:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f06:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f0a:	89 44 24 14          	mov    %eax,0x14(%esp)
  801f0e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801f12:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f16:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f1a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801f1c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f1e:	85 ed                	test   %ebp,%ebp
  801f20:	75 16                	jne    801f38 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801f22:	39 f1                	cmp    %esi,%ecx
  801f24:	0f 86 a6 00 00 00    	jbe    801fd0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f2a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f2c:	89 d0                	mov    %edx,%eax
  801f2e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f30:	83 c4 20             	add    $0x20,%esp
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    
  801f37:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f38:	39 f5                	cmp    %esi,%ebp
  801f3a:	0f 87 ac 00 00 00    	ja     801fec <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f40:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801f43:	83 f0 1f             	xor    $0x1f,%eax
  801f46:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f4a:	0f 84 a8 00 00 00    	je     801ff8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f50:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f54:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f56:	bf 20 00 00 00       	mov    $0x20,%edi
  801f5b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f5f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f63:	89 f9                	mov    %edi,%ecx
  801f65:	d3 e8                	shr    %cl,%eax
  801f67:	09 e8                	or     %ebp,%eax
  801f69:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801f6d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f71:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f75:	d3 e0                	shl    %cl,%eax
  801f77:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f7b:	89 f2                	mov    %esi,%edx
  801f7d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f7f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f83:	d3 e0                	shl    %cl,%eax
  801f85:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f89:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f8d:	89 f9                	mov    %edi,%ecx
  801f8f:	d3 e8                	shr    %cl,%eax
  801f91:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f93:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f95:	89 f2                	mov    %esi,%edx
  801f97:	f7 74 24 18          	divl   0x18(%esp)
  801f9b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f9d:	f7 64 24 0c          	mull   0xc(%esp)
  801fa1:	89 c5                	mov    %eax,%ebp
  801fa3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fa5:	39 d6                	cmp    %edx,%esi
  801fa7:	72 67                	jb     802010 <__umoddi3+0x114>
  801fa9:	74 75                	je     802020 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801fab:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801faf:	29 e8                	sub    %ebp,%eax
  801fb1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801fb3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fb7:	d3 e8                	shr    %cl,%eax
  801fb9:	89 f2                	mov    %esi,%edx
  801fbb:	89 f9                	mov    %edi,%ecx
  801fbd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801fbf:	09 d0                	or     %edx,%eax
  801fc1:	89 f2                	mov    %esi,%edx
  801fc3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fc7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fc9:	83 c4 20             	add    $0x20,%esp
  801fcc:	5e                   	pop    %esi
  801fcd:	5f                   	pop    %edi
  801fce:	5d                   	pop    %ebp
  801fcf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fd0:	85 c9                	test   %ecx,%ecx
  801fd2:	75 0b                	jne    801fdf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fd4:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd9:	31 d2                	xor    %edx,%edx
  801fdb:	f7 f1                	div    %ecx
  801fdd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fdf:	89 f0                	mov    %esi,%eax
  801fe1:	31 d2                	xor    %edx,%edx
  801fe3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fe5:	89 f8                	mov    %edi,%eax
  801fe7:	e9 3e ff ff ff       	jmp    801f2a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801fec:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fee:	83 c4 20             	add    $0x20,%esp
  801ff1:	5e                   	pop    %esi
  801ff2:	5f                   	pop    %edi
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    
  801ff5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ff8:	39 f5                	cmp    %esi,%ebp
  801ffa:	72 04                	jb     802000 <__umoddi3+0x104>
  801ffc:	39 f9                	cmp    %edi,%ecx
  801ffe:	77 06                	ja     802006 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802000:	89 f2                	mov    %esi,%edx
  802002:	29 cf                	sub    %ecx,%edi
  802004:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802006:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802008:	83 c4 20             	add    $0x20,%esp
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    
  80200f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802010:	89 d1                	mov    %edx,%ecx
  802012:	89 c5                	mov    %eax,%ebp
  802014:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802018:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80201c:	eb 8d                	jmp    801fab <__umoddi3+0xaf>
  80201e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802020:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802024:	72 ea                	jb     802010 <__umoddi3+0x114>
  802026:	89 f1                	mov    %esi,%ecx
  802028:	eb 81                	jmp    801fab <__umoddi3+0xaf>
