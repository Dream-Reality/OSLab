
obj/user/stresssched.debug:     file format elf32-i386


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
  80003c:	e8 92 0b 00 00       	call   800bd3 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 67 10 00 00       	call   8010b4 <fork>
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
  80005e:	e8 8f 0b 00 00       	call   800bf2 <sys_yield>
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
  800092:	e8 5b 0b 00 00       	call   800bf2 <sys_yield>
  800097:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  80009c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000a2:	42                   	inc    %edx
  8000a3:	89 15 04 40 80 00    	mov    %edx,0x804004
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
  8000af:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b4:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b9:	74 25                	je     8000e0 <umain+0xac>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 40 26 80 	movl   $0x802640,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 68 26 80 00 	movl   $0x802668,(%esp)
  8000db:	e8 9c 00 00 00       	call   80017c <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8000e5:	8b 00                	mov    (%eax),%eax
  8000e7:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000ea:	8b 40 48             	mov    0x48(%eax),%eax
  8000ed:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f5:	c7 04 24 7b 26 80 00 	movl   $0x80267b,(%esp)
  8000fc:	e8 73 01 00 00       	call   800274 <cprintf>

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
  800116:	e8 b8 0a 00 00       	call   800bd3 <sys_getenvid>
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800127:	c1 e0 07             	shl    $0x7,%eax
  80012a:	29 d0                	sub    %edx,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800134:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800137:	a3 08 40 80 00       	mov    %eax,0x804008
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013c:	85 f6                	test   %esi,%esi
  80013e:	7e 07                	jle    800147 <libmain+0x3f>
		binaryname = argv[0];
  800140:	8b 03                	mov    (%ebx),%eax
  800142:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800147:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80014b:	89 34 24             	mov    %esi,(%esp)
  80014e:	e8 e1 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800153:	e8 08 00 00 00       	call   800160 <exit>
}
  800158:	83 c4 20             	add    $0x20,%esp
  80015b:	5b                   	pop    %ebx
  80015c:	5e                   	pop    %esi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    
	...

00800160 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800166:	e8 42 14 00 00       	call   8015ad <close_all>
	sys_env_destroy(0);
  80016b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800172:	e8 0a 0a 00 00       	call   800b81 <sys_env_destroy>
}
  800177:	c9                   	leave  
  800178:	c3                   	ret    
  800179:	00 00                	add    %al,(%eax)
	...

0080017c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	56                   	push   %esi
  800180:	53                   	push   %ebx
  800181:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800184:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800187:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80018d:	e8 41 0a 00 00       	call   800bd3 <sys_getenvid>
  800192:	8b 55 0c             	mov    0xc(%ebp),%edx
  800195:	89 54 24 10          	mov    %edx,0x10(%esp)
  800199:	8b 55 08             	mov    0x8(%ebp),%edx
  80019c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  8001af:	e8 c0 00 00 00       	call   800274 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bb:	89 04 24             	mov    %eax,(%esp)
  8001be:	e8 50 00 00 00       	call   800213 <vcprintf>
	cprintf("\n");
  8001c3:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  8001ca:	e8 a5 00 00 00       	call   800274 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cf:	cc                   	int3   
  8001d0:	eb fd                	jmp    8001cf <_panic+0x53>
	...

008001d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 14             	sub    $0x14,%esp
  8001db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001de:	8b 03                	mov    (%ebx),%eax
  8001e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e7:	40                   	inc    %eax
  8001e8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ef:	75 19                	jne    80020a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001f1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f8:	00 
  8001f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fc:	89 04 24             	mov    %eax,(%esp)
  8001ff:	e8 40 09 00 00       	call   800b44 <sys_cputs>
		b->idx = 0;
  800204:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80020a:	ff 43 04             	incl   0x4(%ebx)
}
  80020d:	83 c4 14             	add    $0x14,%esp
  800210:	5b                   	pop    %ebx
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80021c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800223:	00 00 00 
	b.cnt = 0;
  800226:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800230:	8b 45 0c             	mov    0xc(%ebp),%eax
  800233:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800237:	8b 45 08             	mov    0x8(%ebp),%eax
  80023a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	89 44 24 04          	mov    %eax,0x4(%esp)
  800248:	c7 04 24 d4 01 80 00 	movl   $0x8001d4,(%esp)
  80024f:	e8 82 01 00 00       	call   8003d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800254:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80025a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800264:	89 04 24             	mov    %eax,(%esp)
  800267:	e8 d8 08 00 00       	call   800b44 <sys_cputs>

	return b.cnt;
}
  80026c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800281:	8b 45 08             	mov    0x8(%ebp),%eax
  800284:	89 04 24             	mov    %eax,(%esp)
  800287:	e8 87 ff ff ff       	call   800213 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    
	...

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 3c             	sub    $0x3c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d7                	mov    %edx,%edi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	75 08                	jne    8002bc <printnum+0x2c>
  8002b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ba:	77 57                	ja     800313 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002c0:	4b                   	dec    %ebx
  8002c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002d0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002db:	00 
  8002dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	e8 fa 20 00 00       	call   8023e8 <__udivdi3>
  8002ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002f2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f6:	89 04 24             	mov    %eax,(%esp)
  8002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fd:	89 fa                	mov    %edi,%edx
  8002ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800302:	e8 89 ff ff ff       	call   800290 <printnum>
  800307:	eb 0f                	jmp    800318 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800309:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030d:	89 34 24             	mov    %esi,(%esp)
  800310:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800313:	4b                   	dec    %ebx
  800314:	85 db                	test   %ebx,%ebx
  800316:	7f f1                	jg     800309 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800318:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800320:	8b 45 10             	mov    0x10(%ebp),%eax
  800323:	89 44 24 08          	mov    %eax,0x8(%esp)
  800327:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032e:	00 
  80032f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800338:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033c:	e8 c7 21 00 00       	call   802508 <__umoddi3>
  800341:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800345:	0f be 80 c7 26 80 00 	movsbl 0x8026c7(%eax),%eax
  80034c:	89 04 24             	mov    %eax,(%esp)
  80034f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800352:	83 c4 3c             	add    $0x3c,%esp
  800355:	5b                   	pop    %ebx
  800356:	5e                   	pop    %esi
  800357:	5f                   	pop    %edi
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035d:	83 fa 01             	cmp    $0x1,%edx
  800360:	7e 0e                	jle    800370 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800362:	8b 10                	mov    (%eax),%edx
  800364:	8d 4a 08             	lea    0x8(%edx),%ecx
  800367:	89 08                	mov    %ecx,(%eax)
  800369:	8b 02                	mov    (%edx),%eax
  80036b:	8b 52 04             	mov    0x4(%edx),%edx
  80036e:	eb 22                	jmp    800392 <getuint+0x38>
	else if (lflag)
  800370:	85 d2                	test   %edx,%edx
  800372:	74 10                	je     800384 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800374:	8b 10                	mov    (%eax),%edx
  800376:	8d 4a 04             	lea    0x4(%edx),%ecx
  800379:	89 08                	mov    %ecx,(%eax)
  80037b:	8b 02                	mov    (%edx),%eax
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
  800382:	eb 0e                	jmp    800392 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800384:	8b 10                	mov    (%eax),%edx
  800386:	8d 4a 04             	lea    0x4(%edx),%ecx
  800389:	89 08                	mov    %ecx,(%eax)
  80038b:	8b 02                	mov    (%edx),%eax
  80038d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a2:	73 08                	jae    8003ac <sprintputch+0x18>
		*b->buf++ = ch;
  8003a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a7:	88 0a                	mov    %cl,(%edx)
  8003a9:	42                   	inc    %edx
  8003aa:	89 10                	mov    %edx,(%eax)
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8003be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cc:	89 04 24             	mov    %eax,(%esp)
  8003cf:	e8 02 00 00 00       	call   8003d6 <vprintfmt>
	va_end(ap);
}
  8003d4:	c9                   	leave  
  8003d5:	c3                   	ret    

