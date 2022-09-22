
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 9a 0b 00 00       	call   800bdb <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 da 0f 00 00       	call   801027 <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 08                	je     800059 <umain+0x25>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  800051:	43                   	inc    %ebx
  800052:	83 fb 14             	cmp    $0x14,%ebx
  800055:	75 f1                	jne    800048 <umain+0x14>
  800057:	eb 05                	jmp    80005e <umain+0x2a>
		if (fork() == 0)
			break;
	if (i == 20) {
  800059:	83 fb 14             	cmp    $0x14,%ebx
  80005c:	75 0e                	jne    80006c <umain+0x38>
		sys_yield();
  80005e:	e8 97 0b 00 00       	call   800bfa <sys_yield>
		return;
  800063:	e9 99 00 00 00       	jmp    800101 <umain+0xcd>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800068:	f3 90                	pause  
  80006a:	eb 1a                	jmp    800086 <umain+0x52>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800079:	89 f2                	mov    %esi,%edx
  80007b:	c1 e2 07             	shl    $0x7,%edx
  80007e:	29 c2                	sub    %eax,%edx
  800080:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  800086:	8b 42 50             	mov    0x50(%edx),%eax
  800089:	85 c0                	test   %eax,%eax
  80008b:	75 db                	jne    800068 <umain+0x34>
  80008d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800092:	e8 63 0b 00 00       	call   800bfa <sys_yield>
  800097:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  80009c:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000a2:	42                   	inc    %edx
  8000a3:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000a9:	48                   	dec    %eax
  8000aa:	75 f0                	jne    80009c <umain+0x68>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000ac:	4b                   	dec    %ebx
  8000ad:	75 e3                	jne    800092 <umain+0x5e>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000af:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b9:	74 25                	je     8000e0 <umain+0xac>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000bb:	a1 04 20 80 00       	mov    0x802004,%eax
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 40 16 80 	movl   $0x801640,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  8000db:	e8 a4 00 00 00       	call   800184 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e0:	a1 08 20 80 00       	mov    0x802008,%eax
  8000e5:	8b 00                	mov    (%eax),%eax
  8000e7:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000ea:	8b 40 48             	mov    0x48(%eax),%eax
  8000ed:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f5:	c7 04 24 7b 16 80 00 	movl   $0x80167b,(%esp)
  8000fc:	e8 7b 01 00 00       	call   80027c <cprintf>

}
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
  80010d:	83 ec 20             	sub    $0x20,%esp
  800110:	8b 75 08             	mov    0x8(%ebp),%esi
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800116:	e8 c0 0a 00 00       	call   800bdb <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800127:	c1 e0 07             	shl    $0x7,%eax
  80012a:	29 d0                	sub    %edx,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800134:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800137:	a3 08 20 80 00       	mov    %eax,0x802008
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("%x\n",pthisenv);
  800140:	c7 04 24 63 19 80 00 	movl   $0x801963,(%esp)
  800147:	e8 30 01 00 00       	call   80027c <cprintf>
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014c:	85 f6                	test   %esi,%esi
  80014e:	7e 07                	jle    800157 <libmain+0x4f>
		binaryname = argv[0];
  800150:	8b 03                	mov    (%ebx),%eax
  800152:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800157:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80015b:	89 34 24             	mov    %esi,(%esp)
  80015e:	e8 d1 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800163:	e8 08 00 00 00       	call   800170 <exit>
}
  800168:	83 c4 20             	add    $0x20,%esp
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    
	...

00800170 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017d:	e8 07 0a 00 00       	call   800b89 <sys_env_destroy>
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80018c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800195:	e8 41 0a 00 00       	call   800bdb <sys_getenvid>
  80019a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  8001b7:	e8 c0 00 00 00       	call   80027c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	e8 50 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001cb:	c7 04 24 75 19 80 00 	movl   $0x801975,(%esp)
  8001d2:	e8 a5 00 00 00       	call   80027c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x53>
	...

008001dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 14             	sub    $0x14,%esp
  8001e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e6:	8b 03                	mov    (%ebx),%eax
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ef:	40                   	inc    %eax
  8001f0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 19                	jne    800212 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001f9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800200:	00 
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	89 04 24             	mov    %eax,(%esp)
  800207:	e8 40 09 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  80020c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800212:	ff 43 04             	incl   0x4(%ebx)
}
  800215:	83 c4 14             	add    $0x14,%esp
  800218:	5b                   	pop    %ebx
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	89 44 24 08          	mov    %eax,0x8(%esp)
  800246:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	c7 04 24 dc 01 80 00 	movl   $0x8001dc,(%esp)
  800257:	e8 82 01 00 00       	call   8003de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800262:	89 44 24 04          	mov    %eax,0x4(%esp)
  800266:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 d8 08 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  800274:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800282:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800285:	89 44 24 04          	mov    %eax,0x4(%esp)
  800289:	8b 45 08             	mov    0x8(%ebp),%eax
  80028c:	89 04 24             	mov    %eax,(%esp)
  80028f:	e8 87 ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    
	...

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 3c             	sub    $0x3c,%esp
  8002a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a4:	89 d7                	mov    %edx,%edi
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b8:	85 c0                	test   %eax,%eax
  8002ba:	75 08                	jne    8002c4 <printnum+0x2c>
  8002bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002c2:	77 57                	ja     80031b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002c8:	4b                   	dec    %ebx
  8002c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002d8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002dc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e3:	00 
  8002e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	e8 fa 10 00 00       	call   8013f0 <__udivdi3>
  8002f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002fe:	89 04 24             	mov    %eax,(%esp)
  800301:	89 54 24 04          	mov    %edx,0x4(%esp)
  800305:	89 fa                	mov    %edi,%edx
  800307:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030a:	e8 89 ff ff ff       	call   800298 <printnum>
  80030f:	eb 0f                	jmp    800320 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	89 34 24             	mov    %esi,(%esp)
  800318:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031b:	4b                   	dec    %ebx
  80031c:	85 db                	test   %ebx,%ebx
  80031e:	7f f1                	jg     800311 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800320:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800324:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800328:	8b 45 10             	mov    0x10(%ebp),%eax
  80032b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800336:	00 
  800337:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800340:	89 44 24 04          	mov    %eax,0x4(%esp)
  800344:	e8 c7 11 00 00       	call   801510 <__umoddi3>
  800349:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034d:	0f be 80 c7 16 80 00 	movsbl 0x8016c7(%eax),%eax
  800354:	89 04 24             	mov    %eax,(%esp)
  800357:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80035a:	83 c4 3c             	add    $0x3c,%esp
  80035d:	5b                   	pop    %ebx
  80035e:	5e                   	pop    %esi
  80035f:	5f                   	pop    %edi
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    

