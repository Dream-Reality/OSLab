
obj/user/primes.debug:     file format elf32-i386


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
  800053:	e8 b0 13 00 00       	call   801408 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
  80005f:	8b 00                	mov    (%eax),%eax
  800061:	8b 40 5c             	mov    0x5c(%eax),%eax
  800064:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  800073:	e8 40 02 00 00       	call   8002b8 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800078:	e8 7b 10 00 00       	call   8010f8 <fork>
  80007d:	89 c7                	mov    %eax,%edi
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 20                	jns    8000a3 <primeproc+0x6f>
		panic("fork: %e", id);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 8c 26 80 	movl   $0x80268c,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 95 26 80 00 	movl   $0x802695,(%esp)
  80009e:	e8 1d 01 00 00       	call   8001c0 <_panic>
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
  8000bd:	e8 46 13 00 00       	call   801408 <ipc_recv>
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
  8000e2:	e8 8e 13 00 00       	call   801475 <ipc_send>
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
  8000f1:	e8 02 10 00 00       	call   8010f8 <fork>
  8000f6:	89 c6                	mov    %eax,%esi
  8000f8:	85 c0                	test   %eax,%eax
  8000fa:	79 20                	jns    80011c <umain+0x33>
		panic("fork: %e", id);
  8000fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800100:	c7 44 24 08 8c 26 80 	movl   $0x80268c,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 95 26 80 00 	movl   $0x802695,(%esp)
  800117:	e8 a4 00 00 00       	call   8001c0 <_panic>
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
  800141:	e8 2f 13 00 00       	call   801475 <ipc_send>
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
  80015a:	e8 b8 0a 00 00       	call   800c17 <sys_getenvid>
  80015f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800164:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80016b:	c1 e0 07             	shl    $0x7,%eax
  80016e:	29 d0                	sub    %edx,%eax
  800170:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800175:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800178:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80017b:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800180:	85 f6                	test   %esi,%esi
  800182:	7e 07                	jle    80018b <libmain+0x3f>
		binaryname = argv[0];
  800184:	8b 03                	mov    (%ebx),%eax
  800186:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80018b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018f:	89 34 24             	mov    %esi,(%esp)
  800192:	e8 52 ff ff ff       	call   8000e9 <umain>

	// exit gracefully
	exit();
  800197:	e8 08 00 00 00       	call   8001a4 <exit>
}
  80019c:	83 c4 20             	add    $0x20,%esp
  80019f:	5b                   	pop    %ebx
  8001a0:	5e                   	pop    %esi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    
	...

008001a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001aa:	e8 5a 15 00 00       	call   801709 <close_all>
	sys_env_destroy(0);
  8001af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b6:	e8 0a 0a 00 00       	call   800bc5 <sys_env_destroy>
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    
  8001bd:	00 00                	add    %al,(%eax)
	...

008001c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001cb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001d1:	e8 41 0a 00 00       	call   800c17 <sys_getenvid>
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	c7 04 24 b0 26 80 00 	movl   $0x8026b0,(%esp)
  8001f3:	e8 c0 00 00 00       	call   8002b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 50 00 00 00       	call   800257 <vcprintf>
	cprintf("\n");
  800207:	c7 04 24 50 2a 80 00 	movl   $0x802a50,(%esp)
  80020e:	e8 a5 00 00 00       	call   8002b8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800213:	cc                   	int3   
  800214:	eb fd                	jmp    800213 <_panic+0x53>
	...

00800218 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	53                   	push   %ebx
  80021c:	83 ec 14             	sub    $0x14,%esp
  80021f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800222:	8b 03                	mov    (%ebx),%eax
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80022b:	40                   	inc    %eax
  80022c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80022e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800233:	75 19                	jne    80024e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800235:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80023c:	00 
  80023d:	8d 43 08             	lea    0x8(%ebx),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 40 09 00 00       	call   800b88 <sys_cputs>
		b->idx = 0;
  800248:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80024e:	ff 43 04             	incl   0x4(%ebx)
}
  800251:	83 c4 14             	add    $0x14,%esp
  800254:	5b                   	pop    %ebx
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800260:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800267:	00 00 00 
	b.cnt = 0;
  80026a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800271:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027b:	8b 45 08             	mov    0x8(%ebp),%eax
  80027e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800282:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	c7 04 24 18 02 80 00 	movl   $0x800218,(%esp)
  800293:	e8 82 01 00 00       	call   80041a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800298:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80029e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	e8 d8 08 00 00       	call   800b88 <sys_cputs>

	return b.cnt;
}
  8002b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	e8 87 ff ff ff       	call   800257 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    
	...

008002d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 3c             	sub    $0x3c,%esp
  8002dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e0:	89 d7                	mov    %edx,%edi
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	75 08                	jne    800300 <printnum+0x2c>
  8002f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002fe:	77 57                	ja     800357 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800300:	89 74 24 10          	mov    %esi,0x10(%esp)
  800304:	4b                   	dec    %ebx
  800305:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800309:	8b 45 10             	mov    0x10(%ebp),%eax
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800314:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	e8 fa 20 00 00       	call   80242c <__udivdi3>
  800332:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800336:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800341:	89 fa                	mov    %edi,%edx
  800343:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800346:	e8 89 ff ff ff       	call   8002d4 <printnum>
  80034b:	eb 0f                	jmp    80035c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800351:	89 34 24             	mov    %esi,(%esp)
  800354:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800357:	4b                   	dec    %ebx
  800358:	85 db                	test   %ebx,%ebx
  80035a:	7f f1                	jg     80034d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800360:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800364:	8b 45 10             	mov    0x10(%ebp),%eax
  800367:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800372:	00 
  800373:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800376:	89 04 24             	mov    %eax,(%esp)
  800379:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800380:	e8 c7 21 00 00       	call   80254c <__umoddi3>
  800385:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800389:	0f be 80 d3 26 80 00 	movsbl 0x8026d3(%eax),%eax
  800390:	89 04 24             	mov    %eax,(%esp)
  800393:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800396:	83 c4 3c             	add    $0x3c,%esp
  800399:	5b                   	pop    %ebx
  80039a:	5e                   	pop    %esi
  80039b:	5f                   	pop    %edi
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a1:	83 fa 01             	cmp    $0x1,%edx
  8003a4:	7e 0e                	jle    8003b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a6:	8b 10                	mov    (%eax),%edx
  8003a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ab:	89 08                	mov    %ecx,(%eax)
  8003ad:	8b 02                	mov    (%edx),%eax
  8003af:	8b 52 04             	mov    0x4(%edx),%edx
  8003b2:	eb 22                	jmp    8003d6 <getuint+0x38>
	else if (lflag)
  8003b4:	85 d2                	test   %edx,%edx
  8003b6:	74 10                	je     8003c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 02                	mov    (%edx),%eax
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c6:	eb 0e                	jmp    8003d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c8:	8b 10                	mov    (%eax),%edx
  8003ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003cd:	89 08                	mov    %ecx,(%eax)
  8003cf:	8b 02                	mov    (%edx),%eax
  8003d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003de:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003e1:	8b 10                	mov    (%eax),%edx
  8003e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e6:	73 08                	jae    8003f0 <sprintputch+0x18>
		*b->buf++ = ch;
  8003e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003eb:	88 0a                	mov    %cl,(%edx)
  8003ed:	42                   	inc    %edx
  8003ee:	89 10                	mov    %edx,(%eax)
}
  8003f0:	5d                   	pop    %ebp
  8003f1:	c3                   	ret    

008003f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800402:	89 44 24 08          	mov    %eax,0x8(%esp)
  800406:	8b 45 0c             	mov    0xc(%ebp),%eax
  800409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	e8 02 00 00 00       	call   80041a <vprintfmt>
	va_end(ap);
}
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	57                   	push   %edi
  80041e:	56                   	push   %esi
  80041f:	53                   	push   %ebx
  800420:	83 ec 4c             	sub    $0x4c,%esp
  800423:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800426:	8b 75 10             	mov    0x10(%ebp),%esi
  800429:	eb 12                	jmp    80043d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042b:	85 c0                	test   %eax,%eax
  80042d:	0f 84 6b 03 00 00    	je     80079e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800433:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043d:	0f b6 06             	movzbl (%esi),%eax
  800440:	46                   	inc    %esi
  800441:	83 f8 25             	cmp    $0x25,%eax
  800444:	75 e5                	jne    80042b <vprintfmt+0x11>
  800446:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80044a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800451:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800456:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80045d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800462:	eb 26                	jmp    80048a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800467:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80046b:	eb 1d                	jmp    80048a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800470:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800474:	eb 14                	jmp    80048a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800479:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800480:	eb 08                	jmp    80048a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800482:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800485:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	0f b6 06             	movzbl (%esi),%eax
  80048d:	8d 56 01             	lea    0x1(%esi),%edx
  800490:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800493:	8a 16                	mov    (%esi),%dl
  800495:	83 ea 23             	sub    $0x23,%edx
  800498:	80 fa 55             	cmp    $0x55,%dl
  80049b:	0f 87 e1 02 00 00    	ja     800782 <vprintfmt+0x368>
  8004a1:	0f b6 d2             	movzbl %dl,%edx
  8004a4:	ff 24 95 20 28 80 00 	jmp    *0x802820(,%edx,4)
  8004ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ae:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004b6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004ba:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004bd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c0:	83 fa 09             	cmp    $0x9,%edx
  8004c3:	77 2a                	ja     8004ef <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c6:	eb eb                	jmp    8004b3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d6:	eb 17                	jmp    8004ef <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004dc:	78 98                	js     800476 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004e1:	eb a7                	jmp    80048a <vprintfmt+0x70>
  8004e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004ed:	eb 9b                	jmp    80048a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f3:	79 95                	jns    80048a <vprintfmt+0x70>
  8004f5:	eb 8b                	jmp    800482 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004fb:	eb 8d                	jmp    80048a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8d 50 04             	lea    0x4(%eax),%edx
  800503:	89 55 14             	mov    %edx,0x14(%ebp)
  800506:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800515:	e9 23 ff ff ff       	jmp    80043d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 50 04             	lea    0x4(%eax),%edx
  800520:	89 55 14             	mov    %edx,0x14(%ebp)
  800523:	8b 00                	mov    (%eax),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	79 02                	jns    80052b <vprintfmt+0x111>
  800529:	f7 d8                	neg    %eax
  80052b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052d:	83 f8 0f             	cmp    $0xf,%eax
  800530:	7f 0b                	jg     80053d <vprintfmt+0x123>
  800532:	8b 04 85 80 29 80 00 	mov    0x802980(,%eax,4),%eax
  800539:	85 c0                	test   %eax,%eax
  80053b:	75 23                	jne    800560 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80053d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800541:	c7 44 24 08 eb 26 80 	movl   $0x8026eb,0x8(%esp)
  800548:	00 
  800549:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054d:	8b 45 08             	mov    0x8(%ebp),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 9a fe ff ff       	call   8003f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80055b:	e9 dd fe ff ff       	jmp    80043d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800560:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800564:	c7 44 24 08 15 2b 80 	movl   $0x802b15,0x8(%esp)
  80056b:	00 
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	8b 55 08             	mov    0x8(%ebp),%edx
  800573:	89 14 24             	mov    %edx,(%esp)
  800576:	e8 77 fe ff ff       	call   8003f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80057e:	e9 ba fe ff ff       	jmp    80043d <vprintfmt+0x23>
  800583:	89 f9                	mov    %edi,%ecx
  800585:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800588:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 30                	mov    (%eax),%esi
  800596:	85 f6                	test   %esi,%esi
  800598:	75 05                	jne    80059f <vprintfmt+0x185>
				p = "(null)";
  80059a:	be e4 26 80 00       	mov    $0x8026e4,%esi
			if (width > 0 && padc != '-')
  80059f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005a3:	0f 8e 84 00 00 00    	jle    80062d <vprintfmt+0x213>
  8005a9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005ad:	74 7e                	je     80062d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b3:	89 34 24             	mov    %esi,(%esp)
  8005b6:	e8 8b 02 00 00       	call   800846 <strnlen>
  8005bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005be:	29 c2                	sub    %eax,%edx
  8005c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005c3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005c7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005ca:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005cd:	89 de                	mov    %ebx,%esi
  8005cf:	89 d3                	mov    %edx,%ebx
  8005d1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d3:	eb 0b                	jmp    8005e0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d9:	89 3c 24             	mov    %edi,(%esp)
  8005dc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	4b                   	dec    %ebx
  8005e0:	85 db                	test   %ebx,%ebx
  8005e2:	7f f1                	jg     8005d5 <vprintfmt+0x1bb>
  8005e4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005e7:	89 f3                	mov    %esi,%ebx
  8005e9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	79 05                	jns    8005f8 <vprintfmt+0x1de>
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fb:	29 c2                	sub    %eax,%edx
  8005fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800600:	eb 2b                	jmp    80062d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800602:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800606:	74 18                	je     800620 <vprintfmt+0x206>
  800608:	8d 50 e0             	lea    -0x20(%eax),%edx
  80060b:	83 fa 5e             	cmp    $0x5e,%edx
  80060e:	76 10                	jbe    800620 <vprintfmt+0x206>
					putch('?', putdat);
  800610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800614:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061b:	ff 55 08             	call   *0x8(%ebp)
  80061e:	eb 0a                	jmp    80062a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062a:	ff 4d e4             	decl   -0x1c(%ebp)
  80062d:	0f be 06             	movsbl (%esi),%eax
  800630:	46                   	inc    %esi
  800631:	85 c0                	test   %eax,%eax
  800633:	74 21                	je     800656 <vprintfmt+0x23c>
  800635:	85 ff                	test   %edi,%edi
  800637:	78 c9                	js     800602 <vprintfmt+0x1e8>
  800639:	4f                   	dec    %edi
  80063a:	79 c6                	jns    800602 <vprintfmt+0x1e8>
  80063c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80063f:	89 de                	mov    %ebx,%esi
  800641:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800644:	eb 18                	jmp    80065e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800651:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800653:	4b                   	dec    %ebx
  800654:	eb 08                	jmp    80065e <vprintfmt+0x244>
  800656:	8b 7d 08             	mov    0x8(%ebp),%edi
  800659:	89 de                	mov    %ebx,%esi
  80065b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80065e:	85 db                	test   %ebx,%ebx
  800660:	7f e4                	jg     800646 <vprintfmt+0x22c>
  800662:	89 7d 08             	mov    %edi,0x8(%ebp)
  800665:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066a:	e9 ce fd ff ff       	jmp    80043d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066f:	83 f9 01             	cmp    $0x1,%ecx
  800672:	7e 10                	jle    800684 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 08             	lea    0x8(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)
  80067d:	8b 30                	mov    (%eax),%esi
  80067f:	8b 78 04             	mov    0x4(%eax),%edi
  800682:	eb 26                	jmp    8006aa <vprintfmt+0x290>
	else if (lflag)
  800684:	85 c9                	test   %ecx,%ecx
  800686:	74 12                	je     80069a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	8b 30                	mov    (%eax),%esi
  800693:	89 f7                	mov    %esi,%edi
  800695:	c1 ff 1f             	sar    $0x1f,%edi
  800698:	eb 10                	jmp    8006aa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a3:	8b 30                	mov    (%eax),%esi
  8006a5:	89 f7                	mov    %esi,%edi
  8006a7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006aa:	85 ff                	test   %edi,%edi
  8006ac:	78 0a                	js     8006b8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b3:	e9 8c 00 00 00       	jmp    800744 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c6:	f7 de                	neg    %esi
  8006c8:	83 d7 00             	adc    $0x0,%edi
  8006cb:	f7 df                	neg    %edi
			}
			base = 10;
  8006cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d2:	eb 70                	jmp    800744 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d4:	89 ca                	mov    %ecx,%edx
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 c0 fc ff ff       	call   80039e <getuint>
  8006de:	89 c6                	mov    %eax,%esi
  8006e0:	89 d7                	mov    %edx,%edi
			base = 10;
  8006e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006e7:	eb 5b                	jmp    800744 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006e9:	89 ca                	mov    %ecx,%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 ab fc ff ff       	call   80039e <getuint>
  8006f3:	89 c6                	mov    %eax,%esi
  8006f5:	89 d7                	mov    %edx,%edi
			base = 8;
  8006f7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006fc:	eb 46                	jmp    800744 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800702:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800709:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80070c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800710:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800717:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 50 04             	lea    0x4(%eax),%edx
  800720:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800723:	8b 30                	mov    (%eax),%esi
  800725:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80072f:	eb 13                	jmp    800744 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800731:	89 ca                	mov    %ecx,%edx
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 63 fc ff ff       	call   80039e <getuint>
  80073b:	89 c6                	mov    %eax,%esi
  80073d:	89 d7                	mov    %edx,%edi
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800744:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800748:	89 54 24 10          	mov    %edx,0x10(%esp)
  80074c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80074f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800753:	89 44 24 08          	mov    %eax,0x8(%esp)
  800757:	89 34 24             	mov    %esi,(%esp)
  80075a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075e:	89 da                	mov    %ebx,%edx
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	e8 6c fb ff ff       	call   8002d4 <printnum>
			break;
  800768:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80076b:	e9 cd fc ff ff       	jmp    80043d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800770:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80077d:	e9 bb fc ff ff       	jmp    80043d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800782:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800786:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80078d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800790:	eb 01                	jmp    800793 <vprintfmt+0x379>
  800792:	4e                   	dec    %esi
  800793:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800797:	75 f9                	jne    800792 <vprintfmt+0x378>
  800799:	e9 9f fc ff ff       	jmp    80043d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80079e:	83 c4 4c             	add    $0x4c,%esp
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5f                   	pop    %edi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 28             	sub    $0x28,%esp
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	74 30                	je     8007f7 <vsnprintf+0x51>
  8007c7:	85 d2                	test   %edx,%edx
  8007c9:	7e 33                	jle    8007fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e0:	c7 04 24 d8 03 80 00 	movl   $0x8003d8,(%esp)
  8007e7:	e8 2e fc ff ff       	call   80041a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f5:	eb 0c                	jmp    800803 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fc:	eb 05                	jmp    800803 <vsnprintf+0x5d>
  8007fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800803:	c9                   	leave  
  800804:	c3                   	ret    