008003d6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	57                   	push   %edi
  8003da:	56                   	push   %esi
  8003db:	53                   	push   %ebx
  8003dc:	83 ec 4c             	sub    $0x4c,%esp
  8003df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003e2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003e5:	eb 12                	jmp    8003f9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	0f 84 6b 03 00 00    	je     80075a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003f3:	89 04 24             	mov    %eax,(%esp)
  8003f6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f9:	0f b6 06             	movzbl (%esi),%eax
  8003fc:	46                   	inc    %esi
  8003fd:	83 f8 25             	cmp    $0x25,%eax
  800400:	75 e5                	jne    8003e7 <vprintfmt+0x11>
  800402:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800406:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80040d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800412:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800419:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041e:	eb 26                	jmp    800446 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800423:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800427:	eb 1d                	jmp    800446 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800430:	eb 14                	jmp    800446 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800435:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80043c:	eb 08                	jmp    800446 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80043e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800441:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	0f b6 06             	movzbl (%esi),%eax
  800449:	8d 56 01             	lea    0x1(%esi),%edx
  80044c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80044f:	8a 16                	mov    (%esi),%dl
  800451:	83 ea 23             	sub    $0x23,%edx
  800454:	80 fa 55             	cmp    $0x55,%dl
  800457:	0f 87 e1 02 00 00    	ja     80073e <vprintfmt+0x368>
  80045d:	0f b6 d2             	movzbl %dl,%edx
  800460:	ff 24 95 00 28 80 00 	jmp    *0x802800(,%edx,4)
  800467:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80046f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800472:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800476:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800479:	8d 50 d0             	lea    -0x30(%eax),%edx
  80047c:	83 fa 09             	cmp    $0x9,%edx
  80047f:	77 2a                	ja     8004ab <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800481:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800482:	eb eb                	jmp    80046f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8d 50 04             	lea    0x4(%eax),%edx
  80048a:	89 55 14             	mov    %edx,0x14(%ebp)
  80048d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800492:	eb 17                	jmp    8004ab <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800494:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800498:	78 98                	js     800432 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049d:	eb a7                	jmp    800446 <vprintfmt+0x70>
  80049f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004a9:	eb 9b                	jmp    800446 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004af:	79 95                	jns    800446 <vprintfmt+0x70>
  8004b1:	eb 8b                	jmp    80043e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b7:	eb 8d                	jmp    800446 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 50 04             	lea    0x4(%eax),%edx
  8004bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c6:	8b 00                	mov    (%eax),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d1:	e9 23 ff ff ff       	jmp    8003f9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 50 04             	lea    0x4(%eax),%edx
  8004dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	79 02                	jns    8004e7 <vprintfmt+0x111>
  8004e5:	f7 d8                	neg    %eax
  8004e7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e9:	83 f8 0f             	cmp    $0xf,%eax
  8004ec:	7f 0b                	jg     8004f9 <vprintfmt+0x123>
  8004ee:	8b 04 85 60 29 80 00 	mov    0x802960(,%eax,4),%eax
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	75 23                	jne    80051c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fd:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  800504:	00 
  800505:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800509:	8b 45 08             	mov    0x8(%ebp),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	e8 9a fe ff ff       	call   8003ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800517:	e9 dd fe ff ff       	jmp    8003f9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80051c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800520:	c7 44 24 08 d9 2a 80 	movl   $0x802ad9,0x8(%esp)
  800527:	00 
  800528:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052c:	8b 55 08             	mov    0x8(%ebp),%edx
  80052f:	89 14 24             	mov    %edx,(%esp)
  800532:	e8 77 fe ff ff       	call   8003ae <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800537:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053a:	e9 ba fe ff ff       	jmp    8003f9 <vprintfmt+0x23>
  80053f:	89 f9                	mov    %edi,%ecx
  800541:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800544:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	8b 30                	mov    (%eax),%esi
  800552:	85 f6                	test   %esi,%esi
  800554:	75 05                	jne    80055b <vprintfmt+0x185>
				p = "(null)";
  800556:	be d8 26 80 00       	mov    $0x8026d8,%esi
			if (width > 0 && padc != '-')
  80055b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055f:	0f 8e 84 00 00 00    	jle    8005e9 <vprintfmt+0x213>
  800565:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800569:	74 7e                	je     8005e9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056f:	89 34 24             	mov    %esi,(%esp)
  800572:	e8 8b 02 00 00       	call   800802 <strnlen>
  800577:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80057a:	29 c2                	sub    %eax,%edx
  80057c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80057f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800583:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800586:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800589:	89 de                	mov    %ebx,%esi
  80058b:	89 d3                	mov    %edx,%ebx
  80058d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	eb 0b                	jmp    80059c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800591:	89 74 24 04          	mov    %esi,0x4(%esp)
  800595:	89 3c 24             	mov    %edi,(%esp)
  800598:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	4b                   	dec    %ebx
  80059c:	85 db                	test   %ebx,%ebx
  80059e:	7f f1                	jg     800591 <vprintfmt+0x1bb>
  8005a0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005a3:	89 f3                	mov    %esi,%ebx
  8005a5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	79 05                	jns    8005b4 <vprintfmt+0x1de>
  8005af:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b7:	29 c2                	sub    %eax,%edx
  8005b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005bc:	eb 2b                	jmp    8005e9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c2:	74 18                	je     8005dc <vprintfmt+0x206>
  8005c4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005c7:	83 fa 5e             	cmp    $0x5e,%edx
  8005ca:	76 10                	jbe    8005dc <vprintfmt+0x206>
					putch('?', putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
  8005da:	eb 0a                	jmp    8005e6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e0:	89 04 24             	mov    %eax,(%esp)
  8005e3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005e9:	0f be 06             	movsbl (%esi),%eax
  8005ec:	46                   	inc    %esi
  8005ed:	85 c0                	test   %eax,%eax
  8005ef:	74 21                	je     800612 <vprintfmt+0x23c>
  8005f1:	85 ff                	test   %edi,%edi
  8005f3:	78 c9                	js     8005be <vprintfmt+0x1e8>
  8005f5:	4f                   	dec    %edi
  8005f6:	79 c6                	jns    8005be <vprintfmt+0x1e8>
  8005f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005fb:	89 de                	mov    %ebx,%esi
  8005fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800600:	eb 18                	jmp    80061a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800602:	89 74 24 04          	mov    %esi,0x4(%esp)
  800606:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060f:	4b                   	dec    %ebx
  800610:	eb 08                	jmp    80061a <vprintfmt+0x244>
  800612:	8b 7d 08             	mov    0x8(%ebp),%edi
  800615:	89 de                	mov    %ebx,%esi
  800617:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80061a:	85 db                	test   %ebx,%ebx
  80061c:	7f e4                	jg     800602 <vprintfmt+0x22c>
  80061e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800621:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800626:	e9 ce fd ff ff       	jmp    8003f9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062b:	83 f9 01             	cmp    $0x1,%ecx
  80062e:	7e 10                	jle    800640 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 08             	lea    0x8(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	8b 30                	mov    (%eax),%esi
  80063b:	8b 78 04             	mov    0x4(%eax),%edi
  80063e:	eb 26                	jmp    800666 <vprintfmt+0x290>
	else if (lflag)
  800640:	85 c9                	test   %ecx,%ecx
  800642:	74 12                	je     800656 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 30                	mov    (%eax),%esi
  80064f:	89 f7                	mov    %esi,%edi
  800651:	c1 ff 1f             	sar    $0x1f,%edi
  800654:	eb 10                	jmp    800666 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 30                	mov    (%eax),%esi
  800661:	89 f7                	mov    %esi,%edi
  800663:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800666:	85 ff                	test   %edi,%edi
  800668:	78 0a                	js     800674 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066f:	e9 8c 00 00 00       	jmp    800700 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800674:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800678:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800682:	f7 de                	neg    %esi
  800684:	83 d7 00             	adc    $0x0,%edi
  800687:	f7 df                	neg    %edi
			}
			base = 10;
  800689:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068e:	eb 70                	jmp    800700 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800690:	89 ca                	mov    %ecx,%edx
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
  800695:	e8 c0 fc ff ff       	call   80035a <getuint>
  80069a:	89 c6                	mov    %eax,%esi
  80069c:	89 d7                	mov    %edx,%edi
			base = 10;
  80069e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006a3:	eb 5b                	jmp    800700 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006a5:	89 ca                	mov    %ecx,%edx
  8006a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006aa:	e8 ab fc ff ff       	call   80035a <getuint>
  8006af:	89 c6                	mov    %eax,%esi
  8006b1:	89 d7                	mov    %edx,%edi
			base = 8;
  8006b3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006b8:	eb 46                	jmp    800700 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006be:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 04             	lea    0x4(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006df:	8b 30                	mov    (%eax),%esi
  8006e1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006eb:	eb 13                	jmp    800700 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ed:	89 ca                	mov    %ecx,%edx
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f2:	e8 63 fc ff ff       	call   80035a <getuint>
  8006f7:	89 c6                	mov    %eax,%esi
  8006f9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800700:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800704:	89 54 24 10          	mov    %edx,0x10(%esp)
  800708:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80070b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800713:	89 34 24             	mov    %esi,(%esp)
  800716:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071a:	89 da                	mov    %ebx,%edx
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	e8 6c fb ff ff       	call   800290 <printnum>
			break;
  800724:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800727:	e9 cd fc ff ff       	jmp    8003f9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800730:	89 04 24             	mov    %eax,(%esp)
  800733:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800736:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800739:	e9 bb fc ff ff       	jmp    8003f9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800742:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800749:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074c:	eb 01                	jmp    80074f <vprintfmt+0x379>
  80074e:	4e                   	dec    %esi
  80074f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800753:	75 f9                	jne    80074e <vprintfmt+0x378>
  800755:	e9 9f fc ff ff       	jmp    8003f9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80075a:	83 c4 4c             	add    $0x4c,%esp
  80075d:	5b                   	pop    %ebx
  80075e:	5e                   	pop    %esi
  80075f:	5f                   	pop    %edi
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 28             	sub    $0x28,%esp
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800771:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800775:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077f:	85 c0                	test   %eax,%eax
  800781:	74 30                	je     8007b3 <vsnprintf+0x51>
  800783:	85 d2                	test   %edx,%edx
  800785:	7e 33                	jle    8007ba <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078e:	8b 45 10             	mov    0x10(%ebp),%eax
  800791:	89 44 24 08          	mov    %eax,0x8(%esp)
  800795:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079c:	c7 04 24 94 03 80 00 	movl   $0x800394,(%esp)
  8007a3:	e8 2e fc ff ff       	call   8003d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b1:	eb 0c                	jmp    8007bf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b8:	eb 05                	jmp    8007bf <vsnprintf+0x5d>
  8007ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	89 04 24             	mov    %eax,(%esp)
  8007e2:	e8 7b ff ff ff       	call   800762 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    
  8007e9:	00 00                	add    %al,(%eax)
	...

008007ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f7:	eb 01                	jmp    8007fa <strlen+0xe>
		n++;
  8007f9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fe:	75 f9                	jne    8007f9 <strlen+0xd>
		n++;
	return n;
}
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800808:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	eb 01                	jmp    800813 <strnlen+0x11>
		n++;
  800812:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800813:	39 d0                	cmp    %edx,%eax
  800815:	74 06                	je     80081d <strnlen+0x1b>
  800817:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081b:	75 f5                	jne    800812 <strnlen+0x10>
		n++;
	return n;
}
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800829:	ba 00 00 00 00       	mov    $0x0,%edx
  80082e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800831:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800834:	42                   	inc    %edx
  800835:	84 c9                	test   %cl,%cl
  800837:	75 f5                	jne    80082e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800839:	5b                   	pop    %ebx
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	53                   	push   %ebx
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800846:	89 1c 24             	mov    %ebx,(%esp)
  800849:	e8 9e ff ff ff       	call   8007ec <strlen>
	strcpy(dst + len, src);
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	89 54 24 04          	mov    %edx,0x4(%esp)
  800855:	01 d8                	add    %ebx,%eax
  800857:	89 04 24             	mov    %eax,(%esp)
  80085a:	e8 c0 ff ff ff       	call   80081f <strcpy>
	return dst;
}
  80085f:	89 d8                	mov    %ebx,%eax
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	5b                   	pop    %ebx
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800872:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800875:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087a:	eb 0c                	jmp    800888 <strncpy+0x21>
		*dst++ = *src;
  80087c:	8a 1a                	mov    (%edx),%bl
  80087e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800881:	80 3a 01             	cmpb   $0x1,(%edx)
  800884:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800887:	41                   	inc    %ecx
  800888:	39 f1                	cmp    %esi,%ecx
  80088a:	75 f0                	jne    80087c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80088c:	5b                   	pop    %ebx
  80088d:	5e                   	pop    %esi
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	56                   	push   %esi
  800894:	53                   	push   %ebx
  800895:	8b 75 08             	mov    0x8(%ebp),%esi
  800898:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089e:	85 d2                	test   %edx,%edx
  8008a0:	75 0a                	jne    8008ac <strlcpy+0x1c>
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	eb 1a                	jmp    8008c0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a6:	88 18                	mov    %bl,(%eax)
  8008a8:	40                   	inc    %eax
  8008a9:	41                   	inc    %ecx
  8008aa:	eb 02                	jmp    8008ae <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ac:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008ae:	4a                   	dec    %edx
  8008af:	74 0a                	je     8008bb <strlcpy+0x2b>
  8008b1:	8a 19                	mov    (%ecx),%bl
  8008b3:	84 db                	test   %bl,%bl
  8008b5:	75 ef                	jne    8008a6 <strlcpy+0x16>
  8008b7:	89 c2                	mov    %eax,%edx
  8008b9:	eb 02                	jmp    8008bd <strlcpy+0x2d>
  8008bb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008bd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008c0:	29 f0                	sub    %esi,%eax
}
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cf:	eb 02                	jmp    8008d3 <strcmp+0xd>
		p++, q++;
  8008d1:	41                   	inc    %ecx
  8008d2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008d3:	8a 01                	mov    (%ecx),%al
  8008d5:	84 c0                	test   %al,%al
  8008d7:	74 04                	je     8008dd <strcmp+0x17>
  8008d9:	3a 02                	cmp    (%edx),%al
  8008db:	74 f4                	je     8008d1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008dd:	0f b6 c0             	movzbl %al,%eax
  8008e0:	0f b6 12             	movzbl (%edx),%edx
  8008e3:	29 d0                	sub    %edx,%eax
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	53                   	push   %ebx
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008f4:	eb 03                	jmp    8008f9 <strncmp+0x12>
		n--, p++, q++;
  8008f6:	4a                   	dec    %edx
  8008f7:	40                   	inc    %eax
  8008f8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f9:	85 d2                	test   %edx,%edx
  8008fb:	74 14                	je     800911 <strncmp+0x2a>
  8008fd:	8a 18                	mov    (%eax),%bl
  8008ff:	84 db                	test   %bl,%bl
  800901:	74 04                	je     800907 <strncmp+0x20>
  800903:	3a 19                	cmp    (%ecx),%bl
  800905:	74 ef                	je     8008f6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 00             	movzbl (%eax),%eax
  80090a:	0f b6 11             	movzbl (%ecx),%edx
  80090d:	29 d0                	sub    %edx,%eax
  80090f:	eb 05                	jmp    800916 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800922:	eb 05                	jmp    800929 <strchr+0x10>
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 0c                	je     800934 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800928:	40                   	inc    %eax
  800929:	8a 10                	mov    (%eax),%dl
  80092b:	84 d2                	test   %dl,%dl
  80092d:	75 f5                	jne    800924 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093f:	eb 05                	jmp    800946 <strfind+0x10>
		if (*s == c)
  800941:	38 ca                	cmp    %cl,%dl
  800943:	74 07                	je     80094c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800945:	40                   	inc    %eax
  800946:	8a 10                	mov    (%eax),%dl
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 f5                	jne    800941 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	57                   	push   %edi
  800952:	56                   	push   %esi
  800953:	53                   	push   %ebx
  800954:	8b 7d 08             	mov    0x8(%ebp),%edi
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095d:	85 c9                	test   %ecx,%ecx
  80095f:	74 30                	je     800991 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800961:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800967:	75 25                	jne    80098e <memset+0x40>
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	75 20                	jne    80098e <memset+0x40>
		c &= 0xFF;
  80096e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800971:	89 d3                	mov    %edx,%ebx
  800973:	c1 e3 08             	shl    $0x8,%ebx
  800976:	89 d6                	mov    %edx,%esi
  800978:	c1 e6 18             	shl    $0x18,%esi
  80097b:	89 d0                	mov    %edx,%eax
  80097d:	c1 e0 10             	shl    $0x10,%eax
  800980:	09 f0                	or     %esi,%eax
  800982:	09 d0                	or     %edx,%eax
  800984:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800986:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800989:	fc                   	cld    
  80098a:	f3 ab                	rep stos %eax,%es:(%edi)
  80098c:	eb 03                	jmp    800991 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098e:	fc                   	cld    
  80098f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800991:	89 f8                	mov    %edi,%eax
  800993:	5b                   	pop    %ebx
  800994:	5e                   	pop    %esi
  800995:	5f                   	pop    %edi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a6:	39 c6                	cmp    %eax,%esi
  8009a8:	73 34                	jae    8009de <memmove+0x46>
  8009aa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ad:	39 d0                	cmp    %edx,%eax
  8009af:	73 2d                	jae    8009de <memmove+0x46>
		s += n;
		d += n;
  8009b1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b4:	f6 c2 03             	test   $0x3,%dl
  8009b7:	75 1b                	jne    8009d4 <memmove+0x3c>
  8009b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bf:	75 13                	jne    8009d4 <memmove+0x3c>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 0e                	jne    8009d4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c6:	83 ef 04             	sub    $0x4,%edi
  8009c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009cf:	fd                   	std    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb 07                	jmp    8009db <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d4:	4f                   	dec    %edi
  8009d5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d8:	fd                   	std    
  8009d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009db:	fc                   	cld    
  8009dc:	eb 20                	jmp    8009fe <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009de:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e4:	75 13                	jne    8009f9 <memmove+0x61>
  8009e6:	a8 03                	test   $0x3,%al
  8009e8:	75 0f                	jne    8009f9 <memmove+0x61>
  8009ea:	f6 c1 03             	test   $0x3,%cl
  8009ed:	75 0a                	jne    8009f9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f2:	89 c7                	mov    %eax,%edi
  8009f4:	fc                   	cld    
  8009f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f7:	eb 05                	jmp    8009fe <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f9:	89 c7                	mov    %eax,%edi
  8009fb:	fc                   	cld    
  8009fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fe:	5e                   	pop    %esi
  8009ff:	5f                   	pop    %edi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a08:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	89 04 24             	mov    %eax,(%esp)
  800a1c:	e8 77 ff ff ff       	call   800998 <memmove>
}
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a32:	ba 00 00 00 00       	mov    $0x0,%edx
  800a37:	eb 16                	jmp    800a4f <memcmp+0x2c>
		if (*s1 != *s2)
  800a39:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a3c:	42                   	inc    %edx
  800a3d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a41:	38 c8                	cmp    %cl,%al
  800a43:	74 0a                	je     800a4f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a45:	0f b6 c0             	movzbl %al,%eax
  800a48:	0f b6 c9             	movzbl %cl,%ecx
  800a4b:	29 c8                	sub    %ecx,%eax
  800a4d:	eb 09                	jmp    800a58 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4f:	39 da                	cmp    %ebx,%edx
  800a51:	75 e6                	jne    800a39 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a66:	89 c2                	mov    %eax,%edx
  800a68:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a6b:	eb 05                	jmp    800a72 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6d:	38 08                	cmp    %cl,(%eax)
  800a6f:	74 05                	je     800a76 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a71:	40                   	inc    %eax
  800a72:	39 d0                	cmp    %edx,%eax
  800a74:	72 f7                	jb     800a6d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a84:	eb 01                	jmp    800a87 <strtol+0xf>
		s++;
  800a86:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a87:	8a 02                	mov    (%edx),%al
  800a89:	3c 20                	cmp    $0x20,%al
  800a8b:	74 f9                	je     800a86 <strtol+0xe>
  800a8d:	3c 09                	cmp    $0x9,%al
  800a8f:	74 f5                	je     800a86 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a91:	3c 2b                	cmp    $0x2b,%al
  800a93:	75 08                	jne    800a9d <strtol+0x25>
		s++;
  800a95:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a96:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9b:	eb 13                	jmp    800ab0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9d:	3c 2d                	cmp    $0x2d,%al
  800a9f:	75 0a                	jne    800aab <strtol+0x33>
		s++, neg = 1;
  800aa1:	8d 52 01             	lea    0x1(%edx),%edx
  800aa4:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa9:	eb 05                	jmp    800ab0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab0:	85 db                	test   %ebx,%ebx
  800ab2:	74 05                	je     800ab9 <strtol+0x41>
  800ab4:	83 fb 10             	cmp    $0x10,%ebx
  800ab7:	75 28                	jne    800ae1 <strtol+0x69>
  800ab9:	8a 02                	mov    (%edx),%al
  800abb:	3c 30                	cmp    $0x30,%al
  800abd:	75 10                	jne    800acf <strtol+0x57>
  800abf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac3:	75 0a                	jne    800acf <strtol+0x57>
		s += 2, base = 16;
  800ac5:	83 c2 02             	add    $0x2,%edx
  800ac8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acd:	eb 12                	jmp    800ae1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800acf:	85 db                	test   %ebx,%ebx
  800ad1:	75 0e                	jne    800ae1 <strtol+0x69>
  800ad3:	3c 30                	cmp    $0x30,%al
  800ad5:	75 05                	jne    800adc <strtol+0x64>
		s++, base = 8;
  800ad7:	42                   	inc    %edx
  800ad8:	b3 08                	mov    $0x8,%bl
  800ada:	eb 05                	jmp    800ae1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800adc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae8:	8a 0a                	mov    (%edx),%cl
  800aea:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aed:	80 fb 09             	cmp    $0x9,%bl
  800af0:	77 08                	ja     800afa <strtol+0x82>
			dig = *s - '0';
  800af2:	0f be c9             	movsbl %cl,%ecx
  800af5:	83 e9 30             	sub    $0x30,%ecx
  800af8:	eb 1e                	jmp    800b18 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800afa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 08                	ja     800b0a <strtol+0x92>
			dig = *s - 'a' + 10;
  800b02:	0f be c9             	movsbl %cl,%ecx
  800b05:	83 e9 57             	sub    $0x57,%ecx
  800b08:	eb 0e                	jmp    800b18 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b0a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b0d:	80 fb 19             	cmp    $0x19,%bl
  800b10:	77 12                	ja     800b24 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b12:	0f be c9             	movsbl %cl,%ecx
  800b15:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b18:	39 f1                	cmp    %esi,%ecx
  800b1a:	7d 0c                	jge    800b28 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b1c:	42                   	inc    %edx
  800b1d:	0f af c6             	imul   %esi,%eax
  800b20:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b22:	eb c4                	jmp    800ae8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b24:	89 c1                	mov    %eax,%ecx
  800b26:	eb 02                	jmp    800b2a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b28:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2e:	74 05                	je     800b35 <strtol+0xbd>
		*endptr = (char *) s;
  800b30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b33:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b35:	85 ff                	test   %edi,%edi
  800b37:	74 04                	je     800b3d <strtol+0xc5>
  800b39:	89 c8                	mov    %ecx,%eax
  800b3b:	f7 d8                	neg    %eax
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    
	...

