
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 ef 02 00 00       	call   800320 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 c4 80             	add    $0xffffff80,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003c:	c7 05 04 30 80 00 c0 	movl   $0x8028c0,0x803004
  800043:	28 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 58 20 00 00       	call   8020a9 <pipe>
  800051:	89 c6                	mov    %eax,%esi
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", i);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 cc 28 80 	movl   $0x8028cc,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  800072:	e8 1d 03 00 00       	call   800394 <_panic>

	if ((pid = fork()) < 0)
  800077:	e8 50 12 00 00       	call   8012cc <fork>
  80007c:	89 c3                	mov    %eax,%ebx
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", i);
  800082:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800086:	c7 44 24 08 e5 28 80 	movl   $0x8028e5,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  80009d:	e8 f2 02 00 00       	call   800394 <_panic>

	if (pid == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 85 d9 00 00 00    	jne    800183 <umain+0x14f>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8000af:	8b 00                	mov    (%eax),%eax
  8000b1:	8b 40 48             	mov    0x48(%eax),%eax
  8000b4:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bf:	c7 04 24 ee 28 80 00 	movl   $0x8028ee,(%esp)
  8000c6:	e8 c1 03 00 00       	call   80048c <cprintf>
		close(p[1]);
  8000cb:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000ce:	89 04 24             	mov    %eax,(%esp)
  8000d1:	e8 be 16 00 00       	call   801794 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000db:	8b 00                	mov    (%eax),%eax
  8000dd:	8b 40 48             	mov    0x48(%eax),%eax
  8000e0:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000e3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000eb:	c7 04 24 0b 29 80 00 	movl   $0x80290b,(%esp)
  8000f2:	e8 95 03 00 00       	call   80048c <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f7:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000fe:	00 
  8000ff:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800102:	89 44 24 04          	mov    %eax,0x4(%esp)
  800106:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 79 18 00 00       	call   80198a <readn>
  800111:	89 c6                	mov    %eax,%esi
		if (i < 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	79 20                	jns    800137 <umain+0x103>
			panic("read: %e", i);
  800117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011b:	c7 44 24 08 28 29 80 	movl   $0x802928,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  800132:	e8 5d 02 00 00       	call   800394 <_panic>
		buf[i] = 0;
  800137:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  80013c:	a1 00 30 80 00       	mov    0x803000,%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800148:	89 04 24             	mov    %eax,(%esp)
  80014b:	e8 8e 09 00 00       	call   800ade <strcmp>
  800150:	85 c0                	test   %eax,%eax
  800152:	75 0e                	jne    800162 <umain+0x12e>
			cprintf("\npipe read closed properly\n");
  800154:	c7 04 24 31 29 80 00 	movl   $0x802931,(%esp)
  80015b:	e8 2c 03 00 00       	call   80048c <cprintf>
  800160:	eb 17                	jmp    800179 <umain+0x145>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800162:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800165:	89 44 24 08          	mov    %eax,0x8(%esp)
  800169:	89 74 24 04          	mov    %esi,0x4(%esp)
  80016d:	c7 04 24 4d 29 80 00 	movl   $0x80294d,(%esp)
  800174:	e8 13 03 00 00       	call   80048c <cprintf>
		exit();
  800179:	e8 fa 01 00 00       	call   800378 <exit>
  80017e:	e9 b0 00 00 00       	jmp    800233 <umain+0x1ff>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800183:	a1 04 40 80 00       	mov    0x804004,%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	8b 40 48             	mov    0x48(%eax),%eax
  80018d:	8b 55 8c             	mov    -0x74(%ebp),%edx
  800190:	89 54 24 08          	mov    %edx,0x8(%esp)
  800194:	89 44 24 04          	mov    %eax,0x4(%esp)
  800198:	c7 04 24 ee 28 80 00 	movl   $0x8028ee,(%esp)
  80019f:	e8 e8 02 00 00       	call   80048c <cprintf>
		close(p[0]);
  8001a4:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 e5 15 00 00       	call   801794 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001af:	a1 04 40 80 00       	mov    0x804004,%eax
  8001b4:	8b 00                	mov    (%eax),%eax
  8001b6:	8b 40 48             	mov    0x48(%eax),%eax
  8001b9:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c4:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  8001cb:	e8 bc 02 00 00       	call   80048c <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001d0:	a1 00 30 80 00       	mov    0x803000,%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 27 08 00 00       	call   800a04 <strlen>
  8001dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e1:	a1 00 30 80 00       	mov    0x803000,%eax
  8001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ea:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	e8 e0 17 00 00       	call   8019d5 <write>
  8001f5:	89 c6                	mov    %eax,%esi
  8001f7:	a1 00 30 80 00       	mov    0x803000,%eax
  8001fc:	89 04 24             	mov    %eax,(%esp)
  8001ff:	e8 00 08 00 00       	call   800a04 <strlen>
  800204:	39 c6                	cmp    %eax,%esi
  800206:	74 20                	je     800228 <umain+0x1f4>
			panic("write: %e", i);
  800208:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80020c:	c7 44 24 08 7d 29 80 	movl   $0x80297d,0x8(%esp)
  800213:	00 
  800214:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  800223:	e8 6c 01 00 00       	call   800394 <_panic>
		close(p[1]);
  800228:	8b 45 90             	mov    -0x70(%ebp),%eax
  80022b:	89 04 24             	mov    %eax,(%esp)
  80022e:	e8 61 15 00 00       	call   801794 <close>
	}
	wait(pid);
  800233:	89 1c 24             	mov    %ebx,(%esp)
  800236:	e8 11 20 00 00       	call   80224c <wait>

	binaryname = "pipewriteeof";
  80023b:	c7 05 04 30 80 00 87 	movl   $0x802987,0x803004
  800242:	29 80 00 
	if ((i = pipe(p)) < 0)
  800245:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 59 1e 00 00       	call   8020a9 <pipe>
  800250:	89 c6                	mov    %eax,%esi
  800252:	85 c0                	test   %eax,%eax
  800254:	79 20                	jns    800276 <umain+0x242>
		panic("pipe: %e", i);
  800256:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80025a:	c7 44 24 08 cc 28 80 	movl   $0x8028cc,0x8(%esp)
  800261:	00 
  800262:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800269:	00 
  80026a:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  800271:	e8 1e 01 00 00       	call   800394 <_panic>

	if ((pid = fork()) < 0)
  800276:	e8 51 10 00 00       	call   8012cc <fork>
  80027b:	89 c3                	mov    %eax,%ebx
  80027d:	85 c0                	test   %eax,%eax
  80027f:	79 20                	jns    8002a1 <umain+0x26d>
		panic("fork: %e", i);
  800281:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800285:	c7 44 24 08 e5 28 80 	movl   $0x8028e5,0x8(%esp)
  80028c:	00 
  80028d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800294:	00 
  800295:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  80029c:	e8 f3 00 00 00       	call   800394 <_panic>

	if (pid == 0) {
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	75 48                	jne    8002ed <umain+0x2b9>
		close(p[0]);
  8002a5:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	e8 e4 14 00 00       	call   801794 <close>
		while (1) {
			cprintf(".");
  8002b0:	c7 04 24 94 29 80 00 	movl   $0x802994,(%esp)
  8002b7:	e8 d0 01 00 00       	call   80048c <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c3:	00 
  8002c4:	c7 44 24 04 96 29 80 	movl   $0x802996,0x4(%esp)
  8002cb:	00 
  8002cc:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	e8 fe 16 00 00       	call   8019d5 <write>
  8002d7:	83 f8 01             	cmp    $0x1,%eax
  8002da:	74 d4                	je     8002b0 <umain+0x27c>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002dc:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  8002e3:	e8 a4 01 00 00       	call   80048c <cprintf>
		exit();
  8002e8:	e8 8b 00 00 00       	call   800378 <exit>
	}
	close(p[0]);
  8002ed:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	e8 9c 14 00 00       	call   801794 <close>
	close(p[1]);
  8002f8:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	e8 91 14 00 00       	call   801794 <close>
	wait(pid);
  800303:	89 1c 24             	mov    %ebx,(%esp)
  800306:	e8 41 1f 00 00       	call   80224c <wait>

	cprintf("pipe tests passed\n");
  80030b:	c7 04 24 b5 29 80 00 	movl   $0x8029b5,(%esp)
  800312:	e8 75 01 00 00       	call   80048c <cprintf>
}
  800317:	83 ec 80             	sub    $0xffffff80,%esp
  80031a:	5b                   	pop    %ebx
  80031b:	5e                   	pop    %esi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    
	...

00800320 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	56                   	push   %esi
  800324:	53                   	push   %ebx
  800325:	83 ec 20             	sub    $0x20,%esp
  800328:	8b 75 08             	mov    0x8(%ebp),%esi
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80032e:	e8 b8 0a 00 00       	call   800deb <sys_getenvid>
  800333:	25 ff 03 00 00       	and    $0x3ff,%eax
  800338:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80033f:	c1 e0 07             	shl    $0x7,%eax
  800342:	29 d0                	sub    %edx,%eax
  800344:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800349:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  80034c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034f:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800354:	85 f6                	test   %esi,%esi
  800356:	7e 07                	jle    80035f <libmain+0x3f>
		binaryname = argv[0];
  800358:	8b 03                	mov    (%ebx),%eax
  80035a:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80035f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800363:	89 34 24             	mov    %esi,(%esp)
  800366:	e8 c9 fc ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80036b:	e8 08 00 00 00       	call   800378 <exit>
}
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    
	...

00800378 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80037e:	e8 42 14 00 00       	call   8017c5 <close_all>
	sys_env_destroy(0);
  800383:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80038a:	e8 0a 0a 00 00       	call   800d99 <sys_env_destroy>
}
  80038f:	c9                   	leave  
  800390:	c3                   	ret    
  800391:	00 00                	add    %al,(%eax)
	...

00800394 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
  800399:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80039c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80039f:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8003a5:	e8 41 0a 00 00       	call   800deb <sys_getenvid>
  8003aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c0:	c7 04 24 18 2a 80 00 	movl   $0x802a18,(%esp)
  8003c7:	e8 c0 00 00 00       	call   80048c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d3:	89 04 24             	mov    %eax,(%esp)
  8003d6:	e8 50 00 00 00       	call   80042b <vcprintf>
	cprintf("\n");
  8003db:	c7 04 24 b0 2d 80 00 	movl   $0x802db0,(%esp)
  8003e2:	e8 a5 00 00 00       	call   80048c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003e7:	cc                   	int3   
  8003e8:	eb fd                	jmp    8003e7 <_panic+0x53>
	...

008003ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	53                   	push   %ebx
  8003f0:	83 ec 14             	sub    $0x14,%esp
  8003f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f6:	8b 03                	mov    (%ebx),%eax
  8003f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003ff:	40                   	inc    %eax
  800400:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800402:	3d ff 00 00 00       	cmp    $0xff,%eax
  800407:	75 19                	jne    800422 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800409:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800410:	00 
  800411:	8d 43 08             	lea    0x8(%ebx),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	e8 40 09 00 00       	call   800d5c <sys_cputs>
		b->idx = 0;
  80041c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800422:	ff 43 04             	incl   0x4(%ebx)
}
  800425:	83 c4 14             	add    $0x14,%esp
  800428:	5b                   	pop    %ebx
  800429:	5d                   	pop    %ebp
  80042a:	c3                   	ret    

0080042b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800434:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043b:	00 00 00 
	b.cnt = 0;
  80043e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800445:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800448:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044f:	8b 45 08             	mov    0x8(%ebp),%eax
  800452:	89 44 24 08          	mov    %eax,0x8(%esp)
  800456:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80045c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800460:	c7 04 24 ec 03 80 00 	movl   $0x8003ec,(%esp)
  800467:	e8 82 01 00 00       	call   8005ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80046c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800472:	89 44 24 04          	mov    %eax,0x4(%esp)
  800476:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 d8 08 00 00       	call   800d5c <sys_cputs>

	return b.cnt;
}
  800484:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048a:	c9                   	leave  
  80048b:	c3                   	ret    

0080048c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800492:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	8b 45 08             	mov    0x8(%ebp),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	e8 87 ff ff ff       	call   80042b <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    
	...

008004a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 3c             	sub    $0x3c,%esp
  8004b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b4:	89 d7                	mov    %edx,%edi
  8004b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	75 08                	jne    8004d4 <printnum+0x2c>
  8004cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004d2:	77 57                	ja     80052b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004d8:	4b                   	dec    %ebx
  8004d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004e8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f3:	00 
  8004f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800501:	e8 66 21 00 00       	call   80266c <__udivdi3>
  800506:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80050a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	89 54 24 04          	mov    %edx,0x4(%esp)
  800515:	89 fa                	mov    %edi,%edx
  800517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051a:	e8 89 ff ff ff       	call   8004a8 <printnum>
  80051f:	eb 0f                	jmp    800530 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800521:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800525:	89 34 24             	mov    %esi,(%esp)
  800528:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80052b:	4b                   	dec    %ebx
  80052c:	85 db                	test   %ebx,%ebx
  80052e:	7f f1                	jg     800521 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800530:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800534:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800538:	8b 45 10             	mov    0x10(%ebp),%eax
  80053b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800546:	00 
  800547:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054a:	89 04 24             	mov    %eax,(%esp)
  80054d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800550:	89 44 24 04          	mov    %eax,0x4(%esp)
  800554:	e8 33 22 00 00       	call   80278c <__umoddi3>
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055d:	0f be 80 3b 2a 80 00 	movsbl 0x802a3b(%eax),%eax
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80056a:	83 c4 3c             	add    $0x3c,%esp
  80056d:	5b                   	pop    %ebx
  80056e:	5e                   	pop    %esi
  80056f:	5f                   	pop    %edi
  800570:	5d                   	pop    %ebp
  800571:	c3                   	ret    

00800572 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800575:	83 fa 01             	cmp    $0x1,%edx
  800578:	7e 0e                	jle    800588 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80057a:	8b 10                	mov    (%eax),%edx
  80057c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80057f:	89 08                	mov    %ecx,(%eax)
  800581:	8b 02                	mov    (%edx),%eax
  800583:	8b 52 04             	mov    0x4(%edx),%edx
  800586:	eb 22                	jmp    8005aa <getuint+0x38>
	else if (lflag)
  800588:	85 d2                	test   %edx,%edx
  80058a:	74 10                	je     80059c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80058c:	8b 10                	mov    (%eax),%edx
  80058e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800591:	89 08                	mov    %ecx,(%eax)
  800593:	8b 02                	mov    (%edx),%eax
  800595:	ba 00 00 00 00       	mov    $0x0,%edx
  80059a:	eb 0e                	jmp    8005aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80059c:	8b 10                	mov    (%eax),%edx
  80059e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a1:	89 08                	mov    %ecx,(%eax)
  8005a3:	8b 02                	mov    (%edx),%eax
  8005a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005aa:	5d                   	pop    %ebp
  8005ab:	c3                   	ret    

