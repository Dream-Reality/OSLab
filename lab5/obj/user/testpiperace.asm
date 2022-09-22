
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 ff 01 00 00       	call   800230 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003c:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  800043:	e8 54 03 00 00       	call   80039c <cprintf>
	if ((r = pipe(p)) < 0)
  800048:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80004b:	89 04 24             	mov    %eax,(%esp)
  80004e:	e8 c2 20 00 00       	call   802115 <pipe>
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", r);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 79 27 80 	movl   $0x802779,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 82 27 80 00 	movl   $0x802782,(%esp)
  800072:	e8 2d 02 00 00       	call   8002a4 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800077:	e8 60 11 00 00       	call   8011dc <fork>
  80007c:	89 c6                	mov    %eax,%esi
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 96 27 80 	movl   $0x802796,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 82 27 80 00 	movl   $0x802782,(%esp)
  80009d:	e8 02 02 00 00       	call   8002a4 <_panic>
	if (r == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	75 54                	jne    8000fa <umain+0xc6>
		close(p[1]);
  8000a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a9:	89 04 24             	mov    %eax,(%esp)
  8000ac:	e8 0b 17 00 00       	call   8017bc <close>
  8000b1:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  8000b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 c4 21 00 00       	call   802285 <pipeisclosed>
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	74 11                	je     8000d6 <umain+0xa2>
				cprintf("RACE: pipe appears closed\n");
  8000c5:	c7 04 24 9f 27 80 00 	movl   $0x80279f,(%esp)
  8000cc:	e8 cb 02 00 00       	call   80039c <cprintf>
				exit();
  8000d1:	e8 b2 01 00 00       	call   800288 <exit>
			}
			sys_yield();
  8000d6:	e8 3f 0c 00 00       	call   800d1a <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000db:	4b                   	dec    %ebx
  8000dc:	75 d8                	jne    8000b6 <umain+0x82>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 f2 13 00 00       	call   8014ec <ipc_recv>
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000fe:	c7 04 24 ba 27 80 00 	movl   $0x8027ba,(%esp)
  800105:	e8 92 02 00 00       	call   80039c <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  80010a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800110:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800117:	c1 e6 07             	shl    $0x7,%esi
  80011a:	29 c6                	sub    %eax,%esi
	cprintf("kid is %d\n", kid-envs);
  80011c:	8d 9e 00 00 c0 ee    	lea    -0x11400000(%esi),%ebx
  800122:	c1 fe 02             	sar    $0x2,%esi
  800125:	89 f2                	mov    %esi,%edx
  800127:	c1 e2 05             	shl    $0x5,%edx
  80012a:	89 f0                	mov    %esi,%eax
  80012c:	c1 e0 0a             	shl    $0xa,%eax
  80012f:	01 d0                	add    %edx,%eax
  800131:	01 f0                	add    %esi,%eax
  800133:	89 c2                	mov    %eax,%edx
  800135:	c1 e2 0f             	shl    $0xf,%edx
  800138:	01 d0                	add    %edx,%eax
  80013a:	c1 e0 05             	shl    $0x5,%eax
  80013d:	01 c6                	add    %eax,%esi
  80013f:	f7 de                	neg    %esi
  800141:	89 74 24 04          	mov    %esi,0x4(%esp)
  800145:	c7 04 24 c5 27 80 00 	movl   $0x8027c5,(%esp)
  80014c:	e8 4b 02 00 00       	call   80039c <cprintf>
	dup(p[0], 10);
  800151:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800158:	00 
  800159:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 a9 16 00 00       	call   80180d <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800164:	eb 13                	jmp    800179 <umain+0x145>
		dup(p[0], 10);
  800166:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  80016d:	00 
  80016e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 94 16 00 00       	call   80180d <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800179:	8b 43 54             	mov    0x54(%ebx),%eax
  80017c:	83 f8 02             	cmp    $0x2,%eax
  80017f:	74 e5                	je     800166 <umain+0x132>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800181:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  800188:	e8 0f 02 00 00       	call   80039c <cprintf>
	if (pipeisclosed(p[0]))
  80018d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 ed 20 00 00       	call   802285 <pipeisclosed>
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 1c                	je     8001b8 <umain+0x184>
		panic("somehow the other end of p[0] got closed!");
  80019c:	c7 44 24 08 2c 28 80 	movl   $0x80282c,0x8(%esp)
  8001a3:	00 
  8001a4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8001ab:	00 
  8001ac:	c7 04 24 82 27 80 00 	movl   $0x802782,(%esp)
  8001b3:	e8 ec 00 00 00       	call   8002a4 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 b8 14 00 00       	call   801682 <fd_lookup>
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	79 20                	jns    8001ee <umain+0x1ba>
		panic("cannot look up p[0]: %e", r);
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	c7 44 24 08 e6 27 80 	movl   $0x8027e6,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 82 27 80 00 	movl   $0x802782,(%esp)
  8001e9:	e8 b6 00 00 00       	call   8002a4 <_panic>
	va = fd2data(fd);
  8001ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 1b 14 00 00       	call   801614 <fd2data>
	if (pageref(va) != 3+1)
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 f7 1c 00 00       	call   801ef8 <pageref>
  800201:	83 f8 04             	cmp    $0x4,%eax
  800204:	74 0e                	je     800214 <umain+0x1e0>
		cprintf("\nchild detected race\n");
  800206:	c7 04 24 fe 27 80 00 	movl   $0x8027fe,(%esp)
  80020d:	e8 8a 01 00 00       	call   80039c <cprintf>
  800212:	eb 14                	jmp    800228 <umain+0x1f4>
	else
		cprintf("\nrace didn't happen\n", max);
  800214:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  800223:	e8 74 01 00 00       	call   80039c <cprintf>
}
  800228:	83 c4 20             	add    $0x20,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    
	...

00800230 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 20             	sub    $0x20,%esp
  800238:	8b 75 08             	mov    0x8(%ebp),%esi
  80023b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80023e:	e8 b8 0a 00 00       	call   800cfb <sys_getenvid>
  800243:	25 ff 03 00 00       	and    $0x3ff,%eax
  800248:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80024f:	c1 e0 07             	shl    $0x7,%eax
  800252:	29 d0                	sub    %edx,%eax
  800254:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800259:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  80025c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80025f:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800264:	85 f6                	test   %esi,%esi
  800266:	7e 07                	jle    80026f <libmain+0x3f>
		binaryname = argv[0];
  800268:	8b 03                	mov    (%ebx),%eax
  80026a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80026f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800273:	89 34 24             	mov    %esi,(%esp)
  800276:	e8 b9 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80027b:	e8 08 00 00 00       	call   800288 <exit>
}
  800280:	83 c4 20             	add    $0x20,%esp
  800283:	5b                   	pop    %ebx
  800284:	5e                   	pop    %esi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    
	...

00800288 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80028e:	e8 5a 15 00 00       	call   8017ed <close_all>
	sys_env_destroy(0);
  800293:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80029a:	e8 0a 0a 00 00       	call   800ca9 <sys_env_destroy>
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    
  8002a1:	00 00                	add    %al,(%eax)
	...

008002a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
  8002a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002af:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002b5:	e8 41 0a 00 00       	call   800cfb <sys_getenvid>
  8002ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	c7 04 24 60 28 80 00 	movl   $0x802860,(%esp)
  8002d7:	e8 c0 00 00 00       	call   80039c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	e8 50 00 00 00       	call   80033b <vcprintf>
	cprintf("\n");
  8002eb:	c7 04 24 f0 2b 80 00 	movl   $0x802bf0,(%esp)
  8002f2:	e8 a5 00 00 00       	call   80039c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002f7:	cc                   	int3   
  8002f8:	eb fd                	jmp    8002f7 <_panic+0x53>
	...

008002fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	53                   	push   %ebx
  800300:	83 ec 14             	sub    $0x14,%esp
  800303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800306:	8b 03                	mov    (%ebx),%eax
  800308:	8b 55 08             	mov    0x8(%ebp),%edx
  80030b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80030f:	40                   	inc    %eax
  800310:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800312:	3d ff 00 00 00       	cmp    $0xff,%eax
  800317:	75 19                	jne    800332 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800319:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800320:	00 
  800321:	8d 43 08             	lea    0x8(%ebx),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	e8 40 09 00 00       	call   800c6c <sys_cputs>
		b->idx = 0;
  80032c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800332:	ff 43 04             	incl   0x4(%ebx)
}
  800335:	83 c4 14             	add    $0x14,%esp
  800338:	5b                   	pop    %ebx
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800344:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80034b:	00 00 00 
	b.cnt = 0;
  80034e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800355:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	89 44 24 08          	mov    %eax,0x8(%esp)
  800366:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80036c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800370:	c7 04 24 fc 02 80 00 	movl   $0x8002fc,(%esp)
  800377:	e8 82 01 00 00       	call   8004fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80037c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800382:	89 44 24 04          	mov    %eax,0x4(%esp)
  800386:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 d8 08 00 00       	call   800c6c <sys_cputs>

	return b.cnt;
}
  800394:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	e8 87 ff ff ff       	call   80033b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    
	...

008003b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	57                   	push   %edi
  8003bc:	56                   	push   %esi
  8003bd:	53                   	push   %ebx
  8003be:	83 ec 3c             	sub    $0x3c,%esp
  8003c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c4:	89 d7                	mov    %edx,%edi
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003d5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003d8:	85 c0                	test   %eax,%eax
  8003da:	75 08                	jne    8003e4 <printnum+0x2c>
  8003dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003e2:	77 57                	ja     80043b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003e4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003e8:	4b                   	dec    %ebx
  8003e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003f8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800403:	00 
  800404:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800407:	89 04 24             	mov    %eax,(%esp)
  80040a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800411:	e8 fa 20 00 00       	call   802510 <__udivdi3>
  800416:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80041a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	89 54 24 04          	mov    %edx,0x4(%esp)
  800425:	89 fa                	mov    %edi,%edx
  800427:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80042a:	e8 89 ff ff ff       	call   8003b8 <printnum>
  80042f:	eb 0f                	jmp    800440 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800431:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800435:	89 34 24             	mov    %esi,(%esp)
  800438:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80043b:	4b                   	dec    %ebx
  80043c:	85 db                	test   %ebx,%ebx
  80043e:	7f f1                	jg     800431 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800440:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800444:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800448:	8b 45 10             	mov    0x10(%ebp),%eax
  80044b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800456:	00 
  800457:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80045a:	89 04 24             	mov    %eax,(%esp)
  80045d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	e8 c7 21 00 00       	call   802630 <__umoddi3>
  800469:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046d:	0f be 80 83 28 80 00 	movsbl 0x802883(%eax),%eax
  800474:	89 04 24             	mov    %eax,(%esp)
  800477:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80047a:	83 c4 3c             	add    $0x3c,%esp
  80047d:	5b                   	pop    %ebx
  80047e:	5e                   	pop    %esi
  80047f:	5f                   	pop    %edi
  800480:	5d                   	pop    %ebp
  800481:	c3                   	ret    

00800482 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800485:	83 fa 01             	cmp    $0x1,%edx
  800488:	7e 0e                	jle    800498 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80048f:	89 08                	mov    %ecx,(%eax)
  800491:	8b 02                	mov    (%edx),%eax
  800493:	8b 52 04             	mov    0x4(%edx),%edx
  800496:	eb 22                	jmp    8004ba <getuint+0x38>
	else if (lflag)
  800498:	85 d2                	test   %edx,%edx
  80049a:	74 10                	je     8004ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80049c:	8b 10                	mov    (%eax),%edx
  80049e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a1:	89 08                	mov    %ecx,(%eax)
  8004a3:	8b 02                	mov    (%edx),%eax
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	eb 0e                	jmp    8004ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b1:	89 08                	mov    %ecx,(%eax)
  8004b3:	8b 02                	mov    (%edx),%eax
  8004b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    

008004bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004c5:	8b 10                	mov    (%eax),%edx
  8004c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ca:	73 08                	jae    8004d4 <sprintputch+0x18>
		*b->buf++ = ch;
  8004cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004cf:	88 0a                	mov    %cl,(%edx)
  8004d1:	42                   	inc    %edx
  8004d2:	89 10                	mov    %edx,(%eax)
}
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 02 00 00 00       	call   8004fe <vprintfmt>
	va_end(ap);
}
  8004fc:	c9                   	leave  
  8004fd:	c3                   	ret    