00800362 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800365:	83 fa 01             	cmp    $0x1,%edx
  800368:	7e 0e                	jle    800378 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80036a:	8b 10                	mov    (%eax),%edx
  80036c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80036f:	89 08                	mov    %ecx,(%eax)
  800371:	8b 02                	mov    (%edx),%eax
  800373:	8b 52 04             	mov    0x4(%edx),%edx
  800376:	eb 22                	jmp    80039a <getuint+0x38>
	else if (lflag)
  800378:	85 d2                	test   %edx,%edx
  80037a:	74 10                	je     80038c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	eb 0e                	jmp    80039a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800391:	89 08                	mov    %ecx,(%eax)
  800393:	8b 02                	mov    (%edx),%eax
  800395:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003a5:	8b 10                	mov    (%eax),%edx
  8003a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003aa:	73 08                	jae    8003b4 <sprintputch+0x18>
		*b->buf++ = ch;
  8003ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003af:	88 0a                	mov    %cl,(%edx)
  8003b1:	42                   	inc    %edx
  8003b2:	89 10                	mov    %edx,(%eax)
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	e8 02 00 00 00       	call   8003de <vprintfmt>
	va_end(ap);
}
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	57                   	push   %edi
  8003e2:	56                   	push   %esi
  8003e3:	53                   	push   %ebx
  8003e4:	83 ec 4c             	sub    $0x4c,%esp
  8003e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ea:	8b 75 10             	mov    0x10(%ebp),%esi
  8003ed:	eb 12                	jmp    800401 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	0f 84 6b 03 00 00    	je     800762 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800401:	0f b6 06             	movzbl (%esi),%eax
  800404:	46                   	inc    %esi
  800405:	83 f8 25             	cmp    $0x25,%eax
  800408:	75 e5                	jne    8003ef <vprintfmt+0x11>
  80040a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80040e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800415:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80041a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800421:	b9 00 00 00 00       	mov    $0x0,%ecx
  800426:	eb 26                	jmp    80044e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80042b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80042f:	eb 1d                	jmp    80044e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800434:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800438:	eb 14                	jmp    80044e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80043d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800444:	eb 08                	jmp    80044e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800446:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800449:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	0f b6 06             	movzbl (%esi),%eax
  800451:	8d 56 01             	lea    0x1(%esi),%edx
  800454:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800457:	8a 16                	mov    (%esi),%dl
  800459:	83 ea 23             	sub    $0x23,%edx
  80045c:	80 fa 55             	cmp    $0x55,%dl
  80045f:	0f 87 e1 02 00 00    	ja     800746 <vprintfmt+0x368>
  800465:	0f b6 d2             	movzbl %dl,%edx
  800468:	ff 24 95 80 17 80 00 	jmp    *0x801780(,%edx,4)
  80046f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800472:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800477:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80047a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80047e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800481:	8d 50 d0             	lea    -0x30(%eax),%edx
  800484:	83 fa 09             	cmp    $0x9,%edx
  800487:	77 2a                	ja     8004b3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800489:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048a:	eb eb                	jmp    800477 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049a:	eb 17                	jmp    8004b3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80049c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a0:	78 98                	js     80043a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004a5:	eb a7                	jmp    80044e <vprintfmt+0x70>
  8004a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004aa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004b1:	eb 9b                	jmp    80044e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b7:	79 95                	jns    80044e <vprintfmt+0x70>
  8004b9:	eb 8b                	jmp    800446 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004bf:	eb 8d                	jmp    80044e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d9:	e9 23 ff ff ff       	jmp    800401 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8d 50 04             	lea    0x4(%eax),%edx
  8004e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e7:	8b 00                	mov    (%eax),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	79 02                	jns    8004ef <vprintfmt+0x111>
  8004ed:	f7 d8                	neg    %eax
  8004ef:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f1:	83 f8 08             	cmp    $0x8,%eax
  8004f4:	7f 0b                	jg     800501 <vprintfmt+0x123>
  8004f6:	8b 04 85 e0 18 80 00 	mov    0x8018e0(,%eax,4),%eax
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	75 23                	jne    800524 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800501:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800505:	c7 44 24 08 df 16 80 	movl   $0x8016df,0x8(%esp)
  80050c:	00 
  80050d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800511:	8b 45 08             	mov    0x8(%ebp),%eax
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	e8 9a fe ff ff       	call   8003b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051f:	e9 dd fe ff ff       	jmp    800401 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800524:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800528:	c7 44 24 08 e8 16 80 	movl   $0x8016e8,0x8(%esp)
  80052f:	00 
  800530:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800534:	8b 55 08             	mov    0x8(%ebp),%edx
  800537:	89 14 24             	mov    %edx,(%esp)
  80053a:	e8 77 fe ff ff       	call   8003b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800542:	e9 ba fe ff ff       	jmp    800401 <vprintfmt+0x23>
  800547:	89 f9                	mov    %edi,%ecx
  800549:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 30                	mov    (%eax),%esi
  80055a:	85 f6                	test   %esi,%esi
  80055c:	75 05                	jne    800563 <vprintfmt+0x185>
				p = "(null)";
  80055e:	be d8 16 80 00       	mov    $0x8016d8,%esi
			if (width > 0 && padc != '-')
  800563:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800567:	0f 8e 84 00 00 00    	jle    8005f1 <vprintfmt+0x213>
  80056d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800571:	74 7e                	je     8005f1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800577:	89 34 24             	mov    %esi,(%esp)
  80057a:	e8 8b 02 00 00       	call   80080a <strnlen>
  80057f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800582:	29 c2                	sub    %eax,%edx
  800584:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800587:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80058b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80058e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800591:	89 de                	mov    %ebx,%esi
  800593:	89 d3                	mov    %edx,%ebx
  800595:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	eb 0b                	jmp    8005a4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800599:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059d:	89 3c 24             	mov    %edi,(%esp)
  8005a0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a3:	4b                   	dec    %ebx
  8005a4:	85 db                	test   %ebx,%ebx
  8005a6:	7f f1                	jg     800599 <vprintfmt+0x1bb>
  8005a8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005ab:	89 f3                	mov    %esi,%ebx
  8005ad:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	79 05                	jns    8005bc <vprintfmt+0x1de>
  8005b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005bf:	29 c2                	sub    %eax,%edx
  8005c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005c4:	eb 2b                	jmp    8005f1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ca:	74 18                	je     8005e4 <vprintfmt+0x206>
  8005cc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005cf:	83 fa 5e             	cmp    $0x5e,%edx
  8005d2:	76 10                	jbe    8005e4 <vprintfmt+0x206>
					putch('?', putdat);
  8005d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
  8005e2:	eb 0a                	jmp    8005ee <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ee:	ff 4d e4             	decl   -0x1c(%ebp)
  8005f1:	0f be 06             	movsbl (%esi),%eax
  8005f4:	46                   	inc    %esi
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	74 21                	je     80061a <vprintfmt+0x23c>
  8005f9:	85 ff                	test   %edi,%edi
  8005fb:	78 c9                	js     8005c6 <vprintfmt+0x1e8>
  8005fd:	4f                   	dec    %edi
  8005fe:	79 c6                	jns    8005c6 <vprintfmt+0x1e8>
  800600:	8b 7d 08             	mov    0x8(%ebp),%edi
  800603:	89 de                	mov    %ebx,%esi
  800605:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800608:	eb 18                	jmp    800622 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80060e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800615:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800617:	4b                   	dec    %ebx
  800618:	eb 08                	jmp    800622 <vprintfmt+0x244>
  80061a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80061d:	89 de                	mov    %ebx,%esi
  80061f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800622:	85 db                	test   %ebx,%ebx
  800624:	7f e4                	jg     80060a <vprintfmt+0x22c>
  800626:	89 7d 08             	mov    %edi,0x8(%ebp)
  800629:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80062e:	e9 ce fd ff ff       	jmp    800401 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800633:	83 f9 01             	cmp    $0x1,%ecx
  800636:	7e 10                	jle    800648 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 08             	lea    0x8(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 30                	mov    (%eax),%esi
  800643:	8b 78 04             	mov    0x4(%eax),%edi
  800646:	eb 26                	jmp    80066e <vprintfmt+0x290>
	else if (lflag)
  800648:	85 c9                	test   %ecx,%ecx
  80064a:	74 12                	je     80065e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 30                	mov    (%eax),%esi
  800657:	89 f7                	mov    %esi,%edi
  800659:	c1 ff 1f             	sar    $0x1f,%edi
  80065c:	eb 10                	jmp    80066e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 30                	mov    (%eax),%esi
  800669:	89 f7                	mov    %esi,%edi
  80066b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80066e:	85 ff                	test   %edi,%edi
  800670:	78 0a                	js     80067c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800672:	b8 0a 00 00 00       	mov    $0xa,%eax
  800677:	e9 8c 00 00 00       	jmp    800708 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80067c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800680:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80068a:	f7 de                	neg    %esi
  80068c:	83 d7 00             	adc    $0x0,%edi
  80068f:	f7 df                	neg    %edi
			}
			base = 10;
  800691:	b8 0a 00 00 00       	mov    $0xa,%eax
  800696:	eb 70                	jmp    800708 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800698:	89 ca                	mov    %ecx,%edx
  80069a:	8d 45 14             	lea    0x14(%ebp),%eax
  80069d:	e8 c0 fc ff ff       	call   800362 <getuint>
  8006a2:	89 c6                	mov    %eax,%esi
  8006a4:	89 d7                	mov    %edx,%edi
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006ab:	eb 5b                	jmp    800708 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006ad:	89 ca                	mov    %ecx,%edx
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b2:	e8 ab fc ff ff       	call   800362 <getuint>
  8006b7:	89 c6                	mov    %eax,%esi
  8006b9:	89 d7                	mov    %edx,%edi
			base = 8;
  8006bb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006c0:	eb 46                	jmp    800708 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e7:	8b 30                	mov    (%eax),%esi
  8006e9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f3:	eb 13                	jmp    800708 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f5:	89 ca                	mov    %ecx,%edx
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	e8 63 fc ff ff       	call   800362 <getuint>
  8006ff:	89 c6                	mov    %eax,%esi
  800701:	89 d7                	mov    %edx,%edi
			base = 16;
  800703:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800708:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80070c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800710:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800713:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800717:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071b:	89 34 24             	mov    %esi,(%esp)
  80071e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800722:	89 da                	mov    %ebx,%edx
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	e8 6c fb ff ff       	call   800298 <printnum>
			break;
  80072c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80072f:	e9 cd fc ff ff       	jmp    800401 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800734:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800738:	89 04 24             	mov    %eax,(%esp)
  80073b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800741:	e9 bb fc ff ff       	jmp    800401 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800746:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800751:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800754:	eb 01                	jmp    800757 <vprintfmt+0x379>
  800756:	4e                   	dec    %esi
  800757:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80075b:	75 f9                	jne    800756 <vprintfmt+0x378>
  80075d:	e9 9f fc ff ff       	jmp    800401 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800762:	83 c4 4c             	add    $0x4c,%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 28             	sub    $0x28,%esp
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800776:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800779:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800787:	85 c0                	test   %eax,%eax
  800789:	74 30                	je     8007bb <vsnprintf+0x51>
  80078b:	85 d2                	test   %edx,%edx
  80078d:	7e 33                	jle    8007c2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800796:	8b 45 10             	mov    0x10(%ebp),%eax
  800799:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a4:	c7 04 24 9c 03 80 00 	movl   $0x80039c,(%esp)
  8007ab:	e8 2e fc ff ff       	call   8003de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b9:	eb 0c                	jmp    8007c7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c0:	eb 05                	jmp    8007c7 <vsnprintf+0x5d>
  8007c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	89 04 24             	mov    %eax,(%esp)
  8007ea:	e8 7b ff ff ff       	call   80076a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    
  8007f1:	00 00                	add    %al,(%eax)
	...

