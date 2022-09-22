
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 ab 01 00 00       	call   8001dc <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003d:	c7 04 24 20 27 80 00 	movl   $0x802720,(%esp)
  800044:	e8 ff 02 00 00       	call   800348 <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 11 1f 00 00       	call   801f65 <pipe>
  800054:	85 c0                	test   %eax,%eax
  800056:	79 20                	jns    800078 <umain+0x44>
		panic("pipe: %e", r);
  800058:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005c:	c7 44 24 08 6e 27 80 	movl   $0x80276e,0x8(%esp)
  800063:	00 
  800064:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006b:	00 
  80006c:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  800073:	e8 d8 01 00 00       	call   800250 <_panic>
	if ((r = fork()) < 0)
  800078:	e8 0b 11 00 00       	call   801188 <fork>
  80007d:	89 c7                	mov    %eax,%edi
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 20                	jns    8000a3 <umain+0x6f>
		panic("fork: %e", r);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 8c 27 80 	movl   $0x80278c,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  80009e:	e8 ad 01 00 00       	call   800250 <_panic>
	if (r == 0) {
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 5d                	jne    800104 <umain+0xd0>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000aa:	89 04 24             	mov    %eax,(%esp)
  8000ad:	e8 9e 15 00 00       	call   801650 <close>
		for (i = 0; i < 200; i++) {
  8000b2:	be 00 00 00 00       	mov    $0x0,%esi
			if (i % 10 == 0)
  8000b7:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8000bc:	89 f0                	mov    %esi,%eax
  8000be:	99                   	cltd   
  8000bf:	f7 fb                	idiv   %ebx
  8000c1:	85 d2                	test   %edx,%edx
  8000c3:	75 10                	jne    8000d5 <umain+0xa1>
				cprintf("%d.", i);
  8000c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c9:	c7 04 24 95 27 80 00 	movl   $0x802795,(%esp)
  8000d0:	e8 73 02 00 00       	call   800348 <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000dc:	89 04 24             	mov    %eax,(%esp)
  8000df:	e8 bd 15 00 00       	call   8016a1 <dup>
			sys_yield();
  8000e4:	e8 dd 0b 00 00       	call   800cc6 <sys_yield>
			close(10);
  8000e9:	89 1c 24             	mov    %ebx,(%esp)
  8000ec:	e8 5f 15 00 00       	call   801650 <close>
			sys_yield();
  8000f1:	e8 d0 0b 00 00       	call   800cc6 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000f6:	46                   	inc    %esi
  8000f7:	81 fe c8 00 00 00    	cmp    $0xc8,%esi
  8000fd:	75 bd                	jne    8000bc <umain+0x88>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000ff:	e8 30 01 00 00       	call   800234 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800104:	89 f8                	mov    %edi,%eax
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800112:	c1 e0 07             	shl    $0x7,%eax
  800115:	29 d0                	sub    %edx,%eax
  800117:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80011d:	eb 28                	jmp    800147 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  80011f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 ab 1f 00 00       	call   8020d5 <pipeisclosed>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	74 19                	je     800147 <umain+0x113>
			cprintf("\nRACE: pipe appears closed\n");
  80012e:	c7 04 24 99 27 80 00 	movl   $0x802799,(%esp)
  800135:	e8 0e 02 00 00       	call   800348 <cprintf>
			sys_env_destroy(r);
  80013a:	89 3c 24             	mov    %edi,(%esp)
  80013d:	e8 13 0b 00 00       	call   800c55 <sys_env_destroy>
			exit();
  800142:	e8 ed 00 00 00       	call   800234 <exit>
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800147:	8b 43 54             	mov    0x54(%ebx),%eax
  80014a:	83 f8 02             	cmp    $0x2,%eax
  80014d:	74 d0                	je     80011f <umain+0xeb>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  80014f:	c7 04 24 b5 27 80 00 	movl   $0x8027b5,(%esp)
  800156:	e8 ed 01 00 00       	call   800348 <cprintf>
	if (pipeisclosed(p[0]))
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 6f 1f 00 00       	call   8020d5 <pipeisclosed>
  800166:	85 c0                	test   %eax,%eax
  800168:	74 1c                	je     800186 <umain+0x152>
		panic("somehow the other end of p[0] got closed!");
  80016a:	c7 44 24 08 44 27 80 	movl   $0x802744,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  800181:	e8 ca 00 00 00       	call   800250 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800186:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 7e 13 00 00       	call   801516 <fd_lookup>
  800198:	85 c0                	test   %eax,%eax
  80019a:	79 20                	jns    8001bc <umain+0x188>
		panic("cannot look up p[0]: %e", r);
  80019c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a0:	c7 44 24 08 cb 27 80 	movl   $0x8027cb,0x8(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001af:	00 
  8001b0:	c7 04 24 77 27 80 00 	movl   $0x802777,(%esp)
  8001b7:	e8 94 00 00 00       	call   800250 <_panic>
	(void) fd2data(fd);
  8001bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 e1 12 00 00       	call   8014a8 <fd2data>
	cprintf("race didn't happen\n");
  8001c7:	c7 04 24 e3 27 80 00 	movl   $0x8027e3,(%esp)
  8001ce:	e8 75 01 00 00       	call   800348 <cprintf>
}
  8001d3:	83 c4 2c             	add    $0x2c,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    
	...

008001dc <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 20             	sub    $0x20,%esp
  8001e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8001ea:	e8 b8 0a 00 00       	call   800ca7 <sys_getenvid>
  8001ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001fb:	c1 e0 07             	shl    $0x7,%eax
  8001fe:	29 d0                	sub    %edx,%eax
  800200:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800205:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80020b:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800210:	85 f6                	test   %esi,%esi
  800212:	7e 07                	jle    80021b <libmain+0x3f>
		binaryname = argv[0];
  800214:	8b 03                	mov    (%ebx),%eax
  800216:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80021b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021f:	89 34 24             	mov    %esi,(%esp)
  800222:	e8 0d fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800227:	e8 08 00 00 00       	call   800234 <exit>
}
  80022c:	83 c4 20             	add    $0x20,%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    
	...

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80023a:	e8 42 14 00 00       	call   801681 <close_all>
	sys_env_destroy(0);
  80023f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800246:	e8 0a 0a 00 00       	call   800c55 <sys_env_destroy>
}
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    
  80024d:	00 00                	add    %al,(%eax)
	...

00800250 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
  800255:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800258:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80025b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800261:	e8 41 0a 00 00       	call   800ca7 <sys_getenvid>
  800266:	8b 55 0c             	mov    0xc(%ebp),%edx
  800269:	89 54 24 10          	mov    %edx,0x10(%esp)
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800274:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027c:	c7 04 24 04 28 80 00 	movl   $0x802804,(%esp)
  800283:	e8 c0 00 00 00       	call   800348 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800288:	89 74 24 04          	mov    %esi,0x4(%esp)
  80028c:	8b 45 10             	mov    0x10(%ebp),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	e8 50 00 00 00       	call   8002e7 <vcprintf>
	cprintf("\n");
  800297:	c7 04 24 90 2b 80 00 	movl   $0x802b90,(%esp)
  80029e:	e8 a5 00 00 00       	call   800348 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a3:	cc                   	int3   
  8002a4:	eb fd                	jmp    8002a3 <_panic+0x53>
	...

008002a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	53                   	push   %ebx
  8002ac:	83 ec 14             	sub    $0x14,%esp
  8002af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b2:	8b 03                	mov    (%ebx),%eax
  8002b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002bb:	40                   	inc    %eax
  8002bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c3:	75 19                	jne    8002de <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002cc:	00 
  8002cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	e8 40 09 00 00       	call   800c18 <sys_cputs>
		b->idx = 0;
  8002d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002de:	ff 43 04             	incl   0x4(%ebx)
}
  8002e1:	83 c4 14             	add    $0x14,%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f7:	00 00 00 
	b.cnt = 0;
  8002fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800301:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800304:	8b 45 0c             	mov    0xc(%ebp),%eax
  800307:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80030b:	8b 45 08             	mov    0x8(%ebp),%eax
  80030e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800312:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031c:	c7 04 24 a8 02 80 00 	movl   $0x8002a8,(%esp)
  800323:	e8 82 01 00 00       	call   8004aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800328:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80032e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800332:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 d8 08 00 00       	call   800c18 <sys_cputs>

	return b.cnt;
}
  800340:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800351:	89 44 24 04          	mov    %eax,0x4(%esp)
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	e8 87 ff ff ff       	call   8002e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800360:	c9                   	leave  
  800361:	c3                   	ret    
	...

00800364 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
  80036a:	83 ec 3c             	sub    $0x3c,%esp
  80036d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800370:	89 d7                	mov    %edx,%edi
  800372:	8b 45 08             	mov    0x8(%ebp),%eax
  800375:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800381:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800384:	85 c0                	test   %eax,%eax
  800386:	75 08                	jne    800390 <printnum+0x2c>
  800388:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80038e:	77 57                	ja     8003e7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800390:	89 74 24 10          	mov    %esi,0x10(%esp)
  800394:	4b                   	dec    %ebx
  800395:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800399:	8b 45 10             	mov    0x10(%ebp),%eax
  80039c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003a4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003af:	00 
  8003b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	e8 fa 20 00 00       	call   8024bc <__udivdi3>
  8003c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003ca:	89 04 24             	mov    %eax,(%esp)
  8003cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003d1:	89 fa                	mov    %edi,%edx
  8003d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003d6:	e8 89 ff ff ff       	call   800364 <printnum>
  8003db:	eb 0f                	jmp    8003ec <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e1:	89 34 24             	mov    %esi,(%esp)
  8003e4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e7:	4b                   	dec    %ebx
  8003e8:	85 db                	test   %ebx,%ebx
  8003ea:	7f f1                	jg     8003dd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800402:	00 
  800403:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800410:	e8 c7 21 00 00       	call   8025dc <__umoddi3>
  800415:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800419:	0f be 80 27 28 80 00 	movsbl 0x802827(%eax),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800426:	83 c4 3c             	add    $0x3c,%esp
  800429:	5b                   	pop    %ebx
  80042a:	5e                   	pop    %esi
  80042b:	5f                   	pop    %edi
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800431:	83 fa 01             	cmp    $0x1,%edx
  800434:	7e 0e                	jle    800444 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800436:	8b 10                	mov    (%eax),%edx
  800438:	8d 4a 08             	lea    0x8(%edx),%ecx
  80043b:	89 08                	mov    %ecx,(%eax)
  80043d:	8b 02                	mov    (%edx),%eax
  80043f:	8b 52 04             	mov    0x4(%edx),%edx
  800442:	eb 22                	jmp    800466 <getuint+0x38>
	else if (lflag)
  800444:	85 d2                	test   %edx,%edx
  800446:	74 10                	je     800458 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800448:	8b 10                	mov    (%eax),%edx
  80044a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80044d:	89 08                	mov    %ecx,(%eax)
  80044f:	8b 02                	mov    (%edx),%eax
  800451:	ba 00 00 00 00       	mov    $0x0,%edx
  800456:	eb 0e                	jmp    800466 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800458:	8b 10                	mov    (%eax),%edx
  80045a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045d:	89 08                	mov    %ecx,(%eax)
  80045f:	8b 02                	mov    (%edx),%eax
  800461:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80046e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800471:	8b 10                	mov    (%eax),%edx
  800473:	3b 50 04             	cmp    0x4(%eax),%edx
  800476:	73 08                	jae    800480 <sprintputch+0x18>
		*b->buf++ = ch;
  800478:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047b:	88 0a                	mov    %cl,(%edx)
  80047d:	42                   	inc    %edx
  80047e:	89 10                	mov    %edx,(%eax)
}
  800480:	5d                   	pop    %ebp
  800481:	c3                   	ret    

00800482 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800488:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80048b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048f:	8b 45 10             	mov    0x10(%ebp),%eax
  800492:	89 44 24 08          	mov    %eax,0x8(%esp)
  800496:	8b 45 0c             	mov    0xc(%ebp),%eax
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 02 00 00 00       	call   8004aa <vprintfmt>
	va_end(ap);
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    