008004fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	57                   	push   %edi
  800502:	56                   	push   %esi
  800503:	53                   	push   %ebx
  800504:	83 ec 4c             	sub    $0x4c,%esp
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	8b 75 10             	mov    0x10(%ebp),%esi
  80050d:	eb 12                	jmp    800521 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80050f:	85 c0                	test   %eax,%eax
  800511:	0f 84 6b 03 00 00    	je     800882 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800517:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051b:	89 04 24             	mov    %eax,(%esp)
  80051e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800521:	0f b6 06             	movzbl (%esi),%eax
  800524:	46                   	inc    %esi
  800525:	83 f8 25             	cmp    $0x25,%eax
  800528:	75 e5                	jne    80050f <vprintfmt+0x11>
  80052a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80052e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800535:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80053a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800541:	b9 00 00 00 00       	mov    $0x0,%ecx
  800546:	eb 26                	jmp    80056e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80054b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80054f:	eb 1d                	jmp    80056e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800554:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800558:	eb 14                	jmp    80056e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80055d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800564:	eb 08                	jmp    80056e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800566:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800569:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	0f b6 06             	movzbl (%esi),%eax
  800571:	8d 56 01             	lea    0x1(%esi),%edx
  800574:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800577:	8a 16                	mov    (%esi),%dl
  800579:	83 ea 23             	sub    $0x23,%edx
  80057c:	80 fa 55             	cmp    $0x55,%dl
  80057f:	0f 87 e1 02 00 00    	ja     800866 <vprintfmt+0x368>
  800585:	0f b6 d2             	movzbl %dl,%edx
  800588:	ff 24 95 c0 29 80 00 	jmp    *0x8029c0(,%edx,4)
  80058f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800592:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800597:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80059a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80059e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005a4:	83 fa 09             	cmp    $0x9,%edx
  8005a7:	77 2a                	ja     8005d3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005aa:	eb eb                	jmp    800597 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 04             	lea    0x4(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ba:	eb 17                	jmp    8005d3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c0:	78 98                	js     80055a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c5:	eb a7                	jmp    80056e <vprintfmt+0x70>
  8005c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005d1:	eb 9b                	jmp    80056e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d7:	79 95                	jns    80056e <vprintfmt+0x70>
  8005d9:	eb 8b                	jmp    800566 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005db:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005df:	eb 8d                	jmp    80056e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 50 04             	lea    0x4(%eax),%edx
  8005e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 04 24             	mov    %eax,(%esp)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f9:	e9 23 ff ff ff       	jmp    800521 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	85 c0                	test   %eax,%eax
  80060b:	79 02                	jns    80060f <vprintfmt+0x111>
  80060d:	f7 d8                	neg    %eax
  80060f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800611:	83 f8 0f             	cmp    $0xf,%eax
  800614:	7f 0b                	jg     800621 <vprintfmt+0x123>
  800616:	8b 04 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%eax
  80061d:	85 c0                	test   %eax,%eax
  80061f:	75 23                	jne    800644 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800621:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800625:	c7 44 24 08 9b 28 80 	movl   $0x80289b,0x8(%esp)
  80062c:	00 
  80062d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800631:	8b 45 08             	mov    0x8(%ebp),%eax
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	e8 9a fe ff ff       	call   8004d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80063f:	e9 dd fe ff ff       	jmp    800521 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800644:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800648:	c7 44 24 08 b5 2c 80 	movl   $0x802cb5,0x8(%esp)
  80064f:	00 
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	8b 55 08             	mov    0x8(%ebp),%edx
  800657:	89 14 24             	mov    %edx,(%esp)
  80065a:	e8 77 fe ff ff       	call   8004d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800662:	e9 ba fe ff ff       	jmp    800521 <vprintfmt+0x23>
  800667:	89 f9                	mov    %edi,%ecx
  800669:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80066c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 04             	lea    0x4(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)
  800678:	8b 30                	mov    (%eax),%esi
  80067a:	85 f6                	test   %esi,%esi
  80067c:	75 05                	jne    800683 <vprintfmt+0x185>
				p = "(null)";
  80067e:	be 94 28 80 00       	mov    $0x802894,%esi
			if (width > 0 && padc != '-')
  800683:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800687:	0f 8e 84 00 00 00    	jle    800711 <vprintfmt+0x213>
  80068d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800691:	74 7e                	je     800711 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800693:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800697:	89 34 24             	mov    %esi,(%esp)
  80069a:	e8 8b 02 00 00       	call   80092a <strnlen>
  80069f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006a2:	29 c2                	sub    %eax,%edx
  8006a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006a7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006ab:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006ae:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006b1:	89 de                	mov    %ebx,%esi
  8006b3:	89 d3                	mov    %edx,%ebx
  8006b5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b7:	eb 0b                	jmp    8006c4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006bd:	89 3c 24             	mov    %edi,(%esp)
  8006c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c3:	4b                   	dec    %ebx
  8006c4:	85 db                	test   %ebx,%ebx
  8006c6:	7f f1                	jg     8006b9 <vprintfmt+0x1bb>
  8006c8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006cb:	89 f3                	mov    %esi,%ebx
  8006cd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	79 05                	jns    8006dc <vprintfmt+0x1de>
  8006d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006df:	29 c2                	sub    %eax,%edx
  8006e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006e4:	eb 2b                	jmp    800711 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ea:	74 18                	je     800704 <vprintfmt+0x206>
  8006ec:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006ef:	83 fa 5e             	cmp    $0x5e,%edx
  8006f2:	76 10                	jbe    800704 <vprintfmt+0x206>
					putch('?', putdat);
  8006f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006ff:	ff 55 08             	call   *0x8(%ebp)
  800702:	eb 0a                	jmp    80070e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	89 04 24             	mov    %eax,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070e:	ff 4d e4             	decl   -0x1c(%ebp)
  800711:	0f be 06             	movsbl (%esi),%eax
  800714:	46                   	inc    %esi
  800715:	85 c0                	test   %eax,%eax
  800717:	74 21                	je     80073a <vprintfmt+0x23c>
  800719:	85 ff                	test   %edi,%edi
  80071b:	78 c9                	js     8006e6 <vprintfmt+0x1e8>
  80071d:	4f                   	dec    %edi
  80071e:	79 c6                	jns    8006e6 <vprintfmt+0x1e8>
  800720:	8b 7d 08             	mov    0x8(%ebp),%edi
  800723:	89 de                	mov    %ebx,%esi
  800725:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800728:	eb 18                	jmp    800742 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80072a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800735:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800737:	4b                   	dec    %ebx
  800738:	eb 08                	jmp    800742 <vprintfmt+0x244>
  80073a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80073d:	89 de                	mov    %ebx,%esi
  80073f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800742:	85 db                	test   %ebx,%ebx
  800744:	7f e4                	jg     80072a <vprintfmt+0x22c>
  800746:	89 7d 08             	mov    %edi,0x8(%ebp)
  800749:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074e:	e9 ce fd ff ff       	jmp    800521 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800753:	83 f9 01             	cmp    $0x1,%ecx
  800756:	7e 10                	jle    800768 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8d 50 08             	lea    0x8(%eax),%edx
  80075e:	89 55 14             	mov    %edx,0x14(%ebp)
  800761:	8b 30                	mov    (%eax),%esi
  800763:	8b 78 04             	mov    0x4(%eax),%edi
  800766:	eb 26                	jmp    80078e <vprintfmt+0x290>
	else if (lflag)
  800768:	85 c9                	test   %ecx,%ecx
  80076a:	74 12                	je     80077e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 04             	lea    0x4(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)
  800775:	8b 30                	mov    (%eax),%esi
  800777:	89 f7                	mov    %esi,%edi
  800779:	c1 ff 1f             	sar    $0x1f,%edi
  80077c:	eb 10                	jmp    80078e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8d 50 04             	lea    0x4(%eax),%edx
  800784:	89 55 14             	mov    %edx,0x14(%ebp)
  800787:	8b 30                	mov    (%eax),%esi
  800789:	89 f7                	mov    %esi,%edi
  80078b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80078e:	85 ff                	test   %edi,%edi
  800790:	78 0a                	js     80079c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800792:	b8 0a 00 00 00       	mov    $0xa,%eax
  800797:	e9 8c 00 00 00       	jmp    800828 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007a7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007aa:	f7 de                	neg    %esi
  8007ac:	83 d7 00             	adc    $0x0,%edi
  8007af:	f7 df                	neg    %edi
			}
			base = 10;
  8007b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b6:	eb 70                	jmp    800828 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007b8:	89 ca                	mov    %ecx,%edx
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8007bd:	e8 c0 fc ff ff       	call   800482 <getuint>
  8007c2:	89 c6                	mov    %eax,%esi
  8007c4:	89 d7                	mov    %edx,%edi
			base = 10;
  8007c6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007cb:	eb 5b                	jmp    800828 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8007cd:	89 ca                	mov    %ecx,%edx
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	e8 ab fc ff ff       	call   800482 <getuint>
  8007d7:	89 c6                	mov    %eax,%esi
  8007d9:	89 d7                	mov    %edx,%edi
			base = 8;
  8007db:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007e0:	eb 46                	jmp    800828 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007ed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8d 50 04             	lea    0x4(%eax),%edx
  800804:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800807:	8b 30                	mov    (%eax),%esi
  800809:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80080e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800813:	eb 13                	jmp    800828 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800815:	89 ca                	mov    %ecx,%edx
  800817:	8d 45 14             	lea    0x14(%ebp),%eax
  80081a:	e8 63 fc ff ff       	call   800482 <getuint>
  80081f:	89 c6                	mov    %eax,%esi
  800821:	89 d7                	mov    %edx,%edi
			base = 16;
  800823:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800828:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80082c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800830:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800833:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800837:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083b:	89 34 24             	mov    %esi,(%esp)
  80083e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800842:	89 da                	mov    %ebx,%edx
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	e8 6c fb ff ff       	call   8003b8 <printnum>
			break;
  80084c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80084f:	e9 cd fc ff ff       	jmp    800521 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800854:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800858:	89 04 24             	mov    %eax,(%esp)
  80085b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800861:	e9 bb fc ff ff       	jmp    800521 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800866:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800871:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800874:	eb 01                	jmp    800877 <vprintfmt+0x379>
  800876:	4e                   	dec    %esi
  800877:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80087b:	75 f9                	jne    800876 <vprintfmt+0x378>
  80087d:	e9 9f fc ff ff       	jmp    800521 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800882:	83 c4 4c             	add    $0x4c,%esp
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	83 ec 28             	sub    $0x28,%esp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800896:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800899:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a7:	85 c0                	test   %eax,%eax
  8008a9:	74 30                	je     8008db <vsnprintf+0x51>
  8008ab:	85 d2                	test   %edx,%edx
  8008ad:	7e 33                	jle    8008e2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c4:	c7 04 24 bc 04 80 00 	movl   $0x8004bc,(%esp)
  8008cb:	e8 2e fc ff ff       	call   8004fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d9:	eb 0c                	jmp    8008e7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e0:	eb 05                	jmp    8008e7 <vsnprintf+0x5d>
  8008e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    

008008e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800900:	89 44 24 04          	mov    %eax,0x4(%esp)
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	89 04 24             	mov    %eax,(%esp)
  80090a:	e8 7b ff ff ff       	call   80088a <vsnprintf>
	va_end(ap);

	return rc;
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    
  800911:	00 00                	add    %al,(%eax)
	...