00800805 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800812:	8b 45 10             	mov    0x10(%ebp),%eax
  800815:	89 44 24 08          	mov    %eax,0x8(%esp)
  800819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	89 04 24             	mov    %eax,(%esp)
  800826:	e8 7b ff ff ff       	call   8007a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    
  80082d:	00 00                	add    %al,(%eax)
	...

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 01                	jmp    80083e <strlen+0xe>
		n++;
  80083d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800842:	75 f9                	jne    80083d <strlen+0xd>
		n++;
	return n;
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	eb 01                	jmp    800857 <strnlen+0x11>
		n++;
  800856:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800857:	39 d0                	cmp    %edx,%eax
  800859:	74 06                	je     800861 <strnlen+0x1b>
  80085b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80085f:	75 f5                	jne    800856 <strnlen+0x10>
		n++;
	return n;
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086d:	ba 00 00 00 00       	mov    $0x0,%edx
  800872:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800875:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800878:	42                   	inc    %edx
  800879:	84 c9                	test   %cl,%cl
  80087b:	75 f5                	jne    800872 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80087d:	5b                   	pop    %ebx
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	53                   	push   %ebx
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088a:	89 1c 24             	mov    %ebx,(%esp)
  80088d:	e8 9e ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
  800895:	89 54 24 04          	mov    %edx,0x4(%esp)
  800899:	01 d8                	add    %ebx,%eax
  80089b:	89 04 24             	mov    %eax,(%esp)
  80089e:	e8 c0 ff ff ff       	call   800863 <strcpy>
	return dst;
}
  8008a3:	89 d8                	mov    %ebx,%eax
  8008a5:	83 c4 08             	add    $0x8,%esp
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008be:	eb 0c                	jmp    8008cc <strncpy+0x21>
		*dst++ = *src;
  8008c0:	8a 1a                	mov    (%edx),%bl
  8008c2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cb:	41                   	inc    %ecx
  8008cc:	39 f1                	cmp    %esi,%ecx
  8008ce:	75 f0                	jne    8008c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e2:	85 d2                	test   %edx,%edx
  8008e4:	75 0a                	jne    8008f0 <strlcpy+0x1c>
  8008e6:	89 f0                	mov    %esi,%eax
  8008e8:	eb 1a                	jmp    800904 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ea:	88 18                	mov    %bl,(%eax)
  8008ec:	40                   	inc    %eax
  8008ed:	41                   	inc    %ecx
  8008ee:	eb 02                	jmp    8008f2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008f2:	4a                   	dec    %edx
  8008f3:	74 0a                	je     8008ff <strlcpy+0x2b>
  8008f5:	8a 19                	mov    (%ecx),%bl
  8008f7:	84 db                	test   %bl,%bl
  8008f9:	75 ef                	jne    8008ea <strlcpy+0x16>
  8008fb:	89 c2                	mov    %eax,%edx
  8008fd:	eb 02                	jmp    800901 <strlcpy+0x2d>
  8008ff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800901:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800904:	29 f0                	sub    %esi,%eax
}
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800913:	eb 02                	jmp    800917 <strcmp+0xd>
		p++, q++;
  800915:	41                   	inc    %ecx
  800916:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800917:	8a 01                	mov    (%ecx),%al
  800919:	84 c0                	test   %al,%al
  80091b:	74 04                	je     800921 <strcmp+0x17>
  80091d:	3a 02                	cmp    (%edx),%al
  80091f:	74 f4                	je     800915 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800921:	0f b6 c0             	movzbl %al,%eax
  800924:	0f b6 12             	movzbl (%edx),%edx
  800927:	29 d0                	sub    %edx,%eax
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800935:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800938:	eb 03                	jmp    80093d <strncmp+0x12>
		n--, p++, q++;
  80093a:	4a                   	dec    %edx
  80093b:	40                   	inc    %eax
  80093c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 14                	je     800955 <strncmp+0x2a>
  800941:	8a 18                	mov    (%eax),%bl
  800943:	84 db                	test   %bl,%bl
  800945:	74 04                	je     80094b <strncmp+0x20>
  800947:	3a 19                	cmp    (%ecx),%bl
  800949:	74 ef                	je     80093a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094b:	0f b6 00             	movzbl (%eax),%eax
  80094e:	0f b6 11             	movzbl (%ecx),%edx
  800951:	29 d0                	sub    %edx,%eax
  800953:	eb 05                	jmp    80095a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095a:	5b                   	pop    %ebx
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800966:	eb 05                	jmp    80096d <strchr+0x10>
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	74 0c                	je     800978 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096c:	40                   	inc    %eax
  80096d:	8a 10                	mov    (%eax),%dl
  80096f:	84 d2                	test   %dl,%dl
  800971:	75 f5                	jne    800968 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800983:	eb 05                	jmp    80098a <strfind+0x10>
		if (*s == c)
  800985:	38 ca                	cmp    %cl,%dl
  800987:	74 07                	je     800990 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800989:	40                   	inc    %eax
  80098a:	8a 10                	mov    (%eax),%dl
  80098c:	84 d2                	test   %dl,%dl
  80098e:	75 f5                	jne    800985 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a1:	85 c9                	test   %ecx,%ecx
  8009a3:	74 30                	je     8009d5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ab:	75 25                	jne    8009d2 <memset+0x40>
  8009ad:	f6 c1 03             	test   $0x3,%cl
  8009b0:	75 20                	jne    8009d2 <memset+0x40>
		c &= 0xFF;
  8009b2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b5:	89 d3                	mov    %edx,%ebx
  8009b7:	c1 e3 08             	shl    $0x8,%ebx
  8009ba:	89 d6                	mov    %edx,%esi
  8009bc:	c1 e6 18             	shl    $0x18,%esi
  8009bf:	89 d0                	mov    %edx,%eax
  8009c1:	c1 e0 10             	shl    $0x10,%eax
  8009c4:	09 f0                	or     %esi,%eax
  8009c6:	09 d0                	or     %edx,%eax
  8009c8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009cd:	fc                   	cld    
  8009ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d0:	eb 03                	jmp    8009d5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d2:	fc                   	cld    
  8009d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d5:	89 f8                	mov    %edi,%eax
  8009d7:	5b                   	pop    %ebx
  8009d8:	5e                   	pop    %esi
  8009d9:	5f                   	pop    %edi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ea:	39 c6                	cmp    %eax,%esi
  8009ec:	73 34                	jae    800a22 <memmove+0x46>
  8009ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f1:	39 d0                	cmp    %edx,%eax
  8009f3:	73 2d                	jae    800a22 <memmove+0x46>
		s += n;
		d += n;
  8009f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f8:	f6 c2 03             	test   $0x3,%dl
  8009fb:	75 1b                	jne    800a18 <memmove+0x3c>
  8009fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a03:	75 13                	jne    800a18 <memmove+0x3c>
  800a05:	f6 c1 03             	test   $0x3,%cl
  800a08:	75 0e                	jne    800a18 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0a:	83 ef 04             	sub    $0x4,%edi
  800a0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a10:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a13:	fd                   	std    
  800a14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a16:	eb 07                	jmp    800a1f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a18:	4f                   	dec    %edi
  800a19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a1c:	fd                   	std    
  800a1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1f:	fc                   	cld    
  800a20:	eb 20                	jmp    800a42 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a28:	75 13                	jne    800a3d <memmove+0x61>
  800a2a:	a8 03                	test   $0x3,%al
  800a2c:	75 0f                	jne    800a3d <memmove+0x61>
  800a2e:	f6 c1 03             	test   $0x3,%cl
  800a31:	75 0a                	jne    800a3d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a33:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a36:	89 c7                	mov    %eax,%edi
  800a38:	fc                   	cld    
  800a39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3b:	eb 05                	jmp    800a42 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a3d:	89 c7                	mov    %eax,%edi
  800a3f:	fc                   	cld    
  800a40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	89 04 24             	mov    %eax,(%esp)
  800a60:	e8 77 ff ff ff       	call   8009dc <memmove>
}
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a76:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7b:	eb 16                	jmp    800a93 <memcmp+0x2c>
		if (*s1 != *s2)
  800a7d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a80:	42                   	inc    %edx
  800a81:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a85:	38 c8                	cmp    %cl,%al
  800a87:	74 0a                	je     800a93 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a89:	0f b6 c0             	movzbl %al,%eax
  800a8c:	0f b6 c9             	movzbl %cl,%ecx
  800a8f:	29 c8                	sub    %ecx,%eax
  800a91:	eb 09                	jmp    800a9c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	39 da                	cmp    %ebx,%edx
  800a95:	75 e6                	jne    800a7d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aaa:	89 c2                	mov    %eax,%edx
  800aac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aaf:	eb 05                	jmp    800ab6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab1:	38 08                	cmp    %cl,(%eax)
  800ab3:	74 05                	je     800aba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab5:	40                   	inc    %eax
  800ab6:	39 d0                	cmp    %edx,%eax
  800ab8:	72 f7                	jb     800ab1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac8:	eb 01                	jmp    800acb <strtol+0xf>
		s++;
  800aca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acb:	8a 02                	mov    (%edx),%al
  800acd:	3c 20                	cmp    $0x20,%al
  800acf:	74 f9                	je     800aca <strtol+0xe>
  800ad1:	3c 09                	cmp    $0x9,%al
  800ad3:	74 f5                	je     800aca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad5:	3c 2b                	cmp    $0x2b,%al
  800ad7:	75 08                	jne    800ae1 <strtol+0x25>
		s++;
  800ad9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ada:	bf 00 00 00 00       	mov    $0x0,%edi
  800adf:	eb 13                	jmp    800af4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae1:	3c 2d                	cmp    $0x2d,%al
  800ae3:	75 0a                	jne    800aef <strtol+0x33>
		s++, neg = 1;
  800ae5:	8d 52 01             	lea    0x1(%edx),%edx
  800ae8:	bf 01 00 00 00       	mov    $0x1,%edi
  800aed:	eb 05                	jmp    800af4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af4:	85 db                	test   %ebx,%ebx
  800af6:	74 05                	je     800afd <strtol+0x41>
  800af8:	83 fb 10             	cmp    $0x10,%ebx
  800afb:	75 28                	jne    800b25 <strtol+0x69>
  800afd:	8a 02                	mov    (%edx),%al
  800aff:	3c 30                	cmp    $0x30,%al
  800b01:	75 10                	jne    800b13 <strtol+0x57>
  800b03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b07:	75 0a                	jne    800b13 <strtol+0x57>
		s += 2, base = 16;
  800b09:	83 c2 02             	add    $0x2,%edx
  800b0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b11:	eb 12                	jmp    800b25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	75 0e                	jne    800b25 <strtol+0x69>
  800b17:	3c 30                	cmp    $0x30,%al
  800b19:	75 05                	jne    800b20 <strtol+0x64>
		s++, base = 8;
  800b1b:	42                   	inc    %edx
  800b1c:	b3 08                	mov    $0x8,%bl
  800b1e:	eb 05                	jmp    800b25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b2c:	8a 0a                	mov    (%edx),%cl
  800b2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b31:	80 fb 09             	cmp    $0x9,%bl
  800b34:	77 08                	ja     800b3e <strtol+0x82>
			dig = *s - '0';
  800b36:	0f be c9             	movsbl %cl,%ecx
  800b39:	83 e9 30             	sub    $0x30,%ecx
  800b3c:	eb 1e                	jmp    800b5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 08                	ja     800b4e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b46:	0f be c9             	movsbl %cl,%ecx
  800b49:	83 e9 57             	sub    $0x57,%ecx
  800b4c:	eb 0e                	jmp    800b5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b51:	80 fb 19             	cmp    $0x19,%bl
  800b54:	77 12                	ja     800b68 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b56:	0f be c9             	movsbl %cl,%ecx
  800b59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b5c:	39 f1                	cmp    %esi,%ecx
  800b5e:	7d 0c                	jge    800b6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b60:	42                   	inc    %edx
  800b61:	0f af c6             	imul   %esi,%eax
  800b64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b66:	eb c4                	jmp    800b2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b68:	89 c1                	mov    %eax,%ecx
  800b6a:	eb 02                	jmp    800b6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b72:	74 05                	je     800b79 <strtol+0xbd>
		*endptr = (char *) s;
  800b74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b79:	85 ff                	test   %edi,%edi
  800b7b:	74 04                	je     800b81 <strtol+0xc5>
  800b7d:	89 c8                	mov    %ecx,%eax
  800b7f:	f7 d8                	neg    %eax
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    
	...