008005ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005b2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ba:	73 08                	jae    8005c4 <sprintputch+0x18>
		*b->buf++ = ch;
  8005bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005bf:	88 0a                	mov    %cl,(%edx)
  8005c1:	42                   	inc    %edx
  8005c2:	89 10                	mov    %edx,(%eax)
}
  8005c4:	5d                   	pop    %ebp
  8005c5:	c3                   	ret    

008005c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005c6:	55                   	push   %ebp
  8005c7:	89 e5                	mov    %esp,%ebp
  8005c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	e8 02 00 00 00       	call   8005ee <vprintfmt>
	va_end(ap);
}
  8005ec:	c9                   	leave  
  8005ed:	c3                   	ret    

008005ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ee:	55                   	push   %ebp
  8005ef:	89 e5                	mov    %esp,%ebp
  8005f1:	57                   	push   %edi
  8005f2:	56                   	push   %esi
  8005f3:	53                   	push   %ebx
  8005f4:	83 ec 4c             	sub    $0x4c,%esp
  8005f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fa:	8b 75 10             	mov    0x10(%ebp),%esi
  8005fd:	eb 12                	jmp    800611 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005ff:	85 c0                	test   %eax,%eax
  800601:	0f 84 6b 03 00 00    	je     800972 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800607:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060b:	89 04 24             	mov    %eax,(%esp)
  80060e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800611:	0f b6 06             	movzbl (%esi),%eax
  800614:	46                   	inc    %esi
  800615:	83 f8 25             	cmp    $0x25,%eax
  800618:	75 e5                	jne    8005ff <vprintfmt+0x11>
  80061a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80061e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800625:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80062a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800631:	b9 00 00 00 00       	mov    $0x0,%ecx
  800636:	eb 26                	jmp    80065e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80063b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80063f:	eb 1d                	jmp    80065e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800644:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800648:	eb 14                	jmp    80065e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80064d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800654:	eb 08                	jmp    80065e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800656:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800659:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	0f b6 06             	movzbl (%esi),%eax
  800661:	8d 56 01             	lea    0x1(%esi),%edx
  800664:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800667:	8a 16                	mov    (%esi),%dl
  800669:	83 ea 23             	sub    $0x23,%edx
  80066c:	80 fa 55             	cmp    $0x55,%dl
  80066f:	0f 87 e1 02 00 00    	ja     800956 <vprintfmt+0x368>
  800675:	0f b6 d2             	movzbl %dl,%edx
  800678:	ff 24 95 80 2b 80 00 	jmp    *0x802b80(,%edx,4)
  80067f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800682:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800687:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80068a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80068e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800691:	8d 50 d0             	lea    -0x30(%eax),%edx
  800694:	83 fa 09             	cmp    $0x9,%edx
  800697:	77 2a                	ja     8006c3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800699:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80069a:	eb eb                	jmp    800687 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006aa:	eb 17                	jmp    8006c3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b0:	78 98                	js     80064a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b5:	eb a7                	jmp    80065e <vprintfmt+0x70>
  8006b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006ba:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006c1:	eb 9b                	jmp    80065e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c7:	79 95                	jns    80065e <vprintfmt+0x70>
  8006c9:	eb 8b                	jmp    800656 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006cb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006cf:	eb 8d                	jmp    80065e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 04             	lea    0x4(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006de:	8b 00                	mov    (%eax),%eax
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006e9:	e9 23 ff ff ff       	jmp    800611 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 50 04             	lea    0x4(%eax),%edx
  8006f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	79 02                	jns    8006ff <vprintfmt+0x111>
  8006fd:	f7 d8                	neg    %eax
  8006ff:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800701:	83 f8 0f             	cmp    $0xf,%eax
  800704:	7f 0b                	jg     800711 <vprintfmt+0x123>
  800706:	8b 04 85 e0 2c 80 00 	mov    0x802ce0(,%eax,4),%eax
  80070d:	85 c0                	test   %eax,%eax
  80070f:	75 23                	jne    800734 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800711:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800715:	c7 44 24 08 53 2a 80 	movl   $0x802a53,0x8(%esp)
  80071c:	00 
  80071d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800721:	8b 45 08             	mov    0x8(%ebp),%eax
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	e8 9a fe ff ff       	call   8005c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80072f:	e9 dd fe ff ff       	jmp    800611 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800734:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800738:	c7 44 24 08 59 2e 80 	movl   $0x802e59,0x8(%esp)
  80073f:	00 
  800740:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800744:	8b 55 08             	mov    0x8(%ebp),%edx
  800747:	89 14 24             	mov    %edx,(%esp)
  80074a:	e8 77 fe ff ff       	call   8005c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800752:	e9 ba fe ff ff       	jmp    800611 <vprintfmt+0x23>
  800757:	89 f9                	mov    %edi,%ecx
  800759:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	8b 30                	mov    (%eax),%esi
  80076a:	85 f6                	test   %esi,%esi
  80076c:	75 05                	jne    800773 <vprintfmt+0x185>
				p = "(null)";
  80076e:	be 4c 2a 80 00       	mov    $0x802a4c,%esi
			if (width > 0 && padc != '-')
  800773:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800777:	0f 8e 84 00 00 00    	jle    800801 <vprintfmt+0x213>
  80077d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800781:	74 7e                	je     800801 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800783:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800787:	89 34 24             	mov    %esi,(%esp)
  80078a:	e8 8b 02 00 00       	call   800a1a <strnlen>
  80078f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800792:	29 c2                	sub    %eax,%edx
  800794:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800797:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80079b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80079e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007a1:	89 de                	mov    %ebx,%esi
  8007a3:	89 d3                	mov    %edx,%ebx
  8007a5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a7:	eb 0b                	jmp    8007b4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ad:	89 3c 24             	mov    %edi,(%esp)
  8007b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b3:	4b                   	dec    %ebx
  8007b4:	85 db                	test   %ebx,%ebx
  8007b6:	7f f1                	jg     8007a9 <vprintfmt+0x1bb>
  8007b8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007bb:	89 f3                	mov    %esi,%ebx
  8007bd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	79 05                	jns    8007cc <vprintfmt+0x1de>
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007cf:	29 c2                	sub    %eax,%edx
  8007d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007d4:	eb 2b                	jmp    800801 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007da:	74 18                	je     8007f4 <vprintfmt+0x206>
  8007dc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007df:	83 fa 5e             	cmp    $0x5e,%edx
  8007e2:	76 10                	jbe    8007f4 <vprintfmt+0x206>
					putch('?', putdat);
  8007e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007ef:	ff 55 08             	call   *0x8(%ebp)
  8007f2:	eb 0a                	jmp    8007fe <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f8:	89 04 24             	mov    %eax,(%esp)
  8007fb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fe:	ff 4d e4             	decl   -0x1c(%ebp)
  800801:	0f be 06             	movsbl (%esi),%eax
  800804:	46                   	inc    %esi
  800805:	85 c0                	test   %eax,%eax
  800807:	74 21                	je     80082a <vprintfmt+0x23c>
  800809:	85 ff                	test   %edi,%edi
  80080b:	78 c9                	js     8007d6 <vprintfmt+0x1e8>
  80080d:	4f                   	dec    %edi
  80080e:	79 c6                	jns    8007d6 <vprintfmt+0x1e8>
  800810:	8b 7d 08             	mov    0x8(%ebp),%edi
  800813:	89 de                	mov    %ebx,%esi
  800815:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800818:	eb 18                	jmp    800832 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80081a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800825:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800827:	4b                   	dec    %ebx
  800828:	eb 08                	jmp    800832 <vprintfmt+0x244>
  80082a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082d:	89 de                	mov    %ebx,%esi
  80082f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800832:	85 db                	test   %ebx,%ebx
  800834:	7f e4                	jg     80081a <vprintfmt+0x22c>
  800836:	89 7d 08             	mov    %edi,0x8(%ebp)
  800839:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80083e:	e9 ce fd ff ff       	jmp    800611 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800843:	83 f9 01             	cmp    $0x1,%ecx
  800846:	7e 10                	jle    800858 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	8d 50 08             	lea    0x8(%eax),%edx
  80084e:	89 55 14             	mov    %edx,0x14(%ebp)
  800851:	8b 30                	mov    (%eax),%esi
  800853:	8b 78 04             	mov    0x4(%eax),%edi
  800856:	eb 26                	jmp    80087e <vprintfmt+0x290>
	else if (lflag)
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	74 12                	je     80086e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	8d 50 04             	lea    0x4(%eax),%edx
  800862:	89 55 14             	mov    %edx,0x14(%ebp)
  800865:	8b 30                	mov    (%eax),%esi
  800867:	89 f7                	mov    %esi,%edi
  800869:	c1 ff 1f             	sar    $0x1f,%edi
  80086c:	eb 10                	jmp    80087e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8d 50 04             	lea    0x4(%eax),%edx
  800874:	89 55 14             	mov    %edx,0x14(%ebp)
  800877:	8b 30                	mov    (%eax),%esi
  800879:	89 f7                	mov    %esi,%edi
  80087b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80087e:	85 ff                	test   %edi,%edi
  800880:	78 0a                	js     80088c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800882:	b8 0a 00 00 00       	mov    $0xa,%eax
  800887:	e9 8c 00 00 00       	jmp    800918 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80088c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800890:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800897:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80089a:	f7 de                	neg    %esi
  80089c:	83 d7 00             	adc    $0x0,%edi
  80089f:	f7 df                	neg    %edi
			}
			base = 10;
  8008a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008a6:	eb 70                	jmp    800918 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008a8:	89 ca                	mov    %ecx,%edx
  8008aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ad:	e8 c0 fc ff ff       	call   800572 <getuint>
  8008b2:	89 c6                	mov    %eax,%esi
  8008b4:	89 d7                	mov    %edx,%edi
			base = 10;
  8008b6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008bb:	eb 5b                	jmp    800918 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8008bd:	89 ca                	mov    %ecx,%edx
  8008bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c2:	e8 ab fc ff ff       	call   800572 <getuint>
  8008c7:	89 c6                	mov    %eax,%esi
  8008c9:	89 d7                	mov    %edx,%edi
			base = 8;
  8008cb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008d0:	eb 46                	jmp    800918 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008dd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008eb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8d 50 04             	lea    0x4(%eax),%edx
  8008f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008f7:	8b 30                	mov    (%eax),%esi
  8008f9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008fe:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800903:	eb 13                	jmp    800918 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800905:	89 ca                	mov    %ecx,%edx
  800907:	8d 45 14             	lea    0x14(%ebp),%eax
  80090a:	e8 63 fc ff ff       	call   800572 <getuint>
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d7                	mov    %edx,%edi
			base = 16;
  800913:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800918:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80091c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800920:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800923:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800927:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092b:	89 34 24             	mov    %esi,(%esp)
  80092e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800932:	89 da                	mov    %ebx,%edx
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	e8 6c fb ff ff       	call   8004a8 <printnum>
			break;
  80093c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80093f:	e9 cd fc ff ff       	jmp    800611 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800944:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800948:	89 04 24             	mov    %eax,(%esp)
  80094b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800951:	e9 bb fc ff ff       	jmp    800611 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800956:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800961:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800964:	eb 01                	jmp    800967 <vprintfmt+0x379>
  800966:	4e                   	dec    %esi
  800967:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80096b:	75 f9                	jne    800966 <vprintfmt+0x378>
  80096d:	e9 9f fc ff ff       	jmp    800611 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800972:	83 c4 4c             	add    $0x4c,%esp
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	83 ec 28             	sub    $0x28,%esp
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800986:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800989:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80098d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800990:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800997:	85 c0                	test   %eax,%eax
  800999:	74 30                	je     8009cb <vsnprintf+0x51>
  80099b:	85 d2                	test   %edx,%edx
  80099d:	7e 33                	jle    8009d2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099f:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b4:	c7 04 24 ac 05 80 00 	movl   $0x8005ac,(%esp)
  8009bb:	e8 2e fc ff ff       	call   8005ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c9:	eb 0c                	jmp    8009d7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d0:	eb 05                	jmp    8009d7 <vsnprintf+0x5d>
  8009d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	89 04 24             	mov    %eax,(%esp)
  8009fa:	e8 7b ff ff ff       	call   80097a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    
  800a01:	00 00                	add    %al,(%eax)
	...