00800914 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80091a:	b8 00 00 00 00       	mov    $0x0,%eax
  80091f:	eb 01                	jmp    800922 <strlen+0xe>
		n++;
  800921:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800922:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800926:	75 f9                	jne    800921 <strlen+0xd>
		n++;
	return n;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
  800938:	eb 01                	jmp    80093b <strnlen+0x11>
		n++;
  80093a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093b:	39 d0                	cmp    %edx,%eax
  80093d:	74 06                	je     800945 <strnlen+0x1b>
  80093f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800943:	75 f5                	jne    80093a <strnlen+0x10>
		n++;
	return n;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800951:	ba 00 00 00 00       	mov    $0x0,%edx
  800956:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800959:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80095c:	42                   	inc    %edx
  80095d:	84 c9                	test   %cl,%cl
  80095f:	75 f5                	jne    800956 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800961:	5b                   	pop    %ebx
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	83 ec 08             	sub    $0x8,%esp
  80096b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096e:	89 1c 24             	mov    %ebx,(%esp)
  800971:	e8 9e ff ff ff       	call   800914 <strlen>
	strcpy(dst + len, src);
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
  800979:	89 54 24 04          	mov    %edx,0x4(%esp)
  80097d:	01 d8                	add    %ebx,%eax
  80097f:	89 04 24             	mov    %eax,(%esp)
  800982:	e8 c0 ff ff ff       	call   800947 <strcpy>
	return dst;
}
  800987:	89 d8                	mov    %ebx,%eax
  800989:	83 c4 08             	add    $0x8,%esp
  80098c:	5b                   	pop    %ebx
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009a2:	eb 0c                	jmp    8009b0 <strncpy+0x21>
		*dst++ = *src;
  8009a4:	8a 1a                	mov    (%edx),%bl
  8009a6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a9:	80 3a 01             	cmpb   $0x1,(%edx)
  8009ac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009af:	41                   	inc    %ecx
  8009b0:	39 f1                	cmp    %esi,%ecx
  8009b2:	75 f0                	jne    8009a4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c6:	85 d2                	test   %edx,%edx
  8009c8:	75 0a                	jne    8009d4 <strlcpy+0x1c>
  8009ca:	89 f0                	mov    %esi,%eax
  8009cc:	eb 1a                	jmp    8009e8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ce:	88 18                	mov    %bl,(%eax)
  8009d0:	40                   	inc    %eax
  8009d1:	41                   	inc    %ecx
  8009d2:	eb 02                	jmp    8009d6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009d6:	4a                   	dec    %edx
  8009d7:	74 0a                	je     8009e3 <strlcpy+0x2b>
  8009d9:	8a 19                	mov    (%ecx),%bl
  8009db:	84 db                	test   %bl,%bl
  8009dd:	75 ef                	jne    8009ce <strlcpy+0x16>
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	eb 02                	jmp    8009e5 <strlcpy+0x2d>
  8009e3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009e5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009e8:	29 f0                	sub    %esi,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f7:	eb 02                	jmp    8009fb <strcmp+0xd>
		p++, q++;
  8009f9:	41                   	inc    %ecx
  8009fa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fb:	8a 01                	mov    (%ecx),%al
  8009fd:	84 c0                	test   %al,%al
  8009ff:	74 04                	je     800a05 <strcmp+0x17>
  800a01:	3a 02                	cmp    (%edx),%al
  800a03:	74 f4                	je     8009f9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a05:	0f b6 c0             	movzbl %al,%eax
  800a08:	0f b6 12             	movzbl (%edx),%edx
  800a0b:	29 d0                	sub    %edx,%eax
}
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a19:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a1c:	eb 03                	jmp    800a21 <strncmp+0x12>
		n--, p++, q++;
  800a1e:	4a                   	dec    %edx
  800a1f:	40                   	inc    %eax
  800a20:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a21:	85 d2                	test   %edx,%edx
  800a23:	74 14                	je     800a39 <strncmp+0x2a>
  800a25:	8a 18                	mov    (%eax),%bl
  800a27:	84 db                	test   %bl,%bl
  800a29:	74 04                	je     800a2f <strncmp+0x20>
  800a2b:	3a 19                	cmp    (%ecx),%bl
  800a2d:	74 ef                	je     800a1e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2f:	0f b6 00             	movzbl (%eax),%eax
  800a32:	0f b6 11             	movzbl (%ecx),%edx
  800a35:	29 d0                	sub    %edx,%eax
  800a37:	eb 05                	jmp    800a3e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a4a:	eb 05                	jmp    800a51 <strchr+0x10>
		if (*s == c)
  800a4c:	38 ca                	cmp    %cl,%dl
  800a4e:	74 0c                	je     800a5c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a50:	40                   	inc    %eax
  800a51:	8a 10                	mov    (%eax),%dl
  800a53:	84 d2                	test   %dl,%dl
  800a55:	75 f5                	jne    800a4c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a67:	eb 05                	jmp    800a6e <strfind+0x10>
		if (*s == c)
  800a69:	38 ca                	cmp    %cl,%dl
  800a6b:	74 07                	je     800a74 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a6d:	40                   	inc    %eax
  800a6e:	8a 10                	mov    (%eax),%dl
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 f5                	jne    800a69 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a85:	85 c9                	test   %ecx,%ecx
  800a87:	74 30                	je     800ab9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8f:	75 25                	jne    800ab6 <memset+0x40>
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 20                	jne    800ab6 <memset+0x40>
		c &= 0xFF;
  800a96:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a99:	89 d3                	mov    %edx,%ebx
  800a9b:	c1 e3 08             	shl    $0x8,%ebx
  800a9e:	89 d6                	mov    %edx,%esi
  800aa0:	c1 e6 18             	shl    $0x18,%esi
  800aa3:	89 d0                	mov    %edx,%eax
  800aa5:	c1 e0 10             	shl    $0x10,%eax
  800aa8:	09 f0                	or     %esi,%eax
  800aaa:	09 d0                	or     %edx,%eax
  800aac:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aae:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ab1:	fc                   	cld    
  800ab2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab4:	eb 03                	jmp    800ab9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab6:	fc                   	cld    
  800ab7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab9:	89 f8                	mov    %edi,%eax
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ace:	39 c6                	cmp    %eax,%esi
  800ad0:	73 34                	jae    800b06 <memmove+0x46>
  800ad2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad5:	39 d0                	cmp    %edx,%eax
  800ad7:	73 2d                	jae    800b06 <memmove+0x46>
		s += n;
		d += n;
  800ad9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adc:	f6 c2 03             	test   $0x3,%dl
  800adf:	75 1b                	jne    800afc <memmove+0x3c>
  800ae1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae7:	75 13                	jne    800afc <memmove+0x3c>
  800ae9:	f6 c1 03             	test   $0x3,%cl
  800aec:	75 0e                	jne    800afc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aee:	83 ef 04             	sub    $0x4,%edi
  800af1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800af7:	fd                   	std    
  800af8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afa:	eb 07                	jmp    800b03 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800afc:	4f                   	dec    %edi
  800afd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b00:	fd                   	std    
  800b01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b03:	fc                   	cld    
  800b04:	eb 20                	jmp    800b26 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0c:	75 13                	jne    800b21 <memmove+0x61>
  800b0e:	a8 03                	test   $0x3,%al
  800b10:	75 0f                	jne    800b21 <memmove+0x61>
  800b12:	f6 c1 03             	test   $0x3,%cl
  800b15:	75 0a                	jne    800b21 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b17:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	fc                   	cld    
  800b1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1f:	eb 05                	jmp    800b26 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b21:	89 c7                	mov    %eax,%edi
  800b23:	fc                   	cld    
  800b24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b30:	8b 45 10             	mov    0x10(%ebp),%eax
  800b33:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	89 04 24             	mov    %eax,(%esp)
  800b44:	e8 77 ff ff ff       	call   800ac0 <memmove>
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	eb 16                	jmp    800b77 <memcmp+0x2c>
		if (*s1 != *s2)
  800b61:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b64:	42                   	inc    %edx
  800b65:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b69:	38 c8                	cmp    %cl,%al
  800b6b:	74 0a                	je     800b77 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b6d:	0f b6 c0             	movzbl %al,%eax
  800b70:	0f b6 c9             	movzbl %cl,%ecx
  800b73:	29 c8                	sub    %ecx,%eax
  800b75:	eb 09                	jmp    800b80 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b77:	39 da                	cmp    %ebx,%edx
  800b79:	75 e6                	jne    800b61 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8e:	89 c2                	mov    %eax,%edx
  800b90:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b93:	eb 05                	jmp    800b9a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b95:	38 08                	cmp    %cl,(%eax)
  800b97:	74 05                	je     800b9e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b99:	40                   	inc    %eax
  800b9a:	39 d0                	cmp    %edx,%eax
  800b9c:	72 f7                	jb     800b95 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bac:	eb 01                	jmp    800baf <strtol+0xf>
		s++;
  800bae:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800baf:	8a 02                	mov    (%edx),%al
  800bb1:	3c 20                	cmp    $0x20,%al
  800bb3:	74 f9                	je     800bae <strtol+0xe>
  800bb5:	3c 09                	cmp    $0x9,%al
  800bb7:	74 f5                	je     800bae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bb9:	3c 2b                	cmp    $0x2b,%al
  800bbb:	75 08                	jne    800bc5 <strtol+0x25>
		s++;
  800bbd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bbe:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc3:	eb 13                	jmp    800bd8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bc5:	3c 2d                	cmp    $0x2d,%al
  800bc7:	75 0a                	jne    800bd3 <strtol+0x33>
		s++, neg = 1;
  800bc9:	8d 52 01             	lea    0x1(%edx),%edx
  800bcc:	bf 01 00 00 00       	mov    $0x1,%edi
  800bd1:	eb 05                	jmp    800bd8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd8:	85 db                	test   %ebx,%ebx
  800bda:	74 05                	je     800be1 <strtol+0x41>
  800bdc:	83 fb 10             	cmp    $0x10,%ebx
  800bdf:	75 28                	jne    800c09 <strtol+0x69>
  800be1:	8a 02                	mov    (%edx),%al
  800be3:	3c 30                	cmp    $0x30,%al
  800be5:	75 10                	jne    800bf7 <strtol+0x57>
  800be7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800beb:	75 0a                	jne    800bf7 <strtol+0x57>
		s += 2, base = 16;
  800bed:	83 c2 02             	add    $0x2,%edx
  800bf0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bf5:	eb 12                	jmp    800c09 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bf7:	85 db                	test   %ebx,%ebx
  800bf9:	75 0e                	jne    800c09 <strtol+0x69>
  800bfb:	3c 30                	cmp    $0x30,%al
  800bfd:	75 05                	jne    800c04 <strtol+0x64>
		s++, base = 8;
  800bff:	42                   	inc    %edx
  800c00:	b3 08                	mov    $0x8,%bl
  800c02:	eb 05                	jmp    800c09 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c04:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c10:	8a 0a                	mov    (%edx),%cl
  800c12:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c15:	80 fb 09             	cmp    $0x9,%bl
  800c18:	77 08                	ja     800c22 <strtol+0x82>
			dig = *s - '0';
  800c1a:	0f be c9             	movsbl %cl,%ecx
  800c1d:	83 e9 30             	sub    $0x30,%ecx
  800c20:	eb 1e                	jmp    800c40 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c22:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c25:	80 fb 19             	cmp    $0x19,%bl
  800c28:	77 08                	ja     800c32 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c2a:	0f be c9             	movsbl %cl,%ecx
  800c2d:	83 e9 57             	sub    $0x57,%ecx
  800c30:	eb 0e                	jmp    800c40 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c32:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c35:	80 fb 19             	cmp    $0x19,%bl
  800c38:	77 12                	ja     800c4c <strtol+0xac>
			dig = *s - 'A' + 10;
  800c3a:	0f be c9             	movsbl %cl,%ecx
  800c3d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c40:	39 f1                	cmp    %esi,%ecx
  800c42:	7d 0c                	jge    800c50 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c44:	42                   	inc    %edx
  800c45:	0f af c6             	imul   %esi,%eax
  800c48:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c4a:	eb c4                	jmp    800c10 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c4c:	89 c1                	mov    %eax,%ecx
  800c4e:	eb 02                	jmp    800c52 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c50:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c56:	74 05                	je     800c5d <strtol+0xbd>
		*endptr = (char *) s;
  800c58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c5b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c5d:	85 ff                	test   %edi,%edi
  800c5f:	74 04                	je     800c65 <strtol+0xc5>
  800c61:	89 c8                	mov    %ecx,%eax
  800c63:	f7 d8                	neg    %eax
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
	...

00800c6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	b8 00 00 00 00       	mov    $0x0,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 c3                	mov    %eax,%ebx
  800c7f:	89 c7                	mov    %eax,%edi
  800c81:	89 c6                	mov    %eax,%esi
  800c83:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	ba 00 00 00 00       	mov    $0x0,%edx
  800c95:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9a:	89 d1                	mov    %edx,%ecx
  800c9c:	89 d3                	mov    %edx,%ebx
  800c9e:	89 d7                	mov    %edx,%edi
  800ca0:	89 d6                	mov    %edx,%esi
  800ca2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800cb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb7:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 cb                	mov    %ecx,%ebx
  800cc1:	89 cf                	mov    %ecx,%edi
  800cc3:	89 ce                	mov    %ecx,%esi
  800cc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 28                	jle    800cf3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800cee:	e8 b1 f5 ff ff       	call   8002a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cf3:	83 c4 2c             	add    $0x2c,%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	ba 00 00 00 00       	mov    $0x0,%edx
  800d06:	b8 02 00 00 00       	mov    $0x2,%eax
  800d0b:	89 d1                	mov    %edx,%ecx
  800d0d:	89 d3                	mov    %edx,%ebx
  800d0f:	89 d7                	mov    %edx,%edi
  800d11:	89 d6                	mov    %edx,%esi
  800d13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_yield>:

void
sys_yield(void)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	ba 00 00 00 00       	mov    $0x0,%edx
  800d25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2a:	89 d1                	mov    %edx,%ecx
  800d2c:	89 d3                	mov    %edx,%ebx
  800d2e:	89 d7                	mov    %edx,%edi
  800d30:	89 d6                	mov    %edx,%esi
  800d32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d42:	be 00 00 00 00       	mov    $0x0,%esi
  800d47:	b8 04 00 00 00       	mov    $0x4,%eax
  800d4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	89 f7                	mov    %esi,%edi
  800d57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800d80:	e8 1f f5 ff ff       	call   8002a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	8b 55 08             	mov    0x8(%ebp),%edx
  800daa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 28                	jle    800dd8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800dd3:	e8 cc f4 ff ff       	call   8002a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dd8:	83 c4 2c             	add    $0x2c,%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
  800de6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dee:	b8 06 00 00 00       	mov    $0x6,%eax
  800df3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df6:	8b 55 08             	mov    0x8(%ebp),%edx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 de                	mov    %ebx,%esi
  800dfd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	7e 28                	jle    800e2b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e07:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1e:	00 
  800e1f:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800e26:	e8 79 f4 ff ff       	call   8002a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e2b:	83 c4 2c             	add    $0x2c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	b8 08 00 00 00       	mov    $0x8,%eax
  800e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	7e 28                	jle    800e7e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e61:	00 
  800e62:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e71:	00 
  800e72:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800e79:	e8 26 f4 ff ff       	call   8002a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e7e:	83 c4 2c             	add    $0x2c,%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e94:	b8 09 00 00 00       	mov    $0x9,%eax
  800e99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 df                	mov    %ebx,%edi
  800ea1:	89 de                	mov    %ebx,%esi
  800ea3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	7e 28                	jle    800ed1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ead:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec4:	00 
  800ec5:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800ecc:	e8 d3 f3 ff ff       	call   8002a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed1:	83 c4 2c             	add    $0x2c,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
  800edf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef2:	89 df                	mov    %ebx,%edi
  800ef4:	89 de                	mov    %ebx,%esi
  800ef6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	7e 28                	jle    800f24 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f00:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f07:	00 
  800f08:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800f0f:	00 
  800f10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f17:	00 
  800f18:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800f1f:	e8 80 f3 ff ff       	call   8002a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f24:	83 c4 2c             	add    $0x2c,%esp
  800f27:	5b                   	pop    %ebx
  800f28:	5e                   	pop    %esi
  800f29:	5f                   	pop    %edi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f32:	be 00 00 00 00       	mov    $0x0,%esi
  800f37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	8b 55 08             	mov    0x8(%ebp),%edx
  800f48:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	89 cb                	mov    %ecx,%ebx
  800f67:	89 cf                	mov    %ecx,%edi
  800f69:	89 ce                	mov    %ecx,%esi
  800f6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	7e 28                	jle    800f99 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f75:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800f94:	e8 0b f3 ff ff       	call   8002a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f99:	83 c4 2c             	add    $0x2c,%esp
  800f9c:	5b                   	pop    %ebx
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    
  800fa1:	00 00                	add    %al,(%eax)
	...

