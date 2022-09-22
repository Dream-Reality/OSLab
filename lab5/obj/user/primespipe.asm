
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 97 02 00 00       	call   8002c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800040:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800043:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800046:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80004d:	00 
  80004e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800052:	89 1c 24             	mov    %ebx,(%esp)
  800055:	e8 d8 18 00 00       	call   801932 <readn>
  80005a:	83 f8 04             	cmp    $0x4,%eax
  80005d:	74 30                	je     80008f <primeproc+0x5b>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005f:	85 c0                	test   %eax,%eax
  800061:	0f 9e c2             	setle  %dl
  800064:	0f b6 d2             	movzbl %dl,%edx
  800067:	f7 da                	neg    %edx
  800069:	21 c2                	and    %eax,%edx
  80006b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80006f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800073:	c7 44 24 08 00 28 80 	movl   $0x802800,0x8(%esp)
  80007a:	00 
  80007b:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800082:	00 
  800083:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  80008a:	e8 ad 02 00 00       	call   80033c <_panic>

	cprintf("%d\n", p);
  80008f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800092:	89 44 24 04          	mov    %eax,0x4(%esp)
  800096:	c7 04 24 41 28 80 00 	movl   $0x802841,(%esp)
  80009d:	e8 92 03 00 00       	call   800434 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  8000a2:	89 3c 24             	mov    %edi,(%esp)
  8000a5:	e8 a7 1f 00 00       	call   802051 <pipe>
  8000aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	79 20                	jns    8000d1 <primeproc+0x9d>
		panic("pipe: %e", i);
  8000b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b5:	c7 44 24 08 45 28 80 	movl   $0x802845,0x8(%esp)
  8000bc:	00 
  8000bd:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c4:	00 
  8000c5:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  8000cc:	e8 6b 02 00 00       	call   80033c <_panic>
	if ((id = fork()) < 0)
  8000d1:	e8 9e 11 00 00       	call   801274 <fork>
  8000d6:	85 c0                	test   %eax,%eax
  8000d8:	79 20                	jns    8000fa <primeproc+0xc6>
		panic("fork: %e", id);
  8000da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000de:	c7 44 24 08 4e 28 80 	movl   $0x80284e,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  8000f5:	e8 42 02 00 00       	call   80033c <_panic>
	if (id == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1b                	jne    800119 <primeproc+0xe5>
		close(fd);
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	e8 36 16 00 00       	call   80173c <close>
		close(pfd[1]);
  800106:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 2b 16 00 00       	call   80173c <close>
		fd = pfd[0];
  800111:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800114:	e9 2d ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  800119:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 18 16 00 00       	call   80173c <close>
	wfd = pfd[1];
  800124:	8b 7d dc             	mov    -0x24(%ebp),%edi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800127:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80012a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800131:	00 
  800132:	89 74 24 04          	mov    %esi,0x4(%esp)
  800136:	89 1c 24             	mov    %ebx,(%esp)
  800139:	e8 f4 17 00 00       	call   801932 <readn>
  80013e:	83 f8 04             	cmp    $0x4,%eax
  800141:	74 3b                	je     80017e <primeproc+0x14a>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800143:	85 c0                	test   %eax,%eax
  800145:	0f 9e c2             	setle  %dl
  800148:	0f b6 d2             	movzbl %dl,%edx
  80014b:	f7 da                	neg    %edx
  80014d:	21 c2                	and    %eax,%edx
  80014f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800153:	89 44 24 14          	mov    %eax,0x14(%esp)
  800157:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 57 28 80 	movl   $0x802857,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  800179:	e8 be 01 00 00       	call   80033c <_panic>
		if (i%p)
  80017e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800181:	99                   	cltd   
  800182:	f7 7d e0             	idivl  -0x20(%ebp)
  800185:	85 d2                	test   %edx,%edx
  800187:	74 a1                	je     80012a <primeproc+0xf6>
			if ((r=write(wfd, &i, 4)) != 4)
  800189:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800190:	00 
  800191:	89 74 24 04          	mov    %esi,0x4(%esp)
  800195:	89 3c 24             	mov    %edi,(%esp)
  800198:	e8 e0 17 00 00       	call   80197d <write>
  80019d:	83 f8 04             	cmp    $0x4,%eax
  8001a0:	74 88                	je     80012a <primeproc+0xf6>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	0f 9e c2             	setle  %dl
  8001a7:	0f b6 d2             	movzbl %dl,%edx
  8001aa:	f7 da                	neg    %edx
  8001ac:	21 c2                	and    %eax,%edx
  8001ae:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bd:	c7 44 24 08 73 28 80 	movl   $0x802873,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  8001d4:	e8 63 01 00 00       	call   80033c <_panic>

008001d9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 34             	sub    $0x34,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  8001e0:	c7 05 00 30 80 00 8d 	movl   $0x80288d,0x803000
  8001e7:	28 80 00 

	if ((i=pipe(p)) < 0)
  8001ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	e8 5c 1e 00 00       	call   802051 <pipe>
  8001f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	79 20                	jns    80021c <umain+0x43>
		panic("pipe: %e", i);
  8001fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800200:	c7 44 24 08 45 28 80 	movl   $0x802845,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  800217:	e8 20 01 00 00       	call   80033c <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80021c:	e8 53 10 00 00       	call   801274 <fork>
  800221:	85 c0                	test   %eax,%eax
  800223:	79 20                	jns    800245 <umain+0x6c>
		panic("fork: %e", id);
  800225:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800229:	c7 44 24 08 4e 28 80 	movl   $0x80284e,0x8(%esp)
  800230:	00 
  800231:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  800240:	e8 f7 00 00 00       	call   80033c <_panic>

	if (id == 0) {
  800245:	85 c0                	test   %eax,%eax
  800247:	75 16                	jne    80025f <umain+0x86>
		close(p[1]);
  800249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 e8 14 00 00       	call   80173c <close>
		primeproc(p[0]);
  800254:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 d5 fd ff ff       	call   800034 <primeproc>
	}

	close(p[0]);
  80025f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	e8 d2 14 00 00       	call   80173c <close>

	// feed all the integers through
	for (i=2;; i++)
  80026a:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800271:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800274:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80027b:	00 
  80027c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800280:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 f2 16 00 00       	call   80197d <write>
  80028b:	83 f8 04             	cmp    $0x4,%eax
  80028e:	74 30                	je     8002c0 <umain+0xe7>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800290:	85 c0                	test   %eax,%eax
  800292:	0f 9e c2             	setle  %dl
  800295:	0f b6 d2             	movzbl %dl,%edx
  800298:	f7 da                	neg    %edx
  80029a:	21 c2                	and    %eax,%edx
  80029c:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a4:	c7 44 24 08 98 28 80 	movl   $0x802898,0x8(%esp)
  8002ab:	00 
  8002ac:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002b3:	00 
  8002b4:	c7 04 24 2f 28 80 00 	movl   $0x80282f,(%esp)
  8002bb:	e8 7c 00 00 00       	call   80033c <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  8002c0:	ff 45 f4             	incl   -0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  8002c3:	eb af                	jmp    800274 <umain+0x9b>
  8002c5:	00 00                	add    %al,(%eax)
	...

008002c8 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	83 ec 20             	sub    $0x20,%esp
  8002d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  8002d6:	e8 b8 0a 00 00       	call   800d93 <sys_getenvid>
  8002db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002e7:	c1 e0 07             	shl    $0x7,%eax
  8002ea:	29 d0                	sub    %edx,%eax
  8002ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  8002f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8002f7:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002fc:	85 f6                	test   %esi,%esi
  8002fe:	7e 07                	jle    800307 <libmain+0x3f>
		binaryname = argv[0];
  800300:	8b 03                	mov    (%ebx),%eax
  800302:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800307:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80030b:	89 34 24             	mov    %esi,(%esp)
  80030e:	e8 c6 fe ff ff       	call   8001d9 <umain>

	// exit gracefully
	exit();
  800313:	e8 08 00 00 00       	call   800320 <exit>
}
  800318:	83 c4 20             	add    $0x20,%esp
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    
	...

00800320 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800326:	e8 42 14 00 00       	call   80176d <close_all>
	sys_env_destroy(0);
  80032b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800332:	e8 0a 0a 00 00       	call   800d41 <sys_env_destroy>
}
  800337:	c9                   	leave  
  800338:	c3                   	ret    
  800339:	00 00                	add    %al,(%eax)
	...

0080033c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
  800341:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800344:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800347:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80034d:	e8 41 0a 00 00       	call   800d93 <sys_getenvid>
  800352:	8b 55 0c             	mov    0xc(%ebp),%edx
  800355:	89 54 24 10          	mov    %edx,0x10(%esp)
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800360:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800364:	89 44 24 04          	mov    %eax,0x4(%esp)
  800368:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  80036f:	e8 c0 00 00 00       	call   800434 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800374:	89 74 24 04          	mov    %esi,0x4(%esp)
  800378:	8b 45 10             	mov    0x10(%ebp),%eax
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	e8 50 00 00 00       	call   8003d3 <vcprintf>
	cprintf("\n");
  800383:	c7 04 24 50 2c 80 00 	movl   $0x802c50,(%esp)
  80038a:	e8 a5 00 00 00       	call   800434 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038f:	cc                   	int3   
  800390:	eb fd                	jmp    80038f <_panic+0x53>
	...

00800394 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	53                   	push   %ebx
  800398:	83 ec 14             	sub    $0x14,%esp
  80039b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039e:	8b 03                	mov    (%ebx),%eax
  8003a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003a7:	40                   	inc    %eax
  8003a8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003af:	75 19                	jne    8003ca <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003b1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003b8:	00 
  8003b9:	8d 43 08             	lea    0x8(%ebx),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 40 09 00 00       	call   800d04 <sys_cputs>
		b->idx = 0;
  8003c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003ca:	ff 43 04             	incl   0x4(%ebx)
}
  8003cd:	83 c4 14             	add    $0x14,%esp
  8003d0:	5b                   	pop    %ebx
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e3:	00 00 00 
	b.cnt = 0;
  8003e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800404:	89 44 24 04          	mov    %eax,0x4(%esp)
  800408:	c7 04 24 94 03 80 00 	movl   $0x800394,(%esp)
  80040f:	e8 82 01 00 00       	call   800596 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800414:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80041a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	e8 d8 08 00 00       	call   800d04 <sys_cputs>

	return b.cnt;
}
  80042c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80043d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	e8 87 ff ff ff       	call   8003d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80044c:	c9                   	leave  
  80044d:	c3                   	ret    
	...

00800450 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	57                   	push   %edi
  800454:	56                   	push   %esi
  800455:	53                   	push   %ebx
  800456:	83 ec 3c             	sub    $0x3c,%esp
  800459:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045c:	89 d7                	mov    %edx,%edi
  80045e:	8b 45 08             	mov    0x8(%ebp),%eax
  800461:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800464:	8b 45 0c             	mov    0xc(%ebp),%eax
  800467:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80046d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800470:	85 c0                	test   %eax,%eax
  800472:	75 08                	jne    80047c <printnum+0x2c>
  800474:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800477:	39 45 10             	cmp    %eax,0x10(%ebp)
  80047a:	77 57                	ja     8004d3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80047c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800480:	4b                   	dec    %ebx
  800481:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800485:	8b 45 10             	mov    0x10(%ebp),%eax
  800488:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800490:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800494:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80049b:	00 
  80049c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a9:	e8 fa 20 00 00       	call   8025a8 <__udivdi3>
  8004ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004b2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004b6:	89 04 24             	mov    %eax,(%esp)
  8004b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004bd:	89 fa                	mov    %edi,%edx
  8004bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004c2:	e8 89 ff ff ff       	call   800450 <printnum>
  8004c7:	eb 0f                	jmp    8004d8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cd:	89 34 24             	mov    %esi,(%esp)
  8004d0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004d3:	4b                   	dec    %ebx
  8004d4:	85 db                	test   %ebx,%ebx
  8004d6:	7f f1                	jg     8004c9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004dc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ee:	00 
  8004ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f2:	89 04 24             	mov    %eax,(%esp)
  8004f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fc:	e8 c7 21 00 00       	call   8026c8 <__umoddi3>
  800501:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800505:	0f be 80 df 28 80 00 	movsbl 0x8028df(%eax),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800512:	83 c4 3c             	add    $0x3c,%esp
  800515:	5b                   	pop    %ebx
  800516:	5e                   	pop    %esi
  800517:	5f                   	pop    %edi
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80051d:	83 fa 01             	cmp    $0x1,%edx
  800520:	7e 0e                	jle    800530 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800522:	8b 10                	mov    (%eax),%edx
  800524:	8d 4a 08             	lea    0x8(%edx),%ecx
  800527:	89 08                	mov    %ecx,(%eax)
  800529:	8b 02                	mov    (%edx),%eax
  80052b:	8b 52 04             	mov    0x4(%edx),%edx
  80052e:	eb 22                	jmp    800552 <getuint+0x38>
	else if (lflag)
  800530:	85 d2                	test   %edx,%edx
  800532:	74 10                	je     800544 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800534:	8b 10                	mov    (%eax),%edx
  800536:	8d 4a 04             	lea    0x4(%edx),%ecx
  800539:	89 08                	mov    %ecx,(%eax)
  80053b:	8b 02                	mov    (%edx),%eax
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
  800542:	eb 0e                	jmp    800552 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800544:	8b 10                	mov    (%eax),%edx
  800546:	8d 4a 04             	lea    0x4(%edx),%ecx
  800549:	89 08                	mov    %ecx,(%eax)
  80054b:	8b 02                	mov    (%edx),%eax
  80054d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800552:	5d                   	pop    %ebp
  800553:	c3                   	ret    

00800554 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80055a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80055d:	8b 10                	mov    (%eax),%edx
  80055f:	3b 50 04             	cmp    0x4(%eax),%edx
  800562:	73 08                	jae    80056c <sprintputch+0x18>
		*b->buf++ = ch;
  800564:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800567:	88 0a                	mov    %cl,(%edx)
  800569:	42                   	inc    %edx
  80056a:	89 10                	mov    %edx,(%eax)
}
  80056c:	5d                   	pop    %ebp
  80056d:	c3                   	ret    

0080056e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800574:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800577:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057b:	8b 45 10             	mov    0x10(%ebp),%eax
  80057e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800582:	8b 45 0c             	mov    0xc(%ebp),%eax
  800585:	89 44 24 04          	mov    %eax,0x4(%esp)
  800589:	8b 45 08             	mov    0x8(%ebp),%eax
  80058c:	89 04 24             	mov    %eax,(%esp)
  80058f:	e8 02 00 00 00       	call   800596 <vprintfmt>
	va_end(ap);
}
  800594:	c9                   	leave  
  800595:	c3                   	ret    