008004aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	57                   	push   %edi
  8004ae:	56                   	push   %esi
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 4c             	sub    $0x4c,%esp
  8004b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b6:	8b 75 10             	mov    0x10(%ebp),%esi
  8004b9:	eb 12                	jmp    8004cd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	0f 84 6b 03 00 00    	je     80082e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c7:	89 04 24             	mov    %eax,(%esp)
  8004ca:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004cd:	0f b6 06             	movzbl (%esi),%eax
  8004d0:	46                   	inc    %esi
  8004d1:	83 f8 25             	cmp    $0x25,%eax
  8004d4:	75 e5                	jne    8004bb <vprintfmt+0x11>
  8004d6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004da:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004e1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004e6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004f2:	eb 26                	jmp    80051a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004fb:	eb 1d                	jmp    80051a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800500:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800504:	eb 14                	jmp    80051a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800509:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800510:	eb 08                	jmp    80051a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800512:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800515:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	0f b6 06             	movzbl (%esi),%eax
  80051d:	8d 56 01             	lea    0x1(%esi),%edx
  800520:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800523:	8a 16                	mov    (%esi),%dl
  800525:	83 ea 23             	sub    $0x23,%edx
  800528:	80 fa 55             	cmp    $0x55,%dl
  80052b:	0f 87 e1 02 00 00    	ja     800812 <vprintfmt+0x368>
  800531:	0f b6 d2             	movzbl %dl,%edx
  800534:	ff 24 95 60 29 80 00 	jmp    *0x802960(,%edx,4)
  80053b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800543:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800546:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80054a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80054d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800550:	83 fa 09             	cmp    $0x9,%edx
  800553:	77 2a                	ja     80057f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800555:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800556:	eb eb                	jmp    800543 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800566:	eb 17                	jmp    80057f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800568:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056c:	78 98                	js     800506 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800571:	eb a7                	jmp    80051a <vprintfmt+0x70>
  800573:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800576:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80057d:	eb 9b                	jmp    80051a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80057f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800583:	79 95                	jns    80051a <vprintfmt+0x70>
  800585:	eb 8b                	jmp    800512 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800587:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80058b:	eb 8d                	jmp    80051a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005a5:	e9 23 ff ff ff       	jmp    8004cd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	85 c0                	test   %eax,%eax
  8005b7:	79 02                	jns    8005bb <vprintfmt+0x111>
  8005b9:	f7 d8                	neg    %eax
  8005bb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005bd:	83 f8 0f             	cmp    $0xf,%eax
  8005c0:	7f 0b                	jg     8005cd <vprintfmt+0x123>
  8005c2:	8b 04 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%eax
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	75 23                	jne    8005f0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005d1:	c7 44 24 08 3f 28 80 	movl   $0x80283f,0x8(%esp)
  8005d8:	00 
  8005d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e0:	89 04 24             	mov    %eax,(%esp)
  8005e3:	e8 9a fe ff ff       	call   800482 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005eb:	e9 dd fe ff ff       	jmp    8004cd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f4:	c7 44 24 08 39 2c 80 	movl   $0x802c39,0x8(%esp)
  8005fb:	00 
  8005fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800600:	8b 55 08             	mov    0x8(%ebp),%edx
  800603:	89 14 24             	mov    %edx,(%esp)
  800606:	e8 77 fe ff ff       	call   800482 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060e:	e9 ba fe ff ff       	jmp    8004cd <vprintfmt+0x23>
  800613:	89 f9                	mov    %edi,%ecx
  800615:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800618:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 30                	mov    (%eax),%esi
  800626:	85 f6                	test   %esi,%esi
  800628:	75 05                	jne    80062f <vprintfmt+0x185>
				p = "(null)";
  80062a:	be 38 28 80 00       	mov    $0x802838,%esi
			if (width > 0 && padc != '-')
  80062f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800633:	0f 8e 84 00 00 00    	jle    8006bd <vprintfmt+0x213>
  800639:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80063d:	74 7e                	je     8006bd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80063f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800643:	89 34 24             	mov    %esi,(%esp)
  800646:	e8 8b 02 00 00       	call   8008d6 <strnlen>
  80064b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80064e:	29 c2                	sub    %eax,%edx
  800650:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800653:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800657:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80065a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80065d:	89 de                	mov    %ebx,%esi
  80065f:	89 d3                	mov    %edx,%ebx
  800661:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	eb 0b                	jmp    800670 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800665:	89 74 24 04          	mov    %esi,0x4(%esp)
  800669:	89 3c 24             	mov    %edi,(%esp)
  80066c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066f:	4b                   	dec    %ebx
  800670:	85 db                	test   %ebx,%ebx
  800672:	7f f1                	jg     800665 <vprintfmt+0x1bb>
  800674:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800677:	89 f3                	mov    %esi,%ebx
  800679:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80067c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80067f:	85 c0                	test   %eax,%eax
  800681:	79 05                	jns    800688 <vprintfmt+0x1de>
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068b:	29 c2                	sub    %eax,%edx
  80068d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800690:	eb 2b                	jmp    8006bd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800692:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800696:	74 18                	je     8006b0 <vprintfmt+0x206>
  800698:	8d 50 e0             	lea    -0x20(%eax),%edx
  80069b:	83 fa 5e             	cmp    $0x5e,%edx
  80069e:	76 10                	jbe    8006b0 <vprintfmt+0x206>
					putch('?', putdat);
  8006a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
  8006ae:	eb 0a                	jmp    8006ba <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	89 04 24             	mov    %eax,(%esp)
  8006b7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ba:	ff 4d e4             	decl   -0x1c(%ebp)
  8006bd:	0f be 06             	movsbl (%esi),%eax
  8006c0:	46                   	inc    %esi
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	74 21                	je     8006e6 <vprintfmt+0x23c>
  8006c5:	85 ff                	test   %edi,%edi
  8006c7:	78 c9                	js     800692 <vprintfmt+0x1e8>
  8006c9:	4f                   	dec    %edi
  8006ca:	79 c6                	jns    800692 <vprintfmt+0x1e8>
  8006cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cf:	89 de                	mov    %ebx,%esi
  8006d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006d4:	eb 18                	jmp    8006ee <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006da:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006e1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e3:	4b                   	dec    %ebx
  8006e4:	eb 08                	jmp    8006ee <vprintfmt+0x244>
  8006e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e9:	89 de                	mov    %ebx,%esi
  8006eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ee:	85 db                	test   %ebx,%ebx
  8006f0:	7f e4                	jg     8006d6 <vprintfmt+0x22c>
  8006f2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006f5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006fa:	e9 ce fd ff ff       	jmp    8004cd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ff:	83 f9 01             	cmp    $0x1,%ecx
  800702:	7e 10                	jle    800714 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8d 50 08             	lea    0x8(%eax),%edx
  80070a:	89 55 14             	mov    %edx,0x14(%ebp)
  80070d:	8b 30                	mov    (%eax),%esi
  80070f:	8b 78 04             	mov    0x4(%eax),%edi
  800712:	eb 26                	jmp    80073a <vprintfmt+0x290>
	else if (lflag)
  800714:	85 c9                	test   %ecx,%ecx
  800716:	74 12                	je     80072a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)
  800721:	8b 30                	mov    (%eax),%esi
  800723:	89 f7                	mov    %esi,%edi
  800725:	c1 ff 1f             	sar    $0x1f,%edi
  800728:	eb 10                	jmp    80073a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 50 04             	lea    0x4(%eax),%edx
  800730:	89 55 14             	mov    %edx,0x14(%ebp)
  800733:	8b 30                	mov    (%eax),%esi
  800735:	89 f7                	mov    %esi,%edi
  800737:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80073a:	85 ff                	test   %edi,%edi
  80073c:	78 0a                	js     800748 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80073e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800743:	e9 8c 00 00 00       	jmp    8007d4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800753:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800756:	f7 de                	neg    %esi
  800758:	83 d7 00             	adc    $0x0,%edi
  80075b:	f7 df                	neg    %edi
			}
			base = 10;
  80075d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800762:	eb 70                	jmp    8007d4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800764:	89 ca                	mov    %ecx,%edx
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 c0 fc ff ff       	call   80042e <getuint>
  80076e:	89 c6                	mov    %eax,%esi
  800770:	89 d7                	mov    %edx,%edi
			base = 10;
  800772:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800777:	eb 5b                	jmp    8007d4 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800779:	89 ca                	mov    %ecx,%edx
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 ab fc ff ff       	call   80042e <getuint>
  800783:	89 c6                	mov    %eax,%esi
  800785:	89 d7                	mov    %edx,%edi
			base = 8;
  800787:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80078c:	eb 46                	jmp    8007d4 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80078e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800792:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800799:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 50 04             	lea    0x4(%eax),%edx
  8007b0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b3:	8b 30                	mov    (%eax),%esi
  8007b5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007bf:	eb 13                	jmp    8007d4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c1:	89 ca                	mov    %ecx,%edx
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c6:	e8 63 fc ff ff       	call   80042e <getuint>
  8007cb:	89 c6                	mov    %eax,%esi
  8007cd:	89 d7                	mov    %edx,%edi
			base = 16;
  8007cf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007d8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e7:	89 34 24             	mov    %esi,(%esp)
  8007ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ee:	89 da                	mov    %ebx,%edx
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	e8 6c fb ff ff       	call   800364 <printnum>
			break;
  8007f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007fb:	e9 cd fc ff ff       	jmp    8004cd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	89 04 24             	mov    %eax,(%esp)
  800807:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80080d:	e9 bb fc ff ff       	jmp    8004cd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800812:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800816:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80081d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800820:	eb 01                	jmp    800823 <vprintfmt+0x379>
  800822:	4e                   	dec    %esi
  800823:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800827:	75 f9                	jne    800822 <vprintfmt+0x378>
  800829:	e9 9f fc ff ff       	jmp    8004cd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80082e:	83 c4 4c             	add    $0x4c,%esp
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	5f                   	pop    %edi
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	83 ec 28             	sub    $0x28,%esp
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800842:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800845:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800849:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80084c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800853:	85 c0                	test   %eax,%eax
  800855:	74 30                	je     800887 <vsnprintf+0x51>
  800857:	85 d2                	test   %edx,%edx
  800859:	7e 33                	jle    80088e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800862:	8b 45 10             	mov    0x10(%ebp),%eax
  800865:	89 44 24 08          	mov    %eax,0x8(%esp)
  800869:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800870:	c7 04 24 68 04 80 00 	movl   $0x800468,(%esp)
  800877:	e8 2e fc ff ff       	call   8004aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	eb 0c                	jmp    800893 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800887:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088c:	eb 05                	jmp    800893 <vsnprintf+0x5d>
  80088e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	89 04 24             	mov    %eax,(%esp)
  8008b6:	e8 7b ff ff ff       	call   800836 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    
  8008bd:	00 00                	add    %al,(%eax)
	...