00800fa4 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	83 ec 3c             	sub    $0x3c,%esp
  800fad:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  800fb0:	89 d6                	mov    %edx,%esi
  800fb2:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  800fb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  800fbf:	e8 37 fd ff ff       	call   800cfb <sys_getenvid>
  800fc4:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  800fc6:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  800fcd:	74 31                	je     801000 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  800fcf:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800fd6:	00 
  800fd7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800fdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fde:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe6:	89 3c 24             	mov    %edi,(%esp)
  800fe9:	e8 9f fd ff ff       	call   800d8d <sys_page_map>
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	0f 8e ae 00 00 00    	jle    8010a4 <duppage+0x100>
  800ff6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffb:	e9 a4 00 00 00       	jmp    8010a4 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  801000:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801003:	25 02 08 00 00       	and    $0x802,%eax
  801008:	83 f8 01             	cmp    $0x1,%eax
  80100b:	19 db                	sbb    %ebx,%ebx
  80100d:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801013:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  801019:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80101d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801021:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801024:	89 44 24 08          	mov    %eax,0x8(%esp)
  801028:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102c:	89 3c 24             	mov    %edi,(%esp)
  80102f:	e8 59 fd ff ff       	call   800d8d <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  801034:	85 c0                	test   %eax,%eax
  801036:	79 1c                	jns    801054 <duppage+0xb0>
  801038:	c7 44 24 08 aa 2b 80 	movl   $0x802baa,0x8(%esp)
  80103f:	00 
  801040:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801047:	00 
  801048:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  80104f:	e8 50 f2 ff ff       	call   8002a4 <_panic>
	if ((perm|~pte)&PTE_COW){
  801054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801057:	f7 d0                	not    %eax
  801059:	09 d8                	or     %ebx,%eax
  80105b:	f6 c4 08             	test   $0x8,%ah
  80105e:	74 38                	je     801098 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  801060:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801064:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801068:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80106c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801070:	89 3c 24             	mov    %edi,(%esp)
  801073:	e8 15 fd ff ff       	call   800d8d <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  801078:	85 c0                	test   %eax,%eax
  80107a:	79 23                	jns    80109f <duppage+0xfb>
  80107c:	c7 44 24 08 aa 2b 80 	movl   $0x802baa,0x8(%esp)
  801083:	00 
  801084:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80108b:	00 
  80108c:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  801093:	e8 0c f2 ff ff       	call   8002a4 <_panic>
	}
	return 0;
  801098:	b8 00 00 00 00       	mov    $0x0,%eax
  80109d:	eb 05                	jmp    8010a4 <duppage+0x100>
  80109f:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  8010a4:	83 c4 3c             	add    $0x3c,%esp
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
  8010b1:	83 ec 20             	sub    $0x20,%esp
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010b7:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  8010b9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010bd:	75 1c                	jne    8010db <pgfault+0x2f>
		panic("pgfault: error!\n");
  8010bf:	c7 44 24 08 c6 2b 80 	movl   $0x802bc6,0x8(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8010ce:	00 
  8010cf:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  8010d6:	e8 c9 f1 ff ff       	call   8002a4 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  8010db:	89 f0                	mov    %esi,%eax
  8010dd:	c1 e8 0c             	shr    $0xc,%eax
  8010e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e7:	f6 c4 08             	test   $0x8,%ah
  8010ea:	75 1c                	jne    801108 <pgfault+0x5c>
		panic("pgfault: error!\n");
  8010ec:	c7 44 24 08 c6 2b 80 	movl   $0x802bc6,0x8(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8010fb:	00 
  8010fc:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  801103:	e8 9c f1 ff ff       	call   8002a4 <_panic>
	envid_t envid = sys_getenvid();
  801108:	e8 ee fb ff ff       	call   800cfb <sys_getenvid>
  80110d:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  80110f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801116:	00 
  801117:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80111e:	00 
  80111f:	89 04 24             	mov    %eax,(%esp)
  801122:	e8 12 fc ff ff       	call   800d39 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  801127:	85 c0                	test   %eax,%eax
  801129:	79 1c                	jns    801147 <pgfault+0x9b>
  80112b:	c7 44 24 08 c6 2b 80 	movl   $0x802bc6,0x8(%esp)
  801132:	00 
  801133:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80113a:	00 
  80113b:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  801142:	e8 5d f1 ff ff       	call   8002a4 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  801147:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  80114d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801154:	00 
  801155:	89 74 24 04          	mov    %esi,0x4(%esp)
  801159:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801160:	e8 c5 f9 ff ff       	call   800b2a <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  801165:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80116c:	00 
  80116d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801171:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801175:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80117c:	00 
  80117d:	89 1c 24             	mov    %ebx,(%esp)
  801180:	e8 08 fc ff ff       	call   800d8d <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801185:	85 c0                	test   %eax,%eax
  801187:	79 1c                	jns    8011a5 <pgfault+0xf9>
  801189:	c7 44 24 08 c6 2b 80 	movl   $0x802bc6,0x8(%esp)
  801190:	00 
  801191:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801198:	00 
  801199:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  8011a0:	e8 ff f0 ff ff       	call   8002a4 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  8011a5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011ac:	00 
  8011ad:	89 1c 24             	mov    %ebx,(%esp)
  8011b0:	e8 2b fc ff ff       	call   800de0 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	79 1c                	jns    8011d5 <pgfault+0x129>
  8011b9:	c7 44 24 08 c6 2b 80 	movl   $0x802bc6,0x8(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8011c8:	00 
  8011c9:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  8011d0:	e8 cf f0 ff ff       	call   8002a4 <_panic>
	return;
	panic("pgfault not implemented");
}
  8011d5:	83 c4 20             	add    $0x20,%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	57                   	push   %edi
  8011e0:	56                   	push   %esi
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8011e5:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  8011ec:	e8 67 12 00 00       	call   802458 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8011f1:	bf 07 00 00 00       	mov    $0x7,%edi
  8011f6:	89 f8                	mov    %edi,%eax
  8011f8:	cd 30                	int    $0x30
  8011fa:	89 c7                	mov    %eax,%edi
  8011fc:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  8011fe:	85 c0                	test   %eax,%eax
  801200:	79 1c                	jns    80121e <fork+0x42>
		panic("fork : error!\n");
  801202:	c7 44 24 08 e3 2b 80 	movl   $0x802be3,0x8(%esp)
  801209:	00 
  80120a:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  801211:	00 
  801212:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  801219:	e8 86 f0 ff ff       	call   8002a4 <_panic>
	if (envid==0){
  80121e:	85 c0                	test   %eax,%eax
  801220:	75 28                	jne    80124a <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  801222:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801228:	e8 ce fa ff ff       	call   800cfb <sys_getenvid>
  80122d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801232:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801239:	c1 e0 07             	shl    $0x7,%eax
  80123c:	29 d0                	sub    %edx,%eax
  80123e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801243:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  801245:	e9 f2 00 00 00       	jmp    80133c <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  80124a:	e8 ac fa ff ff       	call   800cfb <sys_getenvid>
  80124f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801252:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  801257:	89 d8                	mov    %ebx,%eax
  801259:	c1 e8 16             	shr    $0x16,%eax
  80125c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801263:	a8 01                	test   $0x1,%al
  801265:	74 17                	je     80127e <fork+0xa2>
  801267:	89 da                	mov    %ebx,%edx
  801269:	c1 ea 0c             	shr    $0xc,%edx
  80126c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801273:	a8 01                	test   $0x1,%al
  801275:	74 07                	je     80127e <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801277:	89 f0                	mov    %esi,%eax
  801279:	e8 26 fd ff ff       	call   800fa4 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80127e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801284:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80128a:	75 cb                	jne    801257 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  80128c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801293:	00 
  801294:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80129b:	ee 
  80129c:	89 3c 24             	mov    %edi,(%esp)
  80129f:	e8 95 fa ff ff       	call   800d39 <sys_page_alloc>
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	79 1c                	jns    8012c4 <fork+0xe8>
  8012a8:	c7 44 24 08 e3 2b 80 	movl   $0x802be3,0x8(%esp)
  8012af:	00 
  8012b0:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8012b7:	00 
  8012b8:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  8012bf:	e8 e0 ef ff ff       	call   8002a4 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  8012c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8012d3:	c1 e0 07             	shl    $0x7,%eax
  8012d6:	29 d0                	sub    %edx,%eax
  8012d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012dd:	8b 40 64             	mov    0x64(%eax),%eax
  8012e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e4:	89 3c 24             	mov    %edi,(%esp)
  8012e7:	e8 ed fb ff ff       	call   800ed9 <sys_env_set_pgfault_upcall>
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	79 1c                	jns    80130c <fork+0x130>
  8012f0:	c7 44 24 08 e3 2b 80 	movl   $0x802be3,0x8(%esp)
  8012f7:	00 
  8012f8:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8012ff:	00 
  801300:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  801307:	e8 98 ef ff ff       	call   8002a4 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  80130c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801313:	00 
  801314:	89 3c 24             	mov    %edi,(%esp)
  801317:	e8 17 fb ff ff       	call   800e33 <sys_env_set_status>
  80131c:	85 c0                	test   %eax,%eax
  80131e:	79 1c                	jns    80133c <fork+0x160>
  801320:	c7 44 24 08 e3 2b 80 	movl   $0x802be3,0x8(%esp)
  801327:	00 
  801328:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  80132f:	00 
  801330:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  801337:	e8 68 ef ff ff       	call   8002a4 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  80133c:	89 f8                	mov    %edi,%eax
  80133e:	83 c4 2c             	add    $0x2c,%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <sfork>:

// Challenge!
int
sfork(void)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	57                   	push   %edi
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  80134f:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  801356:	e8 fd 10 00 00       	call   802458 <set_pgfault_handler>
  80135b:	ba 07 00 00 00       	mov    $0x7,%edx
  801360:	89 d0                	mov    %edx,%eax
  801362:	cd 30                	int    $0x30
  801364:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801367:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136d:	c7 04 24 d7 2b 80 00 	movl   $0x802bd7,(%esp)
  801374:	e8 23 f0 ff ff       	call   80039c <cprintf>
	if (envid<0)
  801379:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80137d:	79 1c                	jns    80139b <sfork+0x55>
		panic("sfork : error!\n");
  80137f:	c7 44 24 08 e2 2b 80 	movl   $0x802be2,0x8(%esp)
  801386:	00 
  801387:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  80138e:	00 
  80138f:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  801396:	e8 09 ef ff ff       	call   8002a4 <_panic>
	if (envid==0){
  80139b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80139f:	75 28                	jne    8013c9 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  8013a1:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8013a7:	e8 4f f9 ff ff       	call   800cfb <sys_getenvid>
  8013ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8013b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013b8:	c1 e0 07             	shl    $0x7,%eax
  8013bb:	29 d0                	sub    %edx,%eax
  8013bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013c2:	89 03                	mov    %eax,(%ebx)
		return envid;
  8013c4:	e9 18 01 00 00       	jmp    8014e1 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  8013c9:	e8 2d f9 ff ff       	call   800cfb <sys_getenvid>
  8013ce:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8013d0:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8013d5:	89 d8                	mov    %ebx,%eax
  8013d7:	c1 e8 16             	shr    $0x16,%eax
  8013da:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e1:	a8 01                	test   $0x1,%al
  8013e3:	74 2c                	je     801411 <sfork+0xcb>
  8013e5:	89 d8                	mov    %ebx,%eax
  8013e7:	c1 e8 0c             	shr    $0xc,%eax
  8013ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f1:	a8 01                	test   $0x1,%al
  8013f3:	74 1c                	je     801411 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8013f5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013fc:	00 
  8013fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801401:	89 74 24 08          	mov    %esi,0x8(%esp)
  801405:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801409:	89 3c 24             	mov    %edi,(%esp)
  80140c:	e8 7c f9 ff ff       	call   800d8d <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801411:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801417:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  80141d:	75 b6                	jne    8013d5 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  80141f:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801424:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801427:	e8 78 fb ff ff       	call   800fa4 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  80142c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801433:	00 
  801434:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80143b:	ee 
  80143c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80143f:	89 04 24             	mov    %eax,(%esp)
  801442:	e8 f2 f8 ff ff       	call   800d39 <sys_page_alloc>
  801447:	85 c0                	test   %eax,%eax
  801449:	79 1c                	jns    801467 <sfork+0x121>
  80144b:	c7 44 24 08 e2 2b 80 	movl   $0x802be2,0x8(%esp)
  801452:	00 
  801453:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  80145a:	00 
  80145b:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  801462:	e8 3d ee ff ff       	call   8002a4 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  801467:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  80146d:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801474:	c1 e7 07             	shl    $0x7,%edi
  801477:	29 d7                	sub    %edx,%edi
  801479:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80147f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801483:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801486:	89 04 24             	mov    %eax,(%esp)
  801489:	e8 4b fa ff ff       	call   800ed9 <sys_env_set_pgfault_upcall>
  80148e:	85 c0                	test   %eax,%eax
  801490:	79 1c                	jns    8014ae <sfork+0x168>
  801492:	c7 44 24 08 e2 2b 80 	movl   $0x802be2,0x8(%esp)
  801499:	00 
  80149a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  8014a1:	00 
  8014a2:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  8014a9:	e8 f6 ed ff ff       	call   8002a4 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  8014ae:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8014b5:	00 
  8014b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014b9:	89 04 24             	mov    %eax,(%esp)
  8014bc:	e8 72 f9 ff ff       	call   800e33 <sys_env_set_status>
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	79 1c                	jns    8014e1 <sfork+0x19b>
  8014c5:	c7 44 24 08 e2 2b 80 	movl   $0x802be2,0x8(%esp)
  8014cc:	00 
  8014cd:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8014d4:	00 
  8014d5:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  8014dc:	e8 c3 ed ff ff       	call   8002a4 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8014e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e4:	83 c4 3c             	add    $0x3c,%esp
  8014e7:	5b                   	pop    %ebx
  8014e8:	5e                   	pop    %esi
  8014e9:	5f                   	pop    %edi
  8014ea:	5d                   	pop    %ebp
  8014eb:	c3                   	ret    

008014ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 10             	sub    $0x10,%esp
  8014f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	75 05                	jne    801506 <ipc_recv+0x1a>
  801501:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801506:	89 04 24             	mov    %eax,(%esp)
  801509:	e8 41 fa ff ff       	call   800f4f <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80150e:	85 c0                	test   %eax,%eax
  801510:	79 16                	jns    801528 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801512:	85 db                	test   %ebx,%ebx
  801514:	74 06                	je     80151c <ipc_recv+0x30>
  801516:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  80151c:	85 f6                	test   %esi,%esi
  80151e:	74 32                	je     801552 <ipc_recv+0x66>
  801520:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801526:	eb 2a                	jmp    801552 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801528:	85 db                	test   %ebx,%ebx
  80152a:	74 0c                	je     801538 <ipc_recv+0x4c>
  80152c:	a1 04 40 80 00       	mov    0x804004,%eax
  801531:	8b 00                	mov    (%eax),%eax
  801533:	8b 40 74             	mov    0x74(%eax),%eax
  801536:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801538:	85 f6                	test   %esi,%esi
  80153a:	74 0c                	je     801548 <ipc_recv+0x5c>
  80153c:	a1 04 40 80 00       	mov    0x804004,%eax
  801541:	8b 00                	mov    (%eax),%eax
  801543:	8b 40 78             	mov    0x78(%eax),%eax
  801546:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801548:	a1 04 40 80 00       	mov    0x804004,%eax
  80154d:	8b 00                	mov    (%eax),%eax
  80154f:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	5b                   	pop    %ebx
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	57                   	push   %edi
  80155d:	56                   	push   %esi
  80155e:	53                   	push   %ebx
  80155f:	83 ec 1c             	sub    $0x1c,%esp
  801562:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801565:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801568:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80156b:	85 db                	test   %ebx,%ebx
  80156d:	75 05                	jne    801574 <ipc_send+0x1b>
  80156f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801574:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801578:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80157c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801580:	8b 45 08             	mov    0x8(%ebp),%eax
  801583:	89 04 24             	mov    %eax,(%esp)
  801586:	e8 a1 f9 ff ff       	call   800f2c <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  80158b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80158e:	75 07                	jne    801597 <ipc_send+0x3e>
  801590:	e8 85 f7 ff ff       	call   800d1a <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801595:	eb dd                	jmp    801574 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801597:	85 c0                	test   %eax,%eax
  801599:	79 1c                	jns    8015b7 <ipc_send+0x5e>
  80159b:	c7 44 24 08 f2 2b 80 	movl   $0x802bf2,0x8(%esp)
  8015a2:	00 
  8015a3:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8015aa:	00 
  8015ab:	c7 04 24 04 2c 80 00 	movl   $0x802c04,(%esp)
  8015b2:	e8 ed ec ff ff       	call   8002a4 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  8015b7:	83 c4 1c             	add    $0x1c,%esp
  8015ba:	5b                   	pop    %ebx
  8015bb:	5e                   	pop    %esi
  8015bc:	5f                   	pop    %edi
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    

008015bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	53                   	push   %ebx
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8015c6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8015cb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	c1 e2 07             	shl    $0x7,%edx
  8015d7:	29 ca                	sub    %ecx,%edx
  8015d9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8015df:	8b 52 50             	mov    0x50(%edx),%edx
  8015e2:	39 da                	cmp    %ebx,%edx
  8015e4:	75 0f                	jne    8015f5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8015e6:	c1 e0 07             	shl    $0x7,%eax
  8015e9:	29 c8                	sub    %ecx,%eax
  8015eb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8015f0:	8b 40 40             	mov    0x40(%eax),%eax
  8015f3:	eb 0c                	jmp    801601 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8015f5:	40                   	inc    %eax
  8015f6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8015fb:	75 ce                	jne    8015cb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8015fd:	66 b8 00 00          	mov    $0x0,%ax
}
  801601:	5b                   	pop    %ebx
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    

00801604 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801607:	8b 45 08             	mov    0x8(%ebp),%eax
  80160a:	05 00 00 00 30       	add    $0x30000000,%eax
  80160f:	c1 e8 0c             	shr    $0xc,%eax
}
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80161a:	8b 45 08             	mov    0x8(%ebp),%eax
  80161d:	89 04 24             	mov    %eax,(%esp)
  801620:	e8 df ff ff ff       	call   801604 <fd2num>
  801625:	05 20 00 0d 00       	add    $0xd0020,%eax
  80162a:	c1 e0 0c             	shl    $0xc,%eax
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	53                   	push   %ebx
  801633:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801636:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80163b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	c1 ea 16             	shr    $0x16,%edx
  801642:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801649:	f6 c2 01             	test   $0x1,%dl
  80164c:	74 11                	je     80165f <fd_alloc+0x30>
  80164e:	89 c2                	mov    %eax,%edx
  801650:	c1 ea 0c             	shr    $0xc,%edx
  801653:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80165a:	f6 c2 01             	test   $0x1,%dl
  80165d:	75 09                	jne    801668 <fd_alloc+0x39>
			*fd_store = fd;
  80165f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801661:	b8 00 00 00 00       	mov    $0x0,%eax
  801666:	eb 17                	jmp    80167f <fd_alloc+0x50>
  801668:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80166d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801672:	75 c7                	jne    80163b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801674:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80167a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80167f:	5b                   	pop    %ebx
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801688:	83 f8 1f             	cmp    $0x1f,%eax
  80168b:	77 36                	ja     8016c3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80168d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801692:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801695:	89 c2                	mov    %eax,%edx
  801697:	c1 ea 16             	shr    $0x16,%edx
  80169a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016a1:	f6 c2 01             	test   $0x1,%dl
  8016a4:	74 24                	je     8016ca <fd_lookup+0x48>
  8016a6:	89 c2                	mov    %eax,%edx
  8016a8:	c1 ea 0c             	shr    $0xc,%edx
  8016ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016b2:	f6 c2 01             	test   $0x1,%dl
  8016b5:	74 1a                	je     8016d1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ba:	89 02                	mov    %eax,(%edx)
	return 0;
  8016bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c1:	eb 13                	jmp    8016d6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c8:	eb 0c                	jmp    8016d6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016cf:	eb 05                	jmp    8016d6 <fd_lookup+0x54>
  8016d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	53                   	push   %ebx
  8016dc:	83 ec 14             	sub    $0x14,%esp
  8016df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	eb 0e                	jmp    8016fa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8016ec:	39 08                	cmp    %ecx,(%eax)
  8016ee:	75 09                	jne    8016f9 <dev_lookup+0x21>
			*dev = devtab[i];
  8016f0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8016f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f7:	eb 35                	jmp    80172e <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016f9:	42                   	inc    %edx
  8016fa:	8b 04 95 8c 2c 80 00 	mov    0x802c8c(,%edx,4),%eax
  801701:	85 c0                	test   %eax,%eax
  801703:	75 e7                	jne    8016ec <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801705:	a1 04 40 80 00       	mov    0x804004,%eax
  80170a:	8b 00                	mov    (%eax),%eax
  80170c:	8b 40 48             	mov    0x48(%eax),%eax
  80170f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801713:	89 44 24 04          	mov    %eax,0x4(%esp)
  801717:	c7 04 24 10 2c 80 00 	movl   $0x802c10,(%esp)
  80171e:	e8 79 ec ff ff       	call   80039c <cprintf>
	*dev = 0;
  801723:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801729:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80172e:	83 c4 14             	add    $0x14,%esp
  801731:	5b                   	pop    %ebx
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	83 ec 30             	sub    $0x30,%esp
  80173c:	8b 75 08             	mov    0x8(%ebp),%esi
  80173f:	8a 45 0c             	mov    0xc(%ebp),%al
  801742:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801745:	89 34 24             	mov    %esi,(%esp)
  801748:	e8 b7 fe ff ff       	call   801604 <fd2num>
  80174d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801750:	89 54 24 04          	mov    %edx,0x4(%esp)
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 26 ff ff ff       	call   801682 <fd_lookup>
  80175c:	89 c3                	mov    %eax,%ebx
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 05                	js     801767 <fd_close+0x33>
	    || fd != fd2)
  801762:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801765:	74 0d                	je     801774 <fd_close+0x40>
		return (must_exist ? r : 0);
  801767:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80176b:	75 46                	jne    8017b3 <fd_close+0x7f>
  80176d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801772:	eb 3f                	jmp    8017b3 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801774:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177b:	8b 06                	mov    (%esi),%eax
  80177d:	89 04 24             	mov    %eax,(%esp)
  801780:	e8 53 ff ff ff       	call   8016d8 <dev_lookup>
  801785:	89 c3                	mov    %eax,%ebx
  801787:	85 c0                	test   %eax,%eax
  801789:	78 18                	js     8017a3 <fd_close+0x6f>
		if (dev->dev_close)
  80178b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178e:	8b 40 10             	mov    0x10(%eax),%eax
  801791:	85 c0                	test   %eax,%eax
  801793:	74 09                	je     80179e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801795:	89 34 24             	mov    %esi,(%esp)
  801798:	ff d0                	call   *%eax
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	eb 05                	jmp    8017a3 <fd_close+0x6f>
		else
			r = 0;
  80179e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ae:	e8 2d f6 ff ff       	call   800de0 <sys_page_unmap>
	return r;
}
  8017b3:	89 d8                	mov    %ebx,%eax
  8017b5:	83 c4 30             	add    $0x30,%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cc:	89 04 24             	mov    %eax,(%esp)
  8017cf:	e8 ae fe ff ff       	call   801682 <fd_lookup>
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 13                	js     8017eb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8017d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017df:	00 
  8017e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e3:	89 04 24             	mov    %eax,(%esp)
  8017e6:	e8 49 ff ff ff       	call   801734 <fd_close>
}
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <close_all>:

void
close_all(void)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8017f4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8017f9:	89 1c 24             	mov    %ebx,(%esp)
  8017fc:	e8 bb ff ff ff       	call   8017bc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801801:	43                   	inc    %ebx
  801802:	83 fb 20             	cmp    $0x20,%ebx
  801805:	75 f2                	jne    8017f9 <close_all+0xc>
		close(i);
}
  801807:	83 c4 14             	add    $0x14,%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	57                   	push   %edi
  801811:	56                   	push   %esi
  801812:	53                   	push   %ebx
  801813:	83 ec 4c             	sub    $0x4c,%esp
  801816:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801819:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80181c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 57 fe ff ff       	call   801682 <fd_lookup>
  80182b:	89 c3                	mov    %eax,%ebx
  80182d:	85 c0                	test   %eax,%eax
  80182f:	0f 88 e1 00 00 00    	js     801916 <dup+0x109>
		return r;
	close(newfdnum);
  801835:	89 3c 24             	mov    %edi,(%esp)
  801838:	e8 7f ff ff ff       	call   8017bc <close>

	newfd = INDEX2FD(newfdnum);
  80183d:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801843:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801846:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801849:	89 04 24             	mov    %eax,(%esp)
  80184c:	e8 c3 fd ff ff       	call   801614 <fd2data>
  801851:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801853:	89 34 24             	mov    %esi,(%esp)
  801856:	e8 b9 fd ff ff       	call   801614 <fd2data>
  80185b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80185e:	89 d8                	mov    %ebx,%eax
  801860:	c1 e8 16             	shr    $0x16,%eax
  801863:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80186a:	a8 01                	test   $0x1,%al
  80186c:	74 46                	je     8018b4 <dup+0xa7>
  80186e:	89 d8                	mov    %ebx,%eax
  801870:	c1 e8 0c             	shr    $0xc,%eax
  801873:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80187a:	f6 c2 01             	test   $0x1,%dl
  80187d:	74 35                	je     8018b4 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80187f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801886:	25 07 0e 00 00       	and    $0xe07,%eax
  80188b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80188f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801892:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801896:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80189d:	00 
  80189e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a9:	e8 df f4 ff ff       	call   800d8d <sys_page_map>
  8018ae:	89 c3                	mov    %eax,%ebx
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 3b                	js     8018ef <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b7:	89 c2                	mov    %eax,%edx
  8018b9:	c1 ea 0c             	shr    $0xc,%edx
  8018bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018c3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8018c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018d8:	00 
  8018d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e4:	e8 a4 f4 ff ff       	call   800d8d <sys_page_map>
  8018e9:	89 c3                	mov    %eax,%ebx
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	79 25                	jns    801914 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fa:	e8 e1 f4 ff ff       	call   800de0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801902:	89 44 24 04          	mov    %eax,0x4(%esp)
  801906:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190d:	e8 ce f4 ff ff       	call   800de0 <sys_page_unmap>
	return r;
  801912:	eb 02                	jmp    801916 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801914:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801916:	89 d8                	mov    %ebx,%eax
  801918:	83 c4 4c             	add    $0x4c,%esp
  80191b:	5b                   	pop    %ebx
  80191c:	5e                   	pop    %esi
  80191d:	5f                   	pop    %edi
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	53                   	push   %ebx
  801924:	83 ec 24             	sub    $0x24,%esp
  801927:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80192a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80192d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801931:	89 1c 24             	mov    %ebx,(%esp)
  801934:	e8 49 fd ff ff       	call   801682 <fd_lookup>
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 6f                	js     8019ac <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801940:	89 44 24 04          	mov    %eax,0x4(%esp)
  801944:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801947:	8b 00                	mov    (%eax),%eax
  801949:	89 04 24             	mov    %eax,(%esp)
  80194c:	e8 87 fd ff ff       	call   8016d8 <dev_lookup>
  801951:	85 c0                	test   %eax,%eax
  801953:	78 57                	js     8019ac <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801955:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801958:	8b 50 08             	mov    0x8(%eax),%edx
  80195b:	83 e2 03             	and    $0x3,%edx
  80195e:	83 fa 01             	cmp    $0x1,%edx
  801961:	75 25                	jne    801988 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801963:	a1 04 40 80 00       	mov    0x804004,%eax
  801968:	8b 00                	mov    (%eax),%eax
  80196a:	8b 40 48             	mov    0x48(%eax),%eax
  80196d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801971:	89 44 24 04          	mov    %eax,0x4(%esp)
  801975:	c7 04 24 51 2c 80 00 	movl   $0x802c51,(%esp)
  80197c:	e8 1b ea ff ff       	call   80039c <cprintf>
		return -E_INVAL;
  801981:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801986:	eb 24                	jmp    8019ac <read+0x8c>
	}
	if (!dev->dev_read)
  801988:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198b:	8b 52 08             	mov    0x8(%edx),%edx
  80198e:	85 d2                	test   %edx,%edx
  801990:	74 15                	je     8019a7 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801992:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801995:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801999:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80199c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019a0:	89 04 24             	mov    %eax,(%esp)
  8019a3:	ff d2                	call   *%edx
  8019a5:	eb 05                	jmp    8019ac <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8019ac:	83 c4 24             	add    $0x24,%esp
  8019af:	5b                   	pop    %ebx
  8019b0:	5d                   	pop    %ebp
  8019b1:	c3                   	ret    