00800b44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	89 c6                	mov    %eax,%esi
  800b5b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	89 cb                	mov    %ecx,%ebx
  800b99:	89 cf                	mov    %ecx,%edi
  800b9b:	89 ce                	mov    %ecx,%esi
  800b9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 28                	jle    800bcb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bae:	00 
  800baf:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800bb6:	00 
  800bb7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bbe:	00 
  800bbf:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800bc6:	e8 b1 f5 ff ff       	call   80017c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcb:	83 c4 2c             	add    $0x2c,%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bde:	b8 02 00 00 00       	mov    $0x2,%eax
  800be3:	89 d1                	mov    %edx,%ecx
  800be5:	89 d3                	mov    %edx,%ebx
  800be7:	89 d7                	mov    %edx,%edi
  800be9:	89 d6                	mov    %edx,%esi
  800beb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_yield>:

void
sys_yield(void)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c02:	89 d1                	mov    %edx,%ecx
  800c04:	89 d3                	mov    %edx,%ebx
  800c06:	89 d7                	mov    %edx,%edi
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	be 00 00 00 00       	mov    $0x0,%esi
  800c1f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	89 f7                	mov    %esi,%edi
  800c2f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7e 28                	jle    800c5d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c39:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c40:	00 
  800c41:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800c48:	00 
  800c49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c50:	00 
  800c51:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800c58:	e8 1f f5 ff ff       	call   80017c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5d:	83 c4 2c             	add    $0x2c,%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c73:	8b 75 18             	mov    0x18(%ebp),%esi
  800c76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 28                	jle    800cb0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c93:	00 
  800c94:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800c9b:	00 
  800c9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca3:	00 
  800ca4:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800cab:	e8 cc f4 ff ff       	call   80017c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb0:	83 c4 2c             	add    $0x2c,%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 28                	jle    800d03 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800cee:	00 
  800cef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf6:	00 
  800cf7:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800cfe:	e8 79 f4 ff ff       	call   80017c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d03:	83 c4 2c             	add    $0x2c,%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d19:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 df                	mov    %ebx,%edi
  800d26:	89 de                	mov    %ebx,%esi
  800d28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 28                	jle    800d56 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d32:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d39:	00 
  800d3a:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800d41:	00 
  800d42:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d49:	00 
  800d4a:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800d51:	e8 26 f4 ff ff       	call   80017c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d56:	83 c4 2c             	add    $0x2c,%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 28                	jle    800da9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d85:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d8c:	00 
  800d8d:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800d94:	00 
  800d95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9c:	00 
  800d9d:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800da4:	e8 d3 f3 ff ff       	call   80017c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da9:	83 c4 2c             	add    $0x2c,%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	89 df                	mov    %ebx,%edi
  800dcc:	89 de                	mov    %ebx,%esi
  800dce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7e 28                	jle    800dfc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ddf:	00 
  800de0:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800de7:	00 
  800de8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800def:	00 
  800df0:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800df7:	e8 80 f3 ff ff       	call   80017c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dfc:	83 c4 2c             	add    $0x2c,%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	57                   	push   %edi
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	be 00 00 00 00       	mov    $0x0,%esi
  800e0f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	57                   	push   %edi
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e35:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	89 cb                	mov    %ecx,%ebx
  800e3f:	89 cf                	mov    %ecx,%edi
  800e41:	89 ce                	mov    %ecx,%esi
  800e43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e45:	85 c0                	test   %eax,%eax
  800e47:	7e 28                	jle    800e71 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e54:	00 
  800e55:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e64:	00 
  800e65:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800e6c:	e8 0b f3 ff ff       	call   80017c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e71:	83 c4 2c             	add    $0x2c,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
  800e79:	00 00                	add    %al,(%eax)
	...