00800596 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800596:	55                   	push   %ebp
  800597:	89 e5                	mov    %esp,%ebp
  800599:	57                   	push   %edi
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	83 ec 4c             	sub    $0x4c,%esp
  80059f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a2:	8b 75 10             	mov    0x10(%ebp),%esi
  8005a5:	eb 12                	jmp    8005b9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	0f 84 6b 03 00 00    	je     80091a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b3:	89 04 24             	mov    %eax,(%esp)
  8005b6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b9:	0f b6 06             	movzbl (%esi),%eax
  8005bc:	46                   	inc    %esi
  8005bd:	83 f8 25             	cmp    $0x25,%eax
  8005c0:	75 e5                	jne    8005a7 <vprintfmt+0x11>
  8005c2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005c6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005cd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005d2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005de:	eb 26                	jmp    800606 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005e3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005e7:	eb 1d                	jmp    800606 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ec:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005f0:	eb 14                	jmp    800606 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005f5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005fc:	eb 08                	jmp    800606 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005fe:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800601:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	0f b6 06             	movzbl (%esi),%eax
  800609:	8d 56 01             	lea    0x1(%esi),%edx
  80060c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80060f:	8a 16                	mov    (%esi),%dl
  800611:	83 ea 23             	sub    $0x23,%edx
  800614:	80 fa 55             	cmp    $0x55,%dl
  800617:	0f 87 e1 02 00 00    	ja     8008fe <vprintfmt+0x368>
  80061d:	0f b6 d2             	movzbl %dl,%edx
  800620:	ff 24 95 20 2a 80 00 	jmp    *0x802a20(,%edx,4)
  800627:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80062a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80062f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800632:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800636:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800639:	8d 50 d0             	lea    -0x30(%eax),%edx
  80063c:	83 fa 09             	cmp    $0x9,%edx
  80063f:	77 2a                	ja     80066b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800641:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800642:	eb eb                	jmp    80062f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800652:	eb 17                	jmp    80066b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800654:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800658:	78 98                	js     8005f2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80065d:	eb a7                	jmp    800606 <vprintfmt+0x70>
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800662:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800669:	eb 9b                	jmp    800606 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80066b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066f:	79 95                	jns    800606 <vprintfmt+0x70>
  800671:	eb 8b                	jmp    8005fe <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800673:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800674:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800677:	eb 8d                	jmp    800606 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 50 04             	lea    0x4(%eax),%edx
  80067f:	89 55 14             	mov    %edx,0x14(%ebp)
  800682:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800686:	8b 00                	mov    (%eax),%eax
  800688:	89 04 24             	mov    %eax,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800691:	e9 23 ff ff ff       	jmp    8005b9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)
  80069f:	8b 00                	mov    (%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	79 02                	jns    8006a7 <vprintfmt+0x111>
  8006a5:	f7 d8                	neg    %eax
  8006a7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a9:	83 f8 0f             	cmp    $0xf,%eax
  8006ac:	7f 0b                	jg     8006b9 <vprintfmt+0x123>
  8006ae:	8b 04 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%eax
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	75 23                	jne    8006dc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006bd:	c7 44 24 08 f7 28 80 	movl   $0x8028f7,0x8(%esp)
  8006c4:	00 
  8006c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	89 04 24             	mov    %eax,(%esp)
  8006cf:	e8 9a fe ff ff       	call   80056e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006d7:	e9 dd fe ff ff       	jmp    8005b9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e0:	c7 44 24 08 f9 2c 80 	movl   $0x802cf9,0x8(%esp)
  8006e7:	00 
  8006e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ef:	89 14 24             	mov    %edx,(%esp)
  8006f2:	e8 77 fe ff ff       	call   80056e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006fa:	e9 ba fe ff ff       	jmp    8005b9 <vprintfmt+0x23>
  8006ff:	89 f9                	mov    %edi,%ecx
  800701:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800704:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 50 04             	lea    0x4(%eax),%edx
  80070d:	89 55 14             	mov    %edx,0x14(%ebp)
  800710:	8b 30                	mov    (%eax),%esi
  800712:	85 f6                	test   %esi,%esi
  800714:	75 05                	jne    80071b <vprintfmt+0x185>
				p = "(null)";
  800716:	be f0 28 80 00       	mov    $0x8028f0,%esi
			if (width > 0 && padc != '-')
  80071b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80071f:	0f 8e 84 00 00 00    	jle    8007a9 <vprintfmt+0x213>
  800725:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800729:	74 7e                	je     8007a9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80072b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80072f:	89 34 24             	mov    %esi,(%esp)
  800732:	e8 8b 02 00 00       	call   8009c2 <strnlen>
  800737:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80073a:	29 c2                	sub    %eax,%edx
  80073c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80073f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800743:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800746:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800749:	89 de                	mov    %ebx,%esi
  80074b:	89 d3                	mov    %edx,%ebx
  80074d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074f:	eb 0b                	jmp    80075c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800751:	89 74 24 04          	mov    %esi,0x4(%esp)
  800755:	89 3c 24             	mov    %edi,(%esp)
  800758:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80075b:	4b                   	dec    %ebx
  80075c:	85 db                	test   %ebx,%ebx
  80075e:	7f f1                	jg     800751 <vprintfmt+0x1bb>
  800760:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800763:	89 f3                	mov    %esi,%ebx
  800765:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800768:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80076b:	85 c0                	test   %eax,%eax
  80076d:	79 05                	jns    800774 <vprintfmt+0x1de>
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
  800774:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800777:	29 c2                	sub    %eax,%edx
  800779:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80077c:	eb 2b                	jmp    8007a9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80077e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800782:	74 18                	je     80079c <vprintfmt+0x206>
  800784:	8d 50 e0             	lea    -0x20(%eax),%edx
  800787:	83 fa 5e             	cmp    $0x5e,%edx
  80078a:	76 10                	jbe    80079c <vprintfmt+0x206>
					putch('?', putdat);
  80078c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800790:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800797:	ff 55 08             	call   *0x8(%ebp)
  80079a:	eb 0a                	jmp    8007a6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	89 04 24             	mov    %eax,(%esp)
  8007a3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a6:	ff 4d e4             	decl   -0x1c(%ebp)
  8007a9:	0f be 06             	movsbl (%esi),%eax
  8007ac:	46                   	inc    %esi
  8007ad:	85 c0                	test   %eax,%eax
  8007af:	74 21                	je     8007d2 <vprintfmt+0x23c>
  8007b1:	85 ff                	test   %edi,%edi
  8007b3:	78 c9                	js     80077e <vprintfmt+0x1e8>
  8007b5:	4f                   	dec    %edi
  8007b6:	79 c6                	jns    80077e <vprintfmt+0x1e8>
  8007b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007bb:	89 de                	mov    %ebx,%esi
  8007bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007c0:	eb 18                	jmp    8007da <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007cd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007cf:	4b                   	dec    %ebx
  8007d0:	eb 08                	jmp    8007da <vprintfmt+0x244>
  8007d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d5:	89 de                	mov    %ebx,%esi
  8007d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007da:	85 db                	test   %ebx,%ebx
  8007dc:	7f e4                	jg     8007c2 <vprintfmt+0x22c>
  8007de:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007e1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007e6:	e9 ce fd ff ff       	jmp    8005b9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007eb:	83 f9 01             	cmp    $0x1,%ecx
  8007ee:	7e 10                	jle    800800 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8d 50 08             	lea    0x8(%eax),%edx
  8007f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f9:	8b 30                	mov    (%eax),%esi
  8007fb:	8b 78 04             	mov    0x4(%eax),%edi
  8007fe:	eb 26                	jmp    800826 <vprintfmt+0x290>
	else if (lflag)
  800800:	85 c9                	test   %ecx,%ecx
  800802:	74 12                	je     800816 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	8d 50 04             	lea    0x4(%eax),%edx
  80080a:	89 55 14             	mov    %edx,0x14(%ebp)
  80080d:	8b 30                	mov    (%eax),%esi
  80080f:	89 f7                	mov    %esi,%edi
  800811:	c1 ff 1f             	sar    $0x1f,%edi
  800814:	eb 10                	jmp    800826 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 30                	mov    (%eax),%esi
  800821:	89 f7                	mov    %esi,%edi
  800823:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800826:	85 ff                	test   %edi,%edi
  800828:	78 0a                	js     800834 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80082a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082f:	e9 8c 00 00 00       	jmp    8008c0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800834:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800838:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80083f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800842:	f7 de                	neg    %esi
  800844:	83 d7 00             	adc    $0x0,%edi
  800847:	f7 df                	neg    %edi
			}
			base = 10;
  800849:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084e:	eb 70                	jmp    8008c0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800850:	89 ca                	mov    %ecx,%edx
  800852:	8d 45 14             	lea    0x14(%ebp),%eax
  800855:	e8 c0 fc ff ff       	call   80051a <getuint>
  80085a:	89 c6                	mov    %eax,%esi
  80085c:	89 d7                	mov    %edx,%edi
			base = 10;
  80085e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800863:	eb 5b                	jmp    8008c0 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800865:	89 ca                	mov    %ecx,%edx
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
  80086a:	e8 ab fc ff ff       	call   80051a <getuint>
  80086f:	89 c6                	mov    %eax,%esi
  800871:	89 d7                	mov    %edx,%edi
			base = 8;
  800873:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800878:	eb 46                	jmp    8008c0 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80087a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800885:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800888:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800893:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800896:	8b 45 14             	mov    0x14(%ebp),%eax
  800899:	8d 50 04             	lea    0x4(%eax),%edx
  80089c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80089f:	8b 30                	mov    (%eax),%esi
  8008a1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ab:	eb 13                	jmp    8008c0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008ad:	89 ca                	mov    %ecx,%edx
  8008af:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b2:	e8 63 fc ff ff       	call   80051a <getuint>
  8008b7:	89 c6                	mov    %eax,%esi
  8008b9:	89 d7                	mov    %edx,%edi
			base = 16;
  8008bb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008c0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008c4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d3:	89 34 24             	mov    %esi,(%esp)
  8008d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008da:	89 da                	mov    %ebx,%edx
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	e8 6c fb ff ff       	call   800450 <printnum>
			break;
  8008e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008e7:	e9 cd fc ff ff       	jmp    8005b9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008f9:	e9 bb fc ff ff       	jmp    8005b9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800902:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800909:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090c:	eb 01                	jmp    80090f <vprintfmt+0x379>
  80090e:	4e                   	dec    %esi
  80090f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800913:	75 f9                	jne    80090e <vprintfmt+0x378>
  800915:	e9 9f fc ff ff       	jmp    8005b9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80091a:	83 c4 4c             	add    $0x4c,%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5f                   	pop    %edi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 28             	sub    $0x28,%esp
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800931:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800935:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800938:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093f:	85 c0                	test   %eax,%eax
  800941:	74 30                	je     800973 <vsnprintf+0x51>
  800943:	85 d2                	test   %edx,%edx
  800945:	7e 33                	jle    80097a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800947:	8b 45 14             	mov    0x14(%ebp),%eax
  80094a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80094e:	8b 45 10             	mov    0x10(%ebp),%eax
  800951:	89 44 24 08          	mov    %eax,0x8(%esp)
  800955:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800958:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095c:	c7 04 24 54 05 80 00 	movl   $0x800554,(%esp)
  800963:	e8 2e fc ff ff       	call   800596 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800968:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80096b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800971:	eb 0c                	jmp    80097f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800973:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800978:	eb 05                	jmp    80097f <vsnprintf+0x5d>
  80097a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800987:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80098a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098e:	8b 45 10             	mov    0x10(%ebp),%eax
  800991:	89 44 24 08          	mov    %eax,0x8(%esp)
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	e8 7b ff ff ff       	call   800922 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    
  8009a9:	00 00                	add    %al,(%eax)
	...

