
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
  80003a:	c7 04 24 80 10 80 00 	movl   $0x801080,(%esp)
  800041:	e8 2a 02 00 00       	call   800270 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 fb 10 80 	movl   $0x8010fb,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  800070:	e8 03 01 00 00       	call   800178 <_panic>
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
  8000a3:	c7 44 24 08 a0 10 80 	movl   $0x8010a0,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  8000ba:	e8 b9 00 00 00       	call   800178 <_panic>
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
  8000c7:	c7 04 24 c8 10 80 00 	movl   $0x8010c8,(%esp)
  8000ce:	e8 9d 01 00 00       	call   800270 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 27 11 80 	movl   $0x801127,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  8000f4:	e8 7f 00 00 00       	call   800178 <_panic>
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
  80010a:	e8 c0 0a 00 00       	call   800bcf <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011b:	c1 e0 07             	shl    $0x7,%eax
  80011e:	29 d0                	sub    %edx,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800128:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80012b:	a3 20 20 c0 00       	mov    %eax,0xc02020
  800130:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  800134:	c7 04 24 3e 11 80 00 	movl   $0x80113e,(%esp)
  80013b:	e8 30 01 00 00       	call   800270 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800140:	85 f6                	test   %esi,%esi
  800142:	7e 07                	jle    80014b <libmain+0x4f>
		binaryname = argv[0];
  800144:	8b 03                	mov    (%ebx),%eax
  800146:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80014b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80014f:	89 34 24             	mov    %esi,(%esp)
  800152:	e8 dd fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800157:	e8 08 00 00 00       	call   800164 <exit>
}
  80015c:	83 c4 20             	add    $0x20,%esp
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    
	...

00800164 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80016a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800171:	e8 07 0a 00 00       	call   800b7d <sys_env_destroy>
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800180:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800183:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800189:	e8 41 0a 00 00       	call   800bcf <sys_getenvid>
  80018e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800191:	89 54 24 10          	mov    %edx,0x10(%esp)
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80019c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 4c 11 80 00 	movl   $0x80114c,(%esp)
  8001ab:	e8 c0 00 00 00       	call   800270 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 50 00 00 00       	call   80020f <vcprintf>
	cprintf("\n");
  8001bf:	c7 04 24 16 11 80 00 	movl   $0x801116,(%esp)
  8001c6:	e8 a5 00 00 00       	call   800270 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cb:	cc                   	int3   
  8001cc:	eb fd                	jmp    8001cb <_panic+0x53>
	...

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 14             	sub    $0x14,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 03                	mov    (%ebx),%eax
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e3:	40                   	inc    %eax
  8001e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001eb:	75 19                	jne    800206 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f4:	00 
  8001f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 40 09 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  800200:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800206:	ff 43 04             	incl   0x4(%ebx)
}
  800209:	83 c4 14             	add    $0x14,%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	c7 04 24 d0 01 80 00 	movl   $0x8001d0,(%esp)
  80024b:	e8 82 01 00 00       	call   8003d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 d8 08 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
}
  800268:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800276:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	e8 87 ff ff ff       	call   80020f <vcprintf>
	va_end(ap);

	return cnt;
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    
	...