00800a04 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0f:	eb 01                	jmp    800a12 <strlen+0xe>
		n++;
  800a11:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a12:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a16:	75 f9                	jne    800a11 <strlen+0xd>
		n++;
	return n;
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	eb 01                	jmp    800a2b <strnlen+0x11>
		n++;
  800a2a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2b:	39 d0                	cmp    %edx,%eax
  800a2d:	74 06                	je     800a35 <strnlen+0x1b>
  800a2f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a33:	75 f5                	jne    800a2a <strnlen+0x10>
		n++;
	return n;
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a49:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a4c:	42                   	inc    %edx
  800a4d:	84 c9                	test   %cl,%cl
  800a4f:	75 f5                	jne    800a46 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a51:	5b                   	pop    %ebx
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	53                   	push   %ebx
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5e:	89 1c 24             	mov    %ebx,(%esp)
  800a61:	e8 9e ff ff ff       	call   800a04 <strlen>
	strcpy(dst + len, src);
  800a66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a69:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a6d:	01 d8                	add    %ebx,%eax
  800a6f:	89 04 24             	mov    %eax,(%esp)
  800a72:	e8 c0 ff ff ff       	call   800a37 <strcpy>
	return dst;
}
  800a77:	89 d8                	mov    %ebx,%eax
  800a79:	83 c4 08             	add    $0x8,%esp
  800a7c:	5b                   	pop    %ebx
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a92:	eb 0c                	jmp    800aa0 <strncpy+0x21>
		*dst++ = *src;
  800a94:	8a 1a                	mov    (%edx),%bl
  800a96:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a99:	80 3a 01             	cmpb   $0x1,(%edx)
  800a9c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a9f:	41                   	inc    %ecx
  800aa0:	39 f1                	cmp    %esi,%ecx
  800aa2:	75 f0                	jne    800a94 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
  800aad:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab6:	85 d2                	test   %edx,%edx
  800ab8:	75 0a                	jne    800ac4 <strlcpy+0x1c>
  800aba:	89 f0                	mov    %esi,%eax
  800abc:	eb 1a                	jmp    800ad8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800abe:	88 18                	mov    %bl,(%eax)
  800ac0:	40                   	inc    %eax
  800ac1:	41                   	inc    %ecx
  800ac2:	eb 02                	jmp    800ac6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ac6:	4a                   	dec    %edx
  800ac7:	74 0a                	je     800ad3 <strlcpy+0x2b>
  800ac9:	8a 19                	mov    (%ecx),%bl
  800acb:	84 db                	test   %bl,%bl
  800acd:	75 ef                	jne    800abe <strlcpy+0x16>
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	eb 02                	jmp    800ad5 <strlcpy+0x2d>
  800ad3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ad5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ad8:	29 f0                	sub    %esi,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae7:	eb 02                	jmp    800aeb <strcmp+0xd>
		p++, q++;
  800ae9:	41                   	inc    %ecx
  800aea:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aeb:	8a 01                	mov    (%ecx),%al
  800aed:	84 c0                	test   %al,%al
  800aef:	74 04                	je     800af5 <strcmp+0x17>
  800af1:	3a 02                	cmp    (%edx),%al
  800af3:	74 f4                	je     800ae9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af5:	0f b6 c0             	movzbl %al,%eax
  800af8:	0f b6 12             	movzbl (%edx),%edx
  800afb:	29 d0                	sub    %edx,%eax
}
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	53                   	push   %ebx
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b09:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b0c:	eb 03                	jmp    800b11 <strncmp+0x12>
		n--, p++, q++;
  800b0e:	4a                   	dec    %edx
  800b0f:	40                   	inc    %eax
  800b10:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b11:	85 d2                	test   %edx,%edx
  800b13:	74 14                	je     800b29 <strncmp+0x2a>
  800b15:	8a 18                	mov    (%eax),%bl
  800b17:	84 db                	test   %bl,%bl
  800b19:	74 04                	je     800b1f <strncmp+0x20>
  800b1b:	3a 19                	cmp    (%ecx),%bl
  800b1d:	74 ef                	je     800b0e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1f:	0f b6 00             	movzbl (%eax),%eax
  800b22:	0f b6 11             	movzbl (%ecx),%edx
  800b25:	29 d0                	sub    %edx,%eax
  800b27:	eb 05                	jmp    800b2e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b3a:	eb 05                	jmp    800b41 <strchr+0x10>
		if (*s == c)
  800b3c:	38 ca                	cmp    %cl,%dl
  800b3e:	74 0c                	je     800b4c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b40:	40                   	inc    %eax
  800b41:	8a 10                	mov    (%eax),%dl
  800b43:	84 d2                	test   %dl,%dl
  800b45:	75 f5                	jne    800b3c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b57:	eb 05                	jmp    800b5e <strfind+0x10>
		if (*s == c)
  800b59:	38 ca                	cmp    %cl,%dl
  800b5b:	74 07                	je     800b64 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b5d:	40                   	inc    %eax
  800b5e:	8a 10                	mov    (%eax),%dl
  800b60:	84 d2                	test   %dl,%dl
  800b62:	75 f5                	jne    800b59 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b72:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b75:	85 c9                	test   %ecx,%ecx
  800b77:	74 30                	je     800ba9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7f:	75 25                	jne    800ba6 <memset+0x40>
  800b81:	f6 c1 03             	test   $0x3,%cl
  800b84:	75 20                	jne    800ba6 <memset+0x40>
		c &= 0xFF;
  800b86:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b89:	89 d3                	mov    %edx,%ebx
  800b8b:	c1 e3 08             	shl    $0x8,%ebx
  800b8e:	89 d6                	mov    %edx,%esi
  800b90:	c1 e6 18             	shl    $0x18,%esi
  800b93:	89 d0                	mov    %edx,%eax
  800b95:	c1 e0 10             	shl    $0x10,%eax
  800b98:	09 f0                	or     %esi,%eax
  800b9a:	09 d0                	or     %edx,%eax
  800b9c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b9e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba1:	fc                   	cld    
  800ba2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba4:	eb 03                	jmp    800ba9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba6:	fc                   	cld    
  800ba7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ba9:	89 f8                	mov    %edi,%eax
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bbe:	39 c6                	cmp    %eax,%esi
  800bc0:	73 34                	jae    800bf6 <memmove+0x46>
  800bc2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc5:	39 d0                	cmp    %edx,%eax
  800bc7:	73 2d                	jae    800bf6 <memmove+0x46>
		s += n;
		d += n;
  800bc9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcc:	f6 c2 03             	test   $0x3,%dl
  800bcf:	75 1b                	jne    800bec <memmove+0x3c>
  800bd1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd7:	75 13                	jne    800bec <memmove+0x3c>
  800bd9:	f6 c1 03             	test   $0x3,%cl
  800bdc:	75 0e                	jne    800bec <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bde:	83 ef 04             	sub    $0x4,%edi
  800be1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800be7:	fd                   	std    
  800be8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bea:	eb 07                	jmp    800bf3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bec:	4f                   	dec    %edi
  800bed:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf0:	fd                   	std    
  800bf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf3:	fc                   	cld    
  800bf4:	eb 20                	jmp    800c16 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bfc:	75 13                	jne    800c11 <memmove+0x61>
  800bfe:	a8 03                	test   $0x3,%al
  800c00:	75 0f                	jne    800c11 <memmove+0x61>
  800c02:	f6 c1 03             	test   $0x3,%cl
  800c05:	75 0a                	jne    800c11 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c07:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c0a:	89 c7                	mov    %eax,%edi
  800c0c:	fc                   	cld    
  800c0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0f:	eb 05                	jmp    800c16 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c11:	89 c7                	mov    %eax,%edi
  800c13:	fc                   	cld    
  800c14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c20:	8b 45 10             	mov    0x10(%ebp),%eax
  800c23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	89 04 24             	mov    %eax,(%esp)
  800c34:	e8 77 ff ff ff       	call   800bb0 <memmove>
}
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    

00800c3b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4f:	eb 16                	jmp    800c67 <memcmp+0x2c>
		if (*s1 != *s2)
  800c51:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c54:	42                   	inc    %edx
  800c55:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c59:	38 c8                	cmp    %cl,%al
  800c5b:	74 0a                	je     800c67 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c5d:	0f b6 c0             	movzbl %al,%eax
  800c60:	0f b6 c9             	movzbl %cl,%ecx
  800c63:	29 c8                	sub    %ecx,%eax
  800c65:	eb 09                	jmp    800c70 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c67:	39 da                	cmp    %ebx,%edx
  800c69:	75 e6                	jne    800c51 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c7e:	89 c2                	mov    %eax,%edx
  800c80:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c83:	eb 05                	jmp    800c8a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c85:	38 08                	cmp    %cl,(%eax)
  800c87:	74 05                	je     800c8e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c89:	40                   	inc    %eax
  800c8a:	39 d0                	cmp    %edx,%eax
  800c8c:	72 f7                	jb     800c85 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9c:	eb 01                	jmp    800c9f <strtol+0xf>
		s++;
  800c9e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9f:	8a 02                	mov    (%edx),%al
  800ca1:	3c 20                	cmp    $0x20,%al
  800ca3:	74 f9                	je     800c9e <strtol+0xe>
  800ca5:	3c 09                	cmp    $0x9,%al
  800ca7:	74 f5                	je     800c9e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca9:	3c 2b                	cmp    $0x2b,%al
  800cab:	75 08                	jne    800cb5 <strtol+0x25>
		s++;
  800cad:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cae:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb3:	eb 13                	jmp    800cc8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb5:	3c 2d                	cmp    $0x2d,%al
  800cb7:	75 0a                	jne    800cc3 <strtol+0x33>
		s++, neg = 1;
  800cb9:	8d 52 01             	lea    0x1(%edx),%edx
  800cbc:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc1:	eb 05                	jmp    800cc8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc8:	85 db                	test   %ebx,%ebx
  800cca:	74 05                	je     800cd1 <strtol+0x41>
  800ccc:	83 fb 10             	cmp    $0x10,%ebx
  800ccf:	75 28                	jne    800cf9 <strtol+0x69>
  800cd1:	8a 02                	mov    (%edx),%al
  800cd3:	3c 30                	cmp    $0x30,%al
  800cd5:	75 10                	jne    800ce7 <strtol+0x57>
  800cd7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cdb:	75 0a                	jne    800ce7 <strtol+0x57>
		s += 2, base = 16;
  800cdd:	83 c2 02             	add    $0x2,%edx
  800ce0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce5:	eb 12                	jmp    800cf9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ce7:	85 db                	test   %ebx,%ebx
  800ce9:	75 0e                	jne    800cf9 <strtol+0x69>
  800ceb:	3c 30                	cmp    $0x30,%al
  800ced:	75 05                	jne    800cf4 <strtol+0x64>
		s++, base = 8;
  800cef:	42                   	inc    %edx
  800cf0:	b3 08                	mov    $0x8,%bl
  800cf2:	eb 05                	jmp    800cf9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cf4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cf9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d00:	8a 0a                	mov    (%edx),%cl
  800d02:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d05:	80 fb 09             	cmp    $0x9,%bl
  800d08:	77 08                	ja     800d12 <strtol+0x82>
			dig = *s - '0';
  800d0a:	0f be c9             	movsbl %cl,%ecx
  800d0d:	83 e9 30             	sub    $0x30,%ecx
  800d10:	eb 1e                	jmp    800d30 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d12:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d15:	80 fb 19             	cmp    $0x19,%bl
  800d18:	77 08                	ja     800d22 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d1a:	0f be c9             	movsbl %cl,%ecx
  800d1d:	83 e9 57             	sub    $0x57,%ecx
  800d20:	eb 0e                	jmp    800d30 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d22:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d25:	80 fb 19             	cmp    $0x19,%bl
  800d28:	77 12                	ja     800d3c <strtol+0xac>
			dig = *s - 'A' + 10;
  800d2a:	0f be c9             	movsbl %cl,%ecx
  800d2d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d30:	39 f1                	cmp    %esi,%ecx
  800d32:	7d 0c                	jge    800d40 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d34:	42                   	inc    %edx
  800d35:	0f af c6             	imul   %esi,%eax
  800d38:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d3a:	eb c4                	jmp    800d00 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d3c:	89 c1                	mov    %eax,%ecx
  800d3e:	eb 02                	jmp    800d42 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d40:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d46:	74 05                	je     800d4d <strtol+0xbd>
		*endptr = (char *) s;
  800d48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d4b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d4d:	85 ff                	test   %edi,%edi
  800d4f:	74 04                	je     800d55 <strtol+0xc5>
  800d51:	89 c8                	mov    %ecx,%eax
  800d53:	f7 d8                	neg    %eax
}
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    
	...

00800d5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	57                   	push   %edi
  800d60:	56                   	push   %esi
  800d61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	b8 00 00 00 00       	mov    $0x0,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	89 c3                	mov    %eax,%ebx
  800d6f:	89 c7                	mov    %eax,%edi
  800d71:	89 c6                	mov    %eax,%esi
  800d73:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <sys_cgetc>:

int
sys_cgetc(void)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d80:	ba 00 00 00 00       	mov    $0x0,%edx
  800d85:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8a:	89 d1                	mov    %edx,%ecx
  800d8c:	89 d3                	mov    %edx,%ebx
  800d8e:	89 d7                	mov    %edx,%edi
  800d90:	89 d6                	mov    %edx,%esi
  800d92:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
  800d9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da7:	b8 03 00 00 00       	mov    $0x3,%eax
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	89 cb                	mov    %ecx,%ebx
  800db1:	89 cf                	mov    %ecx,%edi
  800db3:	89 ce                	mov    %ecx,%esi
  800db5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800db7:	85 c0                	test   %eax,%eax
  800db9:	7e 28                	jle    800de3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dc6:	00 
  800dc7:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800dce:	00 
  800dcf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd6:	00 
  800dd7:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800dde:	e8 b1 f5 ff ff       	call   800394 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800de3:	83 c4 2c             	add    $0x2c,%esp
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	ba 00 00 00 00       	mov    $0x0,%edx
  800df6:	b8 02 00 00 00       	mov    $0x2,%eax
  800dfb:	89 d1                	mov    %edx,%ecx
  800dfd:	89 d3                	mov    %edx,%ebx
  800dff:	89 d7                	mov    %edx,%edi
  800e01:	89 d6                	mov    %edx,%esi
  800e03:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_yield>:

void
sys_yield(void)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1a:	89 d1                	mov    %edx,%ecx
  800e1c:	89 d3                	mov    %edx,%ebx
  800e1e:	89 d7                	mov    %edx,%edi
  800e20:	89 d6                	mov    %edx,%esi
  800e22:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	be 00 00 00 00       	mov    $0x0,%esi
  800e37:	b8 04 00 00 00       	mov    $0x4,%eax
  800e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	89 f7                	mov    %esi,%edi
  800e47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 28                	jle    800e75 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e51:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e58:	00 
  800e59:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800e60:	00 
  800e61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e68:	00 
  800e69:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800e70:	e8 1f f5 ff ff       	call   800394 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e75:	83 c4 2c             	add    $0x2c,%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
  800e83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e86:	b8 05 00 00 00       	mov    $0x5,%eax
  800e8b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	7e 28                	jle    800ec8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eab:	00 
  800eac:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebb:	00 
  800ebc:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800ec3:	e8 cc f4 ff ff       	call   800394 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ec8:	83 c4 2c             	add    $0x2c,%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	b8 06 00 00 00       	mov    $0x6,%eax
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 de                	mov    %ebx,%esi
  800eed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7e 28                	jle    800f1b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800efe:	00 
  800eff:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800f06:	00 
  800f07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0e:	00 
  800f0f:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800f16:	e8 79 f4 ff ff       	call   800394 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f1b:	83 c4 2c             	add    $0x2c,%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f31:	b8 08 00 00 00       	mov    $0x8,%eax
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	89 df                	mov    %ebx,%edi
  800f3e:	89 de                	mov    %ebx,%esi
  800f40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f42:	85 c0                	test   %eax,%eax
  800f44:	7e 28                	jle    800f6e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f51:	00 
  800f52:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800f69:	e8 26 f4 ff ff       	call   800394 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f6e:	83 c4 2c             	add    $0x2c,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f84:	b8 09 00 00 00       	mov    $0x9,%eax
  800f89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8f:	89 df                	mov    %ebx,%edi
  800f91:	89 de                	mov    %ebx,%esi
  800f93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f95:	85 c0                	test   %eax,%eax
  800f97:	7e 28                	jle    800fc1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800fac:	00 
  800fad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb4:	00 
  800fb5:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  800fbc:	e8 d3 f3 ff ff       	call   800394 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc1:	83 c4 2c             	add    $0x2c,%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    