008009ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b7:	eb 01                	jmp    8009ba <strlen+0xe>
		n++;
  8009b9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009be:	75 f9                	jne    8009b9 <strlen+0xd>
		n++;
	return n;
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d0:	eb 01                	jmp    8009d3 <strnlen+0x11>
		n++;
  8009d2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d3:	39 d0                	cmp    %edx,%eax
  8009d5:	74 06                	je     8009dd <strnlen+0x1b>
  8009d7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009db:	75 f5                	jne    8009d2 <strnlen+0x10>
		n++;
	return n;
}
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	53                   	push   %ebx
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ee:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009f1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009f4:	42                   	inc    %edx
  8009f5:	84 c9                	test   %cl,%cl
  8009f7:	75 f5                	jne    8009ee <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	53                   	push   %ebx
  800a00:	83 ec 08             	sub    $0x8,%esp
  800a03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a06:	89 1c 24             	mov    %ebx,(%esp)
  800a09:	e8 9e ff ff ff       	call   8009ac <strlen>
	strcpy(dst + len, src);
  800a0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a11:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a15:	01 d8                	add    %ebx,%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 c0 ff ff ff       	call   8009df <strcpy>
	return dst;
}
  800a1f:	89 d8                	mov    %ebx,%eax
  800a21:	83 c4 08             	add    $0x8,%esp
  800a24:	5b                   	pop    %ebx
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a32:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a3a:	eb 0c                	jmp    800a48 <strncpy+0x21>
		*dst++ = *src;
  800a3c:	8a 1a                	mov    (%edx),%bl
  800a3e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a41:	80 3a 01             	cmpb   $0x1,(%edx)
  800a44:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a47:	41                   	inc    %ecx
  800a48:	39 f1                	cmp    %esi,%ecx
  800a4a:	75 f0                	jne    800a3c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 75 08             	mov    0x8(%ebp),%esi
  800a58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a5e:	85 d2                	test   %edx,%edx
  800a60:	75 0a                	jne    800a6c <strlcpy+0x1c>
  800a62:	89 f0                	mov    %esi,%eax
  800a64:	eb 1a                	jmp    800a80 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a66:	88 18                	mov    %bl,(%eax)
  800a68:	40                   	inc    %eax
  800a69:	41                   	inc    %ecx
  800a6a:	eb 02                	jmp    800a6e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a6c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800a6e:	4a                   	dec    %edx
  800a6f:	74 0a                	je     800a7b <strlcpy+0x2b>
  800a71:	8a 19                	mov    (%ecx),%bl
  800a73:	84 db                	test   %bl,%bl
  800a75:	75 ef                	jne    800a66 <strlcpy+0x16>
  800a77:	89 c2                	mov    %eax,%edx
  800a79:	eb 02                	jmp    800a7d <strlcpy+0x2d>
  800a7b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a7d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a80:	29 f0                	sub    %esi,%eax
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a8f:	eb 02                	jmp    800a93 <strcmp+0xd>
		p++, q++;
  800a91:	41                   	inc    %ecx
  800a92:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a93:	8a 01                	mov    (%ecx),%al
  800a95:	84 c0                	test   %al,%al
  800a97:	74 04                	je     800a9d <strcmp+0x17>
  800a99:	3a 02                	cmp    (%edx),%al
  800a9b:	74 f4                	je     800a91 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9d:	0f b6 c0             	movzbl %al,%eax
  800aa0:	0f b6 12             	movzbl (%edx),%edx
  800aa3:	29 d0                	sub    %edx,%eax
}
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800ab4:	eb 03                	jmp    800ab9 <strncmp+0x12>
		n--, p++, q++;
  800ab6:	4a                   	dec    %edx
  800ab7:	40                   	inc    %eax
  800ab8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab9:	85 d2                	test   %edx,%edx
  800abb:	74 14                	je     800ad1 <strncmp+0x2a>
  800abd:	8a 18                	mov    (%eax),%bl
  800abf:	84 db                	test   %bl,%bl
  800ac1:	74 04                	je     800ac7 <strncmp+0x20>
  800ac3:	3a 19                	cmp    (%ecx),%bl
  800ac5:	74 ef                	je     800ab6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac7:	0f b6 00             	movzbl (%eax),%eax
  800aca:	0f b6 11             	movzbl (%ecx),%edx
  800acd:	29 d0                	sub    %edx,%eax
  800acf:	eb 05                	jmp    800ad6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ae2:	eb 05                	jmp    800ae9 <strchr+0x10>
		if (*s == c)
  800ae4:	38 ca                	cmp    %cl,%dl
  800ae6:	74 0c                	je     800af4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae8:	40                   	inc    %eax
  800ae9:	8a 10                	mov    (%eax),%dl
  800aeb:	84 d2                	test   %dl,%dl
  800aed:	75 f5                	jne    800ae4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800aff:	eb 05                	jmp    800b06 <strfind+0x10>
		if (*s == c)
  800b01:	38 ca                	cmp    %cl,%dl
  800b03:	74 07                	je     800b0c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b05:	40                   	inc    %eax
  800b06:	8a 10                	mov    (%eax),%dl
  800b08:	84 d2                	test   %dl,%dl
  800b0a:	75 f5                	jne    800b01 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1d:	85 c9                	test   %ecx,%ecx
  800b1f:	74 30                	je     800b51 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b27:	75 25                	jne    800b4e <memset+0x40>
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	75 20                	jne    800b4e <memset+0x40>
		c &= 0xFF;
  800b2e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	c1 e3 08             	shl    $0x8,%ebx
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	c1 e6 18             	shl    $0x18,%esi
  800b3b:	89 d0                	mov    %edx,%eax
  800b3d:	c1 e0 10             	shl    $0x10,%eax
  800b40:	09 f0                	or     %esi,%eax
  800b42:	09 d0                	or     %edx,%eax
  800b44:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b46:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b49:	fc                   	cld    
  800b4a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4c:	eb 03                	jmp    800b51 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4e:	fc                   	cld    
  800b4f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b51:	89 f8                	mov    %edi,%eax
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b63:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b66:	39 c6                	cmp    %eax,%esi
  800b68:	73 34                	jae    800b9e <memmove+0x46>
  800b6a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b6d:	39 d0                	cmp    %edx,%eax
  800b6f:	73 2d                	jae    800b9e <memmove+0x46>
		s += n;
		d += n;
  800b71:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b74:	f6 c2 03             	test   $0x3,%dl
  800b77:	75 1b                	jne    800b94 <memmove+0x3c>
  800b79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7f:	75 13                	jne    800b94 <memmove+0x3c>
  800b81:	f6 c1 03             	test   $0x3,%cl
  800b84:	75 0e                	jne    800b94 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b86:	83 ef 04             	sub    $0x4,%edi
  800b89:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b8c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b8f:	fd                   	std    
  800b90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b92:	eb 07                	jmp    800b9b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b94:	4f                   	dec    %edi
  800b95:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b98:	fd                   	std    
  800b99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b9b:	fc                   	cld    
  800b9c:	eb 20                	jmp    800bbe <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba4:	75 13                	jne    800bb9 <memmove+0x61>
  800ba6:	a8 03                	test   $0x3,%al
  800ba8:	75 0f                	jne    800bb9 <memmove+0x61>
  800baa:	f6 c1 03             	test   $0x3,%cl
  800bad:	75 0a                	jne    800bb9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800baf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bb2:	89 c7                	mov    %eax,%edi
  800bb4:	fc                   	cld    
  800bb5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb7:	eb 05                	jmp    800bbe <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	fc                   	cld    
  800bbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	89 04 24             	mov    %eax,(%esp)
  800bdc:	e8 77 ff ff ff       	call   800b58 <memmove>
}
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	eb 16                	jmp    800c0f <memcmp+0x2c>
		if (*s1 != *s2)
  800bf9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800bfc:	42                   	inc    %edx
  800bfd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c01:	38 c8                	cmp    %cl,%al
  800c03:	74 0a                	je     800c0f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c05:	0f b6 c0             	movzbl %al,%eax
  800c08:	0f b6 c9             	movzbl %cl,%ecx
  800c0b:	29 c8                	sub    %ecx,%eax
  800c0d:	eb 09                	jmp    800c18 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0f:	39 da                	cmp    %ebx,%edx
  800c11:	75 e6                	jne    800bf9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	8b 45 08             	mov    0x8(%ebp),%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c26:	89 c2                	mov    %eax,%edx
  800c28:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c2b:	eb 05                	jmp    800c32 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2d:	38 08                	cmp    %cl,(%eax)
  800c2f:	74 05                	je     800c36 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c31:	40                   	inc    %eax
  800c32:	39 d0                	cmp    %edx,%eax
  800c34:	72 f7                	jb     800c2d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c44:	eb 01                	jmp    800c47 <strtol+0xf>
		s++;
  800c46:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c47:	8a 02                	mov    (%edx),%al
  800c49:	3c 20                	cmp    $0x20,%al
  800c4b:	74 f9                	je     800c46 <strtol+0xe>
  800c4d:	3c 09                	cmp    $0x9,%al
  800c4f:	74 f5                	je     800c46 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c51:	3c 2b                	cmp    $0x2b,%al
  800c53:	75 08                	jne    800c5d <strtol+0x25>
		s++;
  800c55:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c56:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5b:	eb 13                	jmp    800c70 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c5d:	3c 2d                	cmp    $0x2d,%al
  800c5f:	75 0a                	jne    800c6b <strtol+0x33>
		s++, neg = 1;
  800c61:	8d 52 01             	lea    0x1(%edx),%edx
  800c64:	bf 01 00 00 00       	mov    $0x1,%edi
  800c69:	eb 05                	jmp    800c70 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c70:	85 db                	test   %ebx,%ebx
  800c72:	74 05                	je     800c79 <strtol+0x41>
  800c74:	83 fb 10             	cmp    $0x10,%ebx
  800c77:	75 28                	jne    800ca1 <strtol+0x69>
  800c79:	8a 02                	mov    (%edx),%al
  800c7b:	3c 30                	cmp    $0x30,%al
  800c7d:	75 10                	jne    800c8f <strtol+0x57>
  800c7f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c83:	75 0a                	jne    800c8f <strtol+0x57>
		s += 2, base = 16;
  800c85:	83 c2 02             	add    $0x2,%edx
  800c88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8d:	eb 12                	jmp    800ca1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c8f:	85 db                	test   %ebx,%ebx
  800c91:	75 0e                	jne    800ca1 <strtol+0x69>
  800c93:	3c 30                	cmp    $0x30,%al
  800c95:	75 05                	jne    800c9c <strtol+0x64>
		s++, base = 8;
  800c97:	42                   	inc    %edx
  800c98:	b3 08                	mov    $0x8,%bl
  800c9a:	eb 05                	jmp    800ca1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ca8:	8a 0a                	mov    (%edx),%cl
  800caa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cad:	80 fb 09             	cmp    $0x9,%bl
  800cb0:	77 08                	ja     800cba <strtol+0x82>
			dig = *s - '0';
  800cb2:	0f be c9             	movsbl %cl,%ecx
  800cb5:	83 e9 30             	sub    $0x30,%ecx
  800cb8:	eb 1e                	jmp    800cd8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800cba:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cbd:	80 fb 19             	cmp    $0x19,%bl
  800cc0:	77 08                	ja     800cca <strtol+0x92>
			dig = *s - 'a' + 10;
  800cc2:	0f be c9             	movsbl %cl,%ecx
  800cc5:	83 e9 57             	sub    $0x57,%ecx
  800cc8:	eb 0e                	jmp    800cd8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cca:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ccd:	80 fb 19             	cmp    $0x19,%bl
  800cd0:	77 12                	ja     800ce4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800cd2:	0f be c9             	movsbl %cl,%ecx
  800cd5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cd8:	39 f1                	cmp    %esi,%ecx
  800cda:	7d 0c                	jge    800ce8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800cdc:	42                   	inc    %edx
  800cdd:	0f af c6             	imul   %esi,%eax
  800ce0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ce2:	eb c4                	jmp    800ca8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ce4:	89 c1                	mov    %eax,%ecx
  800ce6:	eb 02                	jmp    800cea <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ce8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cee:	74 05                	je     800cf5 <strtol+0xbd>
		*endptr = (char *) s;
  800cf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cf3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cf5:	85 ff                	test   %edi,%edi
  800cf7:	74 04                	je     800cfd <strtol+0xc5>
  800cf9:	89 c8                	mov    %ecx,%eax
  800cfb:	f7 d8                	neg    %eax
}
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
	...

00800d04 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	89 c3                	mov    %eax,%ebx
  800d17:	89 c7                	mov    %eax,%edi
  800d19:	89 c6                	mov    %eax,%esi
  800d1b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d32:	89 d1                	mov    %edx,%ecx
  800d34:	89 d3                	mov    %edx,%ebx
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4f:	b8 03 00 00 00       	mov    $0x3,%eax
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	89 cb                	mov    %ecx,%ebx
  800d59:	89 cf                	mov    %ecx,%edi
  800d5b:	89 ce                	mov    %ecx,%esi
  800d5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 28                	jle    800d8b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d67:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d6e:	00 
  800d6f:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800d76:	00 
  800d77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7e:	00 
  800d7f:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800d86:	e8 b1 f5 ff ff       	call   80033c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d8b:	83 c4 2c             	add    $0x2c,%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d99:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800da3:	89 d1                	mov    %edx,%ecx
  800da5:	89 d3                	mov    %edx,%ebx
  800da7:	89 d7                	mov    %edx,%edi
  800da9:	89 d6                	mov    %edx,%esi
  800dab:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_yield>:

void
sys_yield(void)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc2:	89 d1                	mov    %edx,%ecx
  800dc4:	89 d3                	mov    %edx,%ebx
  800dc6:	89 d7                	mov    %edx,%edi
  800dc8:	89 d6                	mov    %edx,%esi
  800dca:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	be 00 00 00 00       	mov    $0x0,%esi
  800ddf:	b8 04 00 00 00       	mov    $0x4,%eax
  800de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	89 f7                	mov    %esi,%edi
  800def:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800df1:	85 c0                	test   %eax,%eax
  800df3:	7e 28                	jle    800e1d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e00:	00 
  800e01:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800e08:	00 
  800e09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e10:	00 
  800e11:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800e18:	e8 1f f5 ff ff       	call   80033c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e1d:	83 c4 2c             	add    $0x2c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e33:	8b 75 18             	mov    0x18(%ebp),%esi
  800e36:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	7e 28                	jle    800e70 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e48:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e53:	00 
  800e54:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e63:	00 
  800e64:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800e6b:	e8 cc f4 ff ff       	call   80033c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e70:	83 c4 2c             	add    $0x2c,%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	53                   	push   %ebx
  800e7e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e86:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e91:	89 df                	mov    %ebx,%edi
  800e93:	89 de                	mov    %ebx,%esi
  800e95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e97:	85 c0                	test   %eax,%eax
  800e99:	7e 28                	jle    800ec3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800eae:	00 
  800eaf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb6:	00 
  800eb7:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800ebe:	e8 79 f4 ff ff       	call   80033c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ec3:	83 c4 2c             	add    $0x2c,%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed9:	b8 08 00 00 00       	mov    $0x8,%eax
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	89 df                	mov    %ebx,%edi
  800ee6:	89 de                	mov    %ebx,%esi
  800ee8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eea:	85 c0                	test   %eax,%eax
  800eec:	7e 28                	jle    800f16 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ef9:	00 
  800efa:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800f01:	00 
  800f02:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f09:	00 
  800f0a:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800f11:	e8 26 f4 ff ff       	call   80033c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f16:	83 c4 2c             	add    $0x2c,%esp
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800f31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f34:	8b 55 08             	mov    0x8(%ebp),%edx
  800f37:	89 df                	mov    %ebx,%edi
  800f39:	89 de                	mov    %ebx,%esi
  800f3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	7e 28                	jle    800f69 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f45:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800f54:	00 
  800f55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5c:	00 
  800f5d:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800f64:	e8 d3 f3 ff ff       	call   80033c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f69:	83 c4 2c             	add    $0x2c,%esp
  800f6c:	5b                   	pop    %ebx
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	57                   	push   %edi
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f87:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8a:	89 df                	mov    %ebx,%edi
  800f8c:	89 de                	mov    %ebx,%esi
  800f8e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	7e 28                	jle    800fbc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f94:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f98:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f9f:	00 
  800fa0:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  800fa7:	00 
  800fa8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800faf:	00 
  800fb0:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  800fb7:	e8 80 f3 ff ff       	call   80033c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fbc:	83 c4 2c             	add    $0x2c,%esp
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fca:	be 00 00 00 00       	mov    $0x0,%esi
  800fcf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ffa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffd:	89 cb                	mov    %ecx,%ebx
  800fff:	89 cf                	mov    %ecx,%edi
  801001:	89 ce                	mov    %ecx,%esi
  801003:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	7e 28                	jle    801031 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801009:	89 44 24 10          	mov    %eax,0x10(%esp)
  80100d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801014:	00 
  801015:	c7 44 24 08 df 2b 80 	movl   $0x802bdf,0x8(%esp)
  80101c:	00 
  80101d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801024:	00 
  801025:	c7 04 24 fc 2b 80 00 	movl   $0x802bfc,(%esp)
  80102c:	e8 0b f3 ff ff       	call   80033c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801031:	83 c4 2c             	add    $0x2c,%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    
  801039:	00 00                	add    %al,(%eax)
	...