00800b88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 c3                	mov    %eax,%ebx
  800b9b:	89 c7                	mov    %eax,%edi
  800b9d:	89 c6                	mov    %eax,%esi
  800b9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb6:	89 d1                	mov    %edx,%ecx
  800bb8:	89 d3                	mov    %edx,%ebx
  800bba:	89 d7                	mov    %edx,%edi
  800bbc:	89 d6                	mov    %edx,%esi
  800bbe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 cb                	mov    %ecx,%ebx
  800bdd:	89 cf                	mov    %ecx,%edi
  800bdf:	89 ce                	mov    %ecx,%esi
  800be1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 28                	jle    800c0f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800beb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800bfa:	00 
  800bfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c02:	00 
  800c03:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800c0a:	e8 b1 f5 ff ff       	call   8001c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0f:	83 c4 2c             	add    $0x2c,%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 02 00 00 00       	mov    $0x2,%eax
  800c27:	89 d1                	mov    %edx,%ecx
  800c29:	89 d3                	mov    %edx,%ebx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	89 d6                	mov    %edx,%esi
  800c2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_yield>:

void
sys_yield(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	be 00 00 00 00       	mov    $0x0,%esi
  800c63:	b8 04 00 00 00       	mov    $0x4,%eax
  800c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 f7                	mov    %esi,%edi
  800c73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 28                	jle    800ca1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c84:	00 
  800c85:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800c8c:	00 
  800c8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c94:	00 
  800c95:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800c9c:	e8 1f f5 ff ff       	call   8001c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca1:	83 c4 2c             	add    $0x2c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7e 28                	jle    800cf4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce7:	00 
  800ce8:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800cef:	e8 cc f4 ff ff       	call   8001c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf4:	83 c4 2c             	add    $0x2c,%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	89 df                	mov    %ebx,%edi
  800d17:	89 de                	mov    %ebx,%esi
  800d19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	7e 28                	jle    800d47 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800d32:	00 
  800d33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3a:	00 
  800d3b:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800d42:	e8 79 f4 ff ff       	call   8001c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d47:	83 c4 2c             	add    $0x2c,%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 28                	jle    800d9a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d76:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800d85:	00 
  800d86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8d:	00 
  800d8e:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800d95:	e8 26 f4 ff ff       	call   8001c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9a:	83 c4 2c             	add    $0x2c,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db0:	b8 09 00 00 00       	mov    $0x9,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 df                	mov    %ebx,%edi
  800dbd:	89 de                	mov    %ebx,%esi
  800dbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 28                	jle    800ded <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de0:	00 
  800de1:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800de8:	e8 d3 f3 ff ff       	call   8001c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ded:	83 c4 2c             	add    $0x2c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	89 df                	mov    %ebx,%edi
  800e10:	89 de                	mov    %ebx,%esi
  800e12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 28                	jle    800e40 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e23:	00 
  800e24:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e33:	00 
  800e34:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800e3b:	e8 80 f3 ff ff       	call   8001c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e40:	83 c4 2c             	add    $0x2c,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	be 00 00 00 00       	mov    $0x0,%esi
  800e53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	89 cb                	mov    %ecx,%ebx
  800e83:	89 cf                	mov    %ecx,%edi
  800e85:	89 ce                	mov    %ecx,%esi
  800e87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 28                	jle    800eb5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e91:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e98:	00 
  800e99:	c7 44 24 08 df 29 80 	movl   $0x8029df,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 fc 29 80 00 	movl   $0x8029fc,(%esp)
  800eb0:	e8 0b f3 ff ff       	call   8001c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb5:	83 c4 2c             	add    $0x2c,%esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    
  800ebd:	00 00                	add    %al,(%eax)
	...

00800ec0 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
  800ec6:	83 ec 3c             	sub    $0x3c,%esp
  800ec9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800ecc:	89 d6                	mov    %edx,%esi
  800ece:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800ed1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800edb:	e8 37 fd ff ff       	call   800c17 <sys_getenvid>
  800ee0:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800ee2:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800ee9:	74 31                	je     800f1c <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800eeb:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800ef2:	00 
  800ef3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ef7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800efa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800efe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f02:	89 3c 24             	mov    %edi,(%esp)
  800f05:	e8 9f fd ff ff       	call   800ca9 <sys_page_map>
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	0f 8e ae 00 00 00    	jle    800fc0 <duppage+0x100>
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	e9 a4 00 00 00       	jmp    800fc0 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800f1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1f:	25 02 08 00 00       	and    $0x802,%eax
  800f24:	83 f8 01             	cmp    $0x1,%eax
  800f27:	19 db                	sbb    %ebx,%ebx
  800f29:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800f2f:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800f35:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800f39:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f40:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	89 3c 24             	mov    %edi,(%esp)
  800f4b:	e8 59 fd ff ff       	call   800ca9 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800f50:	85 c0                	test   %eax,%eax
  800f52:	79 1c                	jns    800f70 <duppage+0xb0>
  800f54:	c7 44 24 08 0a 2a 80 	movl   $0x802a0a,0x8(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800f63:	00 
  800f64:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  800f6b:	e8 50 f2 ff ff       	call   8001c0 <_panic>
	if ((perm|~pte)&PTE_COW){
  800f70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f73:	f7 d0                	not    %eax
  800f75:	09 d8                	or     %ebx,%eax
  800f77:	f6 c4 08             	test   $0x8,%ah
  800f7a:	74 38                	je     800fb4 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800f7c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800f80:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f84:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f88:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8c:	89 3c 24             	mov    %edi,(%esp)
  800f8f:	e8 15 fd ff ff       	call   800ca9 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800f94:	85 c0                	test   %eax,%eax
  800f96:	79 23                	jns    800fbb <duppage+0xfb>
  800f98:	c7 44 24 08 0a 2a 80 	movl   $0x802a0a,0x8(%esp)
  800f9f:	00 
  800fa0:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800fa7:	00 
  800fa8:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  800faf:	e8 0c f2 ff ff       	call   8001c0 <_panic>
	}
	return 0;
  800fb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb9:	eb 05                	jmp    800fc0 <duppage+0x100>
  800fbb:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  800fc0:	83 c4 3c             	add    $0x3c,%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    

00800fc8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	56                   	push   %esi
  800fcc:	53                   	push   %ebx
  800fcd:	83 ec 20             	sub    $0x20,%esp
  800fd0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fd3:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800fd5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fd9:	75 1c                	jne    800ff7 <pgfault+0x2f>
		panic("pgfault: error!\n");
  800fdb:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  800fe2:	00 
  800fe3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800fea:	00 
  800feb:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  800ff2:	e8 c9 f1 ff ff       	call   8001c0 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800ff7:	89 f0                	mov    %esi,%eax
  800ff9:	c1 e8 0c             	shr    $0xc,%eax
  800ffc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801003:	f6 c4 08             	test   $0x8,%ah
  801006:	75 1c                	jne    801024 <pgfault+0x5c>
		panic("pgfault: error!\n");
  801008:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  80100f:	00 
  801010:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801017:	00 
  801018:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  80101f:	e8 9c f1 ff ff       	call   8001c0 <_panic>
	envid_t envid = sys_getenvid();
  801024:	e8 ee fb ff ff       	call   800c17 <sys_getenvid>
  801029:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  80102b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801032:	00 
  801033:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80103a:	00 
  80103b:	89 04 24             	mov    %eax,(%esp)
  80103e:	e8 12 fc ff ff       	call   800c55 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  801043:	85 c0                	test   %eax,%eax
  801045:	79 1c                	jns    801063 <pgfault+0x9b>
  801047:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  80104e:	00 
  80104f:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801056:	00 
  801057:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  80105e:	e8 5d f1 ff ff       	call   8001c0 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  801063:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  801069:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801070:	00 
  801071:	89 74 24 04          	mov    %esi,0x4(%esp)
  801075:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80107c:	e8 c5 f9 ff ff       	call   800a46 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  801081:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801088:	00 
  801089:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80108d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801091:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801098:	00 
  801099:	89 1c 24             	mov    %ebx,(%esp)
  80109c:	e8 08 fc ff ff       	call   800ca9 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 1c                	jns    8010c1 <pgfault+0xf9>
  8010a5:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  8010ac:	00 
  8010ad:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8010b4:	00 
  8010b5:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8010bc:	e8 ff f0 ff ff       	call   8001c0 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  8010c1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010c8:	00 
  8010c9:	89 1c 24             	mov    %ebx,(%esp)
  8010cc:	e8 2b fc ff ff       	call   800cfc <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	79 1c                	jns    8010f1 <pgfault+0x129>
  8010d5:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8010e4:	00 
  8010e5:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8010ec:	e8 cf f0 ff ff       	call   8001c0 <_panic>
	return;
	panic("pgfault not implemented");
}
  8010f1:	83 c4 20             	add    $0x20,%esp
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801101:	c7 04 24 c8 0f 80 00 	movl   $0x800fc8,(%esp)
  801108:	e8 23 12 00 00       	call   802330 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80110d:	bf 07 00 00 00       	mov    $0x7,%edi
  801112:	89 f8                	mov    %edi,%eax
  801114:	cd 30                	int    $0x30
  801116:	89 c7                	mov    %eax,%edi
  801118:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  80111a:	85 c0                	test   %eax,%eax
  80111c:	79 1c                	jns    80113a <fork+0x42>
		panic("fork : error!\n");
  80111e:	c7 44 24 08 43 2a 80 	movl   $0x802a43,0x8(%esp)
  801125:	00 
  801126:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  80112d:	00 
  80112e:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  801135:	e8 86 f0 ff ff       	call   8001c0 <_panic>
	if (envid==0){
  80113a:	85 c0                	test   %eax,%eax
  80113c:	75 28                	jne    801166 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  80113e:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801144:	e8 ce fa ff ff       	call   800c17 <sys_getenvid>
  801149:	25 ff 03 00 00       	and    $0x3ff,%eax
  80114e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801155:	c1 e0 07             	shl    $0x7,%eax
  801158:	29 d0                	sub    %edx,%eax
  80115a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80115f:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  801161:	e9 f2 00 00 00       	jmp    801258 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  801166:	e8 ac fa ff ff       	call   800c17 <sys_getenvid>
  80116b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80116e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  801173:	89 d8                	mov    %ebx,%eax
  801175:	c1 e8 16             	shr    $0x16,%eax
  801178:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80117f:	a8 01                	test   $0x1,%al
  801181:	74 17                	je     80119a <fork+0xa2>
  801183:	89 da                	mov    %ebx,%edx
  801185:	c1 ea 0c             	shr    $0xc,%edx
  801188:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80118f:	a8 01                	test   $0x1,%al
  801191:	74 07                	je     80119a <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801193:	89 f0                	mov    %esi,%eax
  801195:	e8 26 fd ff ff       	call   800ec0 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80119a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011a0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011a6:	75 cb                	jne    801173 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  8011a8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011af:	00 
  8011b0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011b7:	ee 
  8011b8:	89 3c 24             	mov    %edi,(%esp)
  8011bb:	e8 95 fa ff ff       	call   800c55 <sys_page_alloc>
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	79 1c                	jns    8011e0 <fork+0xe8>
  8011c4:	c7 44 24 08 43 2a 80 	movl   $0x802a43,0x8(%esp)
  8011cb:	00 
  8011cc:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8011d3:	00 
  8011d4:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8011db:	e8 e0 ef ff ff       	call   8001c0 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  8011e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011ef:	c1 e0 07             	shl    $0x7,%eax
  8011f2:	29 d0                	sub    %edx,%eax
  8011f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011f9:	8b 40 64             	mov    0x64(%eax),%eax
  8011fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801200:	89 3c 24             	mov    %edi,(%esp)
  801203:	e8 ed fb ff ff       	call   800df5 <sys_env_set_pgfault_upcall>
  801208:	85 c0                	test   %eax,%eax
  80120a:	79 1c                	jns    801228 <fork+0x130>
  80120c:	c7 44 24 08 43 2a 80 	movl   $0x802a43,0x8(%esp)
  801213:	00 
  801214:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80121b:	00 
  80121c:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  801223:	e8 98 ef ff ff       	call   8001c0 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  801228:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80122f:	00 
  801230:	89 3c 24             	mov    %edi,(%esp)
  801233:	e8 17 fb ff ff       	call   800d4f <sys_env_set_status>
  801238:	85 c0                	test   %eax,%eax
  80123a:	79 1c                	jns    801258 <fork+0x160>
  80123c:	c7 44 24 08 43 2a 80 	movl   $0x802a43,0x8(%esp)
  801243:	00 
  801244:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  80124b:	00 
  80124c:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  801253:	e8 68 ef ff ff       	call   8001c0 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801258:	89 f8                	mov    %edi,%eax
  80125a:	83 c4 2c             	add    $0x2c,%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <sfork>:

// Challenge!
int
sfork(void)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	57                   	push   %edi
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  80126b:	c7 04 24 c8 0f 80 00 	movl   $0x800fc8,(%esp)
  801272:	e8 b9 10 00 00       	call   802330 <set_pgfault_handler>
  801277:	ba 07 00 00 00       	mov    $0x7,%edx
  80127c:	89 d0                	mov    %edx,%eax
  80127e:	cd 30                	int    $0x30
  801280:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801283:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801285:	89 44 24 04          	mov    %eax,0x4(%esp)
  801289:	c7 04 24 37 2a 80 00 	movl   $0x802a37,(%esp)
  801290:	e8 23 f0 ff ff       	call   8002b8 <cprintf>
	if (envid<0)
  801295:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801299:	79 1c                	jns    8012b7 <sfork+0x55>
		panic("sfork : error!\n");
  80129b:	c7 44 24 08 42 2a 80 	movl   $0x802a42,0x8(%esp)
  8012a2:	00 
  8012a3:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  8012aa:	00 
  8012ab:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8012b2:	e8 09 ef ff ff       	call   8001c0 <_panic>
	if (envid==0){
  8012b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8012bb:	75 28                	jne    8012e5 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  8012bd:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8012c3:	e8 4f f9 ff ff       	call   800c17 <sys_getenvid>
  8012c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8012d4:	c1 e0 07             	shl    $0x7,%eax
  8012d7:	29 d0                	sub    %edx,%eax
  8012d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012de:	89 03                	mov    %eax,(%ebx)
		return envid;
  8012e0:	e9 18 01 00 00       	jmp    8013fd <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  8012e5:	e8 2d f9 ff ff       	call   800c17 <sys_getenvid>
  8012ea:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8012ec:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8012f1:	89 d8                	mov    %ebx,%eax
  8012f3:	c1 e8 16             	shr    $0x16,%eax
  8012f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012fd:	a8 01                	test   $0x1,%al
  8012ff:	74 2c                	je     80132d <sfork+0xcb>
  801301:	89 d8                	mov    %ebx,%eax
  801303:	c1 e8 0c             	shr    $0xc,%eax
  801306:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130d:	a8 01                	test   $0x1,%al
  80130f:	74 1c                	je     80132d <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  801311:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801318:	00 
  801319:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80131d:	89 74 24 08          	mov    %esi,0x8(%esp)
  801321:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801325:	89 3c 24             	mov    %edi,(%esp)
  801328:	e8 7c f9 ff ff       	call   800ca9 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80132d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801333:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801339:	75 b6                	jne    8012f1 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  80133b:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801340:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801343:	e8 78 fb ff ff       	call   800ec0 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801348:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80134f:	00 
  801350:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801357:	ee 
  801358:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	e8 f2 f8 ff ff       	call   800c55 <sys_page_alloc>
  801363:	85 c0                	test   %eax,%eax
  801365:	79 1c                	jns    801383 <sfork+0x121>
  801367:	c7 44 24 08 42 2a 80 	movl   $0x802a42,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  801376:	00 
  801377:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  80137e:	e8 3d ee ff ff       	call   8001c0 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  801383:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801389:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801390:	c1 e7 07             	shl    $0x7,%edi
  801393:	29 d7                	sub    %edx,%edi
  801395:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80139b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a2:	89 04 24             	mov    %eax,(%esp)
  8013a5:	e8 4b fa ff ff       	call   800df5 <sys_env_set_pgfault_upcall>
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	79 1c                	jns    8013ca <sfork+0x168>
  8013ae:	c7 44 24 08 42 2a 80 	movl   $0x802a42,0x8(%esp)
  8013b5:	00 
  8013b6:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  8013bd:	00 
  8013be:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8013c5:	e8 f6 ed ff ff       	call   8001c0 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  8013ca:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013d1:	00 
  8013d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013d5:	89 04 24             	mov    %eax,(%esp)
  8013d8:	e8 72 f9 ff ff       	call   800d4f <sys_env_set_status>
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	79 1c                	jns    8013fd <sfork+0x19b>
  8013e1:	c7 44 24 08 42 2a 80 	movl   $0x802a42,0x8(%esp)
  8013e8:	00 
  8013e9:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8013f0:	00 
  8013f1:	c7 04 24 1b 2a 80 00 	movl   $0x802a1b,(%esp)
  8013f8:	e8 c3 ed ff ff       	call   8001c0 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8013fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801400:	83 c4 3c             	add    $0x3c,%esp
  801403:	5b                   	pop    %ebx
  801404:	5e                   	pop    %esi
  801405:	5f                   	pop    %edi
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	83 ec 10             	sub    $0x10,%esp
  801410:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801413:	8b 45 0c             	mov    0xc(%ebp),%eax
  801416:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801419:	85 c0                	test   %eax,%eax
  80141b:	75 05                	jne    801422 <ipc_recv+0x1a>
  80141d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801422:	89 04 24             	mov    %eax,(%esp)
  801425:	e8 41 fa ff ff       	call   800e6b <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80142a:	85 c0                	test   %eax,%eax
  80142c:	79 16                	jns    801444 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  80142e:	85 db                	test   %ebx,%ebx
  801430:	74 06                	je     801438 <ipc_recv+0x30>
  801432:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801438:	85 f6                	test   %esi,%esi
  80143a:	74 32                	je     80146e <ipc_recv+0x66>
  80143c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801442:	eb 2a                	jmp    80146e <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801444:	85 db                	test   %ebx,%ebx
  801446:	74 0c                	je     801454 <ipc_recv+0x4c>
  801448:	a1 04 40 80 00       	mov    0x804004,%eax
  80144d:	8b 00                	mov    (%eax),%eax
  80144f:	8b 40 74             	mov    0x74(%eax),%eax
  801452:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801454:	85 f6                	test   %esi,%esi
  801456:	74 0c                	je     801464 <ipc_recv+0x5c>
  801458:	a1 04 40 80 00       	mov    0x804004,%eax
  80145d:	8b 00                	mov    (%eax),%eax
  80145f:	8b 40 78             	mov    0x78(%eax),%eax
  801462:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801464:	a1 04 40 80 00       	mov    0x804004,%eax
  801469:	8b 00                	mov    (%eax),%eax
  80146b:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	5b                   	pop    %ebx
  801472:	5e                   	pop    %esi
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    

00801475 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	57                   	push   %edi
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	83 ec 1c             	sub    $0x1c,%esp
  80147e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801481:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801484:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801487:	85 db                	test   %ebx,%ebx
  801489:	75 05                	jne    801490 <ipc_send+0x1b>
  80148b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801490:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801494:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801498:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80149c:	8b 45 08             	mov    0x8(%ebp),%eax
  80149f:	89 04 24             	mov    %eax,(%esp)
  8014a2:	e8 a1 f9 ff ff       	call   800e48 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8014a7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8014aa:	75 07                	jne    8014b3 <ipc_send+0x3e>
  8014ac:	e8 85 f7 ff ff       	call   800c36 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8014b1:	eb dd                	jmp    801490 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	79 1c                	jns    8014d3 <ipc_send+0x5e>
  8014b7:	c7 44 24 08 52 2a 80 	movl   $0x802a52,0x8(%esp)
  8014be:	00 
  8014bf:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8014c6:	00 
  8014c7:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  8014ce:	e8 ed ec ff ff       	call   8001c0 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  8014d3:	83 c4 1c             	add    $0x1c,%esp
  8014d6:	5b                   	pop    %ebx
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8014e2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014e7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	c1 e2 07             	shl    $0x7,%edx
  8014f3:	29 ca                	sub    %ecx,%edx
  8014f5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014fb:	8b 52 50             	mov    0x50(%edx),%edx
  8014fe:	39 da                	cmp    %ebx,%edx
  801500:	75 0f                	jne    801511 <ipc_find_env+0x36>
			return envs[i].env_id;
  801502:	c1 e0 07             	shl    $0x7,%eax
  801505:	29 c8                	sub    %ecx,%eax
  801507:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80150c:	8b 40 40             	mov    0x40(%eax),%eax
  80150f:	eb 0c                	jmp    80151d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801511:	40                   	inc    %eax
  801512:	3d 00 04 00 00       	cmp    $0x400,%eax
  801517:	75 ce                	jne    8014e7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801519:	66 b8 00 00          	mov    $0x0,%ax
}
  80151d:	5b                   	pop    %ebx
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801523:	8b 45 08             	mov    0x8(%ebp),%eax
  801526:	05 00 00 00 30       	add    $0x30000000,%eax
  80152b:	c1 e8 0c             	shr    $0xc,%eax
}
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	89 04 24             	mov    %eax,(%esp)
  80153c:	e8 df ff ff ff       	call   801520 <fd2num>
  801541:	05 20 00 0d 00       	add    $0xd0020,%eax
  801546:	c1 e0 0c             	shl    $0xc,%eax
}
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	53                   	push   %ebx
  80154f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801552:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801557:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801559:	89 c2                	mov    %eax,%edx
  80155b:	c1 ea 16             	shr    $0x16,%edx
  80155e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801565:	f6 c2 01             	test   $0x1,%dl
  801568:	74 11                	je     80157b <fd_alloc+0x30>
  80156a:	89 c2                	mov    %eax,%edx
  80156c:	c1 ea 0c             	shr    $0xc,%edx
  80156f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801576:	f6 c2 01             	test   $0x1,%dl
  801579:	75 09                	jne    801584 <fd_alloc+0x39>
			*fd_store = fd;
  80157b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80157d:	b8 00 00 00 00       	mov    $0x0,%eax
  801582:	eb 17                	jmp    80159b <fd_alloc+0x50>
  801584:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801589:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80158e:	75 c7                	jne    801557 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801590:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801596:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80159b:	5b                   	pop    %ebx
  80159c:	5d                   	pop    %ebp
  80159d:	c3                   	ret    