008008c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb 01                	jmp    8008ce <strlen+0xe>
		n++;
  8008cd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d2:	75 f9                	jne    8008cd <strlen+0xd>
		n++;
	return n;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e4:	eb 01                	jmp    8008e7 <strnlen+0x11>
		n++;
  8008e6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e7:	39 d0                	cmp    %edx,%eax
  8008e9:	74 06                	je     8008f1 <strnlen+0x1b>
  8008eb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ef:	75 f5                	jne    8008e6 <strnlen+0x10>
		n++;
	return n;
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	53                   	push   %ebx
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800902:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800905:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800908:	42                   	inc    %edx
  800909:	84 c9                	test   %cl,%cl
  80090b:	75 f5                	jne    800902 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80090d:	5b                   	pop    %ebx
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	53                   	push   %ebx
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091a:	89 1c 24             	mov    %ebx,(%esp)
  80091d:	e8 9e ff ff ff       	call   8008c0 <strlen>
	strcpy(dst + len, src);
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	89 54 24 04          	mov    %edx,0x4(%esp)
  800929:	01 d8                	add    %ebx,%eax
  80092b:	89 04 24             	mov    %eax,(%esp)
  80092e:	e8 c0 ff ff ff       	call   8008f3 <strcpy>
	return dst;
}
  800933:	89 d8                	mov    %ebx,%eax
  800935:	83 c4 08             	add    $0x8,%esp
  800938:	5b                   	pop    %ebx
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
  800946:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800949:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094e:	eb 0c                	jmp    80095c <strncpy+0x21>
		*dst++ = *src;
  800950:	8a 1a                	mov    (%edx),%bl
  800952:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800955:	80 3a 01             	cmpb   $0x1,(%edx)
  800958:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095b:	41                   	inc    %ecx
  80095c:	39 f1                	cmp    %esi,%ecx
  80095e:	75 f0                	jne    800950 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 75 08             	mov    0x8(%ebp),%esi
  80096c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800972:	85 d2                	test   %edx,%edx
  800974:	75 0a                	jne    800980 <strlcpy+0x1c>
  800976:	89 f0                	mov    %esi,%eax
  800978:	eb 1a                	jmp    800994 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097a:	88 18                	mov    %bl,(%eax)
  80097c:	40                   	inc    %eax
  80097d:	41                   	inc    %ecx
  80097e:	eb 02                	jmp    800982 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800980:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800982:	4a                   	dec    %edx
  800983:	74 0a                	je     80098f <strlcpy+0x2b>
  800985:	8a 19                	mov    (%ecx),%bl
  800987:	84 db                	test   %bl,%bl
  800989:	75 ef                	jne    80097a <strlcpy+0x16>
  80098b:	89 c2                	mov    %eax,%edx
  80098d:	eb 02                	jmp    800991 <strlcpy+0x2d>
  80098f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800991:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800994:	29 f0                	sub    %esi,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a3:	eb 02                	jmp    8009a7 <strcmp+0xd>
		p++, q++;
  8009a5:	41                   	inc    %ecx
  8009a6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a7:	8a 01                	mov    (%ecx),%al
  8009a9:	84 c0                	test   %al,%al
  8009ab:	74 04                	je     8009b1 <strcmp+0x17>
  8009ad:	3a 02                	cmp    (%edx),%al
  8009af:	74 f4                	je     8009a5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b1:	0f b6 c0             	movzbl %al,%eax
  8009b4:	0f b6 12             	movzbl (%edx),%edx
  8009b7:	29 d0                	sub    %edx,%eax
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009c8:	eb 03                	jmp    8009cd <strncmp+0x12>
		n--, p++, q++;
  8009ca:	4a                   	dec    %edx
  8009cb:	40                   	inc    %eax
  8009cc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009cd:	85 d2                	test   %edx,%edx
  8009cf:	74 14                	je     8009e5 <strncmp+0x2a>
  8009d1:	8a 18                	mov    (%eax),%bl
  8009d3:	84 db                	test   %bl,%bl
  8009d5:	74 04                	je     8009db <strncmp+0x20>
  8009d7:	3a 19                	cmp    (%ecx),%bl
  8009d9:	74 ef                	je     8009ca <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009db:	0f b6 00             	movzbl (%eax),%eax
  8009de:	0f b6 11             	movzbl (%ecx),%edx
  8009e1:	29 d0                	sub    %edx,%eax
  8009e3:	eb 05                	jmp    8009ea <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f6:	eb 05                	jmp    8009fd <strchr+0x10>
		if (*s == c)
  8009f8:	38 ca                	cmp    %cl,%dl
  8009fa:	74 0c                	je     800a08 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009fc:	40                   	inc    %eax
  8009fd:	8a 10                	mov    (%eax),%dl
  8009ff:	84 d2                	test   %dl,%dl
  800a01:	75 f5                	jne    8009f8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a13:	eb 05                	jmp    800a1a <strfind+0x10>
		if (*s == c)
  800a15:	38 ca                	cmp    %cl,%dl
  800a17:	74 07                	je     800a20 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a19:	40                   	inc    %eax
  800a1a:	8a 10                	mov    (%eax),%dl
  800a1c:	84 d2                	test   %dl,%dl
  800a1e:	75 f5                	jne    800a15 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a31:	85 c9                	test   %ecx,%ecx
  800a33:	74 30                	je     800a65 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3b:	75 25                	jne    800a62 <memset+0x40>
  800a3d:	f6 c1 03             	test   $0x3,%cl
  800a40:	75 20                	jne    800a62 <memset+0x40>
		c &= 0xFF;
  800a42:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a45:	89 d3                	mov    %edx,%ebx
  800a47:	c1 e3 08             	shl    $0x8,%ebx
  800a4a:	89 d6                	mov    %edx,%esi
  800a4c:	c1 e6 18             	shl    $0x18,%esi
  800a4f:	89 d0                	mov    %edx,%eax
  800a51:	c1 e0 10             	shl    $0x10,%eax
  800a54:	09 f0                	or     %esi,%eax
  800a56:	09 d0                	or     %edx,%eax
  800a58:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a5d:	fc                   	cld    
  800a5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a60:	eb 03                	jmp    800a65 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a62:	fc                   	cld    
  800a63:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a65:	89 f8                	mov    %edi,%eax
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7a:	39 c6                	cmp    %eax,%esi
  800a7c:	73 34                	jae    800ab2 <memmove+0x46>
  800a7e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a81:	39 d0                	cmp    %edx,%eax
  800a83:	73 2d                	jae    800ab2 <memmove+0x46>
		s += n;
		d += n;
  800a85:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	f6 c2 03             	test   $0x3,%dl
  800a8b:	75 1b                	jne    800aa8 <memmove+0x3c>
  800a8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a93:	75 13                	jne    800aa8 <memmove+0x3c>
  800a95:	f6 c1 03             	test   $0x3,%cl
  800a98:	75 0e                	jne    800aa8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a9a:	83 ef 04             	sub    $0x4,%edi
  800a9d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aa3:	fd                   	std    
  800aa4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa6:	eb 07                	jmp    800aaf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa8:	4f                   	dec    %edi
  800aa9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aac:	fd                   	std    
  800aad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aaf:	fc                   	cld    
  800ab0:	eb 20                	jmp    800ad2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab8:	75 13                	jne    800acd <memmove+0x61>
  800aba:	a8 03                	test   $0x3,%al
  800abc:	75 0f                	jne    800acd <memmove+0x61>
  800abe:	f6 c1 03             	test   $0x3,%cl
  800ac1:	75 0a                	jne    800acd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ac6:	89 c7                	mov    %eax,%edi
  800ac8:	fc                   	cld    
  800ac9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acb:	eb 05                	jmp    800ad2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	fc                   	cld    
  800ad0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800adc:	8b 45 10             	mov    0x10(%ebp),%eax
  800adf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	89 04 24             	mov    %eax,(%esp)
  800af0:	e8 77 ff ff ff       	call   800a6c <memmove>
}
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	eb 16                	jmp    800b23 <memcmp+0x2c>
		if (*s1 != *s2)
  800b0d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b10:	42                   	inc    %edx
  800b11:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b15:	38 c8                	cmp    %cl,%al
  800b17:	74 0a                	je     800b23 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b19:	0f b6 c0             	movzbl %al,%eax
  800b1c:	0f b6 c9             	movzbl %cl,%ecx
  800b1f:	29 c8                	sub    %ecx,%eax
  800b21:	eb 09                	jmp    800b2c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b23:	39 da                	cmp    %ebx,%edx
  800b25:	75 e6                	jne    800b0d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3a:	89 c2                	mov    %eax,%edx
  800b3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3f:	eb 05                	jmp    800b46 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b41:	38 08                	cmp    %cl,(%eax)
  800b43:	74 05                	je     800b4a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b45:	40                   	inc    %eax
  800b46:	39 d0                	cmp    %edx,%eax
  800b48:	72 f7                	jb     800b41 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b58:	eb 01                	jmp    800b5b <strtol+0xf>
		s++;
  800b5a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5b:	8a 02                	mov    (%edx),%al
  800b5d:	3c 20                	cmp    $0x20,%al
  800b5f:	74 f9                	je     800b5a <strtol+0xe>
  800b61:	3c 09                	cmp    $0x9,%al
  800b63:	74 f5                	je     800b5a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b65:	3c 2b                	cmp    $0x2b,%al
  800b67:	75 08                	jne    800b71 <strtol+0x25>
		s++;
  800b69:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6f:	eb 13                	jmp    800b84 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b71:	3c 2d                	cmp    $0x2d,%al
  800b73:	75 0a                	jne    800b7f <strtol+0x33>
		s++, neg = 1;
  800b75:	8d 52 01             	lea    0x1(%edx),%edx
  800b78:	bf 01 00 00 00       	mov    $0x1,%edi
  800b7d:	eb 05                	jmp    800b84 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b84:	85 db                	test   %ebx,%ebx
  800b86:	74 05                	je     800b8d <strtol+0x41>
  800b88:	83 fb 10             	cmp    $0x10,%ebx
  800b8b:	75 28                	jne    800bb5 <strtol+0x69>
  800b8d:	8a 02                	mov    (%edx),%al
  800b8f:	3c 30                	cmp    $0x30,%al
  800b91:	75 10                	jne    800ba3 <strtol+0x57>
  800b93:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b97:	75 0a                	jne    800ba3 <strtol+0x57>
		s += 2, base = 16;
  800b99:	83 c2 02             	add    $0x2,%edx
  800b9c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba1:	eb 12                	jmp    800bb5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ba3:	85 db                	test   %ebx,%ebx
  800ba5:	75 0e                	jne    800bb5 <strtol+0x69>
  800ba7:	3c 30                	cmp    $0x30,%al
  800ba9:	75 05                	jne    800bb0 <strtol+0x64>
		s++, base = 8;
  800bab:	42                   	inc    %edx
  800bac:	b3 08                	mov    $0x8,%bl
  800bae:	eb 05                	jmp    800bb5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bb0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bba:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bbc:	8a 0a                	mov    (%edx),%cl
  800bbe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bc1:	80 fb 09             	cmp    $0x9,%bl
  800bc4:	77 08                	ja     800bce <strtol+0x82>
			dig = *s - '0';
  800bc6:	0f be c9             	movsbl %cl,%ecx
  800bc9:	83 e9 30             	sub    $0x30,%ecx
  800bcc:	eb 1e                	jmp    800bec <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bce:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bd1:	80 fb 19             	cmp    $0x19,%bl
  800bd4:	77 08                	ja     800bde <strtol+0x92>
			dig = *s - 'a' + 10;
  800bd6:	0f be c9             	movsbl %cl,%ecx
  800bd9:	83 e9 57             	sub    $0x57,%ecx
  800bdc:	eb 0e                	jmp    800bec <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bde:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 12                	ja     800bf8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800be6:	0f be c9             	movsbl %cl,%ecx
  800be9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bec:	39 f1                	cmp    %esi,%ecx
  800bee:	7d 0c                	jge    800bfc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bf0:	42                   	inc    %edx
  800bf1:	0f af c6             	imul   %esi,%eax
  800bf4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bf6:	eb c4                	jmp    800bbc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bf8:	89 c1                	mov    %eax,%ecx
  800bfa:	eb 02                	jmp    800bfe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bfc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bfe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c02:	74 05                	je     800c09 <strtol+0xbd>
		*endptr = (char *) s;
  800c04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c07:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c09:	85 ff                	test   %edi,%edi
  800c0b:	74 04                	je     800c11 <strtol+0xc5>
  800c0d:	89 c8                	mov    %ecx,%eax
  800c0f:	f7 d8                	neg    %eax
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    
	...

00800c18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 c3                	mov    %eax,%ebx
  800c2b:	89 c7                	mov    %eax,%edi
  800c2d:	89 c6                	mov    %eax,%esi
  800c2f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_cgetc>:

int
sys_cgetc(void)
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
  800c41:	b8 01 00 00 00       	mov    $0x1,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c63:	b8 03 00 00 00       	mov    $0x3,%eax
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 cb                	mov    %ecx,%ebx
  800c6d:	89 cf                	mov    %ecx,%edi
  800c6f:	89 ce                	mov    %ecx,%esi
  800c71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 28                	jle    800c9f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c82:	00 
  800c83:	c7 44 24 08 1f 2b 80 	movl   $0x802b1f,0x8(%esp)
  800c8a:	00 
  800c8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c92:	00 
  800c93:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  800c9a:	e8 b1 f5 ff ff       	call   800250 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9f:	83 c4 2c             	add    $0x2c,%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb2:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb7:	89 d1                	mov    %edx,%ecx
  800cb9:	89 d3                	mov    %edx,%ebx
  800cbb:	89 d7                	mov    %edx,%edi
  800cbd:	89 d6                	mov    %edx,%esi
  800cbf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_yield>:

void
sys_yield(void)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd6:	89 d1                	mov    %edx,%ecx
  800cd8:	89 d3                	mov    %edx,%ebx
  800cda:	89 d7                	mov    %edx,%edi
  800cdc:	89 d6                	mov    %edx,%esi
  800cde:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	be 00 00 00 00       	mov    $0x0,%esi
  800cf3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 f7                	mov    %esi,%edi
  800d03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 28                	jle    800d31 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d14:	00 
  800d15:	c7 44 24 08 1f 2b 80 	movl   $0x802b1f,0x8(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d24:	00 
  800d25:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  800d2c:	e8 1f f5 ff ff       	call   800250 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d31:	83 c4 2c             	add    $0x2c,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	b8 05 00 00 00       	mov    $0x5,%eax
  800d47:	8b 75 18             	mov    0x18(%ebp),%esi
  800d4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7e 28                	jle    800d84 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d60:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d67:	00 
  800d68:	c7 44 24 08 1f 2b 80 	movl   $0x802b1f,0x8(%esp)
  800d6f:	00 
  800d70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d77:	00 
  800d78:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  800d7f:	e8 cc f4 ff ff       	call   800250 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d84:	83 c4 2c             	add    $0x2c,%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	89 df                	mov    %ebx,%edi
  800da7:	89 de                	mov    %ebx,%esi
  800da9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 28                	jle    800dd7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dba:	00 
  800dbb:	c7 44 24 08 1f 2b 80 	movl   $0x802b1f,0x8(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dca:	00 
  800dcb:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  800dd2:	e8 79 f4 ff ff       	call   800250 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd7:	83 c4 2c             	add    $0x2c,%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ded:	b8 08 00 00 00       	mov    $0x8,%eax
  800df2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	89 df                	mov    %ebx,%edi
  800dfa:	89 de                	mov    %ebx,%esi
  800dfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	7e 28                	jle    800e2a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e02:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e06:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 08 1f 2b 80 	movl   $0x802b1f,0x8(%esp)
  800e15:	00 
  800e16:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1d:	00 
  800e1e:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  800e25:	e8 26 f4 ff ff       	call   800250 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2a:	83 c4 2c             	add    $0x2c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e40:	b8 09 00 00 00       	mov    $0x9,%eax
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4b:	89 df                	mov    %ebx,%edi
  800e4d:	89 de                	mov    %ebx,%esi
  800e4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e51:	85 c0                	test   %eax,%eax
  800e53:	7e 28                	jle    800e7d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e59:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e60:	00 
  800e61:	c7 44 24 08 1f 2b 80 	movl   $0x802b1f,0x8(%esp)
  800e68:	00 
  800e69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e70:	00 
  800e71:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  800e78:	e8 d3 f3 ff ff       	call   800250 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e7d:	83 c4 2c             	add    $0x2c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e93:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	89 df                	mov    %ebx,%edi
  800ea0:	89 de                	mov    %ebx,%esi
  800ea2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	7e 28                	jle    800ed0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eac:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 08 1f 2b 80 	movl   $0x802b1f,0x8(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec3:	00 
  800ec4:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  800ecb:	e8 80 f3 ff ff       	call   800250 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed0:	83 c4 2c             	add    $0x2c,%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	be 00 00 00 00       	mov    $0x0,%esi
  800ee3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f09:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f11:	89 cb                	mov    %ecx,%ebx
  800f13:	89 cf                	mov    %ecx,%edi
  800f15:	89 ce                	mov    %ecx,%esi
  800f17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	7e 28                	jle    800f45 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f21:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f28:	00 
  800f29:	c7 44 24 08 1f 2b 80 	movl   $0x802b1f,0x8(%esp)
  800f30:	00 
  800f31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f38:	00 
  800f39:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  800f40:	e8 0b f3 ff ff       	call   800250 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f45:	83 c4 2c             	add    $0x2c,%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    
  800f4d:	00 00                	add    %al,(%eax)
	...

00800f50 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	57                   	push   %edi
  800f54:	56                   	push   %esi
  800f55:	53                   	push   %ebx
  800f56:	83 ec 3c             	sub    $0x3c,%esp
  800f59:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800f5c:	89 d6                	mov    %edx,%esi
  800f5e:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800f61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f68:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800f6b:	e8 37 fd ff ff       	call   800ca7 <sys_getenvid>
  800f70:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800f72:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800f79:	74 31                	je     800fac <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800f7b:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800f82:	00 
  800f83:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f87:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f92:	89 3c 24             	mov    %edi,(%esp)
  800f95:	e8 9f fd ff ff       	call   800d39 <sys_page_map>
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	0f 8e ae 00 00 00    	jle    801050 <duppage+0x100>
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa7:	e9 a4 00 00 00       	jmp    801050 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  800fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800faf:	25 02 08 00 00       	and    $0x802,%eax
  800fb4:	83 f8 01             	cmp    $0x1,%eax
  800fb7:	19 db                	sbb    %ebx,%ebx
  800fb9:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  800fbf:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  800fc5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800fc9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd8:	89 3c 24             	mov    %edi,(%esp)
  800fdb:	e8 59 fd ff ff       	call   800d39 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	79 1c                	jns    801000 <duppage+0xb0>
  800fe4:	c7 44 24 08 4a 2b 80 	movl   $0x802b4a,0x8(%esp)
  800feb:	00 
  800fec:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800ff3:	00 
  800ff4:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  800ffb:	e8 50 f2 ff ff       	call   800250 <_panic>
	if ((perm|~pte)&PTE_COW){
  801000:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801003:	f7 d0                	not    %eax
  801005:	09 d8                	or     %ebx,%eax
  801007:	f6 c4 08             	test   $0x8,%ah
  80100a:	74 38                	je     801044 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  80100c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801010:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801014:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801018:	89 74 24 04          	mov    %esi,0x4(%esp)
  80101c:	89 3c 24             	mov    %edi,(%esp)
  80101f:	e8 15 fd ff ff       	call   800d39 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  801024:	85 c0                	test   %eax,%eax
  801026:	79 23                	jns    80104b <duppage+0xfb>
  801028:	c7 44 24 08 4a 2b 80 	movl   $0x802b4a,0x8(%esp)
  80102f:	00 
  801030:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801037:	00 
  801038:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  80103f:	e8 0c f2 ff ff       	call   800250 <_panic>
	}
	return 0;
  801044:	b8 00 00 00 00       	mov    $0x0,%eax
  801049:	eb 05                	jmp    801050 <duppage+0x100>
  80104b:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  801050:	83 c4 3c             	add    $0x3c,%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 20             	sub    $0x20,%esp
  801060:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801063:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  801065:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801069:	75 1c                	jne    801087 <pgfault+0x2f>
		panic("pgfault: error!\n");
  80106b:	c7 44 24 08 66 2b 80 	movl   $0x802b66,0x8(%esp)
  801072:	00 
  801073:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80107a:	00 
  80107b:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  801082:	e8 c9 f1 ff ff       	call   800250 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  801087:	89 f0                	mov    %esi,%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
  80108c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801093:	f6 c4 08             	test   $0x8,%ah
  801096:	75 1c                	jne    8010b4 <pgfault+0x5c>
		panic("pgfault: error!\n");
  801098:	c7 44 24 08 66 2b 80 	movl   $0x802b66,0x8(%esp)
  80109f:	00 
  8010a0:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8010a7:	00 
  8010a8:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  8010af:	e8 9c f1 ff ff       	call   800250 <_panic>
	envid_t envid = sys_getenvid();
  8010b4:	e8 ee fb ff ff       	call   800ca7 <sys_getenvid>
  8010b9:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  8010bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010c2:	00 
  8010c3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010ca:	00 
  8010cb:	89 04 24             	mov    %eax,(%esp)
  8010ce:	e8 12 fc ff ff       	call   800ce5 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	79 1c                	jns    8010f3 <pgfault+0x9b>
  8010d7:	c7 44 24 08 66 2b 80 	movl   $0x802b66,0x8(%esp)
  8010de:	00 
  8010df:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8010e6:	00 
  8010e7:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  8010ee:	e8 5d f1 ff ff       	call   800250 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  8010f3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  8010f9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801100:	00 
  801101:	89 74 24 04          	mov    %esi,0x4(%esp)
  801105:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80110c:	e8 c5 f9 ff ff       	call   800ad6 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  801111:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801118:	00 
  801119:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80111d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801121:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801128:	00 
  801129:	89 1c 24             	mov    %ebx,(%esp)
  80112c:	e8 08 fc ff ff       	call   800d39 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801131:	85 c0                	test   %eax,%eax
  801133:	79 1c                	jns    801151 <pgfault+0xf9>
  801135:	c7 44 24 08 66 2b 80 	movl   $0x802b66,0x8(%esp)
  80113c:	00 
  80113d:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801144:	00 
  801145:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  80114c:	e8 ff f0 ff ff       	call   800250 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801151:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801158:	00 
  801159:	89 1c 24             	mov    %ebx,(%esp)
  80115c:	e8 2b fc ff ff       	call   800d8c <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  801161:	85 c0                	test   %eax,%eax
  801163:	79 1c                	jns    801181 <pgfault+0x129>
  801165:	c7 44 24 08 66 2b 80 	movl   $0x802b66,0x8(%esp)
  80116c:	00 
  80116d:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801174:	00 
  801175:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  80117c:	e8 cf f0 ff ff       	call   800250 <_panic>
	return;
	panic("pgfault not implemented");
}
  801181:	83 c4 20             	add    $0x20,%esp
  801184:	5b                   	pop    %ebx
  801185:	5e                   	pop    %esi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	57                   	push   %edi
  80118c:	56                   	push   %esi
  80118d:	53                   	push   %ebx
  80118e:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801191:	c7 04 24 58 10 80 00 	movl   $0x801058,(%esp)
  801198:	e8 0b 11 00 00       	call   8022a8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80119d:	bf 07 00 00 00       	mov    $0x7,%edi
  8011a2:	89 f8                	mov    %edi,%eax
  8011a4:	cd 30                	int    $0x30
  8011a6:	89 c7                	mov    %eax,%edi
  8011a8:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	79 1c                	jns    8011ca <fork+0x42>
		panic("fork : error!\n");
  8011ae:	c7 44 24 08 83 2b 80 	movl   $0x802b83,0x8(%esp)
  8011b5:	00 
  8011b6:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  8011bd:	00 
  8011be:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  8011c5:	e8 86 f0 ff ff       	call   800250 <_panic>
	if (envid==0){
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	75 28                	jne    8011f6 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  8011ce:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8011d4:	e8 ce fa ff ff       	call   800ca7 <sys_getenvid>
  8011d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011de:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011e5:	c1 e0 07             	shl    $0x7,%eax
  8011e8:	29 d0                	sub    %edx,%eax
  8011ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ef:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  8011f1:	e9 f2 00 00 00       	jmp    8012e8 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  8011f6:	e8 ac fa ff ff       	call   800ca7 <sys_getenvid>
  8011fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8011fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  801203:	89 d8                	mov    %ebx,%eax
  801205:	c1 e8 16             	shr    $0x16,%eax
  801208:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80120f:	a8 01                	test   $0x1,%al
  801211:	74 17                	je     80122a <fork+0xa2>
  801213:	89 da                	mov    %ebx,%edx
  801215:	c1 ea 0c             	shr    $0xc,%edx
  801218:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80121f:	a8 01                	test   $0x1,%al
  801221:	74 07                	je     80122a <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801223:	89 f0                	mov    %esi,%eax
  801225:	e8 26 fd ff ff       	call   800f50 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80122a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801230:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801236:	75 cb                	jne    801203 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801238:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80123f:	00 
  801240:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801247:	ee 
  801248:	89 3c 24             	mov    %edi,(%esp)
  80124b:	e8 95 fa ff ff       	call   800ce5 <sys_page_alloc>
  801250:	85 c0                	test   %eax,%eax
  801252:	79 1c                	jns    801270 <fork+0xe8>
  801254:	c7 44 24 08 83 2b 80 	movl   $0x802b83,0x8(%esp)
  80125b:	00 
  80125c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801263:	00 
  801264:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  80126b:	e8 e0 ef ff ff       	call   800250 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  801270:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801273:	25 ff 03 00 00       	and    $0x3ff,%eax
  801278:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80127f:	c1 e0 07             	shl    $0x7,%eax
  801282:	29 d0                	sub    %edx,%eax
  801284:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801289:	8b 40 64             	mov    0x64(%eax),%eax
  80128c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801290:	89 3c 24             	mov    %edi,(%esp)
  801293:	e8 ed fb ff ff       	call   800e85 <sys_env_set_pgfault_upcall>
  801298:	85 c0                	test   %eax,%eax
  80129a:	79 1c                	jns    8012b8 <fork+0x130>
  80129c:	c7 44 24 08 83 2b 80 	movl   $0x802b83,0x8(%esp)
  8012a3:	00 
  8012a4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8012ab:	00 
  8012ac:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  8012b3:	e8 98 ef ff ff       	call   800250 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8012b8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012bf:	00 
  8012c0:	89 3c 24             	mov    %edi,(%esp)
  8012c3:	e8 17 fb ff ff       	call   800ddf <sys_env_set_status>
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	79 1c                	jns    8012e8 <fork+0x160>
  8012cc:	c7 44 24 08 83 2b 80 	movl   $0x802b83,0x8(%esp)
  8012d3:	00 
  8012d4:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8012db:	00 
  8012dc:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  8012e3:	e8 68 ef ff ff       	call   800250 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  8012e8:	89 f8                	mov    %edi,%eax
  8012ea:	83 c4 2c             	add    $0x2c,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <sfork>:

// Challenge!
int
sfork(void)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	57                   	push   %edi
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8012fb:	c7 04 24 58 10 80 00 	movl   $0x801058,(%esp)
  801302:	e8 a1 0f 00 00       	call   8022a8 <set_pgfault_handler>
  801307:	ba 07 00 00 00       	mov    $0x7,%edx
  80130c:	89 d0                	mov    %edx,%eax
  80130e:	cd 30                	int    $0x30
  801310:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801313:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801315:	89 44 24 04          	mov    %eax,0x4(%esp)
  801319:	c7 04 24 77 2b 80 00 	movl   $0x802b77,(%esp)
  801320:	e8 23 f0 ff ff       	call   800348 <cprintf>
	if (envid<0)
  801325:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801329:	79 1c                	jns    801347 <sfork+0x55>
		panic("sfork : error!\n");
  80132b:	c7 44 24 08 82 2b 80 	movl   $0x802b82,0x8(%esp)
  801332:	00 
  801333:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  80133a:	00 
  80133b:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  801342:	e8 09 ef ff ff       	call   800250 <_panic>
	if (envid==0){
  801347:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80134b:	75 28                	jne    801375 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  80134d:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801353:	e8 4f f9 ff ff       	call   800ca7 <sys_getenvid>
  801358:	25 ff 03 00 00       	and    $0x3ff,%eax
  80135d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801364:	c1 e0 07             	shl    $0x7,%eax
  801367:	29 d0                	sub    %edx,%eax
  801369:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80136e:	89 03                	mov    %eax,(%ebx)
		return envid;
  801370:	e9 18 01 00 00       	jmp    80148d <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801375:	e8 2d f9 ff ff       	call   800ca7 <sys_getenvid>
  80137a:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  80137c:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  801381:	89 d8                	mov    %ebx,%eax
  801383:	c1 e8 16             	shr    $0x16,%eax
  801386:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80138d:	a8 01                	test   $0x1,%al
  80138f:	74 2c                	je     8013bd <sfork+0xcb>
  801391:	89 d8                	mov    %ebx,%eax
  801393:	c1 e8 0c             	shr    $0xc,%eax
  801396:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139d:	a8 01                	test   $0x1,%al
  80139f:	74 1c                	je     8013bd <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8013a1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013a8:	00 
  8013a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013ad:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013b5:	89 3c 24             	mov    %edi,(%esp)
  8013b8:	e8 7c f9 ff ff       	call   800d39 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8013bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013c3:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8013c9:	75 b6                	jne    801381 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  8013cb:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  8013d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013d3:	e8 78 fb ff ff       	call   800f50 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  8013d8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013df:	00 
  8013e0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013e7:	ee 
  8013e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013eb:	89 04 24             	mov    %eax,(%esp)
  8013ee:	e8 f2 f8 ff ff       	call   800ce5 <sys_page_alloc>
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	79 1c                	jns    801413 <sfork+0x121>
  8013f7:	c7 44 24 08 82 2b 80 	movl   $0x802b82,0x8(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  801406:	00 
  801407:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  80140e:	e8 3d ee ff ff       	call   800250 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  801413:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801419:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801420:	c1 e7 07             	shl    $0x7,%edi
  801423:	29 d7                	sub    %edx,%edi
  801425:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80142b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801432:	89 04 24             	mov    %eax,(%esp)
  801435:	e8 4b fa ff ff       	call   800e85 <sys_env_set_pgfault_upcall>
  80143a:	85 c0                	test   %eax,%eax
  80143c:	79 1c                	jns    80145a <sfork+0x168>
  80143e:	c7 44 24 08 82 2b 80 	movl   $0x802b82,0x8(%esp)
  801445:	00 
  801446:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  80144d:	00 
  80144e:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  801455:	e8 f6 ed ff ff       	call   800250 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  80145a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801461:	00 
  801462:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801465:	89 04 24             	mov    %eax,(%esp)
  801468:	e8 72 f9 ff ff       	call   800ddf <sys_env_set_status>
  80146d:	85 c0                	test   %eax,%eax
  80146f:	79 1c                	jns    80148d <sfork+0x19b>
  801471:	c7 44 24 08 82 2b 80 	movl   $0x802b82,0x8(%esp)
  801478:	00 
  801479:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801480:	00 
  801481:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  801488:	e8 c3 ed ff ff       	call   800250 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  80148d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801490:	83 c4 3c             	add    $0x3c,%esp
  801493:	5b                   	pop    %ebx
  801494:	5e                   	pop    %esi
  801495:	5f                   	pop    %edi
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	05 00 00 00 30       	add    $0x30000000,%eax
  8014a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8014a6:	5d                   	pop    %ebp
  8014a7:	c3                   	ret    

008014a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b1:	89 04 24             	mov    %eax,(%esp)
  8014b4:	e8 df ff ff ff       	call   801498 <fd2num>
  8014b9:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014be:	c1 e0 0c             	shl    $0xc,%eax
}
  8014c1:	c9                   	leave  
  8014c2:	c3                   	ret    

008014c3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	53                   	push   %ebx
  8014c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014ca:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014cf:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014d1:	89 c2                	mov    %eax,%edx
  8014d3:	c1 ea 16             	shr    $0x16,%edx
  8014d6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014dd:	f6 c2 01             	test   $0x1,%dl
  8014e0:	74 11                	je     8014f3 <fd_alloc+0x30>
  8014e2:	89 c2                	mov    %eax,%edx
  8014e4:	c1 ea 0c             	shr    $0xc,%edx
  8014e7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ee:	f6 c2 01             	test   $0x1,%dl
  8014f1:	75 09                	jne    8014fc <fd_alloc+0x39>
			*fd_store = fd;
  8014f3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fa:	eb 17                	jmp    801513 <fd_alloc+0x50>
  8014fc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801501:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801506:	75 c7                	jne    8014cf <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801508:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80150e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801513:	5b                   	pop    %ebx
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80151c:	83 f8 1f             	cmp    $0x1f,%eax
  80151f:	77 36                	ja     801557 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801521:	05 00 00 0d 00       	add    $0xd0000,%eax
  801526:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801529:	89 c2                	mov    %eax,%edx
  80152b:	c1 ea 16             	shr    $0x16,%edx
  80152e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801535:	f6 c2 01             	test   $0x1,%dl
  801538:	74 24                	je     80155e <fd_lookup+0x48>
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	c1 ea 0c             	shr    $0xc,%edx
  80153f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801546:	f6 c2 01             	test   $0x1,%dl
  801549:	74 1a                	je     801565 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80154b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154e:	89 02                	mov    %eax,(%edx)
	return 0;
  801550:	b8 00 00 00 00       	mov    $0x0,%eax
  801555:	eb 13                	jmp    80156a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155c:	eb 0c                	jmp    80156a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80155e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801563:	eb 05                	jmp    80156a <fd_lookup+0x54>
  801565:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	53                   	push   %ebx
  801570:	83 ec 14             	sub    $0x14,%esp
  801573:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801576:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801579:	ba 00 00 00 00       	mov    $0x0,%edx
  80157e:	eb 0e                	jmp    80158e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801580:	39 08                	cmp    %ecx,(%eax)
  801582:	75 09                	jne    80158d <dev_lookup+0x21>
			*dev = devtab[i];
  801584:	89 03                	mov    %eax,(%ebx)
			return 0;
  801586:	b8 00 00 00 00       	mov    $0x0,%eax
  80158b:	eb 35                	jmp    8015c2 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80158d:	42                   	inc    %edx
  80158e:	8b 04 95 10 2c 80 00 	mov    0x802c10(,%edx,4),%eax
  801595:	85 c0                	test   %eax,%eax
  801597:	75 e7                	jne    801580 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801599:	a1 04 40 80 00       	mov    0x804004,%eax
  80159e:	8b 00                	mov    (%eax),%eax
  8015a0:	8b 40 48             	mov    0x48(%eax),%eax
  8015a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ab:	c7 04 24 94 2b 80 00 	movl   $0x802b94,(%esp)
  8015b2:	e8 91 ed ff ff       	call   800348 <cprintf>
	*dev = 0;
  8015b7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015c2:	83 c4 14             	add    $0x14,%esp
  8015c5:	5b                   	pop    %ebx
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	56                   	push   %esi
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 30             	sub    $0x30,%esp
  8015d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8015d3:	8a 45 0c             	mov    0xc(%ebp),%al
  8015d6:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015d9:	89 34 24             	mov    %esi,(%esp)
  8015dc:	e8 b7 fe ff ff       	call   801498 <fd2num>
  8015e1:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015e8:	89 04 24             	mov    %eax,(%esp)
  8015eb:	e8 26 ff ff ff       	call   801516 <fd_lookup>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 05                	js     8015fb <fd_close+0x33>
	    || fd != fd2)
  8015f6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015f9:	74 0d                	je     801608 <fd_close+0x40>
		return (must_exist ? r : 0);
  8015fb:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015ff:	75 46                	jne    801647 <fd_close+0x7f>
  801601:	bb 00 00 00 00       	mov    $0x0,%ebx
  801606:	eb 3f                	jmp    801647 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801608:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160f:	8b 06                	mov    (%esi),%eax
  801611:	89 04 24             	mov    %eax,(%esp)
  801614:	e8 53 ff ff ff       	call   80156c <dev_lookup>
  801619:	89 c3                	mov    %eax,%ebx
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 18                	js     801637 <fd_close+0x6f>
		if (dev->dev_close)
  80161f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801622:	8b 40 10             	mov    0x10(%eax),%eax
  801625:	85 c0                	test   %eax,%eax
  801627:	74 09                	je     801632 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801629:	89 34 24             	mov    %esi,(%esp)
  80162c:	ff d0                	call   *%eax
  80162e:	89 c3                	mov    %eax,%ebx
  801630:	eb 05                	jmp    801637 <fd_close+0x6f>
		else
			r = 0;
  801632:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801637:	89 74 24 04          	mov    %esi,0x4(%esp)
  80163b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801642:	e8 45 f7 ff ff       	call   800d8c <sys_page_unmap>
	return r;
}
  801647:	89 d8                	mov    %ebx,%eax
  801649:	83 c4 30             	add    $0x30,%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801656:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165d:	8b 45 08             	mov    0x8(%ebp),%eax
  801660:	89 04 24             	mov    %eax,(%esp)
  801663:	e8 ae fe ff ff       	call   801516 <fd_lookup>
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 13                	js     80167f <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80166c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801673:	00 
  801674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801677:	89 04 24             	mov    %eax,(%esp)
  80167a:	e8 49 ff ff ff       	call   8015c8 <fd_close>
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <close_all>:

void
close_all(void)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	53                   	push   %ebx
  801685:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801688:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80168d:	89 1c 24             	mov    %ebx,(%esp)
  801690:	e8 bb ff ff ff       	call   801650 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801695:	43                   	inc    %ebx
  801696:	83 fb 20             	cmp    $0x20,%ebx
  801699:	75 f2                	jne    80168d <close_all+0xc>
		close(i);
}
  80169b:	83 c4 14             	add    $0x14,%esp
  80169e:	5b                   	pop    %ebx
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	57                   	push   %edi
  8016a5:	56                   	push   %esi
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 4c             	sub    $0x4c,%esp
  8016aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b7:	89 04 24             	mov    %eax,(%esp)
  8016ba:	e8 57 fe ff ff       	call   801516 <fd_lookup>
  8016bf:	89 c3                	mov    %eax,%ebx
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	0f 88 e1 00 00 00    	js     8017aa <dup+0x109>
		return r;
	close(newfdnum);
  8016c9:	89 3c 24             	mov    %edi,(%esp)
  8016cc:	e8 7f ff ff ff       	call   801650 <close>

	newfd = INDEX2FD(newfdnum);
  8016d1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016d7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016dd:	89 04 24             	mov    %eax,(%esp)
  8016e0:	e8 c3 fd ff ff       	call   8014a8 <fd2data>
  8016e5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016e7:	89 34 24             	mov    %esi,(%esp)
  8016ea:	e8 b9 fd ff ff       	call   8014a8 <fd2data>
  8016ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016f2:	89 d8                	mov    %ebx,%eax
  8016f4:	c1 e8 16             	shr    $0x16,%eax
  8016f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016fe:	a8 01                	test   $0x1,%al
  801700:	74 46                	je     801748 <dup+0xa7>
  801702:	89 d8                	mov    %ebx,%eax
  801704:	c1 e8 0c             	shr    $0xc,%eax
  801707:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80170e:	f6 c2 01             	test   $0x1,%dl
  801711:	74 35                	je     801748 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801713:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80171a:	25 07 0e 00 00       	and    $0xe07,%eax
  80171f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801723:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801726:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80172a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801731:	00 
  801732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801736:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173d:	e8 f7 f5 ff ff       	call   800d39 <sys_page_map>
  801742:	89 c3                	mov    %eax,%ebx
  801744:	85 c0                	test   %eax,%eax
  801746:	78 3b                	js     801783 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	c1 ea 0c             	shr    $0xc,%edx
  801750:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801757:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80175d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801761:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801765:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80176c:	00 
  80176d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801771:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801778:	e8 bc f5 ff ff       	call   800d39 <sys_page_map>
  80177d:	89 c3                	mov    %eax,%ebx
  80177f:	85 c0                	test   %eax,%eax
  801781:	79 25                	jns    8017a8 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801783:	89 74 24 04          	mov    %esi,0x4(%esp)
  801787:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80178e:	e8 f9 f5 ff ff       	call   800d8c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801793:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801796:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017a1:	e8 e6 f5 ff ff       	call   800d8c <sys_page_unmap>
	return r;
  8017a6:	eb 02                	jmp    8017aa <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017a8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017aa:	89 d8                	mov    %ebx,%eax
  8017ac:	83 c4 4c             	add    $0x4c,%esp
  8017af:	5b                   	pop    %ebx
  8017b0:	5e                   	pop    %esi
  8017b1:	5f                   	pop    %edi
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	53                   	push   %ebx
  8017b8:	83 ec 24             	sub    $0x24,%esp
  8017bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c5:	89 1c 24             	mov    %ebx,(%esp)
  8017c8:	e8 49 fd ff ff       	call   801516 <fd_lookup>
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 6f                	js     801840 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017db:	8b 00                	mov    (%eax),%eax
  8017dd:	89 04 24             	mov    %eax,(%esp)
  8017e0:	e8 87 fd ff ff       	call   80156c <dev_lookup>
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 57                	js     801840 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ec:	8b 50 08             	mov    0x8(%eax),%edx
  8017ef:	83 e2 03             	and    $0x3,%edx
  8017f2:	83 fa 01             	cmp    $0x1,%edx
  8017f5:	75 25                	jne    80181c <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8017fc:	8b 00                	mov    (%eax),%eax
  8017fe:	8b 40 48             	mov    0x48(%eax),%eax
  801801:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801805:	89 44 24 04          	mov    %eax,0x4(%esp)
  801809:	c7 04 24 d5 2b 80 00 	movl   $0x802bd5,(%esp)
  801810:	e8 33 eb ff ff       	call   800348 <cprintf>
		return -E_INVAL;
  801815:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80181a:	eb 24                	jmp    801840 <read+0x8c>
	}
	if (!dev->dev_read)
  80181c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80181f:	8b 52 08             	mov    0x8(%edx),%edx
  801822:	85 d2                	test   %edx,%edx
  801824:	74 15                	je     80183b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801826:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801829:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80182d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801830:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801834:	89 04 24             	mov    %eax,(%esp)
  801837:	ff d2                	call   *%edx
  801839:	eb 05                	jmp    801840 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80183b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801840:	83 c4 24             	add    $0x24,%esp
  801843:	5b                   	pop    %ebx
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	57                   	push   %edi
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
  80184c:	83 ec 1c             	sub    $0x1c,%esp
  80184f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801852:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801855:	bb 00 00 00 00       	mov    $0x0,%ebx
  80185a:	eb 23                	jmp    80187f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80185c:	89 f0                	mov    %esi,%eax
  80185e:	29 d8                	sub    %ebx,%eax
  801860:	89 44 24 08          	mov    %eax,0x8(%esp)
  801864:	8b 45 0c             	mov    0xc(%ebp),%eax
  801867:	01 d8                	add    %ebx,%eax
  801869:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186d:	89 3c 24             	mov    %edi,(%esp)
  801870:	e8 3f ff ff ff       	call   8017b4 <read>
		if (m < 0)
  801875:	85 c0                	test   %eax,%eax
  801877:	78 10                	js     801889 <readn+0x43>
			return m;
		if (m == 0)
  801879:	85 c0                	test   %eax,%eax
  80187b:	74 0a                	je     801887 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80187d:	01 c3                	add    %eax,%ebx
  80187f:	39 f3                	cmp    %esi,%ebx
  801881:	72 d9                	jb     80185c <readn+0x16>
  801883:	89 d8                	mov    %ebx,%eax
  801885:	eb 02                	jmp    801889 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801887:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801889:	83 c4 1c             	add    $0x1c,%esp
  80188c:	5b                   	pop    %ebx
  80188d:	5e                   	pop    %esi
  80188e:	5f                   	pop    %edi
  80188f:	5d                   	pop    %ebp
  801890:	c3                   	ret    