00800fc9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe2:	89 df                	mov    %ebx,%edi
  800fe4:	89 de                	mov    %ebx,%esi
  800fe6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	7e 28                	jle    801014 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fec:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ff7:	00 
  800ff8:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800fff:	00 
  801000:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801007:	00 
  801008:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  80100f:	e8 80 f3 ff ff       	call   800394 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801014:	83 c4 2c             	add    $0x2c,%esp
  801017:	5b                   	pop    %ebx
  801018:	5e                   	pop    %esi
  801019:	5f                   	pop    %edi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801022:	be 00 00 00 00       	mov    $0x0,%esi
  801027:	b8 0c 00 00 00       	mov    $0xc,%eax
  80102c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80102f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801032:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801035:	8b 55 08             	mov    0x8(%ebp),%edx
  801038:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	57                   	push   %edi
  801043:	56                   	push   %esi
  801044:	53                   	push   %ebx
  801045:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80104d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801052:	8b 55 08             	mov    0x8(%ebp),%edx
  801055:	89 cb                	mov    %ecx,%ebx
  801057:	89 cf                	mov    %ecx,%edi
  801059:	89 ce                	mov    %ecx,%esi
  80105b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80105d:	85 c0                	test   %eax,%eax
  80105f:	7e 28                	jle    801089 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801061:	89 44 24 10          	mov    %eax,0x10(%esp)
  801065:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80106c:	00 
  80106d:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  801074:	00 
  801075:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107c:	00 
  80107d:	c7 04 24 5c 2d 80 00 	movl   $0x802d5c,(%esp)
  801084:	e8 0b f3 ff ff       	call   800394 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801089:	83 c4 2c             	add    $0x2c,%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    
  801091:	00 00                	add    %al,(%eax)
	...

00801094 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
  80109a:	83 ec 3c             	sub    $0x3c,%esp
  80109d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  8010a0:	89 d6                	mov    %edx,%esi
  8010a2:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  8010a5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  8010af:	e8 37 fd ff ff       	call   800deb <sys_getenvid>
  8010b4:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  8010b6:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  8010bd:	74 31                	je     8010f0 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  8010bf:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  8010c6:	00 
  8010c7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d6:	89 3c 24             	mov    %edi,(%esp)
  8010d9:	e8 9f fd ff ff       	call   800e7d <sys_page_map>
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	0f 8e ae 00 00 00    	jle    801194 <duppage+0x100>
  8010e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010eb:	e9 a4 00 00 00       	jmp    801194 <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  8010f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f3:	25 02 08 00 00       	and    $0x802,%eax
  8010f8:	83 f8 01             	cmp    $0x1,%eax
  8010fb:	19 db                	sbb    %ebx,%ebx
  8010fd:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  801103:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  801109:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80110d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801111:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801114:	89 44 24 08          	mov    %eax,0x8(%esp)
  801118:	89 74 24 04          	mov    %esi,0x4(%esp)
  80111c:	89 3c 24             	mov    %edi,(%esp)
  80111f:	e8 59 fd ff ff       	call   800e7d <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  801124:	85 c0                	test   %eax,%eax
  801126:	79 1c                	jns    801144 <duppage+0xb0>
  801128:	c7 44 24 08 6a 2d 80 	movl   $0x802d6a,0x8(%esp)
  80112f:	00 
  801130:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801137:	00 
  801138:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  80113f:	e8 50 f2 ff ff       	call   800394 <_panic>
	if ((perm|~pte)&PTE_COW){
  801144:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801147:	f7 d0                	not    %eax
  801149:	09 d8                	or     %ebx,%eax
  80114b:	f6 c4 08             	test   $0x8,%ah
  80114e:	74 38                	je     801188 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  801150:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801154:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801158:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80115c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801160:	89 3c 24             	mov    %edi,(%esp)
  801163:	e8 15 fd ff ff       	call   800e7d <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  801168:	85 c0                	test   %eax,%eax
  80116a:	79 23                	jns    80118f <duppage+0xfb>
  80116c:	c7 44 24 08 6a 2d 80 	movl   $0x802d6a,0x8(%esp)
  801173:	00 
  801174:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801183:	e8 0c f2 ff ff       	call   800394 <_panic>
	}
	return 0;
  801188:	b8 00 00 00 00       	mov    $0x0,%eax
  80118d:	eb 05                	jmp    801194 <duppage+0x100>
  80118f:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  801194:	83 c4 3c             	add    $0x3c,%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 20             	sub    $0x20,%esp
  8011a4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011a7:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  8011a9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011ad:	75 1c                	jne    8011cb <pgfault+0x2f>
		panic("pgfault: error!\n");
  8011af:	c7 44 24 08 86 2d 80 	movl   $0x802d86,0x8(%esp)
  8011b6:	00 
  8011b7:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8011be:	00 
  8011bf:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  8011c6:	e8 c9 f1 ff ff       	call   800394 <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  8011cb:	89 f0                	mov    %esi,%eax
  8011cd:	c1 e8 0c             	shr    $0xc,%eax
  8011d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d7:	f6 c4 08             	test   $0x8,%ah
  8011da:	75 1c                	jne    8011f8 <pgfault+0x5c>
		panic("pgfault: error!\n");
  8011dc:	c7 44 24 08 86 2d 80 	movl   $0x802d86,0x8(%esp)
  8011e3:	00 
  8011e4:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8011eb:	00 
  8011ec:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  8011f3:	e8 9c f1 ff ff       	call   800394 <_panic>
	envid_t envid = sys_getenvid();
  8011f8:	e8 ee fb ff ff       	call   800deb <sys_getenvid>
  8011fd:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  8011ff:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801206:	00 
  801207:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80120e:	00 
  80120f:	89 04 24             	mov    %eax,(%esp)
  801212:	e8 12 fc ff ff       	call   800e29 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  801217:	85 c0                	test   %eax,%eax
  801219:	79 1c                	jns    801237 <pgfault+0x9b>
  80121b:	c7 44 24 08 86 2d 80 	movl   $0x802d86,0x8(%esp)
  801222:	00 
  801223:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80122a:	00 
  80122b:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801232:	e8 5d f1 ff ff       	call   800394 <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  801237:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  80123d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801244:	00 
  801245:	89 74 24 04          	mov    %esi,0x4(%esp)
  801249:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801250:	e8 c5 f9 ff ff       	call   800c1a <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  801255:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80125c:	00 
  80125d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801261:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801265:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80126c:	00 
  80126d:	89 1c 24             	mov    %ebx,(%esp)
  801270:	e8 08 fc ff ff       	call   800e7d <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  801275:	85 c0                	test   %eax,%eax
  801277:	79 1c                	jns    801295 <pgfault+0xf9>
  801279:	c7 44 24 08 86 2d 80 	movl   $0x802d86,0x8(%esp)
  801280:	00 
  801281:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801288:	00 
  801289:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801290:	e8 ff f0 ff ff       	call   800394 <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  801295:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80129c:	00 
  80129d:	89 1c 24             	mov    %ebx,(%esp)
  8012a0:	e8 2b fc ff ff       	call   800ed0 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	79 1c                	jns    8012c5 <pgfault+0x129>
  8012a9:	c7 44 24 08 86 2d 80 	movl   $0x802d86,0x8(%esp)
  8012b0:	00 
  8012b1:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8012b8:	00 
  8012b9:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  8012c0:	e8 cf f0 ff ff       	call   800394 <_panic>
	return;
	panic("pgfault not implemented");
}
  8012c5:	83 c4 20             	add    $0x20,%esp
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	57                   	push   %edi
  8012d0:	56                   	push   %esi
  8012d1:	53                   	push   %ebx
  8012d2:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8012d5:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  8012dc:	e8 77 11 00 00       	call   802458 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012e1:	bf 07 00 00 00       	mov    $0x7,%edi
  8012e6:	89 f8                	mov    %edi,%eax
  8012e8:	cd 30                	int    $0x30
  8012ea:	89 c7                	mov    %eax,%edi
  8012ec:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	79 1c                	jns    80130e <fork+0x42>
		panic("fork : error!\n");
  8012f2:	c7 44 24 08 a3 2d 80 	movl   $0x802da3,0x8(%esp)
  8012f9:	00 
  8012fa:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  801301:	00 
  801302:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801309:	e8 86 f0 ff ff       	call   800394 <_panic>
	if (envid==0){
  80130e:	85 c0                	test   %eax,%eax
  801310:	75 28                	jne    80133a <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  801312:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801318:	e8 ce fa ff ff       	call   800deb <sys_getenvid>
  80131d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801322:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801329:	c1 e0 07             	shl    $0x7,%eax
  80132c:	29 d0                	sub    %edx,%eax
  80132e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801333:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  801335:	e9 f2 00 00 00       	jmp    80142c <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  80133a:	e8 ac fa ff ff       	call   800deb <sys_getenvid>
  80133f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801342:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  801347:	89 d8                	mov    %ebx,%eax
  801349:	c1 e8 16             	shr    $0x16,%eax
  80134c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801353:	a8 01                	test   $0x1,%al
  801355:	74 17                	je     80136e <fork+0xa2>
  801357:	89 da                	mov    %ebx,%edx
  801359:	c1 ea 0c             	shr    $0xc,%edx
  80135c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801363:	a8 01                	test   $0x1,%al
  801365:	74 07                	je     80136e <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  801367:	89 f0                	mov    %esi,%eax
  801369:	e8 26 fd ff ff       	call   801094 <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  80136e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801374:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80137a:	75 cb                	jne    801347 <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  80137c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801383:	00 
  801384:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80138b:	ee 
  80138c:	89 3c 24             	mov    %edi,(%esp)
  80138f:	e8 95 fa ff ff       	call   800e29 <sys_page_alloc>
  801394:	85 c0                	test   %eax,%eax
  801396:	79 1c                	jns    8013b4 <fork+0xe8>
  801398:	c7 44 24 08 a3 2d 80 	movl   $0x802da3,0x8(%esp)
  80139f:	00 
  8013a0:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8013a7:	00 
  8013a8:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  8013af:	e8 e0 ef ff ff       	call   800394 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  8013b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8013bc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013c3:	c1 e0 07             	shl    $0x7,%eax
  8013c6:	29 d0                	sub    %edx,%eax
  8013c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013cd:	8b 40 64             	mov    0x64(%eax),%eax
  8013d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d4:	89 3c 24             	mov    %edi,(%esp)
  8013d7:	e8 ed fb ff ff       	call   800fc9 <sys_env_set_pgfault_upcall>
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	79 1c                	jns    8013fc <fork+0x130>
  8013e0:	c7 44 24 08 a3 2d 80 	movl   $0x802da3,0x8(%esp)
  8013e7:	00 
  8013e8:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8013ef:	00 
  8013f0:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  8013f7:	e8 98 ef ff ff       	call   800394 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8013fc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801403:	00 
  801404:	89 3c 24             	mov    %edi,(%esp)
  801407:	e8 17 fb ff ff       	call   800f23 <sys_env_set_status>
  80140c:	85 c0                	test   %eax,%eax
  80140e:	79 1c                	jns    80142c <fork+0x160>
  801410:	c7 44 24 08 a3 2d 80 	movl   $0x802da3,0x8(%esp)
  801417:	00 
  801418:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  80141f:	00 
  801420:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801427:	e8 68 ef ff ff       	call   800394 <_panic>
	return envid_child;
	panic("fork not implemented");
}
  80142c:	89 f8                	mov    %edi,%eax
  80142e:	83 c4 2c             	add    $0x2c,%esp
  801431:	5b                   	pop    %ebx
  801432:	5e                   	pop    %esi
  801433:	5f                   	pop    %edi
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <sfork>:

// Challenge!
int
sfork(void)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	57                   	push   %edi
  80143a:	56                   	push   %esi
  80143b:	53                   	push   %ebx
  80143c:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  80143f:	c7 04 24 9c 11 80 00 	movl   $0x80119c,(%esp)
  801446:	e8 0d 10 00 00       	call   802458 <set_pgfault_handler>
  80144b:	ba 07 00 00 00       	mov    $0x7,%edx
  801450:	89 d0                	mov    %edx,%eax
  801452:	cd 30                	int    $0x30
  801454:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801457:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145d:	c7 04 24 97 2d 80 00 	movl   $0x802d97,(%esp)
  801464:	e8 23 f0 ff ff       	call   80048c <cprintf>
	if (envid<0)
  801469:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80146d:	79 1c                	jns    80148b <sfork+0x55>
		panic("sfork : error!\n");
  80146f:	c7 44 24 08 a2 2d 80 	movl   $0x802da2,0x8(%esp)
  801476:	00 
  801477:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  80147e:	00 
  80147f:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801486:	e8 09 ef ff ff       	call   800394 <_panic>
	if (envid==0){
  80148b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80148f:	75 28                	jne    8014b9 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  801491:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  801497:	e8 4f f9 ff ff       	call   800deb <sys_getenvid>
  80149c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8014a8:	c1 e0 07             	shl    $0x7,%eax
  8014ab:	29 d0                	sub    %edx,%eax
  8014ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014b2:	89 03                	mov    %eax,(%ebx)
		return envid;
  8014b4:	e9 18 01 00 00       	jmp    8015d1 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  8014b9:	e8 2d f9 ff ff       	call   800deb <sys_getenvid>
  8014be:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8014c0:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  8014c5:	89 d8                	mov    %ebx,%eax
  8014c7:	c1 e8 16             	shr    $0x16,%eax
  8014ca:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d1:	a8 01                	test   $0x1,%al
  8014d3:	74 2c                	je     801501 <sfork+0xcb>
  8014d5:	89 d8                	mov    %ebx,%eax
  8014d7:	c1 e8 0c             	shr    $0xc,%eax
  8014da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e1:	a8 01                	test   $0x1,%al
  8014e3:	74 1c                	je     801501 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  8014e5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8014ec:	00 
  8014ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014f1:	89 74 24 08          	mov    %esi,0x8(%esp)
  8014f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f9:	89 3c 24             	mov    %edi,(%esp)
  8014fc:	e8 7c f9 ff ff       	call   800e7d <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801501:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801507:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  80150d:	75 b6                	jne    8014c5 <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  80150f:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801514:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801517:	e8 78 fb ff ff       	call   801094 <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  80151c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801523:	00 
  801524:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80152b:	ee 
  80152c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80152f:	89 04 24             	mov    %eax,(%esp)
  801532:	e8 f2 f8 ff ff       	call   800e29 <sys_page_alloc>
  801537:	85 c0                	test   %eax,%eax
  801539:	79 1c                	jns    801557 <sfork+0x121>
  80153b:	c7 44 24 08 a2 2d 80 	movl   $0x802da2,0x8(%esp)
  801542:	00 
  801543:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  80154a:	00 
  80154b:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801552:	e8 3d ee ff ff       	call   800394 <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  801557:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  80155d:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  801564:	c1 e7 07             	shl    $0x7,%edi
  801567:	29 d7                	sub    %edx,%edi
  801569:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  80156f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 4b fa ff ff       	call   800fc9 <sys_env_set_pgfault_upcall>
  80157e:	85 c0                	test   %eax,%eax
  801580:	79 1c                	jns    80159e <sfork+0x168>
  801582:	c7 44 24 08 a2 2d 80 	movl   $0x802da2,0x8(%esp)
  801589:	00 
  80158a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  801591:	00 
  801592:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  801599:	e8 f6 ed ff ff       	call   800394 <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  80159e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8015a5:	00 
  8015a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015a9:	89 04 24             	mov    %eax,(%esp)
  8015ac:	e8 72 f9 ff ff       	call   800f23 <sys_env_set_status>
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	79 1c                	jns    8015d1 <sfork+0x19b>
  8015b5:	c7 44 24 08 a2 2d 80 	movl   $0x802da2,0x8(%esp)
  8015bc:	00 
  8015bd:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  8015c4:	00 
  8015c5:	c7 04 24 7b 2d 80 00 	movl   $0x802d7b,(%esp)
  8015cc:	e8 c3 ed ff ff       	call   800394 <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  8015d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d4:	83 c4 3c             	add    $0x3c,%esp
  8015d7:	5b                   	pop    %ebx
  8015d8:	5e                   	pop    %esi
  8015d9:	5f                   	pop    %edi
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    

008015dc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015df:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8015e7:	c1 e8 0c             	shr    $0xc,%eax
}
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8015f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f5:	89 04 24             	mov    %eax,(%esp)
  8015f8:	e8 df ff ff ff       	call   8015dc <fd2num>
  8015fd:	05 20 00 0d 00       	add    $0xd0020,%eax
  801602:	c1 e0 0c             	shl    $0xc,%eax
}
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	53                   	push   %ebx
  80160b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80160e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801613:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801615:	89 c2                	mov    %eax,%edx
  801617:	c1 ea 16             	shr    $0x16,%edx
  80161a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801621:	f6 c2 01             	test   $0x1,%dl
  801624:	74 11                	je     801637 <fd_alloc+0x30>
  801626:	89 c2                	mov    %eax,%edx
  801628:	c1 ea 0c             	shr    $0xc,%edx
  80162b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801632:	f6 c2 01             	test   $0x1,%dl
  801635:	75 09                	jne    801640 <fd_alloc+0x39>
			*fd_store = fd;
  801637:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801639:	b8 00 00 00 00       	mov    $0x0,%eax
  80163e:	eb 17                	jmp    801657 <fd_alloc+0x50>
  801640:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801645:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80164a:	75 c7                	jne    801613 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80164c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801652:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801657:	5b                   	pop    %ebx
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801660:	83 f8 1f             	cmp    $0x1f,%eax
  801663:	77 36                	ja     80169b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801665:	05 00 00 0d 00       	add    $0xd0000,%eax
  80166a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	c1 ea 16             	shr    $0x16,%edx
  801672:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801679:	f6 c2 01             	test   $0x1,%dl
  80167c:	74 24                	je     8016a2 <fd_lookup+0x48>
  80167e:	89 c2                	mov    %eax,%edx
  801680:	c1 ea 0c             	shr    $0xc,%edx
  801683:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80168a:	f6 c2 01             	test   $0x1,%dl
  80168d:	74 1a                	je     8016a9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80168f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801692:	89 02                	mov    %eax,(%edx)
	return 0;
  801694:	b8 00 00 00 00       	mov    $0x0,%eax
  801699:	eb 13                	jmp    8016ae <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80169b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a0:	eb 0c                	jmp    8016ae <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a7:	eb 05                	jmp    8016ae <fd_lookup+0x54>
  8016a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 14             	sub    $0x14,%esp
  8016b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8016bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c2:	eb 0e                	jmp    8016d2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8016c4:	39 08                	cmp    %ecx,(%eax)
  8016c6:	75 09                	jne    8016d1 <dev_lookup+0x21>
			*dev = devtab[i];
  8016c8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cf:	eb 35                	jmp    801706 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016d1:	42                   	inc    %edx
  8016d2:	8b 04 95 30 2e 80 00 	mov    0x802e30(,%edx,4),%eax
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	75 e7                	jne    8016c4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8016e2:	8b 00                	mov    (%eax),%eax
  8016e4:	8b 40 48             	mov    0x48(%eax),%eax
  8016e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ef:	c7 04 24 b4 2d 80 00 	movl   $0x802db4,(%esp)
  8016f6:	e8 91 ed ff ff       	call   80048c <cprintf>
	*dev = 0;
  8016fb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801701:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801706:	83 c4 14             	add    $0x14,%esp
  801709:	5b                   	pop    %ebx
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
  801711:	83 ec 30             	sub    $0x30,%esp
  801714:	8b 75 08             	mov    0x8(%ebp),%esi
  801717:	8a 45 0c             	mov    0xc(%ebp),%al
  80171a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80171d:	89 34 24             	mov    %esi,(%esp)
  801720:	e8 b7 fe ff ff       	call   8015dc <fd2num>
  801725:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801728:	89 54 24 04          	mov    %edx,0x4(%esp)
  80172c:	89 04 24             	mov    %eax,(%esp)
  80172f:	e8 26 ff ff ff       	call   80165a <fd_lookup>
  801734:	89 c3                	mov    %eax,%ebx
  801736:	85 c0                	test   %eax,%eax
  801738:	78 05                	js     80173f <fd_close+0x33>
	    || fd != fd2)
  80173a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80173d:	74 0d                	je     80174c <fd_close+0x40>
		return (must_exist ? r : 0);
  80173f:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801743:	75 46                	jne    80178b <fd_close+0x7f>
  801745:	bb 00 00 00 00       	mov    $0x0,%ebx
  80174a:	eb 3f                	jmp    80178b <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80174c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801753:	8b 06                	mov    (%esi),%eax
  801755:	89 04 24             	mov    %eax,(%esp)
  801758:	e8 53 ff ff ff       	call   8016b0 <dev_lookup>
  80175d:	89 c3                	mov    %eax,%ebx
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 18                	js     80177b <fd_close+0x6f>
		if (dev->dev_close)
  801763:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801766:	8b 40 10             	mov    0x10(%eax),%eax
  801769:	85 c0                	test   %eax,%eax
  80176b:	74 09                	je     801776 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80176d:	89 34 24             	mov    %esi,(%esp)
  801770:	ff d0                	call   *%eax
  801772:	89 c3                	mov    %eax,%ebx
  801774:	eb 05                	jmp    80177b <fd_close+0x6f>
		else
			r = 0;
  801776:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80177b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80177f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801786:	e8 45 f7 ff ff       	call   800ed0 <sys_page_unmap>
	return r;
}
  80178b:	89 d8                	mov    %ebx,%eax
  80178d:	83 c4 30             	add    $0x30,%esp
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80179a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	89 04 24             	mov    %eax,(%esp)
  8017a7:	e8 ae fe ff ff       	call   80165a <fd_lookup>
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 13                	js     8017c3 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8017b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017b7:	00 
  8017b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017bb:	89 04 24             	mov    %eax,(%esp)
  8017be:	e8 49 ff ff ff       	call   80170c <fd_close>
}
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <close_all>:

void
close_all(void)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	53                   	push   %ebx
  8017c9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8017cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8017d1:	89 1c 24             	mov    %ebx,(%esp)
  8017d4:	e8 bb ff ff ff       	call   801794 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8017d9:	43                   	inc    %ebx
  8017da:	83 fb 20             	cmp    $0x20,%ebx
  8017dd:	75 f2                	jne    8017d1 <close_all+0xc>
		close(i);
}
  8017df:	83 c4 14             	add    $0x14,%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	57                   	push   %edi
  8017e9:	56                   	push   %esi
  8017ea:	53                   	push   %ebx
  8017eb:	83 ec 4c             	sub    $0x4c,%esp
  8017ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8017f1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	89 04 24             	mov    %eax,(%esp)
  8017fe:	e8 57 fe ff ff       	call   80165a <fd_lookup>
  801803:	89 c3                	mov    %eax,%ebx
  801805:	85 c0                	test   %eax,%eax
  801807:	0f 88 e1 00 00 00    	js     8018ee <dup+0x109>
		return r;
	close(newfdnum);
  80180d:	89 3c 24             	mov    %edi,(%esp)
  801810:	e8 7f ff ff ff       	call   801794 <close>

	newfd = INDEX2FD(newfdnum);
  801815:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80181b:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80181e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801821:	89 04 24             	mov    %eax,(%esp)
  801824:	e8 c3 fd ff ff       	call   8015ec <fd2data>
  801829:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80182b:	89 34 24             	mov    %esi,(%esp)
  80182e:	e8 b9 fd ff ff       	call   8015ec <fd2data>
  801833:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801836:	89 d8                	mov    %ebx,%eax
  801838:	c1 e8 16             	shr    $0x16,%eax
  80183b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801842:	a8 01                	test   $0x1,%al
  801844:	74 46                	je     80188c <dup+0xa7>
  801846:	89 d8                	mov    %ebx,%eax
  801848:	c1 e8 0c             	shr    $0xc,%eax
  80184b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801852:	f6 c2 01             	test   $0x1,%dl
  801855:	74 35                	je     80188c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801857:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80185e:	25 07 0e 00 00       	and    $0xe07,%eax
  801863:	89 44 24 10          	mov    %eax,0x10(%esp)
  801867:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80186a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80186e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801875:	00 
  801876:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80187a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801881:	e8 f7 f5 ff ff       	call   800e7d <sys_page_map>
  801886:	89 c3                	mov    %eax,%ebx
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 3b                	js     8018c7 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80188c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80188f:	89 c2                	mov    %eax,%edx
  801891:	c1 ea 0c             	shr    $0xc,%edx
  801894:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80189b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8018a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018b0:	00 
  8018b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018bc:	e8 bc f5 ff ff       	call   800e7d <sys_page_map>
  8018c1:	89 c3                	mov    %eax,%ebx
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	79 25                	jns    8018ec <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018c7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018d2:	e8 f9 f5 ff ff       	call   800ed0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e5:	e8 e6 f5 ff ff       	call   800ed0 <sys_page_unmap>
	return r;
  8018ea:	eb 02                	jmp    8018ee <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8018ec:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8018ee:	89 d8                	mov    %ebx,%eax
  8018f0:	83 c4 4c             	add    $0x4c,%esp
  8018f3:	5b                   	pop    %ebx
  8018f4:	5e                   	pop    %esi
  8018f5:	5f                   	pop    %edi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	53                   	push   %ebx
  8018fc:	83 ec 24             	sub    $0x24,%esp
  8018ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801902:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801905:	89 44 24 04          	mov    %eax,0x4(%esp)
  801909:	89 1c 24             	mov    %ebx,(%esp)
  80190c:	e8 49 fd ff ff       	call   80165a <fd_lookup>
  801911:	85 c0                	test   %eax,%eax
  801913:	78 6f                	js     801984 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801915:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191f:	8b 00                	mov    (%eax),%eax
  801921:	89 04 24             	mov    %eax,(%esp)
  801924:	e8 87 fd ff ff       	call   8016b0 <dev_lookup>
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 57                	js     801984 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80192d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801930:	8b 50 08             	mov    0x8(%eax),%edx
  801933:	83 e2 03             	and    $0x3,%edx
  801936:	83 fa 01             	cmp    $0x1,%edx
  801939:	75 25                	jne    801960 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80193b:	a1 04 40 80 00       	mov    0x804004,%eax
  801940:	8b 00                	mov    (%eax),%eax
  801942:	8b 40 48             	mov    0x48(%eax),%eax
  801945:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194d:	c7 04 24 f5 2d 80 00 	movl   $0x802df5,(%esp)
  801954:	e8 33 eb ff ff       	call   80048c <cprintf>
		return -E_INVAL;
  801959:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80195e:	eb 24                	jmp    801984 <read+0x8c>
	}
	if (!dev->dev_read)
  801960:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801963:	8b 52 08             	mov    0x8(%edx),%edx
  801966:	85 d2                	test   %edx,%edx
  801968:	74 15                	je     80197f <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80196a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80196d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801971:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801974:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801978:	89 04 24             	mov    %eax,(%esp)
  80197b:	ff d2                	call   *%edx
  80197d:	eb 05                	jmp    801984 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80197f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801984:	83 c4 24             	add    $0x24,%esp
  801987:	5b                   	pop    %ebx
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	57                   	push   %edi
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	83 ec 1c             	sub    $0x1c,%esp
  801993:	8b 7d 08             	mov    0x8(%ebp),%edi
  801996:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801999:	bb 00 00 00 00       	mov    $0x0,%ebx
  80199e:	eb 23                	jmp    8019c3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019a0:	89 f0                	mov    %esi,%eax
  8019a2:	29 d8                	sub    %ebx,%eax
  8019a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ab:	01 d8                	add    %ebx,%eax
  8019ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b1:	89 3c 24             	mov    %edi,(%esp)
  8019b4:	e8 3f ff ff ff       	call   8018f8 <read>
		if (m < 0)
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 10                	js     8019cd <readn+0x43>
			return m;
		if (m == 0)
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	74 0a                	je     8019cb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019c1:	01 c3                	add    %eax,%ebx
  8019c3:	39 f3                	cmp    %esi,%ebx
  8019c5:	72 d9                	jb     8019a0 <readn+0x16>
  8019c7:	89 d8                	mov    %ebx,%eax
  8019c9:	eb 02                	jmp    8019cd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8019cb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8019cd:	83 c4 1c             	add    $0x1c,%esp
  8019d0:	5b                   	pop    %ebx
  8019d1:	5e                   	pop    %esi
  8019d2:	5f                   	pop    %edi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 24             	sub    $0x24,%esp
  8019dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e6:	89 1c 24             	mov    %ebx,(%esp)
  8019e9:	e8 6c fc ff ff       	call   80165a <fd_lookup>
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 6a                	js     801a5c <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019fc:	8b 00                	mov    (%eax),%eax
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	e8 aa fc ff ff       	call   8016b0 <dev_lookup>
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 52                	js     801a5c <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a11:	75 25                	jne    801a38 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a13:	a1 04 40 80 00       	mov    0x804004,%eax
  801a18:	8b 00                	mov    (%eax),%eax
  801a1a:	8b 40 48             	mov    0x48(%eax),%eax
  801a1d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a25:	c7 04 24 11 2e 80 00 	movl   $0x802e11,(%esp)
  801a2c:	e8 5b ea ff ff       	call   80048c <cprintf>
		return -E_INVAL;
  801a31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a36:	eb 24                	jmp    801a5c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a38:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a3b:	8b 52 0c             	mov    0xc(%edx),%edx
  801a3e:	85 d2                	test   %edx,%edx
  801a40:	74 15                	je     801a57 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a42:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a45:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a4c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a50:	89 04 24             	mov    %eax,(%esp)
  801a53:	ff d2                	call   *%edx
  801a55:	eb 05                	jmp    801a5c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a57:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a5c:	83 c4 24             	add    $0x24,%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a68:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a72:	89 04 24             	mov    %eax,(%esp)
  801a75:	e8 e0 fb ff ff       	call   80165a <fd_lookup>
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 0e                	js     801a8c <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a81:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a84:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a8c:	c9                   	leave  
  801a8d:	c3                   	ret    