0080159e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80159e:	55                   	push   %ebp
  80159f:	89 e5                	mov    %esp,%ebp
  8015a1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015a4:	83 f8 1f             	cmp    $0x1f,%eax
  8015a7:	77 36                	ja     8015df <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015a9:	05 00 00 0d 00       	add    $0xd0000,%eax
  8015ae:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	c1 ea 16             	shr    $0x16,%edx
  8015b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015bd:	f6 c2 01             	test   $0x1,%dl
  8015c0:	74 24                	je     8015e6 <fd_lookup+0x48>
  8015c2:	89 c2                	mov    %eax,%edx
  8015c4:	c1 ea 0c             	shr    $0xc,%edx
  8015c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015ce:	f6 c2 01             	test   $0x1,%dl
  8015d1:	74 1a                	je     8015ed <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d6:	89 02                	mov    %eax,(%edx)
	return 0;
  8015d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015dd:	eb 13                	jmp    8015f2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e4:	eb 0c                	jmp    8015f2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015eb:	eb 05                	jmp    8015f2 <fd_lookup+0x54>
  8015ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	53                   	push   %ebx
  8015f8:	83 ec 14             	sub    $0x14,%esp
  8015fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801601:	ba 00 00 00 00       	mov    $0x0,%edx
  801606:	eb 0e                	jmp    801616 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801608:	39 08                	cmp    %ecx,(%eax)
  80160a:	75 09                	jne    801615 <dev_lookup+0x21>
			*dev = devtab[i];
  80160c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80160e:	b8 00 00 00 00       	mov    $0x0,%eax
  801613:	eb 35                	jmp    80164a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801615:	42                   	inc    %edx
  801616:	8b 04 95 ec 2a 80 00 	mov    0x802aec(,%edx,4),%eax
  80161d:	85 c0                	test   %eax,%eax
  80161f:	75 e7                	jne    801608 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801621:	a1 04 40 80 00       	mov    0x804004,%eax
  801626:	8b 00                	mov    (%eax),%eax
  801628:	8b 40 48             	mov    0x48(%eax),%eax
  80162b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80162f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801633:	c7 04 24 70 2a 80 00 	movl   $0x802a70,(%esp)
  80163a:	e8 79 ec ff ff       	call   8002b8 <cprintf>
	*dev = 0;
  80163f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801645:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80164a:	83 c4 14             	add    $0x14,%esp
  80164d:	5b                   	pop    %ebx
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	56                   	push   %esi
  801654:	53                   	push   %ebx
  801655:	83 ec 30             	sub    $0x30,%esp
  801658:	8b 75 08             	mov    0x8(%ebp),%esi
  80165b:	8a 45 0c             	mov    0xc(%ebp),%al
  80165e:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801661:	89 34 24             	mov    %esi,(%esp)
  801664:	e8 b7 fe ff ff       	call   801520 <fd2num>
  801669:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80166c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801670:	89 04 24             	mov    %eax,(%esp)
  801673:	e8 26 ff ff ff       	call   80159e <fd_lookup>
  801678:	89 c3                	mov    %eax,%ebx
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 05                	js     801683 <fd_close+0x33>
	    || fd != fd2)
  80167e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801681:	74 0d                	je     801690 <fd_close+0x40>
		return (must_exist ? r : 0);
  801683:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801687:	75 46                	jne    8016cf <fd_close+0x7f>
  801689:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168e:	eb 3f                	jmp    8016cf <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801693:	89 44 24 04          	mov    %eax,0x4(%esp)
  801697:	8b 06                	mov    (%esi),%eax
  801699:	89 04 24             	mov    %eax,(%esp)
  80169c:	e8 53 ff ff ff       	call   8015f4 <dev_lookup>
  8016a1:	89 c3                	mov    %eax,%ebx
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 18                	js     8016bf <fd_close+0x6f>
		if (dev->dev_close)
  8016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016aa:	8b 40 10             	mov    0x10(%eax),%eax
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	74 09                	je     8016ba <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8016b1:	89 34 24             	mov    %esi,(%esp)
  8016b4:	ff d0                	call   *%eax
  8016b6:	89 c3                	mov    %eax,%ebx
  8016b8:	eb 05                	jmp    8016bf <fd_close+0x6f>
		else
			r = 0;
  8016ba:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ca:	e8 2d f6 ff ff       	call   800cfc <sys_page_unmap>
	return r;
}
  8016cf:	89 d8                	mov    %ebx,%eax
  8016d1:	83 c4 30             	add    $0x30,%esp
  8016d4:	5b                   	pop    %ebx
  8016d5:	5e                   	pop    %esi
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e8:	89 04 24             	mov    %eax,(%esp)
  8016eb:	e8 ae fe ff ff       	call   80159e <fd_lookup>
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 13                	js     801707 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016fb:	00 
  8016fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ff:	89 04 24             	mov    %eax,(%esp)
  801702:	e8 49 ff ff ff       	call   801650 <fd_close>
}
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <close_all>:

void
close_all(void)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	53                   	push   %ebx
  80170d:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801710:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801715:	89 1c 24             	mov    %ebx,(%esp)
  801718:	e8 bb ff ff ff       	call   8016d8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80171d:	43                   	inc    %ebx
  80171e:	83 fb 20             	cmp    $0x20,%ebx
  801721:	75 f2                	jne    801715 <close_all+0xc>
		close(i);
}
  801723:	83 c4 14             	add    $0x14,%esp
  801726:	5b                   	pop    %ebx
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	57                   	push   %edi
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	83 ec 4c             	sub    $0x4c,%esp
  801732:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801735:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173c:	8b 45 08             	mov    0x8(%ebp),%eax
  80173f:	89 04 24             	mov    %eax,(%esp)
  801742:	e8 57 fe ff ff       	call   80159e <fd_lookup>
  801747:	89 c3                	mov    %eax,%ebx
  801749:	85 c0                	test   %eax,%eax
  80174b:	0f 88 e1 00 00 00    	js     801832 <dup+0x109>
		return r;
	close(newfdnum);
  801751:	89 3c 24             	mov    %edi,(%esp)
  801754:	e8 7f ff ff ff       	call   8016d8 <close>

	newfd = INDEX2FD(newfdnum);
  801759:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80175f:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801765:	89 04 24             	mov    %eax,(%esp)
  801768:	e8 c3 fd ff ff       	call   801530 <fd2data>
  80176d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80176f:	89 34 24             	mov    %esi,(%esp)
  801772:	e8 b9 fd ff ff       	call   801530 <fd2data>
  801777:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80177a:	89 d8                	mov    %ebx,%eax
  80177c:	c1 e8 16             	shr    $0x16,%eax
  80177f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801786:	a8 01                	test   $0x1,%al
  801788:	74 46                	je     8017d0 <dup+0xa7>
  80178a:	89 d8                	mov    %ebx,%eax
  80178c:	c1 e8 0c             	shr    $0xc,%eax
  80178f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801796:	f6 c2 01             	test   $0x1,%dl
  801799:	74 35                	je     8017d0 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80179b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8017a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b9:	00 
  8017ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c5:	e8 df f4 ff ff       	call   800ca9 <sys_page_map>
  8017ca:	89 c3                	mov    %eax,%ebx
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 3b                	js     80180b <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017d3:	89 c2                	mov    %eax,%edx
  8017d5:	c1 ea 0c             	shr    $0xc,%edx
  8017d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017df:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017e9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017f4:	00 
  8017f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801800:	e8 a4 f4 ff ff       	call   800ca9 <sys_page_map>
  801805:	89 c3                	mov    %eax,%ebx
  801807:	85 c0                	test   %eax,%eax
  801809:	79 25                	jns    801830 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80180b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80180f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801816:	e8 e1 f4 ff ff       	call   800cfc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80181b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80181e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801822:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801829:	e8 ce f4 ff ff       	call   800cfc <sys_page_unmap>
	return r;
  80182e:	eb 02                	jmp    801832 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801830:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801832:	89 d8                	mov    %ebx,%eax
  801834:	83 c4 4c             	add    $0x4c,%esp
  801837:	5b                   	pop    %ebx
  801838:	5e                   	pop    %esi
  801839:	5f                   	pop    %edi
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	53                   	push   %ebx
  801840:	83 ec 24             	sub    $0x24,%esp
  801843:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801846:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184d:	89 1c 24             	mov    %ebx,(%esp)
  801850:	e8 49 fd ff ff       	call   80159e <fd_lookup>
  801855:	85 c0                	test   %eax,%eax
  801857:	78 6f                	js     8018c8 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801859:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801863:	8b 00                	mov    (%eax),%eax
  801865:	89 04 24             	mov    %eax,(%esp)
  801868:	e8 87 fd ff ff       	call   8015f4 <dev_lookup>
  80186d:	85 c0                	test   %eax,%eax
  80186f:	78 57                	js     8018c8 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801874:	8b 50 08             	mov    0x8(%eax),%edx
  801877:	83 e2 03             	and    $0x3,%edx
  80187a:	83 fa 01             	cmp    $0x1,%edx
  80187d:	75 25                	jne    8018a4 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80187f:	a1 04 40 80 00       	mov    0x804004,%eax
  801884:	8b 00                	mov    (%eax),%eax
  801886:	8b 40 48             	mov    0x48(%eax),%eax
  801889:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	c7 04 24 b1 2a 80 00 	movl   $0x802ab1,(%esp)
  801898:	e8 1b ea ff ff       	call   8002b8 <cprintf>
		return -E_INVAL;
  80189d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018a2:	eb 24                	jmp    8018c8 <read+0x8c>
	}
	if (!dev->dev_read)
  8018a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a7:	8b 52 08             	mov    0x8(%edx),%edx
  8018aa:	85 d2                	test   %edx,%edx
  8018ac:	74 15                	je     8018c3 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018bc:	89 04 24             	mov    %eax,(%esp)
  8018bf:	ff d2                	call   *%edx
  8018c1:	eb 05                	jmp    8018c8 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8018c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8018c8:	83 c4 24             	add    $0x24,%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5d                   	pop    %ebp
  8018cd:	c3                   	ret    

008018ce <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	57                   	push   %edi
  8018d2:	56                   	push   %esi
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 1c             	sub    $0x1c,%esp
  8018d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018da:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e2:	eb 23                	jmp    801907 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018e4:	89 f0                	mov    %esi,%eax
  8018e6:	29 d8                	sub    %ebx,%eax
  8018e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ef:	01 d8                	add    %ebx,%eax
  8018f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f5:	89 3c 24             	mov    %edi,(%esp)
  8018f8:	e8 3f ff ff ff       	call   80183c <read>
		if (m < 0)
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	78 10                	js     801911 <readn+0x43>
			return m;
		if (m == 0)
  801901:	85 c0                	test   %eax,%eax
  801903:	74 0a                	je     80190f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801905:	01 c3                	add    %eax,%ebx
  801907:	39 f3                	cmp    %esi,%ebx
  801909:	72 d9                	jb     8018e4 <readn+0x16>
  80190b:	89 d8                	mov    %ebx,%eax
  80190d:	eb 02                	jmp    801911 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80190f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801911:	83 c4 1c             	add    $0x1c,%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	5f                   	pop    %edi
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    

