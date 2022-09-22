
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 24 13 00 00       	call   80137c <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 00                	mov    (%eax),%eax
  800061:	8b 40 5c             	mov    0x5c(%eax),%eax
  800064:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	c7 04 24 a0 17 80 00 	movl   $0x8017a0,(%esp)
  800073:	e8 48 02 00 00       	call   8002c0 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800078:	e8 ee 0f 00 00       	call   80106b <fork>
  80007d:	89 c7                	mov    %eax,%edi
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 20                	jns    8000a3 <primeproc+0x6f>
		panic("fork: %e", id);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 ac 17 80 	movl   $0x8017ac,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 b5 17 80 00 	movl   $0x8017b5,(%esp)
  80009e:	e8 25 01 00 00       	call   8001c8 <_panic>
	if (id == 0)
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	74 99                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a7:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b1:	00 
  8000b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b9:	00 
  8000ba:	89 34 24             	mov    %esi,(%esp)
  8000bd:	e8 ba 12 00 00       	call   80137c <ipc_recv>
  8000c2:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c4:	99                   	cltd   
  8000c5:	f7 fb                	idiv   %ebx
  8000c7:	85 d2                	test   %edx,%edx
  8000c9:	74 df                	je     8000aa <primeproc+0x76>
			ipc_send(id, i, 0, 0);
  8000cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d2:	00 
  8000d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000da:	00 
  8000db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000df:	89 3c 24             	mov    %edi,(%esp)
  8000e2:	e8 02 13 00 00       	call   8013e9 <ipc_send>
  8000e7:	eb c1                	jmp    8000aa <primeproc+0x76>

008000e9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
  8000ee:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f1:	e8 75 0f 00 00       	call   80106b <fork>
  8000f6:	89 c6                	mov    %eax,%esi
  8000f8:	85 c0                	test   %eax,%eax
  8000fa:	79 20                	jns    80011c <umain+0x33>
		panic("fork: %e", id);
  8000fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800100:	c7 44 24 08 ac 17 80 	movl   $0x8017ac,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 b5 17 80 00 	movl   $0x8017b5,(%esp)
  800117:	e8 ac 00 00 00       	call   8001c8 <_panic>
	if (id == 0)
  80011c:	bb 02 00 00 00       	mov    $0x2,%ebx
  800121:	85 c0                	test   %eax,%eax
  800123:	75 05                	jne    80012a <umain+0x41>
		primeproc();
  800125:	e8 0a ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800131:	00 
  800132:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800139:	00 
  80013a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013e:	89 34 24             	mov    %esi,(%esp)
  800141:	e8 a3 12 00 00       	call   8013e9 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800146:	43                   	inc    %ebx
  800147:	eb e1                	jmp    80012a <umain+0x41>
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
  800151:	83 ec 20             	sub    $0x20,%esp
  800154:	8b 75 08             	mov    0x8(%ebp),%esi
  800157:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80015a:	e8 c0 0a 00 00       	call   800c1f <sys_getenvid>
  80015f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800164:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80016b:	c1 e0 07             	shl    $0x7,%eax
  80016e:	29 d0                	sub    %edx,%eax
  800170:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800175:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800178:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80017b:	a3 04 20 80 00       	mov    %eax,0x802004
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  800184:	c7 04 24 a3 1a 80 00 	movl   $0x801aa3,(%esp)
  80018b:	e8 30 01 00 00       	call   8002c0 <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800190:	85 f6                	test   %esi,%esi
  800192:	7e 07                	jle    80019b <libmain+0x4f>
		binaryname = argv[0];
  800194:	8b 03                	mov    (%ebx),%eax
  800196:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80019b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80019f:	89 34 24             	mov    %esi,(%esp)
  8001a2:	e8 42 ff ff ff       	call   8000e9 <umain>

	// exit gracefully
	exit();
  8001a7:	e8 08 00 00 00       	call   8001b4 <exit>
}
  8001ac:	83 c4 20             	add    $0x20,%esp
  8001af:	5b                   	pop    %ebx
  8001b0:	5e                   	pop    %esi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    
	...

008001b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001c1:	e8 07 0a 00 00       	call   800bcd <sys_env_destroy>
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001d0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001d9:	e8 41 0a 00 00       	call   800c1f <sys_getenvid>
  8001de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 d0 17 80 00 	movl   $0x8017d0,(%esp)
  8001fb:	e8 c0 00 00 00       	call   8002c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	89 74 24 04          	mov    %esi,0x4(%esp)
  800204:	8b 45 10             	mov    0x10(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	e8 50 00 00 00       	call   80025f <vcprintf>
	cprintf("\n");
  80020f:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  800216:	e8 a5 00 00 00       	call   8002c0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x53>
	...

00800220 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	53                   	push   %ebx
  800224:	83 ec 14             	sub    $0x14,%esp
  800227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022a:	8b 03                	mov    (%ebx),%eax
  80022c:	8b 55 08             	mov    0x8(%ebp),%edx
  80022f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800233:	40                   	inc    %eax
  800234:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 19                	jne    800256 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80023d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800244:	00 
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 40 09 00 00       	call   800b90 <sys_cputs>
		b->idx = 0;
  800250:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800256:	ff 43 04             	incl   0x4(%ebx)
}
  800259:	83 c4 14             	add    $0x14,%esp
  80025c:	5b                   	pop    %ebx
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800268:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026f:	00 00 00 
	b.cnt = 0;
  800272:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800279:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800283:	8b 45 08             	mov    0x8(%ebp),%eax
  800286:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800290:	89 44 24 04          	mov    %eax,0x4(%esp)
  800294:	c7 04 24 20 02 80 00 	movl   $0x800220,(%esp)
  80029b:	e8 82 01 00 00       	call   800422 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 d8 08 00 00       	call   800b90 <sys_cputs>

	return b.cnt;
}
  8002b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	e8 87 ff ff ff       	call   80025f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d8:	c9                   	leave  
  8002d9:	c3                   	ret    
	...

008002dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	57                   	push   %edi
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 3c             	sub    $0x3c,%esp
  8002e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e8:	89 d7                	mov    %edx,%edi
  8002ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	75 08                	jne    800308 <printnum+0x2c>
  800300:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800303:	39 45 10             	cmp    %eax,0x10(%ebp)
  800306:	77 57                	ja     80035f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800308:	89 74 24 10          	mov    %esi,0x10(%esp)
  80030c:	4b                   	dec    %ebx
  80030d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800311:	8b 45 10             	mov    0x10(%ebp),%eax
  800314:	89 44 24 08          	mov    %eax,0x8(%esp)
  800318:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80031c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800320:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800327:	00 
  800328:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	e8 12 12 00 00       	call   80154c <__udivdi3>
  80033a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800342:	89 04 24             	mov    %eax,(%esp)
  800345:	89 54 24 04          	mov    %edx,0x4(%esp)
  800349:	89 fa                	mov    %edi,%edx
  80034b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034e:	e8 89 ff ff ff       	call   8002dc <printnum>
  800353:	eb 0f                	jmp    800364 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800355:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800359:	89 34 24             	mov    %esi,(%esp)
  80035c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80035f:	4b                   	dec    %ebx
  800360:	85 db                	test   %ebx,%ebx
  800362:	7f f1                	jg     800355 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800364:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800368:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80036c:	8b 45 10             	mov    0x10(%ebp),%eax
  80036f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800373:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037a:	00 
  80037b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037e:	89 04 24             	mov    %eax,(%esp)
  800381:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800384:	89 44 24 04          	mov    %eax,0x4(%esp)
  800388:	e8 df 12 00 00       	call   80166c <__umoddi3>
  80038d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800391:	0f be 80 f3 17 80 00 	movsbl 0x8017f3(%eax),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039e:	83 c4 3c             	add    $0x3c,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a9:	83 fa 01             	cmp    $0x1,%edx
  8003ac:	7e 0e                	jle    8003bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ae:	8b 10                	mov    (%eax),%edx
  8003b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b3:	89 08                	mov    %ecx,(%eax)
  8003b5:	8b 02                	mov    (%edx),%eax
  8003b7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ba:	eb 22                	jmp    8003de <getuint+0x38>
	else if (lflag)
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	74 10                	je     8003d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ce:	eb 0e                	jmp    8003de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ee:	73 08                	jae    8003f8 <sprintputch+0x18>
		*b->buf++ = ch;
  8003f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f3:	88 0a                	mov    %cl,(%edx)
  8003f5:	42                   	inc    %edx
  8003f6:	89 10                	mov    %edx,(%eax)
}
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800400:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800403:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800407:	8b 45 10             	mov    0x10(%ebp),%eax
  80040a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800411:	89 44 24 04          	mov    %eax,0x4(%esp)
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 02 00 00 00       	call   800422 <vprintfmt>
	va_end(ap);
}
  800420:	c9                   	leave  
  800421:	c3                   	ret    