00800e7c <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	57                   	push   %edi
  800e80:	56                   	push   %esi
  800e81:	53                   	push   %ebx
  800e82:	83 ec 3c             	sub    $0x3c,%esp
  800e85:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800e88:	89 d6                	mov    %edx,%esi
  800e8a:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800e8d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e94:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800e97:	e8 37 fd ff ff       	call   800bd3 <sys_getenvid>
  800e9c:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800e9e:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800ea5:	74 31                	je     800ed8 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800ea7:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800eae:	00 
  800eaf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eb6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eba:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ebe:	89 3c 24             	mov    %edi,(%esp)
  800ec1:	e8 9f fd ff ff       	call   800c65 <sys_page_map>
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	0f 8e ae 00 00 00    	jle    800f7c <duppage+0x100>
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	e9 a4 00 00 00       	jmp    800f7c <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800edb:	25 02 08 00 00       	and    $0x802,%eax
  800ee0:	83 f8 01             	cmp    $0x1,%eax
  800ee3:	19 db                	sbb    %ebx,%ebx
  800ee5:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800eeb:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800ef1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800ef5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800efc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f00:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f04:	89 3c 24             	mov    %edi,(%esp)
  800f07:	e8 59 fd ff ff       	call   800c65 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	79 1c                	jns    800f2c <duppage+0xb0>
  800f10:	c7 44 24 08 ea 29 80 	movl   $0x8029ea,0x8(%esp)
  800f17:	00 
  800f18:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800f1f:	00 
  800f20:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  800f27:	e8 50 f2 ff ff       	call   80017c <_panic>
	if ((perm|~pte)&PTE_COW){
  800f2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f2f:	f7 d0                	not    %eax
  800f31:	09 d8                	or     %ebx,%eax
  800f33:	f6 c4 08             	test   $0x8,%ah
  800f36:	74 38                	je     800f70 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  800f38:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800f3c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f40:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	89 3c 24             	mov    %edi,(%esp)
  800f4b:	e8 15 fd ff ff       	call   800c65 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  800f50:	85 c0                	test   %eax,%eax
  800f52:	79 23                	jns    800f77 <duppage+0xfb>
  800f54:	c7 44 24 08 ea 29 80 	movl   $0x8029ea,0x8(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800f63:	00 
  800f64:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  800f6b:	e8 0c f2 ff ff       	call   80017c <_panic>
	}
	return 0;
  800f70:	b8 00 00 00 00       	mov    $0x0,%eax
  800f75:	eb 05                	jmp    800f7c <duppage+0x100>
  800f77:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  800f7c:	83 c4 3c             	add    $0x3c,%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 20             	sub    $0x20,%esp
  800f8c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f8f:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  800f91:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f95:	75 1c                	jne    800fb3 <pgfault+0x2f>
		panic("pgfault: error!\n");
  800f97:	c7 44 24 08 06 2a 80 	movl   $0x802a06,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  800fae:	e8 c9 f1 ff ff       	call   80017c <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  800fb3:	89 f0                	mov    %esi,%eax
  800fb5:	c1 e8 0c             	shr    $0xc,%eax
  800fb8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fbf:	f6 c4 08             	test   $0x8,%ah
  800fc2:	75 1c                	jne    800fe0 <pgfault+0x5c>
		panic("pgfault: error!\n");
  800fc4:	c7 44 24 08 06 2a 80 	movl   $0x802a06,0x8(%esp)
  800fcb:	00 
  800fcc:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800fd3:	00 
  800fd4:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  800fdb:	e8 9c f1 ff ff       	call   80017c <_panic>
	envid_t envid = sys_getenvid();
  800fe0:	e8 ee fb ff ff       	call   800bd3 <sys_getenvid>
  800fe5:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  800fe7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fee:	00 
  800fef:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ff6:	00 
  800ff7:	89 04 24             	mov    %eax,(%esp)
  800ffa:	e8 12 fc ff ff       	call   800c11 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  800fff:	85 c0                	test   %eax,%eax
  801001:	79 1c                	jns    80101f <pgfault+0x9b>
  801003:	c7 44 24 08 06 2a 80 	movl   $0x802a06,0x8(%esp)
  80100a:	00 
  80100b:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801012:	00 
  801013:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  80101a:	e8 5d f1 ff ff       	call   80017c <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  80101f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  801025:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80102c:	00 
  80102d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801031:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801038:	e8 c5 f9 ff ff       	call   800a02 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  80103d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801044:	00 
  801045:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80104d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801054:	00 
  801055:	89 1c 24             	mov    %ebx,(%esp)
  801058:	e8 08 fc ff ff       	call   800c65 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  80105d:	85 c0                	test   %eax,%eax
  80105f:	79 1c                	jns    80107d <pgfault+0xf9>
  801061:	c7 44 24 08 06 2a 80 	movl   $0x802a06,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  801078:	e8 ff f0 ff ff       	call   80017c <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  80107d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801084:	00 
  801085:	89 1c 24             	mov    %ebx,(%esp)
  801088:	e8 2b fc ff ff       	call   800cb8 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 1c                	jns    8010ad <pgfault+0x129>
  801091:	c7 44 24 08 06 2a 80 	movl   $0x802a06,0x8(%esp)
  801098:	00 
  801099:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  8010a8:	e8 cf f0 ff ff       	call   80017c <_panic>
	return;
	panic("pgfault not implemented");
}
  8010ad:	83 c4 20             	add    $0x20,%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8010bd:	c7 04 24 84 0f 80 00 	movl   $0x800f84,(%esp)
  8010c4:	e8 0b 11 00 00       	call   8021d4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010c9:	bf 07 00 00 00       	mov    $0x7,%edi
  8010ce:	89 f8                	mov    %edi,%eax
  8010d0:	cd 30                	int    $0x30
  8010d2:	89 c7                	mov    %eax,%edi
  8010d4:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	79 1c                	jns    8010f6 <fork+0x42>
		panic("fork : error!\n");
  8010da:	c7 44 24 08 23 2a 80 	movl   $0x802a23,0x8(%esp)
  8010e1:	00 
  8010e2:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  8010e9:	00 
  8010ea:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  8010f1:	e8 86 f0 ff ff       	call   80017c <_panic>
	if (envid==0){
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	75 28                	jne    801122 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  8010fa:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  801100:	e8 ce fa ff ff       	call   800bd3 <sys_getenvid>
  801105:	25 ff 03 00 00       	and    $0x3ff,%eax
  80110a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801111:	c1 e0 07             	shl    $0x7,%eax
  801114:	29 d0                	sub    %edx,%eax
  801116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80111b:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  80111d:	e9 f2 00 00 00       	jmp    801214 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  801122:	e8 ac fa ff ff       	call   800bd3 <sys_getenvid>
  801127:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80112a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  80112f:	89 d8                	mov    %ebx,%eax
  801131:	c1 e8 16             	shr    $0x16,%eax
  801134:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113b:	a8 01                	test   $0x1,%al
  80113d:	74 17                	je     801156 <fork+0xa2>
  80113f:	89 da                	mov    %ebx,%edx
  801141:	c1 ea 0c             	shr    $0xc,%edx
  801144:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80114b:	a8 01                	test   $0x1,%al
  80114d:	74 07                	je     801156 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  80114f:	89 f0                	mov    %esi,%eax
  801151:	e8 26 fd ff ff       	call   800e7c <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801156:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80115c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801162:	75 cb                	jne    80112f <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801164:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80116b:	00 
  80116c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801173:	ee 
  801174:	89 3c 24             	mov    %edi,(%esp)
  801177:	e8 95 fa ff ff       	call   800c11 <sys_page_alloc>
  80117c:	85 c0                	test   %eax,%eax
  80117e:	79 1c                	jns    80119c <fork+0xe8>
  801180:	c7 44 24 08 23 2a 80 	movl   $0x802a23,0x8(%esp)
  801187:	00 
  801188:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80118f:	00 
  801190:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  801197:	e8 e0 ef ff ff       	call   80017c <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  80119c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80119f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011ab:	c1 e0 07             	shl    $0x7,%eax
  8011ae:	29 d0                	sub    %edx,%eax
  8011b0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011b5:	8b 40 64             	mov    0x64(%eax),%eax
  8011b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011bc:	89 3c 24             	mov    %edi,(%esp)
  8011bf:	e8 ed fb ff ff       	call   800db1 <sys_env_set_pgfault_upcall>
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	79 1c                	jns    8011e4 <fork+0x130>
  8011c8:	c7 44 24 08 23 2a 80 	movl   $0x802a23,0x8(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8011d7:	00 
  8011d8:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  8011df:	e8 98 ef ff ff       	call   80017c <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8011e4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011eb:	00 
  8011ec:	89 3c 24             	mov    %edi,(%esp)
  8011ef:	e8 17 fb ff ff       	call   800d0b <sys_env_set_status>
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	79 1c                	jns    801214 <fork+0x160>
  8011f8:	c7 44 24 08 23 2a 80 	movl   $0x802a23,0x8(%esp)
  8011ff:	00 
  801200:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  801207:	00 
  801208:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  80120f:	e8 68 ef ff ff       	call   80017c <_panic>
	return envid_child;
	panic("fork not implemented");
}
  801214:	89 f8                	mov    %edi,%eax
  801216:	83 c4 2c             	add    $0x2c,%esp
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5f                   	pop    %edi
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <sfork>:

// Challenge!
int
sfork(void)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	53                   	push   %ebx
  801224:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  801227:	c7 04 24 84 0f 80 00 	movl   $0x800f84,(%esp)
  80122e:	e8 a1 0f 00 00       	call   8021d4 <set_pgfault_handler>
  801233:	ba 07 00 00 00       	mov    $0x7,%edx
  801238:	89 d0                	mov    %edx,%eax
  80123a:	cd 30                	int    $0x30
  80123c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80123f:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801241:	89 44 24 04          	mov    %eax,0x4(%esp)
  801245:	c7 04 24 17 2a 80 00 	movl   $0x802a17,(%esp)
  80124c:	e8 23 f0 ff ff       	call   800274 <cprintf>
	if (envid<0)
  801251:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801255:	79 1c                	jns    801273 <sfork+0x55>
		panic("sfork : error!\n");
  801257:	c7 44 24 08 22 2a 80 	movl   $0x802a22,0x8(%esp)
  80125e:	00 
  80125f:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  801266:	00 
  801267:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  80126e:	e8 09 ef ff ff       	call   80017c <_panic>
	if (envid==0){
  801273:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801277:	75 28                	jne    8012a1 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  801279:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80127f:	e8 4f f9 ff ff       	call   800bd3 <sys_getenvid>
  801284:	25 ff 03 00 00       	and    $0x3ff,%eax
  801289:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801290:	c1 e0 07             	shl    $0x7,%eax
  801293:	29 d0                	sub    %edx,%eax
  801295:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80129a:	89 03                	mov    %eax,(%ebx)
		return envid;
  80129c:	e9 18 01 00 00       	jmp    8013b9 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  8012a1:	e8 2d f9 ff ff       	call   800bd3 <sys_getenvid>
  8012a6:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8012a8:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8012ad:	89 d8                	mov    %ebx,%eax
  8012af:	c1 e8 16             	shr    $0x16,%eax
  8012b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012b9:	a8 01                	test   $0x1,%al
  8012bb:	74 2c                	je     8012e9 <sfork+0xcb>
  8012bd:	89 d8                	mov    %ebx,%eax
  8012bf:	c1 e8 0c             	shr    $0xc,%eax
  8012c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c9:	a8 01                	test   $0x1,%al
  8012cb:	74 1c                	je     8012e9 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8012cd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012d4:	00 
  8012d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012d9:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012e1:	89 3c 24             	mov    %edi,(%esp)
  8012e4:	e8 7c f9 ff ff       	call   800c65 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8012e9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012ef:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8012f5:	75 b6                	jne    8012ad <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  8012f7:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  8012fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ff:	e8 78 fb ff ff       	call   800e7c <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  801304:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80130b:	00 
  80130c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801313:	ee 
  801314:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801317:	89 04 24             	mov    %eax,(%esp)
  80131a:	e8 f2 f8 ff ff       	call   800c11 <sys_page_alloc>
  80131f:	85 c0                	test   %eax,%eax
  801321:	79 1c                	jns    80133f <sfork+0x121>
  801323:	c7 44 24 08 22 2a 80 	movl   $0x802a22,0x8(%esp)
  80132a:	00 
  80132b:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  801332:	00 
  801333:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  80133a:	e8 3d ee ff ff       	call   80017c <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  80133f:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801345:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  80134c:	c1 e7 07             	shl    $0x7,%edi
  80134f:	29 d7                	sub    %edx,%edi
  801351:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80135e:	89 04 24             	mov    %eax,(%esp)
  801361:	e8 4b fa ff ff       	call   800db1 <sys_env_set_pgfault_upcall>
  801366:	85 c0                	test   %eax,%eax
  801368:	79 1c                	jns    801386 <sfork+0x168>
  80136a:	c7 44 24 08 22 2a 80 	movl   $0x802a22,0x8(%esp)
  801371:	00 
  801372:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  801379:	00 
  80137a:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  801381:	e8 f6 ed ff ff       	call   80017c <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  801386:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80138d:	00 
  80138e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801391:	89 04 24             	mov    %eax,(%esp)
  801394:	e8 72 f9 ff ff       	call   800d0b <sys_env_set_status>
  801399:	85 c0                	test   %eax,%eax
  80139b:	79 1c                	jns    8013b9 <sfork+0x19b>
  80139d:	c7 44 24 08 22 2a 80 	movl   $0x802a22,0x8(%esp)
  8013a4:	00 
  8013a5:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8013ac:	00 
  8013ad:	c7 04 24 fb 29 80 00 	movl   $0x8029fb,(%esp)
  8013b4:	e8 c3 ed ff ff       	call   80017c <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8013b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013bc:	83 c4 3c             	add    $0x3c,%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8013cf:	c1 e8 0c             	shr    $0xc,%eax
}
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013da:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dd:	89 04 24             	mov    %eax,(%esp)
  8013e0:	e8 df ff ff ff       	call   8013c4 <fd2num>
  8013e5:	05 20 00 0d 00       	add    $0xd0020,%eax
  8013ea:	c1 e0 0c             	shl    $0xc,%eax
}
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	53                   	push   %ebx
  8013f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013f6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013fb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013fd:	89 c2                	mov    %eax,%edx
  8013ff:	c1 ea 16             	shr    $0x16,%edx
  801402:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801409:	f6 c2 01             	test   $0x1,%dl
  80140c:	74 11                	je     80141f <fd_alloc+0x30>
  80140e:	89 c2                	mov    %eax,%edx
  801410:	c1 ea 0c             	shr    $0xc,%edx
  801413:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80141a:	f6 c2 01             	test   $0x1,%dl
  80141d:	75 09                	jne    801428 <fd_alloc+0x39>
			*fd_store = fd;
  80141f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801421:	b8 00 00 00 00       	mov    $0x0,%eax
  801426:	eb 17                	jmp    80143f <fd_alloc+0x50>
  801428:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80142d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801432:	75 c7                	jne    8013fb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801434:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80143a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80143f:	5b                   	pop    %ebx
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801448:	83 f8 1f             	cmp    $0x1f,%eax
  80144b:	77 36                	ja     801483 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80144d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801452:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801455:	89 c2                	mov    %eax,%edx
  801457:	c1 ea 16             	shr    $0x16,%edx
  80145a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801461:	f6 c2 01             	test   $0x1,%dl
  801464:	74 24                	je     80148a <fd_lookup+0x48>
  801466:	89 c2                	mov    %eax,%edx
  801468:	c1 ea 0c             	shr    $0xc,%edx
  80146b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801472:	f6 c2 01             	test   $0x1,%dl
  801475:	74 1a                	je     801491 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801477:	8b 55 0c             	mov    0xc(%ebp),%edx
  80147a:	89 02                	mov    %eax,(%edx)
	return 0;
  80147c:	b8 00 00 00 00       	mov    $0x0,%eax
  801481:	eb 13                	jmp    801496 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801483:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801488:	eb 0c                	jmp    801496 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80148a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80148f:	eb 05                	jmp    801496 <fd_lookup+0x54>
  801491:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	53                   	push   %ebx
  80149c:	83 ec 14             	sub    $0x14,%esp
  80149f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8014a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014aa:	eb 0e                	jmp    8014ba <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8014ac:	39 08                	cmp    %ecx,(%eax)
  8014ae:	75 09                	jne    8014b9 <dev_lookup+0x21>
			*dev = devtab[i];
  8014b0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b7:	eb 35                	jmp    8014ee <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014b9:	42                   	inc    %edx
  8014ba:	8b 04 95 b0 2a 80 00 	mov    0x802ab0(,%edx,4),%eax
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	75 e7                	jne    8014ac <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014c5:	a1 08 40 80 00       	mov    0x804008,%eax
  8014ca:	8b 00                	mov    (%eax),%eax
  8014cc:	8b 40 48             	mov    0x48(%eax),%eax
  8014cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d7:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  8014de:	e8 91 ed ff ff       	call   800274 <cprintf>
	*dev = 0;
  8014e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014ee:	83 c4 14             	add    $0x14,%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	56                   	push   %esi
  8014f8:	53                   	push   %ebx
  8014f9:	83 ec 30             	sub    $0x30,%esp
  8014fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ff:	8a 45 0c             	mov    0xc(%ebp),%al
  801502:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801505:	89 34 24             	mov    %esi,(%esp)
  801508:	e8 b7 fe ff ff       	call   8013c4 <fd2num>
  80150d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801510:	89 54 24 04          	mov    %edx,0x4(%esp)
  801514:	89 04 24             	mov    %eax,(%esp)
  801517:	e8 26 ff ff ff       	call   801442 <fd_lookup>
  80151c:	89 c3                	mov    %eax,%ebx
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 05                	js     801527 <fd_close+0x33>
	    || fd != fd2)
  801522:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801525:	74 0d                	je     801534 <fd_close+0x40>
		return (must_exist ? r : 0);
  801527:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80152b:	75 46                	jne    801573 <fd_close+0x7f>
  80152d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801532:	eb 3f                	jmp    801573 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801534:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153b:	8b 06                	mov    (%esi),%eax
  80153d:	89 04 24             	mov    %eax,(%esp)
  801540:	e8 53 ff ff ff       	call   801498 <dev_lookup>
  801545:	89 c3                	mov    %eax,%ebx
  801547:	85 c0                	test   %eax,%eax
  801549:	78 18                	js     801563 <fd_close+0x6f>
		if (dev->dev_close)
  80154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154e:	8b 40 10             	mov    0x10(%eax),%eax
  801551:	85 c0                	test   %eax,%eax
  801553:	74 09                	je     80155e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801555:	89 34 24             	mov    %esi,(%esp)
  801558:	ff d0                	call   *%eax
  80155a:	89 c3                	mov    %eax,%ebx
  80155c:	eb 05                	jmp    801563 <fd_close+0x6f>
		else
			r = 0;
  80155e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801563:	89 74 24 04          	mov    %esi,0x4(%esp)
  801567:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156e:	e8 45 f7 ff ff       	call   800cb8 <sys_page_unmap>
	return r;
}
  801573:	89 d8                	mov    %ebx,%eax
  801575:	83 c4 30             	add    $0x30,%esp
  801578:	5b                   	pop    %ebx
  801579:	5e                   	pop    %esi
  80157a:	5d                   	pop    %ebp
  80157b:	c3                   	ret    