008019b2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	57                   	push   %edi
  8019b6:	56                   	push   %esi
  8019b7:	53                   	push   %ebx
  8019b8:	83 ec 1c             	sub    $0x1c,%esp
  8019bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019be:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019c6:	eb 23                	jmp    8019eb <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019c8:	89 f0                	mov    %esi,%eax
  8019ca:	29 d8                	sub    %ebx,%eax
  8019cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d3:	01 d8                	add    %ebx,%eax
  8019d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d9:	89 3c 24             	mov    %edi,(%esp)
  8019dc:	e8 3f ff ff ff       	call   801920 <read>
		if (m < 0)
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	78 10                	js     8019f5 <readn+0x43>
			return m;
		if (m == 0)
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	74 0a                	je     8019f3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019e9:	01 c3                	add    %eax,%ebx
  8019eb:	39 f3                	cmp    %esi,%ebx
  8019ed:	72 d9                	jb     8019c8 <readn+0x16>
  8019ef:	89 d8                	mov    %ebx,%eax
  8019f1:	eb 02                	jmp    8019f5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8019f3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8019f5:	83 c4 1c             	add    $0x1c,%esp
  8019f8:	5b                   	pop    %ebx
  8019f9:	5e                   	pop    %esi
  8019fa:	5f                   	pop    %edi
  8019fb:	5d                   	pop    %ebp
  8019fc:	c3                   	ret    

008019fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	53                   	push   %ebx
  801a01:	83 ec 24             	sub    $0x24,%esp
  801a04:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a07:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0e:	89 1c 24             	mov    %ebx,(%esp)
  801a11:	e8 6c fc ff ff       	call   801682 <fd_lookup>
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 6a                	js     801a84 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a24:	8b 00                	mov    (%eax),%eax
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 aa fc ff ff       	call   8016d8 <dev_lookup>
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 52                	js     801a84 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a35:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a39:	75 25                	jne    801a60 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a3b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a40:	8b 00                	mov    (%eax),%eax
  801a42:	8b 40 48             	mov    0x48(%eax),%eax
  801a45:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4d:	c7 04 24 6d 2c 80 00 	movl   $0x802c6d,(%esp)
  801a54:	e8 43 e9 ff ff       	call   80039c <cprintf>
		return -E_INVAL;
  801a59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a5e:	eb 24                	jmp    801a84 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a60:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a63:	8b 52 0c             	mov    0xc(%edx),%edx
  801a66:	85 d2                	test   %edx,%edx
  801a68:	74 15                	je     801a7f <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a74:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a78:	89 04 24             	mov    %eax,(%esp)
  801a7b:	ff d2                	call   *%edx
  801a7d:	eb 05                	jmp    801a84 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a7f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a84:	83 c4 24             	add    $0x24,%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    

00801a8a <seek>:

int
seek(int fdnum, off_t offset)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a90:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a97:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9a:	89 04 24             	mov    %eax,(%esp)
  801a9d:	e8 e0 fb ff ff       	call   801682 <fd_lookup>
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	78 0e                	js     801ab4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801aa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801aaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 24             	sub    $0x24,%esp
  801abd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ac0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac7:	89 1c 24             	mov    %ebx,(%esp)
  801aca:	e8 b3 fb ff ff       	call   801682 <fd_lookup>
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	78 63                	js     801b36 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ad3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801add:	8b 00                	mov    (%eax),%eax
  801adf:	89 04 24             	mov    %eax,(%esp)
  801ae2:	e8 f1 fb ff ff       	call   8016d8 <dev_lookup>
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 4b                	js     801b36 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801af2:	75 25                	jne    801b19 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801af4:	a1 04 40 80 00       	mov    0x804004,%eax
  801af9:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801afb:	8b 40 48             	mov    0x48(%eax),%eax
  801afe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b06:	c7 04 24 30 2c 80 00 	movl   $0x802c30,(%esp)
  801b0d:	e8 8a e8 ff ff       	call   80039c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b17:	eb 1d                	jmp    801b36 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801b19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b1c:	8b 52 18             	mov    0x18(%edx),%edx
  801b1f:	85 d2                	test   %edx,%edx
  801b21:	74 0e                	je     801b31 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b26:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b2a:	89 04 24             	mov    %eax,(%esp)
  801b2d:	ff d2                	call   *%edx
  801b2f:	eb 05                	jmp    801b36 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b31:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b36:	83 c4 24             	add    $0x24,%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 24             	sub    $0x24,%esp
  801b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b50:	89 04 24             	mov    %eax,(%esp)
  801b53:	e8 2a fb ff ff       	call   801682 <fd_lookup>
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	78 52                	js     801bae <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b66:	8b 00                	mov    (%eax),%eax
  801b68:	89 04 24             	mov    %eax,(%esp)
  801b6b:	e8 68 fb ff ff       	call   8016d8 <dev_lookup>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 3a                	js     801bae <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b77:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b7b:	74 2c                	je     801ba9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b7d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b80:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b87:	00 00 00 
	stat->st_isdir = 0;
  801b8a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b91:	00 00 00 
	stat->st_dev = dev;
  801b94:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b9e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ba1:	89 14 24             	mov    %edx,(%esp)
  801ba4:	ff 50 14             	call   *0x14(%eax)
  801ba7:	eb 05                	jmp    801bae <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801ba9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bae:	83 c4 24             	add    $0x24,%esp
  801bb1:	5b                   	pop    %ebx
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    

00801bb4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bbc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bc3:	00 
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	89 04 24             	mov    %eax,(%esp)
  801bca:	e8 88 02 00 00       	call   801e57 <open>
  801bcf:	89 c3                	mov    %eax,%ebx
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	78 1b                	js     801bf0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdc:	89 1c 24             	mov    %ebx,(%esp)
  801bdf:	e8 58 ff ff ff       	call   801b3c <fstat>
  801be4:	89 c6                	mov    %eax,%esi
	close(fd);
  801be6:	89 1c 24             	mov    %ebx,(%esp)
  801be9:	e8 ce fb ff ff       	call   8017bc <close>
	return r;
  801bee:	89 f3                	mov    %esi,%ebx
}
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	5b                   	pop    %ebx
  801bf6:	5e                   	pop    %esi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    
  801bf9:	00 00                	add    %al,(%eax)
	...

00801bfc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	83 ec 10             	sub    $0x10,%esp
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c08:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c0f:	75 11                	jne    801c22 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c18:	e8 a2 f9 ff ff       	call   8015bf <ipc_find_env>
  801c1d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c22:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c29:	00 
  801c2a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c31:	00 
  801c32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c36:	a1 00 40 80 00       	mov    0x804000,%eax
  801c3b:	89 04 24             	mov    %eax,(%esp)
  801c3e:	e8 16 f9 ff ff       	call   801559 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801c43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c4a:	00 
  801c4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c56:	e8 91 f8 ff ff       	call   8014ec <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5e                   	pop    %esi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c68:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6b:	8b 40 0c             	mov    0xc(%eax),%eax
  801c6e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c76:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c80:	b8 02 00 00 00       	mov    $0x2,%eax
  801c85:	e8 72 ff ff ff       	call   801bfc <fsipc>
}
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	8b 40 0c             	mov    0xc(%eax),%eax
  801c98:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca2:	b8 06 00 00 00       	mov    $0x6,%eax
  801ca7:	e8 50 ff ff ff       	call   801bfc <fsipc>
}
  801cac:	c9                   	leave  
  801cad:	c3                   	ret    

00801cae <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	53                   	push   %ebx
  801cb2:	83 ec 14             	sub    $0x14,%esp
  801cb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbb:	8b 40 0c             	mov    0xc(%eax),%eax
  801cbe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cc3:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc8:	b8 05 00 00 00       	mov    $0x5,%eax
  801ccd:	e8 2a ff ff ff       	call   801bfc <fsipc>
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	78 2b                	js     801d01 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cd6:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cdd:	00 
  801cde:	89 1c 24             	mov    %ebx,(%esp)
  801ce1:	e8 61 ec ff ff       	call   800947 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ce6:	a1 80 50 80 00       	mov    0x805080,%eax
  801ceb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cf1:	a1 84 50 80 00       	mov    0x805084,%eax
  801cf6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801cfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d01:	83 c4 14             	add    $0x14,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    

00801d07 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 14             	sub    $0x14,%esp
  801d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d11:	8b 45 08             	mov    0x8(%ebp),%eax
  801d14:	8b 40 0c             	mov    0xc(%eax),%eax
  801d17:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801d24:	76 05                	jbe    801d2b <devfile_write+0x24>
  801d26:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801d2b:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801d30:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3b:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801d42:	e8 e3 ed ff ff       	call   800b2a <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801d47:	ba 00 00 00 00       	mov    $0x0,%edx
  801d4c:	b8 04 00 00 00       	mov    $0x4,%eax
  801d51:	e8 a6 fe ff ff       	call   801bfc <fsipc>
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 53                	js     801dad <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801d5a:	39 c3                	cmp    %eax,%ebx
  801d5c:	73 24                	jae    801d82 <devfile_write+0x7b>
  801d5e:	c7 44 24 0c 9c 2c 80 	movl   $0x802c9c,0xc(%esp)
  801d65:	00 
  801d66:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  801d6d:	00 
  801d6e:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801d75:	00 
  801d76:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  801d7d:	e8 22 e5 ff ff       	call   8002a4 <_panic>
	assert(r <= PGSIZE);
  801d82:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d87:	7e 24                	jle    801dad <devfile_write+0xa6>
  801d89:	c7 44 24 0c c3 2c 80 	movl   $0x802cc3,0xc(%esp)
  801d90:	00 
  801d91:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  801d98:	00 
  801d99:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801da0:	00 
  801da1:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  801da8:	e8 f7 e4 ff ff       	call   8002a4 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801dad:	83 c4 14             	add    $0x14,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    

00801db3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	56                   	push   %esi
  801db7:	53                   	push   %ebx
  801db8:	83 ec 10             	sub    $0x10,%esp
  801dbb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc1:	8b 40 0c             	mov    0xc(%eax),%eax
  801dc4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801dc9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801dcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd4:	b8 03 00 00 00       	mov    $0x3,%eax
  801dd9:	e8 1e fe ff ff       	call   801bfc <fsipc>
  801dde:	89 c3                	mov    %eax,%ebx
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 6a                	js     801e4e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801de4:	39 c6                	cmp    %eax,%esi
  801de6:	73 24                	jae    801e0c <devfile_read+0x59>
  801de8:	c7 44 24 0c 9c 2c 80 	movl   $0x802c9c,0xc(%esp)
  801def:	00 
  801df0:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  801df7:	00 
  801df8:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801dff:	00 
  801e00:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  801e07:	e8 98 e4 ff ff       	call   8002a4 <_panic>
	assert(r <= PGSIZE);
  801e0c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e11:	7e 24                	jle    801e37 <devfile_read+0x84>
  801e13:	c7 44 24 0c c3 2c 80 	movl   $0x802cc3,0xc(%esp)
  801e1a:	00 
  801e1b:	c7 44 24 08 a3 2c 80 	movl   $0x802ca3,0x8(%esp)
  801e22:	00 
  801e23:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801e2a:	00 
  801e2b:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  801e32:	e8 6d e4 ff ff       	call   8002a4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e3b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e42:	00 
  801e43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e46:	89 04 24             	mov    %eax,(%esp)
  801e49:	e8 72 ec ff ff       	call   800ac0 <memmove>
	return r;
}
  801e4e:	89 d8                	mov    %ebx,%eax
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	56                   	push   %esi
  801e5b:	53                   	push   %ebx
  801e5c:	83 ec 20             	sub    $0x20,%esp
  801e5f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e62:	89 34 24             	mov    %esi,(%esp)
  801e65:	e8 aa ea ff ff       	call   800914 <strlen>
  801e6a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e6f:	7f 60                	jg     801ed1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e74:	89 04 24             	mov    %eax,(%esp)
  801e77:	e8 b3 f7 ff ff       	call   80162f <fd_alloc>
  801e7c:	89 c3                	mov    %eax,%ebx
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	78 54                	js     801ed6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e82:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e86:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e8d:	e8 b5 ea ff ff       	call   800947 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e95:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea2:	e8 55 fd ff ff       	call   801bfc <fsipc>
  801ea7:	89 c3                	mov    %eax,%ebx
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	79 15                	jns    801ec2 <open+0x6b>
		fd_close(fd, 0);
  801ead:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801eb4:	00 
  801eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb8:	89 04 24             	mov    %eax,(%esp)
  801ebb:	e8 74 f8 ff ff       	call   801734 <fd_close>
		return r;
  801ec0:	eb 14                	jmp    801ed6 <open+0x7f>
	}

	return fd2num(fd);
  801ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec5:	89 04 24             	mov    %eax,(%esp)
  801ec8:	e8 37 f7 ff ff       	call   801604 <fd2num>
  801ecd:	89 c3                	mov    %eax,%ebx
  801ecf:	eb 05                	jmp    801ed6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ed1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ed6:	89 d8                	mov    %ebx,%eax
  801ed8:	83 c4 20             	add    $0x20,%esp
  801edb:	5b                   	pop    %ebx
  801edc:	5e                   	pop    %esi
  801edd:	5d                   	pop    %ebp
  801ede:	c3                   	ret    

00801edf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ee5:	ba 00 00 00 00       	mov    $0x0,%edx
  801eea:	b8 08 00 00 00       	mov    $0x8,%eax
  801eef:	e8 08 fd ff ff       	call   801bfc <fsipc>
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    
	...

00801ef8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801efe:	89 c2                	mov    %eax,%edx
  801f00:	c1 ea 16             	shr    $0x16,%edx
  801f03:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f0a:	f6 c2 01             	test   $0x1,%dl
  801f0d:	74 1e                	je     801f2d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f0f:	c1 e8 0c             	shr    $0xc,%eax
  801f12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f19:	a8 01                	test   $0x1,%al
  801f1b:	74 17                	je     801f34 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f1d:	c1 e8 0c             	shr    $0xc,%eax
  801f20:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f27:	ef 
  801f28:	0f b7 c0             	movzwl %ax,%eax
  801f2b:	eb 0c                	jmp    801f39 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f32:	eb 05                	jmp    801f39 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f34:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f39:	5d                   	pop    %ebp
  801f3a:	c3                   	ret    
	...