00800422 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	57                   	push   %edi
  800426:	56                   	push   %esi
  800427:	53                   	push   %ebx
  800428:	83 ec 4c             	sub    $0x4c,%esp
  80042b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80042e:	8b 75 10             	mov    0x10(%ebp),%esi
  800431:	eb 12                	jmp    800445 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800433:	85 c0                	test   %eax,%eax
  800435:	0f 84 6b 03 00 00    	je     8007a6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80043b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800445:	0f b6 06             	movzbl (%esi),%eax
  800448:	46                   	inc    %esi
  800449:	83 f8 25             	cmp    $0x25,%eax
  80044c:	75 e5                	jne    800433 <vprintfmt+0x11>
  80044e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800452:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800459:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80045e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800465:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046a:	eb 26                	jmp    800492 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800473:	eb 1d                	jmp    800492 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800478:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80047c:	eb 14                	jmp    800492 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800481:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800488:	eb 08                	jmp    800492 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80048a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80048d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	0f b6 06             	movzbl (%esi),%eax
  800495:	8d 56 01             	lea    0x1(%esi),%edx
  800498:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80049b:	8a 16                	mov    (%esi),%dl
  80049d:	83 ea 23             	sub    $0x23,%edx
  8004a0:	80 fa 55             	cmp    $0x55,%dl
  8004a3:	0f 87 e1 02 00 00    	ja     80078a <vprintfmt+0x368>
  8004a9:	0f b6 d2             	movzbl %dl,%edx
  8004ac:	ff 24 95 c0 18 80 00 	jmp    *0x8018c0(,%edx,4)
  8004b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004b6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004bb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004be:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004c2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c8:	83 fa 09             	cmp    $0x9,%edx
  8004cb:	77 2a                	ja     8004f7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ce:	eb eb                	jmp    8004bb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 50 04             	lea    0x4(%eax),%edx
  8004d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004de:	eb 17                	jmp    8004f7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e4:	78 98                	js     80047e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004e9:	eb a7                	jmp    800492 <vprintfmt+0x70>
  8004eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004f5:	eb 9b                	jmp    800492 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fb:	79 95                	jns    800492 <vprintfmt+0x70>
  8004fd:	eb 8b                	jmp    80048a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ff:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800503:	eb 8d                	jmp    800492 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 50 04             	lea    0x4(%eax),%edx
  80050b:	89 55 14             	mov    %edx,0x14(%ebp)
  80050e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80051d:	e9 23 ff ff ff       	jmp    800445 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	85 c0                	test   %eax,%eax
  80052f:	79 02                	jns    800533 <vprintfmt+0x111>
  800531:	f7 d8                	neg    %eax
  800533:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800535:	83 f8 08             	cmp    $0x8,%eax
  800538:	7f 0b                	jg     800545 <vprintfmt+0x123>
  80053a:	8b 04 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%eax
  800541:	85 c0                	test   %eax,%eax
  800543:	75 23                	jne    800568 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800545:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800549:	c7 44 24 08 0b 18 80 	movl   $0x80180b,0x8(%esp)
  800550:	00 
  800551:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800555:	8b 45 08             	mov    0x8(%ebp),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	e8 9a fe ff ff       	call   8003fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800563:	e9 dd fe ff ff       	jmp    800445 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800568:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056c:	c7 44 24 08 14 18 80 	movl   $0x801814,0x8(%esp)
  800573:	00 
  800574:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800578:	8b 55 08             	mov    0x8(%ebp),%edx
  80057b:	89 14 24             	mov    %edx,(%esp)
  80057e:	e8 77 fe ff ff       	call   8003fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800583:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800586:	e9 ba fe ff ff       	jmp    800445 <vprintfmt+0x23>
  80058b:	89 f9                	mov    %edi,%ecx
  80058d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800590:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800593:	8b 45 14             	mov    0x14(%ebp),%eax
  800596:	8d 50 04             	lea    0x4(%eax),%edx
  800599:	89 55 14             	mov    %edx,0x14(%ebp)
  80059c:	8b 30                	mov    (%eax),%esi
  80059e:	85 f6                	test   %esi,%esi
  8005a0:	75 05                	jne    8005a7 <vprintfmt+0x185>
				p = "(null)";
  8005a2:	be 04 18 80 00       	mov    $0x801804,%esi
			if (width > 0 && padc != '-')
  8005a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ab:	0f 8e 84 00 00 00    	jle    800635 <vprintfmt+0x213>
  8005b1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005b5:	74 7e                	je     800635 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005bb:	89 34 24             	mov    %esi,(%esp)
  8005be:	e8 8b 02 00 00       	call   80084e <strnlen>
  8005c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005c6:	29 c2                	sub    %eax,%edx
  8005c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005cb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005cf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005d2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005d5:	89 de                	mov    %ebx,%esi
  8005d7:	89 d3                	mov    %edx,%ebx
  8005d9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005db:	eb 0b                	jmp    8005e8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e1:	89 3c 24             	mov    %edi,(%esp)
  8005e4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e7:	4b                   	dec    %ebx
  8005e8:	85 db                	test   %ebx,%ebx
  8005ea:	7f f1                	jg     8005dd <vprintfmt+0x1bb>
  8005ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005ef:	89 f3                	mov    %esi,%ebx
  8005f1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	79 05                	jns    800600 <vprintfmt+0x1de>
  8005fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800600:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800603:	29 c2                	sub    %eax,%edx
  800605:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800608:	eb 2b                	jmp    800635 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060e:	74 18                	je     800628 <vprintfmt+0x206>
  800610:	8d 50 e0             	lea    -0x20(%eax),%edx
  800613:	83 fa 5e             	cmp    $0x5e,%edx
  800616:	76 10                	jbe    800628 <vprintfmt+0x206>
					putch('?', putdat);
  800618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800623:	ff 55 08             	call   *0x8(%ebp)
  800626:	eb 0a                	jmp    800632 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062c:	89 04 24             	mov    %eax,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800632:	ff 4d e4             	decl   -0x1c(%ebp)
  800635:	0f be 06             	movsbl (%esi),%eax
  800638:	46                   	inc    %esi
  800639:	85 c0                	test   %eax,%eax
  80063b:	74 21                	je     80065e <vprintfmt+0x23c>
  80063d:	85 ff                	test   %edi,%edi
  80063f:	78 c9                	js     80060a <vprintfmt+0x1e8>
  800641:	4f                   	dec    %edi
  800642:	79 c6                	jns    80060a <vprintfmt+0x1e8>
  800644:	8b 7d 08             	mov    0x8(%ebp),%edi
  800647:	89 de                	mov    %ebx,%esi
  800649:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80064c:	eb 18                	jmp    800666 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800652:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800659:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065b:	4b                   	dec    %ebx
  80065c:	eb 08                	jmp    800666 <vprintfmt+0x244>
  80065e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800661:	89 de                	mov    %ebx,%esi
  800663:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800666:	85 db                	test   %ebx,%ebx
  800668:	7f e4                	jg     80064e <vprintfmt+0x22c>
  80066a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80066d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800672:	e9 ce fd ff ff       	jmp    800445 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800677:	83 f9 01             	cmp    $0x1,%ecx
  80067a:	7e 10                	jle    80068c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 08             	lea    0x8(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	8b 30                	mov    (%eax),%esi
  800687:	8b 78 04             	mov    0x4(%eax),%edi
  80068a:	eb 26                	jmp    8006b2 <vprintfmt+0x290>
	else if (lflag)
  80068c:	85 c9                	test   %ecx,%ecx
  80068e:	74 12                	je     8006a2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)
  800699:	8b 30                	mov    (%eax),%esi
  80069b:	89 f7                	mov    %esi,%edi
  80069d:	c1 ff 1f             	sar    $0x1f,%edi
  8006a0:	eb 10                	jmp    8006b2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 50 04             	lea    0x4(%eax),%edx
  8006a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ab:	8b 30                	mov    (%eax),%esi
  8006ad:	89 f7                	mov    %esi,%edi
  8006af:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b2:	85 ff                	test   %edi,%edi
  8006b4:	78 0a                	js     8006c0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bb:	e9 8c 00 00 00       	jmp    80074c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ce:	f7 de                	neg    %esi
  8006d0:	83 d7 00             	adc    $0x0,%edi
  8006d3:	f7 df                	neg    %edi
			}
			base = 10;
  8006d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006da:	eb 70                	jmp    80074c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006dc:	89 ca                	mov    %ecx,%edx
  8006de:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e1:	e8 c0 fc ff ff       	call   8003a6 <getuint>
  8006e6:	89 c6                	mov    %eax,%esi
  8006e8:	89 d7                	mov    %edx,%edi
			base = 10;
  8006ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006ef:	eb 5b                	jmp    80074c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006f1:	89 ca                	mov    %ecx,%edx
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 ab fc ff ff       	call   8003a6 <getuint>
  8006fb:	89 c6                	mov    %eax,%esi
  8006fd:	89 d7                	mov    %edx,%edi
			base = 8;
  8006ff:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800704:	eb 46                	jmp    80074c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800706:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800711:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800718:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8d 50 04             	lea    0x4(%eax),%edx
  800728:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072b:	8b 30                	mov    (%eax),%esi
  80072d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800732:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800737:	eb 13                	jmp    80074c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800739:	89 ca                	mov    %ecx,%edx
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	e8 63 fc ff ff       	call   8003a6 <getuint>
  800743:	89 c6                	mov    %eax,%esi
  800745:	89 d7                	mov    %edx,%edi
			base = 16;
  800747:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800750:	89 54 24 10          	mov    %edx,0x10(%esp)
  800754:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800757:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80075b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075f:	89 34 24             	mov    %esi,(%esp)
  800762:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800766:	89 da                	mov    %ebx,%edx
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	e8 6c fb ff ff       	call   8002dc <printnum>
			break;
  800770:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800773:	e9 cd fc ff ff       	jmp    800445 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077c:	89 04 24             	mov    %eax,(%esp)
  80077f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800785:	e9 bb fc ff ff       	jmp    800445 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800795:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800798:	eb 01                	jmp    80079b <vprintfmt+0x379>
  80079a:	4e                   	dec    %esi
  80079b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80079f:	75 f9                	jne    80079a <vprintfmt+0x378>
  8007a1:	e9 9f fc ff ff       	jmp    800445 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007a6:	83 c4 4c             	add    $0x4c,%esp
  8007a9:	5b                   	pop    %ebx
  8007aa:	5e                   	pop    %esi
  8007ab:	5f                   	pop    %edi
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	83 ec 28             	sub    $0x28,%esp
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	74 30                	je     8007ff <vsnprintf+0x51>
  8007cf:	85 d2                	test   %edx,%edx
  8007d1:	7e 33                	jle    800806 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007da:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  8007ef:	e8 2e fc ff ff       	call   800422 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fd:	eb 0c                	jmp    80080b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800804:	eb 05                	jmp    80080b <vsnprintf+0x5d>
  800806:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80080b:	c9                   	leave  
  80080c:	c3                   	ret    