00801891 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	53                   	push   %ebx
  801895:	83 ec 24             	sub    $0x24,%esp
  801898:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80189b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a2:	89 1c 24             	mov    %ebx,(%esp)
  8018a5:	e8 6c fc ff ff       	call   801516 <fd_lookup>
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 6a                	js     801918 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b8:	8b 00                	mov    (%eax),%eax
  8018ba:	89 04 24             	mov    %eax,(%esp)
  8018bd:	e8 aa fc ff ff       	call   80156c <dev_lookup>
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	78 52                	js     801918 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018cd:	75 25                	jne    8018f4 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d4:	8b 00                	mov    (%eax),%eax
  8018d6:	8b 40 48             	mov    0x48(%eax),%eax
  8018d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e1:	c7 04 24 f1 2b 80 00 	movl   $0x802bf1,(%esp)
  8018e8:	e8 5b ea ff ff       	call   800348 <cprintf>
		return -E_INVAL;
  8018ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f2:	eb 24                	jmp    801918 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8018fa:	85 d2                	test   %edx,%edx
  8018fc:	74 15                	je     801913 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801901:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801905:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801908:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80190c:	89 04 24             	mov    %eax,(%esp)
  80190f:	ff d2                	call   *%edx
  801911:	eb 05                	jmp    801918 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801913:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801918:	83 c4 24             	add    $0x24,%esp
  80191b:	5b                   	pop    %ebx
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <seek>:

int
seek(int fdnum, off_t offset)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801924:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192b:	8b 45 08             	mov    0x8(%ebp),%eax
  80192e:	89 04 24             	mov    %eax,(%esp)
  801931:	e8 e0 fb ff ff       	call   801516 <fd_lookup>
  801936:	85 c0                	test   %eax,%eax
  801938:	78 0e                	js     801948 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80193a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80193d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801940:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	53                   	push   %ebx
  80194e:	83 ec 24             	sub    $0x24,%esp
  801951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801954:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195b:	89 1c 24             	mov    %ebx,(%esp)
  80195e:	e8 b3 fb ff ff       	call   801516 <fd_lookup>
  801963:	85 c0                	test   %eax,%eax
  801965:	78 63                	js     8019ca <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801967:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801971:	8b 00                	mov    (%eax),%eax
  801973:	89 04 24             	mov    %eax,(%esp)
  801976:	e8 f1 fb ff ff       	call   80156c <dev_lookup>
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 4b                	js     8019ca <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80197f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801982:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801986:	75 25                	jne    8019ad <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801988:	a1 04 40 80 00       	mov    0x804004,%eax
  80198d:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80198f:	8b 40 48             	mov    0x48(%eax),%eax
  801992:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801996:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199a:	c7 04 24 b4 2b 80 00 	movl   $0x802bb4,(%esp)
  8019a1:	e8 a2 e9 ff ff       	call   800348 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019ab:	eb 1d                	jmp    8019ca <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8019ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b0:	8b 52 18             	mov    0x18(%edx),%edx
  8019b3:	85 d2                	test   %edx,%edx
  8019b5:	74 0e                	je     8019c5 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ba:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019be:	89 04 24             	mov    %eax,(%esp)
  8019c1:	ff d2                	call   *%edx
  8019c3:	eb 05                	jmp    8019ca <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019ca:	83 c4 24             	add    $0x24,%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    