00801919 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	53                   	push   %ebx
  80191d:	83 ec 24             	sub    $0x24,%esp
  801920:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801923:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192a:	89 1c 24             	mov    %ebx,(%esp)
  80192d:	e8 6c fc ff ff       	call   80159e <fd_lookup>
  801932:	85 c0                	test   %eax,%eax
  801934:	78 6a                	js     8019a0 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801936:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801939:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801940:	8b 00                	mov    (%eax),%eax
  801942:	89 04 24             	mov    %eax,(%esp)
  801945:	e8 aa fc ff ff       	call   8015f4 <dev_lookup>
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 52                	js     8019a0 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80194e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801951:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801955:	75 25                	jne    80197c <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801957:	a1 04 40 80 00       	mov    0x804004,%eax
  80195c:	8b 00                	mov    (%eax),%eax
  80195e:	8b 40 48             	mov    0x48(%eax),%eax
  801961:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801965:	89 44 24 04          	mov    %eax,0x4(%esp)
  801969:	c7 04 24 cd 2a 80 00 	movl   $0x802acd,(%esp)
  801970:	e8 43 e9 ff ff       	call   8002b8 <cprintf>
		return -E_INVAL;
  801975:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80197a:	eb 24                	jmp    8019a0 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80197c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80197f:	8b 52 0c             	mov    0xc(%edx),%edx
  801982:	85 d2                	test   %edx,%edx
  801984:	74 15                	je     80199b <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801986:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801989:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80198d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801990:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801994:	89 04 24             	mov    %eax,(%esp)
  801997:	ff d2                	call   *%edx
  801999:	eb 05                	jmp    8019a0 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80199b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8019a0:	83 c4 24             	add    $0x24,%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b6:	89 04 24             	mov    %eax,(%esp)
  8019b9:	e8 e0 fb ff ff       	call   80159e <fd_lookup>
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 0e                	js     8019d0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8019c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8019cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	53                   	push   %ebx
  8019d6:	83 ec 24             	sub    $0x24,%esp
  8019d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e3:	89 1c 24             	mov    %ebx,(%esp)
  8019e6:	e8 b3 fb ff ff       	call   80159e <fd_lookup>
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 63                	js     801a52 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f9:	8b 00                	mov    (%eax),%eax
  8019fb:	89 04 24             	mov    %eax,(%esp)
  8019fe:	e8 f1 fb ff ff       	call   8015f4 <dev_lookup>
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 4b                	js     801a52 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a0e:	75 25                	jne    801a35 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a10:	a1 04 40 80 00       	mov    0x804004,%eax
  801a15:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a17:	8b 40 48             	mov    0x48(%eax),%eax
  801a1a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a22:	c7 04 24 90 2a 80 00 	movl   $0x802a90,(%esp)
  801a29:	e8 8a e8 ff ff       	call   8002b8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a33:	eb 1d                	jmp    801a52 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801a35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a38:	8b 52 18             	mov    0x18(%edx),%edx
  801a3b:	85 d2                	test   %edx,%edx
  801a3d:	74 0e                	je     801a4d <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a46:	89 04 24             	mov    %eax,(%esp)
  801a49:	ff d2                	call   *%edx
  801a4b:	eb 05                	jmp    801a52 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a4d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a52:	83 c4 24             	add    $0x24,%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	53                   	push   %ebx
  801a5c:	83 ec 24             	sub    $0x24,%esp
  801a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	89 04 24             	mov    %eax,(%esp)
  801a6f:	e8 2a fb ff ff       	call   80159e <fd_lookup>
  801a74:	85 c0                	test   %eax,%eax
  801a76:	78 52                	js     801aca <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a82:	8b 00                	mov    (%eax),%eax
  801a84:	89 04 24             	mov    %eax,(%esp)
  801a87:	e8 68 fb ff ff       	call   8015f4 <dev_lookup>
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	78 3a                	js     801aca <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a93:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a97:	74 2c                	je     801ac5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a99:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a9c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801aa3:	00 00 00 
	stat->st_isdir = 0;
  801aa6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aad:	00 00 00 
	stat->st_dev = dev;
  801ab0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ab6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801abd:	89 14 24             	mov    %edx,(%esp)
  801ac0:	ff 50 14             	call   *0x14(%eax)
  801ac3:	eb 05                	jmp    801aca <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ac5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801aca:	83 c4 24             	add    $0x24,%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ad8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801adf:	00 
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	89 04 24             	mov    %eax,(%esp)
  801ae6:	e8 88 02 00 00       	call   801d73 <open>
  801aeb:	89 c3                	mov    %eax,%ebx
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 1b                	js     801b0c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801af1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af8:	89 1c 24             	mov    %ebx,(%esp)
  801afb:	e8 58 ff ff ff       	call   801a58 <fstat>
  801b00:	89 c6                	mov    %eax,%esi
	close(fd);
  801b02:	89 1c 24             	mov    %ebx,(%esp)
  801b05:	e8 ce fb ff ff       	call   8016d8 <close>
	return r;
  801b0a:	89 f3                	mov    %esi,%ebx
}
  801b0c:	89 d8                	mov    %ebx,%eax
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    
  801b15:	00 00                	add    %al,(%eax)
	...

00801b18 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	56                   	push   %esi
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 10             	sub    $0x10,%esp
  801b20:	89 c3                	mov    %eax,%ebx
  801b22:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b24:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b2b:	75 11                	jne    801b3e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b34:	e8 a2 f9 ff ff       	call   8014db <ipc_find_env>
  801b39:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b3e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b45:	00 
  801b46:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b4d:	00 
  801b4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b52:	a1 00 40 80 00       	mov    0x804000,%eax
  801b57:	89 04 24             	mov    %eax,(%esp)
  801b5a:	e8 16 f9 ff ff       	call   801475 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801b5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b66:	00 
  801b67:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b72:	e8 91 f8 ff ff       	call   801408 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	5b                   	pop    %ebx
  801b7b:	5e                   	pop    %esi
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b92:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b97:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9c:	b8 02 00 00 00       	mov    $0x2,%eax
  801ba1:	e8 72 ff ff ff       	call   801b18 <fsipc>
}
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bae:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb1:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbe:	b8 06 00 00 00       	mov    $0x6,%eax
  801bc3:	e8 50 ff ff ff       	call   801b18 <fsipc>
}
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	53                   	push   %ebx
  801bce:	83 ec 14             	sub    $0x14,%esp
  801bd1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd7:	8b 40 0c             	mov    0xc(%eax),%eax
  801bda:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  801be4:	b8 05 00 00 00       	mov    $0x5,%eax
  801be9:	e8 2a ff ff ff       	call   801b18 <fsipc>
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 2b                	js     801c1d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bf2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801bf9:	00 
  801bfa:	89 1c 24             	mov    %ebx,(%esp)
  801bfd:	e8 61 ec ff ff       	call   800863 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c02:	a1 80 50 80 00       	mov    0x805080,%eax
  801c07:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c0d:	a1 84 50 80 00       	mov    0x805084,%eax
  801c12:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c1d:	83 c4 14             	add    $0x14,%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	53                   	push   %ebx
  801c27:	83 ec 14             	sub    $0x14,%esp
  801c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	8b 40 0c             	mov    0xc(%eax),%eax
  801c33:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801c38:	89 d8                	mov    %ebx,%eax
  801c3a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801c40:	76 05                	jbe    801c47 <devfile_write+0x24>
  801c42:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801c47:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801c4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c57:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801c5e:	e8 e3 ed ff ff       	call   800a46 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801c63:	ba 00 00 00 00       	mov    $0x0,%edx
  801c68:	b8 04 00 00 00       	mov    $0x4,%eax
  801c6d:	e8 a6 fe ff ff       	call   801b18 <fsipc>
  801c72:	85 c0                	test   %eax,%eax
  801c74:	78 53                	js     801cc9 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801c76:	39 c3                	cmp    %eax,%ebx
  801c78:	73 24                	jae    801c9e <devfile_write+0x7b>
  801c7a:	c7 44 24 0c fc 2a 80 	movl   $0x802afc,0xc(%esp)
  801c81:	00 
  801c82:	c7 44 24 08 03 2b 80 	movl   $0x802b03,0x8(%esp)
  801c89:	00 
  801c8a:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801c91:	00 
  801c92:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  801c99:	e8 22 e5 ff ff       	call   8001c0 <_panic>
	assert(r <= PGSIZE);
  801c9e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ca3:	7e 24                	jle    801cc9 <devfile_write+0xa6>
  801ca5:	c7 44 24 0c 23 2b 80 	movl   $0x802b23,0xc(%esp)
  801cac:	00 
  801cad:	c7 44 24 08 03 2b 80 	movl   $0x802b03,0x8(%esp)
  801cb4:	00 
  801cb5:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801cbc:	00 
  801cbd:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  801cc4:	e8 f7 e4 ff ff       	call   8001c0 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801cc9:	83 c4 14             	add    $0x14,%esp
  801ccc:	5b                   	pop    %ebx
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 10             	sub    $0x10,%esp
  801cd7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ce5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf0:	b8 03 00 00 00       	mov    $0x3,%eax
  801cf5:	e8 1e fe ff ff       	call   801b18 <fsipc>
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 6a                	js     801d6a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801d00:	39 c6                	cmp    %eax,%esi
  801d02:	73 24                	jae    801d28 <devfile_read+0x59>
  801d04:	c7 44 24 0c fc 2a 80 	movl   $0x802afc,0xc(%esp)
  801d0b:	00 
  801d0c:	c7 44 24 08 03 2b 80 	movl   $0x802b03,0x8(%esp)
  801d13:	00 
  801d14:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801d1b:	00 
  801d1c:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  801d23:	e8 98 e4 ff ff       	call   8001c0 <_panic>
	assert(r <= PGSIZE);
  801d28:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d2d:	7e 24                	jle    801d53 <devfile_read+0x84>
  801d2f:	c7 44 24 0c 23 2b 80 	movl   $0x802b23,0xc(%esp)
  801d36:	00 
  801d37:	c7 44 24 08 03 2b 80 	movl   $0x802b03,0x8(%esp)
  801d3e:	00 
  801d3f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801d46:	00 
  801d47:	c7 04 24 18 2b 80 00 	movl   $0x802b18,(%esp)
  801d4e:	e8 6d e4 ff ff       	call   8001c0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d53:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d57:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d5e:	00 
  801d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d62:	89 04 24             	mov    %eax,(%esp)
  801d65:	e8 72 ec ff ff       	call   8009dc <memmove>
	return r;
}
  801d6a:	89 d8                	mov    %ebx,%eax
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	5b                   	pop    %ebx
  801d70:	5e                   	pop    %esi
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    

00801d73 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	83 ec 20             	sub    $0x20,%esp
  801d7b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d7e:	89 34 24             	mov    %esi,(%esp)
  801d81:	e8 aa ea ff ff       	call   800830 <strlen>
  801d86:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d8b:	7f 60                	jg     801ded <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d90:	89 04 24             	mov    %eax,(%esp)
  801d93:	e8 b3 f7 ff ff       	call   80154b <fd_alloc>
  801d98:	89 c3                	mov    %eax,%ebx
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	78 54                	js     801df2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d9e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801da2:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801da9:	e8 b5 ea ff ff       	call   800863 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801db6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbe:	e8 55 fd ff ff       	call   801b18 <fsipc>
  801dc3:	89 c3                	mov    %eax,%ebx
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	79 15                	jns    801dde <open+0x6b>
		fd_close(fd, 0);
  801dc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dd0:	00 
  801dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd4:	89 04 24             	mov    %eax,(%esp)
  801dd7:	e8 74 f8 ff ff       	call   801650 <fd_close>
		return r;
  801ddc:	eb 14                	jmp    801df2 <open+0x7f>
	}

	return fd2num(fd);
  801dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de1:	89 04 24             	mov    %eax,(%esp)
  801de4:	e8 37 f7 ff ff       	call   801520 <fd2num>
  801de9:	89 c3                	mov    %eax,%ebx
  801deb:	eb 05                	jmp    801df2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ded:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801df2:	89 d8                	mov    %ebx,%eax
  801df4:	83 c4 20             	add    $0x20,%esp
  801df7:	5b                   	pop    %ebx
  801df8:	5e                   	pop    %esi
  801df9:	5d                   	pop    %ebp
  801dfa:	c3                   	ret    

00801dfb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e01:	ba 00 00 00 00       	mov    $0x0,%edx
  801e06:	b8 08 00 00 00       	mov    $0x8,%eax
  801e0b:	e8 08 fd ff ff       	call   801b18 <fsipc>
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    
	...

00801e14 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	56                   	push   %esi
  801e18:	53                   	push   %ebx
  801e19:	83 ec 10             	sub    $0x10,%esp
  801e1c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	89 04 24             	mov    %eax,(%esp)
  801e25:	e8 06 f7 ff ff       	call   801530 <fd2data>
  801e2a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e2c:	c7 44 24 04 2f 2b 80 	movl   $0x802b2f,0x4(%esp)
  801e33:	00 
  801e34:	89 34 24             	mov    %esi,(%esp)
  801e37:	e8 27 ea ff ff       	call   800863 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e3f:	2b 03                	sub    (%ebx),%eax
  801e41:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e47:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e4e:	00 00 00 
	stat->st_dev = &devpipe;
  801e51:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801e58:	30 80 00 
	return 0;
}
  801e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	53                   	push   %ebx
  801e6b:	83 ec 14             	sub    $0x14,%esp
  801e6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e7c:	e8 7b ee ff ff       	call   800cfc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e81:	89 1c 24             	mov    %ebx,(%esp)
  801e84:	e8 a7 f6 ff ff       	call   801530 <fd2data>
  801e89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e94:	e8 63 ee ff ff       	call   800cfc <sys_page_unmap>
}
  801e99:	83 c4 14             	add    $0x14,%esp
  801e9c:	5b                   	pop    %ebx
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    

00801e9f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	57                   	push   %edi
  801ea3:	56                   	push   %esi
  801ea4:	53                   	push   %ebx
  801ea5:	83 ec 2c             	sub    $0x2c,%esp
  801ea8:	89 c7                	mov    %eax,%edi
  801eaa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ead:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb2:	8b 00                	mov    (%eax),%eax
  801eb4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801eb7:	89 3c 24             	mov    %edi,(%esp)
  801eba:	e8 29 05 00 00       	call   8023e8 <pageref>
  801ebf:	89 c6                	mov    %eax,%esi
  801ec1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec4:	89 04 24             	mov    %eax,(%esp)
  801ec7:	e8 1c 05 00 00       	call   8023e8 <pageref>
  801ecc:	39 c6                	cmp    %eax,%esi
  801ece:	0f 94 c0             	sete   %al
  801ed1:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ed4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801eda:	8b 12                	mov    (%edx),%edx
  801edc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801edf:	39 cb                	cmp    %ecx,%ebx
  801ee1:	75 08                	jne    801eeb <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ee3:	83 c4 2c             	add    $0x2c,%esp
  801ee6:	5b                   	pop    %ebx
  801ee7:	5e                   	pop    %esi
  801ee8:	5f                   	pop    %edi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801eeb:	83 f8 01             	cmp    $0x1,%eax
  801eee:	75 bd                	jne    801ead <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ef0:	8b 42 58             	mov    0x58(%edx),%eax
  801ef3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801efa:	00 
  801efb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f03:	c7 04 24 36 2b 80 00 	movl   $0x802b36,(%esp)
  801f0a:	e8 a9 e3 ff ff       	call   8002b8 <cprintf>
  801f0f:	eb 9c                	jmp    801ead <_pipeisclosed+0xe>