0080028c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 3c             	sub    $0x3c,%esp
  800295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800298:	89 d7                	mov    %edx,%edi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ac:	85 c0                	test   %eax,%eax
  8002ae:	75 08                	jne    8002b8 <printnum+0x2c>
  8002b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b6:	77 57                	ja     80030f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002bc:	4b                   	dec    %ebx
  8002bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002cc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d7:	00 
  8002d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002db:	89 04 24             	mov    %eax,(%esp)
  8002de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e5:	e8 3a 0b 00 00       	call   800e24 <__udivdi3>
  8002ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f9:	89 fa                	mov    %edi,%edx
  8002fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fe:	e8 89 ff ff ff       	call   80028c <printnum>
  800303:	eb 0f                	jmp    800314 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800309:	89 34 24             	mov    %esi,(%esp)
  80030c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030f:	4b                   	dec    %ebx
  800310:	85 db                	test   %ebx,%ebx
  800312:	7f f1                	jg     800305 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800314:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800318:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032a:	00 
  80032b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032e:	89 04 24             	mov    %eax,(%esp)
  800331:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800334:	89 44 24 04          	mov    %eax,0x4(%esp)
  800338:	e8 07 0c 00 00       	call   800f44 <__umoddi3>
  80033d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800341:	0f be 80 70 11 80 00 	movsbl 0x801170(%eax),%eax
  800348:	89 04 24             	mov    %eax,(%esp)
  80034b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80034e:	83 c4 3c             	add    $0x3c,%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800359:	83 fa 01             	cmp    $0x1,%edx
  80035c:	7e 0e                	jle    80036c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035e:	8b 10                	mov    (%eax),%edx
  800360:	8d 4a 08             	lea    0x8(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 02                	mov    (%edx),%eax
  800367:	8b 52 04             	mov    0x4(%edx),%edx
  80036a:	eb 22                	jmp    80038e <getuint+0x38>
	else if (lflag)
  80036c:	85 d2                	test   %edx,%edx
  80036e:	74 10                	je     800380 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	eb 0e                	jmp    80038e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 04             	lea    0x4(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800396:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800399:	8b 10                	mov    (%eax),%edx
  80039b:	3b 50 04             	cmp    0x4(%eax),%edx
  80039e:	73 08                	jae    8003a8 <sprintputch+0x18>
		*b->buf++ = ch;
  8003a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a3:	88 0a                	mov    %cl,(%edx)
  8003a5:	42                   	inc    %edx
  8003a6:	89 10                	mov    %edx,(%eax)
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	e8 02 00 00 00       	call   8003d2 <vprintfmt>
	va_end(ap);
}
  8003d0:	c9                   	leave  
  8003d1:	c3                   	ret    

008003d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	57                   	push   %edi
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	83 ec 4c             	sub    $0x4c,%esp
  8003db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003de:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e1:	eb 12                	jmp    8003f5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	0f 84 6b 03 00 00    	je     800756 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f5:	0f b6 06             	movzbl (%esi),%eax
  8003f8:	46                   	inc    %esi
  8003f9:	83 f8 25             	cmp    $0x25,%eax
  8003fc:	75 e5                	jne    8003e3 <vprintfmt+0x11>
  8003fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800402:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800409:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80040e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041a:	eb 26                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800423:	eb 1d                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800428:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80042c:	eb 14                	jmp    800442 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800431:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800438:	eb 08                	jmp    800442 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80043d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	0f b6 06             	movzbl (%esi),%eax
  800445:	8d 56 01             	lea    0x1(%esi),%edx
  800448:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80044b:	8a 16                	mov    (%esi),%dl
  80044d:	83 ea 23             	sub    $0x23,%edx
  800450:	80 fa 55             	cmp    $0x55,%dl
  800453:	0f 87 e1 02 00 00    	ja     80073a <vprintfmt+0x368>
  800459:	0f b6 d2             	movzbl %dl,%edx
  80045c:	ff 24 95 40 12 80 00 	jmp    *0x801240(,%edx,4)
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800466:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80046e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800472:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800475:	8d 50 d0             	lea    -0x30(%eax),%edx
  800478:	83 fa 09             	cmp    $0x9,%edx
  80047b:	77 2a                	ja     8004a7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80047d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047e:	eb eb                	jmp    80046b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80048e:	eb 17                	jmp    8004a7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800490:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800494:	78 98                	js     80042e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800499:	eb a7                	jmp    800442 <vprintfmt+0x70>
  80049b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004a5:	eb 9b                	jmp    800442 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ab:	79 95                	jns    800442 <vprintfmt+0x70>
  8004ad:	eb 8b                	jmp    80043a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004af:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b3:	eb 8d                	jmp    800442 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	89 04 24             	mov    %eax,(%esp)
  8004c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004cd:	e9 23 ff ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	79 02                	jns    8004e3 <vprintfmt+0x111>
  8004e1:	f7 d8                	neg    %eax
  8004e3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e5:	83 f8 08             	cmp    $0x8,%eax
  8004e8:	7f 0b                	jg     8004f5 <vprintfmt+0x123>
  8004ea:	8b 04 85 a0 13 80 00 	mov    0x8013a0(,%eax,4),%eax
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	75 23                	jne    800518 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f9:	c7 44 24 08 88 11 80 	movl   $0x801188,0x8(%esp)
  800500:	00 
  800501:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800505:	8b 45 08             	mov    0x8(%ebp),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	e8 9a fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800513:	e9 dd fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800518:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051c:	c7 44 24 08 91 11 80 	movl   $0x801191,0x8(%esp)
  800523:	00 
  800524:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800528:	8b 55 08             	mov    0x8(%ebp),%edx
  80052b:	89 14 24             	mov    %edx,(%esp)
  80052e:	e8 77 fe ff ff       	call   8003aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800536:	e9 ba fe ff ff       	jmp    8003f5 <vprintfmt+0x23>
  80053b:	89 f9                	mov    %edi,%ecx
  80053d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800540:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 30                	mov    (%eax),%esi
  80054e:	85 f6                	test   %esi,%esi
  800550:	75 05                	jne    800557 <vprintfmt+0x185>
				p = "(null)";
  800552:	be 81 11 80 00       	mov    $0x801181,%esi
			if (width > 0 && padc != '-')
  800557:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055b:	0f 8e 84 00 00 00    	jle    8005e5 <vprintfmt+0x213>
  800561:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800565:	74 7e                	je     8005e5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056b:	89 34 24             	mov    %esi,(%esp)
  80056e:	e8 8b 02 00 00       	call   8007fe <strnlen>
  800573:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800576:	29 c2                	sub    %eax,%edx
  800578:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80057b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80057f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800582:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800585:	89 de                	mov    %ebx,%esi
  800587:	89 d3                	mov    %edx,%ebx
  800589:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	eb 0b                	jmp    800598 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80058d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800591:	89 3c 24             	mov    %edi,(%esp)
  800594:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	4b                   	dec    %ebx
  800598:	85 db                	test   %ebx,%ebx
  80059a:	7f f1                	jg     80058d <vprintfmt+0x1bb>
  80059c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80059f:	89 f3                	mov    %esi,%ebx
  8005a1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	79 05                	jns    8005b0 <vprintfmt+0x1de>
  8005ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b3:	29 c2                	sub    %eax,%edx
  8005b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b8:	eb 2b                	jmp    8005e5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005be:	74 18                	je     8005d8 <vprintfmt+0x206>
  8005c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005c3:	83 fa 5e             	cmp    $0x5e,%edx
  8005c6:	76 10                	jbe    8005d8 <vprintfmt+0x206>
					putch('?', putdat);
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
  8005d6:	eb 0a                	jmp    8005e2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e5:	0f be 06             	movsbl (%esi),%eax
  8005e8:	46                   	inc    %esi
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	74 21                	je     80060e <vprintfmt+0x23c>
  8005ed:	85 ff                	test   %edi,%edi
  8005ef:	78 c9                	js     8005ba <vprintfmt+0x1e8>
  8005f1:	4f                   	dec    %edi
  8005f2:	79 c6                	jns    8005ba <vprintfmt+0x1e8>
  8005f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f7:	89 de                	mov    %ebx,%esi
  8005f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005fc:	eb 18                	jmp    800616 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800602:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800609:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	4b                   	dec    %ebx
  80060c:	eb 08                	jmp    800616 <vprintfmt+0x244>
  80060e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800611:	89 de                	mov    %ebx,%esi
  800613:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800616:	85 db                	test   %ebx,%ebx
  800618:	7f e4                	jg     8005fe <vprintfmt+0x22c>
  80061a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80061d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800622:	e9 ce fd ff ff       	jmp    8003f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 f9 01             	cmp    $0x1,%ecx
  80062a:	7e 10                	jle    80063c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 30                	mov    (%eax),%esi
  800637:	8b 78 04             	mov    0x4(%eax),%edi
  80063a:	eb 26                	jmp    800662 <vprintfmt+0x290>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	74 12                	je     800652 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 50 04             	lea    0x4(%eax),%edx
  800646:	89 55 14             	mov    %edx,0x14(%ebp)
  800649:	8b 30                	mov    (%eax),%esi
  80064b:	89 f7                	mov    %esi,%edi
  80064d:	c1 ff 1f             	sar    $0x1f,%edi
  800650:	eb 10                	jmp    800662 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 30                	mov    (%eax),%esi
  80065d:	89 f7                	mov    %esi,%edi
  80065f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800662:	85 ff                	test   %edi,%edi
  800664:	78 0a                	js     800670 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 8c 00 00 00       	jmp    8006fc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80067e:	f7 de                	neg    %esi
  800680:	83 d7 00             	adc    $0x0,%edi
  800683:	f7 df                	neg    %edi
			}
			base = 10;
  800685:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068a:	eb 70                	jmp    8006fc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068c:	89 ca                	mov    %ecx,%edx
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 c0 fc ff ff       	call   800356 <getuint>
  800696:	89 c6                	mov    %eax,%esi
  800698:	89 d7                	mov    %edx,%edi
			base = 10;
  80069a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80069f:	eb 5b                	jmp    8006fc <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006a1:	89 ca                	mov    %ecx,%edx
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 ab fc ff ff       	call   800356 <getuint>
  8006ab:	89 c6                	mov    %eax,%esi
  8006ad:	89 d7                	mov    %edx,%edi
			base = 8;
  8006af:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006b4:	eb 46                	jmp    8006fc <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ba:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006db:	8b 30                	mov    (%eax),%esi
  8006dd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e7:	eb 13                	jmp    8006fc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e9:	89 ca                	mov    %ecx,%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 63 fc ff ff       	call   800356 <getuint>
  8006f3:	89 c6                	mov    %eax,%esi
  8006f5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800700:	89 54 24 10          	mov    %edx,0x10(%esp)
  800704:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800707:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070f:	89 34 24             	mov    %esi,(%esp)
  800712:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800716:	89 da                	mov    %ebx,%edx
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	e8 6c fb ff ff       	call   80028c <printnum>
			break;
  800720:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800723:	e9 cd fc ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800728:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800735:	e9 bb fc ff ff       	jmp    8003f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800745:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800748:	eb 01                	jmp    80074b <vprintfmt+0x379>
  80074a:	4e                   	dec    %esi
  80074b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80074f:	75 f9                	jne    80074a <vprintfmt+0x378>
  800751:	e9 9f fc ff ff       	jmp    8003f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800756:	83 c4 4c             	add    $0x4c,%esp
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	5f                   	pop    %edi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 28             	sub    $0x28,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 30                	je     8007af <vsnprintf+0x51>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 33                	jle    8007b6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078a:	8b 45 10             	mov    0x10(%ebp),%eax
  80078d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	c7 04 24 90 03 80 00 	movl   $0x800390,(%esp)
  80079f:	e8 2e fc ff ff       	call   8003d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ad:	eb 0c                	jmp    8007bb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b4:	eb 05                	jmp    8007bb <vsnprintf+0x5d>
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	89 04 24             	mov    %eax,(%esp)
  8007de:	e8 7b ff ff ff       	call   80075e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    
  8007e5:	00 00                	add    %al,(%eax)
	...

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	eb 01                	jmp    8007f6 <strlen+0xe>
		n++;
  8007f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fa:	75 f9                	jne    8007f5 <strlen+0xd>
		n++;
	return n;
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	eb 01                	jmp    80080f <strnlen+0x11>
		n++;
  80080e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	39 d0                	cmp    %edx,%eax
  800811:	74 06                	je     800819 <strnlen+0x1b>
  800813:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800817:	75 f5                	jne    80080e <strnlen+0x10>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800825:	ba 00 00 00 00       	mov    $0x0,%edx
  80082a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80082d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800830:	42                   	inc    %edx
  800831:	84 c9                	test   %cl,%cl
  800833:	75 f5                	jne    80082a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800835:	5b                   	pop    %ebx
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800842:	89 1c 24             	mov    %ebx,(%esp)
  800845:	e8 9e ff ff ff       	call   8007e8 <strlen>
	strcpy(dst + len, src);
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800851:	01 d8                	add    %ebx,%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 c0 ff ff ff       	call   80081b <strcpy>
	return dst;
}
  80085b:	89 d8                	mov    %ebx,%eax
  80085d:	83 c4 08             	add    $0x8,%esp
  800860:	5b                   	pop    %ebx
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800871:	b9 00 00 00 00       	mov    $0x0,%ecx
  800876:	eb 0c                	jmp    800884 <strncpy+0x21>
		*dst++ = *src;
  800878:	8a 1a                	mov    (%edx),%bl
  80087a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087d:	80 3a 01             	cmpb   $0x1,(%edx)
  800880:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800883:	41                   	inc    %ecx
  800884:	39 f1                	cmp    %esi,%ecx
  800886:	75 f0                	jne    800878 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	8b 75 08             	mov    0x8(%ebp),%esi
  800894:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800897:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089a:	85 d2                	test   %edx,%edx
  80089c:	75 0a                	jne    8008a8 <strlcpy+0x1c>
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	eb 1a                	jmp    8008bc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a2:	88 18                	mov    %bl,(%eax)
  8008a4:	40                   	inc    %eax
  8008a5:	41                   	inc    %ecx
  8008a6:	eb 02                	jmp    8008aa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008aa:	4a                   	dec    %edx
  8008ab:	74 0a                	je     8008b7 <strlcpy+0x2b>
  8008ad:	8a 19                	mov    (%ecx),%bl
  8008af:	84 db                	test   %bl,%bl
  8008b1:	75 ef                	jne    8008a2 <strlcpy+0x16>
  8008b3:	89 c2                	mov    %eax,%edx
  8008b5:	eb 02                	jmp    8008b9 <strlcpy+0x2d>
  8008b7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008b9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008bc:	29 f0                	sub    %esi,%eax
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cb:	eb 02                	jmp    8008cf <strcmp+0xd>
		p++, q++;
  8008cd:	41                   	inc    %ecx
  8008ce:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cf:	8a 01                	mov    (%ecx),%al
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x17>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 f4                	je     8008cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ed:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 03                	jmp    8008f5 <strncmp+0x12>
		n--, p++, q++;
  8008f2:	4a                   	dec    %edx
  8008f3:	40                   	inc    %eax
  8008f4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	74 14                	je     80090d <strncmp+0x2a>
  8008f9:	8a 18                	mov    (%eax),%bl
  8008fb:	84 db                	test   %bl,%bl
  8008fd:	74 04                	je     800903 <strncmp+0x20>
  8008ff:	3a 19                	cmp    (%ecx),%bl
  800901:	74 ef                	je     8008f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800903:	0f b6 00             	movzbl (%eax),%eax
  800906:	0f b6 11             	movzbl (%ecx),%edx
  800909:	29 d0                	sub    %edx,%eax
  80090b:	eb 05                	jmp    800912 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091e:	eb 05                	jmp    800925 <strchr+0x10>
		if (*s == c)
  800920:	38 ca                	cmp    %cl,%dl
  800922:	74 0c                	je     800930 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800924:	40                   	inc    %eax
  800925:	8a 10                	mov    (%eax),%dl
  800927:	84 d2                	test   %dl,%dl
  800929:	75 f5                	jne    800920 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093b:	eb 05                	jmp    800942 <strfind+0x10>
		if (*s == c)
  80093d:	38 ca                	cmp    %cl,%dl
  80093f:	74 07                	je     800948 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800941:	40                   	inc    %eax
  800942:	8a 10                	mov    (%eax),%dl
  800944:	84 d2                	test   %dl,%dl
  800946:	75 f5                	jne    80093d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 7d 08             	mov    0x8(%ebp),%edi
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800959:	85 c9                	test   %ecx,%ecx
  80095b:	74 30                	je     80098d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800963:	75 25                	jne    80098a <memset+0x40>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 20                	jne    80098a <memset+0x40>
		c &= 0xFF;
  80096a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d3                	mov    %edx,%ebx
  80096f:	c1 e3 08             	shl    $0x8,%ebx
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 18             	shl    $0x18,%esi
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 10             	shl    $0x10,%eax
  80097c:	09 f0                	or     %esi,%eax
  80097e:	09 d0                	or     %edx,%eax
  800980:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800982:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800985:	fc                   	cld    
  800986:	f3 ab                	rep stos %eax,%es:(%edi)
  800988:	eb 03                	jmp    80098d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098a:	fc                   	cld    
  80098b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098d:	89 f8                	mov    %edi,%eax
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5f                   	pop    %edi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a2:	39 c6                	cmp    %eax,%esi
  8009a4:	73 34                	jae    8009da <memmove+0x46>
  8009a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a9:	39 d0                	cmp    %edx,%eax
  8009ab:	73 2d                	jae    8009da <memmove+0x46>
		s += n;
		d += n;
  8009ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	f6 c2 03             	test   $0x3,%dl
  8009b3:	75 1b                	jne    8009d0 <memmove+0x3c>
  8009b5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bb:	75 13                	jne    8009d0 <memmove+0x3c>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 0e                	jne    8009d0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c2:	83 ef 04             	sub    $0x4,%edi
  8009c5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009cb:	fd                   	std    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 07                	jmp    8009d7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d0:	4f                   	dec    %edi
  8009d1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d4:	fd                   	std    
  8009d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d7:	fc                   	cld    
  8009d8:	eb 20                	jmp    8009fa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009da:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e0:	75 13                	jne    8009f5 <memmove+0x61>
  8009e2:	a8 03                	test   $0x3,%al
  8009e4:	75 0f                	jne    8009f5 <memmove+0x61>
  8009e6:	f6 c1 03             	test   $0x3,%cl
  8009e9:	75 0a                	jne    8009f5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ee:	89 c7                	mov    %eax,%edi
  8009f0:	fc                   	cld    
  8009f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f3:	eb 05                	jmp    8009fa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a04:	8b 45 10             	mov    0x10(%ebp),%eax
  800a07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 04 24             	mov    %eax,(%esp)
  800a18:	e8 77 ff ff ff       	call   800994 <memmove>
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a33:	eb 16                	jmp    800a4b <memcmp+0x2c>
		if (*s1 != *s2)
  800a35:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a38:	42                   	inc    %edx
  800a39:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a3d:	38 c8                	cmp    %cl,%al
  800a3f:	74 0a                	je     800a4b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a41:	0f b6 c0             	movzbl %al,%eax
  800a44:	0f b6 c9             	movzbl %cl,%ecx
  800a47:	29 c8                	sub    %ecx,%eax
  800a49:	eb 09                	jmp    800a54 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4b:	39 da                	cmp    %ebx,%edx
  800a4d:	75 e6                	jne    800a35 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5f                   	pop    %edi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a62:	89 c2                	mov    %eax,%edx
  800a64:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a67:	eb 05                	jmp    800a6e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	38 08                	cmp    %cl,(%eax)
  800a6b:	74 05                	je     800a72 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6d:	40                   	inc    %eax
  800a6e:	39 d0                	cmp    %edx,%eax
  800a70:	72 f7                	jb     800a69 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a80:	eb 01                	jmp    800a83 <strtol+0xf>
		s++;
  800a82:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a83:	8a 02                	mov    (%edx),%al
  800a85:	3c 20                	cmp    $0x20,%al
  800a87:	74 f9                	je     800a82 <strtol+0xe>
  800a89:	3c 09                	cmp    $0x9,%al
  800a8b:	74 f5                	je     800a82 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8d:	3c 2b                	cmp    $0x2b,%al
  800a8f:	75 08                	jne    800a99 <strtol+0x25>
		s++;
  800a91:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a92:	bf 00 00 00 00       	mov    $0x0,%edi
  800a97:	eb 13                	jmp    800aac <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a99:	3c 2d                	cmp    $0x2d,%al
  800a9b:	75 0a                	jne    800aa7 <strtol+0x33>
		s++, neg = 1;
  800a9d:	8d 52 01             	lea    0x1(%edx),%edx
  800aa0:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa5:	eb 05                	jmp    800aac <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	74 05                	je     800ab5 <strtol+0x41>
  800ab0:	83 fb 10             	cmp    $0x10,%ebx
  800ab3:	75 28                	jne    800add <strtol+0x69>
  800ab5:	8a 02                	mov    (%edx),%al
  800ab7:	3c 30                	cmp    $0x30,%al
  800ab9:	75 10                	jne    800acb <strtol+0x57>
  800abb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abf:	75 0a                	jne    800acb <strtol+0x57>
		s += 2, base = 16;
  800ac1:	83 c2 02             	add    $0x2,%edx
  800ac4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac9:	eb 12                	jmp    800add <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	75 0e                	jne    800add <strtol+0x69>
  800acf:	3c 30                	cmp    $0x30,%al
  800ad1:	75 05                	jne    800ad8 <strtol+0x64>
		s++, base = 8;
  800ad3:	42                   	inc    %edx
  800ad4:	b3 08                	mov    $0x8,%bl
  800ad6:	eb 05                	jmp    800add <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae4:	8a 0a                	mov    (%edx),%cl
  800ae6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae9:	80 fb 09             	cmp    $0x9,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x82>
			dig = *s - '0';
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 30             	sub    $0x30,%ecx
  800af4:	eb 1e                	jmp    800b14 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af9:	80 fb 19             	cmp    $0x19,%bl
  800afc:	77 08                	ja     800b06 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afe:	0f be c9             	movsbl %cl,%ecx
  800b01:	83 e9 57             	sub    $0x57,%ecx
  800b04:	eb 0e                	jmp    800b14 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b06:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 12                	ja     800b20 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b0e:	0f be c9             	movsbl %cl,%ecx
  800b11:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b14:	39 f1                	cmp    %esi,%ecx
  800b16:	7d 0c                	jge    800b24 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b18:	42                   	inc    %edx
  800b19:	0f af c6             	imul   %esi,%eax
  800b1c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b1e:	eb c4                	jmp    800ae4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b20:	89 c1                	mov    %eax,%ecx
  800b22:	eb 02                	jmp    800b26 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b24:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2a:	74 05                	je     800b31 <strtol+0xbd>
		*endptr = (char *) s;
  800b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b31:	85 ff                	test   %edi,%edi
  800b33:	74 04                	je     800b39 <strtol+0xc5>
  800b35:	89 c8                	mov    %ecx,%eax
  800b37:	f7 d8                	neg    %eax
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    
	...

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 cb                	mov    %ecx,%ebx
  800b95:	89 cf                	mov    %ecx,%edi
  800b97:	89 ce                	mov    %ecx,%esi
  800b99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 28                	jle    800bc7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800baa:	00 
  800bab:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bba:	00 
  800bbb:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800bc2:	e8 b1 f5 ff ff       	call   800178 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc7:	83 c4 2c             	add    $0x2c,%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bda:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdf:	89 d1                	mov    %edx,%ecx
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	89 d7                	mov    %edx,%edi
  800be5:	89 d6                	mov    %edx,%esi
  800be7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_yield>:

void
sys_yield(void)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bfe:	89 d1                	mov    %edx,%ecx
  800c00:	89 d3                	mov    %edx,%ebx
  800c02:	89 d7                	mov    %edx,%edi
  800c04:	89 d6                	mov    %edx,%esi
  800c06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	be 00 00 00 00       	mov    $0x0,%esi
  800c1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 f7                	mov    %esi,%edi
  800c2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	7e 28                	jle    800c59 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c35:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c3c:	00 
  800c3d:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800c44:	00 
  800c45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4c:	00 
  800c4d:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800c54:	e8 1f f5 ff ff       	call   800178 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c59:	83 c4 2c             	add    $0x2c,%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 28                	jle    800cac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c8f:	00 
  800c90:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800c97:	00 
  800c98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9f:	00 
  800ca0:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800ca7:	e8 cc f4 ff ff       	call   800178 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cac:	83 c4 2c             	add    $0x2c,%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800cfa:	e8 79 f4 ff ff       	call   800178 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800d4d:	e8 26 f4 ff ff       	call   800178 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d52:	83 c4 2c             	add    $0x2c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800da0:	e8 d3 f3 ff ff       	call   800178 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	be 00 00 00 00       	mov    $0x0,%esi
  800db8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 cb                	mov    %ecx,%ebx
  800de8:	89 cf                	mov    %ecx,%edi
  800dea:	89 ce                	mov    %ecx,%esi
  800dec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dee:	85 c0                	test   %eax,%eax
  800df0:	7e 28                	jle    800e1a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800dfd:	00 
  800dfe:	c7 44 24 08 c4 13 80 	movl   $0x8013c4,0x8(%esp)
  800e05:	00 
  800e06:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0d:	00 
  800e0e:	c7 04 24 e1 13 80 00 	movl   $0x8013e1,(%esp)
  800e15:	e8 5e f3 ff ff       	call   800178 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1a:	83 c4 2c             	add    $0x2c,%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
	...