008019d0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	53                   	push   %ebx
  8019d4:	83 ec 24             	sub    $0x24,%esp
  8019d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	89 04 24             	mov    %eax,(%esp)
  8019e7:	e8 2a fb ff ff       	call   801516 <fd_lookup>
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 52                	js     801a42 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019fa:	8b 00                	mov    (%eax),%eax
  8019fc:	89 04 24             	mov    %eax,(%esp)
  8019ff:	e8 68 fb ff ff       	call   80156c <dev_lookup>
  801a04:	85 c0                	test   %eax,%eax
  801a06:	78 3a                	js     801a42 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a0f:	74 2c                	je     801a3d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a11:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a14:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a1b:	00 00 00 
	stat->st_isdir = 0;
  801a1e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a25:	00 00 00 
	stat->st_dev = dev;
  801a28:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a32:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a35:	89 14 24             	mov    %edx,(%esp)
  801a38:	ff 50 14             	call   *0x14(%eax)
  801a3b:	eb 05                	jmp    801a42 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a3d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a42:	83 c4 24             	add    $0x24,%esp
  801a45:	5b                   	pop    %ebx
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a57:	00 
  801a58:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5b:	89 04 24             	mov    %eax,(%esp)
  801a5e:	e8 88 02 00 00       	call   801ceb <open>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 1b                	js     801a84 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a70:	89 1c 24             	mov    %ebx,(%esp)
  801a73:	e8 58 ff ff ff       	call   8019d0 <fstat>
  801a78:	89 c6                	mov    %eax,%esi
	close(fd);
  801a7a:	89 1c 24             	mov    %ebx,(%esp)
  801a7d:	e8 ce fb ff ff       	call   801650 <close>
	return r;
  801a82:	89 f3                	mov    %esi,%ebx
}
  801a84:	89 d8                	mov    %ebx,%eax
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5e                   	pop    %esi
  801a8b:	5d                   	pop    %ebp
  801a8c:	c3                   	ret    
  801a8d:	00 00                	add    %al,(%eax)
	...

00801a90 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	83 ec 10             	sub    $0x10,%esp
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a9c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801aa3:	75 11                	jne    801ab6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801aac:	e8 82 09 00 00       	call   802433 <ipc_find_env>
  801ab1:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ab6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801abd:	00 
  801abe:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ac5:	00 
  801ac6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aca:	a1 00 40 80 00       	mov    0x804000,%eax
  801acf:	89 04 24             	mov    %eax,(%esp)
  801ad2:	e8 f6 08 00 00       	call   8023cd <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801ad7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ade:	00 
  801adf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aea:	e8 71 08 00 00       	call   802360 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801afc:	8b 45 08             	mov    0x8(%ebp),%eax
  801aff:	8b 40 0c             	mov    0xc(%eax),%eax
  801b02:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b14:	b8 02 00 00 00       	mov    $0x2,%eax
  801b19:	e8 72 ff ff ff       	call   801a90 <fsipc>
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b26:	8b 45 08             	mov    0x8(%ebp),%eax
  801b29:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b31:	ba 00 00 00 00       	mov    $0x0,%edx
  801b36:	b8 06 00 00 00       	mov    $0x6,%eax
  801b3b:	e8 50 ff ff ff       	call   801a90 <fsipc>
}
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    

00801b42 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	53                   	push   %ebx
  801b46:	83 ec 14             	sub    $0x14,%esp
  801b49:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b52:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b57:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5c:	b8 05 00 00 00       	mov    $0x5,%eax
  801b61:	e8 2a ff ff ff       	call   801a90 <fsipc>
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 2b                	js     801b95 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b6a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b71:	00 
  801b72:	89 1c 24             	mov    %ebx,(%esp)
  801b75:	e8 79 ed ff ff       	call   8008f3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b7a:	a1 80 50 80 00       	mov    0x805080,%eax
  801b7f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b85:	a1 84 50 80 00       	mov    0x805084,%eax
  801b8a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b95:	83 c4 14             	add    $0x14,%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	53                   	push   %ebx
  801b9f:	83 ec 14             	sub    $0x14,%esp
  801ba2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba8:	8b 40 0c             	mov    0xc(%eax),%eax
  801bab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801bb0:	89 d8                	mov    %ebx,%eax
  801bb2:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801bb8:	76 05                	jbe    801bbf <devfile_write+0x24>
  801bba:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801bbf:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801bc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcf:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801bd6:	e8 fb ee ff ff       	call   800ad6 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  801be0:	b8 04 00 00 00       	mov    $0x4,%eax
  801be5:	e8 a6 fe ff ff       	call   801a90 <fsipc>
  801bea:	85 c0                	test   %eax,%eax
  801bec:	78 53                	js     801c41 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801bee:	39 c3                	cmp    %eax,%ebx
  801bf0:	73 24                	jae    801c16 <devfile_write+0x7b>
  801bf2:	c7 44 24 0c 20 2c 80 	movl   $0x802c20,0xc(%esp)
  801bf9:	00 
  801bfa:	c7 44 24 08 27 2c 80 	movl   $0x802c27,0x8(%esp)
  801c01:	00 
  801c02:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801c09:	00 
  801c0a:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  801c11:	e8 3a e6 ff ff       	call   800250 <_panic>
	assert(r <= PGSIZE);
  801c16:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c1b:	7e 24                	jle    801c41 <devfile_write+0xa6>
  801c1d:	c7 44 24 0c 47 2c 80 	movl   $0x802c47,0xc(%esp)
  801c24:	00 
  801c25:	c7 44 24 08 27 2c 80 	movl   $0x802c27,0x8(%esp)
  801c2c:	00 
  801c2d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801c34:	00 
  801c35:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  801c3c:	e8 0f e6 ff ff       	call   800250 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801c41:	83 c4 14             	add    $0x14,%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	56                   	push   %esi
  801c4b:	53                   	push   %ebx
  801c4c:	83 ec 10             	sub    $0x10,%esp
  801c4f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c52:	8b 45 08             	mov    0x8(%ebp),%eax
  801c55:	8b 40 0c             	mov    0xc(%eax),%eax
  801c58:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c5d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c63:	ba 00 00 00 00       	mov    $0x0,%edx
  801c68:	b8 03 00 00 00       	mov    $0x3,%eax
  801c6d:	e8 1e fe ff ff       	call   801a90 <fsipc>
  801c72:	89 c3                	mov    %eax,%ebx
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 6a                	js     801ce2 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c78:	39 c6                	cmp    %eax,%esi
  801c7a:	73 24                	jae    801ca0 <devfile_read+0x59>
  801c7c:	c7 44 24 0c 20 2c 80 	movl   $0x802c20,0xc(%esp)
  801c83:	00 
  801c84:	c7 44 24 08 27 2c 80 	movl   $0x802c27,0x8(%esp)
  801c8b:	00 
  801c8c:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801c93:	00 
  801c94:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  801c9b:	e8 b0 e5 ff ff       	call   800250 <_panic>
	assert(r <= PGSIZE);
  801ca0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ca5:	7e 24                	jle    801ccb <devfile_read+0x84>
  801ca7:	c7 44 24 0c 47 2c 80 	movl   $0x802c47,0xc(%esp)
  801cae:	00 
  801caf:	c7 44 24 08 27 2c 80 	movl   $0x802c27,0x8(%esp)
  801cb6:	00 
  801cb7:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801cbe:	00 
  801cbf:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  801cc6:	e8 85 e5 ff ff       	call   800250 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ccb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ccf:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cd6:	00 
  801cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cda:	89 04 24             	mov    %eax,(%esp)
  801cdd:	e8 8a ed ff ff       	call   800a6c <memmove>
	return r;
}
  801ce2:	89 d8                	mov    %ebx,%eax
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	56                   	push   %esi
  801cef:	53                   	push   %ebx
  801cf0:	83 ec 20             	sub    $0x20,%esp
  801cf3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cf6:	89 34 24             	mov    %esi,(%esp)
  801cf9:	e8 c2 eb ff ff       	call   8008c0 <strlen>
  801cfe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d03:	7f 60                	jg     801d65 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d08:	89 04 24             	mov    %eax,(%esp)
  801d0b:	e8 b3 f7 ff ff       	call   8014c3 <fd_alloc>
  801d10:	89 c3                	mov    %eax,%ebx
  801d12:	85 c0                	test   %eax,%eax
  801d14:	78 54                	js     801d6a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d21:	e8 cd eb ff ff       	call   8008f3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d29:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d31:	b8 01 00 00 00       	mov    $0x1,%eax
  801d36:	e8 55 fd ff ff       	call   801a90 <fsipc>
  801d3b:	89 c3                	mov    %eax,%ebx
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	79 15                	jns    801d56 <open+0x6b>
		fd_close(fd, 0);
  801d41:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d48:	00 
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	89 04 24             	mov    %eax,(%esp)
  801d4f:	e8 74 f8 ff ff       	call   8015c8 <fd_close>
		return r;
  801d54:	eb 14                	jmp    801d6a <open+0x7f>
	}

	return fd2num(fd);
  801d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d59:	89 04 24             	mov    %eax,(%esp)
  801d5c:	e8 37 f7 ff ff       	call   801498 <fd2num>
  801d61:	89 c3                	mov    %eax,%ebx
  801d63:	eb 05                	jmp    801d6a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d65:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d6a:	89 d8                	mov    %ebx,%eax
  801d6c:	83 c4 20             	add    $0x20,%esp
  801d6f:	5b                   	pop    %ebx
  801d70:	5e                   	pop    %esi
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    

00801d73 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d79:	ba 00 00 00 00       	mov    $0x0,%edx
  801d7e:	b8 08 00 00 00       	mov    $0x8,%eax
  801d83:	e8 08 fd ff ff       	call   801a90 <fsipc>
}
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    
	...

00801d8c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	56                   	push   %esi
  801d90:	53                   	push   %ebx
  801d91:	83 ec 10             	sub    $0x10,%esp
  801d94:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d97:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9a:	89 04 24             	mov    %eax,(%esp)
  801d9d:	e8 06 f7 ff ff       	call   8014a8 <fd2data>
  801da2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801da4:	c7 44 24 04 53 2c 80 	movl   $0x802c53,0x4(%esp)
  801dab:	00 
  801dac:	89 34 24             	mov    %esi,(%esp)
  801daf:	e8 3f eb ff ff       	call   8008f3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801db4:	8b 43 04             	mov    0x4(%ebx),%eax
  801db7:	2b 03                	sub    (%ebx),%eax
  801db9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801dbf:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801dc6:	00 00 00 
	stat->st_dev = &devpipe;
  801dc9:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801dd0:	30 80 00 
	return 0;
}
  801dd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5e                   	pop    %esi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    

00801ddf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	53                   	push   %ebx
  801de3:	83 ec 14             	sub    $0x14,%esp
  801de6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801de9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ded:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df4:	e8 93 ef ff ff       	call   800d8c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801df9:	89 1c 24             	mov    %ebx,(%esp)
  801dfc:	e8 a7 f6 ff ff       	call   8014a8 <fd2data>
  801e01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0c:	e8 7b ef ff ff       	call   800d8c <sys_page_unmap>
}
  801e11:	83 c4 14             	add    $0x14,%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5d                   	pop    %ebp
  801e16:	c3                   	ret    

00801e17 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	57                   	push   %edi
  801e1b:	56                   	push   %esi
  801e1c:	53                   	push   %ebx
  801e1d:	83 ec 2c             	sub    $0x2c,%esp
  801e20:	89 c7                	mov    %eax,%edi
  801e22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e25:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2a:	8b 00                	mov    (%eax),%eax
  801e2c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e2f:	89 3c 24             	mov    %edi,(%esp)
  801e32:	e8 41 06 00 00       	call   802478 <pageref>
  801e37:	89 c6                	mov    %eax,%esi
  801e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e3c:	89 04 24             	mov    %eax,(%esp)
  801e3f:	e8 34 06 00 00       	call   802478 <pageref>
  801e44:	39 c6                	cmp    %eax,%esi
  801e46:	0f 94 c0             	sete   %al
  801e49:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e4c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e52:	8b 12                	mov    (%edx),%edx
  801e54:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e57:	39 cb                	cmp    %ecx,%ebx
  801e59:	75 08                	jne    801e63 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e5b:	83 c4 2c             	add    $0x2c,%esp
  801e5e:	5b                   	pop    %ebx
  801e5f:	5e                   	pop    %esi
  801e60:	5f                   	pop    %edi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e63:	83 f8 01             	cmp    $0x1,%eax
  801e66:	75 bd                	jne    801e25 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e68:	8b 42 58             	mov    0x58(%edx),%eax
  801e6b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801e72:	00 
  801e73:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e7b:	c7 04 24 5a 2c 80 00 	movl   $0x802c5a,(%esp)
  801e82:	e8 c1 e4 ff ff       	call   800348 <cprintf>
  801e87:	eb 9c                	jmp    801e25 <_pipeisclosed+0xe>