00801f11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	57                   	push   %edi
  801f15:	56                   	push   %esi
  801f16:	53                   	push   %ebx
  801f17:	83 ec 1c             	sub    $0x1c,%esp
  801f1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f1d:	89 34 24             	mov    %esi,(%esp)
  801f20:	e8 0b f6 ff ff       	call   801530 <fd2data>
  801f25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f27:	bf 00 00 00 00       	mov    $0x0,%edi
  801f2c:	eb 3c                	jmp    801f6a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f2e:	89 da                	mov    %ebx,%edx
  801f30:	89 f0                	mov    %esi,%eax
  801f32:	e8 68 ff ff ff       	call   801e9f <_pipeisclosed>
  801f37:	85 c0                	test   %eax,%eax
  801f39:	75 38                	jne    801f73 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f3b:	e8 f6 ec ff ff       	call   800c36 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f40:	8b 43 04             	mov    0x4(%ebx),%eax
  801f43:	8b 13                	mov    (%ebx),%edx
  801f45:	83 c2 20             	add    $0x20,%edx
  801f48:	39 d0                	cmp    %edx,%eax
  801f4a:	73 e2                	jae    801f2e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f4f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f52:	89 c2                	mov    %eax,%edx
  801f54:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f5a:	79 05                	jns    801f61 <devpipe_write+0x50>
  801f5c:	4a                   	dec    %edx
  801f5d:	83 ca e0             	or     $0xffffffe0,%edx
  801f60:	42                   	inc    %edx
  801f61:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f65:	40                   	inc    %eax
  801f66:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f69:	47                   	inc    %edi
  801f6a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f6d:	75 d1                	jne    801f40 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f6f:	89 f8                	mov    %edi,%eax
  801f71:	eb 05                	jmp    801f78 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f78:	83 c4 1c             	add    $0x1c,%esp
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5f                   	pop    %edi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	57                   	push   %edi
  801f84:	56                   	push   %esi
  801f85:	53                   	push   %ebx
  801f86:	83 ec 1c             	sub    $0x1c,%esp
  801f89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f8c:	89 3c 24             	mov    %edi,(%esp)
  801f8f:	e8 9c f5 ff ff       	call   801530 <fd2data>
  801f94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f96:	be 00 00 00 00       	mov    $0x0,%esi
  801f9b:	eb 3a                	jmp    801fd7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f9d:	85 f6                	test   %esi,%esi
  801f9f:	74 04                	je     801fa5 <devpipe_read+0x25>
				return i;
  801fa1:	89 f0                	mov    %esi,%eax
  801fa3:	eb 40                	jmp    801fe5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fa5:	89 da                	mov    %ebx,%edx
  801fa7:	89 f8                	mov    %edi,%eax
  801fa9:	e8 f1 fe ff ff       	call   801e9f <_pipeisclosed>
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	75 2e                	jne    801fe0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fb2:	e8 7f ec ff ff       	call   800c36 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fb7:	8b 03                	mov    (%ebx),%eax
  801fb9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fbc:	74 df                	je     801f9d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fbe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801fc3:	79 05                	jns    801fca <devpipe_read+0x4a>
  801fc5:	48                   	dec    %eax
  801fc6:	83 c8 e0             	or     $0xffffffe0,%eax
  801fc9:	40                   	inc    %eax
  801fca:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801fce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801fd4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd6:	46                   	inc    %esi
  801fd7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fda:	75 db                	jne    801fb7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fdc:	89 f0                	mov    %esi,%eax
  801fde:	eb 05                	jmp    801fe5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fe5:	83 c4 1c             	add    $0x1c,%esp
  801fe8:	5b                   	pop    %ebx
  801fe9:	5e                   	pop    %esi
  801fea:	5f                   	pop    %edi
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    

00801fed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	57                   	push   %edi
  801ff1:	56                   	push   %esi
  801ff2:	53                   	push   %ebx
  801ff3:	83 ec 3c             	sub    $0x3c,%esp
  801ff6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ff9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ffc:	89 04 24             	mov    %eax,(%esp)
  801fff:	e8 47 f5 ff ff       	call   80154b <fd_alloc>
  802004:	89 c3                	mov    %eax,%ebx
  802006:	85 c0                	test   %eax,%eax
  802008:	0f 88 45 01 00 00    	js     802153 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80200e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802015:	00 
  802016:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802019:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802024:	e8 2c ec ff ff       	call   800c55 <sys_page_alloc>
  802029:	89 c3                	mov    %eax,%ebx
  80202b:	85 c0                	test   %eax,%eax
  80202d:	0f 88 20 01 00 00    	js     802153 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802033:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802036:	89 04 24             	mov    %eax,(%esp)
  802039:	e8 0d f5 ff ff       	call   80154b <fd_alloc>
  80203e:	89 c3                	mov    %eax,%ebx
  802040:	85 c0                	test   %eax,%eax
  802042:	0f 88 f8 00 00 00    	js     802140 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802048:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80204f:	00 
  802050:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802053:	89 44 24 04          	mov    %eax,0x4(%esp)
  802057:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80205e:	e8 f2 eb ff ff       	call   800c55 <sys_page_alloc>
  802063:	89 c3                	mov    %eax,%ebx
  802065:	85 c0                	test   %eax,%eax
  802067:	0f 88 d3 00 00 00    	js     802140 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80206d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802070:	89 04 24             	mov    %eax,(%esp)
  802073:	e8 b8 f4 ff ff       	call   801530 <fd2data>
  802078:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80207a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802081:	00 
  802082:	89 44 24 04          	mov    %eax,0x4(%esp)
  802086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80208d:	e8 c3 eb ff ff       	call   800c55 <sys_page_alloc>
  802092:	89 c3                	mov    %eax,%ebx
  802094:	85 c0                	test   %eax,%eax
  802096:	0f 88 91 00 00 00    	js     80212d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80209f:	89 04 24             	mov    %eax,(%esp)
  8020a2:	e8 89 f4 ff ff       	call   801530 <fd2data>
  8020a7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8020ae:	00 
  8020af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020ba:	00 
  8020bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c6:	e8 de eb ff ff       	call   800ca9 <sys_page_map>
  8020cb:	89 c3                	mov    %eax,%ebx
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 4c                	js     80211d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020d1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020da:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020e6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020ef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020fe:	89 04 24             	mov    %eax,(%esp)
  802101:	e8 1a f4 ff ff       	call   801520 <fd2num>
  802106:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802108:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80210b:	89 04 24             	mov    %eax,(%esp)
  80210e:	e8 0d f4 ff ff       	call   801520 <fd2num>
  802113:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802116:	bb 00 00 00 00       	mov    $0x0,%ebx
  80211b:	eb 36                	jmp    802153 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80211d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802121:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802128:	e8 cf eb ff ff       	call   800cfc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80212d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802130:	89 44 24 04          	mov    %eax,0x4(%esp)
  802134:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80213b:	e8 bc eb ff ff       	call   800cfc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802143:	89 44 24 04          	mov    %eax,0x4(%esp)
  802147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80214e:	e8 a9 eb ff ff       	call   800cfc <sys_page_unmap>
    err:
	return r;
}
  802153:	89 d8                	mov    %ebx,%eax
  802155:	83 c4 3c             	add    $0x3c,%esp
  802158:	5b                   	pop    %ebx
  802159:	5e                   	pop    %esi
  80215a:	5f                   	pop    %edi
  80215b:	5d                   	pop    %ebp
  80215c:	c3                   	ret    

0080215d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
  802160:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802163:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216a:	8b 45 08             	mov    0x8(%ebp),%eax
  80216d:	89 04 24             	mov    %eax,(%esp)
  802170:	e8 29 f4 ff ff       	call   80159e <fd_lookup>
  802175:	85 c0                	test   %eax,%eax
  802177:	78 15                	js     80218e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217c:	89 04 24             	mov    %eax,(%esp)
  80217f:	e8 ac f3 ff ff       	call   801530 <fd2data>
	return _pipeisclosed(fd, p);
  802184:	89 c2                	mov    %eax,%edx
  802186:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802189:	e8 11 fd ff ff       	call   801e9f <_pipeisclosed>
}
  80218e:	c9                   	leave  
  80218f:	c3                   	ret    

00802190 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802193:	b8 00 00 00 00       	mov    $0x0,%eax
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    

0080219a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8021a0:	c7 44 24 04 4e 2b 80 	movl   $0x802b4e,0x4(%esp)
  8021a7:	00 
  8021a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ab:	89 04 24             	mov    %eax,(%esp)
  8021ae:	e8 b0 e6 ff ff       	call   800863 <strcpy>
	return 0;
}
  8021b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    

008021ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
  8021bd:	57                   	push   %edi
  8021be:	56                   	push   %esi
  8021bf:	53                   	push   %ebx
  8021c0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d1:	eb 30                	jmp    802203 <devcons_write+0x49>
		m = n - tot;
  8021d3:	8b 75 10             	mov    0x10(%ebp),%esi
  8021d6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8021d8:	83 fe 7f             	cmp    $0x7f,%esi
  8021db:	76 05                	jbe    8021e2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8021dd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021e2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021e6:	03 45 0c             	add    0xc(%ebp),%eax
  8021e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ed:	89 3c 24             	mov    %edi,(%esp)
  8021f0:	e8 e7 e7 ff ff       	call   8009dc <memmove>
		sys_cputs(buf, m);
  8021f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f9:	89 3c 24             	mov    %edi,(%esp)
  8021fc:	e8 87 e9 ff ff       	call   800b88 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802201:	01 f3                	add    %esi,%ebx
  802203:	89 d8                	mov    %ebx,%eax
  802205:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802208:	72 c9                	jb     8021d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80220a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802210:	5b                   	pop    %ebx
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80221b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80221f:	75 07                	jne    802228 <devcons_read+0x13>
  802221:	eb 25                	jmp    802248 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802223:	e8 0e ea ff ff       	call   800c36 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802228:	e8 79 e9 ff ff       	call   800ba6 <sys_cgetc>
  80222d:	85 c0                	test   %eax,%eax
  80222f:	74 f2                	je     802223 <devcons_read+0xe>
  802231:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802233:	85 c0                	test   %eax,%eax
  802235:	78 1d                	js     802254 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802237:	83 f8 04             	cmp    $0x4,%eax
  80223a:	74 13                	je     80224f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80223c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80223f:	88 10                	mov    %dl,(%eax)
	return 1;
  802241:	b8 01 00 00 00       	mov    $0x1,%eax
  802246:	eb 0c                	jmp    802254 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802248:	b8 00 00 00 00       	mov    $0x0,%eax
  80224d:	eb 05                	jmp    802254 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80224f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802254:	c9                   	leave  
  802255:	c3                   	ret    

00802256 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802256:	55                   	push   %ebp
  802257:	89 e5                	mov    %esp,%ebp
  802259:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80225c:	8b 45 08             	mov    0x8(%ebp),%eax
  80225f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802262:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802269:	00 
  80226a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80226d:	89 04 24             	mov    %eax,(%esp)
  802270:	e8 13 e9 ff ff       	call   800b88 <sys_cputs>
}
  802275:	c9                   	leave  
  802276:	c3                   	ret    

00802277 <getchar>:

int
getchar(void)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80227d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802284:	00 
  802285:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802293:	e8 a4 f5 ff ff       	call   80183c <read>
	if (r < 0)
  802298:	85 c0                	test   %eax,%eax
  80229a:	78 0f                	js     8022ab <getchar+0x34>
		return r;
	if (r < 1)
  80229c:	85 c0                	test   %eax,%eax
  80229e:	7e 06                	jle    8022a6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8022a0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022a4:	eb 05                	jmp    8022ab <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022a6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022ab:	c9                   	leave  
  8022ac:	c3                   	ret    

008022ad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022ad:	55                   	push   %ebp
  8022ae:	89 e5                	mov    %esp,%ebp
  8022b0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bd:	89 04 24             	mov    %eax,(%esp)
  8022c0:	e8 d9 f2 ff ff       	call   80159e <fd_lookup>
  8022c5:	85 c0                	test   %eax,%eax
  8022c7:	78 11                	js     8022da <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022d2:	39 10                	cmp    %edx,(%eax)
  8022d4:	0f 94 c0             	sete   %al
  8022d7:	0f b6 c0             	movzbl %al,%eax
}
  8022da:	c9                   	leave  
  8022db:	c3                   	ret    

008022dc <opencons>:

int
opencons(void)
{
  8022dc:	55                   	push   %ebp
  8022dd:	89 e5                	mov    %esp,%ebp
  8022df:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e5:	89 04 24             	mov    %eax,(%esp)
  8022e8:	e8 5e f2 ff ff       	call   80154b <fd_alloc>
  8022ed:	85 c0                	test   %eax,%eax
  8022ef:	78 3c                	js     80232d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022f1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022f8:	00 
  8022f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802300:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802307:	e8 49 e9 ff ff       	call   800c55 <sys_page_alloc>
  80230c:	85 c0                	test   %eax,%eax
  80230e:	78 1d                	js     80232d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802310:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802316:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802319:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802325:	89 04 24             	mov    %eax,(%esp)
  802328:	e8 f3 f1 ff ff       	call   801520 <fd2num>
}
  80232d:	c9                   	leave  
  80232e:	c3                   	ret    
	...