0080103c <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	57                   	push   %edi
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
  801042:	83 ec 3c             	sub    $0x3c,%esp
  801045:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;
	// LAB 4: Your code here.envid_t myenvid = sys_getenvid();
	void *va = (void*)(pn * PGSIZE);
  801048:	89 d6                	mov    %edx,%esi
  80104a:	c1 e6 0c             	shl    $0xc,%esi
	pte_t pte = uvpt[pn];
  80104d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801054:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	envid_t envid_parent = sys_getenvid();
  801057:	e8 37 fd ff ff       	call   800d93 <sys_getenvid>
  80105c:	89 c7                	mov    %eax,%edi
	if (pte&PTE_SHARE){
  80105e:	f7 45 e4 00 04 00 00 	testl  $0x400,-0x1c(%ebp)
  801065:	74 31                	je     801098 <duppage+0x5c>
		if ((r = sys_page_map(envid_parent,(void*)va,envid,(void*)va,PTE_SYSCALL))<0)
  801067:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  80106e:	00 
  80106f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801073:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801076:	89 44 24 08          	mov    %eax,0x8(%esp)
  80107a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107e:	89 3c 24             	mov    %edi,(%esp)
  801081:	e8 9f fd ff ff       	call   800e25 <sys_page_map>
  801086:	85 c0                	test   %eax,%eax
  801088:	0f 8e ae 00 00 00    	jle    80113c <duppage+0x100>
  80108e:	b8 00 00 00 00       	mov    $0x0,%eax
  801093:	e9 a4 00 00 00       	jmp    80113c <duppage+0x100>
			return r;
		return 0;
	}
	int perm = PTE_U|PTE_P|(((pte&(PTE_W|PTE_COW))>0)?PTE_COW:0);
  801098:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80109b:	25 02 08 00 00       	and    $0x802,%eax
  8010a0:	83 f8 01             	cmp    $0x1,%eax
  8010a3:	19 db                	sbb    %ebx,%ebx
  8010a5:	81 e3 00 f8 ff ff    	and    $0xfffff800,%ebx
  8010ab:	81 c3 05 08 00 00    	add    $0x805,%ebx
	int err;
	err = sys_page_map(envid_parent,va,envid,va,perm);
  8010b1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010b5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c4:	89 3c 24             	mov    %edi,(%esp)
  8010c7:	e8 59 fd ff ff       	call   800e25 <sys_page_map>
	if (err < 0)panic("duppage: error!\n");
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 1c                	jns    8010ec <duppage+0xb0>
  8010d0:	c7 44 24 08 0a 2c 80 	movl   $0x802c0a,0x8(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  8010e7:	e8 50 f2 ff ff       	call   80033c <_panic>
	if ((perm|~pte)&PTE_COW){
  8010ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ef:	f7 d0                	not    %eax
  8010f1:	09 d8                	or     %ebx,%eax
  8010f3:	f6 c4 08             	test   $0x8,%ah
  8010f6:	74 38                	je     801130 <duppage+0xf4>
		err = sys_page_map(envid_parent,va,envid_parent,va,perm);
  8010f8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010fc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801100:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801104:	89 74 24 04          	mov    %esi,0x4(%esp)
  801108:	89 3c 24             	mov    %edi,(%esp)
  80110b:	e8 15 fd ff ff       	call   800e25 <sys_page_map>
		if (err < 0)panic("duppage: error!\n");
  801110:	85 c0                	test   %eax,%eax
  801112:	79 23                	jns    801137 <duppage+0xfb>
  801114:	c7 44 24 08 0a 2c 80 	movl   $0x802c0a,0x8(%esp)
  80111b:	00 
  80111c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801123:	00 
  801124:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  80112b:	e8 0c f2 ff ff       	call   80033c <_panic>
	}
	return 0;
  801130:	b8 00 00 00 00       	mov    $0x0,%eax
  801135:	eb 05                	jmp    80113c <duppage+0x100>
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
	panic("duppage not implemented");
	return 0;
}
  80113c:	83 c4 3c             	add    $0x3c,%esp
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 20             	sub    $0x20,%esp
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80114f:	8b 30                	mov    (%eax),%esi
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((err&FEC_WR)==0)
  801151:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801155:	75 1c                	jne    801173 <pgfault+0x2f>
		panic("pgfault: error!\n");
  801157:	c7 44 24 08 26 2c 80 	movl   $0x802c26,0x8(%esp)
  80115e:	00 
  80115f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  801166:	00 
  801167:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  80116e:	e8 c9 f1 ff ff       	call   80033c <_panic>
	if ((uvpt[PGNUM(addr)]&PTE_COW)==0) 
  801173:	89 f0                	mov    %esi,%eax
  801175:	c1 e8 0c             	shr    $0xc,%eax
  801178:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80117f:	f6 c4 08             	test   $0x8,%ah
  801182:	75 1c                	jne    8011a0 <pgfault+0x5c>
		panic("pgfault: error!\n");
  801184:	c7 44 24 08 26 2c 80 	movl   $0x802c26,0x8(%esp)
  80118b:	00 
  80118c:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801193:	00 
  801194:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  80119b:	e8 9c f1 ff ff       	call   80033c <_panic>
	envid_t envid = sys_getenvid();
  8011a0:	e8 ee fb ff ff       	call   800d93 <sys_getenvid>
  8011a5:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid,(void*)PFTEMP,PTE_P|PTE_U|PTE_W);
  8011a7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011ae:	00 
  8011af:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011b6:	00 
  8011b7:	89 04 24             	mov    %eax,(%esp)
  8011ba:	e8 12 fc ff ff       	call   800dd1 <sys_page_alloc>
	if (r<0)panic("pgfault: error!\n");
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	79 1c                	jns    8011df <pgfault+0x9b>
  8011c3:	c7 44 24 08 26 2c 80 	movl   $0x802c26,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  8011da:	e8 5d f1 ff ff       	call   80033c <_panic>
	addr = ROUNDDOWN(addr,PGSIZE);
  8011df:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	memcpy(PFTEMP,addr,PGSIZE);
  8011e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011ec:	00 
  8011ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011f1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011f8:	e8 c5 f9 ff ff       	call   800bc2 <memcpy>
	r = sys_page_map(envid,(void*)PFTEMP,envid,addr,PTE_P|PTE_U|PTE_W);
  8011fd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801204:	00 
  801205:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80120d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801214:	00 
  801215:	89 1c 24             	mov    %ebx,(%esp)
  801218:	e8 08 fc ff ff       	call   800e25 <sys_page_map>
	if (r<0)panic("pgfault: error!\n");
  80121d:	85 c0                	test   %eax,%eax
  80121f:	79 1c                	jns    80123d <pgfault+0xf9>
  801221:	c7 44 24 08 26 2c 80 	movl   $0x802c26,0x8(%esp)
  801228:	00 
  801229:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801230:	00 
  801231:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  801238:	e8 ff f0 ff ff       	call   80033c <_panic>
	r = sys_page_unmap(envid, PFTEMP);
  80123d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801244:	00 
  801245:	89 1c 24             	mov    %ebx,(%esp)
  801248:	e8 2b fc ff ff       	call   800e78 <sys_page_unmap>
	if (r<0)panic("pgfault: error!\n");
  80124d:	85 c0                	test   %eax,%eax
  80124f:	79 1c                	jns    80126d <pgfault+0x129>
  801251:	c7 44 24 08 26 2c 80 	movl   $0x802c26,0x8(%esp)
  801258:	00 
  801259:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801260:	00 
  801261:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  801268:	e8 cf f0 ff ff       	call   80033c <_panic>
	return;
	panic("pgfault not implemented");
}
  80126d:	83 c4 20             	add    $0x20,%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	57                   	push   %edi
  801278:	56                   	push   %esi
  801279:	53                   	push   %ebx
  80127a:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80127d:	c7 04 24 44 11 80 00 	movl   $0x801144,(%esp)
  801284:	e8 0b 11 00 00       	call   802394 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801289:	bf 07 00 00 00       	mov    $0x7,%edi
  80128e:	89 f8                	mov    %edi,%eax
  801290:	cd 30                	int    $0x30
  801292:	89 c7                	mov    %eax,%edi
  801294:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid<0)
  801296:	85 c0                	test   %eax,%eax
  801298:	79 1c                	jns    8012b6 <fork+0x42>
		panic("fork : error!\n");
  80129a:	c7 44 24 08 43 2c 80 	movl   $0x802c43,0x8(%esp)
  8012a1:	00 
  8012a2:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  8012a9:	00 
  8012aa:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  8012b1:	e8 86 f0 ff ff       	call   80033c <_panic>
	if (envid==0){
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	75 28                	jne    8012e2 <fork+0x6e>
		thisenv = envs+ENVX(sys_getenvid());
  8012ba:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8012c0:	e8 ce fa ff ff       	call   800d93 <sys_getenvid>
  8012c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012ca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8012d1:	c1 e0 07             	shl    $0x7,%eax
  8012d4:	29 d0                	sub    %edx,%eax
  8012d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012db:	89 03                	mov    %eax,(%ebx)
		// cprintf("find\n");
		return envid;
  8012dd:	e9 f2 00 00 00       	jmp    8013d4 <fork+0x160>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
  8012e2:	e8 ac fa ff ff       	call   800d93 <sys_getenvid>
  8012e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
  8012ef:	89 d8                	mov    %ebx,%eax
  8012f1:	c1 e8 16             	shr    $0x16,%eax
  8012f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012fb:	a8 01                	test   $0x1,%al
  8012fd:	74 17                	je     801316 <fork+0xa2>
  8012ff:	89 da                	mov    %ebx,%edx
  801301:	c1 ea 0c             	shr    $0xc,%edx
  801304:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80130b:	a8 01                	test   $0x1,%al
  80130d:	74 07                	je     801316 <fork+0xa2>
			duppage(envid_child,PGNUM(addr));
  80130f:	89 f0                	mov    %esi,%eax
  801311:	e8 26 fd ff ff       	call   80103c <duppage>
		// cprintf("find\n");
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();;
	for (uintptr_t addr=0;addr<USTACKTOP;addr+=PGSIZE)
  801316:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80131c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801322:	75 cb                	jne    8012ef <fork+0x7b>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			duppage(envid_child,PGNUM(addr));
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("fork : error!\n");
  801324:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80132b:	00 
  80132c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801333:	ee 
  801334:	89 3c 24             	mov    %edi,(%esp)
  801337:	e8 95 fa ff ff       	call   800dd1 <sys_page_alloc>
  80133c:	85 c0                	test   %eax,%eax
  80133e:	79 1c                	jns    80135c <fork+0xe8>
  801340:	c7 44 24 08 43 2c 80 	movl   $0x802c43,0x8(%esp)
  801347:	00 
  801348:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80134f:	00 
  801350:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  801357:	e8 e0 ef ff ff       	call   80033c <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("fork : error!\n");
  80135c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80135f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801364:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80136b:	c1 e0 07             	shl    $0x7,%eax
  80136e:	29 d0                	sub    %edx,%eax
  801370:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801375:	8b 40 64             	mov    0x64(%eax),%eax
  801378:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137c:	89 3c 24             	mov    %edi,(%esp)
  80137f:	e8 ed fb ff ff       	call   800f71 <sys_env_set_pgfault_upcall>
  801384:	85 c0                	test   %eax,%eax
  801386:	79 1c                	jns    8013a4 <fork+0x130>
  801388:	c7 44 24 08 43 2c 80 	movl   $0x802c43,0x8(%esp)
  80138f:	00 
  801390:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801397:	00 
  801398:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  80139f:	e8 98 ef ff ff       	call   80033c <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("fork : error!\n");
  8013a4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013ab:	00 
  8013ac:	89 3c 24             	mov    %edi,(%esp)
  8013af:	e8 17 fb ff ff       	call   800ecb <sys_env_set_status>
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	79 1c                	jns    8013d4 <fork+0x160>
  8013b8:	c7 44 24 08 43 2c 80 	movl   $0x802c43,0x8(%esp)
  8013bf:	00 
  8013c0:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
  8013c7:	00 
  8013c8:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  8013cf:	e8 68 ef ff ff       	call   80033c <_panic>
	return envid_child;
	panic("fork not implemented");
}
  8013d4:	89 f8                	mov    %edi,%eax
  8013d6:	83 c4 2c             	add    $0x2c,%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <sfork>:

// Challenge!
int
sfork(void)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	57                   	push   %edi
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
  8013e4:	83 ec 3c             	sub    $0x3c,%esp
	set_pgfault_handler(pgfault);
  8013e7:	c7 04 24 44 11 80 00 	movl   $0x801144,(%esp)
  8013ee:	e8 a1 0f 00 00       	call   802394 <set_pgfault_handler>
  8013f3:	ba 07 00 00 00       	mov    $0x7,%edx
  8013f8:	89 d0                	mov    %edx,%eax
  8013fa:	cd 30                	int    $0x30
  8013fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013ff:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	cprintf("envid :%x\n",envid);
  801401:	89 44 24 04          	mov    %eax,0x4(%esp)
  801405:	c7 04 24 37 2c 80 00 	movl   $0x802c37,(%esp)
  80140c:	e8 23 f0 ff ff       	call   800434 <cprintf>
	if (envid<0)
  801411:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801415:	79 1c                	jns    801433 <sfork+0x55>
		panic("sfork : error!\n");
  801417:	c7 44 24 08 42 2c 80 	movl   $0x802c42,0x8(%esp)
  80141e:	00 
  80141f:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  801426:	00 
  801427:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  80142e:	e8 09 ef ff ff       	call   80033c <_panic>
	if (envid==0){
  801433:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801437:	75 28                	jne    801461 <sfork+0x83>
		thisenv = envs+ENVX(sys_getenvid());
  801439:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  80143f:	e8 4f f9 ff ff       	call   800d93 <sys_getenvid>
  801444:	25 ff 03 00 00       	and    $0x3ff,%eax
  801449:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801450:	c1 e0 07             	shl    $0x7,%eax
  801453:	29 d0                	sub    %edx,%eax
  801455:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80145a:	89 03                	mov    %eax,(%ebx)
		return envid;
  80145c:	e9 18 01 00 00       	jmp    801579 <sfork+0x19b>
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
  801461:	e8 2d f9 ff ff       	call   800d93 <sys_getenvid>
  801466:	89 c7                	mov    %eax,%edi
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  801468:	bb 00 00 80 00       	mov    $0x800000,%ebx
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
  80146d:	89 d8                	mov    %ebx,%eax
  80146f:	c1 e8 16             	shr    $0x16,%eax
  801472:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801479:	a8 01                	test   $0x1,%al
  80147b:	74 2c                	je     8014a9 <sfork+0xcb>
  80147d:	89 d8                	mov    %ebx,%eax
  80147f:	c1 e8 0c             	shr    $0xc,%eax
  801482:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801489:	a8 01                	test   $0x1,%al
  80148b:	74 1c                	je     8014a9 <sfork+0xcb>
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
  80148d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801494:	00 
  801495:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801499:	89 74 24 08          	mov    %esi,0x8(%esp)
  80149d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014a1:	89 3c 24             	mov    %edi,(%esp)
  8014a4:	e8 7c f9 ff ff       	call   800e25 <sys_page_map>
		thisenv = envs+ENVX(sys_getenvid());
		return envid;
	}
	envid_t envid_child = envid;
	envid_t envid_parent = sys_getenvid();
	for (uintptr_t addr=UTEXT;addr<USTACKTOP - PGSIZE;addr+=PGSIZE)
  8014a9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8014af:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8014b5:	75 b6                	jne    80146d <sfork+0x8f>
		if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P)){
			// if ((uvpd[PDX(addr)]&PTE_P)&&(uvpt[PGNUM(addr)]&PTE_P))
			//    duppage(envid_child,PGNUM(addr));
			sys_page_map(envid_parent,(void*)addr,envid_child,(void*)addr,PTE_U|PTE_P|PTE_W);
		}
	duppage(envid_child,PGNUM(USTACKTOP - PGSIZE));
  8014b7:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  8014bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014bf:	e8 78 fb ff ff       	call   80103c <duppage>
	if (sys_page_alloc(envid_child,(void *)(UXSTACKTOP-PGSIZE),PTE_U|PTE_W|PTE_P)<0)panic("sfork : error!\n");
  8014c4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014cb:	00 
  8014cc:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014d3:	ee 
  8014d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d7:	89 04 24             	mov    %eax,(%esp)
  8014da:	e8 f2 f8 ff ff       	call   800dd1 <sys_page_alloc>
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	79 1c                	jns    8014ff <sfork+0x121>
  8014e3:	c7 44 24 08 42 2c 80 	movl   $0x802c42,0x8(%esp)
  8014ea:	00 
  8014eb:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8014f2:	00 
  8014f3:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  8014fa:	e8 3d ee ff ff       	call   80033c <_panic>
	if (sys_env_set_pgfault_upcall(envid_child,(envs + ENVX(envid_parent))->env_pgfault_upcall)<0)panic("sfork : error!\n");
  8014ff:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
  801505:	8d 14 bd 00 00 00 00 	lea    0x0(,%edi,4),%edx
  80150c:	c1 e7 07             	shl    $0x7,%edi
  80150f:	29 d7                	sub    %edx,%edi
  801511:	8b 87 64 00 c0 ee    	mov    -0x113fff9c(%edi),%eax
  801517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80151e:	89 04 24             	mov    %eax,(%esp)
  801521:	e8 4b fa ff ff       	call   800f71 <sys_env_set_pgfault_upcall>
  801526:	85 c0                	test   %eax,%eax
  801528:	79 1c                	jns    801546 <sfork+0x168>
  80152a:	c7 44 24 08 42 2c 80 	movl   $0x802c42,0x8(%esp)
  801531:	00 
  801532:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
  801539:	00 
  80153a:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  801541:	e8 f6 ed ff ff       	call   80033c <_panic>
	if (sys_env_set_status(envid_child, ENV_RUNNABLE)<0)panic("sfork : error!\n");
  801546:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80154d:	00 
  80154e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801551:	89 04 24             	mov    %eax,(%esp)
  801554:	e8 72 f9 ff ff       	call   800ecb <sys_env_set_status>
  801559:	85 c0                	test   %eax,%eax
  80155b:	79 1c                	jns    801579 <sfork+0x19b>
  80155d:	c7 44 24 08 42 2c 80 	movl   $0x802c42,0x8(%esp)
  801564:	00 
  801565:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  80156c:	00 
  80156d:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  801574:	e8 c3 ed ff ff       	call   80033c <_panic>
	return envid_child;

	panic("sfork not implemented");
	return -E_INVAL;
}
  801579:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80157c:	83 c4 3c             	add    $0x3c,%esp
  80157f:	5b                   	pop    %ebx
  801580:	5e                   	pop    %esi
  801581:	5f                   	pop    %edi
  801582:	5d                   	pop    %ebp
  801583:	c3                   	ret    