00801a8e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	53                   	push   %ebx
  801a92:	83 ec 24             	sub    $0x24,%esp
  801a95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9f:	89 1c 24             	mov    %ebx,(%esp)
  801aa2:	e8 b3 fb ff ff       	call   80165a <fd_lookup>
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 63                	js     801b0e <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab5:	8b 00                	mov    (%eax),%eax
  801ab7:	89 04 24             	mov    %eax,(%esp)
  801aba:	e8 f1 fb ff ff       	call   8016b0 <dev_lookup>
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	78 4b                	js     801b0e <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801aca:	75 25                	jne    801af1 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801acc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad1:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801ad3:	8b 40 48             	mov    0x48(%eax),%eax
  801ad6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ada:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ade:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  801ae5:	e8 a2 e9 ff ff       	call   80048c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801aea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801aef:	eb 1d                	jmp    801b0e <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801af1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801af4:	8b 52 18             	mov    0x18(%edx),%edx
  801af7:	85 d2                	test   %edx,%edx
  801af9:	74 0e                	je     801b09 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801afe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b02:	89 04 24             	mov    %eax,(%esp)
  801b05:	ff d2                	call   *%edx
  801b07:	eb 05                	jmp    801b0e <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b09:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b0e:	83 c4 24             	add    $0x24,%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	53                   	push   %ebx
  801b18:	83 ec 24             	sub    $0x24,%esp
  801b1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b1e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	89 04 24             	mov    %eax,(%esp)
  801b2b:	e8 2a fb ff ff       	call   80165a <fd_lookup>
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 52                	js     801b86 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3e:	8b 00                	mov    (%eax),%eax
  801b40:	89 04 24             	mov    %eax,(%esp)
  801b43:	e8 68 fb ff ff       	call   8016b0 <dev_lookup>
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	78 3a                	js     801b86 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b53:	74 2c                	je     801b81 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b55:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b58:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b5f:	00 00 00 
	stat->st_isdir = 0;
  801b62:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b69:	00 00 00 
	stat->st_dev = dev;
  801b6c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b76:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b79:	89 14 24             	mov    %edx,(%esp)
  801b7c:	ff 50 14             	call   *0x14(%eax)
  801b7f:	eb 05                	jmp    801b86 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b81:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b86:	83 c4 24             	add    $0x24,%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b9b:	00 
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	89 04 24             	mov    %eax,(%esp)
  801ba2:	e8 88 02 00 00       	call   801e2f <open>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	78 1b                	js     801bc8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801bad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb4:	89 1c 24             	mov    %ebx,(%esp)
  801bb7:	e8 58 ff ff ff       	call   801b14 <fstat>
  801bbc:	89 c6                	mov    %eax,%esi
	close(fd);
  801bbe:	89 1c 24             	mov    %ebx,(%esp)
  801bc1:	e8 ce fb ff ff       	call   801794 <close>
	return r;
  801bc6:	89 f3                	mov    %esi,%ebx
}
  801bc8:	89 d8                	mov    %ebx,%eax
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    
  801bd1:	00 00                	add    %al,(%eax)
	...

00801bd4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 10             	sub    $0x10,%esp
  801bdc:	89 c3                	mov    %eax,%ebx
  801bde:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801be0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801be7:	75 11                	jne    801bfa <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801be9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801bf0:	e8 ee 09 00 00       	call   8025e3 <ipc_find_env>
  801bf5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bfa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c01:	00 
  801c02:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801c09:	00 
  801c0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c0e:	a1 00 40 80 00       	mov    0x804000,%eax
  801c13:	89 04 24             	mov    %eax,(%esp)
  801c16:	e8 62 09 00 00       	call   80257d <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801c1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c22:	00 
  801c23:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2e:	e8 dd 08 00 00       	call   802510 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    

00801c3a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c40:	8b 45 08             	mov    0x8(%ebp),%eax
  801c43:	8b 40 0c             	mov    0xc(%eax),%eax
  801c46:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c53:	ba 00 00 00 00       	mov    $0x0,%edx
  801c58:	b8 02 00 00 00       	mov    $0x2,%eax
  801c5d:	e8 72 ff ff ff       	call   801bd4 <fsipc>
}
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6d:	8b 40 0c             	mov    0xc(%eax),%eax
  801c70:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c75:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7a:	b8 06 00 00 00       	mov    $0x6,%eax
  801c7f:	e8 50 ff ff ff       	call   801bd4 <fsipc>
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	53                   	push   %ebx
  801c8a:	83 ec 14             	sub    $0x14,%esp
  801c8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c90:	8b 45 08             	mov    0x8(%ebp),%eax
  801c93:	8b 40 0c             	mov    0xc(%eax),%eax
  801c96:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca0:	b8 05 00 00 00       	mov    $0x5,%eax
  801ca5:	e8 2a ff ff ff       	call   801bd4 <fsipc>
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 2b                	js     801cd9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cae:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cb5:	00 
  801cb6:	89 1c 24             	mov    %ebx,(%esp)
  801cb9:	e8 79 ed ff ff       	call   800a37 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cbe:	a1 80 50 80 00       	mov    0x805080,%eax
  801cc3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cc9:	a1 84 50 80 00       	mov    0x805084,%eax
  801cce:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801cd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cd9:	83 c4 14             	add    $0x14,%esp
  801cdc:	5b                   	pop    %ebx
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	53                   	push   %ebx
  801ce3:	83 ec 14             	sub    $0x14,%esp
  801ce6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cec:	8b 40 0c             	mov    0xc(%eax),%eax
  801cef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801cf4:	89 d8                	mov    %ebx,%eax
  801cf6:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801cfc:	76 05                	jbe    801d03 <devfile_write+0x24>
  801cfe:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801d03:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801d08:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d13:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801d1a:	e8 fb ee ff ff       	call   800c1a <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d24:	b8 04 00 00 00       	mov    $0x4,%eax
  801d29:	e8 a6 fe ff ff       	call   801bd4 <fsipc>
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 53                	js     801d85 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801d32:	39 c3                	cmp    %eax,%ebx
  801d34:	73 24                	jae    801d5a <devfile_write+0x7b>
  801d36:	c7 44 24 0c 40 2e 80 	movl   $0x802e40,0xc(%esp)
  801d3d:	00 
  801d3e:	c7 44 24 08 47 2e 80 	movl   $0x802e47,0x8(%esp)
  801d45:	00 
  801d46:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801d4d:	00 
  801d4e:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801d55:	e8 3a e6 ff ff       	call   800394 <_panic>
	assert(r <= PGSIZE);
  801d5a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d5f:	7e 24                	jle    801d85 <devfile_write+0xa6>
  801d61:	c7 44 24 0c 67 2e 80 	movl   $0x802e67,0xc(%esp)
  801d68:	00 
  801d69:	c7 44 24 08 47 2e 80 	movl   $0x802e47,0x8(%esp)
  801d70:	00 
  801d71:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801d78:	00 
  801d79:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801d80:	e8 0f e6 ff ff       	call   800394 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801d85:	83 c4 14             	add    $0x14,%esp
  801d88:	5b                   	pop    %ebx
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	56                   	push   %esi
  801d8f:	53                   	push   %ebx
  801d90:	83 ec 10             	sub    $0x10,%esp
  801d93:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
  801d99:	8b 40 0c             	mov    0xc(%eax),%eax
  801d9c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801da1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801da7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dac:	b8 03 00 00 00       	mov    $0x3,%eax
  801db1:	e8 1e fe ff ff       	call   801bd4 <fsipc>
  801db6:	89 c3                	mov    %eax,%ebx
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 6a                	js     801e26 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801dbc:	39 c6                	cmp    %eax,%esi
  801dbe:	73 24                	jae    801de4 <devfile_read+0x59>
  801dc0:	c7 44 24 0c 40 2e 80 	movl   $0x802e40,0xc(%esp)
  801dc7:	00 
  801dc8:	c7 44 24 08 47 2e 80 	movl   $0x802e47,0x8(%esp)
  801dcf:	00 
  801dd0:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801dd7:	00 
  801dd8:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801ddf:	e8 b0 e5 ff ff       	call   800394 <_panic>
	assert(r <= PGSIZE);
  801de4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801de9:	7e 24                	jle    801e0f <devfile_read+0x84>
  801deb:	c7 44 24 0c 67 2e 80 	movl   $0x802e67,0xc(%esp)
  801df2:	00 
  801df3:	c7 44 24 08 47 2e 80 	movl   $0x802e47,0x8(%esp)
  801dfa:	00 
  801dfb:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801e02:	00 
  801e03:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801e0a:	e8 85 e5 ff ff       	call   800394 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e13:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e1a:	00 
  801e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1e:	89 04 24             	mov    %eax,(%esp)
  801e21:	e8 8a ed ff ff       	call   800bb0 <memmove>
	return r;
}
  801e26:	89 d8                	mov    %ebx,%eax
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	5b                   	pop    %ebx
  801e2c:	5e                   	pop    %esi
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    

00801e2f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	83 ec 20             	sub    $0x20,%esp
  801e37:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e3a:	89 34 24             	mov    %esi,(%esp)
  801e3d:	e8 c2 eb ff ff       	call   800a04 <strlen>
  801e42:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e47:	7f 60                	jg     801ea9 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4c:	89 04 24             	mov    %eax,(%esp)
  801e4f:	e8 b3 f7 ff ff       	call   801607 <fd_alloc>
  801e54:	89 c3                	mov    %eax,%ebx
  801e56:	85 c0                	test   %eax,%eax
  801e58:	78 54                	js     801eae <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e5a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e5e:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e65:	e8 cd eb ff ff       	call   800a37 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e75:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7a:	e8 55 fd ff ff       	call   801bd4 <fsipc>
  801e7f:	89 c3                	mov    %eax,%ebx
  801e81:	85 c0                	test   %eax,%eax
  801e83:	79 15                	jns    801e9a <open+0x6b>
		fd_close(fd, 0);
  801e85:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e8c:	00 
  801e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e90:	89 04 24             	mov    %eax,(%esp)
  801e93:	e8 74 f8 ff ff       	call   80170c <fd_close>
		return r;
  801e98:	eb 14                	jmp    801eae <open+0x7f>
	}

	return fd2num(fd);
  801e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9d:	89 04 24             	mov    %eax,(%esp)
  801ea0:	e8 37 f7 ff ff       	call   8015dc <fd2num>
  801ea5:	89 c3                	mov    %eax,%ebx
  801ea7:	eb 05                	jmp    801eae <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ea9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801eae:	89 d8                	mov    %ebx,%eax
  801eb0:	83 c4 20             	add    $0x20,%esp
  801eb3:	5b                   	pop    %ebx
  801eb4:	5e                   	pop    %esi
  801eb5:	5d                   	pop    %ebp
  801eb6:	c3                   	ret    

00801eb7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ebd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec2:	b8 08 00 00 00       	mov    $0x8,%eax
  801ec7:	e8 08 fd ff ff       	call   801bd4 <fsipc>
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    
	...

00801ed0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	56                   	push   %esi
  801ed4:	53                   	push   %ebx
  801ed5:	83 ec 10             	sub    $0x10,%esp
  801ed8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801edb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ede:	89 04 24             	mov    %eax,(%esp)
  801ee1:	e8 06 f7 ff ff       	call   8015ec <fd2data>
  801ee6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ee8:	c7 44 24 04 73 2e 80 	movl   $0x802e73,0x4(%esp)
  801eef:	00 
  801ef0:	89 34 24             	mov    %esi,(%esp)
  801ef3:	e8 3f eb ff ff       	call   800a37 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ef8:	8b 43 04             	mov    0x4(%ebx),%eax
  801efb:	2b 03                	sub    (%ebx),%eax
  801efd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f03:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f0a:	00 00 00 
	stat->st_dev = &devpipe;
  801f0d:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801f14:	30 80 00 
	return 0;
}
  801f17:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    

00801f23 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	53                   	push   %ebx
  801f27:	83 ec 14             	sub    $0x14,%esp
  801f2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f2d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f38:	e8 93 ef ff ff       	call   800ed0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f3d:	89 1c 24             	mov    %ebx,(%esp)
  801f40:	e8 a7 f6 ff ff       	call   8015ec <fd2data>
  801f45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f50:	e8 7b ef ff ff       	call   800ed0 <sys_page_unmap>
}
  801f55:	83 c4 14             	add    $0x14,%esp
  801f58:	5b                   	pop    %ebx
  801f59:	5d                   	pop    %ebp
  801f5a:	c3                   	ret    

00801f5b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f5b:	55                   	push   %ebp
  801f5c:	89 e5                	mov    %esp,%ebp
  801f5e:	57                   	push   %edi
  801f5f:	56                   	push   %esi
  801f60:	53                   	push   %ebx
  801f61:	83 ec 2c             	sub    $0x2c,%esp
  801f64:	89 c7                	mov    %eax,%edi
  801f66:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f69:	a1 04 40 80 00       	mov    0x804004,%eax
  801f6e:	8b 00                	mov    (%eax),%eax
  801f70:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f73:	89 3c 24             	mov    %edi,(%esp)
  801f76:	e8 ad 06 00 00       	call   802628 <pageref>
  801f7b:	89 c6                	mov    %eax,%esi
  801f7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f80:	89 04 24             	mov    %eax,(%esp)
  801f83:	e8 a0 06 00 00       	call   802628 <pageref>
  801f88:	39 c6                	cmp    %eax,%esi
  801f8a:	0f 94 c0             	sete   %al
  801f8d:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f90:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f96:	8b 12                	mov    (%edx),%edx
  801f98:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f9b:	39 cb                	cmp    %ecx,%ebx
  801f9d:	75 08                	jne    801fa7 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f9f:	83 c4 2c             	add    $0x2c,%esp
  801fa2:	5b                   	pop    %ebx
  801fa3:	5e                   	pop    %esi
  801fa4:	5f                   	pop    %edi
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801fa7:	83 f8 01             	cmp    $0x1,%eax
  801faa:	75 bd                	jne    801f69 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fac:	8b 42 58             	mov    0x58(%edx),%eax
  801faf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801fb6:	00 
  801fb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fbf:	c7 04 24 7a 2e 80 00 	movl   $0x802e7a,(%esp)
  801fc6:	e8 c1 e4 ff ff       	call   80048c <cprintf>
  801fcb:	eb 9c                	jmp    801f69 <_pipeisclosed+0xe>