008007f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ff:	eb 01                	jmp    800802 <strlen+0xe>
		n++;
  800801:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800802:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800806:	75 f9                	jne    800801 <strlen+0xd>
		n++;
	return n;
}
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800813:	b8 00 00 00 00       	mov    $0x0,%eax
  800818:	eb 01                	jmp    80081b <strnlen+0x11>
		n++;
  80081a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081b:	39 d0                	cmp    %edx,%eax
  80081d:	74 06                	je     800825 <strnlen+0x1b>
  80081f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800823:	75 f5                	jne    80081a <strnlen+0x10>
		n++;
	return n;
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800831:	ba 00 00 00 00       	mov    $0x0,%edx
  800836:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800839:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80083c:	42                   	inc    %edx
  80083d:	84 c9                	test   %cl,%cl
  80083f:	75 f5                	jne    800836 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800841:	5b                   	pop    %ebx
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084e:	89 1c 24             	mov    %ebx,(%esp)
  800851:	e8 9e ff ff ff       	call   8007f4 <strlen>
	strcpy(dst + len, src);
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
  800859:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085d:	01 d8                	add    %ebx,%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	e8 c0 ff ff ff       	call   800827 <strcpy>
	return dst;
}
  800867:	89 d8                	mov    %ebx,%eax
  800869:	83 c4 08             	add    $0x8,%esp
  80086c:	5b                   	pop    %ebx
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	56                   	push   %esi
  800873:	53                   	push   %ebx
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800882:	eb 0c                	jmp    800890 <strncpy+0x21>
		*dst++ = *src;
  800884:	8a 1a                	mov    (%edx),%bl
  800886:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800889:	80 3a 01             	cmpb   $0x1,(%edx)
  80088c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088f:	41                   	inc    %ecx
  800890:	39 f1                	cmp    %esi,%ecx
  800892:	75 f0                	jne    800884 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	56                   	push   %esi
  80089c:	53                   	push   %ebx
  80089d:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a6:	85 d2                	test   %edx,%edx
  8008a8:	75 0a                	jne    8008b4 <strlcpy+0x1c>
  8008aa:	89 f0                	mov    %esi,%eax
  8008ac:	eb 1a                	jmp    8008c8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ae:	88 18                	mov    %bl,(%eax)
  8008b0:	40                   	inc    %eax
  8008b1:	41                   	inc    %ecx
  8008b2:	eb 02                	jmp    8008b6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008b6:	4a                   	dec    %edx
  8008b7:	74 0a                	je     8008c3 <strlcpy+0x2b>
  8008b9:	8a 19                	mov    (%ecx),%bl
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	75 ef                	jne    8008ae <strlcpy+0x16>
  8008bf:	89 c2                	mov    %eax,%edx
  8008c1:	eb 02                	jmp    8008c5 <strlcpy+0x2d>
  8008c3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008c5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008c8:	29 f0                	sub    %esi,%eax
}
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d7:	eb 02                	jmp    8008db <strcmp+0xd>
		p++, q++;
  8008d9:	41                   	inc    %ecx
  8008da:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008db:	8a 01                	mov    (%ecx),%al
  8008dd:	84 c0                	test   %al,%al
  8008df:	74 04                	je     8008e5 <strcmp+0x17>
  8008e1:	3a 02                	cmp    (%edx),%al
  8008e3:	74 f4                	je     8008d9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e5:	0f b6 c0             	movzbl %al,%eax
  8008e8:	0f b6 12             	movzbl (%edx),%edx
  8008eb:	29 d0                	sub    %edx,%eax
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	53                   	push   %ebx
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008fc:	eb 03                	jmp    800901 <strncmp+0x12>
		n--, p++, q++;
  8008fe:	4a                   	dec    %edx
  8008ff:	40                   	inc    %eax
  800900:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800901:	85 d2                	test   %edx,%edx
  800903:	74 14                	je     800919 <strncmp+0x2a>
  800905:	8a 18                	mov    (%eax),%bl
  800907:	84 db                	test   %bl,%bl
  800909:	74 04                	je     80090f <strncmp+0x20>
  80090b:	3a 19                	cmp    (%ecx),%bl
  80090d:	74 ef                	je     8008fe <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090f:	0f b6 00             	movzbl (%eax),%eax
  800912:	0f b6 11             	movzbl (%ecx),%edx
  800915:	29 d0                	sub    %edx,%eax
  800917:	eb 05                	jmp    80091e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091e:	5b                   	pop    %ebx
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092a:	eb 05                	jmp    800931 <strchr+0x10>
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 0c                	je     80093c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800930:	40                   	inc    %eax
  800931:	8a 10                	mov    (%eax),%dl
  800933:	84 d2                	test   %dl,%dl
  800935:	75 f5                	jne    80092c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800947:	eb 05                	jmp    80094e <strfind+0x10>
		if (*s == c)
  800949:	38 ca                	cmp    %cl,%dl
  80094b:	74 07                	je     800954 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80094d:	40                   	inc    %eax
  80094e:	8a 10                	mov    (%eax),%dl
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f5                	jne    800949 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 30                	je     800999 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800969:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096f:	75 25                	jne    800996 <memset+0x40>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 20                	jne    800996 <memset+0x40>
		c &= 0xFF;
  800976:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800979:	89 d3                	mov    %edx,%ebx
  80097b:	c1 e3 08             	shl    $0x8,%ebx
  80097e:	89 d6                	mov    %edx,%esi
  800980:	c1 e6 18             	shl    $0x18,%esi
  800983:	89 d0                	mov    %edx,%eax
  800985:	c1 e0 10             	shl    $0x10,%eax
  800988:	09 f0                	or     %esi,%eax
  80098a:	09 d0                	or     %edx,%eax
  80098c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800991:	fc                   	cld    
  800992:	f3 ab                	rep stos %eax,%es:(%edi)
  800994:	eb 03                	jmp    800999 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800996:	fc                   	cld    
  800997:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800999:	89 f8                	mov    %edi,%eax
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5f                   	pop    %edi
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ae:	39 c6                	cmp    %eax,%esi
  8009b0:	73 34                	jae    8009e6 <memmove+0x46>
  8009b2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b5:	39 d0                	cmp    %edx,%eax
  8009b7:	73 2d                	jae    8009e6 <memmove+0x46>
		s += n;
		d += n;
  8009b9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bc:	f6 c2 03             	test   $0x3,%dl
  8009bf:	75 1b                	jne    8009dc <memmove+0x3c>
  8009c1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c7:	75 13                	jne    8009dc <memmove+0x3c>
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 0e                	jne    8009dc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ce:	83 ef 04             	sub    $0x4,%edi
  8009d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009d7:	fd                   	std    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 07                	jmp    8009e3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009dc:	4f                   	dec    %edi
  8009dd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e0:	fd                   	std    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e3:	fc                   	cld    
  8009e4:	eb 20                	jmp    800a06 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ec:	75 13                	jne    800a01 <memmove+0x61>
  8009ee:	a8 03                	test   $0x3,%al
  8009f0:	75 0f                	jne    800a01 <memmove+0x61>
  8009f2:	f6 c1 03             	test   $0x3,%cl
  8009f5:	75 0a                	jne    800a01 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009fa:	89 c7                	mov    %eax,%edi
  8009fc:	fc                   	cld    
  8009fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ff:	eb 05                	jmp    800a06 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a01:	89 c7                	mov    %eax,%edi
  800a03:	fc                   	cld    
  800a04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a06:	5e                   	pop    %esi
  800a07:	5f                   	pop    %edi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a10:	8b 45 10             	mov    0x10(%ebp),%eax
  800a13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	89 04 24             	mov    %eax,(%esp)
  800a24:	e8 77 ff ff ff       	call   8009a0 <memmove>
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3f:	eb 16                	jmp    800a57 <memcmp+0x2c>
		if (*s1 != *s2)
  800a41:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a44:	42                   	inc    %edx
  800a45:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a49:	38 c8                	cmp    %cl,%al
  800a4b:	74 0a                	je     800a57 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a4d:	0f b6 c0             	movzbl %al,%eax
  800a50:	0f b6 c9             	movzbl %cl,%ecx
  800a53:	29 c8                	sub    %ecx,%eax
  800a55:	eb 09                	jmp    800a60 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a57:	39 da                	cmp    %ebx,%edx
  800a59:	75 e6                	jne    800a41 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a6e:	89 c2                	mov    %eax,%edx
  800a70:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a73:	eb 05                	jmp    800a7a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a75:	38 08                	cmp    %cl,(%eax)
  800a77:	74 05                	je     800a7e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a79:	40                   	inc    %eax
  800a7a:	39 d0                	cmp    %edx,%eax
  800a7c:	72 f7                	jb     800a75 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 55 08             	mov    0x8(%ebp),%edx
  800a89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8c:	eb 01                	jmp    800a8f <strtol+0xf>
		s++;
  800a8e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8f:	8a 02                	mov    (%edx),%al
  800a91:	3c 20                	cmp    $0x20,%al
  800a93:	74 f9                	je     800a8e <strtol+0xe>
  800a95:	3c 09                	cmp    $0x9,%al
  800a97:	74 f5                	je     800a8e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a99:	3c 2b                	cmp    $0x2b,%al
  800a9b:	75 08                	jne    800aa5 <strtol+0x25>
		s++;
  800a9d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa3:	eb 13                	jmp    800ab8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa5:	3c 2d                	cmp    $0x2d,%al
  800aa7:	75 0a                	jne    800ab3 <strtol+0x33>
		s++, neg = 1;
  800aa9:	8d 52 01             	lea    0x1(%edx),%edx
  800aac:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab1:	eb 05                	jmp    800ab8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab8:	85 db                	test   %ebx,%ebx
  800aba:	74 05                	je     800ac1 <strtol+0x41>
  800abc:	83 fb 10             	cmp    $0x10,%ebx
  800abf:	75 28                	jne    800ae9 <strtol+0x69>
  800ac1:	8a 02                	mov    (%edx),%al
  800ac3:	3c 30                	cmp    $0x30,%al
  800ac5:	75 10                	jne    800ad7 <strtol+0x57>
  800ac7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800acb:	75 0a                	jne    800ad7 <strtol+0x57>
		s += 2, base = 16;
  800acd:	83 c2 02             	add    $0x2,%edx
  800ad0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad5:	eb 12                	jmp    800ae9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	75 0e                	jne    800ae9 <strtol+0x69>
  800adb:	3c 30                	cmp    $0x30,%al
  800add:	75 05                	jne    800ae4 <strtol+0x64>
		s++, base = 8;
  800adf:	42                   	inc    %edx
  800ae0:	b3 08                	mov    $0x8,%bl
  800ae2:	eb 05                	jmp    800ae9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ae4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aee:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af0:	8a 0a                	mov    (%edx),%cl
  800af2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800af5:	80 fb 09             	cmp    $0x9,%bl
  800af8:	77 08                	ja     800b02 <strtol+0x82>
			dig = *s - '0';
  800afa:	0f be c9             	movsbl %cl,%ecx
  800afd:	83 e9 30             	sub    $0x30,%ecx
  800b00:	eb 1e                	jmp    800b20 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b02:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b05:	80 fb 19             	cmp    $0x19,%bl
  800b08:	77 08                	ja     800b12 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b0a:	0f be c9             	movsbl %cl,%ecx
  800b0d:	83 e9 57             	sub    $0x57,%ecx
  800b10:	eb 0e                	jmp    800b20 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b12:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b15:	80 fb 19             	cmp    $0x19,%bl
  800b18:	77 12                	ja     800b2c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b1a:	0f be c9             	movsbl %cl,%ecx
  800b1d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b20:	39 f1                	cmp    %esi,%ecx
  800b22:	7d 0c                	jge    800b30 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b24:	42                   	inc    %edx
  800b25:	0f af c6             	imul   %esi,%eax
  800b28:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b2a:	eb c4                	jmp    800af0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b2c:	89 c1                	mov    %eax,%ecx
  800b2e:	eb 02                	jmp    800b32 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b30:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b36:	74 05                	je     800b3d <strtol+0xbd>
		*endptr = (char *) s;
  800b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b3b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b3d:	85 ff                	test   %edi,%edi
  800b3f:	74 04                	je     800b45 <strtol+0xc5>
  800b41:	89 c8                	mov    %ecx,%eax
  800b43:	f7 d8                	neg    %eax
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    
	...