00801e89 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	57                   	push   %edi
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	83 ec 1c             	sub    $0x1c,%esp
  801e92:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e95:	89 34 24             	mov    %esi,(%esp)
  801e98:	e8 0b f6 ff ff       	call   8014a8 <fd2data>
  801e9d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e9f:	bf 00 00 00 00       	mov    $0x0,%edi
  801ea4:	eb 3c                	jmp    801ee2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ea6:	89 da                	mov    %ebx,%edx
  801ea8:	89 f0                	mov    %esi,%eax
  801eaa:	e8 68 ff ff ff       	call   801e17 <_pipeisclosed>
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	75 38                	jne    801eeb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801eb3:	e8 0e ee ff ff       	call   800cc6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eb8:	8b 43 04             	mov    0x4(%ebx),%eax
  801ebb:	8b 13                	mov    (%ebx),%edx
  801ebd:	83 c2 20             	add    $0x20,%edx
  801ec0:	39 d0                	cmp    %edx,%eax
  801ec2:	73 e2                	jae    801ea6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ec4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801eca:	89 c2                	mov    %eax,%edx
  801ecc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ed2:	79 05                	jns    801ed9 <devpipe_write+0x50>
  801ed4:	4a                   	dec    %edx
  801ed5:	83 ca e0             	or     $0xffffffe0,%edx
  801ed8:	42                   	inc    %edx
  801ed9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801edd:	40                   	inc    %eax
  801ede:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee1:	47                   	inc    %edi
  801ee2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ee5:	75 d1                	jne    801eb8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ee7:	89 f8                	mov    %edi,%eax
  801ee9:	eb 05                	jmp    801ef0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eeb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ef0:	83 c4 1c             	add    $0x1c,%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5f                   	pop    %edi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	57                   	push   %edi
  801efc:	56                   	push   %esi
  801efd:	53                   	push   %ebx
  801efe:	83 ec 1c             	sub    $0x1c,%esp
  801f01:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f04:	89 3c 24             	mov    %edi,(%esp)
  801f07:	e8 9c f5 ff ff       	call   8014a8 <fd2data>
  801f0c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f0e:	be 00 00 00 00       	mov    $0x0,%esi
  801f13:	eb 3a                	jmp    801f4f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f15:	85 f6                	test   %esi,%esi
  801f17:	74 04                	je     801f1d <devpipe_read+0x25>
				return i;
  801f19:	89 f0                	mov    %esi,%eax
  801f1b:	eb 40                	jmp    801f5d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f1d:	89 da                	mov    %ebx,%edx
  801f1f:	89 f8                	mov    %edi,%eax
  801f21:	e8 f1 fe ff ff       	call   801e17 <_pipeisclosed>
  801f26:	85 c0                	test   %eax,%eax
  801f28:	75 2e                	jne    801f58 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f2a:	e8 97 ed ff ff       	call   800cc6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f2f:	8b 03                	mov    (%ebx),%eax
  801f31:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f34:	74 df                	je     801f15 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f36:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f3b:	79 05                	jns    801f42 <devpipe_read+0x4a>
  801f3d:	48                   	dec    %eax
  801f3e:	83 c8 e0             	or     $0xffffffe0,%eax
  801f41:	40                   	inc    %eax
  801f42:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f49:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f4c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4e:	46                   	inc    %esi
  801f4f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f52:	75 db                	jne    801f2f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f54:	89 f0                	mov    %esi,%eax
  801f56:	eb 05                	jmp    801f5d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f58:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f5d:	83 c4 1c             	add    $0x1c,%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5e                   	pop    %esi
  801f62:	5f                   	pop    %edi
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    

00801f65 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	57                   	push   %edi
  801f69:	56                   	push   %esi
  801f6a:	53                   	push   %ebx
  801f6b:	83 ec 3c             	sub    $0x3c,%esp
  801f6e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f74:	89 04 24             	mov    %eax,(%esp)
  801f77:	e8 47 f5 ff ff       	call   8014c3 <fd_alloc>
  801f7c:	89 c3                	mov    %eax,%ebx
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	0f 88 45 01 00 00    	js     8020cb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f86:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f8d:	00 
  801f8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9c:	e8 44 ed ff ff       	call   800ce5 <sys_page_alloc>
  801fa1:	89 c3                	mov    %eax,%ebx
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	0f 88 20 01 00 00    	js     8020cb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fab:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 0d f5 ff ff       	call   8014c3 <fd_alloc>
  801fb6:	89 c3                	mov    %eax,%ebx
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	0f 88 f8 00 00 00    	js     8020b8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fc7:	00 
  801fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd6:	e8 0a ed ff ff       	call   800ce5 <sys_page_alloc>
  801fdb:	89 c3                	mov    %eax,%ebx
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	0f 88 d3 00 00 00    	js     8020b8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fe5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fe8:	89 04 24             	mov    %eax,(%esp)
  801feb:	e8 b8 f4 ff ff       	call   8014a8 <fd2data>
  801ff0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ff9:	00 
  801ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802005:	e8 db ec ff ff       	call   800ce5 <sys_page_alloc>
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	85 c0                	test   %eax,%eax
  80200e:	0f 88 91 00 00 00    	js     8020a5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802014:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802017:	89 04 24             	mov    %eax,(%esp)
  80201a:	e8 89 f4 ff ff       	call   8014a8 <fd2data>
  80201f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802026:	00 
  802027:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802032:	00 
  802033:	89 74 24 04          	mov    %esi,0x4(%esp)
  802037:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80203e:	e8 f6 ec ff ff       	call   800d39 <sys_page_map>
  802043:	89 c3                	mov    %eax,%ebx
  802045:	85 c0                	test   %eax,%eax
  802047:	78 4c                	js     802095 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802049:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80204f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802052:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802057:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80205e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802064:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802067:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802069:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80206c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802076:	89 04 24             	mov    %eax,(%esp)
  802079:	e8 1a f4 ff ff       	call   801498 <fd2num>
  80207e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802080:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802083:	89 04 24             	mov    %eax,(%esp)
  802086:	e8 0d f4 ff ff       	call   801498 <fd2num>
  80208b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80208e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802093:	eb 36                	jmp    8020cb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802095:	89 74 24 04          	mov    %esi,0x4(%esp)
  802099:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a0:	e8 e7 ec ff ff       	call   800d8c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b3:	e8 d4 ec ff ff       	call   800d8c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c6:	e8 c1 ec ff ff       	call   800d8c <sys_page_unmap>
    err:
	return r;
}
  8020cb:	89 d8                	mov    %ebx,%eax
  8020cd:	83 c4 3c             	add    $0x3c,%esp
  8020d0:	5b                   	pop    %ebx
  8020d1:	5e                   	pop    %esi
  8020d2:	5f                   	pop    %edi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    

008020d5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 29 f4 ff ff       	call   801516 <fd_lookup>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 15                	js     802106 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f4:	89 04 24             	mov    %eax,(%esp)
  8020f7:	e8 ac f3 ff ff       	call   8014a8 <fd2data>
	return _pipeisclosed(fd, p);
  8020fc:	89 c2                	mov    %eax,%edx
  8020fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802101:	e8 11 fd ff ff       	call   801e17 <_pipeisclosed>
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80210b:	b8 00 00 00 00       	mov    $0x0,%eax
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    

00802112 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802118:	c7 44 24 04 72 2c 80 	movl   $0x802c72,0x4(%esp)
  80211f:	00 
  802120:	8b 45 0c             	mov    0xc(%ebp),%eax
  802123:	89 04 24             	mov    %eax,(%esp)
  802126:	e8 c8 e7 ff ff       	call   8008f3 <strcpy>
	return 0;
}
  80212b:	b8 00 00 00 00       	mov    $0x0,%eax
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80213e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802143:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802149:	eb 30                	jmp    80217b <devcons_write+0x49>
		m = n - tot;
  80214b:	8b 75 10             	mov    0x10(%ebp),%esi
  80214e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802150:	83 fe 7f             	cmp    $0x7f,%esi
  802153:	76 05                	jbe    80215a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802155:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80215a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80215e:	03 45 0c             	add    0xc(%ebp),%eax
  802161:	89 44 24 04          	mov    %eax,0x4(%esp)
  802165:	89 3c 24             	mov    %edi,(%esp)
  802168:	e8 ff e8 ff ff       	call   800a6c <memmove>
		sys_cputs(buf, m);
  80216d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802171:	89 3c 24             	mov    %edi,(%esp)
  802174:	e8 9f ea ff ff       	call   800c18 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802179:	01 f3                	add    %esi,%ebx
  80217b:	89 d8                	mov    %ebx,%eax
  80217d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802180:	72 c9                	jb     80214b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802182:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    

0080218d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
  802190:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802193:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802197:	75 07                	jne    8021a0 <devcons_read+0x13>
  802199:	eb 25                	jmp    8021c0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80219b:	e8 26 eb ff ff       	call   800cc6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021a0:	e8 91 ea ff ff       	call   800c36 <sys_cgetc>
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	74 f2                	je     80219b <devcons_read+0xe>
  8021a9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	78 1d                	js     8021cc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021af:	83 f8 04             	cmp    $0x4,%eax
  8021b2:	74 13                	je     8021c7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b7:	88 10                	mov    %dl,(%eax)
	return 1;
  8021b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8021be:	eb 0c                	jmp    8021cc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c5:	eb 05                	jmp    8021cc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021c7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021cc:	c9                   	leave  
  8021cd:	c3                   	ret    

008021ce <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
  8021d1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021e1:	00 
  8021e2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021e5:	89 04 24             	mov    %eax,(%esp)
  8021e8:	e8 2b ea ff ff       	call   800c18 <sys_cputs>
}
  8021ed:	c9                   	leave  
  8021ee:	c3                   	ret    

008021ef <getchar>:

int
getchar(void)
{
  8021ef:	55                   	push   %ebp
  8021f0:	89 e5                	mov    %esp,%ebp
  8021f2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021f5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021fc:	00 
  8021fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802200:	89 44 24 04          	mov    %eax,0x4(%esp)
  802204:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80220b:	e8 a4 f5 ff ff       	call   8017b4 <read>
	if (r < 0)
  802210:	85 c0                	test   %eax,%eax
  802212:	78 0f                	js     802223 <getchar+0x34>
		return r;
	if (r < 1)
  802214:	85 c0                	test   %eax,%eax
  802216:	7e 06                	jle    80221e <getchar+0x2f>
		return -E_EOF;
	return c;
  802218:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80221c:	eb 05                	jmp    802223 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80221e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802223:	c9                   	leave  
  802224:	c3                   	ret    

00802225 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80222b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802232:	8b 45 08             	mov    0x8(%ebp),%eax
  802235:	89 04 24             	mov    %eax,(%esp)
  802238:	e8 d9 f2 ff ff       	call   801516 <fd_lookup>
  80223d:	85 c0                	test   %eax,%eax
  80223f:	78 11                	js     802252 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802244:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80224a:	39 10                	cmp    %edx,(%eax)
  80224c:	0f 94 c0             	sete   %al
  80224f:	0f b6 c0             	movzbl %al,%eax
}
  802252:	c9                   	leave  
  802253:	c3                   	ret    

00802254 <opencons>:

int
opencons(void)
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80225a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225d:	89 04 24             	mov    %eax,(%esp)
  802260:	e8 5e f2 ff ff       	call   8014c3 <fd_alloc>
  802265:	85 c0                	test   %eax,%eax
  802267:	78 3c                	js     8022a5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802269:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802270:	00 
  802271:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802274:	89 44 24 04          	mov    %eax,0x4(%esp)
  802278:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80227f:	e8 61 ea ff ff       	call   800ce5 <sys_page_alloc>
  802284:	85 c0                	test   %eax,%eax
  802286:	78 1d                	js     8022a5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802288:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80228e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802291:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802293:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802296:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80229d:	89 04 24             	mov    %eax,(%esp)
  8022a0:	e8 f3 f1 ff ff       	call   801498 <fd2num>
}
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    
	...

008022a8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	53                   	push   %ebx
  8022ac:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022af:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8022b6:	75 6f                	jne    802327 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8022b8:	e8 ea e9 ff ff       	call   800ca7 <sys_getenvid>
  8022bd:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8022bf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022c6:	00 
  8022c7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8022ce:	ee 
  8022cf:	89 04 24             	mov    %eax,(%esp)
  8022d2:	e8 0e ea ff ff       	call   800ce5 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  8022d7:	85 c0                	test   %eax,%eax
  8022d9:	79 1c                	jns    8022f7 <set_pgfault_handler+0x4f>
  8022db:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  8022e2:	00 
  8022e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8022ea:	00 
  8022eb:	c7 04 24 dc 2c 80 00 	movl   $0x802cdc,(%esp)
  8022f2:	e8 59 df ff ff       	call   800250 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8022f7:	c7 44 24 04 38 23 80 	movl   $0x802338,0x4(%esp)
  8022fe:	00 
  8022ff:	89 1c 24             	mov    %ebx,(%esp)
  802302:	e8 7e eb ff ff       	call   800e85 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  802307:	85 c0                	test   %eax,%eax
  802309:	79 1c                	jns    802327 <set_pgfault_handler+0x7f>
  80230b:	c7 44 24 08 a8 2c 80 	movl   $0x802ca8,0x8(%esp)
  802312:	00 
  802313:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80231a:	00 
  80231b:	c7 04 24 dc 2c 80 00 	movl   $0x802cdc,(%esp)
  802322:	e8 29 df ff ff       	call   800250 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802327:	8b 45 08             	mov    0x8(%ebp),%eax
  80232a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80232f:	83 c4 14             	add    $0x14,%esp
  802332:	5b                   	pop    %ebx
  802333:	5d                   	pop    %ebp
  802334:	c3                   	ret    
  802335:	00 00                	add    %al,(%eax)
	...

00802338 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802338:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802339:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80233e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802340:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  802343:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  802347:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  80234c:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  802350:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  802352:	83 c4 08             	add    $0x8,%esp
	popal
  802355:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  802356:	83 c4 04             	add    $0x4,%esp
	popfl
  802359:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  80235a:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80235d:	c3                   	ret    
	...

00802360 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
  802363:	56                   	push   %esi
  802364:	53                   	push   %ebx
  802365:	83 ec 10             	sub    $0x10,%esp
  802368:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80236b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802371:	85 c0                	test   %eax,%eax
  802373:	75 05                	jne    80237a <ipc_recv+0x1a>
  802375:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  80237a:	89 04 24             	mov    %eax,(%esp)
  80237d:	e8 79 eb ff ff       	call   800efb <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  802382:	85 c0                	test   %eax,%eax
  802384:	79 16                	jns    80239c <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  802386:	85 db                	test   %ebx,%ebx
  802388:	74 06                	je     802390 <ipc_recv+0x30>
  80238a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  802390:	85 f6                	test   %esi,%esi
  802392:	74 32                	je     8023c6 <ipc_recv+0x66>
  802394:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80239a:	eb 2a                	jmp    8023c6 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80239c:	85 db                	test   %ebx,%ebx
  80239e:	74 0c                	je     8023ac <ipc_recv+0x4c>
  8023a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8023a5:	8b 00                	mov    (%eax),%eax
  8023a7:	8b 40 74             	mov    0x74(%eax),%eax
  8023aa:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8023ac:	85 f6                	test   %esi,%esi
  8023ae:	74 0c                	je     8023bc <ipc_recv+0x5c>
  8023b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8023b5:	8b 00                	mov    (%eax),%eax
  8023b7:	8b 40 78             	mov    0x78(%eax),%eax
  8023ba:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  8023bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8023c1:	8b 00                	mov    (%eax),%eax
  8023c3:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8023c6:	83 c4 10             	add    $0x10,%esp
  8023c9:	5b                   	pop    %ebx
  8023ca:	5e                   	pop    %esi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    