00801fcd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	57                   	push   %edi
  801fd1:	56                   	push   %esi
  801fd2:	53                   	push   %ebx
  801fd3:	83 ec 1c             	sub    $0x1c,%esp
  801fd6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fd9:	89 34 24             	mov    %esi,(%esp)
  801fdc:	e8 0b f6 ff ff       	call   8015ec <fd2data>
  801fe1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fe3:	bf 00 00 00 00       	mov    $0x0,%edi
  801fe8:	eb 3c                	jmp    802026 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fea:	89 da                	mov    %ebx,%edx
  801fec:	89 f0                	mov    %esi,%eax
  801fee:	e8 68 ff ff ff       	call   801f5b <_pipeisclosed>
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	75 38                	jne    80202f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ff7:	e8 0e ee ff ff       	call   800e0a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ffc:	8b 43 04             	mov    0x4(%ebx),%eax
  801fff:	8b 13                	mov    (%ebx),%edx
  802001:	83 c2 20             	add    $0x20,%edx
  802004:	39 d0                	cmp    %edx,%eax
  802006:	73 e2                	jae    801fea <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802008:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80200e:	89 c2                	mov    %eax,%edx
  802010:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802016:	79 05                	jns    80201d <devpipe_write+0x50>
  802018:	4a                   	dec    %edx
  802019:	83 ca e0             	or     $0xffffffe0,%edx
  80201c:	42                   	inc    %edx
  80201d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802021:	40                   	inc    %eax
  802022:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802025:	47                   	inc    %edi
  802026:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802029:	75 d1                	jne    801ffc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80202b:	89 f8                	mov    %edi,%eax
  80202d:	eb 05                	jmp    802034 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80202f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802034:	83 c4 1c             	add    $0x1c,%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    

0080203c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	57                   	push   %edi
  802040:	56                   	push   %esi
  802041:	53                   	push   %ebx
  802042:	83 ec 1c             	sub    $0x1c,%esp
  802045:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802048:	89 3c 24             	mov    %edi,(%esp)
  80204b:	e8 9c f5 ff ff       	call   8015ec <fd2data>
  802050:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802052:	be 00 00 00 00       	mov    $0x0,%esi
  802057:	eb 3a                	jmp    802093 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802059:	85 f6                	test   %esi,%esi
  80205b:	74 04                	je     802061 <devpipe_read+0x25>
				return i;
  80205d:	89 f0                	mov    %esi,%eax
  80205f:	eb 40                	jmp    8020a1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802061:	89 da                	mov    %ebx,%edx
  802063:	89 f8                	mov    %edi,%eax
  802065:	e8 f1 fe ff ff       	call   801f5b <_pipeisclosed>
  80206a:	85 c0                	test   %eax,%eax
  80206c:	75 2e                	jne    80209c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80206e:	e8 97 ed ff ff       	call   800e0a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802073:	8b 03                	mov    (%ebx),%eax
  802075:	3b 43 04             	cmp    0x4(%ebx),%eax
  802078:	74 df                	je     802059 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80207a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80207f:	79 05                	jns    802086 <devpipe_read+0x4a>
  802081:	48                   	dec    %eax
  802082:	83 c8 e0             	or     $0xffffffe0,%eax
  802085:	40                   	inc    %eax
  802086:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80208a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80208d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802090:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802092:	46                   	inc    %esi
  802093:	3b 75 10             	cmp    0x10(%ebp),%esi
  802096:	75 db                	jne    802073 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802098:	89 f0                	mov    %esi,%eax
  80209a:	eb 05                	jmp    8020a1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80209c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    

008020a9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	57                   	push   %edi
  8020ad:	56                   	push   %esi
  8020ae:	53                   	push   %ebx
  8020af:	83 ec 3c             	sub    $0x3c,%esp
  8020b2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8020b8:	89 04 24             	mov    %eax,(%esp)
  8020bb:	e8 47 f5 ff ff       	call   801607 <fd_alloc>
  8020c0:	89 c3                	mov    %eax,%ebx
  8020c2:	85 c0                	test   %eax,%eax
  8020c4:	0f 88 45 01 00 00    	js     80220f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020d1:	00 
  8020d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020e0:	e8 44 ed ff ff       	call   800e29 <sys_page_alloc>
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	85 c0                	test   %eax,%eax
  8020e9:	0f 88 20 01 00 00    	js     80220f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8020f2:	89 04 24             	mov    %eax,(%esp)
  8020f5:	e8 0d f5 ff ff       	call   801607 <fd_alloc>
  8020fa:	89 c3                	mov    %eax,%ebx
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	0f 88 f8 00 00 00    	js     8021fc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802104:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80210b:	00 
  80210c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80210f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802113:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80211a:	e8 0a ed ff ff       	call   800e29 <sys_page_alloc>
  80211f:	89 c3                	mov    %eax,%ebx
  802121:	85 c0                	test   %eax,%eax
  802123:	0f 88 d3 00 00 00    	js     8021fc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80212c:	89 04 24             	mov    %eax,(%esp)
  80212f:	e8 b8 f4 ff ff       	call   8015ec <fd2data>
  802134:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802136:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80213d:	00 
  80213e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802149:	e8 db ec ff ff       	call   800e29 <sys_page_alloc>
  80214e:	89 c3                	mov    %eax,%ebx
  802150:	85 c0                	test   %eax,%eax
  802152:	0f 88 91 00 00 00    	js     8021e9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802158:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80215b:	89 04 24             	mov    %eax,(%esp)
  80215e:	e8 89 f4 ff ff       	call   8015ec <fd2data>
  802163:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80216a:	00 
  80216b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802176:	00 
  802177:	89 74 24 04          	mov    %esi,0x4(%esp)
  80217b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802182:	e8 f6 ec ff ff       	call   800e7d <sys_page_map>
  802187:	89 c3                	mov    %eax,%ebx
  802189:	85 c0                	test   %eax,%eax
  80218b:	78 4c                	js     8021d9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80218d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  802193:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802196:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802198:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80219b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021a2:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8021a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021ab:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021b0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ba:	89 04 24             	mov    %eax,(%esp)
  8021bd:	e8 1a f4 ff ff       	call   8015dc <fd2num>
  8021c2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8021c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021c7:	89 04 24             	mov    %eax,(%esp)
  8021ca:	e8 0d f4 ff ff       	call   8015dc <fd2num>
  8021cf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8021d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021d7:	eb 36                	jmp    80220f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8021d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021e4:	e8 e7 ec ff ff       	call   800ed0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8021e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8021ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f7:	e8 d4 ec ff ff       	call   800ed0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8021fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802203:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80220a:	e8 c1 ec ff ff       	call   800ed0 <sys_page_unmap>
    err:
	return r;
}
  80220f:	89 d8                	mov    %ebx,%eax
  802211:	83 c4 3c             	add    $0x3c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    

00802219 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80221f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802222:	89 44 24 04          	mov    %eax,0x4(%esp)
  802226:	8b 45 08             	mov    0x8(%ebp),%eax
  802229:	89 04 24             	mov    %eax,(%esp)
  80222c:	e8 29 f4 ff ff       	call   80165a <fd_lookup>
  802231:	85 c0                	test   %eax,%eax
  802233:	78 15                	js     80224a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802238:	89 04 24             	mov    %eax,(%esp)
  80223b:	e8 ac f3 ff ff       	call   8015ec <fd2data>
	return _pipeisclosed(fd, p);
  802240:	89 c2                	mov    %eax,%edx
  802242:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802245:	e8 11 fd ff ff       	call   801f5b <_pipeisclosed>
}
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    

0080224c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80224c:	55                   	push   %ebp
  80224d:	89 e5                	mov    %esp,%ebp
  80224f:	56                   	push   %esi
  802250:	53                   	push   %ebx
  802251:	83 ec 10             	sub    $0x10,%esp
  802254:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802257:	85 f6                	test   %esi,%esi
  802259:	75 24                	jne    80227f <wait+0x33>
  80225b:	c7 44 24 0c 92 2e 80 	movl   $0x802e92,0xc(%esp)
  802262:	00 
  802263:	c7 44 24 08 47 2e 80 	movl   $0x802e47,0x8(%esp)
  80226a:	00 
  80226b:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802272:	00 
  802273:	c7 04 24 9d 2e 80 00 	movl   $0x802e9d,(%esp)
  80227a:	e8 15 e1 ff ff       	call   800394 <_panic>
	e = &envs[ENVX(envid)];
  80227f:	89 f3                	mov    %esi,%ebx
  802281:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802287:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  80228e:	c1 e3 07             	shl    $0x7,%ebx
  802291:	29 c3                	sub    %eax,%ebx
  802293:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802299:	eb 05                	jmp    8022a0 <wait+0x54>
		sys_yield();
  80229b:	e8 6a eb ff ff       	call   800e0a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022a0:	8b 43 48             	mov    0x48(%ebx),%eax
  8022a3:	39 f0                	cmp    %esi,%eax
  8022a5:	75 07                	jne    8022ae <wait+0x62>
  8022a7:	8b 43 54             	mov    0x54(%ebx),%eax
  8022aa:	85 c0                	test   %eax,%eax
  8022ac:	75 ed                	jne    80229b <wait+0x4f>
		sys_yield();
}
  8022ae:	83 c4 10             	add    $0x10,%esp
  8022b1:	5b                   	pop    %ebx
  8022b2:	5e                   	pop    %esi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    
  8022b5:	00 00                	add    %al,(%eax)
	...

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
  8022c8:	c7 44 24 04 a8 2e 80 	movl   $0x802ea8,0x4(%esp)
  8022cf:	00 
  8022d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d3:	89 04 24             	mov    %eax,(%esp)
  8022d6:	e8 5c e7 ff ff       	call   800a37 <strcpy>
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
  802318:	e8 93 e8 ff ff       	call   800bb0 <memmove>
		sys_cputs(buf, m);
  80231d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802321:	89 3c 24             	mov    %edi,(%esp)
  802324:	e8 33 ea ff ff       	call   800d5c <sys_cputs>
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
  80234b:	e8 ba ea ff ff       	call   800e0a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802350:	e8 25 ea ff ff       	call   800d7a <sys_cgetc>
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
  802398:	e8 bf e9 ff ff       	call   800d5c <sys_cputs>
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
  8023bb:	e8 38 f5 ff ff       	call   8018f8 <read>
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
  8023e8:	e8 6d f2 ff ff       	call   80165a <fd_lookup>
  8023ed:	85 c0                	test   %eax,%eax
  8023ef:	78 11                	js     802402 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f4:	8b 15 40 30 80 00    	mov    0x803040,%edx
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
  802410:	e8 f2 f1 ff ff       	call   801607 <fd_alloc>
  802415:	85 c0                	test   %eax,%eax
  802417:	78 3c                	js     802455 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802419:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802420:	00 
  802421:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802424:	89 44 24 04          	mov    %eax,0x4(%esp)
  802428:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80242f:	e8 f5 e9 ff ff       	call   800e29 <sys_page_alloc>
  802434:	85 c0                	test   %eax,%eax
  802436:	78 1d                	js     802455 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802438:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80243e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802441:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802443:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802446:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80244d:	89 04 24             	mov    %eax,(%esp)
  802450:	e8 87 f1 ff ff       	call   8015dc <fd2num>
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
  802468:	e8 7e e9 ff ff       	call   800deb <sys_getenvid>
  80246d:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80246f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802476:	00 
  802477:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80247e:	ee 
  80247f:	89 04 24             	mov    %eax,(%esp)
  802482:	e8 a2 e9 ff ff       	call   800e29 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  802487:	85 c0                	test   %eax,%eax
  802489:	79 1c                	jns    8024a7 <set_pgfault_handler+0x4f>
  80248b:	c7 44 24 08 b4 2e 80 	movl   $0x802eb4,0x8(%esp)
  802492:	00 
  802493:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80249a:	00 
  80249b:	c7 04 24 10 2f 80 00 	movl   $0x802f10,(%esp)
  8024a2:	e8 ed de ff ff       	call   800394 <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8024a7:	c7 44 24 04 e8 24 80 	movl   $0x8024e8,0x4(%esp)
  8024ae:	00 
  8024af:	89 1c 24             	mov    %ebx,(%esp)
  8024b2:	e8 12 eb ff ff       	call   800fc9 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  8024b7:	85 c0                	test   %eax,%eax
  8024b9:	79 1c                	jns    8024d7 <set_pgfault_handler+0x7f>
  8024bb:	c7 44 24 08 dc 2e 80 	movl   $0x802edc,0x8(%esp)
  8024c2:	00 
  8024c3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  8024ca:	00 
  8024cb:	c7 04 24 10 2f 80 00 	movl   $0x802f10,(%esp)
  8024d2:	e8 bd de ff ff       	call   800394 <_panic>
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

00802510 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	56                   	push   %esi
  802514:	53                   	push   %ebx
  802515:	83 ec 10             	sub    $0x10,%esp
  802518:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80251b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80251e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  802521:	85 c0                	test   %eax,%eax
  802523:	75 05                	jne    80252a <ipc_recv+0x1a>
  802525:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  80252a:	89 04 24             	mov    %eax,(%esp)
  80252d:	e8 0d eb ff ff       	call   80103f <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  802532:	85 c0                	test   %eax,%eax
  802534:	79 16                	jns    80254c <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  802536:	85 db                	test   %ebx,%ebx
  802538:	74 06                	je     802540 <ipc_recv+0x30>
  80253a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  802540:	85 f6                	test   %esi,%esi
  802542:	74 32                	je     802576 <ipc_recv+0x66>
  802544:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80254a:	eb 2a                	jmp    802576 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80254c:	85 db                	test   %ebx,%ebx
  80254e:	74 0c                	je     80255c <ipc_recv+0x4c>
  802550:	a1 04 40 80 00       	mov    0x804004,%eax
  802555:	8b 00                	mov    (%eax),%eax
  802557:	8b 40 74             	mov    0x74(%eax),%eax
  80255a:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80255c:	85 f6                	test   %esi,%esi
  80255e:	74 0c                	je     80256c <ipc_recv+0x5c>
  802560:	a1 04 40 80 00       	mov    0x804004,%eax
  802565:	8b 00                	mov    (%eax),%eax
  802567:	8b 40 78             	mov    0x78(%eax),%eax
  80256a:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  80256c:	a1 04 40 80 00       	mov    0x804004,%eax
  802571:	8b 00                	mov    (%eax),%eax
  802573:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  802576:	83 c4 10             	add    $0x10,%esp
  802579:	5b                   	pop    %ebx
  80257a:	5e                   	pop    %esi
  80257b:	5d                   	pop    %ebp
  80257c:	c3                   	ret    