0080080d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800813:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800816:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081a:	8b 45 10             	mov    0x10(%ebp),%eax
  80081d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800821:	8b 45 0c             	mov    0xc(%ebp),%eax
  800824:	89 44 24 04          	mov    %eax,0x4(%esp)
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	89 04 24             	mov    %eax,(%esp)
  80082e:	e8 7b ff ff ff       	call   8007ae <vsnprintf>
	va_end(ap);

	return rc;
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    
  800835:	00 00                	add    %al,(%eax)
	...

00800838 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
  800843:	eb 01                	jmp    800846 <strlen+0xe>
		n++;
  800845:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084a:	75 f9                	jne    800845 <strlen+0xd>
		n++;
	return n;
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
  80085c:	eb 01                	jmp    80085f <strnlen+0x11>
		n++;
  80085e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085f:	39 d0                	cmp    %edx,%eax
  800861:	74 06                	je     800869 <strnlen+0x1b>
  800863:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800867:	75 f5                	jne    80085e <strnlen+0x10>
		n++;
	return n;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800875:	ba 00 00 00 00       	mov    $0x0,%edx
  80087a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80087d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800880:	42                   	inc    %edx
  800881:	84 c9                	test   %cl,%cl
  800883:	75 f5                	jne    80087a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800892:	89 1c 24             	mov    %ebx,(%esp)
  800895:	e8 9e ff ff ff       	call   800838 <strlen>
	strcpy(dst + len, src);
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a1:	01 d8                	add    %ebx,%eax
  8008a3:	89 04 24             	mov    %eax,(%esp)
  8008a6:	e8 c0 ff ff ff       	call   80086b <strcpy>
	return dst;
}
  8008ab:	89 d8                	mov    %ebx,%eax
  8008ad:	83 c4 08             	add    $0x8,%esp
  8008b0:	5b                   	pop    %ebx
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	56                   	push   %esi
  8008b7:	53                   	push   %ebx
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c6:	eb 0c                	jmp    8008d4 <strncpy+0x21>
		*dst++ = *src;
  8008c8:	8a 1a                	mov    (%edx),%bl
  8008ca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008cd:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d3:	41                   	inc    %ecx
  8008d4:	39 f1                	cmp    %esi,%ecx
  8008d6:	75 f0                	jne    8008c8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ea:	85 d2                	test   %edx,%edx
  8008ec:	75 0a                	jne    8008f8 <strlcpy+0x1c>
  8008ee:	89 f0                	mov    %esi,%eax
  8008f0:	eb 1a                	jmp    80090c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f2:	88 18                	mov    %bl,(%eax)
  8008f4:	40                   	inc    %eax
  8008f5:	41                   	inc    %ecx
  8008f6:	eb 02                	jmp    8008fa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008fa:	4a                   	dec    %edx
  8008fb:	74 0a                	je     800907 <strlcpy+0x2b>
  8008fd:	8a 19                	mov    (%ecx),%bl
  8008ff:	84 db                	test   %bl,%bl
  800901:	75 ef                	jne    8008f2 <strlcpy+0x16>
  800903:	89 c2                	mov    %eax,%edx
  800905:	eb 02                	jmp    800909 <strlcpy+0x2d>
  800907:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800909:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80090c:	29 f0                	sub    %esi,%eax
}
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091b:	eb 02                	jmp    80091f <strcmp+0xd>
		p++, q++;
  80091d:	41                   	inc    %ecx
  80091e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091f:	8a 01                	mov    (%ecx),%al
  800921:	84 c0                	test   %al,%al
  800923:	74 04                	je     800929 <strcmp+0x17>
  800925:	3a 02                	cmp    (%edx),%al
  800927:	74 f4                	je     80091d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800929:	0f b6 c0             	movzbl %al,%eax
  80092c:	0f b6 12             	movzbl (%edx),%edx
  80092f:	29 d0                	sub    %edx,%eax
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800940:	eb 03                	jmp    800945 <strncmp+0x12>
		n--, p++, q++;
  800942:	4a                   	dec    %edx
  800943:	40                   	inc    %eax
  800944:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800945:	85 d2                	test   %edx,%edx
  800947:	74 14                	je     80095d <strncmp+0x2a>
  800949:	8a 18                	mov    (%eax),%bl
  80094b:	84 db                	test   %bl,%bl
  80094d:	74 04                	je     800953 <strncmp+0x20>
  80094f:	3a 19                	cmp    (%ecx),%bl
  800951:	74 ef                	je     800942 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800953:	0f b6 00             	movzbl (%eax),%eax
  800956:	0f b6 11             	movzbl (%ecx),%edx
  800959:	29 d0                	sub    %edx,%eax
  80095b:	eb 05                	jmp    800962 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800962:	5b                   	pop    %ebx
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80096e:	eb 05                	jmp    800975 <strchr+0x10>
		if (*s == c)
  800970:	38 ca                	cmp    %cl,%dl
  800972:	74 0c                	je     800980 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800974:	40                   	inc    %eax
  800975:	8a 10                	mov    (%eax),%dl
  800977:	84 d2                	test   %dl,%dl
  800979:	75 f5                	jne    800970 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80098b:	eb 05                	jmp    800992 <strfind+0x10>
		if (*s == c)
  80098d:	38 ca                	cmp    %cl,%dl
  80098f:	74 07                	je     800998 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800991:	40                   	inc    %eax
  800992:	8a 10                	mov    (%eax),%dl
  800994:	84 d2                	test   %dl,%dl
  800996:	75 f5                	jne    80098d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	57                   	push   %edi
  80099e:	56                   	push   %esi
  80099f:	53                   	push   %ebx
  8009a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a9:	85 c9                	test   %ecx,%ecx
  8009ab:	74 30                	je     8009dd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b3:	75 25                	jne    8009da <memset+0x40>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 20                	jne    8009da <memset+0x40>
		c &= 0xFF;
  8009ba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bd:	89 d3                	mov    %edx,%ebx
  8009bf:	c1 e3 08             	shl    $0x8,%ebx
  8009c2:	89 d6                	mov    %edx,%esi
  8009c4:	c1 e6 18             	shl    $0x18,%esi
  8009c7:	89 d0                	mov    %edx,%eax
  8009c9:	c1 e0 10             	shl    $0x10,%eax
  8009cc:	09 f0                	or     %esi,%eax
  8009ce:	09 d0                	or     %edx,%eax
  8009d0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d5:	fc                   	cld    
  8009d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d8:	eb 03                	jmp    8009dd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009da:	fc                   	cld    
  8009db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009dd:	89 f8                	mov    %edi,%eax
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f2:	39 c6                	cmp    %eax,%esi
  8009f4:	73 34                	jae    800a2a <memmove+0x46>
  8009f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f9:	39 d0                	cmp    %edx,%eax
  8009fb:	73 2d                	jae    800a2a <memmove+0x46>
		s += n;
		d += n;
  8009fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a00:	f6 c2 03             	test   $0x3,%dl
  800a03:	75 1b                	jne    800a20 <memmove+0x3c>
  800a05:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0b:	75 13                	jne    800a20 <memmove+0x3c>
  800a0d:	f6 c1 03             	test   $0x3,%cl
  800a10:	75 0e                	jne    800a20 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a12:	83 ef 04             	sub    $0x4,%edi
  800a15:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a18:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a1b:	fd                   	std    
  800a1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1e:	eb 07                	jmp    800a27 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a20:	4f                   	dec    %edi
  800a21:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a24:	fd                   	std    
  800a25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a27:	fc                   	cld    
  800a28:	eb 20                	jmp    800a4a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a30:	75 13                	jne    800a45 <memmove+0x61>
  800a32:	a8 03                	test   $0x3,%al
  800a34:	75 0f                	jne    800a45 <memmove+0x61>
  800a36:	f6 c1 03             	test   $0x3,%cl
  800a39:	75 0a                	jne    800a45 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a3e:	89 c7                	mov    %eax,%edi
  800a40:	fc                   	cld    
  800a41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a43:	eb 05                	jmp    800a4a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a45:	89 c7                	mov    %eax,%edi
  800a47:	fc                   	cld    
  800a48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a54:	8b 45 10             	mov    0x10(%ebp),%eax
  800a57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	89 04 24             	mov    %eax,(%esp)
  800a68:	e8 77 ff ff ff       	call   8009e4 <memmove>
}
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a83:	eb 16                	jmp    800a9b <memcmp+0x2c>
		if (*s1 != *s2)
  800a85:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a88:	42                   	inc    %edx
  800a89:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a8d:	38 c8                	cmp    %cl,%al
  800a8f:	74 0a                	je     800a9b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a91:	0f b6 c0             	movzbl %al,%eax
  800a94:	0f b6 c9             	movzbl %cl,%ecx
  800a97:	29 c8                	sub    %ecx,%eax
  800a99:	eb 09                	jmp    800aa4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9b:	39 da                	cmp    %ebx,%edx
  800a9d:	75 e6                	jne    800a85 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab7:	eb 05                	jmp    800abe <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab9:	38 08                	cmp    %cl,(%eax)
  800abb:	74 05                	je     800ac2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800abd:	40                   	inc    %eax
  800abe:	39 d0                	cmp    %edx,%eax
  800ac0:	72 f7                	jb     800ab9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	8b 55 08             	mov    0x8(%ebp),%edx
  800acd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad0:	eb 01                	jmp    800ad3 <strtol+0xf>
		s++;
  800ad2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad3:	8a 02                	mov    (%edx),%al
  800ad5:	3c 20                	cmp    $0x20,%al
  800ad7:	74 f9                	je     800ad2 <strtol+0xe>
  800ad9:	3c 09                	cmp    $0x9,%al
  800adb:	74 f5                	je     800ad2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800add:	3c 2b                	cmp    $0x2b,%al
  800adf:	75 08                	jne    800ae9 <strtol+0x25>
		s++;
  800ae1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae7:	eb 13                	jmp    800afc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae9:	3c 2d                	cmp    $0x2d,%al
  800aeb:	75 0a                	jne    800af7 <strtol+0x33>
		s++, neg = 1;
  800aed:	8d 52 01             	lea    0x1(%edx),%edx
  800af0:	bf 01 00 00 00       	mov    $0x1,%edi
  800af5:	eb 05                	jmp    800afc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afc:	85 db                	test   %ebx,%ebx
  800afe:	74 05                	je     800b05 <strtol+0x41>
  800b00:	83 fb 10             	cmp    $0x10,%ebx
  800b03:	75 28                	jne    800b2d <strtol+0x69>
  800b05:	8a 02                	mov    (%edx),%al
  800b07:	3c 30                	cmp    $0x30,%al
  800b09:	75 10                	jne    800b1b <strtol+0x57>
  800b0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b0f:	75 0a                	jne    800b1b <strtol+0x57>
		s += 2, base = 16;
  800b11:	83 c2 02             	add    $0x2,%edx
  800b14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b19:	eb 12                	jmp    800b2d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b1b:	85 db                	test   %ebx,%ebx
  800b1d:	75 0e                	jne    800b2d <strtol+0x69>
  800b1f:	3c 30                	cmp    $0x30,%al
  800b21:	75 05                	jne    800b28 <strtol+0x64>
		s++, base = 8;
  800b23:	42                   	inc    %edx
  800b24:	b3 08                	mov    $0x8,%bl
  800b26:	eb 05                	jmp    800b2d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b28:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b34:	8a 0a                	mov    (%edx),%cl
  800b36:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b39:	80 fb 09             	cmp    $0x9,%bl
  800b3c:	77 08                	ja     800b46 <strtol+0x82>
			dig = *s - '0';
  800b3e:	0f be c9             	movsbl %cl,%ecx
  800b41:	83 e9 30             	sub    $0x30,%ecx
  800b44:	eb 1e                	jmp    800b64 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b46:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b49:	80 fb 19             	cmp    $0x19,%bl
  800b4c:	77 08                	ja     800b56 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b4e:	0f be c9             	movsbl %cl,%ecx
  800b51:	83 e9 57             	sub    $0x57,%ecx
  800b54:	eb 0e                	jmp    800b64 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b56:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 12                	ja     800b70 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b5e:	0f be c9             	movsbl %cl,%ecx
  800b61:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b64:	39 f1                	cmp    %esi,%ecx
  800b66:	7d 0c                	jge    800b74 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b68:	42                   	inc    %edx
  800b69:	0f af c6             	imul   %esi,%eax
  800b6c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b6e:	eb c4                	jmp    800b34 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b70:	89 c1                	mov    %eax,%ecx
  800b72:	eb 02                	jmp    800b76 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b74:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7a:	74 05                	je     800b81 <strtol+0xbd>
		*endptr = (char *) s;
  800b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b7f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b81:	85 ff                	test   %edi,%edi
  800b83:	74 04                	je     800b89 <strtol+0xc5>
  800b85:	89 c8                	mov    %ecx,%eax
  800b87:	f7 d8                	neg    %eax
}
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    
	...