00801584 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801587:	8b 45 08             	mov    0x8(%ebp),%eax
  80158a:	05 00 00 00 30       	add    $0x30000000,%eax
  80158f:	c1 e8 0c             	shr    $0xc,%eax
}
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80159a:	8b 45 08             	mov    0x8(%ebp),%eax
  80159d:	89 04 24             	mov    %eax,(%esp)
  8015a0:	e8 df ff ff ff       	call   801584 <fd2num>
  8015a5:	05 20 00 0d 00       	add    $0xd0020,%eax
  8015aa:	c1 e0 0c             	shl    $0xc,%eax
}
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	53                   	push   %ebx
  8015b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8015b6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8015bb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	c1 ea 16             	shr    $0x16,%edx
  8015c2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015c9:	f6 c2 01             	test   $0x1,%dl
  8015cc:	74 11                	je     8015df <fd_alloc+0x30>
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	c1 ea 0c             	shr    $0xc,%edx
  8015d3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015da:	f6 c2 01             	test   $0x1,%dl
  8015dd:	75 09                	jne    8015e8 <fd_alloc+0x39>
			*fd_store = fd;
  8015df:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8015e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e6:	eb 17                	jmp    8015ff <fd_alloc+0x50>
  8015e8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015ed:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015f2:	75 c7                	jne    8015bb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8015fa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8015ff:	5b                   	pop    %ebx
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801608:	83 f8 1f             	cmp    $0x1f,%eax
  80160b:	77 36                	ja     801643 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80160d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801612:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801615:	89 c2                	mov    %eax,%edx
  801617:	c1 ea 16             	shr    $0x16,%edx
  80161a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801621:	f6 c2 01             	test   $0x1,%dl
  801624:	74 24                	je     80164a <fd_lookup+0x48>
  801626:	89 c2                	mov    %eax,%edx
  801628:	c1 ea 0c             	shr    $0xc,%edx
  80162b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801632:	f6 c2 01             	test   $0x1,%dl
  801635:	74 1a                	je     801651 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801637:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163a:	89 02                	mov    %eax,(%edx)
	return 0;
  80163c:	b8 00 00 00 00       	mov    $0x0,%eax
  801641:	eb 13                	jmp    801656 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801643:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801648:	eb 0c                	jmp    801656 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80164a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164f:	eb 05                	jmp    801656 <fd_lookup+0x54>
  801651:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    

00801658 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	53                   	push   %ebx
  80165c:	83 ec 14             	sub    $0x14,%esp
  80165f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801662:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801665:	ba 00 00 00 00       	mov    $0x0,%edx
  80166a:	eb 0e                	jmp    80167a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80166c:	39 08                	cmp    %ecx,(%eax)
  80166e:	75 09                	jne    801679 <dev_lookup+0x21>
			*dev = devtab[i];
  801670:	89 03                	mov    %eax,(%ebx)
			return 0;
  801672:	b8 00 00 00 00       	mov    $0x0,%eax
  801677:	eb 35                	jmp    8016ae <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801679:	42                   	inc    %edx
  80167a:	8b 04 95 d0 2c 80 00 	mov    0x802cd0(,%edx,4),%eax
  801681:	85 c0                	test   %eax,%eax
  801683:	75 e7                	jne    80166c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801685:	a1 04 40 80 00       	mov    0x804004,%eax
  80168a:	8b 00                	mov    (%eax),%eax
  80168c:	8b 40 48             	mov    0x48(%eax),%eax
  80168f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801693:	89 44 24 04          	mov    %eax,0x4(%esp)
  801697:	c7 04 24 54 2c 80 00 	movl   $0x802c54,(%esp)
  80169e:	e8 91 ed ff ff       	call   800434 <cprintf>
	*dev = 0;
  8016a3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8016a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016ae:	83 c4 14             	add    $0x14,%esp
  8016b1:	5b                   	pop    %ebx
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 30             	sub    $0x30,%esp
  8016bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8016bf:	8a 45 0c             	mov    0xc(%ebp),%al
  8016c2:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8016c5:	89 34 24             	mov    %esi,(%esp)
  8016c8:	e8 b7 fe ff ff       	call   801584 <fd2num>
  8016cd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016d4:	89 04 24             	mov    %eax,(%esp)
  8016d7:	e8 26 ff ff ff       	call   801602 <fd_lookup>
  8016dc:	89 c3                	mov    %eax,%ebx
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 05                	js     8016e7 <fd_close+0x33>
	    || fd != fd2)
  8016e2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8016e5:	74 0d                	je     8016f4 <fd_close+0x40>
		return (must_exist ? r : 0);
  8016e7:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8016eb:	75 46                	jne    801733 <fd_close+0x7f>
  8016ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f2:	eb 3f                	jmp    801733 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fb:	8b 06                	mov    (%esi),%eax
  8016fd:	89 04 24             	mov    %eax,(%esp)
  801700:	e8 53 ff ff ff       	call   801658 <dev_lookup>
  801705:	89 c3                	mov    %eax,%ebx
  801707:	85 c0                	test   %eax,%eax
  801709:	78 18                	js     801723 <fd_close+0x6f>
		if (dev->dev_close)
  80170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170e:	8b 40 10             	mov    0x10(%eax),%eax
  801711:	85 c0                	test   %eax,%eax
  801713:	74 09                	je     80171e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801715:	89 34 24             	mov    %esi,(%esp)
  801718:	ff d0                	call   *%eax
  80171a:	89 c3                	mov    %eax,%ebx
  80171c:	eb 05                	jmp    801723 <fd_close+0x6f>
		else
			r = 0;
  80171e:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801723:	89 74 24 04          	mov    %esi,0x4(%esp)
  801727:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172e:	e8 45 f7 ff ff       	call   800e78 <sys_page_unmap>
	return r;
}
  801733:	89 d8                	mov    %ebx,%eax
  801735:	83 c4 30             	add    $0x30,%esp
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	89 44 24 04          	mov    %eax,0x4(%esp)
  801749:	8b 45 08             	mov    0x8(%ebp),%eax
  80174c:	89 04 24             	mov    %eax,(%esp)
  80174f:	e8 ae fe ff ff       	call   801602 <fd_lookup>
  801754:	85 c0                	test   %eax,%eax
  801756:	78 13                	js     80176b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801758:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80175f:	00 
  801760:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801763:	89 04 24             	mov    %eax,(%esp)
  801766:	e8 49 ff ff ff       	call   8016b4 <fd_close>
}
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <close_all>:

void
close_all(void)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	53                   	push   %ebx
  801771:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801774:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801779:	89 1c 24             	mov    %ebx,(%esp)
  80177c:	e8 bb ff ff ff       	call   80173c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801781:	43                   	inc    %ebx
  801782:	83 fb 20             	cmp    $0x20,%ebx
  801785:	75 f2                	jne    801779 <close_all+0xc>
		close(i);
}
  801787:	83 c4 14             	add    $0x14,%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	57                   	push   %edi
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	83 ec 4c             	sub    $0x4c,%esp
  801796:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801799:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80179c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	89 04 24             	mov    %eax,(%esp)
  8017a6:	e8 57 fe ff ff       	call   801602 <fd_lookup>
  8017ab:	89 c3                	mov    %eax,%ebx
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	0f 88 e1 00 00 00    	js     801896 <dup+0x109>
		return r;
	close(newfdnum);
  8017b5:	89 3c 24             	mov    %edi,(%esp)
  8017b8:	e8 7f ff ff ff       	call   80173c <close>

	newfd = INDEX2FD(newfdnum);
  8017bd:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8017c3:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8017c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017c9:	89 04 24             	mov    %eax,(%esp)
  8017cc:	e8 c3 fd ff ff       	call   801594 <fd2data>
  8017d1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8017d3:	89 34 24             	mov    %esi,(%esp)
  8017d6:	e8 b9 fd ff ff       	call   801594 <fd2data>
  8017db:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8017de:	89 d8                	mov    %ebx,%eax
  8017e0:	c1 e8 16             	shr    $0x16,%eax
  8017e3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017ea:	a8 01                	test   $0x1,%al
  8017ec:	74 46                	je     801834 <dup+0xa7>
  8017ee:	89 d8                	mov    %ebx,%eax
  8017f0:	c1 e8 0c             	shr    $0xc,%eax
  8017f3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8017fa:	f6 c2 01             	test   $0x1,%dl
  8017fd:	74 35                	je     801834 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801806:	25 07 0e 00 00       	and    $0xe07,%eax
  80180b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80180f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801812:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801816:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80181d:	00 
  80181e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801822:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801829:	e8 f7 f5 ff ff       	call   800e25 <sys_page_map>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	85 c0                	test   %eax,%eax
  801832:	78 3b                	js     80186f <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801837:	89 c2                	mov    %eax,%edx
  801839:	c1 ea 0c             	shr    $0xc,%edx
  80183c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801843:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801849:	89 54 24 10          	mov    %edx,0x10(%esp)
  80184d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801851:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801858:	00 
  801859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801864:	e8 bc f5 ff ff       	call   800e25 <sys_page_map>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	85 c0                	test   %eax,%eax
  80186d:	79 25                	jns    801894 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80186f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801873:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80187a:	e8 f9 f5 ff ff       	call   800e78 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80187f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80188d:	e8 e6 f5 ff ff       	call   800e78 <sys_page_unmap>
	return r;
  801892:	eb 02                	jmp    801896 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801894:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801896:	89 d8                	mov    %ebx,%eax
  801898:	83 c4 4c             	add    $0x4c,%esp
  80189b:	5b                   	pop    %ebx
  80189c:	5e                   	pop    %esi
  80189d:	5f                   	pop    %edi
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 24             	sub    $0x24,%esp
  8018a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	89 1c 24             	mov    %ebx,(%esp)
  8018b4:	e8 49 fd ff ff       	call   801602 <fd_lookup>
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 6f                	js     80192c <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c7:	8b 00                	mov    (%eax),%eax
  8018c9:	89 04 24             	mov    %eax,(%esp)
  8018cc:	e8 87 fd ff ff       	call   801658 <dev_lookup>
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	78 57                	js     80192c <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d8:	8b 50 08             	mov    0x8(%eax),%edx
  8018db:	83 e2 03             	and    $0x3,%edx
  8018de:	83 fa 01             	cmp    $0x1,%edx
  8018e1:	75 25                	jne    801908 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e8:	8b 00                	mov    (%eax),%eax
  8018ea:	8b 40 48             	mov    0x48(%eax),%eax
  8018ed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f5:	c7 04 24 95 2c 80 00 	movl   $0x802c95,(%esp)
  8018fc:	e8 33 eb ff ff       	call   800434 <cprintf>
		return -E_INVAL;
  801901:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801906:	eb 24                	jmp    80192c <read+0x8c>
	}
	if (!dev->dev_read)
  801908:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190b:	8b 52 08             	mov    0x8(%edx),%edx
  80190e:	85 d2                	test   %edx,%edx
  801910:	74 15                	je     801927 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801912:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801915:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80191c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801920:	89 04 24             	mov    %eax,(%esp)
  801923:	ff d2                	call   *%edx
  801925:	eb 05                	jmp    80192c <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801927:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80192c:	83 c4 24             	add    $0x24,%esp
  80192f:	5b                   	pop    %ebx
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    

00801932 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	57                   	push   %edi
  801936:	56                   	push   %esi
  801937:	53                   	push   %ebx
  801938:	83 ec 1c             	sub    $0x1c,%esp
  80193b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80193e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801941:	bb 00 00 00 00       	mov    $0x0,%ebx
  801946:	eb 23                	jmp    80196b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801948:	89 f0                	mov    %esi,%eax
  80194a:	29 d8                	sub    %ebx,%eax
  80194c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801950:	8b 45 0c             	mov    0xc(%ebp),%eax
  801953:	01 d8                	add    %ebx,%eax
  801955:	89 44 24 04          	mov    %eax,0x4(%esp)
  801959:	89 3c 24             	mov    %edi,(%esp)
  80195c:	e8 3f ff ff ff       	call   8018a0 <read>
		if (m < 0)
  801961:	85 c0                	test   %eax,%eax
  801963:	78 10                	js     801975 <readn+0x43>
			return m;
		if (m == 0)
  801965:	85 c0                	test   %eax,%eax
  801967:	74 0a                	je     801973 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801969:	01 c3                	add    %eax,%ebx
  80196b:	39 f3                	cmp    %esi,%ebx
  80196d:	72 d9                	jb     801948 <readn+0x16>
  80196f:	89 d8                	mov    %ebx,%eax
  801971:	eb 02                	jmp    801975 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801973:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801975:	83 c4 1c             	add    $0x1c,%esp
  801978:	5b                   	pop    %ebx
  801979:	5e                   	pop    %esi
  80197a:	5f                   	pop    %edi
  80197b:	5d                   	pop    %ebp
  80197c:	c3                   	ret    

0080197d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	53                   	push   %ebx
  801981:	83 ec 24             	sub    $0x24,%esp
  801984:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801987:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198e:	89 1c 24             	mov    %ebx,(%esp)
  801991:	e8 6c fc ff ff       	call   801602 <fd_lookup>
  801996:	85 c0                	test   %eax,%eax
  801998:	78 6a                	js     801a04 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80199a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a4:	8b 00                	mov    (%eax),%eax
  8019a6:	89 04 24             	mov    %eax,(%esp)
  8019a9:	e8 aa fc ff ff       	call   801658 <dev_lookup>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	78 52                	js     801a04 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019b9:	75 25                	jne    8019e0 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8019bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8019c0:	8b 00                	mov    (%eax),%eax
  8019c2:	8b 40 48             	mov    0x48(%eax),%eax
  8019c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cd:	c7 04 24 b1 2c 80 00 	movl   $0x802cb1,(%esp)
  8019d4:	e8 5b ea ff ff       	call   800434 <cprintf>
		return -E_INVAL;
  8019d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019de:	eb 24                	jmp    801a04 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8019e6:	85 d2                	test   %edx,%edx
  8019e8:	74 15                	je     8019ff <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019f8:	89 04 24             	mov    %eax,(%esp)
  8019fb:	ff d2                	call   *%edx
  8019fd:	eb 05                	jmp    801a04 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8019ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a04:	83 c4 24             	add    $0x24,%esp
  801a07:	5b                   	pop    %ebx
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    

00801a0a <seek>:

int
seek(int fdnum, off_t offset)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a10:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a17:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1a:	89 04 24             	mov    %eax,(%esp)
  801a1d:	e8 e0 fb ff ff       	call   801602 <fd_lookup>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	78 0e                	js     801a34 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a26:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a29:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a2c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 24             	sub    $0x24,%esp
  801a3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a47:	89 1c 24             	mov    %ebx,(%esp)
  801a4a:	e8 b3 fb ff ff       	call   801602 <fd_lookup>
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 63                	js     801ab6 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5d:	8b 00                	mov    (%eax),%eax
  801a5f:	89 04 24             	mov    %eax,(%esp)
  801a62:	e8 f1 fb ff ff       	call   801658 <dev_lookup>
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 4b                	js     801ab6 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a72:	75 25                	jne    801a99 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801a74:	a1 04 40 80 00       	mov    0x804004,%eax
  801a79:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801a7b:	8b 40 48             	mov    0x48(%eax),%eax
  801a7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a86:	c7 04 24 74 2c 80 00 	movl   $0x802c74,(%esp)
  801a8d:	e8 a2 e9 ff ff       	call   800434 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801a92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a97:	eb 1d                	jmp    801ab6 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801a99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a9c:	8b 52 18             	mov    0x18(%edx),%edx
  801a9f:	85 d2                	test   %edx,%edx
  801aa1:	74 0e                	je     801ab1 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801aa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	ff d2                	call   *%edx
  801aaf:	eb 05                	jmp    801ab6 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801ab1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801ab6:	83 c4 24             	add    $0x24,%esp
  801ab9:	5b                   	pop    %ebx
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	53                   	push   %ebx
  801ac0:	83 ec 24             	sub    $0x24,%esp
  801ac3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ac6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad0:	89 04 24             	mov    %eax,(%esp)
  801ad3:	e8 2a fb ff ff       	call   801602 <fd_lookup>
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 52                	js     801b2e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801adc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae6:	8b 00                	mov    (%eax),%eax
  801ae8:	89 04 24             	mov    %eax,(%esp)
  801aeb:	e8 68 fb ff ff       	call   801658 <dev_lookup>
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 3a                	js     801b2e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801afb:	74 2c                	je     801b29 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801afd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b00:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b07:	00 00 00 
	stat->st_isdir = 0;
  801b0a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b11:	00 00 00 
	stat->st_dev = dev;
  801b14:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b1e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b21:	89 14 24             	mov    %edx,(%esp)
  801b24:	ff 50 14             	call   *0x14(%eax)
  801b27:	eb 05                	jmp    801b2e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b29:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b2e:	83 c4 24             	add    $0x24,%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	56                   	push   %esi
  801b38:	53                   	push   %ebx
  801b39:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b3c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b43:	00 
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	89 04 24             	mov    %eax,(%esp)
  801b4a:	e8 88 02 00 00       	call   801dd7 <open>
  801b4f:	89 c3                	mov    %eax,%ebx
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 1b                	js     801b70 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5c:	89 1c 24             	mov    %ebx,(%esp)
  801b5f:	e8 58 ff ff ff       	call   801abc <fstat>
  801b64:	89 c6                	mov    %eax,%esi
	close(fd);
  801b66:	89 1c 24             	mov    %ebx,(%esp)
  801b69:	e8 ce fb ff ff       	call   80173c <close>
	return r;
  801b6e:	89 f3                	mov    %esi,%ebx
}
  801b70:	89 d8                	mov    %ebx,%eax
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    
  801b79:	00 00                	add    %al,(%eax)
	...

00801b7c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 10             	sub    $0x10,%esp
  801b84:	89 c3                	mov    %eax,%ebx
  801b86:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b88:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b8f:	75 11                	jne    801ba2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b98:	e8 82 09 00 00       	call   80251f <ipc_find_env>
  801b9d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ba2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ba9:	00 
  801baa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801bb1:	00 
  801bb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bb6:	a1 00 40 80 00       	mov    0x804000,%eax
  801bbb:	89 04 24             	mov    %eax,(%esp)
  801bbe:	e8 f6 08 00 00       	call   8024b9 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  801bc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bca:	00 
  801bcb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd6:	e8 71 08 00 00       	call   80244c <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  801bdb:	83 c4 10             	add    $0x10,%esp
  801bde:	5b                   	pop    %ebx
  801bdf:	5e                   	pop    %esi
  801be0:	5d                   	pop    %ebp
  801be1:	c3                   	ret    

00801be2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801be8:	8b 45 08             	mov    0x8(%ebp),%eax
  801beb:	8b 40 0c             	mov    0xc(%eax),%eax
  801bee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  801c00:	b8 02 00 00 00       	mov    $0x2,%eax
  801c05:	e8 72 ff ff ff       	call   801b7c <fsipc>
}
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c12:	8b 45 08             	mov    0x8(%ebp),%eax
  801c15:	8b 40 0c             	mov    0xc(%eax),%eax
  801c18:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c22:	b8 06 00 00 00       	mov    $0x6,%eax
  801c27:	e8 50 ff ff ff       	call   801b7c <fsipc>
}
  801c2c:	c9                   	leave  
  801c2d:	c3                   	ret    

00801c2e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	53                   	push   %ebx
  801c32:	83 ec 14             	sub    $0x14,%esp
  801c35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c38:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3b:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c43:	ba 00 00 00 00       	mov    $0x0,%edx
  801c48:	b8 05 00 00 00       	mov    $0x5,%eax
  801c4d:	e8 2a ff ff ff       	call   801b7c <fsipc>
  801c52:	85 c0                	test   %eax,%eax
  801c54:	78 2b                	js     801c81 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c56:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c5d:	00 
  801c5e:	89 1c 24             	mov    %ebx,(%esp)
  801c61:	e8 79 ed ff ff       	call   8009df <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c66:	a1 80 50 80 00       	mov    0x805080,%eax
  801c6b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c71:	a1 84 50 80 00       	mov    0x805084,%eax
  801c76:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c81:	83 c4 14             	add    $0x14,%esp
  801c84:	5b                   	pop    %ebx
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	53                   	push   %ebx
  801c8b:	83 ec 14             	sub    $0x14,%esp
  801c8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	8b 40 0c             	mov    0xc(%eax),%eax
  801c97:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801ca4:	76 05                	jbe    801cab <devfile_write+0x24>
  801ca6:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  801cab:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  801cb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbb:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801cc2:	e8 fb ee ff ff       	call   800bc2 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  801cc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801ccc:	b8 04 00 00 00       	mov    $0x4,%eax
  801cd1:	e8 a6 fe ff ff       	call   801b7c <fsipc>
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 53                	js     801d2d <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  801cda:	39 c3                	cmp    %eax,%ebx
  801cdc:	73 24                	jae    801d02 <devfile_write+0x7b>
  801cde:	c7 44 24 0c e0 2c 80 	movl   $0x802ce0,0xc(%esp)
  801ce5:	00 
  801ce6:	c7 44 24 08 e7 2c 80 	movl   $0x802ce7,0x8(%esp)
  801ced:	00 
  801cee:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  801cf5:	00 
  801cf6:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  801cfd:	e8 3a e6 ff ff       	call   80033c <_panic>
	assert(r <= PGSIZE);
  801d02:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d07:	7e 24                	jle    801d2d <devfile_write+0xa6>
  801d09:	c7 44 24 0c 07 2d 80 	movl   $0x802d07,0xc(%esp)
  801d10:	00 
  801d11:	c7 44 24 08 e7 2c 80 	movl   $0x802ce7,0x8(%esp)
  801d18:	00 
  801d19:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  801d20:	00 
  801d21:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  801d28:	e8 0f e6 ff ff       	call   80033c <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  801d2d:	83 c4 14             	add    $0x14,%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	56                   	push   %esi
  801d37:	53                   	push   %ebx
  801d38:	83 ec 10             	sub    $0x10,%esp
  801d3b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d41:	8b 40 0c             	mov    0xc(%eax),%eax
  801d44:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d49:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d54:	b8 03 00 00 00       	mov    $0x3,%eax
  801d59:	e8 1e fe ff ff       	call   801b7c <fsipc>
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	85 c0                	test   %eax,%eax
  801d62:	78 6a                	js     801dce <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801d64:	39 c6                	cmp    %eax,%esi
  801d66:	73 24                	jae    801d8c <devfile_read+0x59>
  801d68:	c7 44 24 0c e0 2c 80 	movl   $0x802ce0,0xc(%esp)
  801d6f:	00 
  801d70:	c7 44 24 08 e7 2c 80 	movl   $0x802ce7,0x8(%esp)
  801d77:	00 
  801d78:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  801d7f:	00 
  801d80:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  801d87:	e8 b0 e5 ff ff       	call   80033c <_panic>
	assert(r <= PGSIZE);
  801d8c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d91:	7e 24                	jle    801db7 <devfile_read+0x84>
  801d93:	c7 44 24 0c 07 2d 80 	movl   $0x802d07,0xc(%esp)
  801d9a:	00 
  801d9b:	c7 44 24 08 e7 2c 80 	movl   $0x802ce7,0x8(%esp)
  801da2:	00 
  801da3:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801daa:	00 
  801dab:	c7 04 24 fc 2c 80 00 	movl   $0x802cfc,(%esp)
  801db2:	e8 85 e5 ff ff       	call   80033c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801db7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dbb:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dc2:	00 
  801dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc6:	89 04 24             	mov    %eax,(%esp)
  801dc9:	e8 8a ed ff ff       	call   800b58 <memmove>
	return r;
}
  801dce:	89 d8                	mov    %ebx,%eax
  801dd0:	83 c4 10             	add    $0x10,%esp
  801dd3:	5b                   	pop    %ebx
  801dd4:	5e                   	pop    %esi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    

00801dd7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	56                   	push   %esi
  801ddb:	53                   	push   %ebx
  801ddc:	83 ec 20             	sub    $0x20,%esp
  801ddf:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801de2:	89 34 24             	mov    %esi,(%esp)
  801de5:	e8 c2 eb ff ff       	call   8009ac <strlen>
  801dea:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801def:	7f 60                	jg     801e51 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801df1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df4:	89 04 24             	mov    %eax,(%esp)
  801df7:	e8 b3 f7 ff ff       	call   8015af <fd_alloc>
  801dfc:	89 c3                	mov    %eax,%ebx
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 54                	js     801e56 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e02:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e06:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e0d:	e8 cd eb ff ff       	call   8009df <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e15:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e22:	e8 55 fd ff ff       	call   801b7c <fsipc>
  801e27:	89 c3                	mov    %eax,%ebx
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	79 15                	jns    801e42 <open+0x6b>
		fd_close(fd, 0);
  801e2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e34:	00 
  801e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e38:	89 04 24             	mov    %eax,(%esp)
  801e3b:	e8 74 f8 ff ff       	call   8016b4 <fd_close>
		return r;
  801e40:	eb 14                	jmp    801e56 <open+0x7f>
	}

	return fd2num(fd);
  801e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e45:	89 04 24             	mov    %eax,(%esp)
  801e48:	e8 37 f7 ff ff       	call   801584 <fd2num>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	eb 05                	jmp    801e56 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e51:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e56:	89 d8                	mov    %ebx,%eax
  801e58:	83 c4 20             	add    $0x20,%esp
  801e5b:	5b                   	pop    %ebx
  801e5c:	5e                   	pop    %esi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e65:	ba 00 00 00 00       	mov    $0x0,%edx
  801e6a:	b8 08 00 00 00       	mov    $0x8,%eax
  801e6f:	e8 08 fd ff ff       	call   801b7c <fsipc>
}
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    
	...

00801e78 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	56                   	push   %esi
  801e7c:	53                   	push   %ebx
  801e7d:	83 ec 10             	sub    $0x10,%esp
  801e80:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e83:	8b 45 08             	mov    0x8(%ebp),%eax
  801e86:	89 04 24             	mov    %eax,(%esp)
  801e89:	e8 06 f7 ff ff       	call   801594 <fd2data>
  801e8e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e90:	c7 44 24 04 13 2d 80 	movl   $0x802d13,0x4(%esp)
  801e97:	00 
  801e98:	89 34 24             	mov    %esi,(%esp)
  801e9b:	e8 3f eb ff ff       	call   8009df <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ea0:	8b 43 04             	mov    0x4(%ebx),%eax
  801ea3:	2b 03                	sub    (%ebx),%eax
  801ea5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801eab:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801eb2:	00 00 00 
	stat->st_dev = &devpipe;
  801eb5:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801ebc:	30 80 00 
	return 0;
}
  801ebf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	5b                   	pop    %ebx
  801ec8:	5e                   	pop    %esi
  801ec9:	5d                   	pop    %ebp
  801eca:	c3                   	ret    

00801ecb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	53                   	push   %ebx
  801ecf:	83 ec 14             	sub    $0x14,%esp
  801ed2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ed5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ed9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ee0:	e8 93 ef ff ff       	call   800e78 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ee5:	89 1c 24             	mov    %ebx,(%esp)
  801ee8:	e8 a7 f6 ff ff       	call   801594 <fd2data>
  801eed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ef8:	e8 7b ef ff ff       	call   800e78 <sys_page_unmap>
}
  801efd:	83 c4 14             	add    $0x14,%esp
  801f00:	5b                   	pop    %ebx
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    

00801f03 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	57                   	push   %edi
  801f07:	56                   	push   %esi
  801f08:	53                   	push   %ebx
  801f09:	83 ec 2c             	sub    $0x2c,%esp
  801f0c:	89 c7                	mov    %eax,%edi
  801f0e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f11:	a1 04 40 80 00       	mov    0x804004,%eax
  801f16:	8b 00                	mov    (%eax),%eax
  801f18:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f1b:	89 3c 24             	mov    %edi,(%esp)
  801f1e:	e8 41 06 00 00       	call   802564 <pageref>
  801f23:	89 c6                	mov    %eax,%esi
  801f25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f28:	89 04 24             	mov    %eax,(%esp)
  801f2b:	e8 34 06 00 00       	call   802564 <pageref>
  801f30:	39 c6                	cmp    %eax,%esi
  801f32:	0f 94 c0             	sete   %al
  801f35:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f38:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f3e:	8b 12                	mov    (%edx),%edx
  801f40:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f43:	39 cb                	cmp    %ecx,%ebx
  801f45:	75 08                	jne    801f4f <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f47:	83 c4 2c             	add    $0x2c,%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f4f:	83 f8 01             	cmp    $0x1,%eax
  801f52:	75 bd                	jne    801f11 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f54:	8b 42 58             	mov    0x58(%edx),%eax
  801f57:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801f5e:	00 
  801f5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f67:	c7 04 24 1a 2d 80 00 	movl   $0x802d1a,(%esp)
  801f6e:	e8 c1 e4 ff ff       	call   800434 <cprintf>
  801f73:	eb 9c                	jmp    801f11 <_pipeisclosed+0xe>