00800b4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	89 c6                	mov    %eax,%esi
  800b63:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	89 cb                	mov    %ecx,%ebx
  800ba1:	89 cf                	mov    %ecx,%edi
  800ba3:	89 ce                	mov    %ecx,%esi
  800ba5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7e 28                	jle    800bd3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800baf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bb6:	00 
  800bb7:	c7 44 24 08 04 19 80 	movl   $0x801904,0x8(%esp)
  800bbe:	00 
  800bbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc6:	00 
  800bc7:	c7 04 24 21 19 80 00 	movl   $0x801921,(%esp)
  800bce:	e8 b1 f5 ff ff       	call   800184 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd3:	83 c4 2c             	add    $0x2c,%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
  800be6:	b8 02 00 00 00       	mov    $0x2,%eax
  800beb:	89 d1                	mov    %edx,%ecx
  800bed:	89 d3                	mov    %edx,%ebx
  800bef:	89 d7                	mov    %edx,%edi
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_yield>:

void
sys_yield(void)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c0a:	89 d1                	mov    %edx,%ecx
  800c0c:	89 d3                	mov    %edx,%ebx
  800c0e:	89 d7                	mov    %edx,%edi
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	be 00 00 00 00       	mov    $0x0,%esi
  800c27:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 f7                	mov    %esi,%edi
  800c37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 28                	jle    800c65 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c41:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c48:	00 
  800c49:	c7 44 24 08 04 19 80 	movl   $0x801904,0x8(%esp)
  800c50:	00 
  800c51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c58:	00 
  800c59:	c7 04 24 21 19 80 00 	movl   $0x801921,(%esp)
  800c60:	e8 1f f5 ff ff       	call   800184 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c65:	83 c4 2c             	add    $0x2c,%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800c76:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 28                	jle    800cb8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c94:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c9b:	00 
  800c9c:	c7 44 24 08 04 19 80 	movl   $0x801904,0x8(%esp)
  800ca3:	00 
  800ca4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cab:	00 
  800cac:	c7 04 24 21 19 80 00 	movl   $0x801921,(%esp)
  800cb3:	e8 cc f4 ff ff       	call   800184 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb8:	83 c4 2c             	add    $0x2c,%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cce:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 df                	mov    %ebx,%edi
  800cdb:	89 de                	mov    %ebx,%esi
  800cdd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7e 28                	jle    800d0b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cee:	00 
  800cef:	c7 44 24 08 04 19 80 	movl   $0x801904,0x8(%esp)
  800cf6:	00 
  800cf7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfe:	00 
  800cff:	c7 04 24 21 19 80 00 	movl   $0x801921,(%esp)
  800d06:	e8 79 f4 ff ff       	call   800184 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d0b:	83 c4 2c             	add    $0x2c,%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	b8 08 00 00 00       	mov    $0x8,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 28                	jle    800d5e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d41:	00 
  800d42:	c7 44 24 08 04 19 80 	movl   $0x801904,0x8(%esp)
  800d49:	00 
  800d4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d51:	00 
  800d52:	c7 04 24 21 19 80 00 	movl   $0x801921,(%esp)
  800d59:	e8 26 f4 ff ff       	call   800184 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5e:	83 c4 2c             	add    $0x2c,%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d74:	b8 09 00 00 00       	mov    $0x9,%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7e 28                	jle    800db1 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d94:	00 
  800d95:	c7 44 24 08 04 19 80 	movl   $0x801904,0x8(%esp)
  800d9c:	00 
  800d9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da4:	00 
  800da5:	c7 04 24 21 19 80 00 	movl   $0x801921,(%esp)
  800dac:	e8 d3 f3 ff ff       	call   800184 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db1:	83 c4 2c             	add    $0x2c,%esp
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbf:	be 00 00 00 00       	mov    $0x0,%esi
  800dc4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800def:	8b 55 08             	mov    0x8(%ebp),%edx
  800df2:	89 cb                	mov    %ecx,%ebx
  800df4:	89 cf                	mov    %ecx,%edi
  800df6:	89 ce                	mov    %ecx,%esi
  800df8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	7e 28                	jle    800e26 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e02:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e09:	00 
  800e0a:	c7 44 24 08 04 19 80 	movl   $0x801904,0x8(%esp)
  800e11:	00 
  800e12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e19:	00 
  800e1a:	c7 04 24 21 19 80 00 	movl   $0x801921,(%esp)
  800e21:	e8 5e f3 ff ff       	call   800184 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e26:	83 c4 2c             	add    $0x2c,%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    
	...