00800e24 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e24:	55                   	push   %ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	83 ec 10             	sub    $0x10,%esp
  800e2a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e2e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e32:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e36:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e3a:	89 cd                	mov    %ecx,%ebp
  800e3c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e40:	85 c0                	test   %eax,%eax
  800e42:	75 2c                	jne    800e70 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e44:	39 f9                	cmp    %edi,%ecx
  800e46:	77 68                	ja     800eb0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e48:	85 c9                	test   %ecx,%ecx
  800e4a:	75 0b                	jne    800e57 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	f7 f1                	div    %ecx
  800e55:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e57:	31 d2                	xor    %edx,%edx
  800e59:	89 f8                	mov    %edi,%eax
  800e5b:	f7 f1                	div    %ecx
  800e5d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e5f:	89 f0                	mov    %esi,%eax
  800e61:	f7 f1                	div    %ecx
  800e63:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e65:	89 f0                	mov    %esi,%eax
  800e67:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	5e                   	pop    %esi
  800e6d:	5f                   	pop    %edi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e70:	39 f8                	cmp    %edi,%eax
  800e72:	77 2c                	ja     800ea0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e74:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800e77:	83 f6 1f             	xor    $0x1f,%esi
  800e7a:	75 4c                	jne    800ec8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e7c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e7e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e83:	72 0a                	jb     800e8f <__udivdi3+0x6b>
  800e85:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800e89:	0f 87 ad 00 00 00    	ja     800f3c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e8f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e94:	89 f0                	mov    %esi,%eax
  800e96:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    
  800e9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ea0:	31 ff                	xor    %edi,%edi
  800ea2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ea4:	89 f0                	mov    %esi,%eax
  800ea6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    
  800eaf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb0:	89 fa                	mov    %edi,%edx
  800eb2:	89 f0                	mov    %esi,%eax
  800eb4:	f7 f1                	div    %ecx
  800eb6:	89 c6                	mov    %eax,%esi
  800eb8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eba:	89 f0                	mov    %esi,%eax
  800ebc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ec8:	89 f1                	mov    %esi,%ecx
  800eca:	d3 e0                	shl    %cl,%eax
  800ecc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ed0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800ed7:	89 ea                	mov    %ebp,%edx
  800ed9:	88 c1                	mov    %al,%cl
  800edb:	d3 ea                	shr    %cl,%edx
  800edd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800ee1:	09 ca                	or     %ecx,%edx
  800ee3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800ee7:	89 f1                	mov    %esi,%ecx
  800ee9:	d3 e5                	shl    %cl,%ebp
  800eeb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800eef:	89 fd                	mov    %edi,%ebp
  800ef1:	88 c1                	mov    %al,%cl
  800ef3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800ef5:	89 fa                	mov    %edi,%edx
  800ef7:	89 f1                	mov    %esi,%ecx
  800ef9:	d3 e2                	shl    %cl,%edx
  800efb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800eff:	88 c1                	mov    %al,%cl
  800f01:	d3 ef                	shr    %cl,%edi
  800f03:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f05:	89 f8                	mov    %edi,%eax
  800f07:	89 ea                	mov    %ebp,%edx
  800f09:	f7 74 24 08          	divl   0x8(%esp)
  800f0d:	89 d1                	mov    %edx,%ecx
  800f0f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f11:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f15:	39 d1                	cmp    %edx,%ecx
  800f17:	72 17                	jb     800f30 <__udivdi3+0x10c>
  800f19:	74 09                	je     800f24 <__udivdi3+0x100>
  800f1b:	89 fe                	mov    %edi,%esi
  800f1d:	31 ff                	xor    %edi,%edi
  800f1f:	e9 41 ff ff ff       	jmp    800e65 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f24:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f28:	89 f1                	mov    %esi,%ecx
  800f2a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f2c:	39 c2                	cmp    %eax,%edx
  800f2e:	73 eb                	jae    800f1b <__udivdi3+0xf7>
		{
		  q0--;
  800f30:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f33:	31 ff                	xor    %edi,%edi
  800f35:	e9 2b ff ff ff       	jmp    800e65 <__udivdi3+0x41>
  800f3a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f3c:	31 f6                	xor    %esi,%esi
  800f3e:	e9 22 ff ff ff       	jmp    800e65 <__udivdi3+0x41>
	...

00800f44 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f44:	55                   	push   %ebp
  800f45:	57                   	push   %edi
  800f46:	56                   	push   %esi
  800f47:	83 ec 20             	sub    $0x20,%esp
  800f4a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f4e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f52:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f56:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800f5a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f5e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f62:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800f64:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f66:	85 ed                	test   %ebp,%ebp
  800f68:	75 16                	jne    800f80 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800f6a:	39 f1                	cmp    %esi,%ecx
  800f6c:	0f 86 a6 00 00 00    	jbe    801018 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f72:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f74:	89 d0                	mov    %edx,%eax
  800f76:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    
  800f7f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f80:	39 f5                	cmp    %esi,%ebp
  800f82:	0f 87 ac 00 00 00    	ja     801034 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f88:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800f8b:	83 f0 1f             	xor    $0x1f,%eax
  800f8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f92:	0f 84 a8 00 00 00    	je     801040 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f98:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f9c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f9e:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fa7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fab:	89 f9                	mov    %edi,%ecx
  800fad:	d3 e8                	shr    %cl,%eax
  800faf:	09 e8                	or     %ebp,%eax
  800fb1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800fb5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fb9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fbd:	d3 e0                	shl    %cl,%eax
  800fbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fc7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fcb:	d3 e0                	shl    %cl,%eax
  800fcd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fd1:	8b 44 24 14          	mov    0x14(%esp),%eax
  800fd5:	89 f9                	mov    %edi,%ecx
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fdb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fdd:	89 f2                	mov    %esi,%edx
  800fdf:	f7 74 24 18          	divl   0x18(%esp)
  800fe3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fe5:	f7 64 24 0c          	mull   0xc(%esp)
  800fe9:	89 c5                	mov    %eax,%ebp
  800feb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fed:	39 d6                	cmp    %edx,%esi
  800fef:	72 67                	jb     801058 <__umoddi3+0x114>
  800ff1:	74 75                	je     801068 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ff3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ff7:	29 e8                	sub    %ebp,%eax
  800ff9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800ffb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fff:	d3 e8                	shr    %cl,%eax
  801001:	89 f2                	mov    %esi,%edx
  801003:	89 f9                	mov    %edi,%ecx
  801005:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801007:	09 d0                	or     %edx,%eax
  801009:	89 f2                	mov    %esi,%edx
  80100b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80100f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801011:	83 c4 20             	add    $0x20,%esp
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801018:	85 c9                	test   %ecx,%ecx
  80101a:	75 0b                	jne    801027 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80101c:	b8 01 00 00 00       	mov    $0x1,%eax
  801021:	31 d2                	xor    %edx,%edx
  801023:	f7 f1                	div    %ecx
  801025:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801027:	89 f0                	mov    %esi,%eax
  801029:	31 d2                	xor    %edx,%edx
  80102b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80102d:	89 f8                	mov    %edi,%eax
  80102f:	e9 3e ff ff ff       	jmp    800f72 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801034:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801036:	83 c4 20             	add    $0x20,%esp
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    
  80103d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801040:	39 f5                	cmp    %esi,%ebp
  801042:	72 04                	jb     801048 <__umoddi3+0x104>
  801044:	39 f9                	cmp    %edi,%ecx
  801046:	77 06                	ja     80104e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801048:	89 f2                	mov    %esi,%edx
  80104a:	29 cf                	sub    %ecx,%edi
  80104c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80104e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801050:	83 c4 20             	add    $0x20,%esp
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    
  801057:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801058:	89 d1                	mov    %edx,%ecx
  80105a:	89 c5                	mov    %eax,%ebp
  80105c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801060:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801064:	eb 8d                	jmp    800ff3 <__umoddi3+0xaf>
  801066:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801068:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80106c:	72 ea                	jb     801058 <__umoddi3+0x114>
  80106e:	89 f1                	mov    %esi,%ecx
  801070:	eb 81                	jmp    800ff3 <__umoddi3+0xaf>