00801f75 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	57                   	push   %edi
  801f79:	56                   	push   %esi
  801f7a:	53                   	push   %ebx
  801f7b:	83 ec 1c             	sub    $0x1c,%esp
  801f7e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f81:	89 34 24             	mov    %esi,(%esp)
  801f84:	e8 0b f6 ff ff       	call   801594 <fd2data>
  801f89:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8b:	bf 00 00 00 00       	mov    $0x0,%edi
  801f90:	eb 3c                	jmp    801fce <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f92:	89 da                	mov    %ebx,%edx
  801f94:	89 f0                	mov    %esi,%eax
  801f96:	e8 68 ff ff ff       	call   801f03 <_pipeisclosed>
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	75 38                	jne    801fd7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f9f:	e8 0e ee ff ff       	call   800db2 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fa4:	8b 43 04             	mov    0x4(%ebx),%eax
  801fa7:	8b 13                	mov    (%ebx),%edx
  801fa9:	83 c2 20             	add    $0x20,%edx
  801fac:	39 d0                	cmp    %edx,%eax
  801fae:	73 e2                	jae    801f92 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801fb6:	89 c2                	mov    %eax,%edx
  801fb8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801fbe:	79 05                	jns    801fc5 <devpipe_write+0x50>
  801fc0:	4a                   	dec    %edx
  801fc1:	83 ca e0             	or     $0xffffffe0,%edx
  801fc4:	42                   	inc    %edx
  801fc5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fc9:	40                   	inc    %eax
  801fca:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fcd:	47                   	inc    %edi
  801fce:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fd1:	75 d1                	jne    801fa4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fd3:	89 f8                	mov    %edi,%eax
  801fd5:	eb 05                	jmp    801fdc <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fd7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fdc:	83 c4 1c             	add    $0x1c,%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5f                   	pop    %edi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	57                   	push   %edi
  801fe8:	56                   	push   %esi
  801fe9:	53                   	push   %ebx
  801fea:	83 ec 1c             	sub    $0x1c,%esp
  801fed:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ff0:	89 3c 24             	mov    %edi,(%esp)
  801ff3:	e8 9c f5 ff ff       	call   801594 <fd2data>
  801ff8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ffa:	be 00 00 00 00       	mov    $0x0,%esi
  801fff:	eb 3a                	jmp    80203b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802001:	85 f6                	test   %esi,%esi
  802003:	74 04                	je     802009 <devpipe_read+0x25>
				return i;
  802005:	89 f0                	mov    %esi,%eax
  802007:	eb 40                	jmp    802049 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802009:	89 da                	mov    %ebx,%edx
  80200b:	89 f8                	mov    %edi,%eax
  80200d:	e8 f1 fe ff ff       	call   801f03 <_pipeisclosed>
  802012:	85 c0                	test   %eax,%eax
  802014:	75 2e                	jne    802044 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802016:	e8 97 ed ff ff       	call   800db2 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80201b:	8b 03                	mov    (%ebx),%eax
  80201d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802020:	74 df                	je     802001 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802022:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802027:	79 05                	jns    80202e <devpipe_read+0x4a>
  802029:	48                   	dec    %eax
  80202a:	83 c8 e0             	or     $0xffffffe0,%eax
  80202d:	40                   	inc    %eax
  80202e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802032:	8b 55 0c             	mov    0xc(%ebp),%edx
  802035:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802038:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80203a:	46                   	inc    %esi
  80203b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80203e:	75 db                	jne    80201b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802040:	89 f0                	mov    %esi,%eax
  802042:	eb 05                	jmp    802049 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802044:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802049:	83 c4 1c             	add    $0x1c,%esp
  80204c:	5b                   	pop    %ebx
  80204d:	5e                   	pop    %esi
  80204e:	5f                   	pop    %edi
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    

00802051 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	57                   	push   %edi
  802055:	56                   	push   %esi
  802056:	53                   	push   %ebx
  802057:	83 ec 3c             	sub    $0x3c,%esp
  80205a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80205d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802060:	89 04 24             	mov    %eax,(%esp)
  802063:	e8 47 f5 ff ff       	call   8015af <fd_alloc>
  802068:	89 c3                	mov    %eax,%ebx
  80206a:	85 c0                	test   %eax,%eax
  80206c:	0f 88 45 01 00 00    	js     8021b7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802072:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802079:	00 
  80207a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80207d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802081:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802088:	e8 44 ed ff ff       	call   800dd1 <sys_page_alloc>
  80208d:	89 c3                	mov    %eax,%ebx
  80208f:	85 c0                	test   %eax,%eax
  802091:	0f 88 20 01 00 00    	js     8021b7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802097:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80209a:	89 04 24             	mov    %eax,(%esp)
  80209d:	e8 0d f5 ff ff       	call   8015af <fd_alloc>
  8020a2:	89 c3                	mov    %eax,%ebx
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	0f 88 f8 00 00 00    	js     8021a4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ac:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020b3:	00 
  8020b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c2:	e8 0a ed ff ff       	call   800dd1 <sys_page_alloc>
  8020c7:	89 c3                	mov    %eax,%ebx
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	0f 88 d3 00 00 00    	js     8021a4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020d4:	89 04 24             	mov    %eax,(%esp)
  8020d7:	e8 b8 f4 ff ff       	call   801594 <fd2data>
  8020dc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020de:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020e5:	00 
  8020e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f1:	e8 db ec ff ff       	call   800dd1 <sys_page_alloc>
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	0f 88 91 00 00 00    	js     802191 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802100:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802103:	89 04 24             	mov    %eax,(%esp)
  802106:	e8 89 f4 ff ff       	call   801594 <fd2data>
  80210b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802112:	00 
  802113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80211e:	00 
  80211f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802123:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80212a:	e8 f6 ec ff ff       	call   800e25 <sys_page_map>
  80212f:	89 c3                	mov    %eax,%ebx
  802131:	85 c0                	test   %eax,%eax
  802133:	78 4c                	js     802181 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802135:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80213b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80213e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802140:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802143:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80214a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802150:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802153:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802155:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802158:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80215f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802162:	89 04 24             	mov    %eax,(%esp)
  802165:	e8 1a f4 ff ff       	call   801584 <fd2num>
  80216a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80216c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80216f:	89 04 24             	mov    %eax,(%esp)
  802172:	e8 0d f4 ff ff       	call   801584 <fd2num>
  802177:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80217a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80217f:	eb 36                	jmp    8021b7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802181:	89 74 24 04          	mov    %esi,0x4(%esp)
  802185:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80218c:	e8 e7 ec ff ff       	call   800e78 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802191:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802194:	89 44 24 04          	mov    %eax,0x4(%esp)
  802198:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80219f:	e8 d4 ec ff ff       	call   800e78 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8021a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b2:	e8 c1 ec ff ff       	call   800e78 <sys_page_unmap>
    err:
	return r;
}
  8021b7:	89 d8                	mov    %ebx,%eax
  8021b9:	83 c4 3c             	add    $0x3c,%esp
  8021bc:	5b                   	pop    %ebx
  8021bd:	5e                   	pop    %esi
  8021be:	5f                   	pop    %edi
  8021bf:	5d                   	pop    %ebp
  8021c0:	c3                   	ret    

008021c1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021c1:	55                   	push   %ebp
  8021c2:	89 e5                	mov    %esp,%ebp
  8021c4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d1:	89 04 24             	mov    %eax,(%esp)
  8021d4:	e8 29 f4 ff ff       	call   801602 <fd_lookup>
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	78 15                	js     8021f2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e0:	89 04 24             	mov    %eax,(%esp)
  8021e3:	e8 ac f3 ff ff       	call   801594 <fd2data>
	return _pipeisclosed(fd, p);
  8021e8:	89 c2                	mov    %eax,%edx
  8021ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ed:	e8 11 fd ff ff       	call   801f03 <_pipeisclosed>
}
  8021f2:	c9                   	leave  
  8021f3:	c3                   	ret    

008021f4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021fc:	5d                   	pop    %ebp
  8021fd:	c3                   	ret    

008021fe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802204:	c7 44 24 04 2d 2d 80 	movl   $0x802d2d,0x4(%esp)
  80220b:	00 
  80220c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220f:	89 04 24             	mov    %eax,(%esp)
  802212:	e8 c8 e7 ff ff       	call   8009df <strcpy>
	return 0;
}
  802217:	b8 00 00 00 00       	mov    $0x0,%eax
  80221c:	c9                   	leave  
  80221d:	c3                   	ret    

0080221e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80221e:	55                   	push   %ebp
  80221f:	89 e5                	mov    %esp,%ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80222a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80222f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802235:	eb 30                	jmp    802267 <devcons_write+0x49>
		m = n - tot;
  802237:	8b 75 10             	mov    0x10(%ebp),%esi
  80223a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80223c:	83 fe 7f             	cmp    $0x7f,%esi
  80223f:	76 05                	jbe    802246 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802241:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802246:	89 74 24 08          	mov    %esi,0x8(%esp)
  80224a:	03 45 0c             	add    0xc(%ebp),%eax
  80224d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802251:	89 3c 24             	mov    %edi,(%esp)
  802254:	e8 ff e8 ff ff       	call   800b58 <memmove>
		sys_cputs(buf, m);
  802259:	89 74 24 04          	mov    %esi,0x4(%esp)
  80225d:	89 3c 24             	mov    %edi,(%esp)
  802260:	e8 9f ea ff ff       	call   800d04 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802265:	01 f3                	add    %esi,%ebx
  802267:	89 d8                	mov    %ebx,%eax
  802269:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80226c:	72 c9                	jb     802237 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80226e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    

00802279 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80227f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802283:	75 07                	jne    80228c <devcons_read+0x13>
  802285:	eb 25                	jmp    8022ac <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802287:	e8 26 eb ff ff       	call   800db2 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80228c:	e8 91 ea ff ff       	call   800d22 <sys_cgetc>
  802291:	85 c0                	test   %eax,%eax
  802293:	74 f2                	je     802287 <devcons_read+0xe>
  802295:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802297:	85 c0                	test   %eax,%eax
  802299:	78 1d                	js     8022b8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80229b:	83 f8 04             	cmp    $0x4,%eax
  80229e:	74 13                	je     8022b3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8022a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a3:	88 10                	mov    %dl,(%eax)
	return 1;
  8022a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8022aa:	eb 0c                	jmp    8022b8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8022ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b1:	eb 05                	jmp    8022b8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022b3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022b8:	c9                   	leave  
  8022b9:	c3                   	ret    

008022ba <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022ba:	55                   	push   %ebp
  8022bb:	89 e5                	mov    %esp,%ebp
  8022bd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8022c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8022cd:	00 
  8022ce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022d1:	89 04 24             	mov    %eax,(%esp)
  8022d4:	e8 2b ea ff ff       	call   800d04 <sys_cputs>
}
  8022d9:	c9                   	leave  
  8022da:	c3                   	ret    

008022db <getchar>:

int
getchar(void)
{
  8022db:	55                   	push   %ebp
  8022dc:	89 e5                	mov    %esp,%ebp
  8022de:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022e1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8022e8:	00 
  8022e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f7:	e8 a4 f5 ff ff       	call   8018a0 <read>
	if (r < 0)
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	78 0f                	js     80230f <getchar+0x34>
		return r;
	if (r < 1)
  802300:	85 c0                	test   %eax,%eax
  802302:	7e 06                	jle    80230a <getchar+0x2f>
		return -E_EOF;
	return c;
  802304:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802308:	eb 05                	jmp    80230f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80230a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80230f:	c9                   	leave  
  802310:	c3                   	ret    

00802311 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802311:	55                   	push   %ebp
  802312:	89 e5                	mov    %esp,%ebp
  802314:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802317:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80231a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80231e:	8b 45 08             	mov    0x8(%ebp),%eax
  802321:	89 04 24             	mov    %eax,(%esp)
  802324:	e8 d9 f2 ff ff       	call   801602 <fd_lookup>
  802329:	85 c0                	test   %eax,%eax
  80232b:	78 11                	js     80233e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80232d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802330:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802336:	39 10                	cmp    %edx,(%eax)
  802338:	0f 94 c0             	sete   %al
  80233b:	0f b6 c0             	movzbl %al,%eax
}
  80233e:	c9                   	leave  
  80233f:	c3                   	ret    

00802340 <opencons>:

int
opencons(void)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802346:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802349:	89 04 24             	mov    %eax,(%esp)
  80234c:	e8 5e f2 ff ff       	call   8015af <fd_alloc>
  802351:	85 c0                	test   %eax,%eax
  802353:	78 3c                	js     802391 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802355:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80235c:	00 
  80235d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802360:	89 44 24 04          	mov    %eax,0x4(%esp)
  802364:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80236b:	e8 61 ea ff ff       	call   800dd1 <sys_page_alloc>
  802370:	85 c0                	test   %eax,%eax
  802372:	78 1d                	js     802391 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802374:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80237a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80237f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802382:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802389:	89 04 24             	mov    %eax,(%esp)
  80238c:	e8 f3 f1 ff ff       	call   801584 <fd2num>
}
  802391:	c9                   	leave  
  802392:	c3                   	ret    
	...