0080157c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801582:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801585:	89 44 24 04          	mov    %eax,0x4(%esp)
  801589:	8b 45 08             	mov    0x8(%ebp),%eax
  80158c:	89 04 24             	mov    %eax,(%esp)
  80158f:	e8 ae fe ff ff       	call   801442 <fd_lookup>
  801594:	85 c0                	test   %eax,%eax
  801596:	78 13                	js     8015ab <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801598:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80159f:	00 
  8015a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a3:	89 04 24             	mov    %eax,(%esp)
  8015a6:	e8 49 ff ff ff       	call   8014f4 <fd_close>
}
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <close_all>:

void
close_all(void)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015b9:	89 1c 24             	mov    %ebx,(%esp)
  8015bc:	e8 bb ff ff ff       	call   80157c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015c1:	43                   	inc    %ebx
  8015c2:	83 fb 20             	cmp    $0x20,%ebx
  8015c5:	75 f2                	jne    8015b9 <close_all+0xc>
		close(i);
}
  8015c7:	83 c4 14             	add    $0x14,%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	57                   	push   %edi
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 4c             	sub    $0x4c,%esp
  8015d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	89 04 24             	mov    %eax,(%esp)
  8015e6:	e8 57 fe ff ff       	call   801442 <fd_lookup>
  8015eb:	89 c3                	mov    %eax,%ebx
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	0f 88 e1 00 00 00    	js     8016d6 <dup+0x109>
		return r;
	close(newfdnum);
  8015f5:	89 3c 24             	mov    %edi,(%esp)
  8015f8:	e8 7f ff ff ff       	call   80157c <close>

	newfd = INDEX2FD(newfdnum);
  8015fd:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801603:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801606:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801609:	89 04 24             	mov    %eax,(%esp)
  80160c:	e8 c3 fd ff ff       	call   8013d4 <fd2data>
  801611:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801613:	89 34 24             	mov    %esi,(%esp)
  801616:	e8 b9 fd ff ff       	call   8013d4 <fd2data>
  80161b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80161e:	89 d8                	mov    %ebx,%eax
  801620:	c1 e8 16             	shr    $0x16,%eax
  801623:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80162a:	a8 01                	test   $0x1,%al
  80162c:	74 46                	je     801674 <dup+0xa7>
  80162e:	89 d8                	mov    %ebx,%eax
  801630:	c1 e8 0c             	shr    $0xc,%eax
  801633:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80163a:	f6 c2 01             	test   $0x1,%dl
  80163d:	74 35                	je     801674 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80163f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801646:	25 07 0e 00 00       	and    $0xe07,%eax
  80164b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80164f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801652:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801656:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80165d:	00 
  80165e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801662:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801669:	e8 f7 f5 ff ff       	call   800c65 <sys_page_map>
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	85 c0                	test   %eax,%eax
  801672:	78 3b                	js     8016af <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801674:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801677:	89 c2                	mov    %eax,%edx
  801679:	c1 ea 0c             	shr    $0xc,%edx
  80167c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801683:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801689:	89 54 24 10          	mov    %edx,0x10(%esp)
  80168d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801691:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801698:	00 
  801699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a4:	e8 bc f5 ff ff       	call   800c65 <sys_page_map>
  8016a9:	89 c3                	mov    %eax,%ebx
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	79 25                	jns    8016d4 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ba:	e8 f9 f5 ff ff       	call   800cb8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016cd:	e8 e6 f5 ff ff       	call   800cb8 <sys_page_unmap>
	return r;
  8016d2:	eb 02                	jmp    8016d6 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016d4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016d6:	89 d8                	mov    %ebx,%eax
  8016d8:	83 c4 4c             	add    $0x4c,%esp
  8016db:	5b                   	pop    %ebx
  8016dc:	5e                   	pop    %esi
  8016dd:	5f                   	pop    %edi
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 24             	sub    $0x24,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f1:	89 1c 24             	mov    %ebx,(%esp)
  8016f4:	e8 49 fd ff ff       	call   801442 <fd_lookup>
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 6f                	js     80176c <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801700:	89 44 24 04          	mov    %eax,0x4(%esp)
  801704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801707:	8b 00                	mov    (%eax),%eax
  801709:	89 04 24             	mov    %eax,(%esp)
  80170c:	e8 87 fd ff ff       	call   801498 <dev_lookup>
  801711:	85 c0                	test   %eax,%eax
  801713:	78 57                	js     80176c <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801718:	8b 50 08             	mov    0x8(%eax),%edx
  80171b:	83 e2 03             	and    $0x3,%edx
  80171e:	83 fa 01             	cmp    $0x1,%edx
  801721:	75 25                	jne    801748 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801723:	a1 08 40 80 00       	mov    0x804008,%eax
  801728:	8b 00                	mov    (%eax),%eax
  80172a:	8b 40 48             	mov    0x48(%eax),%eax
  80172d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801731:	89 44 24 04          	mov    %eax,0x4(%esp)
  801735:	c7 04 24 75 2a 80 00 	movl   $0x802a75,(%esp)
  80173c:	e8 33 eb ff ff       	call   800274 <cprintf>
		return -E_INVAL;
  801741:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801746:	eb 24                	jmp    80176c <read+0x8c>
	}
	if (!dev->dev_read)
  801748:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174b:	8b 52 08             	mov    0x8(%edx),%edx
  80174e:	85 d2                	test   %edx,%edx
  801750:	74 15                	je     801767 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801752:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801755:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801759:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801760:	89 04 24             	mov    %eax,(%esp)
  801763:	ff d2                	call   *%edx
  801765:	eb 05                	jmp    80176c <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801767:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80176c:	83 c4 24             	add    $0x24,%esp
  80176f:	5b                   	pop    %ebx
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	57                   	push   %edi
  801776:	56                   	push   %esi
  801777:	53                   	push   %ebx
  801778:	83 ec 1c             	sub    $0x1c,%esp
  80177b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80177e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801781:	bb 00 00 00 00       	mov    $0x0,%ebx
  801786:	eb 23                	jmp    8017ab <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801788:	89 f0                	mov    %esi,%eax
  80178a:	29 d8                	sub    %ebx,%eax
  80178c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801790:	8b 45 0c             	mov    0xc(%ebp),%eax
  801793:	01 d8                	add    %ebx,%eax
  801795:	89 44 24 04          	mov    %eax,0x4(%esp)
  801799:	89 3c 24             	mov    %edi,(%esp)
  80179c:	e8 3f ff ff ff       	call   8016e0 <read>
		if (m < 0)
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 10                	js     8017b5 <readn+0x43>
			return m;
		if (m == 0)
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	74 0a                	je     8017b3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017a9:	01 c3                	add    %eax,%ebx
  8017ab:	39 f3                	cmp    %esi,%ebx
  8017ad:	72 d9                	jb     801788 <readn+0x16>
  8017af:	89 d8                	mov    %ebx,%eax
  8017b1:	eb 02                	jmp    8017b5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017b3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017b5:	83 c4 1c             	add    $0x1c,%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	5f                   	pop    %edi
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 24             	sub    $0x24,%esp
  8017c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ce:	89 1c 24             	mov    %ebx,(%esp)
  8017d1:	e8 6c fc ff ff       	call   801442 <fd_lookup>
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 6a                	js     801844 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e4:	8b 00                	mov    (%eax),%eax
  8017e6:	89 04 24             	mov    %eax,(%esp)
  8017e9:	e8 aa fc ff ff       	call   801498 <dev_lookup>
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 52                	js     801844 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f9:	75 25                	jne    801820 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017fb:	a1 08 40 80 00       	mov    0x804008,%eax
  801800:	8b 00                	mov    (%eax),%eax
  801802:	8b 40 48             	mov    0x48(%eax),%eax
  801805:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180d:	c7 04 24 91 2a 80 00 	movl   $0x802a91,(%esp)
  801814:	e8 5b ea ff ff       	call   800274 <cprintf>
		return -E_INVAL;
  801819:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80181e:	eb 24                	jmp    801844 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801820:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801823:	8b 52 0c             	mov    0xc(%edx),%edx
  801826:	85 d2                	test   %edx,%edx
  801828:	74 15                	je     80183f <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80182a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80182d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801831:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801834:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801838:	89 04 24             	mov    %eax,(%esp)
  80183b:	ff d2                	call   *%edx
  80183d:	eb 05                	jmp    801844 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80183f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801844:	83 c4 24             	add    $0x24,%esp
  801847:	5b                   	pop    %ebx
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <seek>:

int
seek(int fdnum, off_t offset)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801850:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801853:	89 44 24 04          	mov    %eax,0x4(%esp)
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	89 04 24             	mov    %eax,(%esp)
  80185d:	e8 e0 fb ff ff       	call   801442 <fd_lookup>
  801862:	85 c0                	test   %eax,%eax
  801864:	78 0e                	js     801874 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801866:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80186c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	53                   	push   %ebx
  80187a:	83 ec 24             	sub    $0x24,%esp
  80187d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801880:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801883:	89 44 24 04          	mov    %eax,0x4(%esp)
  801887:	89 1c 24             	mov    %ebx,(%esp)
  80188a:	e8 b3 fb ff ff       	call   801442 <fd_lookup>
  80188f:	85 c0                	test   %eax,%eax
  801891:	78 63                	js     8018f6 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801893:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801896:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189d:	8b 00                	mov    (%eax),%eax
  80189f:	89 04 24             	mov    %eax,(%esp)
  8018a2:	e8 f1 fb ff ff       	call   801498 <dev_lookup>
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 4b                	js     8018f6 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018b2:	75 25                	jne    8018d9 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018b4:	a1 08 40 80 00       	mov    0x804008,%eax
  8018b9:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018bb:	8b 40 48             	mov    0x48(%eax),%eax
  8018be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c6:	c7 04 24 54 2a 80 00 	movl   $0x802a54,(%esp)
  8018cd:	e8 a2 e9 ff ff       	call   800274 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018d7:	eb 1d                	jmp    8018f6 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8018d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018dc:	8b 52 18             	mov    0x18(%edx),%edx
  8018df:	85 d2                	test   %edx,%edx
  8018e1:	74 0e                	je     8018f1 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ea:	89 04 24             	mov    %eax,(%esp)
  8018ed:	ff d2                	call   *%edx
  8018ef:	eb 05                	jmp    8018f6 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018f6:	83 c4 24             	add    $0x24,%esp
  8018f9:	5b                   	pop    %ebx
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	53                   	push   %ebx
  801900:	83 ec 24             	sub    $0x24,%esp
  801903:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801906:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	89 04 24             	mov    %eax,(%esp)
  801913:	e8 2a fb ff ff       	call   801442 <fd_lookup>
  801918:	85 c0                	test   %eax,%eax
  80191a:	78 52                	js     80196e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80191c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801923:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801926:	8b 00                	mov    (%eax),%eax
  801928:	89 04 24             	mov    %eax,(%esp)
  80192b:	e8 68 fb ff ff       	call   801498 <dev_lookup>
  801930:	85 c0                	test   %eax,%eax
  801932:	78 3a                	js     80196e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801934:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801937:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80193b:	74 2c                	je     801969 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80193d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801940:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801947:	00 00 00 
	stat->st_isdir = 0;
  80194a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801951:	00 00 00 
	stat->st_dev = dev;
  801954:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80195a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80195e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801961:	89 14 24             	mov    %edx,(%esp)
  801964:	ff 50 14             	call   *0x14(%eax)
  801967:	eb 05                	jmp    80196e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801969:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80196e:	83 c4 24             	add    $0x24,%esp
  801971:	5b                   	pop    %ebx
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80197c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801983:	00 
  801984:	8b 45 08             	mov    0x8(%ebp),%eax
  801987:	89 04 24             	mov    %eax,(%esp)
  80198a:	e8 88 02 00 00       	call   801c17 <open>
  80198f:	89 c3                	mov    %eax,%ebx
  801991:	85 c0                	test   %eax,%eax
  801993:	78 1b                	js     8019b0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801995:	8b 45 0c             	mov    0xc(%ebp),%eax
  801998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199c:	89 1c 24             	mov    %ebx,(%esp)
  80199f:	e8 58 ff ff ff       	call   8018fc <fstat>
  8019a4:	89 c6                	mov    %eax,%esi
	close(fd);
  8019a6:	89 1c 24             	mov    %ebx,(%esp)
  8019a9:	e8 ce fb ff ff       	call   80157c <close>
	return r;
  8019ae:	89 f3                	mov    %esi,%ebx
}
  8019b0:	89 d8                	mov    %ebx,%eax
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    
  8019b9:	00 00                	add    %al,(%eax)
	...