00800e30 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	57                   	push   %edi
  800e34:	56                   	push   %esi
  800e35:	53                   	push   %ebx
  800e36:	83 ec 3c             	sub    $0x3c,%esp
  800e39:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800e3c:	89 d6                	mov    %edx,%esi
  800e3e:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800e41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e48:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800e4b:	e8 8b fd ff ff       	call   800bdb <sys_getenvid>
  800e50:	89 c7                	mov    %eax,%edi
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e55:	25 02 08 00 00       	and    $0x802,%eax
  800e5a:	83 f8 01             	cmp    $0x1,%eax
  800e5d:	19 db                	sbb    %ebx,%ebx
  800e5f:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800e65:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800e6b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800e6f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e73:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e76:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7e:	89 3c 24             	mov    %edi,(%esp)
  800e81:	e8 e7 fd ff ff       	call   800c6d <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800e86:	85 c0                	test   %eax,%eax
  800e88:	79 1c                	jns    800ea6 <duppage+0x76>
  800e8a:	c7 44 24 08 2f 19 80 	movl   $0x80192f,0x8(%esp)
  800e91:	00 
  800e92:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  800e99:	00 
  800e9a:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  800ea1:	e8 de f2 ff ff       	call   800184 <_panic>
	if ((perm|~pte)&PTE_COW){
  800ea6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ea9:	f7 d0                	not    %eax
  800eab:	09 d8                	or     %ebx,%eax
  800ead:	f6 c4 08             	test   $0x8,%ah
  800eb0:	74 38                	je     800eea <duppage+0xba>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800eb2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800eb6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800eba:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ebe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ec2:	89 3c 24             	mov    %edi,(%esp)
  800ec5:	e8 a3 fd ff ff       	call   800c6d <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	79 1c                	jns    800eea <duppage+0xba>
  800ece:	c7 44 24 08 2f 19 80 	movl   $0x80192f,0x8(%esp)
  800ed5:	00 
  800ed6:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
  800edd:	00 
  800ede:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  800ee5:	e8 9a f2 ff ff       	call   800184 <_panic>
	}
	return 0;
	panic("duppage not implemented");
	return 0;
}
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	83 c4 3c             	add    $0x3c,%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	83 ec 20             	sub    $0x20,%esp
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f02:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800f04:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f08:	75 1c                	jne    800f26 <pgfault+0x2f>
		panic("pgfault: error!\n");
  800f0a:	c7 44 24 08 4b 19 80 	movl   $0x80194b,0x8(%esp)
  800f11:	00 
  800f12:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f19:	00 
  800f1a:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  800f21:	e8 5e f2 ff ff       	call   800184 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800f26:	89 f0                	mov    %esi,%eax
  800f28:	c1 e8 0c             	shr    $0xc,%eax
  800f2b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f32:	f6 c4 08             	test   $0x8,%ah
  800f35:	75 1c                	jne    800f53 <pgfault+0x5c>
		panic("pgfault: error!\n");
  800f37:	c7 44 24 08 4b 19 80 	movl   $0x80194b,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  800f4e:	e8 31 f2 ff ff       	call   800184 <_panic>
	envid_t envid = sys_getenvid();
  800f53:	e8 83 fc ff ff       	call   800bdb <sys_getenvid>
  800f58:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800f5a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f69:	00 
  800f6a:	89 04 24             	mov    %eax,(%esp)
  800f6d:	e8 a7 fc ff ff       	call   800c19 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800f72:	85 c0                	test   %eax,%eax
  800f74:	79 1c                	jns    800f92 <pgfault+0x9b>
  800f76:	c7 44 24 08 4b 19 80 	movl   $0x80194b,0x8(%esp)
  800f7d:	00 
  800f7e:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800f85:	00 
  800f86:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  800f8d:	e8 f2 f1 ff ff       	call   800184 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  800f92:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  800f98:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f9f:	00 
  800fa0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fab:	e8 5a fa ff ff       	call   800a0a <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  800fb0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fb7:	00 
  800fb8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fbc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fc0:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fc7:	00 
  800fc8:	89 1c 24             	mov    %ebx,(%esp)
  800fcb:	e8 9d fc ff ff       	call   800c6d <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 1c                	jns    800ff0 <pgfault+0xf9>
  800fd4:	c7 44 24 08 4b 19 80 	movl   $0x80194b,0x8(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  800fe3:	00 
  800fe4:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  800feb:	e8 94 f1 ff ff       	call   800184 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  800ff0:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ff7:	00 
  800ff8:	89 1c 24             	mov    %ebx,(%esp)
  800ffb:	e8 c0 fc ff ff       	call   800cc0 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  801000:	85 c0                	test   %eax,%eax
  801002:	79 1c                	jns    801020 <pgfault+0x129>
  801004:	c7 44 24 08 4b 19 80 	movl   $0x80194b,0x8(%esp)
  80100b:	00 
  80100c:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801013:	00 
  801014:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  80101b:	e8 64 f1 ff ff       	call   800184 <_panic>
	return;
	panic("pgfault not implemented");
}
  801020:	83 c4 20             	add    $0x20,%esp
  801023:	5b                   	pop    %ebx
  801024:	5e                   	pop    %esi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801030:	c7 04 24 f7 0e 80 00 	movl   $0x800ef7,(%esp)
  801037:	e8 fc 02 00 00       	call   801338 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80103c:	bf 07 00 00 00       	mov    $0x7,%edi
  801041:	89 f8                	mov    %edi,%eax
  801043:	cd 30                	int    $0x30
  801045:	89 c7                	mov    %eax,%edi
  801047:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 1c                	jns    801069 <fork+0x42>
		panic("fork : error!\n");
  80104d:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  801064:	e8 1b f1 ff ff       	call   800184 <_panic>
	if (envid==0){
  801069:	85 c0                	test   %eax,%eax
  80106b:	75 28                	jne    801095 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  80106d:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  801073:	e8 63 fb ff ff       	call   800bdb <sys_getenvid>
  801078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80107d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801084:	c1 e0 07             	shl    $0x7,%eax
  801087:	29 d0                	sub    %edx,%eax
  801089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80108e:	89 03                	mov    %eax,(%ebx)
		return envid;
  801090:	e9 f2 00 00 00       	jmp    801187 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  801095:	e8 41 fb ff ff       	call   800bdb <sys_getenvid>
  80109a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80109d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  8010a2:	89 d8                	mov    %ebx,%eax
  8010a4:	c1 e8 16             	shr    $0x16,%eax
  8010a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ae:	a8 01                	test   $0x1,%al
  8010b0:	74 17                	je     8010c9 <fork+0xa2>
  8010b2:	89 da                	mov    %ebx,%edx
  8010b4:	c1 ea 0c             	shr    $0xc,%edx
  8010b7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010be:	a8 01                	test   $0x1,%al
  8010c0:	74 07                	je     8010c9 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  8010c2:	89 f0                	mov    %esi,%eax
  8010c4:	e8 67 fd ff ff       	call   800e30 <duppage>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8010c9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010cf:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010d5:	75 cb                	jne    8010a2 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  8010d7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010de:	00 
  8010df:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010e6:	ee 
  8010e7:	89 3c 24             	mov    %edi,(%esp)
  8010ea:	e8 2a fb ff ff       	call   800c19 <sys_page_alloc>
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	79 1c                	jns    80110f <fork+0xe8>
  8010f3:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  801102:	00 
  801103:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  80110a:	e8 75 f0 ff ff       	call   800184 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  80110f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801112:	25 ff 03 00 00       	and    $0x3ff,%eax
  801117:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80111e:	c1 e0 07             	shl    $0x7,%eax
  801121:	29 d0                	sub    %edx,%eax
  801123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801128:	8b 40 64             	mov    0x64(%eax),%eax
  80112b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112f:	89 3c 24             	mov    %edi,(%esp)
  801132:	e8 2f fc ff ff       	call   800d66 <sys_env_set_pgfault_upcall>
  801137:	85 c0                	test   %eax,%eax
  801139:	79 1c                	jns    801157 <fork+0x130>
  80113b:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  801142:	00 
  801143:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  80114a:	00 
  80114b:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  801152:	e8 2d f0 ff ff       	call   800184 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  801157:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80115e:	00 
  80115f:	89 3c 24             	mov    %edi,(%esp)
  801162:	e8 ac fb ff ff       	call   800d13 <sys_env_set_status>
  801167:	85 c0                	test   %eax,%eax
  801169:	79 1c                	jns    801187 <fork+0x160>
  80116b:	c7 44 24 08 68 19 80 	movl   $0x801968,0x8(%esp)
  801172:	00 
  801173:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  80117a:	00 
  80117b:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  801182:	e8 fd ef ff ff       	call   800184 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801187:	89 f8                	mov    %edi,%eax
  801189:	83 c4 2c             	add    $0x2c,%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <sfork>:

// Challenge!
int
sfork(void)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  80119a:	c7 04 24 f7 0e 80 00 	movl   $0x800ef7,(%esp)
  8011a1:	e8 92 01 00 00       	call   801338 <set_pgfault_handler>
  8011a6:	ba 07 00 00 00       	mov    $0x7,%edx
  8011ab:	89 d0                	mov    %edx,%eax
  8011ad:	cd 30                	int    $0x30
  8011af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011b2:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  8011b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b8:	c7 04 24 5c 19 80 00 	movl   $0x80195c,(%esp)
  8011bf:	e8 b8 f0 ff ff       	call   80027c <cprintf>
	if (envid<0)
  8011c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011c8:	79 1c                	jns    8011e6 <sfork+0x55>
		panic("sfork : error!\n");
  8011ca:	c7 44 24 08 67 19 80 	movl   $0x801967,0x8(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8011d9:	00 
  8011da:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  8011e1:	e8 9e ef ff ff       	call   800184 <_panic>
	if (envid==0){
  8011e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8011ea:	75 28                	jne    801214 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  8011ec:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8011f2:	e8 e4 f9 ff ff       	call   800bdb <sys_getenvid>
  8011f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011fc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801203:	c1 e0 07             	shl    $0x7,%eax
  801206:	29 d0                	sub    %edx,%eax
  801208:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80120d:	89 03                	mov    %eax,(%ebx)
		return envid;
  80120f:	e9 18 01 00 00       	jmp    80132c <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801214:	e8 c2 f9 ff ff       	call   800bdb <sys_getenvid>
  801219:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80121b:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801220:	89 d8                	mov    %ebx,%eax
  801222:	c1 e8 16             	shr    $0x16,%eax
  801225:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80122c:	a8 01                	test   $0x1,%al
  80122e:	74 2c                	je     80125c <sfork+0xcb>
  801230:	89 d8                	mov    %ebx,%eax
  801232:	c1 e8 0c             	shr    $0xc,%eax
  801235:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80123c:	a8 01                	test   $0x1,%al
  80123e:	74 1c                	je     80125c <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  801240:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801247:	00 
  801248:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80124c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801250:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801254:	89 3c 24             	mov    %edi,(%esp)
  801257:	e8 11 fa ff ff       	call   800c6d <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80125c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801262:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801268:	75 b6                	jne    801220 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  80126a:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  80126f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801272:	e8 b9 fb ff ff       	call   800e30 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801277:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80127e:	00 
  80127f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801286:	ee 
  801287:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80128a:	89 04 24             	mov    %eax,(%esp)
  80128d:	e8 87 f9 ff ff       	call   800c19 <sys_page_alloc>
  801292:	85 c0                	test   %eax,%eax
  801294:	79 1c                	jns    8012b2 <sfork+0x121>
  801296:	c7 44 24 08 67 19 80 	movl   $0x801967,0x8(%esp)
  80129d:	00 
  80129e:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8012a5:	00 
  8012a6:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  8012ad:	e8 d2 ee ff ff       	call   800184 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  8012b2:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  8012b8:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  8012bf:	c1 e7 07             	shl    $0x7,%edi
  8012c2:	29 d7                	sub    %edx,%edi
  8012c4:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  8012ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d1:	89 04 24             	mov    %eax,(%esp)
  8012d4:	e8 8d fa ff ff       	call   800d66 <sys_env_set_pgfault_upcall>
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	79 1c                	jns    8012f9 <sfork+0x168>
  8012dd:	c7 44 24 08 67 19 80 	movl   $0x801967,0x8(%esp)
  8012e4:	00 
  8012e5:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
  8012ec:	00 
  8012ed:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  8012f4:	e8 8b ee ff ff       	call   800184 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  8012f9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801300:	00 
  801301:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801304:	89 04 24             	mov    %eax,(%esp)
  801307:	e8 07 fa ff ff       	call   800d13 <sys_env_set_status>
  80130c:	85 c0                	test   %eax,%eax
  80130e:	79 1c                	jns    80132c <sfork+0x19b>
  801310:	c7 44 24 08 67 19 80 	movl   $0x801967,0x8(%esp)
  801317:	00 
  801318:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  80131f:	00 
  801320:	c7 04 24 40 19 80 00 	movl   $0x801940,(%esp)
  801327:	e8 58 ee ff ff       	call   800184 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  80132c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80132f:	83 c4 3c             	add    $0x3c,%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5f                   	pop    %edi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    
	...

00801338 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80133f:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801346:	75 6f                	jne    8013b7 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  801348:	e8 8e f8 ff ff       	call   800bdb <sys_getenvid>
  80134d:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80134f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801356:	00 
  801357:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80135e:	ee 
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	e8 b2 f8 ff ff       	call   800c19 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  801367:	85 c0                	test   %eax,%eax
  801369:	79 1c                	jns    801387 <set_pgfault_handler+0x4f>
  80136b:	c7 44 24 08 78 19 80 	movl   $0x801978,0x8(%esp)
  801372:	00 
  801373:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80137a:	00 
  80137b:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  801382:	e8 fd ed ff ff       	call   800184 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  801387:	c7 44 24 04 c8 13 80 	movl   $0x8013c8,0x4(%esp)
  80138e:	00 
  80138f:	89 1c 24             	mov    %ebx,(%esp)
  801392:	e8 cf f9 ff ff       	call   800d66 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  801397:	85 c0                	test   %eax,%eax
  801399:	79 1c                	jns    8013b7 <set_pgfault_handler+0x7f>
  80139b:	c7 44 24 08 a0 19 80 	movl   $0x8019a0,0x8(%esp)
  8013a2:	00 
  8013a3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8013aa:	00 
  8013ab:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  8013b2:	e8 cd ed ff ff       	call   800184 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ba:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8013bf:	83 c4 14             	add    $0x14,%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    
  8013c5:	00 00                	add    %al,(%eax)
	...

008013c8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013c8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013c9:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8013ce:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013d0:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8013d3:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8013d7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8013dc:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  8013e0:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  8013e2:	83 c4 08             	add    $0x8,%esp
	popal
  8013e5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  8013e6:	83 c4 04             	add    $0x4,%esp
	popfl
  8013e9:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  8013ea:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8013ed:	c3                   	ret    
	...

008013f0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8013f0:	55                   	push   %ebp
  8013f1:	57                   	push   %edi
  8013f2:	56                   	push   %esi
  8013f3:	83 ec 10             	sub    $0x10,%esp
  8013f6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8013fa:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8013fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801402:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801406:	89 cd                	mov    %ecx,%ebp
  801408:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80140c:	85 c0                	test   %eax,%eax
  80140e:	75 2c                	jne    80143c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801410:	39 f9                	cmp    %edi,%ecx
  801412:	77 68                	ja     80147c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801414:	85 c9                	test   %ecx,%ecx
  801416:	75 0b                	jne    801423 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801418:	b8 01 00 00 00       	mov    $0x1,%eax
  80141d:	31 d2                	xor    %edx,%edx
  80141f:	f7 f1                	div    %ecx
  801421:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801423:	31 d2                	xor    %edx,%edx
  801425:	89 f8                	mov    %edi,%eax
  801427:	f7 f1                	div    %ecx
  801429:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80142b:	89 f0                	mov    %esi,%eax
  80142d:	f7 f1                	div    %ecx
  80142f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801431:	89 f0                	mov    %esi,%eax
  801433:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	5e                   	pop    %esi
  801439:	5f                   	pop    %edi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80143c:	39 f8                	cmp    %edi,%eax
  80143e:	77 2c                	ja     80146c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801440:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801443:	83 f6 1f             	xor    $0x1f,%esi
  801446:	75 4c                	jne    801494 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801448:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80144a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80144f:	72 0a                	jb     80145b <__udivdi3+0x6b>
  801451:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801455:	0f 87 ad 00 00 00    	ja     801508 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80145b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801460:	89 f0                	mov    %esi,%eax
  801462:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	5e                   	pop    %esi
  801468:	5f                   	pop    %edi
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    
  80146b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80146c:	31 ff                	xor    %edi,%edi
  80146e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801470:	89 f0                	mov    %esi,%eax
  801472:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	5e                   	pop    %esi
  801478:	5f                   	pop    %edi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    
  80147b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80147c:	89 fa                	mov    %edi,%edx
  80147e:	89 f0                	mov    %esi,%eax
  801480:	f7 f1                	div    %ecx
  801482:	89 c6                	mov    %eax,%esi
  801484:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801486:	89 f0                	mov    %esi,%eax
  801488:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	5e                   	pop    %esi
  80148e:	5f                   	pop    %edi
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    
  801491:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801494:	89 f1                	mov    %esi,%ecx
  801496:	d3 e0                	shl    %cl,%eax
  801498:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80149c:	b8 20 00 00 00       	mov    $0x20,%eax
  8014a1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8014a3:	89 ea                	mov    %ebp,%edx
  8014a5:	88 c1                	mov    %al,%cl
  8014a7:	d3 ea                	shr    %cl,%edx
  8014a9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8014ad:	09 ca                	or     %ecx,%edx
  8014af:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8014b3:	89 f1                	mov    %esi,%ecx
  8014b5:	d3 e5                	shl    %cl,%ebp
  8014b7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8014bb:	89 fd                	mov    %edi,%ebp
  8014bd:	88 c1                	mov    %al,%cl
  8014bf:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8014c1:	89 fa                	mov    %edi,%edx
  8014c3:	89 f1                	mov    %esi,%ecx
  8014c5:	d3 e2                	shl    %cl,%edx
  8014c7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014cb:	88 c1                	mov    %al,%cl
  8014cd:	d3 ef                	shr    %cl,%edi
  8014cf:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8014d1:	89 f8                	mov    %edi,%eax
  8014d3:	89 ea                	mov    %ebp,%edx
  8014d5:	f7 74 24 08          	divl   0x8(%esp)
  8014d9:	89 d1                	mov    %edx,%ecx
  8014db:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8014dd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014e1:	39 d1                	cmp    %edx,%ecx
  8014e3:	72 17                	jb     8014fc <__udivdi3+0x10c>
  8014e5:	74 09                	je     8014f0 <__udivdi3+0x100>
  8014e7:	89 fe                	mov    %edi,%esi
  8014e9:	31 ff                	xor    %edi,%edi
  8014eb:	e9 41 ff ff ff       	jmp    801431 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8014f0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014f4:	89 f1                	mov    %esi,%ecx
  8014f6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014f8:	39 c2                	cmp    %eax,%edx
  8014fa:	73 eb                	jae    8014e7 <__udivdi3+0xf7>
		{
		  q0--;
  8014fc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8014ff:	31 ff                	xor    %edi,%edi
  801501:	e9 2b ff ff ff       	jmp    801431 <__udivdi3+0x41>
  801506:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801508:	31 f6                	xor    %esi,%esi
  80150a:	e9 22 ff ff ff       	jmp    801431 <__udivdi3+0x41>
	...

00801510 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801510:	55                   	push   %ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	83 ec 20             	sub    $0x20,%esp
  801516:	8b 44 24 30          	mov    0x30(%esp),%eax
  80151a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80151e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801522:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801526:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80152a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80152e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801530:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801532:	85 ed                	test   %ebp,%ebp
  801534:	75 16                	jne    80154c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801536:	39 f1                	cmp    %esi,%ecx
  801538:	0f 86 a6 00 00 00    	jbe    8015e4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80153e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801540:	89 d0                	mov    %edx,%eax
  801542:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801544:	83 c4 20             	add    $0x20,%esp
  801547:	5e                   	pop    %esi
  801548:	5f                   	pop    %edi
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    
  80154b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80154c:	39 f5                	cmp    %esi,%ebp
  80154e:	0f 87 ac 00 00 00    	ja     801600 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801554:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801557:	83 f0 1f             	xor    $0x1f,%eax
  80155a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80155e:	0f 84 a8 00 00 00    	je     80160c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801564:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801568:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80156a:	bf 20 00 00 00       	mov    $0x20,%edi
  80156f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801573:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801577:	89 f9                	mov    %edi,%ecx
  801579:	d3 e8                	shr    %cl,%eax
  80157b:	09 e8                	or     %ebp,%eax
  80157d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801581:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801585:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801589:	d3 e0                	shl    %cl,%eax
  80158b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80158f:	89 f2                	mov    %esi,%edx
  801591:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801593:	8b 44 24 14          	mov    0x14(%esp),%eax
  801597:	d3 e0                	shl    %cl,%eax
  801599:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80159d:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015a1:	89 f9                	mov    %edi,%ecx
  8015a3:	d3 e8                	shr    %cl,%eax
  8015a5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8015a7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8015a9:	89 f2                	mov    %esi,%edx
  8015ab:	f7 74 24 18          	divl   0x18(%esp)
  8015af:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8015b1:	f7 64 24 0c          	mull   0xc(%esp)
  8015b5:	89 c5                	mov    %eax,%ebp
  8015b7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015b9:	39 d6                	cmp    %edx,%esi
  8015bb:	72 67                	jb     801624 <__umoddi3+0x114>
  8015bd:	74 75                	je     801634 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8015bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8015c3:	29 e8                	sub    %ebp,%eax
  8015c5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8015c7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015cb:	d3 e8                	shr    %cl,%eax
  8015cd:	89 f2                	mov    %esi,%edx
  8015cf:	89 f9                	mov    %edi,%ecx
  8015d1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8015d3:	09 d0                	or     %edx,%eax
  8015d5:	89 f2                	mov    %esi,%edx
  8015d7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015db:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015dd:	83 c4 20             	add    $0x20,%esp
  8015e0:	5e                   	pop    %esi
  8015e1:	5f                   	pop    %edi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8015e4:	85 c9                	test   %ecx,%ecx
  8015e6:	75 0b                	jne    8015f3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8015e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ed:	31 d2                	xor    %edx,%edx
  8015ef:	f7 f1                	div    %ecx
  8015f1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8015f3:	89 f0                	mov    %esi,%eax
  8015f5:	31 d2                	xor    %edx,%edx
  8015f7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8015f9:	89 f8                	mov    %edi,%eax
  8015fb:	e9 3e ff ff ff       	jmp    80153e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801600:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801602:	83 c4 20             	add    $0x20,%esp
  801605:	5e                   	pop    %esi
  801606:	5f                   	pop    %edi
  801607:	5d                   	pop    %ebp
  801608:	c3                   	ret    
  801609:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80160c:	39 f5                	cmp    %esi,%ebp
  80160e:	72 04                	jb     801614 <__umoddi3+0x104>
  801610:	39 f9                	cmp    %edi,%ecx
  801612:	77 06                	ja     80161a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801614:	89 f2                	mov    %esi,%edx
  801616:	29 cf                	sub    %ecx,%edi
  801618:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80161a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80161c:	83 c4 20             	add    $0x20,%esp
  80161f:	5e                   	pop    %esi
  801620:	5f                   	pop    %edi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    
  801623:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801624:	89 d1                	mov    %edx,%ecx
  801626:	89 c5                	mov    %eax,%ebp
  801628:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80162c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801630:	eb 8d                	jmp    8015bf <__umoddi3+0xaf>
  801632:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801634:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801638:	72 ea                	jb     801624 <__umoddi3+0x114>
  80163a:	89 f1                	mov    %esi,%ecx
  80163c:	eb 81                	jmp    8015bf <__umoddi3+0xaf>