00802394 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
  802397:	53                   	push   %ebx
  802398:	83 ec 14             	sub    $0x14,%esp
	int r;

	if (_pgfault_handler == 0) {
  80239b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8023a2:	75 6f                	jne    802413 <set_pgfault_handler+0x7f>
		// First time through!
		// LAB 4: Your code here.
		// cprintf("%x\n",handler);
		envid_t eid = sys_getenvid();
  8023a4:	e8 ea e9 ff ff       	call   800d93 <sys_getenvid>
  8023a9:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(eid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  8023ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8023b2:	00 
  8023b3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8023ba:	ee 
  8023bb:	89 04 24             	mov    %eax,(%esp)
  8023be:	e8 0e ea ff ff       	call   800dd1 <sys_page_alloc>
		if (r<0)panic("set_pgfault_handler: sys_page_alloc\n");
  8023c3:	85 c0                	test   %eax,%eax
  8023c5:	79 1c                	jns    8023e3 <set_pgfault_handler+0x4f>
  8023c7:	c7 44 24 08 3c 2d 80 	movl   $0x802d3c,0x8(%esp)
  8023ce:	00 
  8023cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8023d6:	00 
  8023d7:	c7 04 24 98 2d 80 00 	movl   $0x802d98,(%esp)
  8023de:	e8 59 df ff ff       	call   80033c <_panic>
		r = sys_env_set_pgfault_upcall(eid,_pgfault_upcall);
  8023e3:	c7 44 24 04 24 24 80 	movl   $0x802424,0x4(%esp)
  8023ea:	00 
  8023eb:	89 1c 24             	mov    %ebx,(%esp)
  8023ee:	e8 7e eb ff ff       	call   800f71 <sys_env_set_pgfault_upcall>
		if (r<0)panic("set_pgfault_handler: sys_env_set_pgfault_upcall\n");
  8023f3:	85 c0                	test   %eax,%eax
  8023f5:	79 1c                	jns    802413 <set_pgfault_handler+0x7f>
  8023f7:	c7 44 24 08 64 2d 80 	movl   $0x802d64,0x8(%esp)
  8023fe:	00 
  8023ff:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  802406:	00 
  802407:	c7 04 24 98 2d 80 00 	movl   $0x802d98,(%esp)
  80240e:	e8 29 df ff ff       	call   80033c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802413:	8b 45 08             	mov    0x8(%ebp),%eax
  802416:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80241b:	83 c4 14             	add    $0x14,%esp
  80241e:	5b                   	pop    %ebx
  80241f:	5d                   	pop    %ebp
  802420:	c3                   	ret    
  802421:	00 00                	add    %al,(%eax)
	...

00802424 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802424:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802425:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80242a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80242c:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax
  80242f:	8b 44 24 28          	mov    0x28(%esp),%eax
	subl $0x4, 0x30(%esp)
  802433:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %ebx
  802438:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, (%ebx)
  80243c:	89 03                	mov    %eax,(%ebx)
	addl $8,%esp
  80243e:	83 c4 08             	add    $0x8,%esp
	popal
  802441:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4,%esp
  802442:	83 c4 04             	add    $0x4,%esp
	popfl
  802445:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp),%esp
  802446:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802449:	c3                   	ret    
	...

0080244c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80244c:	55                   	push   %ebp
  80244d:	89 e5                	mov    %esp,%ebp
  80244f:	56                   	push   %esi
  802450:	53                   	push   %ebx
  802451:	83 ec 10             	sub    $0x10,%esp
  802454:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80245a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  80245d:	85 c0                	test   %eax,%eax
  80245f:	75 05                	jne    802466 <ipc_recv+0x1a>
  802461:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  802466:	89 04 24             	mov    %eax,(%esp)
  802469:	e8 79 eb ff ff       	call   800fe7 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  80246e:	85 c0                	test   %eax,%eax
  802470:	79 16                	jns    802488 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  802472:	85 db                	test   %ebx,%ebx
  802474:	74 06                	je     80247c <ipc_recv+0x30>
  802476:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  80247c:	85 f6                	test   %esi,%esi
  80247e:	74 32                	je     8024b2 <ipc_recv+0x66>
  802480:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802486:	eb 2a                	jmp    8024b2 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802488:	85 db                	test   %ebx,%ebx
  80248a:	74 0c                	je     802498 <ipc_recv+0x4c>
  80248c:	a1 04 40 80 00       	mov    0x804004,%eax
  802491:	8b 00                	mov    (%eax),%eax
  802493:	8b 40 74             	mov    0x74(%eax),%eax
  802496:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802498:	85 f6                	test   %esi,%esi
  80249a:	74 0c                	je     8024a8 <ipc_recv+0x5c>
  80249c:	a1 04 40 80 00       	mov    0x804004,%eax
  8024a1:	8b 00                	mov    (%eax),%eax
  8024a3:	8b 40 78             	mov    0x78(%eax),%eax
  8024a6:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  8024a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8024ad:	8b 00                	mov    (%eax),%eax
  8024af:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  8024b2:	83 c4 10             	add    $0x10,%esp
  8024b5:	5b                   	pop    %ebx
  8024b6:	5e                   	pop    %esi
  8024b7:	5d                   	pop    %ebp
  8024b8:	c3                   	ret    

008024b9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024b9:	55                   	push   %ebp
  8024ba:	89 e5                	mov    %esp,%ebp
  8024bc:	57                   	push   %edi
  8024bd:	56                   	push   %esi
  8024be:	53                   	push   %ebx
  8024bf:	83 ec 1c             	sub    $0x1c,%esp
  8024c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024c8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  8024cb:	85 db                	test   %ebx,%ebx
  8024cd:	75 05                	jne    8024d4 <ipc_send+0x1b>
  8024cf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  8024d4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8024d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e3:	89 04 24             	mov    %eax,(%esp)
  8024e6:	e8 d9 ea ff ff       	call   800fc4 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  8024eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024ee:	75 07                	jne    8024f7 <ipc_send+0x3e>
  8024f0:	e8 bd e8 ff ff       	call   800db2 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  8024f5:	eb dd                	jmp    8024d4 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  8024f7:	85 c0                	test   %eax,%eax
  8024f9:	79 1c                	jns    802517 <ipc_send+0x5e>
  8024fb:	c7 44 24 08 a6 2d 80 	movl   $0x802da6,0x8(%esp)
  802502:	00 
  802503:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80250a:	00 
  80250b:	c7 04 24 b8 2d 80 00 	movl   $0x802db8,(%esp)
  802512:	e8 25 de ff ff       	call   80033c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  802517:	83 c4 1c             	add    $0x1c,%esp
  80251a:	5b                   	pop    %ebx
  80251b:	5e                   	pop    %esi
  80251c:	5f                   	pop    %edi
  80251d:	5d                   	pop    %ebp
  80251e:	c3                   	ret    

0080251f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80251f:	55                   	push   %ebp
  802520:	89 e5                	mov    %esp,%ebp
  802522:	53                   	push   %ebx
  802523:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802526:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80252b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802532:	89 c2                	mov    %eax,%edx
  802534:	c1 e2 07             	shl    $0x7,%edx
  802537:	29 ca                	sub    %ecx,%edx
  802539:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80253f:	8b 52 50             	mov    0x50(%edx),%edx
  802542:	39 da                	cmp    %ebx,%edx
  802544:	75 0f                	jne    802555 <ipc_find_env+0x36>
			return envs[i].env_id;
  802546:	c1 e0 07             	shl    $0x7,%eax
  802549:	29 c8                	sub    %ecx,%eax
  80254b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802550:	8b 40 40             	mov    0x40(%eax),%eax
  802553:	eb 0c                	jmp    802561 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802555:	40                   	inc    %eax
  802556:	3d 00 04 00 00       	cmp    $0x400,%eax
  80255b:	75 ce                	jne    80252b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80255d:	66 b8 00 00          	mov    $0x0,%ax
}
  802561:	5b                   	pop    %ebx
  802562:	5d                   	pop    %ebp
  802563:	c3                   	ret    

00802564 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802564:	55                   	push   %ebp
  802565:	89 e5                	mov    %esp,%ebp
  802567:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  80256a:	89 c2                	mov    %eax,%edx
  80256c:	c1 ea 16             	shr    $0x16,%edx
  80256f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802576:	f6 c2 01             	test   $0x1,%dl
  802579:	74 1e                	je     802599 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80257b:	c1 e8 0c             	shr    $0xc,%eax
  80257e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802585:	a8 01                	test   $0x1,%al
  802587:	74 17                	je     8025a0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802589:	c1 e8 0c             	shr    $0xc,%eax
  80258c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802593:	ef 
  802594:	0f b7 c0             	movzwl %ax,%eax
  802597:	eb 0c                	jmp    8025a5 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802599:	b8 00 00 00 00       	mov    $0x0,%eax
  80259e:	eb 05                	jmp    8025a5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8025a0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8025a5:	5d                   	pop    %ebp
  8025a6:	c3                   	ret    
	...

008025a8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8025a8:	55                   	push   %ebp
  8025a9:	57                   	push   %edi
  8025aa:	56                   	push   %esi
  8025ab:	83 ec 10             	sub    $0x10,%esp
  8025ae:	8b 74 24 20          	mov    0x20(%esp),%esi
  8025b2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ba:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8025be:	89 cd                	mov    %ecx,%ebp
  8025c0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025c4:	85 c0                	test   %eax,%eax
  8025c6:	75 2c                	jne    8025f4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8025c8:	39 f9                	cmp    %edi,%ecx
  8025ca:	77 68                	ja     802634 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025cc:	85 c9                	test   %ecx,%ecx
  8025ce:	75 0b                	jne    8025db <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d5:	31 d2                	xor    %edx,%edx
  8025d7:	f7 f1                	div    %ecx
  8025d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025db:	31 d2                	xor    %edx,%edx
  8025dd:	89 f8                	mov    %edi,%eax
  8025df:	f7 f1                	div    %ecx
  8025e1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025e3:	89 f0                	mov    %esi,%eax
  8025e5:	f7 f1                	div    %ecx
  8025e7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025e9:	89 f0                	mov    %esi,%eax
  8025eb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025ed:	83 c4 10             	add    $0x10,%esp
  8025f0:	5e                   	pop    %esi
  8025f1:	5f                   	pop    %edi
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025f4:	39 f8                	cmp    %edi,%eax
  8025f6:	77 2c                	ja     802624 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025f8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8025fb:	83 f6 1f             	xor    $0x1f,%esi
  8025fe:	75 4c                	jne    80264c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802600:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802602:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802607:	72 0a                	jb     802613 <__udivdi3+0x6b>
  802609:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80260d:	0f 87 ad 00 00 00    	ja     8026c0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802613:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802618:	89 f0                	mov    %esi,%eax
  80261a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80261c:	83 c4 10             	add    $0x10,%esp
  80261f:	5e                   	pop    %esi
  802620:	5f                   	pop    %edi
  802621:	5d                   	pop    %ebp
  802622:	c3                   	ret    
  802623:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802624:	31 ff                	xor    %edi,%edi
  802626:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802628:	89 f0                	mov    %esi,%eax
  80262a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80262c:	83 c4 10             	add    $0x10,%esp
  80262f:	5e                   	pop    %esi
  802630:	5f                   	pop    %edi
  802631:	5d                   	pop    %ebp
  802632:	c3                   	ret    
  802633:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802634:	89 fa                	mov    %edi,%edx
  802636:	89 f0                	mov    %esi,%eax
  802638:	f7 f1                	div    %ecx
  80263a:	89 c6                	mov    %eax,%esi
  80263c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80263e:	89 f0                	mov    %esi,%eax
  802640:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802642:	83 c4 10             	add    $0x10,%esp
  802645:	5e                   	pop    %esi
  802646:	5f                   	pop    %edi
  802647:	5d                   	pop    %ebp
  802648:	c3                   	ret    
  802649:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80264c:	89 f1                	mov    %esi,%ecx
  80264e:	d3 e0                	shl    %cl,%eax
  802650:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802654:	b8 20 00 00 00       	mov    $0x20,%eax
  802659:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80265b:	89 ea                	mov    %ebp,%edx
  80265d:	88 c1                	mov    %al,%cl
  80265f:	d3 ea                	shr    %cl,%edx
  802661:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802665:	09 ca                	or     %ecx,%edx
  802667:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80266b:	89 f1                	mov    %esi,%ecx
  80266d:	d3 e5                	shl    %cl,%ebp
  80266f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802673:	89 fd                	mov    %edi,%ebp
  802675:	88 c1                	mov    %al,%cl
  802677:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802679:	89 fa                	mov    %edi,%edx
  80267b:	89 f1                	mov    %esi,%ecx
  80267d:	d3 e2                	shl    %cl,%edx
  80267f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802683:	88 c1                	mov    %al,%cl
  802685:	d3 ef                	shr    %cl,%edi
  802687:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802689:	89 f8                	mov    %edi,%eax
  80268b:	89 ea                	mov    %ebp,%edx
  80268d:	f7 74 24 08          	divl   0x8(%esp)
  802691:	89 d1                	mov    %edx,%ecx
  802693:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802695:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802699:	39 d1                	cmp    %edx,%ecx
  80269b:	72 17                	jb     8026b4 <__udivdi3+0x10c>
  80269d:	74 09                	je     8026a8 <__udivdi3+0x100>
  80269f:	89 fe                	mov    %edi,%esi
  8026a1:	31 ff                	xor    %edi,%edi
  8026a3:	e9 41 ff ff ff       	jmp    8025e9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8026a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026ac:	89 f1                	mov    %esi,%ecx
  8026ae:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026b0:	39 c2                	cmp    %eax,%edx
  8026b2:	73 eb                	jae    80269f <__udivdi3+0xf7>
		{
		  q0--;
  8026b4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026b7:	31 ff                	xor    %edi,%edi
  8026b9:	e9 2b ff ff ff       	jmp    8025e9 <__udivdi3+0x41>
  8026be:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026c0:	31 f6                	xor    %esi,%esi
  8026c2:	e9 22 ff ff ff       	jmp    8025e9 <__udivdi3+0x41>
	...

008026c8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8026c8:	55                   	push   %ebp
  8026c9:	57                   	push   %edi
  8026ca:	56                   	push   %esi
  8026cb:	83 ec 20             	sub    $0x20,%esp
  8026ce:	8b 44 24 30          	mov    0x30(%esp),%eax
  8026d2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026d6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8026da:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8026de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026e2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8026e6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8026e8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026ea:	85 ed                	test   %ebp,%ebp
  8026ec:	75 16                	jne    802704 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8026ee:	39 f1                	cmp    %esi,%ecx
  8026f0:	0f 86 a6 00 00 00    	jbe    80279c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026f6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8026f8:	89 d0                	mov    %edx,%eax
  8026fa:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026fc:	83 c4 20             	add    $0x20,%esp
  8026ff:	5e                   	pop    %esi
  802700:	5f                   	pop    %edi
  802701:	5d                   	pop    %ebp
  802702:	c3                   	ret    
  802703:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802704:	39 f5                	cmp    %esi,%ebp
  802706:	0f 87 ac 00 00 00    	ja     8027b8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80270c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80270f:	83 f0 1f             	xor    $0x1f,%eax
  802712:	89 44 24 10          	mov    %eax,0x10(%esp)
  802716:	0f 84 a8 00 00 00    	je     8027c4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80271c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802720:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802722:	bf 20 00 00 00       	mov    $0x20,%edi
  802727:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80272b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80272f:	89 f9                	mov    %edi,%ecx
  802731:	d3 e8                	shr    %cl,%eax
  802733:	09 e8                	or     %ebp,%eax
  802735:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802739:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80273d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802741:	d3 e0                	shl    %cl,%eax
  802743:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802747:	89 f2                	mov    %esi,%edx
  802749:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80274b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80274f:	d3 e0                	shl    %cl,%eax
  802751:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802755:	8b 44 24 14          	mov    0x14(%esp),%eax
  802759:	89 f9                	mov    %edi,%ecx
  80275b:	d3 e8                	shr    %cl,%eax
  80275d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80275f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802761:	89 f2                	mov    %esi,%edx
  802763:	f7 74 24 18          	divl   0x18(%esp)
  802767:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802769:	f7 64 24 0c          	mull   0xc(%esp)
  80276d:	89 c5                	mov    %eax,%ebp
  80276f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802771:	39 d6                	cmp    %edx,%esi
  802773:	72 67                	jb     8027dc <__umoddi3+0x114>
  802775:	74 75                	je     8027ec <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802777:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80277b:	29 e8                	sub    %ebp,%eax
  80277d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80277f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802783:	d3 e8                	shr    %cl,%eax
  802785:	89 f2                	mov    %esi,%edx
  802787:	89 f9                	mov    %edi,%ecx
  802789:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80278b:	09 d0                	or     %edx,%eax
  80278d:	89 f2                	mov    %esi,%edx
  80278f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802793:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802795:	83 c4 20             	add    $0x20,%esp
  802798:	5e                   	pop    %esi
  802799:	5f                   	pop    %edi
  80279a:	5d                   	pop    %ebp
  80279b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80279c:	85 c9                	test   %ecx,%ecx
  80279e:	75 0b                	jne    8027ab <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8027a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8027a5:	31 d2                	xor    %edx,%edx
  8027a7:	f7 f1                	div    %ecx
  8027a9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8027ab:	89 f0                	mov    %esi,%eax
  8027ad:	31 d2                	xor    %edx,%edx
  8027af:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027b1:	89 f8                	mov    %edi,%eax
  8027b3:	e9 3e ff ff ff       	jmp    8026f6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8027b8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027ba:	83 c4 20             	add    $0x20,%esp
  8027bd:	5e                   	pop    %esi
  8027be:	5f                   	pop    %edi
  8027bf:	5d                   	pop    %ebp
  8027c0:	c3                   	ret    
  8027c1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8027c4:	39 f5                	cmp    %esi,%ebp
  8027c6:	72 04                	jb     8027cc <__umoddi3+0x104>
  8027c8:	39 f9                	cmp    %edi,%ecx
  8027ca:	77 06                	ja     8027d2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027cc:	89 f2                	mov    %esi,%edx
  8027ce:	29 cf                	sub    %ecx,%edi
  8027d0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8027d2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8027d4:	83 c4 20             	add    $0x20,%esp
  8027d7:	5e                   	pop    %esi
  8027d8:	5f                   	pop    %edi
  8027d9:	5d                   	pop    %ebp
  8027da:	c3                   	ret    
  8027db:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027dc:	89 d1                	mov    %edx,%ecx
  8027de:	89 c5                	mov    %eax,%ebp
  8027e0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8027e4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8027e8:	eb 8d                	jmp    802777 <__umoddi3+0xaf>
  8027ea:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027ec:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8027f0:	72 ea                	jb     8027dc <__umoddi3+0x114>
  8027f2:	89 f1                	mov    %esi,%ecx
  8027f4:	eb 81                	jmp    802777 <__umoddi3+0xaf>