0080257d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80257d:	55                   	push   %ebp
  80257e:	89 e5                	mov    %esp,%ebp
  802580:	57                   	push   %edi
  802581:	56                   	push   %esi
  802582:	53                   	push   %ebx
  802583:	83 ec 1c             	sub    $0x1c,%esp
  802586:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802589:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80258c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80258f:	85 db                	test   %ebx,%ebx
  802591:	75 05                	jne    802598 <ipc_send+0x1b>
  802593:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  802598:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80259c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a7:	89 04 24             	mov    %eax,(%esp)
  8025aa:	e8 6d ea ff ff       	call   80101c <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8025af:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025b2:	75 07                	jne    8025bb <ipc_send+0x3e>
  8025b4:	e8 51 e8 ff ff       	call   800e0a <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8025b9:	eb dd                	jmp    802598 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8025bb:	85 c0                	test   %eax,%eax
  8025bd:	79 1c                	jns    8025db <ipc_send+0x5e>
  8025bf:	c7 44 24 08 1e 2f 80 	movl   $0x802f1e,0x8(%esp)
  8025c6:	00 
  8025c7:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8025ce:	00 
  8025cf:	c7 04 24 30 2f 80 00 	movl   $0x802f30,(%esp)
  8025d6:	e8 b9 dd ff ff       	call   800394 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  8025db:	83 c4 1c             	add    $0x1c,%esp
  8025de:	5b                   	pop    %ebx
  8025df:	5e                   	pop    %esi
  8025e0:	5f                   	pop    %edi
  8025e1:	5d                   	pop    %ebp
  8025e2:	c3                   	ret    

008025e3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025e3:	55                   	push   %ebp
  8025e4:	89 e5                	mov    %esp,%ebp
  8025e6:	53                   	push   %ebx
  8025e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8025ea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025ef:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8025f6:	89 c2                	mov    %eax,%edx
  8025f8:	c1 e2 07             	shl    $0x7,%edx
  8025fb:	29 ca                	sub    %ecx,%edx
  8025fd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802603:	8b 52 50             	mov    0x50(%edx),%edx
  802606:	39 da                	cmp    %ebx,%edx
  802608:	75 0f                	jne    802619 <ipc_find_env+0x36>
			return envs[i].env_id;
  80260a:	c1 e0 07             	shl    $0x7,%eax
  80260d:	29 c8                	sub    %ecx,%eax
  80260f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802614:	8b 40 40             	mov    0x40(%eax),%eax
  802617:	eb 0c                	jmp    802625 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802619:	40                   	inc    %eax
  80261a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80261f:	75 ce                	jne    8025ef <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802621:	66 b8 00 00          	mov    $0x0,%ax
}
  802625:	5b                   	pop    %ebx
  802626:	5d                   	pop    %ebp
  802627:	c3                   	ret    

00802628 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802628:	55                   	push   %ebp
  802629:	89 e5                	mov    %esp,%ebp
  80262b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  80262e:	89 c2                	mov    %eax,%edx
  802630:	c1 ea 16             	shr    $0x16,%edx
  802633:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80263a:	f6 c2 01             	test   $0x1,%dl
  80263d:	74 1e                	je     80265d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80263f:	c1 e8 0c             	shr    $0xc,%eax
  802642:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802649:	a8 01                	test   $0x1,%al
  80264b:	74 17                	je     802664 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80264d:	c1 e8 0c             	shr    $0xc,%eax
  802650:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802657:	ef 
  802658:	0f b7 c0             	movzwl %ax,%eax
  80265b:	eb 0c                	jmp    802669 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80265d:	b8 00 00 00 00       	mov    $0x0,%eax
  802662:	eb 05                	jmp    802669 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802664:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802669:	5d                   	pop    %ebp
  80266a:	c3                   	ret    
	...

0080266c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80266c:	55                   	push   %ebp
  80266d:	57                   	push   %edi
  80266e:	56                   	push   %esi
  80266f:	83 ec 10             	sub    $0x10,%esp
  802672:	8b 74 24 20          	mov    0x20(%esp),%esi
  802676:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80267a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80267e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802682:	89 cd                	mov    %ecx,%ebp
  802684:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802688:	85 c0                	test   %eax,%eax
  80268a:	75 2c                	jne    8026b8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80268c:	39 f9                	cmp    %edi,%ecx
  80268e:	77 68                	ja     8026f8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802690:	85 c9                	test   %ecx,%ecx
  802692:	75 0b                	jne    80269f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802694:	b8 01 00 00 00       	mov    $0x1,%eax
  802699:	31 d2                	xor    %edx,%edx
  80269b:	f7 f1                	div    %ecx
  80269d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80269f:	31 d2                	xor    %edx,%edx
  8026a1:	89 f8                	mov    %edi,%eax
  8026a3:	f7 f1                	div    %ecx
  8026a5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026a7:	89 f0                	mov    %esi,%eax
  8026a9:	f7 f1                	div    %ecx
  8026ab:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026ad:	89 f0                	mov    %esi,%eax
  8026af:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026b1:	83 c4 10             	add    $0x10,%esp
  8026b4:	5e                   	pop    %esi
  8026b5:	5f                   	pop    %edi
  8026b6:	5d                   	pop    %ebp
  8026b7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8026b8:	39 f8                	cmp    %edi,%eax
  8026ba:	77 2c                	ja     8026e8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8026bc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8026bf:	83 f6 1f             	xor    $0x1f,%esi
  8026c2:	75 4c                	jne    802710 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026c4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8026c6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026cb:	72 0a                	jb     8026d7 <__udivdi3+0x6b>
  8026cd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8026d1:	0f 87 ad 00 00 00    	ja     802784 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8026d7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026dc:	89 f0                	mov    %esi,%eax
  8026de:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026e0:	83 c4 10             	add    $0x10,%esp
  8026e3:	5e                   	pop    %esi
  8026e4:	5f                   	pop    %edi
  8026e5:	5d                   	pop    %ebp
  8026e6:	c3                   	ret    
  8026e7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8026e8:	31 ff                	xor    %edi,%edi
  8026ea:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026ec:	89 f0                	mov    %esi,%eax
  8026ee:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026f0:	83 c4 10             	add    $0x10,%esp
  8026f3:	5e                   	pop    %esi
  8026f4:	5f                   	pop    %edi
  8026f5:	5d                   	pop    %ebp
  8026f6:	c3                   	ret    
  8026f7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026f8:	89 fa                	mov    %edi,%edx
  8026fa:	89 f0                	mov    %esi,%eax
  8026fc:	f7 f1                	div    %ecx
  8026fe:	89 c6                	mov    %eax,%esi
  802700:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802702:	89 f0                	mov    %esi,%eax
  802704:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802706:	83 c4 10             	add    $0x10,%esp
  802709:	5e                   	pop    %esi
  80270a:	5f                   	pop    %edi
  80270b:	5d                   	pop    %ebp
  80270c:	c3                   	ret    
  80270d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802710:	89 f1                	mov    %esi,%ecx
  802712:	d3 e0                	shl    %cl,%eax
  802714:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802718:	b8 20 00 00 00       	mov    $0x20,%eax
  80271d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80271f:	89 ea                	mov    %ebp,%edx
  802721:	88 c1                	mov    %al,%cl
  802723:	d3 ea                	shr    %cl,%edx
  802725:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802729:	09 ca                	or     %ecx,%edx
  80272b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80272f:	89 f1                	mov    %esi,%ecx
  802731:	d3 e5                	shl    %cl,%ebp
  802733:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802737:	89 fd                	mov    %edi,%ebp
  802739:	88 c1                	mov    %al,%cl
  80273b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80273d:	89 fa                	mov    %edi,%edx
  80273f:	89 f1                	mov    %esi,%ecx
  802741:	d3 e2                	shl    %cl,%edx
  802743:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802747:	88 c1                	mov    %al,%cl
  802749:	d3 ef                	shr    %cl,%edi
  80274b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80274d:	89 f8                	mov    %edi,%eax
  80274f:	89 ea                	mov    %ebp,%edx
  802751:	f7 74 24 08          	divl   0x8(%esp)
  802755:	89 d1                	mov    %edx,%ecx
  802757:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802759:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80275d:	39 d1                	cmp    %edx,%ecx
  80275f:	72 17                	jb     802778 <__udivdi3+0x10c>
  802761:	74 09                	je     80276c <__udivdi3+0x100>
  802763:	89 fe                	mov    %edi,%esi
  802765:	31 ff                	xor    %edi,%edi
  802767:	e9 41 ff ff ff       	jmp    8026ad <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80276c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802770:	89 f1                	mov    %esi,%ecx
  802772:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802774:	39 c2                	cmp    %eax,%edx
  802776:	73 eb                	jae    802763 <__udivdi3+0xf7>
		{
		  q0--;
  802778:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80277b:	31 ff                	xor    %edi,%edi
  80277d:	e9 2b ff ff ff       	jmp    8026ad <__udivdi3+0x41>
  802782:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802784:	31 f6                	xor    %esi,%esi
  802786:	e9 22 ff ff ff       	jmp    8026ad <__udivdi3+0x41>
	...

0080278c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80278c:	55                   	push   %ebp
  80278d:	57                   	push   %edi
  80278e:	56                   	push   %esi
  80278f:	83 ec 20             	sub    $0x20,%esp
  802792:	8b 44 24 30          	mov    0x30(%esp),%eax
  802796:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80279a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80279e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8027a2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027a6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8027aa:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8027ac:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8027ae:	85 ed                	test   %ebp,%ebp
  8027b0:	75 16                	jne    8027c8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8027b2:	39 f1                	cmp    %esi,%ecx
  8027b4:	0f 86 a6 00 00 00    	jbe    802860 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027ba:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8027bc:	89 d0                	mov    %edx,%eax
  8027be:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027c0:	83 c4 20             	add    $0x20,%esp
  8027c3:	5e                   	pop    %esi
  8027c4:	5f                   	pop    %edi
  8027c5:	5d                   	pop    %ebp
  8027c6:	c3                   	ret    
  8027c7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027c8:	39 f5                	cmp    %esi,%ebp
  8027ca:	0f 87 ac 00 00 00    	ja     80287c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8027d0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8027d3:	83 f0 1f             	xor    $0x1f,%eax
  8027d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8027da:	0f 84 a8 00 00 00    	je     802888 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027e0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8027e4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027e6:	bf 20 00 00 00       	mov    $0x20,%edi
  8027eb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8027ef:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8027f3:	89 f9                	mov    %edi,%ecx
  8027f5:	d3 e8                	shr    %cl,%eax
  8027f7:	09 e8                	or     %ebp,%eax
  8027f9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8027fd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802801:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802805:	d3 e0                	shl    %cl,%eax
  802807:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80280b:	89 f2                	mov    %esi,%edx
  80280d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80280f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802813:	d3 e0                	shl    %cl,%eax
  802815:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802819:	8b 44 24 14          	mov    0x14(%esp),%eax
  80281d:	89 f9                	mov    %edi,%ecx
  80281f:	d3 e8                	shr    %cl,%eax
  802821:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802823:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802825:	89 f2                	mov    %esi,%edx
  802827:	f7 74 24 18          	divl   0x18(%esp)
  80282b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80282d:	f7 64 24 0c          	mull   0xc(%esp)
  802831:	89 c5                	mov    %eax,%ebp
  802833:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802835:	39 d6                	cmp    %edx,%esi
  802837:	72 67                	jb     8028a0 <__umoddi3+0x114>
  802839:	74 75                	je     8028b0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80283b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80283f:	29 e8                	sub    %ebp,%eax
  802841:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802843:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802847:	d3 e8                	shr    %cl,%eax
  802849:	89 f2                	mov    %esi,%edx
  80284b:	89 f9                	mov    %edi,%ecx
  80284d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80284f:	09 d0                	or     %edx,%eax
  802851:	89 f2                	mov    %esi,%edx
  802853:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802857:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802859:	83 c4 20             	add    $0x20,%esp
  80285c:	5e                   	pop    %esi
  80285d:	5f                   	pop    %edi
  80285e:	5d                   	pop    %ebp
  80285f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802860:	85 c9                	test   %ecx,%ecx
  802862:	75 0b                	jne    80286f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802864:	b8 01 00 00 00       	mov    $0x1,%eax
  802869:	31 d2                	xor    %edx,%edx
  80286b:	f7 f1                	div    %ecx
  80286d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80286f:	89 f0                	mov    %esi,%eax
  802871:	31 d2                	xor    %edx,%edx
  802873:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802875:	89 f8                	mov    %edi,%eax
  802877:	e9 3e ff ff ff       	jmp    8027ba <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80287c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80287e:	83 c4 20             	add    $0x20,%esp
  802881:	5e                   	pop    %esi
  802882:	5f                   	pop    %edi
  802883:	5d                   	pop    %ebp
  802884:	c3                   	ret    
  802885:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802888:	39 f5                	cmp    %esi,%ebp
  80288a:	72 04                	jb     802890 <__umoddi3+0x104>
  80288c:	39 f9                	cmp    %edi,%ecx
  80288e:	77 06                	ja     802896 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802890:	89 f2                	mov    %esi,%edx
  802892:	29 cf                	sub    %ecx,%edi
  802894:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802896:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802898:	83 c4 20             	add    $0x20,%esp
  80289b:	5e                   	pop    %esi
  80289c:	5f                   	pop    %edi
  80289d:	5d                   	pop    %ebp
  80289e:	c3                   	ret    
  80289f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8028a0:	89 d1                	mov    %edx,%ecx
  8028a2:	89 c5                	mov    %eax,%ebp
  8028a4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8028a8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8028ac:	eb 8d                	jmp    80283b <__umoddi3+0xaf>
  8028ae:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028b0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8028b4:	72 ea                	jb     8028a0 <__umoddi3+0x114>
  8028b6:	89 f1                	mov    %esi,%ecx
  8028b8:	eb 81                	jmp    80283b <__umoddi3+0xaf>