00801f3c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	56                   	push   %esi
  801f40:	53                   	push   %ebx
  801f41:	83 ec 10             	sub    $0x10,%esp
  801f44:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f47:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4a:	89 04 24             	mov    %eax,(%esp)
  801f4d:	e8 c2 f6 ff ff       	call   801614 <fd2data>
  801f52:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801f54:	c7 44 24 04 cf 2c 80 	movl   $0x802ccf,0x4(%esp)
  801f5b:	00 
  801f5c:	89 34 24             	mov    %esi,(%esp)
  801f5f:	e8 e3 e9 ff ff       	call   800947 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f64:	8b 43 04             	mov    0x4(%ebx),%eax
  801f67:	2b 03                	sub    (%ebx),%eax
  801f69:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f6f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f76:	00 00 00 
	stat->st_dev = &devpipe;
  801f79:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801f80:	30 80 00 
	return 0;
}
  801f83:	b8 00 00 00 00       	mov    $0x0,%eax
  801f88:	83 c4 10             	add    $0x10,%esp
  801f8b:	5b                   	pop    %ebx
  801f8c:	5e                   	pop    %esi
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    

00801f8f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	53                   	push   %ebx
  801f93:	83 ec 14             	sub    $0x14,%esp
  801f96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa4:	e8 37 ee ff ff       	call   800de0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fa9:	89 1c 24             	mov    %ebx,(%esp)
  801fac:	e8 63 f6 ff ff       	call   801614 <fd2data>
  801fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fbc:	e8 1f ee ff ff       	call   800de0 <sys_page_unmap>
}
  801fc1:	83 c4 14             	add    $0x14,%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5d                   	pop    %ebp
  801fc6:	c3                   	ret    

00801fc7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	57                   	push   %edi
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	83 ec 2c             	sub    $0x2c,%esp
  801fd0:	89 c7                	mov    %eax,%edi
  801fd2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fd5:	a1 04 40 80 00       	mov    0x804004,%eax
  801fda:	8b 00                	mov    (%eax),%eax
  801fdc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fdf:	89 3c 24             	mov    %edi,(%esp)
  801fe2:	e8 11 ff ff ff       	call   801ef8 <pageref>
  801fe7:	89 c6                	mov    %eax,%esi
  801fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fec:	89 04 24             	mov    %eax,(%esp)
  801fef:	e8 04 ff ff ff       	call   801ef8 <pageref>
  801ff4:	39 c6                	cmp    %eax,%esi
  801ff6:	0f 94 c0             	sete   %al
  801ff9:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ffc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802002:	8b 12                	mov    (%edx),%edx
  802004:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802007:	39 cb                	cmp    %ecx,%ebx
  802009:	75 08                	jne    802013 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80200b:	83 c4 2c             	add    $0x2c,%esp
  80200e:	5b                   	pop    %ebx
  80200f:	5e                   	pop    %esi
  802010:	5f                   	pop    %edi
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802013:	83 f8 01             	cmp    $0x1,%eax
  802016:	75 bd                	jne    801fd5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802018:	8b 42 58             	mov    0x58(%edx),%eax
  80201b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802022:	00 
  802023:	89 44 24 08          	mov    %eax,0x8(%esp)
  802027:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80202b:	c7 04 24 d6 2c 80 00 	movl   $0x802cd6,(%esp)
  802032:	e8 65 e3 ff ff       	call   80039c <cprintf>
  802037:	eb 9c                	jmp    801fd5 <_pipeisclosed+0xe>

00802039 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	57                   	push   %edi
  80203d:	56                   	push   %esi
  80203e:	53                   	push   %ebx
  80203f:	83 ec 1c             	sub    $0x1c,%esp
  802042:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802045:	89 34 24             	mov    %esi,(%esp)
  802048:	e8 c7 f5 ff ff       	call   801614 <fd2data>
  80204d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80204f:	bf 00 00 00 00       	mov    $0x0,%edi
  802054:	eb 3c                	jmp    802092 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802056:	89 da                	mov    %ebx,%edx
  802058:	89 f0                	mov    %esi,%eax
  80205a:	e8 68 ff ff ff       	call   801fc7 <_pipeisclosed>
  80205f:	85 c0                	test   %eax,%eax
  802061:	75 38                	jne    80209b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802063:	e8 b2 ec ff ff       	call   800d1a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802068:	8b 43 04             	mov    0x4(%ebx),%eax
  80206b:	8b 13                	mov    (%ebx),%edx
  80206d:	83 c2 20             	add    $0x20,%edx
  802070:	39 d0                	cmp    %edx,%eax
  802072:	73 e2                	jae    802056 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802074:	8b 55 0c             	mov    0xc(%ebp),%edx
  802077:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80207a:	89 c2                	mov    %eax,%edx
  80207c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802082:	79 05                	jns    802089 <devpipe_write+0x50>
  802084:	4a                   	dec    %edx
  802085:	83 ca e0             	or     $0xffffffe0,%edx
  802088:	42                   	inc    %edx
  802089:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80208d:	40                   	inc    %eax
  80208e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802091:	47                   	inc    %edi
  802092:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802095:	75 d1                	jne    802068 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802097:	89 f8                	mov    %edi,%eax
  802099:	eb 05                	jmp    8020a0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80209b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    

008020a8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	57                   	push   %edi
  8020ac:	56                   	push   %esi
  8020ad:	53                   	push   %ebx
  8020ae:	83 ec 1c             	sub    $0x1c,%esp
  8020b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020b4:	89 3c 24             	mov    %edi,(%esp)
  8020b7:	e8 58 f5 ff ff       	call   801614 <fd2data>
  8020bc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020be:	be 00 00 00 00       	mov    $0x0,%esi
  8020c3:	eb 3a                	jmp    8020ff <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020c5:	85 f6                	test   %esi,%esi
  8020c7:	74 04                	je     8020cd <devpipe_read+0x25>
				return i;
  8020c9:	89 f0                	mov    %esi,%eax
  8020cb:	eb 40                	jmp    80210d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020cd:	89 da                	mov    %ebx,%edx
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	e8 f1 fe ff ff       	call   801fc7 <_pipeisclosed>
  8020d6:	85 c0                	test   %eax,%eax
  8020d8:	75 2e                	jne    802108 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020da:	e8 3b ec ff ff       	call   800d1a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020df:	8b 03                	mov    (%ebx),%eax
  8020e1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020e4:	74 df                	je     8020c5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020e6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8020eb:	79 05                	jns    8020f2 <devpipe_read+0x4a>
  8020ed:	48                   	dec    %eax
  8020ee:	83 c8 e0             	or     $0xffffffe0,%eax
  8020f1:	40                   	inc    %eax
  8020f2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8020f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020f9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8020fc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020fe:	46                   	inc    %esi
  8020ff:	3b 75 10             	cmp    0x10(%ebp),%esi
  802102:	75 db                	jne    8020df <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802104:	89 f0                	mov    %esi,%eax
  802106:	eb 05                	jmp    80210d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802108:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80210d:	83 c4 1c             	add    $0x1c,%esp
  802110:	5b                   	pop    %ebx
  802111:	5e                   	pop    %esi
  802112:	5f                   	pop    %edi
  802113:	5d                   	pop    %ebp
  802114:	c3                   	ret    

00802115 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	57                   	push   %edi
  802119:	56                   	push   %esi
  80211a:	53                   	push   %ebx
  80211b:	83 ec 3c             	sub    $0x3c,%esp
  80211e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802121:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802124:	89 04 24             	mov    %eax,(%esp)
  802127:	e8 03 f5 ff ff       	call   80162f <fd_alloc>
  80212c:	89 c3                	mov    %eax,%ebx
  80212e:	85 c0                	test   %eax,%eax
  802130:	0f 88 45 01 00 00    	js     80227b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802136:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80213d:	00 
  80213e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802141:	89 44 24 04          	mov    %eax,0x4(%esp)
  802145:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80214c:	e8 e8 eb ff ff       	call   800d39 <sys_page_alloc>
  802151:	89 c3                	mov    %eax,%ebx
  802153:	85 c0                	test   %eax,%eax
  802155:	0f 88 20 01 00 00    	js     80227b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80215b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80215e:	89 04 24             	mov    %eax,(%esp)
  802161:	e8 c9 f4 ff ff       	call   80162f <fd_alloc>
  802166:	89 c3                	mov    %eax,%ebx
  802168:	85 c0                	test   %eax,%eax
  80216a:	0f 88 f8 00 00 00    	js     802268 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802170:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802177:	00 
  802178:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80217b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80217f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802186:	e8 ae eb ff ff       	call   800d39 <sys_page_alloc>
  80218b:	89 c3                	mov    %eax,%ebx
  80218d:	85 c0                	test   %eax,%eax
  80218f:	0f 88 d3 00 00 00    	js     802268 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802195:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802198:	89 04 24             	mov    %eax,(%esp)
  80219b:	e8 74 f4 ff ff       	call   801614 <fd2data>
  8021a0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021a9:	00 
  8021aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b5:	e8 7f eb ff ff       	call   800d39 <sys_page_alloc>
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	0f 88 91 00 00 00    	js     802255 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021c7:	89 04 24             	mov    %eax,(%esp)
  8021ca:	e8 45 f4 ff ff       	call   801614 <fd2data>
  8021cf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8021d6:	00 
  8021d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8021e2:	00 
  8021e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ee:	e8 9a eb ff ff       	call   800d8d <sys_page_map>
  8021f3:	89 c3                	mov    %eax,%ebx
  8021f5:	85 c0                	test   %eax,%eax
  8021f7:	78 4c                	js     802245 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021f9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8021ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802202:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802204:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802207:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80220e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802214:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802217:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802219:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80221c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802226:	89 04 24             	mov    %eax,(%esp)
  802229:	e8 d6 f3 ff ff       	call   801604 <fd2num>
  80222e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802230:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802233:	89 04 24             	mov    %eax,(%esp)
  802236:	e8 c9 f3 ff ff       	call   801604 <fd2num>
  80223b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80223e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802243:	eb 36                	jmp    80227b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802245:	89 74 24 04          	mov    %esi,0x4(%esp)
  802249:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802250:	e8 8b eb ff ff       	call   800de0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802255:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802263:	e8 78 eb ff ff       	call   800de0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80226b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80226f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802276:	e8 65 eb ff ff       	call   800de0 <sys_page_unmap>
    err:
	return r;
}
  80227b:	89 d8                	mov    %ebx,%eax
  80227d:	83 c4 3c             	add    $0x3c,%esp
  802280:	5b                   	pop    %ebx
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    

00802285 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80228b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802292:	8b 45 08             	mov    0x8(%ebp),%eax
  802295:	89 04 24             	mov    %eax,(%esp)
  802298:	e8 e5 f3 ff ff       	call   801682 <fd_lookup>
  80229d:	85 c0                	test   %eax,%eax
  80229f:	78 15                	js     8022b6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a4:	89 04 24             	mov    %eax,(%esp)
  8022a7:	e8 68 f3 ff ff       	call   801614 <fd2data>
	return _pipeisclosed(fd, p);
  8022ac:	89 c2                	mov    %eax,%edx
  8022ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b1:	e8 11 fd ff ff       	call   801fc7 <_pipeisclosed>
}
  8022b6:	c9                   	leave  
  8022b7:	c3                   	ret    

008022b8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    

008022c2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8022c8:	c7 44 24 04 ee 2c 80 	movl   $0x802cee,0x4(%esp)
  8022cf:	00 
  8022d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d3:	89 04 24             	mov    %eax,(%esp)
  8022d6:	e8 6c e6 ff ff       	call   800947 <strcpy>
	return 0;
}
  8022db:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e0:	c9                   	leave  
  8022e1:	c3                   	ret    

008022e2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022e2:	55                   	push   %ebp
  8022e3:	89 e5                	mov    %esp,%ebp
  8022e5:	57                   	push   %edi
  8022e6:	56                   	push   %esi
  8022e7:	53                   	push   %ebx
  8022e8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022f3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f9:	eb 30                	jmp    80232b <devcons_write+0x49>
		m = n - tot;
  8022fb:	8b 75 10             	mov    0x10(%ebp),%esi
  8022fe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802300:	83 fe 7f             	cmp    $0x7f,%esi
  802303:	76 05                	jbe    80230a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802305:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80230a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80230e:	03 45 0c             	add    0xc(%ebp),%eax
  802311:	89 44 24 04          	mov    %eax,0x4(%esp)
  802315:	89 3c 24             	mov    %edi,(%esp)
  802318:	e8 a3 e7 ff ff       	call   800ac0 <memmove>
		sys_cputs(buf, m);
  80231d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802321:	89 3c 24             	mov    %edi,(%esp)
  802324:	e8 43 e9 ff ff       	call   800c6c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802329:	01 f3                	add    %esi,%ebx
  80232b:	89 d8                	mov    %ebx,%eax
  80232d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802330:	72 c9                	jb     8022fb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802332:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    

0080233d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802343:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802347:	75 07                	jne    802350 <devcons_read+0x13>
  802349:	eb 25                	jmp    802370 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80234b:	e8 ca e9 ff ff       	call   800d1a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802350:	e8 35 e9 ff ff       	call   800c8a <sys_cgetc>
  802355:	85 c0                	test   %eax,%eax
  802357:	74 f2                	je     80234b <devcons_read+0xe>
  802359:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80235b:	85 c0                	test   %eax,%eax
  80235d:	78 1d                	js     80237c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80235f:	83 f8 04             	cmp    $0x4,%eax
  802362:	74 13                	je     802377 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802364:	8b 45 0c             	mov    0xc(%ebp),%eax
  802367:	88 10                	mov    %dl,(%eax)
	return 1;
  802369:	b8 01 00 00 00       	mov    $0x1,%eax
  80236e:	eb 0c                	jmp    80237c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802370:	b8 00 00 00 00       	mov    $0x0,%eax
  802375:	eb 05                	jmp    80237c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802377:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80237c:	c9                   	leave  
  80237d:	c3                   	ret    

0080237e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80237e:	55                   	push   %ebp
  80237f:	89 e5                	mov    %esp,%ebp
  802381:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802384:	8b 45 08             	mov    0x8(%ebp),%eax
  802387:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80238a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802391:	00 
  802392:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802395:	89 04 24             	mov    %eax,(%esp)
  802398:	e8 cf e8 ff ff       	call   800c6c <sys_cputs>
}
  80239d:	c9                   	leave  
  80239e:	c3                   	ret    