00800b90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	89 c3                	mov    %eax,%ebx
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	89 c6                	mov    %eax,%esi
  800ba7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_cgetc>:

int
sys_cgetc(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdb:	b8 03 00 00 00       	mov    $0x3,%eax
  800be0:	8b 55 08             	mov    0x8(%ebp),%edx
  800be3:	89 cb                	mov    %ecx,%ebx
  800be5:	89 cf                	mov    %ecx,%edi
  800be7:	89 ce                	mov    %ecx,%esi
  800be9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800beb:	85 c0                	test   %eax,%eax
  800bed:	7e 28                	jle    800c17 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bfa:	00 
  800bfb:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800c02:	00 
  800c03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0a:	00 
  800c0b:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800c12:	e8 b1 f5 ff ff       	call   8001c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c17:	83 c4 2c             	add    $0x2c,%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2f:	89 d1                	mov    %edx,%ecx
  800c31:	89 d3                	mov    %edx,%ebx
  800c33:	89 d7                	mov    %edx,%edi
  800c35:	89 d6                	mov    %edx,%esi
  800c37:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_yield>:

void
sys_yield(void)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	ba 00 00 00 00       	mov    $0x0,%edx
  800c49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4e:	89 d1                	mov    %edx,%ecx
  800c50:	89 d3                	mov    %edx,%ebx
  800c52:	89 d7                	mov    %edx,%edi
  800c54:	89 d6                	mov    %edx,%esi
  800c56:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	be 00 00 00 00       	mov    $0x0,%esi
  800c6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 f7                	mov    %esi,%edi
  800c7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 28                	jle    800ca9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c85:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c8c:	00 
  800c8d:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800c94:	00 
  800c95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9c:	00 
  800c9d:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800ca4:	e8 1f f5 ff ff       	call   8001c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca9:	83 c4 2c             	add    $0x2c,%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	b8 05 00 00 00       	mov    $0x5,%eax
  800cbf:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7e 28                	jle    800cfc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800ce7:	00 
  800ce8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cef:	00 
  800cf0:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800cf7:	e8 cc f4 ff ff       	call   8001c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cfc:	83 c4 2c             	add    $0x2c,%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 06 00 00 00       	mov    $0x6,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 28                	jle    800d4f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d32:	00 
  800d33:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d42:	00 
  800d43:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800d4a:	e8 79 f4 ff ff       	call   8001c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4f:	83 c4 2c             	add    $0x2c,%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d65:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d70:	89 df                	mov    %ebx,%edi
  800d72:	89 de                	mov    %ebx,%esi
  800d74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7e 28                	jle    800da2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d85:	00 
  800d86:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800d8d:	00 
  800d8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d95:	00 
  800d96:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800d9d:	e8 26 f4 ff ff       	call   8001c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da2:	83 c4 2c             	add    $0x2c,%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 28                	jle    800df5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800df0:	e8 d3 f3 ff ff       	call   8001c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df5:	83 c4 2c             	add    $0x2c,%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e03:	be 00 00 00 00       	mov    $0x0,%esi
  800e08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e0d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	89 cb                	mov    %ecx,%ebx
  800e38:	89 cf                	mov    %ecx,%edi
  800e3a:	89 ce                	mov    %ecx,%esi
  800e3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7e 28                	jle    800e6a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e46:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  800e55:	00 
  800e56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5d:	00 
  800e5e:	c7 04 24 61 1a 80 00 	movl   $0x801a61,(%esp)
  800e65:	e8 5e f3 ff ff       	call   8001c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6a:	83 c4 2c             	add    $0x2c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
	...

00800e74 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
  800e7a:	83 ec 3c             	sub    $0x3c,%esp
  800e7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800e85:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800e8f:	e8 8b fd ff ff       	call   800c1f <sys_getenvid>
  800e94:	89 c7                	mov    %eax,%edi
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800e96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e99:	25 02 08 00 00       	and    $0x802,%eax
  800e9e:	83 f8 01             	cmp    $0x1,%eax
  800ea1:	19 db                	sbb    %ebx,%ebx
  800ea3:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800ea9:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800eaf:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800eb3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800eb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ebe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ec2:	89 3c 24             	mov    %edi,(%esp)
  800ec5:	e8 e7 fd ff ff       	call   800cb1 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	79 1c                	jns    800eea <duppage+0x76>
  800ece:	c7 44 24 08 6f 1a 80 	movl   $0x801a6f,0x8(%esp)
  800ed5:	00 
  800ed6:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  800edd:	00 
  800ede:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800ee5:	e8 de f2 ff ff       	call   8001c8 <_panic>
	if ((perm|~pte)&PTE_COW){
  800eea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eed:	f7 d0                	not    %eax
  800eef:	09 d8                	or     %ebx,%eax
  800ef1:	f6 c4 08             	test   $0x8,%ah
  800ef4:	74 38                	je     800f2e <duppage+0xba>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800ef6:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800efa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800efe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f02:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f06:	89 3c 24             	mov    %edi,(%esp)
  800f09:	e8 a3 fd ff ff       	call   800cb1 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	79 1c                	jns    800f2e <duppage+0xba>
  800f12:	c7 44 24 08 6f 1a 80 	movl   $0x801a6f,0x8(%esp)
  800f19:	00 
  800f1a:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  800f21:	00 
  800f22:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800f29:	e8 9a f2 ff ff       	call   8001c8 <_panic>
	}
	return 0;
	panic("duppage not implemented");
	return 0;
}
  800f2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f33:	83 c4 3c             	add    $0x3c,%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 20             	sub    $0x20,%esp
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f46:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800f48:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f4c:	75 1c                	jne    800f6a <pgfault+0x2f>
		panic("pgfault: error!\n");
  800f4e:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  800f55:	00 
  800f56:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f5d:	00 
  800f5e:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800f65:	e8 5e f2 ff ff       	call   8001c8 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800f6a:	89 f0                	mov    %esi,%eax
  800f6c:	c1 e8 0c             	shr    $0xc,%eax
  800f6f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f76:	f6 c4 08             	test   $0x8,%ah
  800f79:	75 1c                	jne    800f97 <pgfault+0x5c>
		panic("pgfault: error!\n");
  800f7b:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  800f82:	00 
  800f83:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800f8a:	00 
  800f8b:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800f92:	e8 31 f2 ff ff       	call   8001c8 <_panic>
	envid_t envid = sys_getenvid();
  800f97:	e8 83 fc ff ff       	call   800c1f <sys_getenvid>
  800f9c:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800f9e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fa5:	00 
  800fa6:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fad:	00 
  800fae:	89 04 24             	mov    %eax,(%esp)
  800fb1:	e8 a7 fc ff ff       	call   800c5d <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	79 1c                	jns    800fd6 <pgfault+0x9b>
  800fba:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800fc9:	00 
  800fca:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  800fd1:	e8 f2 f1 ff ff       	call   8001c8 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800fd6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  800fdc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fe3:	00 
  800fe4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe8:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fef:	e8 5a fa ff ff       	call   800a4e <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  800ff4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ffb:	00 
  800ffc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801000:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801004:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80100b:	00 
  80100c:	89 1c 24             	mov    %ebx,(%esp)
  80100f:	e8 9d fc ff ff       	call   800cb1 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801014:	85 c0                	test   %eax,%eax
  801016:	79 1c                	jns    801034 <pgfault+0xf9>
  801018:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  80101f:	00 
  801020:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801027:	00 
  801028:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  80102f:	e8 94 f1 ff ff       	call   8001c8 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801034:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80103b:	00 
  80103c:	89 1c 24             	mov    %ebx,(%esp)
  80103f:	e8 c0 fc ff ff       	call   800d04 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  801044:	85 c0                	test   %eax,%eax
  801046:	79 1c                	jns    801064 <pgfault+0x129>
  801048:	c7 44 24 08 8b 1a 80 	movl   $0x801a8b,0x8(%esp)
  80104f:	00 
  801050:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801057:	00 
  801058:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  80105f:	e8 64 f1 ff ff       	call   8001c8 <_panic>
	return;
	panic("pgfault not implemented");
}
  801064:	83 c4 20             	add    $0x20,%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801074:	c7 04 24 3b 0f 80 00 	movl   $0x800f3b,(%esp)
  80107b:	e8 14 04 00 00       	call   801494 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801080:	bf 07 00 00 00       	mov    $0x7,%edi
  801085:	89 f8                	mov    %edi,%eax
  801087:	cd 30                	int    $0x30
  801089:	89 c7                	mov    %eax,%edi
  80108b:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 1c                	jns    8010ad <fork+0x42>
		panic("fork : error!\n");
  801091:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  801098:	00 
  801099:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  8010a8:	e8 1b f1 ff ff       	call   8001c8 <_panic>
	if (envid==0){
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	75 28                	jne    8010d9 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  8010b1:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  8010b7:	e8 63 fb ff ff       	call   800c1f <sys_getenvid>
  8010bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010c8:	c1 e0 07             	shl    $0x7,%eax
  8010cb:	29 d0                	sub    %edx,%eax
  8010cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d2:	89 03                	mov    %eax,(%ebx)
		return envid;
  8010d4:	e9 f2 00 00 00       	jmp    8011cb <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  8010d9:	e8 41 fb ff ff       	call   800c1f <sys_getenvid>
  8010de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8010e1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  8010e6:	89 d8                	mov    %ebx,%eax
  8010e8:	c1 e8 16             	shr    $0x16,%eax
  8010eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f2:	a8 01                	test   $0x1,%al
  8010f4:	74 17                	je     80110d <fork+0xa2>
  8010f6:	89 da                	mov    %ebx,%edx
  8010f8:	c1 ea 0c             	shr    $0xc,%edx
  8010fb:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801102:	a8 01                	test   $0x1,%al
  801104:	74 07                	je     80110d <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801106:	89 f0                	mov    %esi,%eax
  801108:	e8 67 fd ff ff       	call   800e74 <duppage>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80110d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801113:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801119:	75 cb                	jne    8010e6 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  80111b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801122:	00 
  801123:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80112a:	ee 
  80112b:	89 3c 24             	mov    %edi,(%esp)
  80112e:	e8 2a fb ff ff       	call   800c5d <sys_page_alloc>
  801133:	85 c0                	test   %eax,%eax
  801135:	79 1c                	jns    801153 <fork+0xe8>
  801137:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  80113e:	00 
  80113f:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  801146:	00 
  801147:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  80114e:	e8 75 f0 ff ff       	call   8001c8 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  801153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801156:	25 ff 03 00 00       	and    $0x3ff,%eax
  80115b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801162:	c1 e0 07             	shl    $0x7,%eax
  801165:	29 d0                	sub    %edx,%eax
  801167:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80116c:	8b 40 64             	mov    0x64(%eax),%eax
  80116f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801173:	89 3c 24             	mov    %edi,(%esp)
  801176:	e8 2f fc ff ff       	call   800daa <sys_env_set_pgfault_upcall>
  80117b:	85 c0                	test   %eax,%eax
  80117d:	79 1c                	jns    80119b <fork+0x130>
  80117f:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  801186:	00 
  801187:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  80118e:	00 
  80118f:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  801196:	e8 2d f0 ff ff       	call   8001c8 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  80119b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011a2:	00 
  8011a3:	89 3c 24             	mov    %edi,(%esp)
  8011a6:	e8 ac fb ff ff       	call   800d57 <sys_env_set_status>
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 1c                	jns    8011cb <fork+0x160>
  8011af:	c7 44 24 08 a8 1a 80 	movl   $0x801aa8,0x8(%esp)
  8011b6:	00 
  8011b7:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  8011be:	00 
  8011bf:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  8011c6:	e8 fd ef ff ff       	call   8001c8 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  8011cb:	89 f8                	mov    %edi,%eax
  8011cd:	83 c4 2c             	add    $0x2c,%esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5e                   	pop    %esi
  8011d2:	5f                   	pop    %edi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <sfork>:

// Challenge!
int
sfork(void)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8011de:	c7 04 24 3b 0f 80 00 	movl   $0x800f3b,(%esp)
  8011e5:	e8 aa 02 00 00       	call   801494 <set_pgfault_handler>
  8011ea:	ba 07 00 00 00       	mov    $0x7,%edx
  8011ef:	89 d0                	mov    %edx,%eax
  8011f1:	cd 30                	int    $0x30
  8011f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011f6:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  8011f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fc:	c7 04 24 9c 1a 80 00 	movl   $0x801a9c,(%esp)
  801203:	e8 b8 f0 ff ff       	call   8002c0 <cprintf>
	if (envid<0)
  801208:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80120c:	79 1c                	jns    80122a <sfork+0x55>
		panic("sfork : error!\n");
  80120e:	c7 44 24 08 a7 1a 80 	movl   $0x801aa7,0x8(%esp)
  801215:	00 
  801216:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80121d:	00 
  80121e:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  801225:	e8 9e ef ff ff       	call   8001c8 <_panic>
	if (envid==0){
  80122a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80122e:	75 28                	jne    801258 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  801230:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  801236:	e8 e4 f9 ff ff       	call   800c1f <sys_getenvid>
  80123b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801240:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801247:	c1 e0 07             	shl    $0x7,%eax
  80124a:	29 d0                	sub    %edx,%eax
  80124c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801251:	89 03                	mov    %eax,(%ebx)
		return envid;
  801253:	e9 18 01 00 00       	jmp    801370 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801258:	e8 c2 f9 ff ff       	call   800c1f <sys_getenvid>
  80125d:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80125f:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801264:	89 d8                	mov    %ebx,%eax
  801266:	c1 e8 16             	shr    $0x16,%eax
  801269:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801270:	a8 01                	test   $0x1,%al
  801272:	74 2c                	je     8012a0 <sfork+0xcb>
  801274:	89 d8                	mov    %ebx,%eax
  801276:	c1 e8 0c             	shr    $0xc,%eax
  801279:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801280:	a8 01                	test   $0x1,%al
  801282:	74 1c                	je     8012a0 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  801284:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80128b:	00 
  80128c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801290:	89 74 24 08          	mov    %esi,0x8(%esp)
  801294:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801298:	89 3c 24             	mov    %edi,(%esp)
  80129b:	e8 11 fa ff ff       	call   800cb1 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8012a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012a6:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8012ac:	75 b6                	jne    801264 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  8012ae:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  8012b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b6:	e8 b9 fb ff ff       	call   800e74 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  8012bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012c2:	00 
  8012c3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012ca:	ee 
  8012cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ce:	89 04 24             	mov    %eax,(%esp)
  8012d1:	e8 87 f9 ff ff       	call   800c5d <sys_page_alloc>
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	79 1c                	jns    8012f6 <sfork+0x121>
  8012da:	c7 44 24 08 a7 1a 80 	movl   $0x801aa7,0x8(%esp)
  8012e1:	00 
  8012e2:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8012e9:	00 
  8012ea:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  8012f1:	e8 d2 ee ff ff       	call   8001c8 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  8012f6:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  8012fc:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801303:	c1 e7 07             	shl    $0x7,%edi
  801306:	29 d7                	sub    %edx,%edi
  801308:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80130e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801312:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801315:	89 04 24             	mov    %eax,(%esp)
  801318:	e8 8d fa ff ff       	call   800daa <sys_env_set_pgfault_upcall>
  80131d:	85 c0                	test   %eax,%eax
  80131f:	79 1c                	jns    80133d <sfork+0x168>
  801321:	c7 44 24 08 a7 1a 80 	movl   $0x801aa7,0x8(%esp)
  801328:	00 
  801329:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  801330:	00 
  801331:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  801338:	e8 8b ee ff ff       	call   8001c8 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  80133d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801344:	00 
  801345:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801348:	89 04 24             	mov    %eax,(%esp)
  80134b:	e8 07 fa ff ff       	call   800d57 <sys_env_set_status>
  801350:	85 c0                	test   %eax,%eax
  801352:	79 1c                	jns    801370 <sfork+0x19b>
  801354:	c7 44 24 08 a7 1a 80 	movl   $0x801aa7,0x8(%esp)
  80135b:	00 
  80135c:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  801363:	00 
  801364:	c7 04 24 80 1a 80 00 	movl   $0x801a80,(%esp)
  80136b:	e8 58 ee ff ff       	call   8001c8 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  801370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801373:	83 c4 3c             	add    $0x3c,%esp
  801376:	5b                   	pop    %ebx
  801377:	5e                   	pop    %esi
  801378:	5f                   	pop    %edi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    
	...

0080137c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	83 ec 10             	sub    $0x10,%esp
  801384:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801387:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	
	if (pg==NULL)pg=(void *)UTOP;
  80138d:	85 c0                	test   %eax,%eax
  80138f:	75 05                	jne    801396 <ipc_recv+0x1a>
  801391:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801396:	89 04 24             	mov    %eax,(%esp)
  801399:	e8 82 fa ff ff       	call   800e20 <sys_ipc_recv>
	// cprintf("%x\n",err);
	if (err < 0){
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	79 16                	jns    8013b8 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  8013a2:	85 db                	test   %ebx,%ebx
  8013a4:	74 06                	je     8013ac <ipc_recv+0x30>
  8013a6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  8013ac:	85 f6                	test   %esi,%esi
  8013ae:	74 32                	je     8013e2 <ipc_recv+0x66>
  8013b0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8013b6:	eb 2a                	jmp    8013e2 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8013b8:	85 db                	test   %ebx,%ebx
  8013ba:	74 0c                	je     8013c8 <ipc_recv+0x4c>
  8013bc:	a1 04 20 80 00       	mov    0x802004,%eax
  8013c1:	8b 00                	mov    (%eax),%eax
  8013c3:	8b 40 74             	mov    0x74(%eax),%eax
  8013c6:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8013c8:	85 f6                	test   %esi,%esi
  8013ca:	74 0c                	je     8013d8 <ipc_recv+0x5c>
  8013cc:	a1 04 20 80 00       	mov    0x802004,%eax
  8013d1:	8b 00                	mov    (%eax),%eax
  8013d3:	8b 40 78             	mov    0x78(%eax),%eax
  8013d6:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  8013d8:	a1 04 20 80 00       	mov    0x802004,%eax
  8013dd:	8b 00                	mov    (%eax),%eax
  8013df:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5e                   	pop    %esi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	57                   	push   %edi
  8013ed:	56                   	push   %esi
  8013ee:	53                   	push   %ebx
  8013ef:	83 ec 1c             	sub    $0x1c,%esp
  8013f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013f8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8013fb:	85 db                	test   %ebx,%ebx
  8013fd:	75 05                	jne    801404 <ipc_send+0x1b>
  8013ff:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801404:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801408:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80140c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	89 04 24             	mov    %eax,(%esp)
  801416:	e8 e2 f9 ff ff       	call   800dfd <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  80141b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80141e:	75 07                	jne    801427 <ipc_send+0x3e>
  801420:	e8 19 f8 ff ff       	call   800c3e <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801425:	eb dd                	jmp    801404 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801427:	85 c0                	test   %eax,%eax
  801429:	79 1c                	jns    801447 <ipc_send+0x5e>
  80142b:	c7 44 24 08 b7 1a 80 	movl   $0x801ab7,0x8(%esp)
  801432:	00 
  801433:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80143a:	00 
  80143b:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  801442:	e8 81 ed ff ff       	call   8001c8 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801447:	83 c4 1c             	add    $0x1c,%esp
  80144a:	5b                   	pop    %ebx
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	53                   	push   %ebx
  801453:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801456:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80145b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801462:	89 c2                	mov    %eax,%edx
  801464:	c1 e2 07             	shl    $0x7,%edx
  801467:	29 ca                	sub    %ecx,%edx
  801469:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80146f:	8b 52 50             	mov    0x50(%edx),%edx
  801472:	39 da                	cmp    %ebx,%edx
  801474:	75 0f                	jne    801485 <ipc_find_env+0x36>
			return envs[i].env_id;
  801476:	c1 e0 07             	shl    $0x7,%eax
  801479:	29 c8                	sub    %ecx,%eax
  80147b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801480:	8b 40 40             	mov    0x40(%eax),%eax
  801483:	eb 0c                	jmp    801491 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801485:	40                   	inc    %eax
  801486:	3d 00 04 00 00       	cmp    $0x400,%eax
  80148b:	75 ce                	jne    80145b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80148d:	66 b8 00 00          	mov    $0x0,%ax
}
  801491:	5b                   	pop    %ebx
  801492:	5d                   	pop    %ebp
  801493:	c3                   	ret    

00801494 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80149b:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8014a2:	75 6f                	jne    801513 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8014a4:	e8 76 f7 ff ff       	call   800c1f <sys_getenvid>
  8014a9:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8014ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014b2:	00 
  8014b3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014ba:	ee 
  8014bb:	89 04 24             	mov    %eax,(%esp)
  8014be:	e8 9a f7 ff ff       	call   800c5d <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	79 1c                	jns    8014e3 <set_pgfault_handler+0x4f>
  8014c7:	c7 44 24 08 d4 1a 80 	movl   $0x801ad4,0x8(%esp)
  8014ce:	00 
  8014cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014d6:	00 
  8014d7:	c7 04 24 30 1b 80 00 	movl   $0x801b30,(%esp)
  8014de:	e8 e5 ec ff ff       	call   8001c8 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8014e3:	c7 44 24 04 24 15 80 	movl   $0x801524,0x4(%esp)
  8014ea:	00 
  8014eb:	89 1c 24             	mov    %ebx,(%esp)
  8014ee:	e8 b7 f8 ff ff       	call   800daa <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	79 1c                	jns    801513 <set_pgfault_handler+0x7f>
  8014f7:	c7 44 24 08 fc 1a 80 	movl   $0x801afc,0x8(%esp)
  8014fe:	00 
  8014ff:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801506:	00 
  801507:	c7 04 24 30 1b 80 00 	movl   $0x801b30,(%esp)
  80150e:	e8 b5 ec ff ff       	call   8001c8 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80151b:	83 c4 14             	add    $0x14,%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5d                   	pop    %ebp
  801520:	c3                   	ret    
  801521:	00 00                	add    %al,(%eax)
	...

00801524 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801524:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801525:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80152a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80152c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  80152f:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  801533:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  801538:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  80153c:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  80153e:	83 c4 08             	add    $0x8,%esp
	popal
  801541:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  801542:	83 c4 04             	add    $0x4,%esp
	popfl
  801545:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  801546:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801549:	c3                   	ret    
	...

0080154c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80154c:	55                   	push   %ebp
  80154d:	57                   	push   %edi
  80154e:	56                   	push   %esi
  80154f:	83 ec 10             	sub    $0x10,%esp
  801552:	8b 74 24 20          	mov    0x20(%esp),%esi
  801556:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80155a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80155e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801562:	89 cd                	mov    %ecx,%ebp
  801564:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801568:	85 c0                	test   %eax,%eax
  80156a:	75 2c                	jne    801598 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80156c:	39 f9                	cmp    %edi,%ecx
  80156e:	77 68                	ja     8015d8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801570:	85 c9                	test   %ecx,%ecx
  801572:	75 0b                	jne    80157f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801574:	b8 01 00 00 00       	mov    $0x1,%eax
  801579:	31 d2                	xor    %edx,%edx
  80157b:	f7 f1                	div    %ecx
  80157d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80157f:	31 d2                	xor    %edx,%edx
  801581:	89 f8                	mov    %edi,%eax
  801583:	f7 f1                	div    %ecx
  801585:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801587:	89 f0                	mov    %esi,%eax
  801589:	f7 f1                	div    %ecx
  80158b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80158d:	89 f0                	mov    %esi,%eax
  80158f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	5e                   	pop    %esi
  801595:	5f                   	pop    %edi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801598:	39 f8                	cmp    %edi,%eax
  80159a:	77 2c                	ja     8015c8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80159c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80159f:	83 f6 1f             	xor    $0x1f,%esi
  8015a2:	75 4c                	jne    8015f0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015a4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8015a6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015ab:	72 0a                	jb     8015b7 <__udivdi3+0x6b>
  8015ad:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8015b1:	0f 87 ad 00 00 00    	ja     801664 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8015b7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015bc:	89 f0                	mov    %esi,%eax
  8015be:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	5e                   	pop    %esi
  8015c4:	5f                   	pop    %edi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    
  8015c7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8015c8:	31 ff                	xor    %edi,%edi
  8015ca:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015cc:	89 f0                	mov    %esi,%eax
  8015ce:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    
  8015d7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8015d8:	89 fa                	mov    %edi,%edx
  8015da:	89 f0                	mov    %esi,%eax
  8015dc:	f7 f1                	div    %ecx
  8015de:	89 c6                	mov    %eax,%esi
  8015e0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8015e2:	89 f0                	mov    %esi,%eax
  8015e4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	5e                   	pop    %esi
  8015ea:	5f                   	pop    %edi
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    
  8015ed:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8015f0:	89 f1                	mov    %esi,%ecx
  8015f2:	d3 e0                	shl    %cl,%eax
  8015f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8015f8:	b8 20 00 00 00       	mov    $0x20,%eax
  8015fd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8015ff:	89 ea                	mov    %ebp,%edx
  801601:	88 c1                	mov    %al,%cl
  801603:	d3 ea                	shr    %cl,%edx
  801605:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801609:	09 ca                	or     %ecx,%edx
  80160b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80160f:	89 f1                	mov    %esi,%ecx
  801611:	d3 e5                	shl    %cl,%ebp
  801613:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801617:	89 fd                	mov    %edi,%ebp
  801619:	88 c1                	mov    %al,%cl
  80161b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80161d:	89 fa                	mov    %edi,%edx
  80161f:	89 f1                	mov    %esi,%ecx
  801621:	d3 e2                	shl    %cl,%edx
  801623:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801627:	88 c1                	mov    %al,%cl
  801629:	d3 ef                	shr    %cl,%edi
  80162b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80162d:	89 f8                	mov    %edi,%eax
  80162f:	89 ea                	mov    %ebp,%edx
  801631:	f7 74 24 08          	divl   0x8(%esp)
  801635:	89 d1                	mov    %edx,%ecx
  801637:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801639:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80163d:	39 d1                	cmp    %edx,%ecx
  80163f:	72 17                	jb     801658 <__udivdi3+0x10c>
  801641:	74 09                	je     80164c <__udivdi3+0x100>
  801643:	89 fe                	mov    %edi,%esi
  801645:	31 ff                	xor    %edi,%edi
  801647:	e9 41 ff ff ff       	jmp    80158d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80164c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801650:	89 f1                	mov    %esi,%ecx
  801652:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801654:	39 c2                	cmp    %eax,%edx
  801656:	73 eb                	jae    801643 <__udivdi3+0xf7>
		{
		  q0--;
  801658:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80165b:	31 ff                	xor    %edi,%edi
  80165d:	e9 2b ff ff ff       	jmp    80158d <__udivdi3+0x41>
  801662:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801664:	31 f6                	xor    %esi,%esi
  801666:	e9 22 ff ff ff       	jmp    80158d <__udivdi3+0x41>
	...

0080166c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80166c:	55                   	push   %ebp
  80166d:	57                   	push   %edi
  80166e:	56                   	push   %esi
  80166f:	83 ec 20             	sub    $0x20,%esp
  801672:	8b 44 24 30          	mov    0x30(%esp),%eax
  801676:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80167a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80167e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801682:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801686:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80168a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80168c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80168e:	85 ed                	test   %ebp,%ebp
  801690:	75 16                	jne    8016a8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801692:	39 f1                	cmp    %esi,%ecx
  801694:	0f 86 a6 00 00 00    	jbe    801740 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80169a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80169c:	89 d0                	mov    %edx,%eax
  80169e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016a0:	83 c4 20             	add    $0x20,%esp
  8016a3:	5e                   	pop    %esi
  8016a4:	5f                   	pop    %edi
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    
  8016a7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8016a8:	39 f5                	cmp    %esi,%ebp
  8016aa:	0f 87 ac 00 00 00    	ja     80175c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8016b0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8016b3:	83 f0 1f             	xor    $0x1f,%eax
  8016b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016ba:	0f 84 a8 00 00 00    	je     801768 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8016c0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016c4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8016c6:	bf 20 00 00 00       	mov    $0x20,%edi
  8016cb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8016cf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8016d3:	89 f9                	mov    %edi,%ecx
  8016d5:	d3 e8                	shr    %cl,%eax
  8016d7:	09 e8                	or     %ebp,%eax
  8016d9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8016dd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8016e1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016e5:	d3 e0                	shl    %cl,%eax
  8016e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8016eb:	89 f2                	mov    %esi,%edx
  8016ed:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8016ef:	8b 44 24 14          	mov    0x14(%esp),%eax
  8016f3:	d3 e0                	shl    %cl,%eax
  8016f5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8016f9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8016fd:	89 f9                	mov    %edi,%ecx
  8016ff:	d3 e8                	shr    %cl,%eax
  801701:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801703:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801705:	89 f2                	mov    %esi,%edx
  801707:	f7 74 24 18          	divl   0x18(%esp)
  80170b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80170d:	f7 64 24 0c          	mull   0xc(%esp)
  801711:	89 c5                	mov    %eax,%ebp
  801713:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801715:	39 d6                	cmp    %edx,%esi
  801717:	72 67                	jb     801780 <__umoddi3+0x114>
  801719:	74 75                	je     801790 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80171b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80171f:	29 e8                	sub    %ebp,%eax
  801721:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801723:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801727:	d3 e8                	shr    %cl,%eax
  801729:	89 f2                	mov    %esi,%edx
  80172b:	89 f9                	mov    %edi,%ecx
  80172d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80172f:	09 d0                	or     %edx,%eax
  801731:	89 f2                	mov    %esi,%edx
  801733:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801737:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801739:	83 c4 20             	add    $0x20,%esp
  80173c:	5e                   	pop    %esi
  80173d:	5f                   	pop    %edi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801740:	85 c9                	test   %ecx,%ecx
  801742:	75 0b                	jne    80174f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801744:	b8 01 00 00 00       	mov    $0x1,%eax
  801749:	31 d2                	xor    %edx,%edx
  80174b:	f7 f1                	div    %ecx
  80174d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80174f:	89 f0                	mov    %esi,%eax
  801751:	31 d2                	xor    %edx,%edx
  801753:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801755:	89 f8                	mov    %edi,%eax
  801757:	e9 3e ff ff ff       	jmp    80169a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80175c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80175e:	83 c4 20             	add    $0x20,%esp
  801761:	5e                   	pop    %esi
  801762:	5f                   	pop    %edi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    
  801765:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801768:	39 f5                	cmp    %esi,%ebp
  80176a:	72 04                	jb     801770 <__umoddi3+0x104>
  80176c:	39 f9                	cmp    %edi,%ecx
  80176e:	77 06                	ja     801776 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801770:	89 f2                	mov    %esi,%edx
  801772:	29 cf                	sub    %ecx,%edi
  801774:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801776:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801778:	83 c4 20             	add    $0x20,%esp
  80177b:	5e                   	pop    %esi
  80177c:	5f                   	pop    %edi
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    
  80177f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801780:	89 d1                	mov    %edx,%ecx
  801782:	89 c5                	mov    %eax,%ebp
  801784:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801788:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80178c:	eb 8d                	jmp    80171b <__umoddi3+0xaf>
  80178e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801790:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801794:	72 ea                	jb     801780 <__umoddi3+0x114>
  801796:	89 f1                	mov    %esi,%ecx
  801798:	eb 81                	jmp    80171b <__umoddi3+0xaf>