00802330 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	53                   	push   %ebx
  802334:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  802337:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80233e:	75 6f                	jne    8023af <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  802340:	e8 d2 e8 ff ff       	call   800c17 <sys_getenvid>
  802345:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  802347:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80234e:	00 
  80234f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802356:	ee 
  802357:	89 04 24             	mov    %eax,(%esp)
  80235a:	e8 f6 e8 ff ff       	call   800c55 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  80235f:	85 c0                	test   %eax,%eax
  802361:	79 1c                	jns    80237f <set_pgfault_handler+0x4f>
  802363:	c7 44 24 08 5c 2b 80 	movl   $0x802b5c,0x8(%esp)
  80236a:	00 
  80236b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802372:	00 
  802373:	c7 04 24 b8 2b 80 00 	movl   $0x802bb8,(%esp)
  80237a:	e8 41 de ff ff       	call   8001c0 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  80237f:	c7 44 24 04 c0 23 80 	movl   $0x8023c0,0x4(%esp)
  802386:	00 
  802387:	89 1c 24             	mov    %ebx,(%esp)
  80238a:	e8 66 ea ff ff       	call   800df5 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  80238f:	85 c0                	test   %eax,%eax
  802391:	79 1c                	jns    8023af <set_pgfault_handler+0x7f>
  802393:	c7 44 24 08 84 2b 80 	movl   $0x802b84,0x8(%esp)
  80239a:	00 
  80239b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8023a2:	00 
  8023a3:	c7 04 24 b8 2b 80 00 	movl   $0x802bb8,(%esp)
  8023aa:	e8 11 de ff ff       	call   8001c0 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023af:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b2:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8023b7:	83 c4 14             	add    $0x14,%esp
  8023ba:	5b                   	pop    %ebx
  8023bb:	5d                   	pop    %ebp
  8023bc:	c3                   	ret    
  8023bd:	00 00                	add    %al,(%eax)
	...

008023c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023c1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8023c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023c8:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8023cb:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8023cf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8023d4:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  8023d8:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  8023da:	83 c4 08             	add    $0x8,%esp
	popal
  8023dd:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  8023de:	83 c4 04             	add    $0x4,%esp
	popfl
  8023e1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  8023e2:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8023e5:	c3                   	ret    
	...

008023e8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
  8023eb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  8023ee:	89 c2                	mov    %eax,%edx
  8023f0:	c1 ea 16             	shr    $0x16,%edx
  8023f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023fa:	f6 c2 01             	test   $0x1,%dl
  8023fd:	74 1e                	je     80241d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023ff:	c1 e8 0c             	shr    $0xc,%eax
  802402:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802409:	a8 01                	test   $0x1,%al
  80240b:	74 17                	je     802424 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80240d:	c1 e8 0c             	shr    $0xc,%eax
  802410:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802417:	ef 
  802418:	0f b7 c0             	movzwl %ax,%eax
  80241b:	eb 0c                	jmp    802429 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80241d:	b8 00 00 00 00       	mov    $0x0,%eax
  802422:	eb 05                	jmp    802429 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802424:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802429:	5d                   	pop    %ebp
  80242a:	c3                   	ret    
	...

0080242c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80242c:	55                   	push   %ebp
  80242d:	57                   	push   %edi
  80242e:	56                   	push   %esi
  80242f:	83 ec 10             	sub    $0x10,%esp
  802432:	8b 74 24 20          	mov    0x20(%esp),%esi
  802436:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80243a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80243e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802442:	89 cd                	mov    %ecx,%ebp
  802444:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802448:	85 c0                	test   %eax,%eax
  80244a:	75 2c                	jne    802478 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80244c:	39 f9                	cmp    %edi,%ecx
  80244e:	77 68                	ja     8024b8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802450:	85 c9                	test   %ecx,%ecx
  802452:	75 0b                	jne    80245f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802454:	b8 01 00 00 00       	mov    $0x1,%eax
  802459:	31 d2                	xor    %edx,%edx
  80245b:	f7 f1                	div    %ecx
  80245d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80245f:	31 d2                	xor    %edx,%edx
  802461:	89 f8                	mov    %edi,%eax
  802463:	f7 f1                	div    %ecx
  802465:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802467:	89 f0                	mov    %esi,%eax
  802469:	f7 f1                	div    %ecx
  80246b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80246d:	89 f0                	mov    %esi,%eax
  80246f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802471:	83 c4 10             	add    $0x10,%esp
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802478:	39 f8                	cmp    %edi,%eax
  80247a:	77 2c                	ja     8024a8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80247c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80247f:	83 f6 1f             	xor    $0x1f,%esi
  802482:	75 4c                	jne    8024d0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802484:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802486:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80248b:	72 0a                	jb     802497 <__udivdi3+0x6b>
  80248d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802491:	0f 87 ad 00 00 00    	ja     802544 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802497:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80249c:	89 f0                	mov    %esi,%eax
  80249e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024a0:	83 c4 10             	add    $0x10,%esp
  8024a3:	5e                   	pop    %esi
  8024a4:	5f                   	pop    %edi
  8024a5:	5d                   	pop    %ebp
  8024a6:	c3                   	ret    
  8024a7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024a8:	31 ff                	xor    %edi,%edi
  8024aa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024ac:	89 f0                	mov    %esi,%eax
  8024ae:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024b0:	83 c4 10             	add    $0x10,%esp
  8024b3:	5e                   	pop    %esi
  8024b4:	5f                   	pop    %edi
  8024b5:	5d                   	pop    %ebp
  8024b6:	c3                   	ret    
  8024b7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024b8:	89 fa                	mov    %edi,%edx
  8024ba:	89 f0                	mov    %esi,%eax
  8024bc:	f7 f1                	div    %ecx
  8024be:	89 c6                	mov    %eax,%esi
  8024c0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024c2:	89 f0                	mov    %esi,%eax
  8024c4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024c6:	83 c4 10             	add    $0x10,%esp
  8024c9:	5e                   	pop    %esi
  8024ca:	5f                   	pop    %edi
  8024cb:	5d                   	pop    %ebp
  8024cc:	c3                   	ret    
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024d0:	89 f1                	mov    %esi,%ecx
  8024d2:	d3 e0                	shl    %cl,%eax
  8024d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024d8:	b8 20 00 00 00       	mov    $0x20,%eax
  8024dd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8024df:	89 ea                	mov    %ebp,%edx
  8024e1:	88 c1                	mov    %al,%cl
  8024e3:	d3 ea                	shr    %cl,%edx
  8024e5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8024e9:	09 ca                	or     %ecx,%edx
  8024eb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8024ef:	89 f1                	mov    %esi,%ecx
  8024f1:	d3 e5                	shl    %cl,%ebp
  8024f3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8024f7:	89 fd                	mov    %edi,%ebp
  8024f9:	88 c1                	mov    %al,%cl
  8024fb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8024fd:	89 fa                	mov    %edi,%edx
  8024ff:	89 f1                	mov    %esi,%ecx
  802501:	d3 e2                	shl    %cl,%edx
  802503:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802507:	88 c1                	mov    %al,%cl
  802509:	d3 ef                	shr    %cl,%edi
  80250b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80250d:	89 f8                	mov    %edi,%eax
  80250f:	89 ea                	mov    %ebp,%edx
  802511:	f7 74 24 08          	divl   0x8(%esp)
  802515:	89 d1                	mov    %edx,%ecx
  802517:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802519:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80251d:	39 d1                	cmp    %edx,%ecx
  80251f:	72 17                	jb     802538 <__udivdi3+0x10c>
  802521:	74 09                	je     80252c <__udivdi3+0x100>
  802523:	89 fe                	mov    %edi,%esi
  802525:	31 ff                	xor    %edi,%edi
  802527:	e9 41 ff ff ff       	jmp    80246d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80252c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802530:	89 f1                	mov    %esi,%ecx
  802532:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802534:	39 c2                	cmp    %eax,%edx
  802536:	73 eb                	jae    802523 <__udivdi3+0xf7>
		{
		  q0--;
  802538:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80253b:	31 ff                	xor    %edi,%edi
  80253d:	e9 2b ff ff ff       	jmp    80246d <__udivdi3+0x41>
  802542:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802544:	31 f6                	xor    %esi,%esi
  802546:	e9 22 ff ff ff       	jmp    80246d <__udivdi3+0x41>
	...

0080254c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80254c:	55                   	push   %ebp
  80254d:	57                   	push   %edi
  80254e:	56                   	push   %esi
  80254f:	83 ec 20             	sub    $0x20,%esp
  802552:	8b 44 24 30          	mov    0x30(%esp),%eax
  802556:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80255a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80255e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802562:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802566:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80256a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80256c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80256e:	85 ed                	test   %ebp,%ebp
  802570:	75 16                	jne    802588 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802572:	39 f1                	cmp    %esi,%ecx
  802574:	0f 86 a6 00 00 00    	jbe    802620 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80257a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80257c:	89 d0                	mov    %edx,%eax
  80257e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802580:	83 c4 20             	add    $0x20,%esp
  802583:	5e                   	pop    %esi
  802584:	5f                   	pop    %edi
  802585:	5d                   	pop    %ebp
  802586:	c3                   	ret    
  802587:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802588:	39 f5                	cmp    %esi,%ebp
  80258a:	0f 87 ac 00 00 00    	ja     80263c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802590:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802593:	83 f0 1f             	xor    $0x1f,%eax
  802596:	89 44 24 10          	mov    %eax,0x10(%esp)
  80259a:	0f 84 a8 00 00 00    	je     802648 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025a0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025a4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025a6:	bf 20 00 00 00       	mov    $0x20,%edi
  8025ab:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8025af:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025b3:	89 f9                	mov    %edi,%ecx
  8025b5:	d3 e8                	shr    %cl,%eax
  8025b7:	09 e8                	or     %ebp,%eax
  8025b9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8025bd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025c1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025c5:	d3 e0                	shl    %cl,%eax
  8025c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025cb:	89 f2                	mov    %esi,%edx
  8025cd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8025cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025d3:	d3 e0                	shl    %cl,%eax
  8025d5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025d9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025dd:	89 f9                	mov    %edi,%ecx
  8025df:	d3 e8                	shr    %cl,%eax
  8025e1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8025e3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025e5:	89 f2                	mov    %esi,%edx
  8025e7:	f7 74 24 18          	divl   0x18(%esp)
  8025eb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8025ed:	f7 64 24 0c          	mull   0xc(%esp)
  8025f1:	89 c5                	mov    %eax,%ebp
  8025f3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025f5:	39 d6                	cmp    %edx,%esi
  8025f7:	72 67                	jb     802660 <__umoddi3+0x114>
  8025f9:	74 75                	je     802670 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8025fb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025ff:	29 e8                	sub    %ebp,%eax
  802601:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802603:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802607:	d3 e8                	shr    %cl,%eax
  802609:	89 f2                	mov    %esi,%edx
  80260b:	89 f9                	mov    %edi,%ecx
  80260d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80260f:	09 d0                	or     %edx,%eax
  802611:	89 f2                	mov    %esi,%edx
  802613:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802617:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802619:	83 c4 20             	add    $0x20,%esp
  80261c:	5e                   	pop    %esi
  80261d:	5f                   	pop    %edi
  80261e:	5d                   	pop    %ebp
  80261f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802620:	85 c9                	test   %ecx,%ecx
  802622:	75 0b                	jne    80262f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802624:	b8 01 00 00 00       	mov    $0x1,%eax
  802629:	31 d2                	xor    %edx,%edx
  80262b:	f7 f1                	div    %ecx
  80262d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80262f:	89 f0                	mov    %esi,%eax
  802631:	31 d2                	xor    %edx,%edx
  802633:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802635:	89 f8                	mov    %edi,%eax
  802637:	e9 3e ff ff ff       	jmp    80257a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80263c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80263e:	83 c4 20             	add    $0x20,%esp
  802641:	5e                   	pop    %esi
  802642:	5f                   	pop    %edi
  802643:	5d                   	pop    %ebp
  802644:	c3                   	ret    
  802645:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802648:	39 f5                	cmp    %esi,%ebp
  80264a:	72 04                	jb     802650 <__umoddi3+0x104>
  80264c:	39 f9                	cmp    %edi,%ecx
  80264e:	77 06                	ja     802656 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802650:	89 f2                	mov    %esi,%edx
  802652:	29 cf                	sub    %ecx,%edi
  802654:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802656:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802658:	83 c4 20             	add    $0x20,%esp
  80265b:	5e                   	pop    %esi
  80265c:	5f                   	pop    %edi
  80265d:	5d                   	pop    %ebp
  80265e:	c3                   	ret    
  80265f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802660:	89 d1                	mov    %edx,%ecx
  802662:	89 c5                	mov    %eax,%ebp
  802664:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802668:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80266c:	eb 8d                	jmp    8025fb <__umoddi3+0xaf>
  80266e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802670:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802674:	72 ea                	jb     802660 <__umoddi3+0x114>
  802676:	89 f1                	mov    %esi,%ecx
  802678:	eb 81                	jmp    8025fb <__umoddi3+0xaf>