008023cd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023cd:	55                   	push   %ebp
  8023ce:	89 e5                	mov    %esp,%ebp
  8023d0:	57                   	push   %edi
  8023d1:	56                   	push   %esi
  8023d2:	53                   	push   %ebx
  8023d3:	83 ec 1c             	sub    $0x1c,%esp
  8023d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023dc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8023df:	85 db                	test   %ebx,%ebx
  8023e1:	75 05                	jne    8023e8 <ipc_send+0x1b>
  8023e3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8023e8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8023ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f7:	89 04 24             	mov    %eax,(%esp)
  8023fa:	e8 d9 ea ff ff       	call   800ed8 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8023ff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802402:	75 07                	jne    80240b <ipc_send+0x3e>
  802404:	e8 bd e8 ff ff       	call   800cc6 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  802409:	eb dd                	jmp    8023e8 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  80240b:	85 c0                	test   %eax,%eax
  80240d:	79 1c                	jns    80242b <ipc_send+0x5e>
  80240f:	c7 44 24 08 ea 2c 80 	movl   $0x802cea,0x8(%esp)
  802416:	00 
  802417:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80241e:	00 
  80241f:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  802426:	e8 25 de ff ff       	call   800250 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  80242b:	83 c4 1c             	add    $0x1c,%esp
  80242e:	5b                   	pop    %ebx
  80242f:	5e                   	pop    %esi
  802430:	5f                   	pop    %edi
  802431:	5d                   	pop    %ebp
  802432:	c3                   	ret    

00802433 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802433:	55                   	push   %ebp
  802434:	89 e5                	mov    %esp,%ebp
  802436:	53                   	push   %ebx
  802437:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80243a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80243f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802446:	89 c2                	mov    %eax,%edx
  802448:	c1 e2 07             	shl    $0x7,%edx
  80244b:	29 ca                	sub    %ecx,%edx
  80244d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802453:	8b 52 50             	mov    0x50(%edx),%edx
  802456:	39 da                	cmp    %ebx,%edx
  802458:	75 0f                	jne    802469 <ipc_find_env+0x36>
			return envs[i].env_id;
  80245a:	c1 e0 07             	shl    $0x7,%eax
  80245d:	29 c8                	sub    %ecx,%eax
  80245f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802464:	8b 40 40             	mov    0x40(%eax),%eax
  802467:	eb 0c                	jmp    802475 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802469:	40                   	inc    %eax
  80246a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80246f:	75 ce                	jne    80243f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802471:	66 b8 00 00          	mov    $0x0,%ax
}
  802475:	5b                   	pop    %ebx
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    

00802478 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802478:	55                   	push   %ebp
  802479:	89 e5                	mov    %esp,%ebp
  80247b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  80247e:	89 c2                	mov    %eax,%edx
  802480:	c1 ea 16             	shr    $0x16,%edx
  802483:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80248a:	f6 c2 01             	test   $0x1,%dl
  80248d:	74 1e                	je     8024ad <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80248f:	c1 e8 0c             	shr    $0xc,%eax
  802492:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802499:	a8 01                	test   $0x1,%al
  80249b:	74 17                	je     8024b4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80249d:	c1 e8 0c             	shr    $0xc,%eax
  8024a0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8024a7:	ef 
  8024a8:	0f b7 c0             	movzwl %ax,%eax
  8024ab:	eb 0c                	jmp    8024b9 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8024ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b2:	eb 05                	jmp    8024b9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8024b4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8024b9:	5d                   	pop    %ebp
  8024ba:	c3                   	ret    
	...

008024bc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8024bc:	55                   	push   %ebp
  8024bd:	57                   	push   %edi
  8024be:	56                   	push   %esi
  8024bf:	83 ec 10             	sub    $0x10,%esp
  8024c2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8024c6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024ce:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8024d2:	89 cd                	mov    %ecx,%ebp
  8024d4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024d8:	85 c0                	test   %eax,%eax
  8024da:	75 2c                	jne    802508 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8024dc:	39 f9                	cmp    %edi,%ecx
  8024de:	77 68                	ja     802548 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024e0:	85 c9                	test   %ecx,%ecx
  8024e2:	75 0b                	jne    8024ef <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e9:	31 d2                	xor    %edx,%edx
  8024eb:	f7 f1                	div    %ecx
  8024ed:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024ef:	31 d2                	xor    %edx,%edx
  8024f1:	89 f8                	mov    %edi,%eax
  8024f3:	f7 f1                	div    %ecx
  8024f5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024f7:	89 f0                	mov    %esi,%eax
  8024f9:	f7 f1                	div    %ecx
  8024fb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024fd:	89 f0                	mov    %esi,%eax
  8024ff:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802501:	83 c4 10             	add    $0x10,%esp
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802508:	39 f8                	cmp    %edi,%eax
  80250a:	77 2c                	ja     802538 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80250c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80250f:	83 f6 1f             	xor    $0x1f,%esi
  802512:	75 4c                	jne    802560 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802514:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802516:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80251b:	72 0a                	jb     802527 <__udivdi3+0x6b>
  80251d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802521:	0f 87 ad 00 00 00    	ja     8025d4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802527:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80252c:	89 f0                	mov    %esi,%eax
  80252e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802530:	83 c4 10             	add    $0x10,%esp
  802533:	5e                   	pop    %esi
  802534:	5f                   	pop    %edi
  802535:	5d                   	pop    %ebp
  802536:	c3                   	ret    
  802537:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802538:	31 ff                	xor    %edi,%edi
  80253a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80253c:	89 f0                	mov    %esi,%eax
  80253e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802540:	83 c4 10             	add    $0x10,%esp
  802543:	5e                   	pop    %esi
  802544:	5f                   	pop    %edi
  802545:	5d                   	pop    %ebp
  802546:	c3                   	ret    
  802547:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802548:	89 fa                	mov    %edi,%edx
  80254a:	89 f0                	mov    %esi,%eax
  80254c:	f7 f1                	div    %ecx
  80254e:	89 c6                	mov    %eax,%esi
  802550:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802552:	89 f0                	mov    %esi,%eax
  802554:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802556:	83 c4 10             	add    $0x10,%esp
  802559:	5e                   	pop    %esi
  80255a:	5f                   	pop    %edi
  80255b:	5d                   	pop    %ebp
  80255c:	c3                   	ret    
  80255d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802560:	89 f1                	mov    %esi,%ecx
  802562:	d3 e0                	shl    %cl,%eax
  802564:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802568:	b8 20 00 00 00       	mov    $0x20,%eax
  80256d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80256f:	89 ea                	mov    %ebp,%edx
  802571:	88 c1                	mov    %al,%cl
  802573:	d3 ea                	shr    %cl,%edx
  802575:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802579:	09 ca                	or     %ecx,%edx
  80257b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80257f:	89 f1                	mov    %esi,%ecx
  802581:	d3 e5                	shl    %cl,%ebp
  802583:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802587:	89 fd                	mov    %edi,%ebp
  802589:	88 c1                	mov    %al,%cl
  80258b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80258d:	89 fa                	mov    %edi,%edx
  80258f:	89 f1                	mov    %esi,%ecx
  802591:	d3 e2                	shl    %cl,%edx
  802593:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802597:	88 c1                	mov    %al,%cl
  802599:	d3 ef                	shr    %cl,%edi
  80259b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80259d:	89 f8                	mov    %edi,%eax
  80259f:	89 ea                	mov    %ebp,%edx
  8025a1:	f7 74 24 08          	divl   0x8(%esp)
  8025a5:	89 d1                	mov    %edx,%ecx
  8025a7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8025a9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025ad:	39 d1                	cmp    %edx,%ecx
  8025af:	72 17                	jb     8025c8 <__udivdi3+0x10c>
  8025b1:	74 09                	je     8025bc <__udivdi3+0x100>
  8025b3:	89 fe                	mov    %edi,%esi
  8025b5:	31 ff                	xor    %edi,%edi
  8025b7:	e9 41 ff ff ff       	jmp    8024fd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8025bc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025c0:	89 f1                	mov    %esi,%ecx
  8025c2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025c4:	39 c2                	cmp    %eax,%edx
  8025c6:	73 eb                	jae    8025b3 <__udivdi3+0xf7>
		{
		  q0--;
  8025c8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025cb:	31 ff                	xor    %edi,%edi
  8025cd:	e9 2b ff ff ff       	jmp    8024fd <__udivdi3+0x41>
  8025d2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025d4:	31 f6                	xor    %esi,%esi
  8025d6:	e9 22 ff ff ff       	jmp    8024fd <__udivdi3+0x41>
	...

008025dc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8025dc:	55                   	push   %ebp
  8025dd:	57                   	push   %edi
  8025de:	56                   	push   %esi
  8025df:	83 ec 20             	sub    $0x20,%esp
  8025e2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025e6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025ea:	89 44 24 14          	mov    %eax,0x14(%esp)
  8025ee:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8025f2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025f6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8025fa:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8025fc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025fe:	85 ed                	test   %ebp,%ebp
  802600:	75 16                	jne    802618 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802602:	39 f1                	cmp    %esi,%ecx
  802604:	0f 86 a6 00 00 00    	jbe    8026b0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80260a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80260c:	89 d0                	mov    %edx,%eax
  80260e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802610:	83 c4 20             	add    $0x20,%esp
  802613:	5e                   	pop    %esi
  802614:	5f                   	pop    %edi
  802615:	5d                   	pop    %ebp
  802616:	c3                   	ret    
  802617:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802618:	39 f5                	cmp    %esi,%ebp
  80261a:	0f 87 ac 00 00 00    	ja     8026cc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802620:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802623:	83 f0 1f             	xor    $0x1f,%eax
  802626:	89 44 24 10          	mov    %eax,0x10(%esp)
  80262a:	0f 84 a8 00 00 00    	je     8026d8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802630:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802634:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802636:	bf 20 00 00 00       	mov    $0x20,%edi
  80263b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80263f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802643:	89 f9                	mov    %edi,%ecx
  802645:	d3 e8                	shr    %cl,%eax
  802647:	09 e8                	or     %ebp,%eax
  802649:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80264d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802651:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802655:	d3 e0                	shl    %cl,%eax
  802657:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80265b:	89 f2                	mov    %esi,%edx
  80265d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80265f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802663:	d3 e0                	shl    %cl,%eax
  802665:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802669:	8b 44 24 14          	mov    0x14(%esp),%eax
  80266d:	89 f9                	mov    %edi,%ecx
  80266f:	d3 e8                	shr    %cl,%eax
  802671:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802673:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802675:	89 f2                	mov    %esi,%edx
  802677:	f7 74 24 18          	divl   0x18(%esp)
  80267b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80267d:	f7 64 24 0c          	mull   0xc(%esp)
  802681:	89 c5                	mov    %eax,%ebp
  802683:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802685:	39 d6                	cmp    %edx,%esi
  802687:	72 67                	jb     8026f0 <__umoddi3+0x114>
  802689:	74 75                	je     802700 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80268b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80268f:	29 e8                	sub    %ebp,%eax
  802691:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802693:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802697:	d3 e8                	shr    %cl,%eax
  802699:	89 f2                	mov    %esi,%edx
  80269b:	89 f9                	mov    %edi,%ecx
  80269d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80269f:	09 d0                	or     %edx,%eax
  8026a1:	89 f2                	mov    %esi,%edx
  8026a3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026a7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026a9:	83 c4 20             	add    $0x20,%esp
  8026ac:	5e                   	pop    %esi
  8026ad:	5f                   	pop    %edi
  8026ae:	5d                   	pop    %ebp
  8026af:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026b0:	85 c9                	test   %ecx,%ecx
  8026b2:	75 0b                	jne    8026bf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8026b9:	31 d2                	xor    %edx,%edx
  8026bb:	f7 f1                	div    %ecx
  8026bd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8026bf:	89 f0                	mov    %esi,%eax
  8026c1:	31 d2                	xor    %edx,%edx
  8026c3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026c5:	89 f8                	mov    %edi,%eax
  8026c7:	e9 3e ff ff ff       	jmp    80260a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8026cc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026ce:	83 c4 20             	add    $0x20,%esp
  8026d1:	5e                   	pop    %esi
  8026d2:	5f                   	pop    %edi
  8026d3:	5d                   	pop    %ebp
  8026d4:	c3                   	ret    
  8026d5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026d8:	39 f5                	cmp    %esi,%ebp
  8026da:	72 04                	jb     8026e0 <__umoddi3+0x104>
  8026dc:	39 f9                	cmp    %edi,%ecx
  8026de:	77 06                	ja     8026e6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8026e0:	89 f2                	mov    %esi,%edx
  8026e2:	29 cf                	sub    %ecx,%edi
  8026e4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8026e6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026e8:	83 c4 20             	add    $0x20,%esp
  8026eb:	5e                   	pop    %esi
  8026ec:	5f                   	pop    %edi
  8026ed:	5d                   	pop    %ebp
  8026ee:	c3                   	ret    
  8026ef:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026f0:	89 d1                	mov    %edx,%ecx
  8026f2:	89 c5                	mov    %eax,%ebp
  8026f4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8026f8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8026fc:	eb 8d                	jmp    80268b <__umoddi3+0xaf>
  8026fe:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802700:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802704:	72 ea                	jb     8026f0 <__umoddi3+0x114>
  802706:	89 f1                	mov    %esi,%ecx
  802708:	eb 81                	jmp    80268b <__umoddi3+0xaf>