008019bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 10             	sub    $0x10,%esp
  8019c4:	89 c3                	mov    %eax,%ebx
  8019c6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019c8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019cf:	75 11                	jne    8019e2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019d8:	e8 82 09 00 00       	call   80235f <ipc_find_env>
  8019dd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019e2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019e9:	00 
  8019ea:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019f1:	00 
  8019f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019f6:	a1 00 40 80 00       	mov    0x804000,%eax
  8019fb:	89 04 24             	mov    %eax,(%esp)
  8019fe:	e8 f6 08 00 00       	call   8022f9 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801a03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a0a:	00 
  801a0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a16:	e8 71 08 00 00       	call   80228c <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	5b                   	pop    %ebx
  801a1f:	5e                   	pop    %esi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a36:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a40:	b8 02 00 00 00       	mov    $0x2,%eax
  801a45:	e8 72 ff ff ff       	call   8019bc <fsipc>
}
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a52:	8b 45 08             	mov    0x8(%ebp),%eax
  801a55:	8b 40 0c             	mov    0xc(%eax),%eax
  801a58:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a62:	b8 06 00 00 00       	mov    $0x6,%eax
  801a67:	e8 50 ff ff ff       	call   8019bc <fsipc>
}
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	53                   	push   %ebx
  801a72:	83 ec 14             	sub    $0x14,%esp
  801a75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a78:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a83:	ba 00 00 00 00       	mov    $0x0,%edx
  801a88:	b8 05 00 00 00       	mov    $0x5,%eax
  801a8d:	e8 2a ff ff ff       	call   8019bc <fsipc>
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 2b                	js     801ac1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a96:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a9d:	00 
  801a9e:	89 1c 24             	mov    %ebx,(%esp)
  801aa1:	e8 79 ed ff ff       	call   80081f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aa6:	a1 80 50 80 00       	mov    0x805080,%eax
  801aab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ab1:	a1 84 50 80 00       	mov    0x805084,%eax
  801ab6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801abc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac1:	83 c4 14             	add    $0x14,%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    

00801ac7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	53                   	push   %ebx
  801acb:	83 ec 14             	sub    $0x14,%esp
  801ace:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801adc:	89 d8                	mov    %ebx,%eax
  801ade:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801ae4:	76 05                	jbe    801aeb <devfile_write+0x24>
  801ae6:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801aeb:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801af0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afb:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801b02:	e8 fb ee ff ff       	call   800a02 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801b07:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0c:	b8 04 00 00 00       	mov    $0x4,%eax
  801b11:	e8 a6 fe ff ff       	call   8019bc <fsipc>
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 53                	js     801b6d <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801b1a:	39 c3                	cmp    %eax,%ebx
  801b1c:	73 24                	jae    801b42 <devfile_write+0x7b>
  801b1e:	c7 44 24 0c c0 2a 80 	movl   $0x802ac0,0xc(%esp)
  801b25:	00 
  801b26:	c7 44 24 08 c7 2a 80 	movl   $0x802ac7,0x8(%esp)
  801b2d:	00 
  801b2e:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801b35:	00 
  801b36:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801b3d:	e8 3a e6 ff ff       	call   80017c <_panic>
	assert(r <= PGSIZE);
  801b42:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b47:	7e 24                	jle    801b6d <devfile_write+0xa6>
  801b49:	c7 44 24 0c e7 2a 80 	movl   $0x802ae7,0xc(%esp)
  801b50:	00 
  801b51:	c7 44 24 08 c7 2a 80 	movl   $0x802ac7,0x8(%esp)
  801b58:	00 
  801b59:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801b60:	00 
  801b61:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801b68:	e8 0f e6 ff ff       	call   80017c <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801b6d:	83 c4 14             	add    $0x14,%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	83 ec 10             	sub    $0x10,%esp
  801b7b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	8b 40 0c             	mov    0xc(%eax),%eax
  801b84:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b89:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b94:	b8 03 00 00 00       	mov    $0x3,%eax
  801b99:	e8 1e fe ff ff       	call   8019bc <fsipc>
  801b9e:	89 c3                	mov    %eax,%ebx
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	78 6a                	js     801c0e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ba4:	39 c6                	cmp    %eax,%esi
  801ba6:	73 24                	jae    801bcc <devfile_read+0x59>
  801ba8:	c7 44 24 0c c0 2a 80 	movl   $0x802ac0,0xc(%esp)
  801baf:	00 
  801bb0:	c7 44 24 08 c7 2a 80 	movl   $0x802ac7,0x8(%esp)
  801bb7:	00 
  801bb8:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801bbf:	00 
  801bc0:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801bc7:	e8 b0 e5 ff ff       	call   80017c <_panic>
	assert(r <= PGSIZE);
  801bcc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bd1:	7e 24                	jle    801bf7 <devfile_read+0x84>
  801bd3:	c7 44 24 0c e7 2a 80 	movl   $0x802ae7,0xc(%esp)
  801bda:	00 
  801bdb:	c7 44 24 08 c7 2a 80 	movl   $0x802ac7,0x8(%esp)
  801be2:	00 
  801be3:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801bea:	00 
  801beb:	c7 04 24 dc 2a 80 00 	movl   $0x802adc,(%esp)
  801bf2:	e8 85 e5 ff ff       	call   80017c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bf7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bfb:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c02:	00 
  801c03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c06:	89 04 24             	mov    %eax,(%esp)
  801c09:	e8 8a ed ff ff       	call   800998 <memmove>
	return r;
}
  801c0e:	89 d8                	mov    %ebx,%eax
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
  801c1c:	83 ec 20             	sub    $0x20,%esp
  801c1f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c22:	89 34 24             	mov    %esi,(%esp)
  801c25:	e8 c2 eb ff ff       	call   8007ec <strlen>
  801c2a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c2f:	7f 60                	jg     801c91 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c34:	89 04 24             	mov    %eax,(%esp)
  801c37:	e8 b3 f7 ff ff       	call   8013ef <fd_alloc>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 54                	js     801c96 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c42:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c46:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c4d:	e8 cd eb ff ff       	call   80081f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c55:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c5d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c62:	e8 55 fd ff ff       	call   8019bc <fsipc>
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	79 15                	jns    801c82 <open+0x6b>
		fd_close(fd, 0);
  801c6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c74:	00 
  801c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c78:	89 04 24             	mov    %eax,(%esp)
  801c7b:	e8 74 f8 ff ff       	call   8014f4 <fd_close>
		return r;
  801c80:	eb 14                	jmp    801c96 <open+0x7f>
	}

	return fd2num(fd);
  801c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c85:	89 04 24             	mov    %eax,(%esp)
  801c88:	e8 37 f7 ff ff       	call   8013c4 <fd2num>
  801c8d:	89 c3                	mov    %eax,%ebx
  801c8f:	eb 05                	jmp    801c96 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c91:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c96:	89 d8                	mov    %ebx,%eax
  801c98:	83 c4 20             	add    $0x20,%esp
  801c9b:	5b                   	pop    %ebx
  801c9c:	5e                   	pop    %esi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ca5:	ba 00 00 00 00       	mov    $0x0,%edx
  801caa:	b8 08 00 00 00       	mov    $0x8,%eax
  801caf:	e8 08 fd ff ff       	call   8019bc <fsipc>
}
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    
	...

00801cb8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	56                   	push   %esi
  801cbc:	53                   	push   %ebx
  801cbd:	83 ec 10             	sub    $0x10,%esp
  801cc0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc6:	89 04 24             	mov    %eax,(%esp)
  801cc9:	e8 06 f7 ff ff       	call   8013d4 <fd2data>
  801cce:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801cd0:	c7 44 24 04 f3 2a 80 	movl   $0x802af3,0x4(%esp)
  801cd7:	00 
  801cd8:	89 34 24             	mov    %esi,(%esp)
  801cdb:	e8 3f eb ff ff       	call   80081f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ce0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ce3:	2b 03                	sub    (%ebx),%eax
  801ce5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ceb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801cf2:	00 00 00 
	stat->st_dev = &devpipe;
  801cf5:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801cfc:	30 80 00 
	return 0;
}
  801cff:	b8 00 00 00 00       	mov    $0x0,%eax
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	53                   	push   %ebx
  801d0f:	83 ec 14             	sub    $0x14,%esp
  801d12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d19:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d20:	e8 93 ef ff ff       	call   800cb8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d25:	89 1c 24             	mov    %ebx,(%esp)
  801d28:	e8 a7 f6 ff ff       	call   8013d4 <fd2data>
  801d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d38:	e8 7b ef ff ff       	call   800cb8 <sys_page_unmap>
}
  801d3d:	83 c4 14             	add    $0x14,%esp
  801d40:	5b                   	pop    %ebx
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	57                   	push   %edi
  801d47:	56                   	push   %esi
  801d48:	53                   	push   %ebx
  801d49:	83 ec 2c             	sub    $0x2c,%esp
  801d4c:	89 c7                	mov    %eax,%edi
  801d4e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d51:	a1 08 40 80 00       	mov    0x804008,%eax
  801d56:	8b 00                	mov    (%eax),%eax
  801d58:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d5b:	89 3c 24             	mov    %edi,(%esp)
  801d5e:	e8 41 06 00 00       	call   8023a4 <pageref>
  801d63:	89 c6                	mov    %eax,%esi
  801d65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d68:	89 04 24             	mov    %eax,(%esp)
  801d6b:	e8 34 06 00 00       	call   8023a4 <pageref>
  801d70:	39 c6                	cmp    %eax,%esi
  801d72:	0f 94 c0             	sete   %al
  801d75:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d78:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801d7e:	8b 12                	mov    (%edx),%edx
  801d80:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d83:	39 cb                	cmp    %ecx,%ebx
  801d85:	75 08                	jne    801d8f <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d87:	83 c4 2c             	add    $0x2c,%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5f                   	pop    %edi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d8f:	83 f8 01             	cmp    $0x1,%eax
  801d92:	75 bd                	jne    801d51 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d94:	8b 42 58             	mov    0x58(%edx),%eax
  801d97:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d9e:	00 
  801d9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801da7:	c7 04 24 fa 2a 80 00 	movl   $0x802afa,(%esp)
  801dae:	e8 c1 e4 ff ff       	call   800274 <cprintf>
  801db3:	eb 9c                	jmp    801d51 <_pipeisclosed+0xe>

00801db5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	57                   	push   %edi
  801db9:	56                   	push   %esi
  801dba:	53                   	push   %ebx
  801dbb:	83 ec 1c             	sub    $0x1c,%esp
  801dbe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dc1:	89 34 24             	mov    %esi,(%esp)
  801dc4:	e8 0b f6 ff ff       	call   8013d4 <fd2data>
  801dc9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dcb:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd0:	eb 3c                	jmp    801e0e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dd2:	89 da                	mov    %ebx,%edx
  801dd4:	89 f0                	mov    %esi,%eax
  801dd6:	e8 68 ff ff ff       	call   801d43 <_pipeisclosed>
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	75 38                	jne    801e17 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ddf:	e8 0e ee ff ff       	call   800bf2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801de4:	8b 43 04             	mov    0x4(%ebx),%eax
  801de7:	8b 13                	mov    (%ebx),%edx
  801de9:	83 c2 20             	add    $0x20,%edx
  801dec:	39 d0                	cmp    %edx,%eax
  801dee:	73 e2                	jae    801dd2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801df0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801df6:	89 c2                	mov    %eax,%edx
  801df8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801dfe:	79 05                	jns    801e05 <devpipe_write+0x50>
  801e00:	4a                   	dec    %edx
  801e01:	83 ca e0             	or     $0xffffffe0,%edx
  801e04:	42                   	inc    %edx
  801e05:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e09:	40                   	inc    %eax
  801e0a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0d:	47                   	inc    %edi
  801e0e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e11:	75 d1                	jne    801de4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e13:	89 f8                	mov    %edi,%eax
  801e15:	eb 05                	jmp    801e1c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e17:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e1c:	83 c4 1c             	add    $0x1c,%esp
  801e1f:	5b                   	pop    %ebx
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    