0080239f <getchar>:

int
getchar(void)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8023ac:	00 
  8023ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023bb:	e8 60 f5 ff ff       	call   801920 <read>
	if (r < 0)
  8023c0:	85 c0                	test   %eax,%eax
  8023c2:	78 0f                	js     8023d3 <getchar+0x34>
		return r;
	if (r < 1)
  8023c4:	85 c0                	test   %eax,%eax
  8023c6:	7e 06                	jle    8023ce <getchar+0x2f>
		return -E_EOF;
	return c;
  8023c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023cc:	eb 05                	jmp    8023d3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023d3:	c9                   	leave  
  8023d4:	c3                   	ret    

008023d5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e5:	89 04 24             	mov    %eax,(%esp)
  8023e8:	e8 95 f2 ff ff       	call   801682 <fd_lookup>
  8023ed:	85 c0                	test   %eax,%eax
  8023ef:	78 11                	js     802402 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023fa:	39 10                	cmp    %edx,(%eax)
  8023fc:	0f 94 c0             	sete   %al
  8023ff:	0f b6 c0             	movzbl %al,%eax
}
  802402:	c9                   	leave  
  802403:	c3                   	ret    

00802404 <opencons>:

int
opencons(void)
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80240a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80240d:	89 04 24             	mov    %eax,(%esp)
  802410:	e8 1a f2 ff ff       	call   80162f <fd_alloc>
  802415:	85 c0                	test   %eax,%eax
  802417:	78 3c                	js     802455 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802419:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802420:	00 
  802421:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802424:	89 44 24 04          	mov    %eax,0x4(%esp)
  802428:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80242f:	e8 05 e9 ff ff       	call   800d39 <sys_page_alloc>
  802434:	85 c0                	test   %eax,%eax
  802436:	78 1d                	js     802455 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802438:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80243e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802441:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802443:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802446:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80244d:	89 04 24             	mov    %eax,(%esp)
  802450:	e8 af f1 ff ff       	call   801604 <fd2num>
}
  802455:	c9                   	leave  
  802456:	c3                   	ret    
	...

00802458 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802458:	55                   	push   %ebp
  802459:	89 e5                	mov    %esp,%ebp
  80245b:	53                   	push   %ebx
  80245c:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80245f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802466:	75 6f                	jne    8024d7 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  802468:	e8 8e e8 ff ff       	call   800cfb <sys_getenvid>
  80246d:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80246f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802476:	00 
  802477:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80247e:	ee 
  80247f:	89 04 24             	mov    %eax,(%esp)
  802482:	e8 b2 e8 ff ff       	call   800d39 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  802487:	85 c0                	test   %eax,%eax
  802489:	79 1c                	jns    8024a7 <set_pgfault_handler+0x4f>
  80248b:	c7 44 24 08 fc 2c 80 	movl   $0x802cfc,0x8(%esp)
  802492:	00 
  802493:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80249a:	00 
  80249b:	c7 04 24 58 2d 80 00 	movl   $0x802d58,(%esp)
  8024a2:	e8 fd dd ff ff       	call   8002a4 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8024a7:	c7 44 24 04 e8 24 80 	movl   $0x8024e8,0x4(%esp)
  8024ae:	00 
  8024af:	89 1c 24             	mov    %ebx,(%esp)
  8024b2:	e8 22 ea ff ff       	call   800ed9 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  8024b7:	85 c0                	test   %eax,%eax
  8024b9:	79 1c                	jns    8024d7 <set_pgfault_handler+0x7f>
  8024bb:	c7 44 24 08 24 2d 80 	movl   $0x802d24,0x8(%esp)
  8024c2:	00 
  8024c3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8024ca:	00 
  8024cb:	c7 04 24 58 2d 80 00 	movl   $0x802d58,(%esp)
  8024d2:	e8 cd dd ff ff       	call   8002a4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024da:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8024df:	83 c4 14             	add    $0x14,%esp
  8024e2:	5b                   	pop    %ebx
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    
  8024e5:	00 00                	add    %al,(%eax)
	...

008024e8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8024e8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8024e9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8024ee:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024f0:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  8024f3:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  8024f7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  8024fc:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  802500:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  802502:	83 c4 08             	add    $0x8,%esp
	popal
  802505:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  802506:	83 c4 04             	add    $0x4,%esp
	popfl
  802509:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  80250a:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80250d:	c3                   	ret    
	...

00802510 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	83 ec 10             	sub    $0x10,%esp
  802516:	8b 74 24 20          	mov    0x20(%esp),%esi
  80251a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80251e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802522:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802526:	89 cd                	mov    %ecx,%ebp
  802528:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80252c:	85 c0                	test   %eax,%eax
  80252e:	75 2c                	jne    80255c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802530:	39 f9                	cmp    %edi,%ecx
  802532:	77 68                	ja     80259c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802534:	85 c9                	test   %ecx,%ecx
  802536:	75 0b                	jne    802543 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802538:	b8 01 00 00 00       	mov    $0x1,%eax
  80253d:	31 d2                	xor    %edx,%edx
  80253f:	f7 f1                	div    %ecx
  802541:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802543:	31 d2                	xor    %edx,%edx
  802545:	89 f8                	mov    %edi,%eax
  802547:	f7 f1                	div    %ecx
  802549:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80254b:	89 f0                	mov    %esi,%eax
  80254d:	f7 f1                	div    %ecx
  80254f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802551:	89 f0                	mov    %esi,%eax
  802553:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802555:	83 c4 10             	add    $0x10,%esp
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80255c:	39 f8                	cmp    %edi,%eax
  80255e:	77 2c                	ja     80258c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802560:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802563:	83 f6 1f             	xor    $0x1f,%esi
  802566:	75 4c                	jne    8025b4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802568:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80256a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80256f:	72 0a                	jb     80257b <__udivdi3+0x6b>
  802571:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802575:	0f 87 ad 00 00 00    	ja     802628 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80257b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802580:	89 f0                	mov    %esi,%eax
  802582:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802584:	83 c4 10             	add    $0x10,%esp
  802587:	5e                   	pop    %esi
  802588:	5f                   	pop    %edi
  802589:	5d                   	pop    %ebp
  80258a:	c3                   	ret    
  80258b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80258c:	31 ff                	xor    %edi,%edi
  80258e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802590:	89 f0                	mov    %esi,%eax
  802592:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802594:	83 c4 10             	add    $0x10,%esp
  802597:	5e                   	pop    %esi
  802598:	5f                   	pop    %edi
  802599:	5d                   	pop    %ebp
  80259a:	c3                   	ret    
  80259b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80259c:	89 fa                	mov    %edi,%edx
  80259e:	89 f0                	mov    %esi,%eax
  8025a0:	f7 f1                	div    %ecx
  8025a2:	89 c6                	mov    %eax,%esi
  8025a4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025a6:	89 f0                	mov    %esi,%eax
  8025a8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025aa:	83 c4 10             	add    $0x10,%esp
  8025ad:	5e                   	pop    %esi
  8025ae:	5f                   	pop    %edi
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    
  8025b1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025b4:	89 f1                	mov    %esi,%ecx
  8025b6:	d3 e0                	shl    %cl,%eax
  8025b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8025c1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8025c3:	89 ea                	mov    %ebp,%edx
  8025c5:	88 c1                	mov    %al,%cl
  8025c7:	d3 ea                	shr    %cl,%edx
  8025c9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8025cd:	09 ca                	or     %ecx,%edx
  8025cf:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8025d3:	89 f1                	mov    %esi,%ecx
  8025d5:	d3 e5                	shl    %cl,%ebp
  8025d7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8025db:	89 fd                	mov    %edi,%ebp
  8025dd:	88 c1                	mov    %al,%cl
  8025df:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8025e1:	89 fa                	mov    %edi,%edx
  8025e3:	89 f1                	mov    %esi,%ecx
  8025e5:	d3 e2                	shl    %cl,%edx
  8025e7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025eb:	88 c1                	mov    %al,%cl
  8025ed:	d3 ef                	shr    %cl,%edi
  8025ef:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025f1:	89 f8                	mov    %edi,%eax
  8025f3:	89 ea                	mov    %ebp,%edx
  8025f5:	f7 74 24 08          	divl   0x8(%esp)
  8025f9:	89 d1                	mov    %edx,%ecx
  8025fb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8025fd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802601:	39 d1                	cmp    %edx,%ecx
  802603:	72 17                	jb     80261c <__udivdi3+0x10c>
  802605:	74 09                	je     802610 <__udivdi3+0x100>
  802607:	89 fe                	mov    %edi,%esi
  802609:	31 ff                	xor    %edi,%edi
  80260b:	e9 41 ff ff ff       	jmp    802551 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802610:	8b 54 24 04          	mov    0x4(%esp),%edx
  802614:	89 f1                	mov    %esi,%ecx
  802616:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802618:	39 c2                	cmp    %eax,%edx
  80261a:	73 eb                	jae    802607 <__udivdi3+0xf7>
		{
		  q0--;
  80261c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80261f:	31 ff                	xor    %edi,%edi
  802621:	e9 2b ff ff ff       	jmp    802551 <__udivdi3+0x41>
  802626:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802628:	31 f6                	xor    %esi,%esi
  80262a:	e9 22 ff ff ff       	jmp    802551 <__udivdi3+0x41>
	...

00802630 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802630:	55                   	push   %ebp
  802631:	57                   	push   %edi
  802632:	56                   	push   %esi
  802633:	83 ec 20             	sub    $0x20,%esp
  802636:	8b 44 24 30          	mov    0x30(%esp),%eax
  80263a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80263e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802642:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802646:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80264a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80264e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802650:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802652:	85 ed                	test   %ebp,%ebp
  802654:	75 16                	jne    80266c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802656:	39 f1                	cmp    %esi,%ecx
  802658:	0f 86 a6 00 00 00    	jbe    802704 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80265e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802660:	89 d0                	mov    %edx,%eax
  802662:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802664:	83 c4 20             	add    $0x20,%esp
  802667:	5e                   	pop    %esi
  802668:	5f                   	pop    %edi
  802669:	5d                   	pop    %ebp
  80266a:	c3                   	ret    
  80266b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80266c:	39 f5                	cmp    %esi,%ebp
  80266e:	0f 87 ac 00 00 00    	ja     802720 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802674:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802677:	83 f0 1f             	xor    $0x1f,%eax
  80267a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80267e:	0f 84 a8 00 00 00    	je     80272c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802684:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802688:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80268a:	bf 20 00 00 00       	mov    $0x20,%edi
  80268f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802693:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802697:	89 f9                	mov    %edi,%ecx
  802699:	d3 e8                	shr    %cl,%eax
  80269b:	09 e8                	or     %ebp,%eax
  80269d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8026a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026a5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026a9:	d3 e0                	shl    %cl,%eax
  8026ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8026af:	89 f2                	mov    %esi,%edx
  8026b1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8026b3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026b7:	d3 e0                	shl    %cl,%eax
  8026b9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8026bd:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026c1:	89 f9                	mov    %edi,%ecx
  8026c3:	d3 e8                	shr    %cl,%eax
  8026c5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8026c7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8026c9:	89 f2                	mov    %esi,%edx
  8026cb:	f7 74 24 18          	divl   0x18(%esp)
  8026cf:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8026d1:	f7 64 24 0c          	mull   0xc(%esp)
  8026d5:	89 c5                	mov    %eax,%ebp
  8026d7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026d9:	39 d6                	cmp    %edx,%esi
  8026db:	72 67                	jb     802744 <__umoddi3+0x114>
  8026dd:	74 75                	je     802754 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8026df:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8026e3:	29 e8                	sub    %ebp,%eax
  8026e5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8026e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026eb:	d3 e8                	shr    %cl,%eax
  8026ed:	89 f2                	mov    %esi,%edx
  8026ef:	89 f9                	mov    %edi,%ecx
  8026f1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8026f3:	09 d0                	or     %edx,%eax
  8026f5:	89 f2                	mov    %esi,%edx
  8026f7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026fb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026fd:	83 c4 20             	add    $0x20,%esp
  802700:	5e                   	pop    %esi
  802701:	5f                   	pop    %edi
  802702:	5d                   	pop    %ebp
  802703:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802704:	85 c9                	test   %ecx,%ecx
  802706:	75 0b                	jne    802713 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802708:	b8 01 00 00 00       	mov    $0x1,%eax
  80270d:	31 d2                	xor    %edx,%edx
  80270f:	f7 f1                	div    %ecx
  802711:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802713:	89 f0                	mov    %esi,%eax
  802715:	31 d2                	xor    %edx,%edx
  802717:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802719:	89 f8                	mov    %edi,%eax
  80271b:	e9 3e ff ff ff       	jmp    80265e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802720:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802722:	83 c4 20             	add    $0x20,%esp
  802725:	5e                   	pop    %esi
  802726:	5f                   	pop    %edi
  802727:	5d                   	pop    %ebp
  802728:	c3                   	ret    
  802729:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80272c:	39 f5                	cmp    %esi,%ebp
  80272e:	72 04                	jb     802734 <__umoddi3+0x104>
  802730:	39 f9                	cmp    %edi,%ecx
  802732:	77 06                	ja     80273a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802734:	89 f2                	mov    %esi,%edx
  802736:	29 cf                	sub    %ecx,%edi
  802738:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80273a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80273c:	83 c4 20             	add    $0x20,%esp
  80273f:	5e                   	pop    %esi
  802740:	5f                   	pop    %edi
  802741:	5d                   	pop    %ebp
  802742:	c3                   	ret    
  802743:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802744:	89 d1                	mov    %edx,%ecx
  802746:	89 c5                	mov    %eax,%ebp
  802748:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80274c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802750:	eb 8d                	jmp    8026df <__umoddi3+0xaf>
  802752:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802754:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802758:	72 ea                	jb     802744 <__umoddi3+0x114>
  80275a:	89 f1                	mov    %esi,%ecx
  80275c:	eb 81                	jmp    8026df <__umoddi3+0xaf>