00801e24 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	57                   	push   %edi
  801e28:	56                   	push   %esi
  801e29:	53                   	push   %ebx
  801e2a:	83 ec 1c             	sub    $0x1c,%esp
  801e2d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e30:	89 3c 24             	mov    %edi,(%esp)
  801e33:	e8 9c f5 ff ff       	call   8013d4 <fd2data>
  801e38:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3a:	be 00 00 00 00       	mov    $0x0,%esi
  801e3f:	eb 3a                	jmp    801e7b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e41:	85 f6                	test   %esi,%esi
  801e43:	74 04                	je     801e49 <devpipe_read+0x25>
				return i;
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	eb 40                	jmp    801e89 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e49:	89 da                	mov    %ebx,%edx
  801e4b:	89 f8                	mov    %edi,%eax
  801e4d:	e8 f1 fe ff ff       	call   801d43 <_pipeisclosed>
  801e52:	85 c0                	test   %eax,%eax
  801e54:	75 2e                	jne    801e84 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e56:	e8 97 ed ff ff       	call   800bf2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e5b:	8b 03                	mov    (%ebx),%eax
  801e5d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e60:	74 df                	je     801e41 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e62:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e67:	79 05                	jns    801e6e <devpipe_read+0x4a>
  801e69:	48                   	dec    %eax
  801e6a:	83 c8 e0             	or     $0xffffffe0,%eax
  801e6d:	40                   	inc    %eax
  801e6e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e72:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e75:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e78:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e7a:	46                   	inc    %esi
  801e7b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e7e:	75 db                	jne    801e5b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e80:	89 f0                	mov    %esi,%eax
  801e82:	eb 05                	jmp    801e89 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e84:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e89:	83 c4 1c             	add    $0x1c,%esp
  801e8c:	5b                   	pop    %ebx
  801e8d:	5e                   	pop    %esi
  801e8e:	5f                   	pop    %edi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	57                   	push   %edi
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	83 ec 3c             	sub    $0x3c,%esp
  801e9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ea0:	89 04 24             	mov    %eax,(%esp)
  801ea3:	e8 47 f5 ff ff       	call   8013ef <fd_alloc>
  801ea8:	89 c3                	mov    %eax,%ebx
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	0f 88 45 01 00 00    	js     801ff7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eb9:	00 
  801eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec8:	e8 44 ed ff ff       	call   800c11 <sys_page_alloc>
  801ecd:	89 c3                	mov    %eax,%ebx
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	0f 88 20 01 00 00    	js     801ff7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ed7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801eda:	89 04 24             	mov    %eax,(%esp)
  801edd:	e8 0d f5 ff ff       	call   8013ef <fd_alloc>
  801ee2:	89 c3                	mov    %eax,%ebx
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	0f 88 f8 00 00 00    	js     801fe4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eec:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ef3:	00 
  801ef4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801efb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f02:	e8 0a ed ff ff       	call   800c11 <sys_page_alloc>
  801f07:	89 c3                	mov    %eax,%ebx
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	0f 88 d3 00 00 00    	js     801fe4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f14:	89 04 24             	mov    %eax,(%esp)
  801f17:	e8 b8 f4 ff ff       	call   8013d4 <fd2data>
  801f1c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f25:	00 
  801f26:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f31:	e8 db ec ff ff       	call   800c11 <sys_page_alloc>
  801f36:	89 c3                	mov    %eax,%ebx
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	0f 88 91 00 00 00    	js     801fd1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f40:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f43:	89 04 24             	mov    %eax,(%esp)
  801f46:	e8 89 f4 ff ff       	call   8013d4 <fd2data>
  801f4b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f52:	00 
  801f53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f5e:	00 
  801f5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f6a:	e8 f6 ec ff ff       	call   800c65 <sys_page_map>
  801f6f:	89 c3                	mov    %eax,%ebx
  801f71:	85 c0                	test   %eax,%eax
  801f73:	78 4c                	js     801fc1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f75:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f7e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f83:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f8a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f93:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f95:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f98:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fa2:	89 04 24             	mov    %eax,(%esp)
  801fa5:	e8 1a f4 ff ff       	call   8013c4 <fd2num>
  801faa:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801fac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801faf:	89 04 24             	mov    %eax,(%esp)
  801fb2:	e8 0d f4 ff ff       	call   8013c4 <fd2num>
  801fb7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801fba:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fbf:	eb 36                	jmp    801ff7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801fc1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fcc:	e8 e7 ec ff ff       	call   800cb8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fdf:	e8 d4 ec ff ff       	call   800cb8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801fe4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801feb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff2:	e8 c1 ec ff ff       	call   800cb8 <sys_page_unmap>
    err:
	return r;
}
  801ff7:	89 d8                	mov    %ebx,%eax
  801ff9:	83 c4 3c             	add    $0x3c,%esp
  801ffc:	5b                   	pop    %ebx
  801ffd:	5e                   	pop    %esi
  801ffe:	5f                   	pop    %edi
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    

00802001 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802007:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80200a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200e:	8b 45 08             	mov    0x8(%ebp),%eax
  802011:	89 04 24             	mov    %eax,(%esp)
  802014:	e8 29 f4 ff ff       	call   801442 <fd_lookup>
  802019:	85 c0                	test   %eax,%eax
  80201b:	78 15                	js     802032 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80201d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802020:	89 04 24             	mov    %eax,(%esp)
  802023:	e8 ac f3 ff ff       	call   8013d4 <fd2data>
	return _pipeisclosed(fd, p);
  802028:	89 c2                	mov    %eax,%edx
  80202a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202d:	e8 11 fd ff ff       	call   801d43 <_pipeisclosed>
}
  802032:	c9                   	leave  
  802033:	c3                   	ret    

00802034 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
  80203c:	5d                   	pop    %ebp
  80203d:	c3                   	ret    

0080203e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802044:	c7 44 24 04 12 2b 80 	movl   $0x802b12,0x4(%esp)
  80204b:	00 
  80204c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204f:	89 04 24             	mov    %eax,(%esp)
  802052:	e8 c8 e7 ff ff       	call   80081f <strcpy>
	return 0;
}
  802057:	b8 00 00 00 00       	mov    $0x0,%eax
  80205c:	c9                   	leave  
  80205d:	c3                   	ret    

0080205e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80205e:	55                   	push   %ebp
  80205f:	89 e5                	mov    %esp,%ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80206a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80206f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802075:	eb 30                	jmp    8020a7 <devcons_write+0x49>
		m = n - tot;
  802077:	8b 75 10             	mov    0x10(%ebp),%esi
  80207a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80207c:	83 fe 7f             	cmp    $0x7f,%esi
  80207f:	76 05                	jbe    802086 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802081:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802086:	89 74 24 08          	mov    %esi,0x8(%esp)
  80208a:	03 45 0c             	add    0xc(%ebp),%eax
  80208d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802091:	89 3c 24             	mov    %edi,(%esp)
  802094:	e8 ff e8 ff ff       	call   800998 <memmove>
		sys_cputs(buf, m);
  802099:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209d:	89 3c 24             	mov    %edi,(%esp)
  8020a0:	e8 9f ea ff ff       	call   800b44 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a5:	01 f3                	add    %esi,%ebx
  8020a7:	89 d8                	mov    %ebx,%eax
  8020a9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020ac:	72 c9                	jb     802077 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020ae:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    

008020b9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8020bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020c3:	75 07                	jne    8020cc <devcons_read+0x13>
  8020c5:	eb 25                	jmp    8020ec <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020c7:	e8 26 eb ff ff       	call   800bf2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020cc:	e8 91 ea ff ff       	call   800b62 <sys_cgetc>
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	74 f2                	je     8020c7 <devcons_read+0xe>
  8020d5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	78 1d                	js     8020f8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020db:	83 f8 04             	cmp    $0x4,%eax
  8020de:	74 13                	je     8020f3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8020e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e3:	88 10                	mov    %dl,(%eax)
	return 1;
  8020e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ea:	eb 0c                	jmp    8020f8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8020ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f1:	eb 05                	jmp    8020f8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020f8:	c9                   	leave  
  8020f9:	c3                   	ret    

008020fa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802100:	8b 45 08             	mov    0x8(%ebp),%eax
  802103:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802106:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80210d:	00 
  80210e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802111:	89 04 24             	mov    %eax,(%esp)
  802114:	e8 2b ea ff ff       	call   800b44 <sys_cputs>
}
  802119:	c9                   	leave  
  80211a:	c3                   	ret    

0080211b <getchar>:

int
getchar(void)
{
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802121:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802128:	00 
  802129:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80212c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802137:	e8 a4 f5 ff ff       	call   8016e0 <read>
	if (r < 0)
  80213c:	85 c0                	test   %eax,%eax
  80213e:	78 0f                	js     80214f <getchar+0x34>
		return r;
	if (r < 1)
  802140:	85 c0                	test   %eax,%eax
  802142:	7e 06                	jle    80214a <getchar+0x2f>
		return -E_EOF;
	return c;
  802144:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802148:	eb 05                	jmp    80214f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80214a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80214f:	c9                   	leave  
  802150:	c3                   	ret    

00802151 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802151:	55                   	push   %ebp
  802152:	89 e5                	mov    %esp,%ebp
  802154:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802157:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80215a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80215e:	8b 45 08             	mov    0x8(%ebp),%eax
  802161:	89 04 24             	mov    %eax,(%esp)
  802164:	e8 d9 f2 ff ff       	call   801442 <fd_lookup>
  802169:	85 c0                	test   %eax,%eax
  80216b:	78 11                	js     80217e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80216d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802170:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802176:	39 10                	cmp    %edx,(%eax)
  802178:	0f 94 c0             	sete   %al
  80217b:	0f b6 c0             	movzbl %al,%eax
}
  80217e:	c9                   	leave  
  80217f:	c3                   	ret    

00802180 <opencons>:

int
opencons(void)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802186:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802189:	89 04 24             	mov    %eax,(%esp)
  80218c:	e8 5e f2 ff ff       	call   8013ef <fd_alloc>
  802191:	85 c0                	test   %eax,%eax
  802193:	78 3c                	js     8021d1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802195:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80219c:	00 
  80219d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ab:	e8 61 ea ff ff       	call   800c11 <sys_page_alloc>
  8021b0:	85 c0                	test   %eax,%eax
  8021b2:	78 1d                	js     8021d1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021b4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021c9:	89 04 24             	mov    %eax,(%esp)
  8021cc:	e8 f3 f1 ff ff       	call   8013c4 <fd2num>
}
  8021d1:	c9                   	leave  
  8021d2:	c3                   	ret    
	...

008021d4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021d4:	55                   	push   %ebp
  8021d5:	89 e5                	mov    %esp,%ebp
  8021d7:	53                   	push   %ebx
  8021d8:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021db:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021e2:	75 6f                	jne    802253 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8021e4:	e8 ea e9 ff ff       	call   800bd3 <sys_getenvid>
  8021e9:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8021eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021f2:	00 
  8021f3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021fa:	ee 
  8021fb:	89 04 24             	mov    %eax,(%esp)
  8021fe:	e8 0e ea ff ff       	call   800c11 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  802203:	85 c0                	test   %eax,%eax
  802205:	79 1c                	jns    802223 <set_pgfault_handler+0x4f>
  802207:	c7 44 24 08 20 2b 80 	movl   $0x802b20,0x8(%esp)
  80220e:	00 
  80220f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802216:	00 
  802217:	c7 04 24 7c 2b 80 00 	movl   $0x802b7c,(%esp)
  80221e:	e8 59 df ff ff       	call   80017c <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  802223:	c7 44 24 04 64 22 80 	movl   $0x802264,0x4(%esp)
  80222a:	00 
  80222b:	89 1c 24             	mov    %ebx,(%esp)
  80222e:	e8 7e eb ff ff       	call   800db1 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  802233:	85 c0                	test   %eax,%eax
  802235:	79 1c                	jns    802253 <set_pgfault_handler+0x7f>
  802237:	c7 44 24 08 48 2b 80 	movl   $0x802b48,0x8(%esp)
  80223e:	00 
  80223f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  802246:	00 
  802247:	c7 04 24 7c 2b 80 00 	movl   $0x802b7c,(%esp)
  80224e:	e8 29 df ff ff       	call   80017c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802253:	8b 45 08             	mov    0x8(%ebp),%eax
  802256:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80225b:	83 c4 14             	add    $0x14,%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    
  802261:	00 00                	add    %al,(%eax)
	...

00802264 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802264:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802265:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80226a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80226c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  80226f:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  802273:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  802278:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  80227c:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  80227e:	83 c4 08             	add    $0x8,%esp
	popal
  802281:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  802282:	83 c4 04             	add    $0x4,%esp
	popfl
  802285:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  802286:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802289:	c3                   	ret    
	...

0080228c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	56                   	push   %esi
  802290:	53                   	push   %ebx
  802291:	83 ec 10             	sub    $0x10,%esp
  802294:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802297:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80229d:	85 c0                	test   %eax,%eax
  80229f:	75 05                	jne    8022a6 <ipc_recv+0x1a>
  8022a1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  8022a6:	89 04 24             	mov    %eax,(%esp)
  8022a9:	e8 79 eb ff ff       	call   800e27 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	79 16                	jns    8022c8 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  8022b2:	85 db                	test   %ebx,%ebx
  8022b4:	74 06                	je     8022bc <ipc_recv+0x30>
  8022b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  8022bc:	85 f6                	test   %esi,%esi
  8022be:	74 32                	je     8022f2 <ipc_recv+0x66>
  8022c0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8022c6:	eb 2a                	jmp    8022f2 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8022c8:	85 db                	test   %ebx,%ebx
  8022ca:	74 0c                	je     8022d8 <ipc_recv+0x4c>
  8022cc:	a1 08 40 80 00       	mov    0x804008,%eax
  8022d1:	8b 00                	mov    (%eax),%eax
  8022d3:	8b 40 74             	mov    0x74(%eax),%eax
  8022d6:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8022d8:	85 f6                	test   %esi,%esi
  8022da:	74 0c                	je     8022e8 <ipc_recv+0x5c>
  8022dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8022e1:	8b 00                	mov    (%eax),%eax
  8022e3:	8b 40 78             	mov    0x78(%eax),%eax
  8022e6:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  8022e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8022ed:	8b 00                	mov    (%eax),%eax
  8022ef:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8022f2:	83 c4 10             	add    $0x10,%esp
  8022f5:	5b                   	pop    %ebx
  8022f6:	5e                   	pop    %esi
  8022f7:	5d                   	pop    %ebp
  8022f8:	c3                   	ret    

008022f9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022f9:	55                   	push   %ebp
  8022fa:	89 e5                	mov    %esp,%ebp
  8022fc:	57                   	push   %edi
  8022fd:	56                   	push   %esi
  8022fe:	53                   	push   %ebx
  8022ff:	83 ec 1c             	sub    $0x1c,%esp
  802302:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802305:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802308:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80230b:	85 db                	test   %ebx,%ebx
  80230d:	75 05                	jne    802314 <ipc_send+0x1b>
  80230f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  802314:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802318:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802320:	8b 45 08             	mov    0x8(%ebp),%eax
  802323:	89 04 24             	mov    %eax,(%esp)
  802326:	e8 d9 ea ff ff       	call   800e04 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  80232b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80232e:	75 07                	jne    802337 <ipc_send+0x3e>
  802330:	e8 bd e8 ff ff       	call   800bf2 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  802335:	eb dd                	jmp    802314 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  802337:	85 c0                	test   %eax,%eax
  802339:	79 1c                	jns    802357 <ipc_send+0x5e>
  80233b:	c7 44 24 08 8a 2b 80 	movl   $0x802b8a,0x8(%esp)
  802342:	00 
  802343:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80234a:	00 
  80234b:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  802352:	e8 25 de ff ff       	call   80017c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  802357:	83 c4 1c             	add    $0x1c,%esp
  80235a:	5b                   	pop    %ebx
  80235b:	5e                   	pop    %esi
  80235c:	5f                   	pop    %edi
  80235d:	5d                   	pop    %ebp
  80235e:	c3                   	ret    

0080235f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80235f:	55                   	push   %ebp
  802360:	89 e5                	mov    %esp,%ebp
  802362:	53                   	push   %ebx
  802363:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802366:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80236b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802372:	89 c2                	mov    %eax,%edx
  802374:	c1 e2 07             	shl    $0x7,%edx
  802377:	29 ca                	sub    %ecx,%edx
  802379:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80237f:	8b 52 50             	mov    0x50(%edx),%edx
  802382:	39 da                	cmp    %ebx,%edx
  802384:	75 0f                	jne    802395 <ipc_find_env+0x36>
			return envs[i].env_id;
  802386:	c1 e0 07             	shl    $0x7,%eax
  802389:	29 c8                	sub    %ecx,%eax
  80238b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802390:	8b 40 40             	mov    0x40(%eax),%eax
  802393:	eb 0c                	jmp    8023a1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802395:	40                   	inc    %eax
  802396:	3d 00 04 00 00       	cmp    $0x400,%eax
  80239b:	75 ce                	jne    80236b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80239d:	66 b8 00 00          	mov    $0x0,%ax
}
  8023a1:	5b                   	pop    %ebx
  8023a2:	5d                   	pop    %ebp
  8023a3:	c3                   	ret    

008023a4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023a4:	55                   	push   %ebp
  8023a5:	89 e5                	mov    %esp,%ebp
  8023a7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  8023aa:	89 c2                	mov    %eax,%edx
  8023ac:	c1 ea 16             	shr    $0x16,%edx
  8023af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023b6:	f6 c2 01             	test   $0x1,%dl
  8023b9:	74 1e                	je     8023d9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023bb:	c1 e8 0c             	shr    $0xc,%eax
  8023be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023c5:	a8 01                	test   $0x1,%al
  8023c7:	74 17                	je     8023e0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023c9:	c1 e8 0c             	shr    $0xc,%eax
  8023cc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023d3:	ef 
  8023d4:	0f b7 c0             	movzwl %ax,%eax
  8023d7:	eb 0c                	jmp    8023e5 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023de:	eb 05                	jmp    8023e5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023e0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023e5:	5d                   	pop    %ebp
  8023e6:	c3                   	ret    
	...

008023e8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8023e8:	55                   	push   %ebp
  8023e9:	57                   	push   %edi
  8023ea:	56                   	push   %esi
  8023eb:	83 ec 10             	sub    $0x10,%esp
  8023ee:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023fa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8023fe:	89 cd                	mov    %ecx,%ebp
  802400:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802404:	85 c0                	test   %eax,%eax
  802406:	75 2c                	jne    802434 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802408:	39 f9                	cmp    %edi,%ecx
  80240a:	77 68                	ja     802474 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80240c:	85 c9                	test   %ecx,%ecx
  80240e:	75 0b                	jne    80241b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802410:	b8 01 00 00 00       	mov    $0x1,%eax
  802415:	31 d2                	xor    %edx,%edx
  802417:	f7 f1                	div    %ecx
  802419:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	89 f8                	mov    %edi,%eax
  80241f:	f7 f1                	div    %ecx
  802421:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802423:	89 f0                	mov    %esi,%eax
  802425:	f7 f1                	div    %ecx
  802427:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802429:	89 f0                	mov    %esi,%eax
  80242b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80242d:	83 c4 10             	add    $0x10,%esp
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802434:	39 f8                	cmp    %edi,%eax
  802436:	77 2c                	ja     802464 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802438:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80243b:	83 f6 1f             	xor    $0x1f,%esi
  80243e:	75 4c                	jne    80248c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802440:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802442:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802447:	72 0a                	jb     802453 <__udivdi3+0x6b>
  802449:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80244d:	0f 87 ad 00 00 00    	ja     802500 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802453:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802458:	89 f0                	mov    %esi,%eax
  80245a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80245c:	83 c4 10             	add    $0x10,%esp
  80245f:	5e                   	pop    %esi
  802460:	5f                   	pop    %edi
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    
  802463:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802464:	31 ff                	xor    %edi,%edi
  802466:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802468:	89 f0                	mov    %esi,%eax
  80246a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80246c:	83 c4 10             	add    $0x10,%esp
  80246f:	5e                   	pop    %esi
  802470:	5f                   	pop    %edi
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    
  802473:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802474:	89 fa                	mov    %edi,%edx
  802476:	89 f0                	mov    %esi,%eax
  802478:	f7 f1                	div    %ecx
  80247a:	89 c6                	mov    %eax,%esi
  80247c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80247e:	89 f0                	mov    %esi,%eax
  802480:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802482:	83 c4 10             	add    $0x10,%esp
  802485:	5e                   	pop    %esi
  802486:	5f                   	pop    %edi
  802487:	5d                   	pop    %ebp
  802488:	c3                   	ret    
  802489:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80248c:	89 f1                	mov    %esi,%ecx
  80248e:	d3 e0                	shl    %cl,%eax
  802490:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802494:	b8 20 00 00 00       	mov    $0x20,%eax
  802499:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80249b:	89 ea                	mov    %ebp,%edx
  80249d:	88 c1                	mov    %al,%cl
  80249f:	d3 ea                	shr    %cl,%edx
  8024a1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8024a5:	09 ca                	or     %ecx,%edx
  8024a7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8024ab:	89 f1                	mov    %esi,%ecx
  8024ad:	d3 e5                	shl    %cl,%ebp
  8024af:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8024b3:	89 fd                	mov    %edi,%ebp
  8024b5:	88 c1                	mov    %al,%cl
  8024b7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8024b9:	89 fa                	mov    %edi,%edx
  8024bb:	89 f1                	mov    %esi,%ecx
  8024bd:	d3 e2                	shl    %cl,%edx
  8024bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024c3:	88 c1                	mov    %al,%cl
  8024c5:	d3 ef                	shr    %cl,%edi
  8024c7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024c9:	89 f8                	mov    %edi,%eax
  8024cb:	89 ea                	mov    %ebp,%edx
  8024cd:	f7 74 24 08          	divl   0x8(%esp)
  8024d1:	89 d1                	mov    %edx,%ecx
  8024d3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8024d5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024d9:	39 d1                	cmp    %edx,%ecx
  8024db:	72 17                	jb     8024f4 <__udivdi3+0x10c>
  8024dd:	74 09                	je     8024e8 <__udivdi3+0x100>
  8024df:	89 fe                	mov    %edi,%esi
  8024e1:	31 ff                	xor    %edi,%edi
  8024e3:	e9 41 ff ff ff       	jmp    802429 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8024e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024ec:	89 f1                	mov    %esi,%ecx
  8024ee:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024f0:	39 c2                	cmp    %eax,%edx
  8024f2:	73 eb                	jae    8024df <__udivdi3+0xf7>
		{
		  q0--;
  8024f4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024f7:	31 ff                	xor    %edi,%edi
  8024f9:	e9 2b ff ff ff       	jmp    802429 <__udivdi3+0x41>
  8024fe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802500:	31 f6                	xor    %esi,%esi
  802502:	e9 22 ff ff ff       	jmp    802429 <__udivdi3+0x41>
	...

00802508 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802508:	55                   	push   %ebp
  802509:	57                   	push   %edi
  80250a:	56                   	push   %esi
  80250b:	83 ec 20             	sub    $0x20,%esp
  80250e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802512:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802516:	89 44 24 14          	mov    %eax,0x14(%esp)
  80251a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80251e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802522:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802526:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802528:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80252a:	85 ed                	test   %ebp,%ebp
  80252c:	75 16                	jne    802544 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80252e:	39 f1                	cmp    %esi,%ecx
  802530:	0f 86 a6 00 00 00    	jbe    8025dc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802536:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802538:	89 d0                	mov    %edx,%eax
  80253a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80253c:	83 c4 20             	add    $0x20,%esp
  80253f:	5e                   	pop    %esi
  802540:	5f                   	pop    %edi
  802541:	5d                   	pop    %ebp
  802542:	c3                   	ret    
  802543:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802544:	39 f5                	cmp    %esi,%ebp
  802546:	0f 87 ac 00 00 00    	ja     8025f8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80254c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80254f:	83 f0 1f             	xor    $0x1f,%eax
  802552:	89 44 24 10          	mov    %eax,0x10(%esp)
  802556:	0f 84 a8 00 00 00    	je     802604 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80255c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802560:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802562:	bf 20 00 00 00       	mov    $0x20,%edi
  802567:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80256b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80256f:	89 f9                	mov    %edi,%ecx
  802571:	d3 e8                	shr    %cl,%eax
  802573:	09 e8                	or     %ebp,%eax
  802575:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802579:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80257d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802581:	d3 e0                	shl    %cl,%eax
  802583:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802587:	89 f2                	mov    %esi,%edx
  802589:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80258b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80258f:	d3 e0                	shl    %cl,%eax
  802591:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802595:	8b 44 24 14          	mov    0x14(%esp),%eax
  802599:	89 f9                	mov    %edi,%ecx
  80259b:	d3 e8                	shr    %cl,%eax
  80259d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80259f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025a1:	89 f2                	mov    %esi,%edx
  8025a3:	f7 74 24 18          	divl   0x18(%esp)
  8025a7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8025a9:	f7 64 24 0c          	mull   0xc(%esp)
  8025ad:	89 c5                	mov    %eax,%ebp
  8025af:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025b1:	39 d6                	cmp    %edx,%esi
  8025b3:	72 67                	jb     80261c <__umoddi3+0x114>
  8025b5:	74 75                	je     80262c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8025b7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025bb:	29 e8                	sub    %ebp,%eax
  8025bd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8025bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025c3:	d3 e8                	shr    %cl,%eax
  8025c5:	89 f2                	mov    %esi,%edx
  8025c7:	89 f9                	mov    %edi,%ecx
  8025c9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8025cb:	09 d0                	or     %edx,%eax
  8025cd:	89 f2                	mov    %esi,%edx
  8025cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025d3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025d5:	83 c4 20             	add    $0x20,%esp
  8025d8:	5e                   	pop    %esi
  8025d9:	5f                   	pop    %edi
  8025da:	5d                   	pop    %ebp
  8025db:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025dc:	85 c9                	test   %ecx,%ecx
  8025de:	75 0b                	jne    8025eb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e5:	31 d2                	xor    %edx,%edx
  8025e7:	f7 f1                	div    %ecx
  8025e9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025eb:	89 f0                	mov    %esi,%eax
  8025ed:	31 d2                	xor    %edx,%edx
  8025ef:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025f1:	89 f8                	mov    %edi,%eax
  8025f3:	e9 3e ff ff ff       	jmp    802536 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025f8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025fa:	83 c4 20             	add    $0x20,%esp
  8025fd:	5e                   	pop    %esi
  8025fe:	5f                   	pop    %edi
  8025ff:	5d                   	pop    %ebp
  802600:	c3                   	ret    
  802601:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802604:	39 f5                	cmp    %esi,%ebp
  802606:	72 04                	jb     80260c <__umoddi3+0x104>
  802608:	39 f9                	cmp    %edi,%ecx
  80260a:	77 06                	ja     802612 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80260c:	89 f2                	mov    %esi,%edx
  80260e:	29 cf                	sub    %ecx,%edi
  802610:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802612:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802614:	83 c4 20             	add    $0x20,%esp
  802617:	5e                   	pop    %esi
  802618:	5f                   	pop    %edi
  802619:	5d                   	pop    %ebp
  80261a:	c3                   	ret    
  80261b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80261c:	89 d1                	mov    %edx,%ecx
  80261e:	89 c5                	mov    %eax,%ebp
  802620:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802624:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802628:	eb 8d                	jmp    8025b7 <__umoddi3+0xaf>
  80262a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80262c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802630:	72 ea                	jb     80261c <__umoddi3+0x114>
  802632:	89 f1                	mov    %esi,%ecx
  802634:	eb 81                	jmp    8025b7 <__umoddi3+0xaf>
